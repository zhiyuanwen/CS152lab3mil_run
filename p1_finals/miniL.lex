   /* cs152-miniL */

%option noyywrap

%{
#include <stdio.h>
#include "miniL.tab.h"


int col = 1, row = 1;
%}

   /* some common rules */
INVALN   [0-9]+[a-zA-Z_]+
DIGIT    [0-9]
NUM      [DIGIT]+
NEWL     \n
TAB      \t
INVALU   [a-zA-z][a-zA-Z0-9_]*_
SID      [a-zA-Z]
ID       [a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]
ASGN     :=
EQUATE   ==
LT       <[^[=>]]
GT       >[^=]
LB       "\["
RB       "]"
LP       "\("
RP       ")"
MOD      %
LTE      <=
GTE      >=
NE       <>
SEMI     ;
COLN     :
CMMA     ,
comment  ##.*
UNKNOWN  [^TAB NEWL comment CMMA COLN SEMI NE GTE LTE MOD RP LP RB LB GT LT EQUATE ASGN ID SID INVALU INVALN FUNC NUM]

%%
   /* specific lexer rules in regex */
"+"            {/*printf("ADD\n");*/ col++; return(PLUS);}
"-"            {/*printf("SUB\n");*/ col++; return(MINUS);}
"*"            {/*printf("MULT\n");*/ col++; return(MULT);}
"/"            {/*printf("DIV\n");*/ col++; return(DIV);}
{MOD}          {/*printf("MOD\n");*/ col++; return(MODULO);}
{LP}           {/*printf("L_PAREN\n");*/ col++; return(LEFT_PAREN);}
{RP}           {/*printf("R_PAREN\n");*/ col++;return(RIGHT_PAREN);}
{LB}           {/*printf("L_SQUARE_BRACKET\n");*/ col++; return(LEFT_BRACK);}
{RB}           {/*printf("R_SQUARE_BRACKET\n");*/ col++; return(RIGHT_BRACK);}
{SEMI}         {/*printf("SEMICOLON\n");*/ col++; return(SCOLON);}
{COLN}         {/*printf("COLON\n");*/ col++; return(COLON);}
{comment}      {}   
{EQUATE}       {/*printf("EQ\n");*/ col++; return(EQUAL);}
{ASGN}         {/*printf("ASSIGNED\n");*/ col++; return(ASSIGN);}
{LT}           {/*printf("LT\n");*/ col++; return(LESSER);}
{GT}           {/*printf("GT\n");*/ col++; return(GREATER);}
{LTE}          {/*printf("LTE\n");*/ col += 2; return(LTE);}
{GTE}          {/*printf("GTE\n");*/ col += 2; return(GTE);}
{NE}           {/*printf("NEQ\n");*/ col += 2; return(NOTEQ);}
"array"        {/*printf("ARRAY\n");*/ col += 5; return(ARR);}
"function"     {/*printf("FUNCTION\n");*/ col += 8; return(FUNC);}
"beginparams"  {/*printf("BEGIN_PARAMS\n");*/ col += 11; return(BPARAM);}
"endparams"    {/*printf("END_PARAMS\n");*/ col += 9; return(EPARAM);}
"beginlocals"  {/*printf("BEGIN_LOCALS\n");*/ col += 11; return(BLOCAL);}
"endlocals"    {/*printf("END_LOCALS\n");*/ col += 9; return(ELOCAL);}
"beginbody"    {/*printf("BEGIN_BODY\n");*/ col += 9; return(BBODY);}
"endbody"      {/*printf("END_BODY\n");*/ col += 7; return(EBODY);}
"integer"      {/*printf("INTEGER\n");*/ col += 7; return(INT);}  
"of"           {/*printf("OF\n");*/ col += 2; return(OF);}
"if"           {/*printf("IF\n");*/ col += 2; return(IF);}
"then"         {/*printf("THEN\n");*/ col += 4; return(THEN);}
"endif"        {/*printf("ENDIF\n");*/ col += 5; return(ENDIF);}
"else"         {/*printf("ELSE\n");*/ col += 4; return(ELSE);}
"while"        {/*printf("WHILE\n");*/ col += 5; return(WHILE);}
"do"           {/*printf("DO\n");*/ col += 2; return(DO);}
"beginloop"    {/*printf("BEGINLOOP\n");*/ col += 9; return(BLOOP);}
"endloop"      {/*printf("ENDLOOP\n");*/ col += 7; return(ENDLOOP);}
"continue"     {/*printf("CONTINUE\n");*/ col += 8; return(CONT);}
"break"        {/*printf("BREAK\n");*/ col += 5; return(BREAK);}
"read"         {/*printf("READ\n");*/ col += 4; return(READ);}
"write"        {/*printf("WRITE\n");*/ col += 5; return(WRITE);}
"not"          {/*printf("NOT\n");*/ col += 3;return(NOT);}
"true"         {/*printf("TRUE\n");*/ col += 4; return(T);}
"false"        {/*printf("FALSE\n");*/ col += 5; return(F);}
"return"       {/*printf("RETURN\n");*/ col += 6; return(RET);}
"for"          {/*printf("FOR\n");*/ col += 3; return(FOR);}
" "            {col++;}
{NEWL}         {row++; col = 0;}
{TAB}          {col += 4;}
{INVALN}       {/*printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", row, col, yytext);*/ exit(1);}
{INVALU}       {/*printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", row, col, yytext);*/ exit(1);}
{ID}           {/*printf("IDENT %s\n", yytext);*/ col += yyleng; return(IDENT);}
{SID}          {/*printf("IDENT %s\n", yytext);*/ col += yyleng; return(IDENT);}
{DIGIT}+       {/*printf("NUMBER %s\n", yytext);*/ col += yyleng; return (NUM);}

{UNKNOWN}      {/*printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", row, col, yytext);*/ exit(1);}
%%
