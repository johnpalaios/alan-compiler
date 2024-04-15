%{
#define T_eof 0

#define T_proc 667
#define T_if 668
#define T_else 669
#define T_while 670
#define T_true 672
#define T_false 672
#define T_return 673

#define T_reference 674

#define T_int 675
#define T_byte 676

#define T_const 700
#define T_id 701

#define T_esc_seq 702
#define T_const_char_esc_seq 703
#define T_const_char 704
#define T_const_string 705

#define T_symb_op 706
#define T_separator 707

int num_lines = 0;
//int num_chars = 0;

%}


ID [a-zA-Z][a-zA-Z0-9_]*
ESC_SEQ \\([tnr0'"]|[x][0-9a-d][0-9a-d]|\\)
L [a-z]
D [0-9]
W [ \t\r]
U [_]
CONST_CHAR \'[ -~^\\"']\'
CONST_ES_CHAR \'\\([tnr0'"]|[x][0-9a-d][0-9a-d]|\\)\'
CONST_STR \"[^\n]+\"
SYMB_OPS "="|"=="|"!="|">"|"<"|">="|"<="|"+"|"-"|"*"|"/"|"%"|"!"|"&"|"|"
SEPARATORS "("|")"|"["|"]"|"{"|"}"|","|":"|";"
L_COMMENT "--".*\n
ML_COMMENT \(\*([^*]|\*[^)])*\*+\)
%option noyywrap

%%
{L_COMMENT}  { ++num_lines; }
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

{CONST_ES_CHAR} { return T_const_char_esc_seq; }
{CONST_CHAR}  	{ return T_const_char; }
{CONST_STR}	  	{ return T_const_string; }
{SYMB_OPS} 		{ return T_symb_op; }
{SEPARATORS}  	{ return T_separator; }
 
"proc"  	{ return T_proc; }
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
{D}+    	{ return T_const; }
{W}+    	{ /* Do nothing */ }

\n 			{ ++num_lines; }
.   		{ fprintf(stderr, "Illegal character %c at line %d\n", yytext[0], num_lines); }

%%

int main() {
    int token;
    do {
        token = yylex();
        printf("token = %d, lexeme = %s\n", token, yytext);
    } while(token != T_eof);
    return 0;
}


