%{
#include "lexer.h"
#include "parser.h"
#include <string.h>
#define T_eof 0

int num_lines = 0;
int MAX_STR_CONST = 10000;
void throw_err(const char *error_msg, int line_num, char *err_str);
char *string_buf_ptr;
%}


ID [a-zA-Z][a-zA-Z0-9_]*
ESC_SEQ \\([tnr0'"]|[x][0-9a-d][0-9a-d]|\\)
L [a-z]
D [0-9]
W [ \t\r]
CONST_ES_CHAR \'[ -~^\\"']\'
CONST_CHAR \'(\\([tnr0'"]|[x][0-9a-d][0-9a-d]|\\)|[ -~^\\"'])\'
CONST_STR \"[^\n]+\"
HEX_VALUE [0-9a-f]{2}

MATH_OPS "="|"+"|"-"|"*"|"/"|"%"
REL_OPS "=="|"!="|">"|"<"|">="|"<="
LOG_OPS "&"|"|"|"!"
SEPARATORS "("|")"|"["|"]"|"{"|"}"|","|":"|";"
L_COMMENT "--".*\n
ML_COMMENT \(\*([^*]|\*[^)])*\*+\)

%option noyywrap
%option yylineno

%x chr
%x chr_esc_seq

%x str
%x str_esc_seq
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
				
\' 			{ 	/* Starting char quote */	BEGIN(chr); }
<chr>[^\\\']\' {	BEGIN(INITIAL); yylval.char_val = yytext[0]; return T_char_const; }
<chr>\\ 	{	BEGIN(chr_esc_seq);	}
<chr>.		{ 	throw_err("Single Quotes with more than one character", yylineno, yytext); }

<chr_esc_seq>n\'	{   BEGIN(INITIAL); yylval.char_val ='\n'; return T_char_const; }
<chr_esc_seq>t\'	{   BEGIN(INITIAL); yylval.char_val ='\t'; return T_char_const; }
<chr_esc_seq>r\'	{   BEGIN(INITIAL); yylval.char_val ='\r'; return T_char_const; }
<chr_esc_seq>0\'	{   BEGIN(INITIAL); yylval.char_val ='\0'; return T_char_const; }
<chr_esc_seq>\\\'	{   BEGIN(INITIAL); yylval.char_val ='\\'; return T_char_const; }
<chr_esc_seq>\'\'	{   BEGIN(INITIAL); yylval.char_val ='\''; return T_char_const; }
<chr_esc_seq>\"\'	{   BEGIN(INITIAL); yylval.char_val ='\"'; return T_char_const; }					   	  
<chr_esc_seq>x{HEX_VALUE}\' {   BEGIN(INITIAL); char hex_ch; sscanf(yytext,  "x%hhx", &hex_ch);
                                yylval.char_val = hex_ch; return T_char_const; }

<chr_esc_seq>.	{ 	throw_err("Single Quotes with more than one character", yylineno, yytext); }

\"				{ 	/* Starting string quote */	
					char str_buf[MAX_STR_CONST];
					string_buf_ptr = str_buf;
					yylval.string_val = str_buf; 
				 	BEGIN(str);	
				}
<str>\"			{	/* Final string quote */
					*string_buf_ptr = '\0';
					BEGIN(INITIAL); 
					//printf("yylval.string_val : %s|\n", yylval.string_val); 
					return T_string_lit; }

<str>\n			{   throw_err("New line character detected on string", yylineno, "\\n"); }	
<str>\\			{ 	BEGIN(str_esc_seq); /* Backslash detected */ }
<str>[^\\\"\n]+ {	BEGIN(str);
					char *yptr = yytext;
            		while ( *yptr )
                    	*string_buf_ptr++ = *yptr++;
            	}  


<str_esc_seq>n 				{   *string_buf_ptr++ = '\n'; BEGIN(str); }
<str_esc_seq>t 				{   *string_buf_ptr++ = '\t'; BEGIN(str); }
<str_esc_seq>r 				{   *string_buf_ptr++ = '\r'; BEGIN(str); }
<str_esc_seq>\\ 			{   *string_buf_ptr++ = '\\'; BEGIN(str); }
<str_esc_seq>\' 			{   *string_buf_ptr++ = '\''; BEGIN(str); }
<str_esc_seq>\" 			{   *string_buf_ptr++ = '\"'; BEGIN(str); }
<str_esc_seq>x{HEX_VALUE} 	{   char hex_ch; sscanf(yytext,  "x%hhx", &hex_ch);
								*string_buf_ptr++ = hex_ch; BEGIN(str); }
<str_esc_seq>.				{ 	throw_err("Not known escape sequence", yylineno, yytext); }

{REL_OPS}      	{ yylval.string_val = yytext;  return T_rel_op; }
{LOG_OPS}      	{ yylval.char_val = yytext[0]; return yytext[0]; }
{MATH_OPS}      { yylval.char_val = yytext[0]; return yytext[0]; }
{SEPARATORS}    { return yytext[0]; }

\n 				{ ++num_lines; }
{L_COMMENT}  	{ printf("Line Comment on line %d\n",++num_lines); }
{ML_COMMENT} 	{  int i = 0;
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

// {CONST_STR}     {  printf("ehey!\n");yylval.string_val = yytext; return T_string_lit; }
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


void throw_err(const char *error_msg, int line_num, char *err_str) {
	fprintf(stderr, "Flex Error : '%s' at line %d and char '%s'.\n", error_msg, line_num, err_str);
	exit(1);
}

int main() {
    int token;
    do {
        token = yylex();
    	if(token == T_string_lit) {
			printf("yylval.string_val : \"%s\"\n", yylval.string_val);
		} else if(token == T_char_const) {
			printf("yylval.char_val : \'%c\'\n", yylval.char_val);
		} else {
        	printf("token = %d, lexeme = %s\n", token, yytext);
		} 
	} while(token != T_eof);
    return 0;
}


