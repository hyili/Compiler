%{
/*
 * grammar.y
 *
 * Pascal grammar in Yacc format, based originally on BNF given
 * in "Standard Pascal -- User Reference Manual", by Doug Cooper.
 * This in turn is the BNF given by the ANSI and ISO Pascal standards,
 * and so, is PUBLIC DOMAIN. The grammar is for ISO Level 0 Pascal.
 * The grammar has been massaged somewhat to make it LALR, and added
 * the following extensions.
 *
 * constant expressions
 * otherwise statement in a case
 * productions to correctly match else's with if's
 * beginnings of a separate compilation facility
 */

 #include <stdio.h>

     /* Called by yyparse on error.  */
     void
     yyerror (char const *s)
     {
        extern char *yytext;
        extern int lineCount;
        fprintf (stderr, "%s: at line %d symbol'%s'\n", s,lineCount,yytext);
     }


%}

%token ID ASSIGN SEMICOLON PLUS NUM

%%

ss : ID ASSIGN ee SEMICOLON  
     { fprintf(stderr, "Use rule 1.\n");} ;

ee : ee PLUS tt
     { fprintf(stderr, "Use rule 2.\n");} 
    | tt
     { fprintf(stderr, "Use rule 3.\n");} ;

tt : ID
     { fprintf(stderr, "Use rule 4.\n");} 
    | NUM
     { fprintf(stderr, "Use rule 5.\n");} ;

%%

int main(int argc, char** argv) {
    int res;
    
    fprintf(stderr, "open file.\n");
    if(argc>1 && freopen(argv[1],"r",stdin)==NULL){
	return 1;
    }
    
    fprintf(stderr, "call yyparse\n");
    res = yyparse();
    fprintf(stderr, "after call yyparse, res = %d.\n", res);
    
    if (res==0)
        fprintf(stderr, "SUCCESS\n");
    else
        fprintf(stderr, "ERROR\n");
}

 #include "lex.yy.c"
