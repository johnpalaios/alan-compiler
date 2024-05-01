%{
#include <stdio.h>
#include <stdlib.h>
#include "lexer.h"
%}
%union {
	char char_val;
	char *string_val;
	int int_val;
}

%token T_proc   	"proc"
%token T_if     	"if"
%token T_else   	"else"
%token T_while  	"while"
%token T_true   	"true"
%token T_false  	"false"
%token T_return 	"return"
%token T_reference  "reference"
%token T_int 	 	"int"
%token T_byte 	 	"byte"

%token T_int_const
%token T_char_const
%token T_string_lit
%token T_id

%token<string_val> T_rel_op 
%token<char_val> T_log_op

%precedence '!'
%left T_log_op
%left '&' '|' 
%left '+' '-' 
%left '*' '/' '%'
%nonassoc T_rel_op ':'

%expect 1

%%

program 	: func_def
			;

func_def 	: T_id '(' fpar_list ')' ':' r_type local_def compound_stmt
			;

fpar_list	: /* nothing */
		  	| fpar_def fpar_list
			| ',' fpar_def fpar_list
			;

fpar_def 	: T_id ':' "reference" type
			| T_id ':' type
			;

data_type 	: "int"
			| "byte"
			;

type		: data_type
			| data_type '[' ']'
			;

r_type		: data_type
			| "proc"
			;

local_def	: /* nothing */ 
			| func_def local_def
			| var_def local_def
			;

var_def		: T_id ':' data_type ';'
			| T_id ':' data_type '[' T_int_const ']' ';'
			;

stmt		: ';' 
			| l_value '=' expr ';'
			| compound_stmt
			| func_call ';'
			| "if" '(' cond ')' stmt 
			| "if" '(' cond ')' stmt "else" stmt
			| "while" '(' cond ')' stmt 
			| "return" ';'
			| "return" expr ';' 
			; 

compound_stmt	: '{'  stmt_list '}'
				; 

stmt_list 	: /* nothing */
			| stmt_list stmt
			;

func_call 	: T_id '(' ')'
			| T_id '(' expr expr_list ')'
			;

expr_list	: /* nothing */
			| ',' expr expr_list
			;

expr 		: T_int_const
			| T_char_const
			| l_value
			| '(' expr ')' 
			| func_call 
			| '+' expr
			| '-' expr
			| expr '+' expr
			| expr '-' expr
			| expr '*' expr
			| expr '/' expr
			| expr '%' expr
			;

l_value		: T_id
			| T_id '[' expr ']'
			| T_string_lit 
 			;

cond 		: "true"
			| "false"
			| '(' cond ')' 
			| '!' cond
			| expr T_rel_op expr
			| cond '&' cond
			| cond '|' cond
			;

%%

void yyerror(const char *msg) {
  fprintf(stderr, "Syntax error: %s\n", msg);
  exit(42);
}
/*
int main() {
  int result = yyparse();
  if (result == 0) printf("Successful parsing!\n");
  return result;
}*/
