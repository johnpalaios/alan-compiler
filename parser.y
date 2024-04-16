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
%token T_string_literal
%token T_id

%token<string_val> T_rel_op 
%token<char_val> T_log_op

%precedence '!'
%left T_log_op 
%left '+' '-' '*' '/' '%'
%nonassoc T_rel_op

//%expect 1

%%
program : stmt_list
        ;

stmt_list : /* nothing */
          | stmt_list stmt
          ;

stmt : "begin" stmt_list "end"
     | "for" expr "do" stmt
     | "if" expr "then" stmt
     | "if" expr "then" stmt "else" stmt
     | "let" T_id '=' expr
     | "print" expr
     ;

expr : T_int_const
     | T_id
     | '(' expr ')'
     | expr '+' expr
     | expr '-' expr
     | expr '*' expr
     | expr '/' expr
     | expr '%' expr
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
