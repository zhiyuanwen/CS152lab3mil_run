all: miniL
miniL.tab.c miniL.tab.h:	miniL.y
	bison -t -v -d miniL.y
lex.yy.c: miniL.lex miniL.tab.h
	flex miniL.lex 
miniL: lex.yy.c miniL.tab.c miniL.tab.h
	g++ -o miniL miniL.tab.c lex.yy.c -lfl
clean:
	rm miniL miniL.tab.c lex.yy.c miniL.tab.h miniL.output
