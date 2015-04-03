/* Prologue. */
%option noyywrap
%{
#include "parsecalc.hh"
# define YY_USER_ACTION                         \
  yylloc->end.column += yyleng;

%}
%%
%{
  yylloc->step();
%}
"+"         return yy::parser::token::TOK_PLUS;
"-"         return yy::parser::token::TOK_MINUS;
"*"         return yy::parser::token::TOK_STAR;
"/"         return yy::parser::token::TOK_SLASH;
"("         return yy::parser::token::TOK_LPAREN;
")"         return yy::parser::token::TOK_RPAREN;
[0-9]+      yylval->build<int>(strtol(yytext, 0, 10)); return yy::parser::token::TOK_INT;
" "+        yylloc->step(); continue;
"\n"        yylloc->end.line += 1; yylloc->end.column = 1; yylloc->step(); return yy::parser::token::TOK_EOL;
.           fprintf (stderr, "error: invalid character: %c\n", *yytext);
<<EOF>> 	return yy::parser::token::TOK_EOF;
%%
/* Epilogue.  */
