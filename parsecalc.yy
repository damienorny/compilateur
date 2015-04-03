%language "c++"
%define api.token.prefix {TOK_}
//%define api.token.constructor
%define api.value.type variant
%defines
%error-verbose
%debug
%locations
%parse-param { unsigned* nerrs }


%code provides
{
#define YY_DECL                                 \
  yy::parser::token_type yylex(yy::parser::semantic_type* yylval, yy::parser::location_type* yylloc)
  YY_DECL;
}

%code top
{
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
}

%code requires
{
  #include "exp.hh"
}

%expect 0
%left "+" "-"
%left "*" "/"

%token <int> INT "number"
%type <Exp*> exp line

//%printer { yyo << $$; } <int>

%token
  LPAREN "("
  MINUS "-"
  PLUS "+"
  RPAREN ")"
  SLASH "/"
  STAR  "*"
  EOL "end of line"
  EOF 0 "end of file"
%%
input:
  %empty
| input line  { std::cout << *$2 << std::endl; }
;

line:
  EOL       { $$ = new Num(-1); }
| exp EOL   { $$ = $1; }
| error EOL { $$ = new Num(666); yyerrok; }
;

exp:
  exp "+" exp  { $$ = new Bin('+', $1, $3); }
| exp "-" exp  { $$ = new Bin('-', $1, $3); }
| exp "*" exp  { $$ = new Bin('*', $1, $3); }
| exp "/" exp  { $$ = new Bin('/', $1, $3); }
| "(" exp ")"  { $$ = $2; }
| "(" error ")"{ $$ = new Num(777); }
| INT          { $$ = new Num($1); }
;

%%

void yy::parser::error(const location_type& loc, const std::string& msg)
{
  std::cerr<<loc;
  std::cerr<<" : " << msg << std::endl;
  *nerrs+=1;
}

int main()
{
  unsigned nerrs = 0;
  yy::parser p(&nerrs);
  nerrs += !!p.parse();
  return !!nerrs; 
}
