all: lex yacc
	g++ lex.yy.c y.tab.c -ll -o project

yacc: yacc_v2.y
	yacc -d yacc_v2.y

lex: project_lex.l
	lex project_lex.l
clean: 
	rm lex.yy.c y.tab.c  y.tab.h  project