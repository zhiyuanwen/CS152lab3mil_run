%{

#include <stdio.h>
#include <stdlib.h>
extern int yylex();
extern int yyparse();
extern FILE* yyin;
//i think everything 
void yyerror(const char* s);

#include<stdio.h>
#include<stdlib.h>

#include<iostream>
#include<string>
#include<vector>
#include<string.h>
#include<map>
#include<sstream>

using namespace std;

int count_names = 0;
string currCode = "";
string beginCode = "";
vector<string> allLines;
string exOperator = "";
map<string, int> varVals;

string tempVar = "";
int temp_count = 0;
std::string gen_temp_var()
{
  std::string temp_var;
  char tempstr[40] = "";
  sprintf(tempstr, "_temp%d", temp_count++);
  temp_var = tempstr;

/*  
  do {
    count_names++;
    temp_var = "_temp" + std::to_string(count_names);
  } while (find_variable(temp_var));
*/  
  return temp_var;
}

string funcName = "";
vector<string> allFuncs;
string varName = "";
vector<string> currVar;
vector<vector<string> > allVars;

void print_symbol_table(void) {
    printf("symbol table:\n");
    printf("--------------------\n");
    for(int i = 0; i < allFuncs.size(); i++) {
        cout << "function " << allFuncs[i] << endl;
        if(allVars.size() > i) {
            for(int j = 0; j < allVars[i].size(); j++) {
                cout << "  locals: " << allVars[i][j] << endl;
            }
        } 
    }
    printf("--------------------\n");
}

struct CodeNode {
    std::string code;
    std::string name;
};

%}

%union {
    int int_val;
    char *op_val;
    struct CodeNode *code_node;
}

%define parse.error verbose

%start beginP
%left FUNC SCOLON
%token LEFT_PAREN RIGHT_PAREN MINUS MULT DIV PLUS MODULO LEFT_BRACK RIGHT_BRACK COLON ASSIGN LESSER GREATER
%token LTE GTE NOTEQ ARR BPARAM EPARAM BLOCAL ELOCAL BBODY EBODY INT OF IF THEN ENDIF ELSE WHILE DO BLOOP ENDLOOP CONT BREAK READ
%token WRITE NOT T F RET FOR
%token EQUAL
%token <int_val> NUM
%token <op_val> IDENT
%type <code_node> value
%type <code_node> math
%type <code_node> assignment
%type <code_node> functions
%type <code_node> function
%type <code_node> val
%type <code_node> write
%type <code_node> read



%%
beginP: functions 
        {
            //printf("beginP -> functions\n");
        }
functions: function functions
            {
                //printf("functions -> function functions\n");
            }
          | %empty 
            {
                //printf("functions -> epsilon\n");
            }
function: FUNC IDENT SCOLON BPARAM declarations EPARAM BLOCAL declarations ELOCAL BBODY lines EBODY
        {
            //funcName = "main";
            funcName = $2;
            allFuncs.push_back(funcName);
            allVars.push_back(currVar);
            cout << "func " << funcName << endl;
            for(int i = 0; i < allLines.size(); ++i) {
                cout << allLines[i];
            }
            cout << "endfunc" << endl;
            cout << endl;
            //printf("function -> stuff\n");
        }

lines: line lines 
        {
            //printf("lines -> line lines\n");
        }
      | %empty 
        {
          //printf("lines -> epsilon\n");
        }
line: assignment 
    {
        //printf("line-> assignment\n");
    }
    | ifThen 
    {
        //printf("line-> ifThen\n");
    }
    | loop 
    {
        //printf("line-> loop\n");
    }
    | read 
    {
        //printf("line -> read\n");
    }
    | write 
    {
        //printf("line -> write\n");
    }
    | CONT SCOLON
    {
        //printf("line -> CONT(terminal)\n");
    }
    | BREAK SCOLON
    {
        //printf("line -> break(terminal)\n");
    }
    | returns 
    {
        //printf("line -> returns\n");
    }

assignment: IDENT ASSIGN val SCOLON
            {
                CodeNode *node = new CodeNode;
                node -> code = $3 -> code;
                node -> code += string("= ") + string($1) + string(", ") + $3 -> name + string("\n");
                allLines.push_back(node -> code);
                $$ = node;
                //printf("assignment -> variable ASSIGN val\n");
            }
           | IDENT LEFT_BRACK value RIGHT_BRACK ASSIGN val SCOLON
            {
                //cout << "what does the array get" << endl;
                CodeNode *node = new CodeNode;
                node -> code = $6 -> code;
                node -> code += string("[]= ") + string($1) + string(", ") + string($3 -> name) + string(", ") + $6 -> name + "\n";
                allLines.push_back(node -> code);
                $$ = node;
                //cout << "array value now has something" << endl;
                //printf("assignment -> array val val\n");
            }

value: NUM 
    {
        CodeNode *node = new CodeNode;
        node -> code = "";
        node -> name = strdup(to_string($1).c_str());
        $$ = node;
    }
    | IDENT
    {
        CodeNode *node = new CodeNode;
        node -> code = "";
        node -> name = $1;
        $$ = node;
    }
ifThen: IF condition THEN lines EIf ENDIF SCOLON 
{
    //printf("ifThen -> if statement\n");
}

EIf: ELSE lines 
{
    //printf("EIf -> else\n");
}
    | %empty 
    {
        //printf("EIf -> epsilon\n");
    }

condition: val comp val 
{
    //printf("condition -> val comp val\n");
}
          | NOT val comp val 
          {
              //printf("condition -> not val comp val\n");
          }

comp: LTE 
{
    //printf("comp -> LTE\n");
}
    |GTE 
    {
        //printf("comp -> GTE\n");
    }
    |GREATER 
    {
        //printf("comp -> greater\n");
    }
    |LESSER 
    {
        //printf("comp -> lesser\n");
    }
    |NOTEQ 
    {
        //printf("comp -> noteq\n");
    }
    |EQUAL 
    {
        //printf("comp -> equal\n");
    }

loop: WHILE condition BLOOP lines ENDLOOP SCOLON 
{
    //printf("loop -> while\n");
}
    | DO BLOOP lines ENDLOOP WHILE condition 
    {
        //printf("loop -> do\n");
    }

read: READ IDENT SCOLON
{
    currCode += string(".< ") + $2 + string("\n");
    allLines.push_back(currCode);
    //printf("read -> read Ident\n");
}

write: WRITE IDENT SCOLON
{
    currCode = string(".> ") + $2 + string("\n");
    allLines.push_back(currCode);
    //printf("write -> write ident\n");
}
    | WRITE IDENT LEFT_BRACK value RIGHT_BRACK SCOLON {
        //cout << "Beginning array writes" << endl;
        tempVar = gen_temp_var();
        allLines.push_back(". " + tempVar + "\n");
        currCode = "=[] " + tempVar + ", " + $2 + ", " + ($4 -> name) + "\n";
        allLines.push_back(currCode);
        currCode = (".> ") + tempVar + "\n";
        allLines.push_back(currCode);
        //printf("assignment -> array val val\n");
        //cout << "Ending array writes" << endl;
    }

returns: RET val SCOLON 
{
    //printf("returns -> ret val scolon\n");
}

val: func 
{
    //printf("val -> func\n");
}
    | math 
    {
        //printf("val -> math\n");
    }

math: NUM 
    {
        CodeNode *node = new CodeNode;
        node -> code = "";
        node -> name = strdup(to_string($1).c_str());
        $$ = node;
        //printf("math -> num\n");
    }
    | IDENT LEFT_BRACK value RIGHT_BRACK 
    {
        //cout << "Beginning array value" << endl;
        tempVar = gen_temp_var();
        allLines.push_back(". " + tempVar + "\n");
        CodeNode *node = new CodeNode;
        node -> code = string("=[] ") + string(tempVar) + ", " + string($1) + ", " + string($3 -> name) + "\n";
        node -> name = tempVar;
        $$ = node;
        //cout << "Got the array number" << endl;
    }
    | IDENT 
    {
        CodeNode *node = new CodeNode;
        node -> code = "";
        node -> name = $1;
        $$ = node;
        //printf("math -> Ident\n");
    }
    | val op val 
    {
        tempVar = gen_temp_var();
        allLines.push_back(". " + tempVar + "\n");
        CodeNode *node = new CodeNode;
        node -> code = ($1 -> code) + ($3 -> code);
        node -> code += string(exOperator) + tempVar + string(", ") + $1 -> name + string(", ") + $3 -> name + string("\n");
        node -> name = tempVar;
        $$ = node;
        //printf("math -> val op val\n");
    }
    |LEFT_PAREN val RIGHT_PAREN
    {
        //
    }

func: IDENT LEFT_PAREN val RIGHT_PAREN 
{
    //printf("func -> ident (val)\n");
}
    | func op func 
    {
        /*
        tempVar = gen_temp_var();
        beginCode = (". " + tempVar + "\n");
        allLines.push_back(beginCode);
        beginCode = exOperator;
        beginCode += tempVar;
        beginCode += (", ");
        currCode = beginCode + currCode + "\n";
        allLines.push_back(currCode); 
        
        currCode = "";
        beginCode = "";
        //printf("func -> func op func\n");
        */
    }

op: PLUS 
{
    exOperator = "+ ";
    //printf("op -> +\n");
}
    |MINUS 
    {
        exOperator = "- ";
        //printf("op -> -\n");
    }
    |MULT 
    {
        exOperator = "* ";
        //printf("op -> *\n");
    }
    |DIV 
    {
        exOperator = "/ ";
        //printf("op -> div\n");
    }
    |MODULO 
    {
        exOperator = "% ";
        //printf("op -> mod\n");
    }

declarations: declaration declarations 
{
    //printf("declarations -> declaration declarations\n");
}
            | %empty 
            {
                //printf("declaration -> epsilon\n");
            }
declaration:IDENT COLON ARR LEFT_BRACK NUM RIGHT_BRACK OF INT SCOLON 
{
    //cout << "Beginning declaration of array" << endl;
    varName = $1;
    currCode = ".[] " + varName + ", ";
    varName += "[]";
    currVar.push_back(varName);
    currCode += to_string($5);
    currCode += "\n";
    allLines.push_back(currCode);
    //cout << "Ending declaration" << endl;
    currCode = "";
    //printf("declaration array\n");
}
            |IDENT COLON INT SCOLON 
            {
                varName = $1;
                currVar.push_back(varName);
                currCode += (". ") + varName + "\n";
                allLines.push_back(currCode);
                currCode = "";
                //printf("declaration -> integer\n");
            }

;

%%

int main() {
  yyin = stdin;

  do {
    //printf("Parse.\n");
    yyparse();
  } while(!feof(yyin));
  printf("valid expression!\n");
  print_symbol_table();
  return 0;
}

void yyerror(const char* s) {
  fprintf(stderr, "invalid: %s. unacceptable!\n", s);
  exit(1);
}
