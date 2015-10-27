%{
/*
 * scan.l
 *
 * lex input file for pascal scanner
 *
 * extensions: to ways to spell "external" and "->" ok for "^".
 */
extern YYSTYPE yylval;
int line_no = 1;

%}

%%

[Aa][Rr][Rr][Aa][Yy]			{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(ARRAY);}
[Bb][eE][Gg][Ii][Nn]			{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(PBEGIN);}
[Dd][Oo]				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(DO);}
[Ee][Ll][Ss][Ee]			{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(ELSE);}
[Ee][Nn][Dd]				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext);return(END);}
[Ee][Xx][Tt][Ee][Rr][Nn] |
[Ff][Uu][Nn][Cc][Tt][Ii][Oo][Nn]	{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(FUNCTION);}
[Ii][Ff]				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(IF);}
[Ii][Nn]				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(IN);}
[Nn][Oo][Tt]				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(NOT);}
[Oo][Ff]				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(OF);}
[Pp][Rr][Oo][Cc][Ee][Dd][Uu][Rr][Ee]	{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(PROCEDURE);}
[Tt][Hh][Ee][Nn]			{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(THEN);}
[Vv][Aa][Rr]				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(VAR);}
[Ww][Hh][Ii][Ll][Ee]			{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(WHILE);}
[Ii][Nn][Tt][Ee][Gg][Ee][Rr]		{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(INTEGER);}
[Pp][Rr][Oo][Gg][Rr][Aa][Mm]		{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(PROGRAM);}
[Rr][Ee][Aa][Ll]			{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(REAL);}
[Ss][Tt][Rr][Ii][Nn][Gg]		{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(STRING);}
[a-zA-Z]([a-zA-Z0-9])*			{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(IDENTIFIER);}

":="					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(ASSIGNMENT);}
\"([^'\"]+)\"				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(CHARACTER_STRING);}
'([^'\"]+)'				{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(CHARACTER_STRING);}
\"\"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(CHARACTER_STRING);}
''					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(CHARACTER_STRING);}
":"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(COLON);}
","					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(COMMA);}
"."					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(DOT);}
".."					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(DOTDOT);}
"="					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(EQUAL);}
"!="					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(NOTEQUAL);}
">="					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(GE);}
">"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(GT);}
"["					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(LBRAC);}
"<="					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(LE);}
"("					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(LPAREN);}
"<"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(LT);}
"-"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(MINUS);}
"<>"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(NOTEQUAL);}
"+"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(PLUS);}
"]"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(LBRAC);}
[0-9]+					{/*fprintf(stderr, "%d\n", atoi(yytext));*/ yylval.ival = atoi(yytext); return(DIGSEQ);}
[0-9]+"."[0-9]+				{/*fprintf(stderr, "%f\n", atof(yytext));*/ yylval.fval = atof(yytext); return(REALNUMBER);}
")"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(RPAREN);}
";"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(SEMICOLON);}
"/"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(SLASH);}
"*"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(STAR);}
"**"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(STARSTAR);}
"->"   |
"^"					{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(UPARROW);}
[0-9]+((\.)[0-9]+)?"E"[+|-][0-9]+((\.)[0-9]+)?	{/*fprintf(stderr, "%s\n", yytext);*/ yylval.text = (char*)malloc(strlen(yytext)+1); strcpy(yylval.text, yytext); return(EXPOPRST);}


"//"    { register int c;
     while ((c = input()))
     {
      if (c == '\n')
      {
        line_no++;
        break;
      }
      else if (c == 0)
        fprintf (stderr, "Unexpected EOF inside comment at line %d\n",line_no);
     }
    }

"(*"   |
"{"    { register int c;
         register int cc;
     cc = 0;
     while ((c = input()))
     {
      if (c == '}'){
       if(cc != 0)
        cc--;
       else
        break;
      }
      else if (c == '*')
      {
       if ((c = input()) == ')')
        if(cc != 0)
         cc--;
        else
         break;
       else
        unput (c);
      }
      else if (c == '{')
       cc++;
      else if (c == '(')
      {
       if ((c = input()) == '*')
        cc++;
       else
        unput (c);
      }
      else if (c == '\n')
       line_no++;
      else if (c == 0)
        fprintf (stderr, "Unexpected EOF inside comment at line %d\n",line_no);
     }
    }

[ \t\f]    ;

\r         ;
\n    line_no++;

.    {fprintf(stderr,"[Lexical analyzer error] at line %d : %s\n",line_no,yytext);}

[0-9]+[a-zA-Z]*[a-zA-Z0-9]*				{fprintf(stderr, "[Lexical analyzer error] INVALID IDENTIFIER\n"); return(ERROR);}
[^ \n]*[~!@#$%?_]+([^ :\n]*[~!@#$%?_]*)?[^ :\n]*		{fprintf(stderr, "[Lexical analyzer error] INVALID CHARACTER\n"); return(ERROR);}

%%

int commenteof()
{
	fprintf (stderr, "unexpected EOF inside comment at line %d\n",line_no);
	return 1;
}

int yywrap()
{
//	fprintf(stderr, "\n************** RESULT **************\n\n");
	fclose(yyin);
	return 1;
}
