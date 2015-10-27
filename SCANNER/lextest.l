Digit [0-9]
E [Ee]
eol \n
blank [\t]
Letter [A-Za-z]
ILLEGAL [\!#\$\%\?@\\\^`\{\}\[\]~]
%{
 /*
#define ID  258
#define ASSIGN  259
#define SEMICOLON   260
#define PLUS    261
#define NUM 262
 */
  int lineCount = 1;
%}

%%

[A-Za-z][A-Za-z]* {
    fprintf(stderr, "id...%d.%s.\n", lineCount,yytext);
    return(ID);
  }
  
[0-9][0-9]* { 
    fprintf(stderr, "num...%d.%s.\n", lineCount,yytext);
    return(NUM);
  }
  
:= {
    fprintf(stderr, "assign...%d.%s.\n", lineCount,yytext);
    return(ASSIGN);
  }

\+ {
    fprintf(stderr, "plus...%d\n", lineCount);
    return(PLUS);
  }

; { 
    fprintf(stderr, "semi...%d\n", lineCount);
    return(SEMICOLON);
  }

\n { 
    fprintf(stderr, "eol...%d\n", lineCount);
    lineCount ++; 
  }

{blank} { 
    fprintf(stderr, "blank...%d\n", lineCount);
    /*   lineCount ++; */
  }

{ILLEGAL}([^\40\t]*)? {
  fprintf(stderr,"Lexical analyzer error at line:%d, %s\n",lineCount,yytext);
  }
%%

/*
int main(int argc, char** argv) {
  int i, tok;
  yyin = fopen("abc.def", "r");
  for (i = 0; 1==1; i ++) {
    tok = yylex();
    fprintf(stderr, "The %d-th token: %d, %s on line %d.\n", i, tok, yytext, lineCount);
  }
  return(0);
} 
*/ 


yywrap() {
  fprintf(stderr, "end of lexing.\n"); 
  fclose(yyin);
  exit(1);
}

