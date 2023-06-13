digit	[0-9]
letter	[A-Za-z]
%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
int linenum = 1;
%}

%%
"define"        { return DEFINE; }
"include"       { return INCLUDE; }
"void"          { return VOID; }
"int"           { return INT; }
"char"          { return CHAR; }
"double"        { return DOUBLE; }
"float"         { return FLOAT; }
"for"           { return FOR; }
"if"            { return IF; }
"else"          { return ELSE; }
"else if"       { return ELIF; }
"scanf"         { return SCANF; }
"printf"        { return PRINTF; }
"return"        { return RETURN; }
"+"             { return PLUSOP; }
"-"             { return MINUSOP; }
"*"             { return MULOP; }
"/"             { return DIVOP; }
"<"             { return LT; }
">"             { return GT; }
"="             { return EQ; }
"!"             { return NEG; }
"("             { return RPAR; }
")"             { return LPAR; }

({letter}|{digit})+.h {return LIB; }
({letter}|{digit})+ {yylval.str = strdup(yytext); return ALPNUM; }
({letter}|_)({letter}|{digit}|_)*   { yylval.str = strdup(yytext); return IDENT; }
-?{digit}+                          { yylval.str = strdup(yytext); return INTNUM; }
-?{digit}+\.{digit}+                { yylval.str = strdup(yytext); return FNUM;}
"/*"(.|\n)*?"*/"       
"//".*                  
\n              { linenum++; }
[ \t\r]+
%%

int yywrap() {
    return 1;
}