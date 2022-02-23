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

using namespace std;

int count_names = 0;
string currCode = "";
string beginCode = "";
vector<string> allLines;
int checkCommas = 0;
string backTrack = "";
string exOperator = "";

string tempVar = "";
int temp_count = 0;
std::string gen_temp_var()
{
  std::string temp_var;
  char tempstr[40] = "";
  sprintf(tempstr, "temp%d", temp_count++);
  temp_var = tempstr;

/*  
  do {
    count_names++;
    temp_var = "temp" + std::to_string(count_names);
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

%}

%union {
    int notU;
    char *notUsed;
    int int_val;
    char *op_val;
}

%define parse.error verbose

%start beginP
%left FUNC SCOLON
%token LEFT_PAREN RIGHT_PAREN MINUS MULT DIV PLUS MODULO LEFT_BRACK RIGHT_BRACK COLON ASSIGN LESSER GREATER
%token LTE GTE NOTEQ ARR BPARAM EPARAM BLOCAL ELOCAL BBODY EBODY INT OF IF THEN ENDIF ELSE WHILE DO BLOOP ENDLOOP CONT BREAK READ
%token WRITE NOT T F RET FOR
%token EQUAL
%token <op_val> NUM
%token <op_val> IDENT
%type <op_val> value


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
function: FUNC IDENT 
        {
            funcName = "main";
            //funcName = *$2;
            allFuncs.push_back(funcName);
        }
        SCOLON BPARAM declarations EPARAM BLOCAL declarations ELOCAL BBODY lines EBODY
        {
            allVars.push_back(currVar);
            cout << "function " << funcName << endl;
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
                if(exOperator != "") {
                    beginCode = ("= ");
                    beginCode += ("tempAssign");
                    //beginCode += ("%s", $1);
                    beginCode += (", ") + (tempVar) + "\n";
                    allLines.push_back(beginCode);
                    currCode = "";
                    exOperator = "";
                }
                else {
                    beginCode = ("= ");
                    beginCode += ("tempAssign");
                    //beginCode += ("%s", $1);
                    beginCode += (", ");
                    currCode = beginCode + currCode + "\n";
                    allLines.push_back(currCode);
                    currCode = "";
                }
                //printf("assignment -> variable ASSIGN val\n");
            }
           | IDENT LEFT_BRACK value RIGHT_BRACK ASSIGN val SCOLON
           {
               //printf("assignment -> array val val\n");
           }

value: NUM 
    {
        currCode += ("69");
        //currCode += ("%s", $1);
        checkCommas = 0;
        //$$ = $1;
    }
    | IDENT
    {
        currCode += ("b");
        //currCode += ("%s", $1);
        if(checkCommas == 1) {
            checkCommas = 0;
        }
        else {
            checkCommas++;
            currCode += (", ");
        }
        //$$ = $1; 
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
    //printf("read -> read Ident\n");
}

write: WRITE IDENT SCOLON
{
    currCode += (".> ");
    currCode += ("c");
    //currCode += ("%s", $2);
    currCode += ("\n");
    allLines.push_back(currCode);
    currCode = "";
    //printf("write -> write ident\n");
}
    | WRITE IDENT LEFT_BRACK value RIGHT_BRACK SCOLON {
        //array writing
    }

returns: RET val SCOLON 
{
    //printf("returns -> ret val scolon\n");
}

val: func 
{
    //printf("val -> func\n");
}
    |math 
    {
        //printf("val -> math\n");
    }

math: NUM 
    {
        currCode += ("69");
        //currCode += ("%s", $1);
        checkCommas = 0;
        //$$ = $1;
        //printf("math -> num\n");
    }
    | IDENT LEFT_BRACK value RIGHT_BRACK 
    {
        //array thing
    }
    | IDENT 
    {
        currCode += ("b");
        //currCode += ("%s", $1);
        if(checkCommas == 1) {
            checkCommas = 0;
        }
        else {
            checkCommas++;
            currCode += (", ");
        }
        //$$ = $1; 
        //printf("math -> Ident\n");
    }
    | val op val 
    {
        tempVar = gen_temp_var();
        beginCode = (". ");
        beginCode += tempVar;
        beginCode += ("\n");
        allLines.push_back(beginCode);
        beginCode = exOperator;
        beginCode += tempVar;
        beginCode += (", ");
        currCode = beginCode + currCode + "\n";
        allLines.push_back(currCode);
        currCode = "";
        beginCode = "";
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
        //backTrack = $1;
        tempVar = gen_temp_var();
        beginCode = (". ");
        beginCode += tempVar;
        beginCode += ("\n");
        allLines.push_back(beginCode);
        beginCode = exOperator;
        beginCode += tempVar;
        beginCode += (", ");
        currCode = beginCode + currCode + "\n";
        allLines.push_back(currCode);
        currCode = "";
        beginCode = "";
        //printf("func -> func op func\n");
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
        exOperator = "* ";
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
    varName = "z";
    //varName = $1;
    currCode += (".[] ") + varName + ", ";
    varName += "[]";
    currVar.push_back(varName);
    //currCode += $5;
    currCode += "20\n";
    allLines.push_back(currCode);
    currCode = "";
    //printf("declaration array\n");
}
            |IDENT COLON INT SCOLON 
            {
                varName = "a";
                //varName = $1;
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
