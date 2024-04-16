%{
#include "lexer.h"
#include "parser.h"
#include <string.h>
#define T_eof 0

int num_lines = 0;

%}


ID [a-zA-Z][a-zA-Z0-9_]*
ESC_SEQ \\([tnr0'"]|[x][0-9a-d][0-9a-d]|\\)
L [a-z]
D [0-9]
W [ \t\r]
CONST_ES_CHAR \'[ -~^\\"']\'
CONST_CHAR \'(\\([tnr0'"]|[x][0-9a-d][0-9a-d]|\\)|[ -~^\\"'])\'
CONST_STR \"[^\n]+\"

MATH_OPS "="|"+"|"-"|"*"|"/"|"%"
REL_OPS "=="|"!="|">"|"<"|">="|"<="
LOG_OPS "&"|"|"|"!"
SEPARATORS "("|")"|"["|"]"|"{"|"}"|","|":"|";"
L_COMMENT "--".*\n
ML_COMMENT \(\*([^*]|\*[^)])*\*+\)
%option noyywrap

%%

"proc"		{ return T_proc; }
"if"  		{ return T_if; }
"else"   	{ return T_else; }
"while"    	{ return T_while; }
"true"   	{ return T_true; }
"false" 	{ return T_false; }
"return"    { return T_return; }

"reference" { return T_reference; }

"int"   	{ return T_int; }
"byte"  	{ return T_byte; }

{ID}     	{ return T_id; }
{D}+    	{ yylval.int_val = atoi(yytext); return T_int_const; }
{W}+    	{ /* Do nothing */ }

{CONST_CHAR}    {
					/* 
						2 cases : 
					1. A character or digit etc.
					2. An escape sequence 
					*/
					char const_char = getConstChar(yytext);
					if(const_char == '\0') {
						fprintf(stderr, "Illegal character %c at line %d\n", yytext[0], num_lines); 
					}
    			    yylval.char_val = const_char;	
					printf("Char val = %c\n", const_char);				
					return T_char_const;
				}

{CONST_STR}     {  yylval.string_val = yytext; return T_string_literal; }

{REL_OPS}      	{ yylval.string_val = yytext;  return T_rel_op; }
{LOG_OPS}      	{ yylval.char_val = yytext[0]; return yytext[0]; }
{MATH_OPS}      { yylval.char_val = yytext[0]; return yytext[0]; }
{SEPARATORS}    { return yytext[0]; }

\n 			{ ++num_lines; }
{L_COMMENT}  { printf("Line Comment on line %d\n",++num_lines);}
{ML_COMMENT} {
                int i = 0;
                while(yytext[i] != '\0') {
                    char c = yytext[i];
                    if (c == '\n') {
                        ++num_lines;
                    }
                    if (c == ')' && yytext[i-1] == '*') {
                        printf("End of Comment on line %d\n", num_lines);
                        break;
                    }
                    i++;
                }
                return 1000;
            }
.   		{ fprintf(stderr, "Illegal character %c at line %d\n", yytext[0], num_lines); }

%%
char getConstChar(const char *c) {
	char ch;
	int result = 1;
	int n = strlen(c);
    if(n == 3) {
        ch = c[1];
    } else if (n == 4) {
        result = sscanf(c,  "\'\\%s\'", &ch);
        switch(ch) {
            case 'n':
                ch = '\n';
                break;
            case 't':
                ch = '\t';
                break;
            case 'r':
                ch = '\r';
                break;
            case '0':
                ch = '\0';
                break;
            case '\\':
                ch = '\\';
                break;
            case '\'':
                ch = '\'';
                break;
            case '\"':
                ch = '\"';
                break;
        }
    } else if (n == 6) {
        result = sscanf(c,  "'\\x%hhx'", &ch);
    }
	return result == 1 ? ch : '\0';
}

int main() {
    int token;
    do {
        token = yylex();
        printf("token = %d, lexeme = %s\n", token, yytext);
    } while(token != T_eof);
    return 0;
}


