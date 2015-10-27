/* original parser id follows */
/* yysccsid[] = "@(#)yaccpar	1.9 (Berkeley) 02/21/93" */
/* (use YYMAJOR/YYMINOR for ifdefs dependent on parser version) */

#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9

#define YYEMPTY        (-1)
#define yyclearin      (yychar = YYEMPTY)
#define yyerrok        (yyerrflag = 0)
#define YYRECOVERING() (yyerrflag != 0)
#define YYENOMEM       (-2)
#define YYEOF          0
#define YYPREFIX "yy"

#define YYPURE 0

#line 1 "new-standard-pascal.y"

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
#include <stdlib.h>
#include <string.h>
#include "node.h"
#include "symtab.h"

/* Called by yyparse on error.  */

int res = 0, err = 0, B_E = 0, definition = 0;
nodeType AST, TEMP;
sym_node I, R, S;
FILE* ofile;
char jasmin[1000];

void file_init();
void def_init();
void main_init();
void file_finish();
void symdestroy(int scope);  /*  destroy symble table*/
sym_node symcheck(nodeType current, int scope, nodeType retval);  /*  check the type with no assignment*/
sym_node RHSsymcheck(nodeType current, int scope, nodeType retval);  /*  check the type in RHS*/
sym_node LHSsymcheck(nodeType current, int scope, nodeType retval);  /*  check the type in LHS*/
int Ievaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval);  /*  test and evaluate the expression whether it is integer or not*/
float Revaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval);  /*  test and evaluate the expression whether it is real number or not*/
sym_node RHSsymlook(nodeType current, int scope, nodeType retval, int* isvalue);  /* run through the RHS, and seperate it to digit number, real number, string, variable, and expression. then, call RHSsymcheck and LHSsymcheck to do the type checking.*/
void symlook(nodeType current, int scope, nodeType retval);  /*  run through the whole AST, and find out the VAR, FUNCTION, PROCEDURE, and PROGRAM declaration. others are ASSIGNMENT, IF, WHILE, PBEGIN, and END tokens.*/

void yyerror (char const *s)
{
	extern char *yytext;
	extern int line_no;
	fprintf(stderr, "[Syntactic analyzer error] %s at line %d symbol '%s'\n\n", s, line_no, yytext);
	res = 1;
	err++;
}

void shift()
{
	fprintf(stderr, "Shift\n");
}

void reduced(int rule)
{
	fprintf(stderr, "Reduced to rule %d\n", rule);
}

#line 66 "new-standard-pascal.y"
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union
{
        int ival;
	float fval;
        char* text;
	nodeType nval;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
#line 99 "y.tab.c"

/* compatibility with bison */
#ifdef YYPARSE_PARAM
/* compatibility with FreeBSD */
# ifdef YYPARSE_PARAM_TYPE
#  define YYPARSE_DECL() yyparse(YYPARSE_PARAM_TYPE YYPARSE_PARAM)
# else
#  define YYPARSE_DECL() yyparse(void *YYPARSE_PARAM)
# endif
#else
# define YYPARSE_DECL() yyparse(void)
#endif

/* Parameters sent to lex. */
#ifdef YYLEX_PARAM
# define YYLEX_DECL() yylex(void *YYLEX_PARAM)
# define YYLEX yylex(YYLEX_PARAM)
#else
# define YYLEX_DECL() yylex(void)
# define YYLEX yylex()
#endif

/* Parameters sent to yyerror. */
#ifndef YYERROR_DECL
#define YYERROR_DECL() yyerror(const char *s)
#endif
#ifndef YYERROR_CALL
#define YYERROR_CALL(msg) yyerror(msg)
#endif

extern int YYPARSE_DECL();

#define ARRAY 257
#define ASSIGNMENT 258
#define COLON 259
#define COMMA 260
#define DO 261
#define DOT 262
#define DOTDOT 263
#define ELSE 264
#define END 265
#define EQUAL 266
#define ERROR 267
#define FUNCTION 268
#define GE 269
#define GOTO 270
#define GT 271
#define IF 272
#define IN 273
#define LBRAC 274
#define LE 275
#define LPAREN 276
#define LT 277
#define MINUS 278
#define NOT 279
#define NOTEQUAL 280
#define OF 281
#define PBEGIN 282
#define PLUS 283
#define PROCEDURE 284
#define PROGRAM 285
#define RBRAC 286
#define RPAREN 287
#define SEMICOLON 288
#define SLASH 289
#define STAR 290
#define STARSTAR 291
#define STRING 292
#define THEN 293
#define UPARROW 294
#define VAR 295
#define WHILE 296
#define NIDENTIFIER 297
#define INTEGER 298
#define REAL 299
#define INVALIDSYM 300
#define CHARACTER_STRING 301
#define IDENTIFIER 302
#define EXPOPRST 303
#define DIGSEQ 304
#define REALNUMBER 305
#define EMPTY 306
#define YYERRCODE 256
typedef short YYINT;
static const YYINT yylhs[] = {                           -1,
    0,    0,    1,    1,    1,    2,    2,    2,    3,    3,
    3,    4,    4,    4,    5,    5,    6,    7,    7,    8,
    8,    9,    9,   10,   10,   11,   12,   12,   13,   13,
   13,   13,   13,   14,   15,   15,   16,   16,   16,   17,
   17,   17,   18,   18,   19,   19,   20,   20,   21,   21,
   21,   21,   21,   21,   22,   22,   23,   23,   24,   24,
   24,   24,   24,   24,   25,   25,   25,   25,   25,   25,
};
static const YYINT yylen[] = {                            2,
   10,    1,    1,    3,    1,    6,    0,    1,    1,    8,
    1,    1,    1,    1,    3,    0,    3,    6,    4,    3,
    0,    3,    5,    3,    0,    1,    1,    3,    3,    1,
    1,    6,    4,    2,    4,    0,    1,    4,    1,    1,
    3,    0,    1,    3,    1,    3,    1,    3,    2,    4,
    1,    3,    2,    1,    1,    1,    1,    1,    1,    1,
    1,    2,    2,    2,    1,    1,    1,    1,    1,    1,
};
static const YYINT yydefred[] = {                         0,
    2,    0,    0,    0,    0,    5,    3,    0,    0,    0,
    4,    0,    8,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,   39,    0,    0,    0,   31,
    0,    0,   27,    0,   30,    0,   15,    0,    1,   11,
    0,   14,   12,   13,    0,    9,    0,    0,    0,    0,
    0,   54,    0,   61,   59,   60,    0,    0,    0,   47,
   51,    0,    0,    0,   34,   24,    0,    0,    0,   17,
    0,    6,    0,    0,    0,    0,   64,   62,   63,   53,
    0,   49,    0,   67,   69,   66,   68,   65,   56,   70,
   55,    0,    0,   58,   57,    0,    0,    0,    0,   40,
   28,   29,   19,    0,    0,   20,    0,    0,   52,    0,
    0,    0,    0,   48,   33,    0,    0,   38,    0,   22,
    0,   18,   50,    0,   35,   41,    0,    0,   32,    0,
   23,    0,   10,
};
static const YYINT yydgoto[] = {                          3,
    8,   14,   45,   46,   16,   21,   22,   48,   74,   30,
   31,   32,   33,   34,   65,   35,   99,  100,   58,   59,
   60,   92,   96,   61,   93,
};
static const YYINT yysindex[] = {                      -246,
    0, -294,    0, -238, -250,    0,    0, -227, -225, -242,
    0, -173,    0, -181, -250, -256, -190, -185, -247, -180,
 -156, -173, -114, -241, -126,    0,  -98,  -98, -188,    0,
  -99, -149,    0,  -97,    0, -126,    0, -172,    0,    0,
 -105,    0,    0,    0, -121,    0, -250,  -87,  -98, -104,
  -98,    0, -168,    0,    0,    0, -120,  -46, -209,    0,
    0,  -86,  -98,  -98,    0,    0, -247,  -98, -100,    0,
 -107,    0, -123, -146, -187, -103,    0,    0,    0,    0,
  -98,    0, -247,    0,    0,    0,    0,    0,    0,    0,
    0,  -98,  -98,    0,    0,  -98, -247,  -95, -213,    0,
    0,    0,    0,  -80, -241,    0, -250,  -93,    0, -212,
  -62, -209, -264,    0,    0,  -65,  -98,    0, -107,    0,
 -106,    0,    0, -247,    0,    0,  -76, -241,    0,  -70,
    0, -241,    0,
};
static const YYINT yyrindex[] = {                         0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0, -255,    0,  -54,    0,  -49,    0,    0, -224,    0,
    0, -137,    0,    0,  -47,    0,    0,    0, -234,    0,
    0,  -44,    0,    0,    0,  -64,    0,  -61,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0, -162,    0,    0,    0,    0, -243, -131,    0,
    0,    0,    0, -198,    0,    0, -224,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
 -198,    0,  -45,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0, -145,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0, -101,  -71,    0,    0, -193,    0,    0,    0,    0,
    0,    0,    0, -145,    0,    0,    0,    0,    0,    0,
    0,    0,    0,
};
static const YYINT yygindex[] = {                         0,
  -15,  196,  -69,  151,    0,    0,    0,  197,    0,   63,
    0,    0,  -63,    0,  -50,    0,  154,  -26,  143,  146,
  -40,    0,    0,  -66,    0,
};
#define YYTABLESIZE 238
static const YYINT yytable[] = {                         17,
   57,   62,   82,  101,  104,    6,    7,    4,   26,    1,
   80,   18,    7,   89,   40,   41,   43,   43,   91,  111,
   43,   43,   76,   36,   27,   19,    7,   20,    7,   37,
   37,   73,    9,  115,   19,  120,   98,    5,    2,    7,
   25,  102,   43,   43,   43,   12,  117,  117,   28,   43,
   42,    7,  127,   37,   29,  114,   43,   44,  131,   10,
  129,   42,  133,   25,   36,  125,   36,   36,   24,    9,
   36,   36,   36,  118,  123,   36,   11,   36,   23,   94,
   95,   36,   13,   36,   36,   63,   36,   64,   42,   36,
  126,  121,   36,   36,   36,   36,   36,   36,   36,   36,
   70,   36,   36,   36,   42,   63,   36,   81,   36,   19,
   43,   44,   36,   15,   36,   36,   25,   36,   25,   25,
   36,   36,   15,   36,   36,   36,   36,   36,   45,   45,
   36,   37,   45,   45,   45,  105,    9,   45,   67,   45,
  106,  107,   25,   45,    7,   45,   45,   39,   45,   47,
    7,   45,  128,    9,   45,   45,   45,    7,   46,   46,
   68,   45,   46,   46,   46,   66,   72,   46,   71,   46,
   50,   75,   83,   46,   97,   46,   46,   49,   46,   50,
   51,   46,  119,  109,   46,   46,   46,  103,   44,   44,
  116,   46,   44,   44,  122,   54,   55,   56,   77,   78,
   79,  124,   52,   53,   54,   55,   56,   16,   63,  130,
  132,   21,   25,   16,   44,   44,   44,   38,   25,   84,
   26,   44,   85,   21,   86,  108,   25,   16,   87,   16,
   88,   89,   69,   90,  110,  113,   91,  112,
};
static const YYINT yycheck[] = {                         15,
   27,   28,   53,   67,   71,  256,  262,  302,  256,  256,
   51,  268,  268,  278,  256,  257,  260,  261,  283,   83,
  264,  265,   49,  258,  272,  282,  282,  284,  284,  264,
  265,   47,  260,   97,  282,  105,   63,  276,  285,  295,
  265,   68,  286,  287,  288,  288,  260,  260,  296,  293,
  292,  302,  119,  288,  302,   96,  298,  299,  128,  287,
  124,  260,  132,  288,  258,  116,  260,  261,  259,  260,
  264,  265,  266,  287,  287,  269,  302,  271,   16,  289,
  290,  275,  256,  277,  278,  274,  280,  276,  287,  283,
  117,  107,  286,  287,  288,  289,  290,  260,  261,  293,
   38,  264,  265,  266,  292,  274,  269,  276,  271,  282,
  298,  299,  275,  295,  277,  278,  302,  280,  264,  265,
  283,  302,  295,  286,  287,  288,  289,  290,  260,  261,
  293,  288,  264,  265,  266,  259,  260,  269,  288,  271,
  287,  288,  288,  275,  282,  277,  278,  262,  280,  276,
  288,  283,  259,  260,  286,  287,  288,  295,  260,  261,
  258,  293,  264,  265,  266,  265,  288,  269,  274,  271,
  278,  259,  293,  275,  261,  277,  278,  276,  280,  278,
  279,  283,  263,  287,  286,  287,  288,  288,  260,  261,
  286,  293,  264,  265,  288,  303,  304,  305,  303,  304,
  305,  264,  301,  302,  303,  304,  305,  262,  274,  286,
  281,  259,  262,  268,  286,  287,  288,   22,  264,  266,
  265,  293,  269,  288,  271,   75,  288,  282,  275,  284,
  277,  278,   36,  280,   81,   93,  283,   92,
};
#define YYFINAL 3
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 306
#define YYUNDFTOKEN 334
#define YYTRANSLATE(a) ((a) > YYMAXTOKEN ? YYUNDFTOKEN : (a))
#if YYDEBUG
static const char *const yyname[] = {

"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"ARRAY","ASSIGNMENT","COLON",
"COMMA","DO","DOT","DOTDOT","ELSE","END","EQUAL","ERROR","FUNCTION","GE","GOTO",
"GT","IF","IN","LBRAC","LE","LPAREN","LT","MINUS","NOT","NOTEQUAL","OF",
"PBEGIN","PLUS","PROCEDURE","PROGRAM","RBRAC","RPAREN","SEMICOLON","SLASH",
"STAR","STARSTAR","STRING","THEN","UPARROW","VAR","WHILE","NIDENTIFIER",
"INTEGER","REAL","INVALIDSYM","CHARACTER_STRING","IDENTIFIER","EXPOPRST",
"DIGSEQ","REALNUMBER","EMPTY",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,"illegal-symbol",
};
static const char *const yyrule[] = {
"$accept : program",
"program : PROGRAM IDENTIFIER LPAREN identifier_list RPAREN SEMICOLON declarations subprogram_declarations compound_statement DOT",
"program : error",
"identifier_list : IDENTIFIER",
"identifier_list : identifier_list COMMA IDENTIFIER",
"identifier_list : error",
"declarations : declarations VAR identifier_list COLON type SEMICOLON",
"declarations :",
"declarations : error",
"type : standard_type",
"type : ARRAY LBRAC num DOTDOT num RBRAC OF type",
"type : error",
"standard_type : INTEGER",
"standard_type : REAL",
"standard_type : STRING",
"subprogram_declarations : subprogram_declarations subprogram_declaration SEMICOLON",
"subprogram_declarations :",
"subprogram_declaration : subprogram_head declarations compound_statement",
"subprogram_head : FUNCTION IDENTIFIER arguments COLON standard_type SEMICOLON",
"subprogram_head : PROCEDURE IDENTIFIER arguments SEMICOLON",
"arguments : LPAREN parameter_list RPAREN",
"arguments :",
"parameter_list : identifier_list COLON type",
"parameter_list : parameter_list SEMICOLON identifier_list COLON type",
"compound_statement : PBEGIN optional_statements END",
"compound_statement :",
"optional_statements : statement_list",
"statement_list : statement",
"statement_list : statement_list SEMICOLON statement",
"statement : variable ASSIGNMENT expression",
"statement : procedure_statement",
"statement : compound_statement",
"statement : IF expression THEN statement ELSE statement",
"statement : WHILE expression DO statement",
"variable : IDENTIFIER tail",
"tail : LBRAC expression RBRAC tail",
"tail :",
"procedure_statement : IDENTIFIER",
"procedure_statement : IDENTIFIER LPAREN expression_list RPAREN",
"procedure_statement : error",
"expression_list : expression",
"expression_list : expression_list COMMA expression",
"expression_list :",
"expression : simple_expression",
"expression : simple_expression relop simple_expression",
"simple_expression : term",
"simple_expression : simple_expression addop term",
"term : factor",
"term : term mulop factor",
"factor : IDENTIFIER tail",
"factor : IDENTIFIER LPAREN expression_list RPAREN",
"factor : num",
"factor : LPAREN expression RPAREN",
"factor : NOT factor",
"factor : CHARACTER_STRING",
"addop : PLUS",
"addop : MINUS",
"mulop : STAR",
"mulop : SLASH",
"num : DIGSEQ",
"num : REALNUMBER",
"num : EXPOPRST",
"num : MINUS DIGSEQ",
"num : MINUS REALNUMBER",
"num : MINUS EXPOPRST",
"relop : LT",
"relop : GT",
"relop : EQUAL",
"relop : LE",
"relop : GE",
"relop : NOTEQUAL",

};
#endif

int      yydebug;
int      yynerrs;

int      yyerrflag;
int      yychar;
YYSTYPE  yyval;
YYSTYPE  yylval;

/* define the initial stack-sizes */
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH  YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 10000
#define YYMAXDEPTH  10000
#endif
#endif

#define YYINITSTACKSIZE 200

typedef struct {
    unsigned stacksize;
    YYINT    *s_base;
    YYINT    *s_mark;
    YYINT    *s_last;
    YYSTYPE  *l_base;
    YYSTYPE  *l_mark;
} YYSTACKDATA;
/* variables for the parser stack */
static YYSTACKDATA yystack;
#line 504 "new-standard-pascal.y"




void file_init()
{
    fwrite(".class public a\n", sizeof(char), 16, ofile);
    fwrite(".super java/lang/Object\n\n", sizeof(char), 25, ofile);

	return;
}

void def_init()
{
	//  print integer
	fwrite(".method public static printint(I)V\n", sizeof(char), 35, ofile);
    fwrite("	.limit stack 100\n", sizeof(char), 18, ofile);
    fwrite("	.limit locals 100\n", sizeof(char), 19, ofile);
	fwrite("		iload 0\n", sizeof(char), 10, ofile);
	fwrite("		getstatic java/lang/System/out Ljava/io/PrintStream;\n", sizeof(char), 55, ofile);
	fwrite("		swap\n", sizeof(char), 7, ofile);
	fwrite("		invokevirtual java/io/PrintStream/print(I)V\n", sizeof(char), 46, ofile);
	fwrite("		return\n", sizeof(char), 9, ofile);
	fwrite(".end method\n\n", sizeof(char), 13, ofile);
	//  print float
	fwrite(".method public static printreal(F)V\n", sizeof(char), 36, ofile);
    fwrite("	.limit stack 100\n", sizeof(char), 18, ofile);
    fwrite("	.limit locals 100\n", sizeof(char), 19, ofile);
	fwrite("		fload 0\n", sizeof(char), 10, ofile);
	fwrite("		getstatic java/lang/System/out Ljava/io/PrintStream;\n", sizeof(char), 55, ofile);
	fwrite("		swap\n", sizeof(char), 7, ofile);
	fwrite("		invokevirtual java/io/PrintStream/print(F)V\n", sizeof(char), 46, ofile);
	fwrite("		return\n", sizeof(char), 9, ofile);
	fwrite(".end method\n\n", sizeof(char), 13, ofile);
	//  print string
	fwrite(".method public static print(Ljava/lang/String;)V\n", sizeof(char), 49, ofile);
    fwrite("	.limit stack 100\n", sizeof(char), 18, ofile);
    fwrite("	.limit locals 100\n", sizeof(char), 19, ofile);
	fwrite("		aload 0\n", sizeof(char), 10, ofile);
	fwrite("		getstatic java/lang/System/out Ljava/io/PrintStream;\n", sizeof(char), 55, ofile);
	fwrite("		swap\n", sizeof(char), 7, ofile);
	fwrite("		invokevirtual java/io/PrintStream/print(Ljava/lang/String;)V\n", sizeof(char), 63, ofile);
	fwrite("		return\n", sizeof(char), 9, ofile);
	fwrite(".end method\n\n", sizeof(char), 13, ofile);
	//  init
    fwrite(".method public <init>()V\n", sizeof(char), 25, ofile);
    fwrite("		aload_0\n", sizeof(char), 10, ofile);
    fwrite("		invokespecial java/lang/Object/<init>()V\n", sizeof(char), 43, ofile);
    fwrite("		return\n", sizeof(char), 9, ofile);
    fwrite(".end method\n\n", sizeof(char), 13, ofile);

	return;
}

void main_init()
{
	//  main
    fwrite(".method public static main([Ljava/lang/String;)V\n", sizeof(char), 49, ofile);
    fwrite("	.limit stack 100\n", sizeof(char), 18, ofile);
    fwrite("	.limit locals 100\n\n", sizeof(char), 20, ofile);

	return;
}

void file_finish()
{
    fwrite("		return\n", sizeof(char), 9, ofile);
    fwrite(".end method\n", sizeof(char), 12, ofile);

	return;
}

void symdestroy(int scope)
{
	sym_node ptr = scope_display[scope];

	while(ptr != NULL){
		scope_display[scope] = ptr->scope;

		fprintf(stdout, "Remove node %s %s %d\n", ptr->cate, ptr->name, scope);
		if((scope != 1) && (scope != 0) && (strcmp(ptr->cate, "VAR") == 0))
			nofvar--;
		rm_sym_node(ptr);  //  **********

		ptr = scope_display[scope];
	}
}

sym_node symcheck(nodeType current, int scope, nodeType retval)
{
	sym_node ptr;
	int current_scope = scope, para, i, isvalue;
	sym_node Ttype;

	do{
		ptr = scope_display[current_scope];
		while(ptr != NULL){
			if(strcmp(ptr->name, current->node_text) == 0){
				if(strcmp(ptr->cate, "PROGRAM") == 0){
					fprintf(stdout, "** Program symbal %s can't be used here **\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else if(strcmp(ptr->cate, "VAR") == 0){
					fprintf(stdout, "** Var symbal %s can't be used here **\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else{
					fprintf(stdout, "** Find symbal %s **\n", ptr->name);
					//  function procedure parameter
					if((strcmp(ptr->cate, "FUNCTION") == 0) || (strcmp(ptr->cate, "PROCEDURE") == 0)){
						para = 0;
						current = current->l_child;
						while(current != NULL){
							if(para == ptr->para){
								if(strcmp(ptr->cate, "FUNCTION") == 0){
									fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
									err++;
									res = 1;
								}
								else{
									fprintf(stdout, "** Wrong number of parameter in procedure %s **\n", ptr->name);
									err++;
									res = 1;
								}
								return NULL;
							}
							if((Ttype = RHSsymlook(current, scope, retval, &isvalue)) == NULL){  //  type comparison
								if(strcmp(ptr->cate, "FUNCTION") == 0){
									fprintf(stdout, "** Wrong syntax of parameter when calling function %s **\n", ptr->name);
									err++;
									res = 1;
								}
								else{
									fprintf(stdout, "** Wrong syntax of parameter when calling procedure %s **\n", ptr->name);
									err++;
									res = 1;
								}
								return NULL;
							}
							if((ptr->ptype[para] == 'I') && ((Ttype->type[0] == 'i') || (Ttype->type[0] == 'I')));  //  ??
							else{
								if((ptr->ptype[para] == 'F') && ((Ttype->type[0] == 'r') || (Ttype->type[0] == 'R')));  //  ??
								else{
									if((ptr->ptype[para] == 'S') && ((Ttype->type[0] == 's') || (Ttype->type[0] == 'S')));  //  ??
									else{
										if(strcmp(ptr->cate, "FUNCTION") == 0){
											fprintf(stdout, "** Wrong type of parameter when calling function %s %s %s**\n", ptr->name);
											err++;
											res = 1;
										}
										else{
											fprintf(stdout, "** Wrong type of parameter when calling procedure %s **\n", ptr->name);
											err++;
											res = 1;
										}
										return NULL;
									}
								}
							}
							para++;
							do{
								current = current->r_sibling;
								if(current == NULL)
									break;
							}while(current->node_type == LBRAC);
						}
						if(para != ptr->para){
							if(strcmp(ptr->cate, "FUNCTION") == 0){
								fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
								err++;
								res = 1;
							}
							else{
								fprintf(stdout, "** Wrong number of parameter in procedure %s **\n", ptr->name);
								err++;
								res = 1;
							}
							return NULL;
						}
						else{
							//sprintf(jasmin, "		invokestatic a/%s(%s)%s\n", ptr->name, ptr->ptype, ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "I" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "F" : (ptr->type[0] == 'V') ? "V" : "Ljava/lang/String;");
							//fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							sprintf(jasmin, "		invokestatic a/%s(", ptr->name);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							for(i = 0; i < ptr->para; i++){
								if(ptr->ptype[i] == 'S'){
									sprintf(jasmin, "%s", "Ljava/lang/String;");
									fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
								}
								else{
									sprintf(jasmin, "%c", ptr->ptype[i]);
									fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
								}
							}
							sprintf(jasmin, ")%s\n", ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "I" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "F" : (ptr->type[0] == 'V') ? "V" : "Ljava/lang/String;");
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							if(strcmp(ptr->cate, "FUNCTION") == 0){
								sprintf(jasmin, "		pop\n");
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
							return ptr;
						}
					}
					//  no need array bound
					return ptr;
				}
			}
			ptr = ptr->scope;
		}
	}while(current_scope--);
	
	fprintf(stdout, "** Undeclared symbal %s **\n", current->node_text);
	err++;
	res = 1;
	return NULL;
}

sym_node RHSsymcheck(nodeType current, int scope, nodeType retval)
{
	sym_node ptr, Ttype;
	int current_scope = scope, array, para, i = 0, isvalue;
	
	do{
		ptr = scope_display[current_scope];
		while(ptr != NULL){
			if(strcmp(ptr->name, current->node_text) == 0){
				if(strcmp(ptr->cate, "PROCEDURE") == 0){
					fprintf(stdout, "** Procedure symbal %s can't be RHS **\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else if(strcmp(ptr->cate, "PROGRAM") == 0){
					fprintf(stdout, "** Program symbal %s can't be RHS **\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else{
					if((ptr->init == 0) && (retval == NULL)){
						fprintf(stdout, "** Use %s after initialization **\n", ptr->name);
						err++;
						res = 1;
						return NULL;
					}

					fprintf(stdout, "** Find symbal %s in RHS **\n", ptr->name);
					//  function parameter
					if((strcmp(ptr->cate, "FUNCTION") == 0)){
						para = 0;
						current = current->l_child;
						while(current != NULL){
							if(para == ptr->para){
								fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
								err++;
								res = 1;
								return NULL;
							}
							if((Ttype = RHSsymlook(current, scope, retval, &isvalue)) == NULL){
								fprintf(stdout, "** Wrong parameter in function %s **\n", ptr->name);
								err++;
								res = 1;
								return NULL;
							}
							if((ptr->ptype[para] == 'I') && ((Ttype->type[0] == 'i') || (Ttype->type[0] == 'I')));  //  ??
							else{
								if((ptr->ptype[para] == 'F') && ((Ttype->type[0] == 'r') || (Ttype->type[0] == 'R')));  //  ??
								else{
									if((ptr->ptype[para] == 'S') && ((Ttype->type[0] == 's') || (Ttype->type[0] == 'S')));  //  ??
									else{
										if(strcmp(ptr->cate, "FUNCTION") == 0){
											fprintf(stdout, "** Wrong type of parameter when calling function %s **\n", ptr->name);
											err++;
											res = 1;
										}
										else{
											fprintf(stdout, "** Wrong type of parameter when calling procedure %s **\n", ptr->name);
											err++;
											res = 1;
										}
										return NULL;
									}
								}
							}
							para++;
							do{
								current = current->r_sibling;
								if(current == NULL)
									break;
							}while(current->node_type == LBRAC);
						}
						if(para != ptr->para){
							fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
							err++;
							res = 1;
							return NULL;
						}
						else{
							//sprintf(jasmin, "		invokestatic a/%s(%s)%s\n", ptr->name, ptr->ptype, ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "I" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "F" : "Ljava/lang/String;");
							//fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							

							sprintf(jasmin, "		invokestatic a/%s(", ptr->name);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							for(i = 0; i < ptr->para; i++){
								if(ptr->ptype[i] == 'S'){
									sprintf(jasmin, "%s", "Ljava/lang/String;");
									fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
								}
								else{
									sprintf(jasmin, "%c", ptr->ptype[i]);
									fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
								}
							}
							sprintf(jasmin, ")%s\n", ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "I" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "F" : "Ljava/lang/String;");
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							return ptr;
						}
					}
					//  array bound
					else{
						array = ptr->array;
						current = current->r_sibling;
						while(current != NULL){
							if(current->node_type == LBRAC){
								if((array--) == 0){
									fprintf(stdout, "** Wrong number of dimension symbal %s in RHS **\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
								if((Ttype = RHSsymlook(current->l_child, scope, retval, &isvalue)) == NULL){  //XXXX
									fprintf(stdout, "** Wrong expression in array %s of RHS **\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
								if((Ttype->type[0] != 'i') && (Ttype->type[0] != 'I')){
									fprintf(stdout, "** Wrong parameter type in array %s of RHS **\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
								else{
									if(isvalue == 0){
										current = current->r_sibling;
										continue;
									}

									if(Ttype->ivalue < ptr->bound[i++]){
										fprintf(stdout, "** Out of bound %s of RHS **\n", ptr->name);
										err++;
										res = 1;
										return NULL;
									}
									if(Ttype->ivalue > ptr->bound[i++]){
										fprintf(stdout, "** Out of bound %s of RHS **\n", ptr->name);
										err++;
										res = 1;
										return NULL;
									}
								}
								current = current->r_sibling;
							}
							else
								break;
						}
						if(array != 0){
							fprintf(stdout, "** Wrong number of dimension symbal %s in RHS **\n", ptr->name);
							err++;
							res = 1;
							return NULL;
						}
						else
							return ptr;
					}
				}
			}
			ptr = ptr->scope;
		}
	}while(current_scope--);
	
	fprintf(stdout, "** Undeclared symbal %s **\n", current->node_text);
	err++;
	res = 1;
	return NULL;
}

sym_node LHSsymcheck(nodeType current, int scope, nodeType retval)
{
	sym_node ptr, Ttype;
	int current_scope = scope, array, i = 0, isvalue;

	do{
		ptr = scope_display[current_scope];
		while(ptr != NULL){
			if(strcmp(ptr->name, current->node_text) == 0){
				if(strcmp(ptr->cate, "FUNCTION") == 0){
					if(strcmp(current->node_text, retval->node_text) == 0){
						fprintf(stdout, "** Find return symbal %s in LHS **\n", ptr->name);
						err++;
						res = 1;
						return ptr;
					}
					else{
						fprintf(stdout, "** Function symbal %s can't be LHS **\n", ptr->name);
						err++;
						res = 1;
						return NULL;
					}
				}
				else if(strcmp(ptr->cate, "PROCEDURE") == 0){
					fprintf(stdout, "** Procedure symbal %s can't be LHS **\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else if(strcmp(ptr->cate, "PROGRAM") == 0){
					fprintf(stdout, "** Program symbal %s can't be LHS **\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else{
					fprintf(stdout, "** Find symbal %s in LHS **\n", ptr->name);
					//  array bound
					array = ptr->array;
					current = current->r_sibling;
					while(current != NULL){
						if(current->node_type == LBRAC){
							if((array--) == 0){
								fprintf(stdout, "** Wrong number of dimension symbal %s in LHS **\n", ptr->name);
								err++;
								res = 1;
								return NULL;
							}
							if((Ttype = RHSsymlook(current->l_child, scope, retval, &isvalue)) == NULL){  //XXXX
								fprintf(stdout, "** Wrong expression in array %s of LHS **\n", ptr->name);
								err++;
								res = 1;
								return NULL;
							}
							if((Ttype->type[0] != 'i') && (Ttype->type[0] != 'I')){
								fprintf(stdout, "** Wrong parameter type in array %s of LHS **\n", ptr->name);
								err++;
								res = 1;
								return NULL;
							}
							else{
								if(isvalue == 0){
									current = current->r_sibling;
									continue;
								}
								
								if(Ttype->ivalue < ptr->bound[i++]){
									fprintf(stdout, "** Out of bound %s of LHS **\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
								if(Ttype->ivalue > ptr->bound[i++]){
									fprintf(stdout, "** Out of bound %s of LHS **\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
							}
							current = current->r_sibling;
						}
						else
							break;
					}
					if(array != 0){
						fprintf(stdout, "** Wrong number of dimension symbal %s in RHS **\n", ptr->name);
						err++;
						res = 1;
						return NULL;
					}
					else
						return ptr;
				}
			}
			ptr = ptr->scope;
		}
	}while(current_scope--);
	
	fprintf(stdout, "** Undeclared symbal %s **\n", current->node_text);
	err++;
	res = 1;
	return NULL;
}

int Ievaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval)
{
	int aa, bb;
	sym_node ptr;
	
	if(a->node_type == DIGSEQ){
		sprintf(jasmin, "		ldc %d\n", a->node_ivalue);
		fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		aa = a->node_ivalue;
	}
	else if(a->node_type == IDENTIFIER || a->node_type == FUNCTION){
		if((ptr = RHSsymcheck(a, scope, retval)) == NULL){  //  Undeclared
			*check = 4;
			return 0;
		}
		if((ptr->type[0] == 'i') || (ptr->type[0] == 'I')){  //  Variable
			if(ptr->j_var == -1){
				sprintf(jasmin, "		getstatic a/%s %s\n", ptr->name, "I");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			else{
				sprintf(jasmin, "		iload %d\n", ptr->j_var);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			*check = 1;
		}
		else{
			*check = 2;
			return 0;
		}
	}
	else if((a->node_type == PLUS) || (a->node_type == MINUS) || (a->node_type == STAR) || (a->node_type == SLASH)){
		aa = Ievaluate(a, a->l_child, a->l_child->r_sibling, scope, check, retval);
		if((*check == 2) && (*check == 3))
			return 0;
	}
	else{  //  Wrong type
		*check = 2;
		return 0;
	}
	
	if(b->node_type == DIGSEQ){
		sprintf(jasmin, "		ldc %d\n", b->node_ivalue);
		fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		bb = b->node_ivalue;
	}
	else if(b->node_type == IDENTIFIER || b->node_type == FUNCTION){
		if((ptr = RHSsymcheck(b, scope, retval)) == NULL){  //  Undeclared
			*check = 4;
			return 0;
		}
		if((ptr->type[0] == 'i') || (ptr->type[0] == 'I')){  //  Variable
			if(ptr->j_var == -1){
				sprintf(jasmin, "		getstatic a/%s %s\n", ptr->name, "I");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			else{
				sprintf(jasmin, "		iload %d\n", ptr->j_var);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			*check = 1;
		}
		else{
			*check = 2;
			return 0;
		}
	}
	else if((b->node_type == PLUS) || (b->node_type == MINUS) || (b->node_type == STAR) || (b->node_type == SLASH)){
		bb = Ievaluate(b, b->l_child, b->l_child->r_sibling, scope, check, retval);
		if((*check == 2) && (*check == 3))
			return 0;
	}
	else{  //  Wrong type
		*check = 2;
		return 0;
	}
	
	if(*check != 1){
		if(op->node_type == PLUS){
			sprintf(jasmin, "		iadd\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			return aa+bb;
		}
		else if(op->node_type == MINUS){
			sprintf(jasmin, "		isub\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			return aa-bb;
		}
		else if(op->node_type == STAR){
			sprintf(jasmin, "		imul\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			return aa*bb;
		}
		else{
			if(bb == 0){  //  divided by zero
				*check = 3;
				return 0;
			}
			sprintf(jasmin, "		idiv\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			return aa/bb;
		}
	}
	else{
		if(op->node_type == PLUS){
			sprintf(jasmin, "		iadd\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		else if(op->node_type == MINUS){
			sprintf(jasmin, "		isub\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		else if(op->node_type == STAR){
			sprintf(jasmin, "		imul\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		else{
			if(bb == 0){  //  divided by zero
				*check = 3;
				return 0;
			}
			sprintf(jasmin, "		idiv\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		return 0;
	}
}

float Revaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval)
{
	float aa, bb;
	sym_node ptr;

	if(a->node_type == REALNUMBER){
		sprintf(jasmin, "		ldc %f\n", a->node_fvalue);
		fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		aa = a->node_fvalue;
	}
	else if(a->node_type == IDENTIFIER || a->node_type == FUNCTION){
		if((ptr = RHSsymcheck(a, scope, retval)) == NULL){  //  Undeclared
			*check = 4;
			return 0;
		}
		if((ptr->type[0] == 'r') || (ptr->type[0] == 'R')){  //  Variable
			if(ptr->j_var == -1){
				sprintf(jasmin, "		getstatic a/%s %s\n", ptr->name, "F");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			else{
				sprintf(jasmin, "		fload %d\n", ptr->j_var);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			*check = 1;
		}
		else{
			*check = 2;
			return 0;
		}
	}
	else if((a->node_type == PLUS) || (a->node_type == MINUS) || (a->node_type == STAR) || (a->node_type == SLASH)){
		aa = Revaluate(a, a->l_child, a->l_child->r_sibling, scope, check, retval);
		if((*check == 2) && (*check == 3))
			return 0;
	}
	else{  //  Wrong type
		*check = 2;
		return 0;
	}
	
	if(b->node_type == REALNUMBER){
		sprintf(jasmin, "		ldc %f\n", b->node_fvalue);
		fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		bb = b->node_fvalue;
	}
	else if(b->node_type == IDENTIFIER || b->node_type == FUNCTION){
		if((ptr = RHSsymcheck(b, scope, retval)) == NULL){  //  Undeclared
			*check = 4;
			return 0;
		}
		if((ptr->type[0] == 'r') || (ptr->type[0] == 'R')){  //  Variable
			if(ptr->j_var == -1){
				sprintf(jasmin, "		getstatic a/%s %s\n", ptr->name, "F");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			else{
				sprintf(jasmin, "		fload %d\n", ptr->j_var);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			*check = 1;
		}
		else{
			*check = 2;
			return 0;
		}
	}
	else if((b->node_type == PLUS) || (b->node_type == MINUS) || (b->node_type == STAR) || (b->node_type == SLASH)){
		bb = Revaluate(b, b->l_child, b->l_child->r_sibling, scope, check, retval);
		if((*check == 2) && (*check == 3))
			return 0;
	}
	else{  //  Wrong type
		*check = 2;
		return 0;
	}
	
	if(*check != 1){
		if(op->node_type == PLUS){
			sprintf(jasmin, "		fadd\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			return aa+bb;
		}
		else if(op->node_type == MINUS){
			sprintf(jasmin, "		fsub\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			return aa-bb;
		}
		else if(op->node_type == STAR){
			sprintf(jasmin, "		fmul\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			return aa*bb;
		}
		else{
			if(bb == 0){  //  divided by zero
				*check = 3;
				return 0;
			}
			sprintf(jasmin, "		fdiv\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			return aa/bb;
		}
	}
	else{
		if(op->node_type == PLUS){
			sprintf(jasmin, "		fadd\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		else if(op->node_type == MINUS){
			sprintf(jasmin, "		fsub\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		else if(op->node_type == STAR){
			sprintf(jasmin, "		fmul\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		else{
			if(bb == 0){  //  divided by zero
				*check = 3;
				return 0;
			}
			sprintf(jasmin, "		fdiv\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		return 0;
	}
}

sym_node RHSsymlook(nodeType current, int scope, nodeType retval, int* isvalue)
{
	int check = 0, ians = 0;
	float fans = 0;
	char *text = NULL;
	sym_node Ttype = NULL;
	nodeType temp;
	
	*isvalue = 0;
	if(current->node_type == IDENTIFIER){
		if((Ttype = RHSsymcheck(current, scope, retval)) == NULL){
			check = 4;
			goto RHSresult;
		}

		if(strcmp(Ttype->cate, "FUNCTION") == 0){
			check = 1;
			goto RHSresult;
		}
		if((Ttype->type[0] == 'i') || (Ttype->type[0] == 'I')){
			if(Ttype->j_var == -1){
				sprintf(jasmin, "		getstatic a/%s %s\n", Ttype->name, "I");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			else{
				sprintf(jasmin, "		iload %d\n", Ttype->j_var);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			check = 1;
			Ttype = I;
			goto RHSresult;
		}
		if((Ttype->type[0] == 'r') || (Ttype->type[0] == 'R')){
			if(Ttype->j_var == -1){
				sprintf(jasmin, "		getstatic a/%s %s\n", Ttype->name, "F");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			else{
				sprintf(jasmin, "		fload %d\n", Ttype->j_var);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			check = 1;
			Ttype = R;
			goto RHSresult;
		}
		if((Ttype->type[0] == 's') || (Ttype->type[0] == 'S')){
			if(Ttype->j_var == -1){
				sprintf(jasmin, "		getstatic a/%s %s\n", Ttype->name, "Ljava/lang/String;");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			else{
				sprintf(jasmin, "		aload %d\n", Ttype->j_var);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			check = 1;
			Ttype = S;
			goto RHSresult;
		}
	}

	if(current->node_type == DIGSEQ){
		ians = current->node_ivalue;
		*isvalue = 1;
		Ttype = I;
		sprintf(jasmin, "		ldc %d\n", current->node_ivalue);
		fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		goto RHSresult;
	}
	if((current->node_type == PLUS) || (current->node_type == MINUS) || (current->node_type == STAR) || (current->node_type == SLASH)){
			//  fprintf(stdout, "** Wrong **");
		temp = current->l_child->r_sibling;
		while(temp != NULL)
			if(temp->node_type == LBRAC)  //  avoid array dimension
				temp = temp->r_sibling;
			else
				break;

		ians = Ievaluate(current, current->l_child, temp, scope, &check, retval);
		if(check == 0)
			*isvalue = 1;
		if((check == 0) || (check == 1))
			Ttype = I;
		if(check != 2)
			goto RHSresult;
	}

	check = 0;
	if(current->node_type == REALNUMBER){
		fans = current->node_fvalue;
		*isvalue = 1;
		Ttype = R;
		sprintf(jasmin, "		ldc %f\n", current->node_fvalue);
		fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		goto RHSresult;
	}
	if((current->node_type == PLUS) || (current->node_type == MINUS) || (current->node_type == STAR) || (current->node_type == SLASH)){
		fans = Revaluate(current, current->l_child, temp, scope, &check, retval);
		if(check == 0)
			*isvalue = 1;
		if((check == 0) || (check == 1))
			Ttype = R;
		if(check != 2)
			goto RHSresult;
	}

	check = 0;
	if(current->node_type == CHARACTER_STRING){
		text = (char*)malloc(strlen(current->node_text)+1);
		*isvalue = 1;
		Ttype = S;
		sprintf(jasmin, "		ldc %s\n", current->node_text);
		fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		goto RHSresult;
	}
	return NULL;

	RHSresult:
		if(Ttype != NULL){
			Ttype->ivalue = ians;
			Ttype->fvalue = fans;
		}
		if(check == 0)  //  Normal constant
			return Ttype;
		else if(check == 1)  //  Contain variable
			return Ttype;
		else if(check == 2)  //  Wrong type
			return NULL;
		else if(check == 3)  //  Divided by zero
			return NULL;
		else if(check == 4)  //  Undeclared
			return NULL;
}

void symlook(nodeType current, int scope, nodeType retval)
{
	char *cate = NULL, *type = NULL, *name = NULL, *ttype = NULL;
	int array = 0, para = 0, i = 0, tnoflabel = 0;
	int *bound = NULL, isvalue;
	nodeType origin = current, temp[2];
	sym_node Ltype, Rtype, Ttype;
	if(current->node_type == VAR){
		cate = (char*)malloc(4);
		strcpy(cate, "VAR");

		current = current->l_child;
		if(current->node_type == ARRAY){
			array = current->node_ivalue;
			current = current->l_child;
			bound = (int*)malloc(sizeof(int)*array*2);
			for(i = 0; i < array*2; i+=2){
				bound[i] = current->node_ivalue;
				current = current->r_sibling;
				bound[i+1] = current->node_ivalue;
				current = current->r_sibling;
			}
		}
		type = (char*)malloc(strlen(current->node_text)+1);
		strcpy(type, current->node_text);

		current = origin->l_child->r_sibling;
		while(current != NULL){
			name = (char*)malloc(strlen(current->node_text)+1);
			strcpy(name, current->node_text);
			if((Ttype = new_sym_node(cate, name, type, array, bound, scope)) == NULL){  //  **********
				fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
				err++;
				res = 1;
			}
			else{
				fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
				if(scope == 1){
					sprintf(jasmin, ".field public static %s %s\n", name, ((type[0] == 'I') || (type[0] == 'i')) ? "I" : ((type[0] == 'R') || (type[0] == 'r')) ? "F" : "Ljava/lang/String;");
					fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
				}
				else
					Ttype->j_var = ++nofvar;  //  NOF
            }
			free(name);
			current = current->r_sibling;
		}
		free(cate);
		free(type);
		free(bound);
		
		if(origin->r_sibling != NULL)
			symlook(origin->r_sibling, scope, retval);
	}
	else if(current->node_type == FUNCTION){
		cate = (char*)malloc(9);
		strcpy(cate, "FUNCTION");

		current = current->l_child;
		ttype = (char*)malloc(strlen(current->node_text)+1);
		strcpy(ttype, current->node_text);
		
		current = current->r_sibling;
		name = (char*)malloc(strlen(current->node_text)+1);
		strcpy(name, current->node_text);
		if((Ttype = new_sym_node(cate, name, ttype, array, NULL, scope)) == NULL){  //  **********
			fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
			err++;
			res = 1;
			if(origin->r_sibling != NULL)
				symlook(origin->r_sibling, scope, retval);
			return;
		}
		else{
			fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
    		sprintf(jasmin, ".method public static %s(", name);
    		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
		}
		free(name);
		free(cate);

		scope++;
		fprintf(stdout, "New scope %d\n", scope);
		
		cate = (char*)malloc(4);
		strcpy(cate, "VAR");

		temp[0] = current->l_child;
		while(temp[0] != NULL){
			if(temp[0]->node_type == EMPTY)
				break;
			type = (char*)malloc(strlen(temp[0]->node_text)+1);
			strcpy(type, temp[0]->node_text);
			temp[1] = temp[0]->l_child;
			while(temp[1] != NULL){
				nofvar++;  //  NOF
				name = (char*)malloc(strlen(temp[1]->node_text)+1);
				strcpy(name, temp[1]->node_text);
				if(new_sym_node(cate, name, type, array, NULL, scope) == NULL){  //  **********
					fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
					err++;
					res = 1;
				}
				else{
					fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
					sprintf(jasmin, "%s", ((type[0] == 'I') || (type[0] == 'i')) ? "I" : ((type[0] == 'R') || (type[0] == 'r')) ? "F" : "Ljava/lang/String;");
		    		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
					Ttype->ptype[para++] = ((type[0] == 'I') || (type[0] == 'i')) ? 'I' : ((type[0] == 'R') || (type[0] == 'r')) ? 'F' : 'S';  //  number of parameter
				}
				free(name);
				temp[1] = temp[1]->r_sibling;
			}
			free(type);
			temp[0] = temp[0]->r_sibling;
		}
		sprintf(jasmin, ")%s\n", ((ttype[0] == 'I') || (ttype[0] == 'i')) ? "I" : ((ttype[0] == 'R') || (ttype[0] == 'r')) ? "F" : "Ljava/lang/String;");
		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
		fwrite("	.limit stack 100\n", sizeof(char), 18, ofile);
		fwrite("	.limit locals 100\n", sizeof(char), 19, ofile);
		Ttype->para = para;  //  insert the number of parameter into function IDENTIFIER
		Ttype->j_var = ++nofvar;  //  NOF
		free(cate);
		
		current = origin->l_child->r_sibling->r_sibling;
		if(current != NULL)
			symlook(current, scope, origin->l_child->r_sibling);

		symdestroy(scope);
		fprintf(stdout, "Close scope %d\n", scope);
		sprintf(jasmin, "		%sload %d\n", ((ttype[0] == 'I') || (ttype[0] == 'i')) ? "i" : ((ttype[0] == 'R') || (ttype[0] == 'r')) ? "f" : "a", Ttype->j_var);
		fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		sprintf(jasmin, "		%sreturn\n", ((ttype[0] == 'I') || (ttype[0] == 'i')) ? "i" : ((ttype[0] == 'R') || (ttype[0] == 'r')) ? "f" : "a");
		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
		sprintf(jasmin, ".end method\n\n");
		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
		free(ttype);
		nofvar--;  //  NOF
		scope--;

		if(origin->r_sibling != NULL)
			symlook(origin->r_sibling, scope, retval);
	}
	else if(current->node_type == PROCEDURE){
		cate = (char*)malloc(10);
		strcpy(cate, "PROCEDURE");

		current = current->l_child->r_sibling;
		name = (char*)malloc(strlen(current->node_text)+1);
		strcpy(name, current->node_text);

		type = (char*)malloc(5);
		strcpy(type, "VOID");
		if((Ttype = new_sym_node(cate, name, type, array, NULL, scope)) == NULL){  //  **********
			fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
			if(origin->r_sibling != NULL)
				symlook(origin->r_sibling, scope, retval);
			return;
		}
		else{
			fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
    		sprintf(jasmin, ".method public static %s(", name);
    		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
		}
		free(cate);
		free(name);
		free(type);

		scope++;
		fprintf(stdout, "New scope %d\n", scope);

		cate = (char*)malloc(4);
		strcpy(cate, "VAR");
	
		temp[0] = current->l_child;
		while(temp[0] != NULL){
			if(temp[0]->node_type == EMPTY)
				break;
			type = (char*)malloc(strlen(temp[0]->node_text)+1);
			strcpy(type, temp[0]->node_text);
			temp[1] = temp[0]->l_child;
			while(temp[1] != NULL){
				nofvar++;  //  NOF
				if(temp[1]->node_type != IDENTIFIER)
					break;
				name = (char*)malloc(strlen(temp[1]->node_text)+1);
				strcpy(name, temp[1]->node_text);
				if(new_sym_node(cate, name, type, array, NULL, scope) == NULL){  //  **********
					fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
					err++;
					res = 1;
				}
				else{
					fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
					sprintf(jasmin, "%s", ((type[0] == 'I') || (type[0] == 'i')) ? "I" : ((type[0] == 'R') || (type[0] == 'r')) ? "F" : "Ljava/lang/String;");
		    		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
					Ttype->ptype[para++] = ((type[0] == 'I') || (type[0] == 'i')) ? 'I' : ((type[0] == 'R') || (type[0] == 'r')) ? 'F' : 'S';  //  number of parameter
				}
				free(name);
				temp[1] = temp[1]->r_sibling;
			}
			free(type);
			temp[0] = temp[0]->r_sibling;
		}
		sprintf(jasmin, ")%s\n", "V");
		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
		fwrite("	.limit stack 100\n", sizeof(char), 18, ofile);
		fwrite("	.limit locals 100\n", sizeof(char), 19, ofile);
		Ttype->para = para;  //  insert the number of parameter into function IDENTIFIER
		free(cate);
		
		current = origin->l_child->r_sibling->r_sibling;
		if(current != NULL)
			symlook(current, scope, origin->l_child->r_sibling);

		symdestroy(scope);
		fprintf(stdout, "Close scope %d\n", scope);
		sprintf(jasmin, "		return\n");
		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
		sprintf(jasmin, ".end method\n\n");
		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
		scope--;

		if(origin->r_sibling != NULL)
			symlook(origin->r_sibling, scope, retval);
	}
	else if(current->node_type == PROGRAM){
		cate = (char*)malloc(8);
		strcpy(cate, "PROGRAM");
		
		current = current->l_child;
		name = (char*)malloc(strlen(current->node_text)+1);
		strcpy(name, current->node_text);

		/* printf function predefinition */
		cate = (char*)malloc(10);
		strcpy(cate, "PROCEDURE");

		name = (char*)malloc(9);
		strcpy(name, "printint");

		type = (char*)malloc(5);
		strcpy(type, "VOID");
		
		Ttype = new_sym_node(cate, name, type, 0, NULL, scope);  //  **********

		Ttype->para = 1;
		Ttype->ptype[0] = 'I';


		cate = (char*)malloc(10);
		strcpy(cate, "PROCEDURE");

		name = (char*)malloc(10);
		strcpy(name, "printreal");

		type = (char*)malloc(5);
		strcpy(type, "VOID");
		
		Ttype = new_sym_node(cate, name, type, 0, NULL, scope);  //  **********

		Ttype->para = 1;
		Ttype->ptype[0] = 'F';


		cate = (char*)malloc(10);
		strcpy(cate, "PROCEDURE");

		name = (char*)malloc(6);
		strcpy(name, "print");

		type = (char*)malloc(5);
		strcpy(type, "VOID");
		
		Ttype = new_sym_node(cate, name, type, 0, NULL, scope);  //  **********

		Ttype->para = 1;
		Ttype->ptype[0] = 'S';
		/* printf function predefinition */

		new_sym_node(cate, name, NULL, array, NULL, scope);  //  **********
		fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
		free(name);
		free(cate);

		scope++;
		fprintf(stdout, "New scope %d\n", scope);
		if(current->r_sibling != NULL)
			symlook(current->r_sibling, scope, origin->r_sibling);

		symdestroy(scope);
		fprintf(stdout, "Close scope %d\n", scope);
		scope--;
	}
	else{  //  NOW
		if(current->node_type == ASSIGNMENT){
			temp[0] = current->l_child;
			
			if((Ltype = LHSsymcheck(temp[0], scope, retval)) == NULL){
				fprintf(stdout, "** Wrong LHS **\n");
				err++;
				res = 1;
				goto Next;
			}
			temp[0] = temp[0]->r_sibling;
			while(temp[0]->node_type == LBRAC)
				temp[0] = temp[0]->r_sibling;

			if((Rtype = RHSsymlook(temp[0], scope, retval, &isvalue)) == NULL){
				fprintf(stdout, "** Wrong RHS **\n");
				err++;
				res = 1;
				goto Next;
			}
			Ltype->init = 1;
			
			if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I'))){
				if(Ltype->j_var == -1){
					sprintf(jasmin, "		putstatic a/%s %s\n", Ltype->name, "I");
					fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
				}
				else{
					sprintf(jasmin, "		istore %d\n", Ltype->j_var);
					fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
				}
			}
			else{
				if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R'))){
					if(Ltype->j_var == -1){
						sprintf(jasmin, "		putstatic a/%s %s\n", Ltype->name, "F");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else{
						sprintf(jasmin, "		fstore %d\n", Ltype->j_var);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
				}
				else{
					if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S'))){
						if(Ltype->j_var == -1){
							sprintf(jasmin, "		putstatic a/%s %s\n", Ltype->name, "Ljava/lang/String;");
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
						else{
							sprintf(jasmin, "		astore %d\n", Ltype->j_var);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
					}
					else{
						fprintf(stdout, "** Wrong type between LHS & RHS **\n");
						err++;
						res = 1;
					}
				}
			}
			goto Next;
		}
		else if(current->node_type == IF){
			temp[0] = current->l_child;
			
			if((temp[0]->node_type == NOTEQUAL) || (temp[0]->node_type == EQUAL) || (temp[0]->node_type == GE) || (temp[0]->node_type == GT) || (temp[0]->node_type == LE) || (temp[0]->node_type == LT)){  //  factor
				sprintf(jasmin, "	%s%d-%d:\n", "IF", noflabel, nofnest);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
				if((Ltype = RHSsymlook(temp[0]->l_child, scope, retval, &isvalue)) == NULL){
					fprintf(stdout, "** Wrong expression in if statement **\n");
					err++;
					res = 1;
					goto Next;
				}
				if((Rtype = RHSsymlook(temp[0]->l_child->r_sibling, scope, retval, &isvalue)) == NULL){
					fprintf(stdout, "** Wrong expression in if statement **\n");
					err++;
					res = 1;
					goto Next;
				}

				if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I'))){
					if(temp[0]->node_type == NOTEQUAL){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifne %s%d-%d\n", "THEN", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == EQUAL){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifeq %s%d-%d\n", "THEN", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == GE){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifge %s%d-%d\n", "THEN", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == GT){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifgt %s%d-%d\n", "THEN", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == LE){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifle %s%d-%d\n", "THEN", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == LT){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		iflt %s%d-%d\n", "THEN", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
				}
				else{
					if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R'))){
						fprintf(stdout, "** Can't use real number in expression **\n");
						err++;
						res = 1;
						goto Next;
					}
					else{
						if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S'))){
							fprintf(stdout, "** Can't use string in expression **\n");
							err++;
							res = 1;
							goto Next;
						}
						else{
							fprintf(stdout, "** Wrong type between LHS & RHS **\n");
							err++;
							res = 1;
							goto Next;			
						}
					}
				}
			}
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;
			
			tnoflabel = noflabel;  //  NOF
			nofnest++;  //  NOF
			symlook(temp[1], scope, retval);
			noflabel = tnoflabel;  //  NOF
			nofnest--;  //  NOF
			sprintf(jasmin, "		goto %s%d-%d\n", "ENDIF", noflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;

			sprintf(jasmin, "	%s%d-%d:\n", "THEN", noflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			tnoflabel = noflabel;  //  NOF
			nofnest++;  //  NOF
			symlook(temp[1], scope, retval);
			noflabel = tnoflabel;  //  NOF
			nofnest--;  //  NOF
			sprintf(jasmin, "	%s%d-%d:\n", "ENDIF", noflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);

			noflabel++;  //  NOF
			goto Next;
		}
		else if(current->node_type == WHILE){
			temp[0] = current->l_child;
			
			if((temp[0]->node_type == NOTEQUAL) || (temp[0]->node_type == EQUAL) || (temp[0]->node_type == GE) || (temp[0]->node_type == GT) || (temp[0]->node_type == LE) || (temp[0]->node_type == LT)){  //  factor
				sprintf(jasmin, "	%s%d-%d:\n", "WHILE", noflabel, nofnest);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
				if((Ltype = RHSsymlook(temp[0]->l_child, scope, retval, &isvalue)) == NULL){
					fprintf(stdout, "** Wrong expression in if statement **\n");
					err++;
					res = 1;
					goto Next;
				}
				if((Rtype = RHSsymlook(temp[0]->l_child->r_sibling, scope, retval, &isvalue)) == NULL){
					fprintf(stdout, "** Wrong expression in if statement **\n");
					err++;
					res = 1;
					goto Next;
				}

				if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I'))){
					if(temp[0]->node_type == NOTEQUAL){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifne %s%d-%d\n", "DO", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == EQUAL){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifeq %s%d-%d\n", "DO", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == GE){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifge %s%d-%d\n", "DO", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == GT){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifgt %s%d-%d\n", "DO", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == LE){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifle %s%d-%d\n", "DO", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == LT){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		iflt %s%d-%d\n", "DO", noflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
				}
				else{
					if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R'))){
						fprintf(stdout, "** Can't use real number in expression **\n");
						err++;
						res = 1;
						goto Next;
					}
					else{
						if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S'))){
							fprintf(stdout, "** Can't use string in expression **\n");
							err++;
							res = 1;
							goto Next;
						}
						else{
							fprintf(stdout, "** Wrong type between LHS & RHS **\n");
							err++;
							res = 1;
							goto Next;
						}
					}
				}
			}
			sprintf(jasmin, "		goto %s%d-%d\n", "ENDWHILE", noflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;

			sprintf(jasmin, "	%s%d-%d:\n", "DO", noflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			tnoflabel = noflabel;  //  NOF
			nofnest++;  //  NOF
			symlook(temp[1], scope, retval);
			noflabel = tnoflabel;  //  NOF
			nofnest--;  //  NOF
			sprintf(jasmin, "		goto %s%d-%d\n", "WHILE", noflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			sprintf(jasmin, "	%s%d-%d:\n", "ENDWHILE", noflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			
			noflabel++;
			goto Next;
		}
		else if(current->node_type == IDENTIFIER){  //  function & procedure
			temp[0] = current;
			if((Ltype = symcheck(temp[0], scope, retval)) != NULL);
			else{
				fprintf(stdout, "** Error occured, some error in function or procedure **\n");
				err++;
				res = 1;
			}
			
			goto Next;
		}
		else if(current->node_type == PBEGIN){
			B_E++;
			fprintf(stdout, "** Begin **\n");
			if((definition == 0) && (scope == 1)){
				def_init();
				main_init();
				definition = 1;
			}
			goto Next;
		}
		else if(current->node_type == END){  //  when the scope is closed, delete the correspond sym_node
			if(--B_E < 0){
				fprintf(stdout, "** Error occured, expect a previous begin **\n");
				err++;
				res = 1;
			}
			fprintf(stdout, "** End **\n");
			return;
		}
		else{
			if(current->l_child != NULL)
				symlook(current->l_child, scope, retval);
			Next:
				if(current->r_sibling != NULL)
					symlook(current->r_sibling, scope, retval);
		}
	}
}

int main(int argc, char** argv) {
	fprintf(stderr, "open file.\n\n");
	if(argc>1 && freopen(argv[1],"r",stdin)==NULL){
		return 1;
	}
    
    ofile = fopen("a.out", "w");
	fprintf(stderr, "********** Syntax Checking & Parsing **********\n\n");
	yyparse();
	fprintf(stdout, "after call yyparse, res = %d, err = %d.\n\n", res, err);
	fprintf(stderr, "********** Syntax Checking & Parsing **********\n\n");
	if(res == 1){
		fclose(ofile);
		fprintf(stderr, "ERROR\n\n");
		return 1;
	}
	else{
		fprintf(stderr, "SUCCESS\n\n");
	}

//	fprintf(stdout, "********** Abstract Syntax Tree **********\n\n");
//	print_AST(AST);
//	fprintf(stdout, "\n\n********** Abstract Syntax Tree **********\n\n");

	fprintf(stdout, "********** Symbol Table Checking **********\n\n");
    file_init();
	fprintf(stdout, "Create symbal table\n\n");
	I = new_sym_node("VAR", "Integer", "INTEGER", 0, NULL, 9);  //  *****
	R = new_sym_node("VAR", "Real", "REAL", 0, NULL, 9);  //  *****
	S = new_sym_node("VAR", "String", "STRING", 0, NULL, 9);  //  *****
	symlook(AST, 0, NULL);
	symdestroy(0);
	rm_sym_node(I);
	rm_sym_node(R);
	rm_sym_node(S);
	fprintf(stdout, "Destroy symbal table\n\n");
    file_finish();
	fprintf(stdout, "after call symlook, res = %d, err = %d.\n\n", res, err);
	fprintf(stdout, "********** Symbol Table Checking **********\n\n");
	if (res == 1){
		fclose(ofile);
		fprintf(stderr, "ERROR\n\n");
		return 1;
	}
	else{
		fclose(ofile);
		fprintf(stderr, "SUCCESS\n\n");
		return 0;
	}
}

#include "lex.yy.c"
#line 1987 "y.tab.c"

#if YYDEBUG
#include <stdio.h>		/* needed for printf */
#endif

#include <stdlib.h>	/* needed for malloc, etc */
#include <string.h>	/* needed for memset */

/* allocate initial stack or double stack size, up to YYMAXDEPTH */
static int yygrowstack(YYSTACKDATA *data)
{
    int i;
    unsigned newsize;
    YYINT *newss;
    YYSTYPE *newvs;

    if ((newsize = data->stacksize) == 0)
        newsize = YYINITSTACKSIZE;
    else if (newsize >= YYMAXDEPTH)
        return YYENOMEM;
    else if ((newsize *= 2) > YYMAXDEPTH)
        newsize = YYMAXDEPTH;

    i = (int) (data->s_mark - data->s_base);
    newss = (YYINT *)realloc(data->s_base, newsize * sizeof(*newss));
    if (newss == 0)
        return YYENOMEM;

    data->s_base = newss;
    data->s_mark = newss + i;

    newvs = (YYSTYPE *)realloc(data->l_base, newsize * sizeof(*newvs));
    if (newvs == 0)
        return YYENOMEM;

    data->l_base = newvs;
    data->l_mark = newvs + i;

    data->stacksize = newsize;
    data->s_last = data->s_base + newsize - 1;
    return 0;
}

#if YYPURE || defined(YY_NO_LEAKS)
static void yyfreestack(YYSTACKDATA *data)
{
    free(data->s_base);
    free(data->l_base);
    memset(data, 0, sizeof(*data));
}
#else
#define yyfreestack(data) /* nothing */
#endif

#define YYABORT  goto yyabort
#define YYREJECT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR  goto yyerrlab

int
YYPARSE_DECL()
{
    int yym, yyn, yystate;
#if YYDEBUG
    const char *yys;

    if ((yys = getenv("YYDEBUG")) != 0)
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yynerrs = 0;
    yyerrflag = 0;
    yychar = YYEMPTY;
    yystate = 0;

#if YYPURE
    memset(&yystack, 0, sizeof(yystack));
#endif

    if (yystack.s_base == NULL && yygrowstack(&yystack) == YYENOMEM) goto yyoverflow;
    yystack.s_mark = yystack.s_base;
    yystack.l_mark = yystack.l_base;
    yystate = 0;
    *yystack.s_mark = 0;

yyloop:
    if ((yyn = yydefred[yystate]) != 0) goto yyreduce;
    if (yychar < 0)
    {
        if ((yychar = YYLEX) < 0) yychar = YYEOF;
#if YYDEBUG
        if (yydebug)
        {
            yys = yyname[YYTRANSLATE(yychar)];
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
#endif
        if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
        {
            goto yyoverflow;
        }
        yystate = yytable[yyn];
        *++yystack.s_mark = yytable[yyn];
        *++yystack.l_mark = yylval;
        yychar = YYEMPTY;
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if ((yyn = yyrindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag) goto yyinrecovery;

    YYERROR_CALL("syntax error");

    goto yyerrlab;

yyerrlab:
    ++yynerrs;

yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if ((yyn = yysindex[*yystack.s_mark]) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yystack.s_mark, yytable[yyn]);
#endif
                if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
                {
                    goto yyoverflow;
                }
                yystate = yytable[yyn];
                *++yystack.s_mark = yytable[yyn];
                *++yystack.l_mark = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yystack.s_mark);
#endif
                if (yystack.s_mark <= yystack.s_base) goto yyabort;
                --yystack.s_mark;
                --yystack.l_mark;
            }
        }
    }
    else
    {
        if (yychar == YYEOF) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            yys = yyname[YYTRANSLATE(yychar)];
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = YYEMPTY;
        goto yyloop;
    }

yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    if (yym)
        yyval = yystack.l_mark[1-yym];
    else
        memset(&yyval, 0, sizeof yyval);
    switch (yyn)
    {
case 1:
#line 83 "new-standard-pascal.y"
	{
		/*AST = new_node_t(PROGRAM, "PROGRAM");*/
		AST = new_node_t(PROGRAM, yystack.l_mark[-9].text);
		AST = new_family_4(AST, new_l_child(new_node_t(IDENTIFIER, yystack.l_mark[-8].text), yystack.l_mark[-6].nval), yystack.l_mark[-3].nval, yystack.l_mark[-2].nval, yystack.l_mark[-1].nval);
	}
break;
case 2:
#line 89 "new-standard-pascal.y"
	{
		yyval.nval = new_node(ERROR);
	}
break;
case 3:
#line 95 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(IDENTIFIER, yystack.l_mark[0].text);
	}
break;
case 4:
#line 99 "new-standard-pascal.y"
	{
		yyval.nval = new_r_sibling(yystack.l_mark[-2].nval, new_node_t(IDENTIFIER, yystack.l_mark[0].text));
	}
break;
case 5:
#line 103 "new-standard-pascal.y"
	{
		yyval.nval = new_node(ERROR);
	}
break;
case 6:
#line 110 "new-standard-pascal.y"
	{
		/*TEMP = new_family_2(new_node_t(VAR, "VAR"), $5, $3);*/
		TEMP = new_family_2(new_node_t(VAR, yystack.l_mark[-4].text), yystack.l_mark[-1].nval, yystack.l_mark[-3].nval);
		if(yystack.l_mark[-5].nval->node_type != EMPTY)
			yyval.nval = new_r_sibling(yystack.l_mark[-5].nval, TEMP);
		else{
			yyval.nval = TEMP;
			free(yystack.l_mark[-5].nval);
		}
	}
break;
case 7:
#line 121 "new-standard-pascal.y"
	{
		yyval.nval = new_node(EMPTY);
	}
break;
case 8:
#line 125 "new-standard-pascal.y"
	{
		yyval.nval = new_node(ERROR);
	}
break;
case 9:
#line 132 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 10:
#line 136 "new-standard-pascal.y"
	{
		if(yystack.l_mark[0].nval->node_type == ARRAY){
			/*$$ = new_family_3(new_node_t(ARRAY, "ARRAY"), $3, $5, $8->l_child);*/
			yyval.nval = new_family_3(new_node_t(ARRAY, yystack.l_mark[-7].text), yystack.l_mark[-5].nval, yystack.l_mark[-3].nval, yystack.l_mark[0].nval->l_child);
			yyval.nval->node_ivalue = yystack.l_mark[0].nval->node_ivalue + 1;
			rm_nodeType(yystack.l_mark[0].nval);
		}
		else{
			/*$$ = new_family_3(new_node_t(ARRAY, "ARRAY"), $3, $5, $8);*/
			yyval.nval = new_family_3(new_node_t(ARRAY, yystack.l_mark[-7].text), yystack.l_mark[-5].nval, yystack.l_mark[-3].nval, yystack.l_mark[0].nval);
			yyval.nval->node_ivalue = 1;
		}
	}
break;
case 11:
#line 150 "new-standard-pascal.y"
	{
		yyval.nval = new_node(ERROR);
	}
break;
case 12:
#line 157 "new-standard-pascal.y"
	{
		/*$$ = new_node_t(INTEGER, "INTEGER");*/
		yyval.nval = new_node_t(INTEGER, yystack.l_mark[0].text);
	}
break;
case 13:
#line 162 "new-standard-pascal.y"
	{
		/*$$ = new_node_t(REAL, "REAL");*/
		yyval.nval = new_node_t(REAL, yystack.l_mark[0].text);
	}
break;
case 14:
#line 167 "new-standard-pascal.y"
	{
		/*$$ = new_node_t(STRING, "STRING");*/
		yyval.nval = new_node_t(STRING, yystack.l_mark[0].text);
	}
break;
case 15:
#line 175 "new-standard-pascal.y"
	{
		if(yystack.l_mark[-2].nval->node_type != EMPTY)
			yyval.nval = new_r_sibling(yystack.l_mark[-2].nval, yystack.l_mark[-1].nval);
		else{
			yyval.nval = yystack.l_mark[-1].nval;
			free(yystack.l_mark[-2].nval);
		}
	}
break;
case 16:
#line 184 "new-standard-pascal.y"
	{
		yyval.nval = new_node(EMPTY);
	}
break;
case 17:
#line 191 "new-standard-pascal.y"
	{
		new_r_sibling(yystack.l_mark[-2].nval->l_child, yystack.l_mark[-1].nval);
		new_r_sibling(yystack.l_mark[-1].nval, yystack.l_mark[0].nval);
		yyval.nval = yystack.l_mark[-2].nval;
	}
break;
case 18:
#line 199 "new-standard-pascal.y"
	{
		/*TEMP = new_node_t(FUNCTION, "FUNCTION");*/
		TEMP = new_node_t(FUNCTION, yystack.l_mark[-5].text);
		yyval.nval = new_family_2(TEMP, yystack.l_mark[-1].nval, new_l_child(new_node_t(IDENTIFIER, yystack.l_mark[-4].text), yystack.l_mark[-3].nval));
	}
break;
case 19:
#line 205 "new-standard-pascal.y"
	{
		/*TEMP = new_node_t(PROCEDURE, "PROCEDURE");*/
		TEMP = new_node_t(PROCEDURE, yystack.l_mark[-3].text);
		yyval.nval = new_family_2(TEMP, new_node(EMPTY), new_l_child(new_node_t(IDENTIFIER, yystack.l_mark[-2].text), yystack.l_mark[-1].nval));
	}
break;
case 20:
#line 214 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[-1].nval;
	}
break;
case 21:
#line 218 "new-standard-pascal.y"
	{
		yyval.nval = new_node(EMPTY);
	}
break;
case 22:
#line 225 "new-standard-pascal.y"
	{
		yyval.nval = new_l_child(yystack.l_mark[0].nval, yystack.l_mark[-2].nval);
	}
break;
case 23:
#line 229 "new-standard-pascal.y"
	{
		yyval.nval = new_r_sibling(yystack.l_mark[-4].nval, yystack.l_mark[0].nval);
		new_l_child(yystack.l_mark[0].nval, yystack.l_mark[-2].nval);
	}
break;
case 24:
#line 237 "new-standard-pascal.y"
	{
		/*$$ = new_r_sibling(new_node_t(PBEGIN, "BEGIN"), $2);*/
		yyval.nval = new_r_sibling(new_node_t(PBEGIN, yystack.l_mark[-2].text), yystack.l_mark[-1].nval);
		/*new_r_sibling($2, new_node_t(END, "END"));*/
		new_r_sibling(yystack.l_mark[-1].nval, new_node_t(END, yystack.l_mark[0].text));
	}
break;
case 25:
#line 244 "new-standard-pascal.y"
	{
		yyval.nval = new_node(EMPTY);
	}
break;
case 26:
#line 251 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 27:
#line 258 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 28:
#line 262 "new-standard-pascal.y"
	{
		yyval.nval = new_r_sibling(yystack.l_mark[-2].nval, yystack.l_mark[0].nval);
	}
break;
case 29:
#line 269 "new-standard-pascal.y"
	{
		yyval.nval = new_family_2(new_node_t(ASSIGNMENT, yystack.l_mark[-1].text), yystack.l_mark[-2].nval, yystack.l_mark[0].nval);
	}
break;
case 30:
#line 273 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 31:
#line 277 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 32:
#line 281 "new-standard-pascal.y"
	{
		/*$$ = new_family_3(new_node_t(IF, "IF"), $2, $4, $6);    //    NOT YET*/
		yyval.nval = new_family_3(new_node_t(IF, yystack.l_mark[-5].text), yystack.l_mark[-4].nval, new_l_child(new_node_t(THEN, yystack.l_mark[-3].text), yystack.l_mark[-2].nval), new_l_child(new_node_t(ELSE, yystack.l_mark[-1].text), yystack.l_mark[0].nval));
	}
break;
case 33:
#line 286 "new-standard-pascal.y"
	{
		/*$$ = new_family_2(new_node_t(WHILE, "WHILE"), $2, $4);    //    NOT YET*/
		yyval.nval = new_family_2(new_node_t(WHILE, yystack.l_mark[-3].text), yystack.l_mark[-2].nval, new_l_child(new_node_t(DO, yystack.l_mark[-1].text), yystack.l_mark[0].nval));
	}
break;
case 34:
#line 294 "new-standard-pascal.y"
	{
		if(yystack.l_mark[0].nval->node_type != EMPTY)
			yyval.nval = new_r_sibling(new_node_t(IDENTIFIER, yystack.l_mark[-1].text), yystack.l_mark[0].nval);
		else{
			yyval.nval = new_node_t(IDENTIFIER, yystack.l_mark[-1].text);
			free(yystack.l_mark[0].nval);
		}
	}
break;
case 35:
#line 306 "new-standard-pascal.y"
	{
		if(yystack.l_mark[0].nval->node_type != EMPTY){
			TEMP = new_node_t(LBRAC, yystack.l_mark[-3].text);
			yyval.nval = new_l_child(TEMP, yystack.l_mark[-2].nval);
			new_r_sibling(TEMP, yystack.l_mark[0].nval);
		}
		else{
			TEMP = new_node_t(LBRAC, yystack.l_mark[-3].text);
			yyval.nval = new_l_child(TEMP, yystack.l_mark[-2].nval);
			free(yystack.l_mark[0].nval);
		}
	}
break;
case 36:
#line 319 "new-standard-pascal.y"
	{
		yyval.nval = new_node(EMPTY);
	}
break;
case 37:
#line 326 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(IDENTIFIER, yystack.l_mark[0].text);
	}
break;
case 38:
#line 330 "new-standard-pascal.y"
	{
		yyval.nval = new_l_child(new_node_t(IDENTIFIER, yystack.l_mark[-3].text), yystack.l_mark[-1].nval);
	}
break;
case 39:
#line 334 "new-standard-pascal.y"
	{
		yyval.nval = new_node(ERROR);
	}
break;
case 40:
#line 341 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 41:
#line 345 "new-standard-pascal.y"
	{
		yyval.nval = new_r_sibling(yystack.l_mark[-2].nval, yystack.l_mark[0].nval);
	}
break;
case 42:
#line 349 "new-standard-pascal.y"
	{
		yyval.nval = new_node(EMPTY);
	}
break;
case 43:
#line 356 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 44:
#line 360 "new-standard-pascal.y"
	{
		yyval.nval = new_family_2(yystack.l_mark[-1].nval, yystack.l_mark[-2].nval, yystack.l_mark[0].nval);
	}
break;
case 45:
#line 367 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 46:
#line 371 "new-standard-pascal.y"
	{
		yyval.nval = new_family_2(yystack.l_mark[-1].nval, yystack.l_mark[-2].nval, yystack.l_mark[0].nval);

	}
break;
case 47:
#line 379 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 48:
#line 383 "new-standard-pascal.y"
	{
		yyval.nval = new_family_2(yystack.l_mark[-1].nval, yystack.l_mark[-2].nval, yystack.l_mark[0].nval);
	}
break;
case 49:
#line 390 "new-standard-pascal.y"
	{
		if(yystack.l_mark[0].nval->node_type != EMPTY)
			yyval.nval = new_r_sibling(new_node_t(IDENTIFIER, yystack.l_mark[-1].text), yystack.l_mark[0].nval);
		else{
			yyval.nval = new_node_t(IDENTIFIER, yystack.l_mark[-1].text);
			free(yystack.l_mark[0].nval);
		}
	}
break;
case 50:
#line 399 "new-standard-pascal.y"
	{
		yyval.nval = new_l_child(new_node_t(IDENTIFIER, yystack.l_mark[-3].text), yystack.l_mark[-1].nval);
	}
break;
case 51:
#line 403 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[0].nval;
	}
break;
case 52:
#line 407 "new-standard-pascal.y"
	{
		yyval.nval = yystack.l_mark[-1].nval;
	}
break;
case 53:
#line 411 "new-standard-pascal.y"
	{
		yyval.nval = new_l_child(new_node_t(NOT, yystack.l_mark[-1].text), yystack.l_mark[0].nval);
	}
break;
case 54:
#line 415 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(CHARACTER_STRING, yystack.l_mark[0].text);
	}
break;
case 55:
#line 422 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(PLUS, yystack.l_mark[0].text);
	}
break;
case 56:
#line 426 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(MINUS, yystack.l_mark[0].text);
	}
break;
case 57:
#line 433 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(STAR, yystack.l_mark[0].text);
	}
break;
case 58:
#line 437 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(SLASH, yystack.l_mark[0].text);
	}
break;
case 59:
#line 444 "new-standard-pascal.y"
	{
		yyval.nval = new_node_i(DIGSEQ, yystack.l_mark[0].ival);
	}
break;
case 60:
#line 448 "new-standard-pascal.y"
	{
		yyval.nval = new_node_f(REALNUMBER, yystack.l_mark[0].fval);
	}
break;
case 61:
#line 452 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(EXPOPRST, yystack.l_mark[0].text);
	}
break;
case 62:
#line 456 "new-standard-pascal.y"
	{
		/*TEMP = new_node_t(MINUS, $1);*/
		/*$$ = new_r_sibling(TEMP, new_node_i(DIGSEQ, $2)); */
		yystack.l_mark[0].ival = 0-yystack.l_mark[0].ival;
		yyval.nval = new_node_i(REALNUMBER, yystack.l_mark[0].ival);
	}
break;
case 63:
#line 463 "new-standard-pascal.y"
	{
		/*TEMP = new_node_t(MINUS, $1);*/
		/*$$ = new_r_sibling(TEMP, new_node_f(REALNUMBER, $2));*/
		yystack.l_mark[0].fval = 0-yystack.l_mark[0].fval;
		yyval.nval = new_node_f(REALNUMBER, yystack.l_mark[0].fval);
	}
break;
case 64:
#line 470 "new-standard-pascal.y"
	{
		TEMP = new_node_t(MINUS, yystack.l_mark[-1].text);
		yyval.nval = new_r_sibling(TEMP, new_node_t(EXPOPRST, yystack.l_mark[0].text));
	}
break;
case 65:
#line 478 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(LT, yystack.l_mark[0].text);
	}
break;
case 66:
#line 482 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(GT, yystack.l_mark[0].text);
	}
break;
case 67:
#line 486 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(EQUAL, yystack.l_mark[0].text);
	}
break;
case 68:
#line 490 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(LE, yystack.l_mark[0].text);
	}
break;
case 69:
#line 494 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(GE, yystack.l_mark[0].text);
	}
break;
case 70:
#line 498 "new-standard-pascal.y"
	{
		yyval.nval = new_node_t(NOTEQUAL, yystack.l_mark[0].text);
	}
break;
#line 2675 "y.tab.c"
    }
    yystack.s_mark -= yym;
    yystate = *yystack.s_mark;
    yystack.l_mark -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
#endif
        yystate = YYFINAL;
        *++yystack.s_mark = YYFINAL;
        *++yystack.l_mark = yyval;
        if (yychar < 0)
        {
            if ((yychar = YYLEX) < 0) yychar = YYEOF;
#if YYDEBUG
            if (yydebug)
            {
                yys = yyname[YYTRANSLATE(yychar)];
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == YYEOF) goto yyaccept;
        goto yyloop;
    }
    if ((yyn = yygindex[yym]) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yystack.s_mark, yystate);
#endif
    if (yystack.s_mark >= yystack.s_last && yygrowstack(&yystack) == YYENOMEM)
    {
        goto yyoverflow;
    }
    *++yystack.s_mark = (YYINT) yystate;
    *++yystack.l_mark = yyval;
    goto yyloop;

yyoverflow:
    YYERROR_CALL("yacc stack overflow");

yyabort:
    yyfreestack(&yystack);
    return (1);

yyaccept:
    yyfreestack(&yystack);
    return (0);
}
