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

string currCode = "";
vector<string> allLines;
vector<string> loopLined;
vector<string> ifElseLined;
string exOperator = "";
string compOperator = "";
map<string, int> varVals;
int loop_count = 0;
int ifElseCount = 0;
int excessLines = 0;
string breakLooper = "";
string continueLooper = "";
int deepLooper = 0;

string tempVar = "";
int temp_count = 0;
std::string gen_temp_var()
{
  std::string temp_var;
  char tempstr[40] = "";
  sprintf(tempstr, "_temp%d", temp_count++);
  temp_var = tempstr;
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
%type <code_node> condition
%type <code_node> ifThen
%type <code_node> lines
%type <code_node> line
%type <code_node> loop
%type <code_node> comp
%type <code_node> op
%type <code_node> returns



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
            funcName = $2;
            allFuncs.push_back(funcName);
            allVars.push_back(currVar);
            cout << "func " << funcName << endl;
            for(int i = 0; i < allLines.size(); ++i) {
                cout << allLines[i];
            }
            allLines.clear();
            cout << "endfunc" << endl;
            cout << endl;
            //printf("function -> stuff\n");
        }

lines: line lines 
        {
            excessLines++;
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
        if(continueLooper == "") {
            yyerror("continue");
        }
        CodeNode *node = new CodeNode;
        node -> code = string(continueLooper);
        node -> name = "";
        allLines.push_back(continueLooper);
        $$ = node;
        //printf("line -> CONT(terminal)\n");
    }
    | BREAK SCOLON
    {
        if(breakLooper == "") {
            yyerror("break");
        }
        CodeNode *node = new CodeNode;
        node -> code = string(breakLooper);
        node -> name = "";
        allLines.push_back(breakLooper);
        $$ = node;
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
                CodeNode *node = new CodeNode;
                node -> code = $6 -> code;
                node -> code += string("[]= ") + string($1) + string(", ") + string($3 -> name) + string(", ") + $6 -> name + "\n";
                allLines.push_back(node -> code);
                $$ = node;
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

ifThen: IF condition THEN lines ELSE lines ENDIF SCOLON 
{
    for(int i = 0; i < 2; ++i) {
        ifElseLined.push_back(allLines.back());
        allLines.pop_back();
    }
    allLines.push_back($2 -> code);
    allLines.push_back("?:= if_true" + to_string(ifElseCount) + string(", ") + $2 -> name + "\n");
    allLines.push_back(":= else" + to_string(ifElseCount) + string("\n"));
    allLines.push_back(": if_true" + to_string(ifElseCount) + string("\n"));
    allLines.push_back(ifElseLined[1]);
    allLines.push_back(":= endif" + to_string(ifElseCount) + string("\n"));
    allLines.push_back(": else" + to_string(ifElseCount) + string("\n"));
    allLines.push_back(ifElseLined[0]);
    allLines.push_back(": endif" + to_string(ifElseCount) + string("\n"));
    ifElseCount++;
    ifElseLined.clear();
    excessLines += 5;
    //printf("ifThen -> if statement\n");
    //printf("EIf -> else\n");
}
| IF condition THEN lines ENDIF SCOLON {
    ifElseLined.push_back(allLines.back());
    allLines.pop_back();
    allLines.push_back($2 -> code);
    allLines.push_back("?:= if_true" + to_string(ifElseCount) + string(", ") + $2 -> name + "\n");
    allLines.push_back(":= endif" + to_string(ifElseCount) + string("\n"));
    allLines.push_back(": if_true" + to_string(ifElseCount) + string("\n"));
    allLines.push_back(ifElseLined[0]);
    allLines.push_back(": endif" + to_string(ifElseCount) + string("\n"));
    ifElseCount++;
    ifElseLined.clear();
    excessLines += 3;
    //printf("ifThen -> if statement\n");
    //printf("EIf -> epsilon\n");
}

condition: val comp val 
{
    tempVar = gen_temp_var();
    allLines.push_back(". " + tempVar + "\n");
    CodeNode *node = new CodeNode;
    node -> code = $1 -> code + $3 -> code;
    node -> code += string(compOperator) + tempVar + string(", ") + string($1 -> name) + string(", ") + string($3 -> name) + string("\n");
    node -> name = tempVar;
    $$ = node;
    //printf("condition -> val comp val\n");
}
          | NOT val comp val 
          {
              //specifics that I'm not attempting here
              //printf("condition -> not val comp val\n");
          }

comp: LTE 
{
    compOperator = "<= ";
    //printf("comp -> LTE\n");
}
    | GTE 
    {
        compOperator = ">= ";
        //printf("comp -> GTE\n");
    }
    | GREATER 
    {
        compOperator = "> ";
        //printf("comp -> greater\n");
    }
    | LESSER 
    {
        compOperator = "< ";
        //printf("comp -> lesser\n");
    }
    |NOTEQ 
    {
        compOperator = "!= ";
        //printf("comp -> noteq\n");
    }
    |EQUAL 
    {
        compOperator = "== ";
        //printf("comp -> equal\n");
    }

loop: WHILE condition
{
    breakLooper = ":= endloop" + to_string(loop_count + deepLooper) + "\n";
    continueLooper = ":= beginloop " + to_string(loop_count + deepLooper + 1) + "\n";
    loopLined.push_back(allLines.back());
    allLines.pop_back();
    excessLines = 0;
    allLines.push_back(": beginloop" + to_string(loop_count + deepLooper) + "\n");
    allLines.push_back(loopLined[0]);
    allLines.push_back($2 -> code);
    allLines.push_back("?:= loop_body" + to_string(loop_count + deepLooper) + string(", ") + $2 -> name + "\n");
    allLines.push_back(":= endloop" + to_string(loop_count + deepLooper) + string("\n"));
    allLines.push_back(": loop_body" + to_string(loop_count + deepLooper) + string("\n"));
    loopLined.clear();
}
BLOOP lines ENDLOOP SCOLON 
{
    for(int i = 0; i < excessLines + temp_count; ++i) {
        loopLined.push_back(allLines.back());
        allLines.pop_back();
    }
    excessLines = 0;
    for(int i = loopLined.size() - 1; i >= 0; --i) {
        allLines.push_back(loopLined[i]);
    }
    loopLined.clear();
    allLines.push_back(":= beginloop" + to_string(loop_count + deepLooper) + string("\n"));
    allLines.push_back(": endloop" + to_string(loop_count + deepLooper) + string("\n"));
    loop_count++;
    breakLooper = "";
    continueLooper = "";
    loopLined.clear();
    excessLines = 0;
    //printf("loop -> while\n");
}

    | DO BLOOP lines ENDLOOP WHILE condition 
    {
        breakLooper = ":= endloop" + to_string(loop_count + deepLooper) + "\n";
        continueLooper = ":= beginloop " + to_string(loop_count + deepLooper + 1) + "\n";
        string conditionDeclare = allLines.back();
        allLines.pop_back();
        for(int i = 0; i < excessLines; ++i) {
            loopLined.push_back(allLines.back());
            allLines.pop_back();
        }
        allLines.push_back(": beginloop" + to_string(loop_count + deepLooper) + "\n");
        for(int i = loopLined.size() - 1; i >= 0; --i) {
            allLines.push_back(loopLined[i]);
        }
        allLines.push_back(conditionDeclare);
        allLines.push_back($6 -> code);
        allLines.push_back("?:= beginloop" + to_string(loop_count + deepLooper) + string(", ") + $6 -> name + "\n");
        allLines.push_back(":= endloop" + to_string(loop_count + deepLooper) + string("\n"));
        allLines.push_back(": endloop" + to_string(loop_count + deepLooper) + string("\n"));
        loop_count++;
        breakLooper = "";
        continueLooper = "";
        excessLines = 0;
        loopLined.clear();
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
    CodeNode *node = new CodeNode;
    node -> code = string(".> ") + $2 + string("\n");
    node -> name = "";
    allLines.push_back(node -> code);
    $$ = node;
    //printf("write -> write ident\n");
}
    | WRITE IDENT LEFT_BRACK value RIGHT_BRACK SCOLON {
        tempVar = gen_temp_var();
        allLines.push_back(". " + tempVar + "\n");
        currCode = "=[] " + tempVar + ", " + $2 + ", " + ($4 -> name) + "\n";
        allLines.push_back(currCode);
        currCode = (".> ") + tempVar + "\n";
        allLines.push_back(currCode);
        //printf("assignment -> array val val\n");
    }

returns: RET val SCOLON 
{
    CodeNode *node = new CodeNode;
    node -> code = $2 -> code;
    node -> code += string("ret ") + $2 -> name + string("\n");
    node -> name = "";
    allLines.push_back(node -> code);
    $$ = node;
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
        tempVar = gen_temp_var();
        allLines.push_back(". " + tempVar + "\n");
        CodeNode *node = new CodeNode;
        node -> code = string("=[] ") + string(tempVar) + ", " + string($1) + ", " + string($3 -> name) + "\n";
        node -> name = tempVar;
        $$ = node;
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
        //Need to implement
    }

func: IDENT LEFT_PAREN val RIGHT_PAREN 
{
    //printf("func -> ident (val)\n");
}
    | func op func 
    {
        //Need to do
        /*
        tempVar = gen_temp_var();
        allLines.push_back(". " + tempVar + "\n");
        currCode = exOperator;
        currCode += tempVar;
        currCode += (", ");
        allLines.push_back(currCode); 
        
        currCode = "";
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
    varName = $1;
    currCode = ".[] " + varName + ", ";
    varName += "[]";
    currVar.push_back(varName);
    currCode += to_string($5);
    currCode += "\n";
    allLines.push_back(currCode);
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
