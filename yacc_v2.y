%{
	#include <stdio.h>
	#include <iostream>
	#include <fstream>
	#include <string>
    #include <cstring>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);
	extern int linenum;
	ofstream output_file;
%}

%union
{
	char *str;
}

%token <str> IDENT INTNUM FNUM
%token DIVOP EQ NEG RPAR LPAR LT GT PRINTF SCANF PLUSOP MINUSOP MULOP LIB 
%token VOID INT CHAR DOUBLE FLOAT FOR IF ELSE ELIF RETURN INCLUDE DEFINE ALPNUM
%type<str> program func_defns func_defn
%type<str> func_sign param_lst param stmts
%type<str> stmt asg_stmt call_stmt arg_lst
%type<str> rtn_stmt dec_stmt dec 
%type<str> loop_stmt cond_stmt if_stmt expr 
%type<str> else_stmt elif_stmt  cmp_expr 
%type<str> inc_expr

%%

program : func_defns { output_file.open("pseudo_code_output.txt", ios::app);
        output_file << $1; output_file.close(); }
		| macro_stms func_defns { output_file.open("pseudo_code_output.txt", ios::app);
        output_file << $2; output_file.close(); }
        ;

macro_stms	: macro_stm
			| macro_stms macro_stm
            ;

macro_stm	: "#" INCLUDE LT LIB GT
			| "#" INCLUDE "\"" LIB "\""
			| "#" DEFINE IDENT FNUM
			| "#" DEFINE IDENT INTNUM
			| "#" DEFINE IDENT IDENT
            ;

func_defns : func_defn { $$ = $1; }
            | func_defns func_defn { string s = string($1) + "\n" + string($2);
                                      $$ = strdup(s.c_str()); 
            } 
            ;

func_defn : func_sign "{" stmts "}" { 
                                        string s = "FUNCTION " + string($1) + "\n\t" + string($3) + "\nEND FUNCTION " + string($1);
                                        $$ = strdup(s.c_str()); 
          }
          ;
                
func_sign : type IDENT RPAR param_lst LPAR { 
                                                string s = string($2) + " " + string($4);
                                                $$ = strdup(s.c_str());
          }
          ;

param_lst : param { $$ = $1; }
               | param_lst "," param { string s = string($1) + " " + string($3); $$ = strdup(s.c_str()); }
               ;

param : type IDENT { $$ = $2; }
		  | VOID { $$ = strdup(" "); }
		  | type IDENT EQ expr { string s = string($2) + "=" + string($4); $$ = strdup(s.c_str()); }
          ;

type : VOID
     | INT
	 | CHAR
     | FLOAT    
	 | DOUBLE
     ;

stmts : stmt { $$ = $1; }
           | stmts stmt { string s = string($1) + "\n" + string($2); $$ = strdup(s.c_str()); }
           ;


stmt : asg_stmt ";" { $$ = $1; }
		  | dec_stmt ";" { $$ = $1; }
          | call_stmt ";" { $$ = $1; }
          | rtn_stmt ";" { $$ = $1; }
          | loop_stmt { $$ = $1; }
          | cond_stmt { $$ = $1; }
          ;

asg_stmt : IDENT "=" expr { string s = string($1) + "=" + string($3); $$ = strdup(s.c_str()); }
                     | IDENT "=" call_stmt { string s = string($1) + "=" + string($3); $$ = strdup(s.c_str()); }
                     ;


call_stmt : IDENT RPAR arg_lst LPAR { string s = string($1) + " " + string($3); $$ = strdup(s.c_str()); }
			   | SCANF RPAR arg_lst LPAR { string s = "READ " + string($3); $$ = strdup(s.c_str()); }
			   | PRINTF RPAR arg_lst LPAR { string s = "PRINT " + string($3); $$ = strdup(s.c_str()); }
               ;

arg_lst : { $$ = strdup(""); }
              | expr { $$ = $1; }
              | arg_lst "," expr { string s = string($1) + "," + string($3); $$ = strdup(s.c_str()); }
              ;

rtn_stmt : RETURN expr { $$ = $2; }
                 ;

dec_stmt : dec { $$ = $1; }
					  | dec "," dec_stmt { string s = string($1) + "," + string($3); $$ = strdup(s.c_str()); }
                      ;

dec : type IDENT { $$ = $2; }
			| type IDENT "=" expr { string s = string($2) + "=" + string($4); $$ = strdup(s.c_str()); }
            ;

loop_stmt : FOR "(" asg_stmt ";" cmp_expr ";" inc_expr ")" "{" stmts "}" {
    string s = string($3) + "\nWHILE " + string($5) + "\n\t" + string($10) + "\n" + string($7) + "\nEND WHILE";
    $$ = strdup(s.c_str()); }
          ;

cond_stmt : if_stmt { string s = string($1) + "\nENDIF"; $$ = strdup(s.c_str()); }
		  | if_stmt else_stmt { string s = string($1) + "\n" + string($2) + "\nENDIF"; $$ = strdup(s.c_str()); }
		  | if_stmt elif_stmt else_stmt { string s = string($1) + "\n" + string($2) + "\n" + string($3) + "\nENDIF"; $$ = strdup(s.c_str()); }
          ;

if_stmt : IF "(" cmp_expr ")" "{" stmts "}" { string s = "IF " + string($3) + " THEN\n\t" + string($6); $$ = strdup(s.c_str()); }
             ;

else_stmt : ELSE "{" stmts "}" { string s = "ELSE\n\t" + string($3); $$ = strdup(s.c_str()); }
               ;

elif_stmt : ELIF "(" cmp_expr ")" "{" stmts "}" { string s = "ELSEIF " + string($3) + " THEN\n\t" + string($6); $$ = strdup(s.c_str()); }
                ;

expr : IDENT { $$ = $1; }
           | INTNUM { $$ = $1; }
		   | FNUM { $$ = $1; }
           | expr PLUSOP IDENT { string s = string($1) + "+" + string($3); $$ = strdup(s.c_str()); }
           | expr PLUSOP INTNUM { string s = string($1) + "+" + string($3); $$ = strdup(s.c_str()); }
           | expr PLUSOP FNUM { string s = string($1) + "+" + string($3); $$ = strdup(s.c_str()); }
           | expr MINUSOP IDENT { string s = string($1) + "-" + string($3); $$ = strdup(s.c_str()); }
           | expr MINUSOP INTNUM { string s = string($1) + "-" + string($3); $$ = strdup(s.c_str()); }
           | expr MINUSOP FNUM { string s = string($1) + "-" + string($3); $$ = strdup(s.c_str()); }
           | expr MULOP IDENT { string s = string($1) + "*" + string($3); $$ = strdup(s.c_str()); }
           | expr MULOP INTNUM { string s = string($1) + "*" + string($3); $$ = strdup(s.c_str()); }
           | expr MULOP FNUM { string s = string($1) + "*" + string($3); $$ = strdup(s.c_str()); }
           | expr DIVOP IDENT { string s = string($1) + "/" + string($3); $$ = strdup(s.c_str()); }
           | expr DIVOP INTNUM { string s = string($1) + "/" + string($3); $$ = strdup(s.c_str()); }
           | expr DIVOP FNUM { string s = string($1) + "/" + string($3); $$ = strdup(s.c_str()); }
		   | "(" expr ")" { string s = "(" + string($2) + ")"; $$ = strdup(s.c_str()); }
           ;

cmp_expr : expr EQ EQ expr { string s = string($1) + "==" + string($4); $$ = strdup(s.c_str()); }
					  | expr LT expr { string s = string($1) + "<" + string($3); $$ = strdup(s.c_str()); }
					  | expr LT EQ expr { string s = string($1) + "<=" + string($4); $$ = strdup(s.c_str()); }
					  | expr GT expr { string s = string($1) + ">" + string($3); $$ = strdup(s.c_str()); }
					  | expr GT EQ expr { string s = string($1) + ">=" + string($4); $$ = strdup(s.c_str()); }
					  | expr NEG EQ expr { string s = string($1) + "!=" + string($4); $$ = strdup(s.c_str()); }
                      ;

inc_expr : IDENT PLUSOP PLUSOP { string s = string($1) + "++"; $$ = strdup(s.c_str()); }
					 | IDENT EQ IDENT PLUSOP "1" { string s = string($1) + "=" + string($3) + "+1"; $$ = strdup(s.c_str()); }
					 | IDENT MINUSOP MINUSOP { string s = string($1) + "--"; $$ = strdup(s.c_str()); }
                     ;

%%
void yyerror(string s){
	cout<<"Error at line: "<< linenum <<"\nError: "<<s<<endl;
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
	output_file.open("pseudo_code_output.txt");
	output_file.close();
    yyparse();
    fclose(yyin);
    return 0;
}

