/* cs152-miniL phase3 */


%{

#include <stdio.h>
#include <stdlib.h>
extern int yylex();
extern int yyparse();
extern FILE* yyin;
//i think everything 
void yyerror(const char* s);
%}
%define parse.error verbose

%left LEFT_PAREN RIGHT_PAREN MINUS MULT DIV PLUS MODULO LEFT_BRACK RIGHT_BRACK COLON ASSIGN LESSER GREATER NUM IDENT 
%left LTE GTE NOTEQ ARR FUNC BPARAM EPARAM BLOCAL ELOCAL BBODY EBODY INT OF IF THEN ENDIF ELSE WHILE DO BLOOP ENDLOOP CONT BREAK READ
%left WRITE NOT T F RET FOR
%token EQUAL SCOLON
%start beginP 


%%
beginP: functions 
        {printf("beginP -> functions\n");}
functions: function functions 
        {printf("functions -> function functions\n");}
          | %empty 
        {printf("functions -> epsilon\n");}
function: FUNC IDENT SCOLON BPARAM declarations EPARAM BLOCAL declarations ELOCAL BBODY lines EBODY 
        {printf("function -> stuff\n");}

lines: line lines {printf("lines -> line lines\n");}
      | %empty {printf("lines -> epsilon\n");}
line: assignment {printf("line-> assignment\n");}
    | ifThen {printf("line-> ifThen\n");}
    | loop {printf("line-> loop\n");}
    | read {printf("line -> read\n");}
    | write {printf("line -> write\n");}
    | CONT SCOLON{printf("line -> CONT(terminal)\n");}
    | BREAK SCOLON{printf("line -> break(terminal)\n");}
    | returns {printf("line -> returns\n");}

assignment: IDENT ASSIGN val SCOLON{printf("assignment -> variable ASSIGN val\n");}
           | IDENT LEFT_BRACK value RIGHT_BRACK ASSIGN val SCOLON {printf("assignment -> array val val\n");}

value: NUM
    | IDENT
ifThen: IF condition THEN lines EIf ENDIF SCOLON {printf("ifThen -> if statement\n");}

EIf: ELSE lines {printf("EIf -> else\n");}
    | %empty {printf("EIf -> epsilon\n");}

condition: val comp val {printf("condition -> val comp val\n");}
          | NOT val comp val {printf("condition -> not val comp val\n");}

comp: LTE {printf("comp -> LTE\n");}
    |GTE {printf("comp -> GTE\n");}
    |GREATER {printf("comp -> greater\n");}
    |LESSER {printf("comp -> lesser\n");}
    |NOTEQ {printf("comp -> noteq\n");}
    |EQUAL {printf("comp -> equal\n");}

loop: WHILE condition BLOOP lines ENDLOOP SCOLON {printf("loop -> while\n");}
    | DO BLOOP lines ENDLOOP WHILE condition {printf("loop -> do\n");}

read: READ IDENT SCOLON{printf("read -> read Ident\n");}

write: WRITE IDENT SCOLON{printf("write -> write ident\n");}

returns: RET val SCOLON {printf("returns -> ret val scolon\n");}

val: func {printf("val -> func\n");}
    |math {printf("val -> math\n");}

math: NUM {printf("math -> num\n");}
    | IDENT LEFT_BRACK value RIGHT_BRACK
    | IDENT {printf("math -> Ident\n");}
    | val op val {printf("math -> val op val\n");}
    |LEFT_PAREN val RIGHT_PAREN

func: IDENT LEFT_PAREN val RIGHT_PAREN {printf("func -> ident (val)\n");}
    | func op func {printf("func -> func op func\n");}

op: PLUS {printf("op -> +\n");}
    |MINUS {printf("op -> -\n");}
    |MULT {printf("op -> *\n");}
    |DIV {printf("op -> div\n");}
    |MODULO {printf("op -> mod\n");}

declarations: declaration declarations {printf("declarations -> declaration declarations\n");}
            | %empty {printf("declaration -> epsilon\n");}
declaration:IDENT COLON ARR LEFT_BRACK NUM RIGHT_BRACK OF INT SCOLON {printf("declaration array\n");}
            |IDENT COLON INT SCOLON {printf("declaration -> integer\n");}

;

%%

int main() {
  yyin = stdin;

  do {
    printf("Parse.\n");
    yyparse();
  } while(!feof(yyin));
  printf("valid expression!\n");
  return 0;
}

void yyerror(const char* s) {
  fprintf(stderr, "invalid: %s. unacceptable!\n", s);
  exit(1);
}
