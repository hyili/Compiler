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
void symdestroy(int scope);  //  destroy symble table
sym_node symcheck(nodeType current, int scope, nodeType retval);  //  check the type with no assignment
sym_node RHSsymcheck(nodeType current, int scope, nodeType retval);  //  check the type in RHS
sym_node LHSsymcheck(nodeType current, int scope, nodeType retval);  //  check the type in LHS
int Ievaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval);  //  test and evaluate the expression whether it is integer or not
float Revaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval);  //  test and evaluate the expression whether it is real number or not
sym_node RHSsymlook(nodeType current, int scope, nodeType retval, int* isvalue, sym_node Ltype);  // run through the RHS, and seperate it to digit number, real number, string, variable, and expression. then, call RHSsymcheck and LHSsymcheck to do the type checking.
void symlook(nodeType current, int scope, nodeType retval);  //  run through the whole AST, and find out the VAR, FUNCTION, PROCEDURE, and PROGRAM declaration. others are ASSIGNMENT, IF, WHILE, PBEGIN, and END tokens.

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

%}

%union
{
        int ival;
	float fval;
        char* text;
	nodeType nval;
}

%token <text> ARRAY ASSIGNMENT COLON COMMA DO DOT DOTDOT ELSE END EQUAL ERROR FUNCTION GE GOTO GT IF IN LBRAC LE LPAREN LT MINUS NOT NOTEQUAL OF PBEGIN PLUS PROCEDURE PROGRAM RBRAC RPAREN SEMICOLON SLASH STAR STARSTAR STRING THEN UPARROW VAR WHILE NIDENTIFIER INTEGER REAL INVALIDSYM CHARACTER_STRING IDENTIFIER EXPOPRST
%token <ival> DIGSEQ 
%token <fval> REALNUMBER
%token EMPTY

%type <nval> program identifier_list declarations type standard_type subprogram_declarations subprogram_declaration subprogram_head arguments parameter_list compound_statement optional_statements statement_list statement variable tail procedure_statement expression_list expression simple_expression term factor addop mulop num relop
%%

program : PROGRAM IDENTIFIER LPAREN identifier_list RPAREN SEMICOLON declarations subprogram_declarations compound_statement DOT
	{
		//AST = new_node_t(PROGRAM, "PROGRAM");
		AST = new_node_t(PROGRAM, $1);
		AST = new_family_4(AST, new_l_child(new_node_t(IDENTIFIER, $2), $4), $7, $8, $9);
	}
	| error		/* the default action assigns an undefined value to $$ */
	{
		$$ = new_node(ERROR);
	}
	;

identifier_list : IDENTIFIER
	{
		$$ = new_node_t(IDENTIFIER, $1);
	}
	| identifier_list COMMA IDENTIFIER
	{
		$$ = new_r_sibling($1, new_node_t(IDENTIFIER, $3));
	}
	| error		/* the default action assigns an undefined value to $$ */
	{
		$$ = new_node(ERROR);
	}
	;


declarations : declarations VAR identifier_list COLON type SEMICOLON	/* the default action assigns an undefined value to $$ */
	{
		//TEMP = new_family_2(new_node_t(VAR, "VAR"), $5, $3);
		TEMP = new_family_2(new_node_t(VAR, $2), $5, $3);
		if($1->node_type != EMPTY)
			$$ = new_r_sibling($1, TEMP);
		else{
			$$ = TEMP;
			free($1);
		}
	}
	|
	{
		$$ = new_node(EMPTY);
	}
	| error		/* the default action assigns an undefined value to $$ */
	{
		$$ = new_node(ERROR);
	}
	;


type : standard_type
	{
		$$ = $1;
	}
	| ARRAY LBRAC num DOTDOT num RBRAC OF type
	{
		if($8->node_type == ARRAY){
			//$$ = new_family_3(new_node_t(ARRAY, "ARRAY"), $3, $5, $8->l_child);
			$$ = new_family_3(new_node_t(ARRAY, $1), $3, $5, $8->l_child);
			$$->node_ivalue = $8->node_ivalue + 1;
			rm_nodeType($8);
		}
		else{
			//$$ = new_family_3(new_node_t(ARRAY, "ARRAY"), $3, $5, $8);
			$$ = new_family_3(new_node_t(ARRAY, $1), $3, $5, $8);
			$$->node_ivalue = 1;
		}
	}
	| error		/* the default action assigns an undefined value to $$ */
	{
		$$ = new_node(ERROR);
	}
	;


standard_type : INTEGER
	{
		//$$ = new_node_t(INTEGER, "INTEGER");
		$$ = new_node_t(INTEGER, $1);
	}
	| REAL
	{
		//$$ = new_node_t(REAL, "REAL");
		$$ = new_node_t(REAL, $1);
	}
        | STRING
	{
		//$$ = new_node_t(STRING, "STRING");
		$$ = new_node_t(STRING, $1);
	}
	;


subprogram_declarations : subprogram_declarations subprogram_declaration SEMICOLON
	{
		if($1->node_type != EMPTY)
			$$ = new_r_sibling($1, $2);
		else{
			$$ = $2;
			free($1);
		}
	}
	|
	{
		$$ = new_node(EMPTY);
	}
	;


subprogram_declaration :subprogram_head declarations compound_statement
	{
		new_r_sibling($1->l_child, $2);
		new_r_sibling($2, $3);
		$$ = $1;
	}
	;

subprogram_head : FUNCTION IDENTIFIER arguments COLON standard_type SEMICOLON
	{
		//TEMP = new_node_t(FUNCTION, "FUNCTION");
		TEMP = new_node_t(FUNCTION, $1);
		$$ = new_family_2(TEMP, $5, new_l_child(new_node_t(IDENTIFIER, $2), $3));
	}
	| PROCEDURE IDENTIFIER arguments SEMICOLON
	{
		//TEMP = new_node_t(PROCEDURE, "PROCEDURE");
		TEMP = new_node_t(PROCEDURE, $1);
		$$ = new_family_2(TEMP, new_node(EMPTY), new_l_child(new_node_t(IDENTIFIER, $2), $3));
	}
	;


arguments : LPAREN parameter_list RPAREN
	{
		$$ = $2;
	}
	|
	{
		$$ = new_node(EMPTY);
	}
	;


parameter_list : identifier_list COLON type
	{
		$$ = new_l_child($3, $1);
	}
	| parameter_list SEMICOLON identifier_list COLON type
	{
		$$ = new_r_sibling($1, $5);
		new_l_child($5, $3);
	}
	;


compound_statement : PBEGIN optional_statements END
	{
		//$$ = new_r_sibling(new_node_t(PBEGIN, "BEGIN"), $2);
		$$ = new_r_sibling(new_node_t(PBEGIN, $1), $2);
		//new_r_sibling($2, new_node_t(END, "END"));
		new_r_sibling($2, new_node_t(END, $3));
	}
	|
	{
		$$ = new_node(EMPTY);
	}
	;


optional_statements : statement_list
	{
		$$ = $1;
	}
	;


statement_list : statement
	{
		$$ = $1;
	}
	| statement_list SEMICOLON statement
	{
		$$ = new_r_sibling($1, $3);
	}
	;


statement : variable ASSIGNMENT expression
	{
		$$ = new_family_2(new_node_t(ASSIGNMENT, $2), $1, $3);
	}
	| procedure_statement
	{
		$$ = $1;
	}
	| compound_statement
	{
		$$ = $1;
	}
	| IF expression THEN statement ELSE statement
	{
		//$$ = new_family_3(new_node_t(IF, "IF"), $2, $4, $6);    //    NOT YET
		$$ = new_family_3(new_node_t(IF, $1), $2, new_l_child(new_node_t(THEN, $3), $4), new_l_child(new_node_t(ELSE, $5), $6));
	}
	| WHILE expression DO statement
	{
		//$$ = new_family_2(new_node_t(WHILE, "WHILE"), $2, $4);    //    NOT YET
		$$ = new_family_2(new_node_t(WHILE, $1), $2, new_l_child(new_node_t(DO, $3), $4));
	}
	;


variable : IDENTIFIER tail
	{
		if($2->node_type != EMPTY)
			$$ = new_r_sibling(new_node_t(IDENTIFIER, $1), $2);
		else{
			$$ = new_node_t(IDENTIFIER, $1);
			free($2);
		}
	}
	;


tail     : LBRAC expression RBRAC tail
	{
		if($4->node_type != EMPTY){
			TEMP = new_node_t(LBRAC, $1);
			$$ = new_l_child(TEMP, $2);
			new_r_sibling(TEMP, $4);
		}
		else{
			TEMP = new_node_t(LBRAC, $1);
			$$ = new_l_child(TEMP, $2);
			free($4);
		}
	}
	|
	{
		$$ = new_node(EMPTY);
	}
	;


procedure_statement : IDENTIFIER
	{
		$$ = new_node_t(IDENTIFIER, $1);
	}
	| IDENTIFIER LPAREN expression_list RPAREN
	{
		$$ = new_l_child(new_node_t(IDENTIFIER, $1), $3);
	}
	| error		/* the default action assigns an undefined value to $$ */
	{
		$$ = new_node(ERROR);
	}
	;


expression_list : expression
	{
		$$ = $1;
	}
	| expression_list COMMA expression
	{
		$$ = new_r_sibling($1, $3);
	}
	|
	{
		$$ = new_node(EMPTY);
	}
	;


expression : simple_expression
	{
		$$ = $1;
	}
	| simple_expression relop simple_expression
	{
		$$ = new_family_2($2, $1, $3);
	}
	;


simple_expression : term
	{
		$$ = $1;
	}
	| simple_expression addop term
	{
		$$ = new_family_2($2, $1, $3);

	}
	;


term : factor
	{
		$$ = $1;
	}
	| term mulop factor
	{
		$$ = new_family_2($2, $1, $3);
	}
	;


factor : IDENTIFIER tail
	{
		if($2->node_type != EMPTY)
			$$ = new_r_sibling(new_node_t(IDENTIFIER, $1), $2);
		else{
			$$ = new_node_t(IDENTIFIER, $1);
			free($2);
		}
	}
	| IDENTIFIER LPAREN expression_list RPAREN
	{
		$$ = new_l_child(new_node_t(IDENTIFIER, $1), $3);
	}
	| num
	{
		$$ = $1;
	}
	| LPAREN expression RPAREN
	{
		$$ = $2;
	}
	| NOT factor
	{
		$$ = new_l_child(new_node_t(NOT, $1), $2);
	}
	| CHARACTER_STRING
	{
		$$ = new_node_t(CHARACTER_STRING, $1);
	}
	;


addop : PLUS
	{
		$$ = new_node_t(PLUS, $1);
	}
	| MINUS
	{
		$$ = new_node_t(MINUS, $1);
	}
	;


mulop : STAR
	{
		$$ = new_node_t(STAR, $1);
	}
	| SLASH
	{
		$$ = new_node_t(SLASH, $1);
	}
	;


num : DIGSEQ
	{
		$$ = new_node_i(DIGSEQ, $1);
	}
	| REALNUMBER
	{
		$$ = new_node_f(REALNUMBER, $1);
	}
	| EXPOPRST
	{
		$$ = new_node_t(EXPOPRST, $1);
	}
	| MINUS DIGSEQ
	{
		//TEMP = new_node_t(MINUS, $1);
		//$$ = new_r_sibling(TEMP, new_node_i(DIGSEQ, $2)); 
		$2 = 0-$2;
		$$ = new_node_i(DIGSEQ, $2);
	}
	| MINUS REALNUMBER
	{
		//TEMP = new_node_t(MINUS, $1);
		//$$ = new_r_sibling(TEMP, new_node_f(REALNUMBER, $2));
		$2 = 0-$2;
		$$ = new_node_f(REALNUMBER, $2);
	}
	| MINUS EXPOPRST
	{
		TEMP = new_node_t(MINUS, $1);
		$$ = new_r_sibling(TEMP, new_node_t(EXPOPRST, $2));
	}
	;


relop : LT
	{
		$$ = new_node_t(LT, $1);
	}
	| GT
	{
		$$ = new_node_t(GT, $1);
	}
	| EQUAL
	{
		$$ = new_node_t(EQUAL, $1);
	}
	| LE
	{
		$$ = new_node_t(LE, $1);
	}
	| GE
	{
		$$ = new_node_t(GE, $1);
	}
	| NOTEQUAL
	{
		$$ = new_node_t(NOTEQUAL, $1);
	}
	;


%%



void file_init()
{
    fwrite(".class public a\n", sizeof(char), 16, ofile);
    fwrite(".super java/lang/Object\n\n", sizeof(char), 25, ofile);

	return;
}

void def_init()
{
	//  print integer
	fwrite(".method public static printInt(I)V\n", sizeof(char), 35, ofile);
    fwrite("	.limit stack 100\n", sizeof(char), 18, ofile);
    fwrite("	.limit locals 100\n", sizeof(char), 19, ofile);
	fwrite("		iload 0\n", sizeof(char), 10, ofile);
	fwrite("		getstatic java/lang/System/out Ljava/io/PrintStream;\n", sizeof(char), 55, ofile);
	fwrite("		swap\n", sizeof(char), 7, ofile);
	fwrite("		invokevirtual java/io/PrintStream/print(I)V\n", sizeof(char), 46, ofile);
	fwrite("		return\n", sizeof(char), 9, ofile);
	fwrite(".end method\n\n", sizeof(char), 13, ofile);
	//  print float
	fwrite(".method public static printReal(F)V\n", sizeof(char), 36, ofile);
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
	int i;
	sym_node ptr = scope_display[1];
	//  main
    fwrite(".method public static main([Ljava/lang/String;)V\n", sizeof(char), 49, ofile);
    fwrite("	.limit stack 100\n", sizeof(char), 18, ofile);
    fwrite("	.limit locals 100\n\n", sizeof(char), 20, ofile);

	while(ptr != NULL){
		if(ptr->array != 0){
			for(i = 0; i < ptr->array*2; i+=2){
				sprintf(jasmin, "		ldc %d\n", ptr->bound[i+1]+1);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			sprintf(jasmin, "		multianewarray ");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			for(i = 0; i < ptr->array*2; i+=2){
				sprintf(jasmin, "[");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			sprintf(jasmin, "%s %d\n", ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "I" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "F" : "Ljava/lang/String;", ptr->array);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			sprintf(jasmin, "		putstatic a/%s ", ptr->name);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			for(i = 0; i < ptr->array*2; i+=2){
				sprintf(jasmin, "[");
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			}
			sprintf(jasmin, "%s\n", ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "I" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "F" : "Ljava/lang/String;", ptr->array);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		ptr = ptr->scope;
	}
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
					fprintf(stdout, "[Checking Error] Program symbal %s can't be used here\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else if(strcmp(ptr->cate, "VAR") == 0){
					fprintf(stdout, "[Checking Error] Var symbal %s can't be used here\n", ptr->name);
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
									fprintf(stdout, "[Checking Error] Wrong number of parameter in function %s\n", ptr->name);
									err++;
									res = 1;
								}
								else{
									fprintf(stdout, "[Checking Error] Wrong number of parameter in procedure %s\n", ptr->name);
									err++;
									res = 1;
								}
								return NULL;
							}
							if((Ttype = RHSsymlook(current, scope, retval, &isvalue, (ptr->ptype[para] == 'I') ? I : (ptr->ptype[para] == 'F') ? R : S)) == NULL){  //  type comparison
								if(strcmp(ptr->cate, "FUNCTION") == 0){
									fprintf(stdout, "[Checking Error] Wrong syntax of parameter when calling function %s\n", ptr->name);
									err++;
									res = 1;
								}
								else{
									fprintf(stdout, "[Checking Error] Wrong syntax of parameter when calling procedure %s\n", ptr->name);
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
											fprintf(stdout, "[Checking Error] Wrong type of parameter when calling function %s %s %s\n", ptr->name);
											err++;
											res = 1;
										}
										else{
											fprintf(stdout, "[Checking Error] Wrong type of parameter when calling procedure %s\n", ptr->name);
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
								fprintf(stdout, "[Checking Error] Wrong number of parameter in function %s\n", ptr->name);
								err++;
								res = 1;
							}
							else{
								fprintf(stdout, "[Checking Error] Wrong number of parameter in procedure %s\n", ptr->name);
								err++;
								res = 1;
							}
							return NULL;
						}
						else{
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
	
	fprintf(stdout, "[Checking Error] Undeclared symbal %s\n", current->node_text);
	err++;
	res = 1;
	return NULL;
}

sym_node RHSsymcheck(nodeType current, int scope, nodeType retval)
{
	sym_node ptr, Ttype;
	int current_scope = scope, array, para, i = 0, isvalue;//, index;
	
	do{
		ptr = scope_display[current_scope];
		while(ptr != NULL){
			if(strcmp(ptr->name, current->node_text) == 0){
				if(strcmp(ptr->cate, "PROCEDURE") == 0){
					fprintf(stdout, "[Checking Error] Procedure symbal %s can't be RHS\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else if(strcmp(ptr->cate, "PROGRAM") == 0){
					fprintf(stdout, "[Checking Error] Program symbal %s can't be RHS\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else{
					if((ptr->init == 0) && (retval == NULL)){
						fprintf(stdout, "[Checking Error] Use %s after initialization\n", ptr->name);
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
								fprintf(stdout, "[Checking Error] Wrong number of parameter in function %s\n", ptr->name);
								err++;
								res = 1;
								return NULL;
							}
							if((Ttype = RHSsymlook(current, scope, retval, &isvalue, (ptr->ptype[para] == 'I') ? I : (ptr->ptype[para] == 'F') ? R : S)) == NULL){
								fprintf(stdout, "[Checking Error] Wrong parameter in function %s\n", ptr->name);
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
											fprintf(stdout, "[Checking Error] Wrong type of parameter when calling function %s\n", ptr->name);
											err++;
											res = 1;
										}
										else{
											fprintf(stdout, "[Checking Error] Wrong type of parameter when calling procedure %s\n", ptr->name);
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
							fprintf(stdout, "[Checking Error] Wrong number of parameter in function %s\n", ptr->name);
							err++;
							res = 1;
							return NULL;
						}
						else{
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
						if(ptr->j_var == -1){
							sprintf(jasmin, "		getstatic a/%s ", ptr->name);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							for(i = 0; i < array; i++){
								sprintf(jasmin, "[");
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
							sprintf(jasmin, "%s\n", ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "I" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "F" : "Ljava/lang/String;", ptr->j_var);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
						else{
							if(array == 0){
								sprintf(jasmin, "		%sload %d\n", ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "i" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "f" : "a", ptr->j_var);
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
							else{
								sprintf(jasmin, "		aload %d\n", ptr->j_var);
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
						}
						i = 0;
						while(current != NULL){
							if(current->node_type == LBRAC){
								if((array--) == 0){
									fprintf(stdout, "[Checking Error] Wrong number of dimension symbal %s in RHS\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
								if((Ttype = RHSsymlook(current->l_child, scope, retval, &isvalue, I)) == NULL){
									fprintf(stdout, "[Checking Error] Wrong expression in array %s of RHS\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
								if((Ttype->type[0] != 'i') && (Ttype->type[0] != 'I')){
									fprintf(stdout, "[Checking Error] Wrong parameter type in array %s of RHS\n", ptr->name);
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
										fprintf(stdout, "[Checking Error] Out of bound %s of RHS\n", ptr->name);
										err++;
										res = 1;
										return NULL;
									}
									if(Ttype->ivalue > ptr->bound[i++]){
										fprintf(stdout, "[Checking Error] Out of bound %s of RHS\n", ptr->name);
										err++;
										res = 1;
										return NULL;
									}
									if(array > 0){
										sprintf(jasmin, "		aaload\n");
										fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
									}
								}
								current = current->r_sibling;
							}
							else{
								break;
							}
						}
						if(array != 0){
							fprintf(stdout, "[Checking Error] Wrong number of dimension symbal %s in RHS\n", ptr->name);
							err++;
							res = 1;
							return NULL;
						}
						else{
							if(ptr->array > 0){
								sprintf(jasmin, "		%saload\n", ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "i" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "f" : "a", ptr->j_var);
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
							return ptr;
						}
					}
				}
			}
			ptr = ptr->scope;
		}
	}while(current_scope--);
	
	fprintf(stdout, "[Checking Error] Undeclared symbal %s\n", current->node_text);
	err++;
	res = 1;
	return NULL;
}

sym_node LHSsymcheck(nodeType current, int scope, nodeType retval)
{
	sym_node ptr, Ttype;
	int current_scope = scope, array, i = 0, isvalue;//, index;

	do{
		ptr = scope_display[current_scope];
		while(ptr != NULL){
			if(strcmp(ptr->name, current->node_text) == 0){
				if(strcmp(ptr->cate, "FUNCTION") == 0){
					if(strcmp(current->node_text, retval->node_text) == 0){
						fprintf(stdout, "** Find return symbal %s in LHS **\n", ptr->name);
						return ptr;
					}
					else{
						fprintf(stdout, "[Checking Error] Function symbal %s can't be LHS\n", ptr->name);
						err++;
						res = 1;
						return NULL;
					}
				}
				else if(strcmp(ptr->cate, "PROCEDURE") == 0){
					fprintf(stdout, "[Checking Error] Procedure symbal %s can't be LHS\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else if(strcmp(ptr->cate, "PROGRAM") == 0){
					fprintf(stdout, "[Checking Error] Program symbal %s can't be LHS\n", ptr->name);
					err++;
					res = 1;
					return NULL;
				}
				else{
					fprintf(stdout, "** Find symbal %s in LHS **\n", ptr->name);
					//  array bound
					array = ptr->array;
					current = current->r_sibling;
					if(ptr->j_var == -1){
						if(array == 0);
						else{
							sprintf(jasmin, "		getstatic a/%s ", ptr->name);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							for(i = 0; i < array; i++){
								sprintf(jasmin, "[");
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
							sprintf(jasmin, "%s\n", ((ptr->type[0] == 'i') || (ptr->type[0] == 'I')) ? "I" : ((ptr->type[0] == 'r') || (ptr->type[0] == 'R')) ? "F" : "Ljava/lang/String;", ptr->j_var);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
					}
					else{
						if(array == 0);
						else{
							sprintf(jasmin, "		aload %d\n", ptr->j_var);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
					}
					i = 0;
					while(current != NULL){
						if(current->node_type == LBRAC){
							if((array--) == 0){
								fprintf(stdout, "[Checking Error] Wrong number of dimension symbal %s in LHS\n", ptr->name);
								err++;
								res = 1;
								return NULL;
							}
							if((Ttype = RHSsymlook(current->l_child, scope, retval, &isvalue, I)) == NULL){
								fprintf(stdout, "[Checking Error] Wrong expression in array %s of LHS\n", ptr->name);
								err++;
								res = 1;
								return NULL;
							}
							if((Ttype->type[0] != 'i') && (Ttype->type[0] != 'I')){
								fprintf(stdout, "[Checking Error] Wrong parameter type in array %s of LHS\n", ptr->name);
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
									fprintf(stdout, "[Checking Error] Out of bound %s of LHS\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
								if(Ttype->ivalue > ptr->bound[i++]){
									fprintf(stdout, "[Checking Error] Out of bound %s of LHS\n", ptr->name);
									err++;
									res = 1;
									return NULL;
								}
								if(array > 0){
									sprintf(jasmin, "		aaload\n");
									fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
								}
							}
							current = current->r_sibling;
						}
						else
							break;
					}
					if(array != 0){
						fprintf(stdout, "[Checking Error] Wrong number of dimension symbal %s in RHS\n", ptr->name);
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
	
	fprintf(stdout, "[Checking Error] Undeclared symbal %s\n", current->node_text);
	err++;
	res = 1;
	return NULL;
}

int Ievaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval)
{
	int aa, bb;
	sym_node ptr;
	nodeType temp;
	
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
			*check = 1;
		}
		else{
			*check = 2;
			return 0;
		}
	}
	else if((a->node_type == PLUS) || (a->node_type == MINUS) || (a->node_type == STAR) || (a->node_type == SLASH)){
		temp = a->l_child->r_sibling;  //  this is b
		while(temp != NULL)
			if(temp->node_type == LBRAC)  //  avoid array dimension
				temp = temp->r_sibling;
			else
				break;
		aa = Ievaluate(a, a->l_child, temp, scope, check, retval);
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
			*check = 1;
		}
		else{
			*check = 2;
			return 0;
		}
	}
	else if((b->node_type == PLUS) || (b->node_type == MINUS) || (b->node_type == STAR) || (b->node_type == SLASH)){
		temp = b->l_child->r_sibling;  //  this is b
		while(temp != NULL)
			if(temp->node_type == LBRAC)  //  avoid array dimension
				temp = temp->r_sibling;
			else
				break;
		bb = Ievaluate(b, b->l_child, temp, scope, check, retval);
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
	nodeType temp;

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
			*check = 1;
		}
		else{
			*check = 2;
			return 0;
		}
	}
	else if((a->node_type == PLUS) || (a->node_type == MINUS) || (a->node_type == STAR) || (a->node_type == SLASH)){
		temp = a->l_child->r_sibling;  //  this is b
		while(temp != NULL)
			if(temp->node_type == LBRAC)  //  avoid array dimension
				temp = temp->r_sibling;
			else
				break;
		aa = Revaluate(a, a->l_child, temp, scope, check, retval);
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
			*check = 1;
		}
		else{
			*check = 2;
			return 0;
		}
	}
	else if((b->node_type == PLUS) || (b->node_type == MINUS) || (b->node_type == STAR) || (b->node_type == SLASH)){
		temp = b->l_child->r_sibling;  //  this is b
		while(temp != NULL)
			if(temp->node_type == LBRAC)  //  avoid array dimension
				temp = temp->r_sibling;
			else
				break;
		bb = Revaluate(b, b->l_child, temp, scope, check, retval);
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
			sprintf(jasmin, "		fdiv\n");
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
		}
		return 0;
	}
}

sym_node RHSsymlook(nodeType current, int scope, nodeType retval, int* isvalue, sym_node Ltype)
{
	int check = 0, ians = 0, i;
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
			check = 1;
			Ttype = I;
			goto RHSresult;
		}
		if((Ttype->type[0] == 'r') || (Ttype->type[0] == 'R')){
			check = 1;
			Ttype = R;
			goto RHSresult;
		}
		if((Ttype->type[0] == 's') || (Ttype->type[0] == 'S')){
			check = 1;
			Ttype = S;
			goto RHSresult;
		}
	}

	
	if((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')){
		if(current->node_type == DIGSEQ){
			ians = current->node_ivalue;
			*isvalue = 1;
			Ttype = I;
			sprintf(jasmin, "		ldc %d\n", current->node_ivalue);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			goto RHSresult;
		}
		if((current->node_type == PLUS) || (current->node_type == MINUS) || (current->node_type == STAR) || (current->node_type == SLASH)){
			temp = current->l_child->r_sibling;  //  this is b
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
	}
	else if((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')){
		if(current->node_type == REALNUMBER){
			fans = current->node_fvalue;
			*isvalue = 1;
			Ttype = R;
			sprintf(jasmin, "		ldc %f\n", current->node_fvalue);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			goto RHSresult;
		}
		if((current->node_type == PLUS) || (current->node_type == MINUS) || (current->node_type == STAR) || (current->node_type == SLASH)){
			temp = current->l_child->r_sibling;  //  this is b
			while(temp != NULL)
				if(temp->node_type == LBRAC)  //  avoid array dimension
					temp = temp->r_sibling;
				else
					break;
			fans = Revaluate(current, current->l_child, temp, scope, &check, retval);
			if(check == 0)
				*isvalue = 1;
			if((check == 0) || (check == 1))
				Ttype = R;
			if(check != 2)
				goto RHSresult;
		}
	}
	else{
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
	}

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
				fprintf(stdout, "[Checking Error] Duplicate symbal %s %s\n", cate, name);
				err++;
				res = 1;
			}
			else{
				fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
				if(scope == 1){
					if(array == 0){
						sprintf(jasmin, ".field public static %s %s\n", name, ((type[0] == 'I') || (type[0] == 'i')) ? "I" : ((type[0] == 'R') || (type[0] == 'r')) ? "F" : "Ljava/lang/String;");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else{
						sprintf(jasmin, ".field public static %s ", name);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						for(i = 0; i < array; i++){
							sprintf(jasmin, "[");
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
						sprintf(jasmin, "%s\n", ((type[0] == 'I') || (type[0] == 'i')) ? "I" : ((type[0] == 'R') || (type[0] == 'r')) ? "F" : "Ljava/lang/String;");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						
					}
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
			fprintf(stdout, "[Checking Error] Duplicate symbal %s %s\n", cate, name);
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
					fprintf(stdout, "[Checking Error] Duplicate symbal %s %s\n", cate, name);
					err++;
					res = 1;
				}
				else{
					fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
					sprintf(jasmin, "%s", ((type[0] == 'I') || (type[0] == 'i')) ? "I" : ((type[0] == 'R') || (type[0] == 'r')) ? "F" : "Ljava/lang/String;");
		    		fwrite(jasmin , sizeof(char), strlen(jasmin), ofile);
					Ttype->ptype[para++] = ((type[0] == 'I') || (type[0] == 'i')) ? 'I' : ((type[0] == 'R') || (type[0] == 'r')) ? 'F' : 'S';  //  number of parameter
					Ttype->init = 1;
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
					fprintf(stdout, "[Checking Error] Duplicate symbal %s %s\n", cate, name);
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
		strcpy(name, "printInt");

		type = (char*)malloc(5);
		strcpy(type, "VOID");
		
		Ttype = new_sym_node(cate, name, type, 0, NULL, scope);  //  **********

		Ttype->para = 1;
		Ttype->ptype[0] = 'I';


		cate = (char*)malloc(10);
		strcpy(cate, "PROCEDURE");

		name = (char*)malloc(10);
		strcpy(name, "printReal");

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
				fprintf(stdout, "[Checking Error] Wrong LHS\n");
				err++;
				res = 1;
				goto Next;
			}
			temp[0] = temp[0]->r_sibling;
			while(temp[0]->node_type == LBRAC)
				temp[0] = temp[0]->r_sibling;

			if((Rtype = RHSsymlook(temp[0], scope, retval, &isvalue, Ltype)) == NULL){
				fprintf(stdout, "[Checking Error] Wrong RHS\n");
				err++;
				res = 1;
				goto Next;
			}
			Ltype->init = 1;
			
			if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I'))){
				if(Ltype->j_var == -1){
					if(Ltype->array == 0){
						sprintf(jasmin, "		putstatic a/%s %s\n", Ltype->name, "I");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else{
						sprintf(jasmin, "		iastore\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
				}
				else{
					if(Ltype->array == 0){
						sprintf(jasmin, "		istore %d\n", Ltype->j_var);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else{
						sprintf(jasmin, "		iastore\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
				}
			}
			else{
				if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R'))){
					if(Ltype->j_var == -1){
						if(Ltype->array == 0){
							sprintf(jasmin, "		putstatic a/%s %s\n", Ltype->name, "F");
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
						else{
							sprintf(jasmin, "		fastore\n");
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
					}
					else{
						if(Ltype->array == 0){
							sprintf(jasmin, "		fstore %d\n", Ltype->j_var);
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
						else{
							sprintf(jasmin, "		fastore\n");
							fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						}
					}
				}
				else{
					if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S'))){
						if(Ltype->j_var == -1){
							if(Ltype->array == 0){
								sprintf(jasmin, "		putstatic a/%s %s\n", Ltype->name, "Ljava/lang/String;");
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
							else{
								sprintf(jasmin, "		aastore\n");
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
						}
						else{
							if(Ltype->array == 0){
								sprintf(jasmin, "		astore %d\n", Ltype->j_var);
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
							else{
								sprintf(jasmin, "		aastore\n");
								fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
							}
						}
					}
					else{
						fprintf(stdout, "[Checking Error] Wrong type between LHS & RHS\n");
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
				tnoflabel = noflabel++;  //  NOF
				sprintf(jasmin, "	%s%d-%d:\n", "IF", tnoflabel, nofnest);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
				if((Ltype = RHSsymlook(temp[0]->l_child, scope, retval, &isvalue, I)) == NULL){
					fprintf(stdout, "[Checking Error] Wrong expression in if statement\n");
					err++;
					res = 1;
					goto Next;
				}
				temp[1] = temp[0]->l_child->r_sibling;
				while(temp[1] != NULL)
					if(temp[1]->node_type == LBRAC)
						temp[1] = temp[1]->r_sibling;
					else
						break;
				if((Rtype = RHSsymlook(temp[1], scope, retval, &isvalue, I)) == NULL){
					fprintf(stdout, "[Checking Error] Wrong expression in if statement\n");
					err++;
					res = 1;
					goto Next;
				}

				if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I'))){
					if(temp[0]->node_type == NOTEQUAL){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifeq %s%d-%d\n", "ELSE", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == EQUAL){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifne %s%d-%d\n", "ELSE", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == GE){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		iflt %s%d-%d\n", "ELSE", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == GT){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifle %s%d-%d\n", "ELSE", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == LE){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifgt %s%d-%d\n", "ELSE", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == LT){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifge %s%d-%d\n", "ELSE", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
				}
				else{
					if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R'))){
						fprintf(stdout, "[Checking Error] Can't use real number in expression\n");
						err++;
						res = 1;
						goto Next;
					}
					else{
						if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S'))){
							fprintf(stdout, "[Checking Error] Can't use string in expression\n");
							err++;
							res = 1;
							goto Next;
						}
						else{
							fprintf(stdout, "[Checking Error] Wrong type between LHS & RHS\n");
							err++;
							res = 1;
							goto Next;			
						}
					}
				}
			}
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;
			
			nofnest++;  //  NOF
			symlook(temp[1], scope, retval);
			nofnest--;  //  NOF
			sprintf(jasmin, "		goto %s%d-%d\n", "ENDIF", tnoflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;

			sprintf(jasmin, "	%s%d-%d:\n", "ELSE", tnoflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			nofnest++;  //  NOF
			symlook(temp[1], scope, retval);
			nofnest--;  //  NOF
			sprintf(jasmin, "	%s%d-%d:\n", "ENDIF", tnoflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);

			goto Next;
		}
		else if(current->node_type == WHILE){
			temp[0] = current->l_child;
			
			if((temp[0]->node_type == NOTEQUAL) || (temp[0]->node_type == EQUAL) || (temp[0]->node_type == GE) || (temp[0]->node_type == GT) || (temp[0]->node_type == LE) || (temp[0]->node_type == LT)){  //  factor
				tnoflabel = noflabel++;  //  NOF
				sprintf(jasmin, "	%s%d-%d:\n", "WHILE", tnoflabel, nofnest);
				fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
				if((Ltype = RHSsymlook(temp[0]->l_child, scope, retval, &isvalue, I)) == NULL){
					fprintf(stdout, "[Checking Error] Wrong expression in while statement\n");
					err++;
					res = 1;
					goto Next;
				}
				temp[1] = temp[0]->l_child->r_sibling;
				while(temp[1] != NULL)
					if(temp[1]->node_type == LBRAC)
						temp[1] = temp[1]->r_sibling;
					else
						break;
				if((Rtype = RHSsymlook(temp[1], scope, retval, &isvalue, I)) == NULL){
					fprintf(stdout, "[Checking Error] Wrong expression in while statement\n");
					err++;
					res = 1;
					goto Next;
				}

				if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I'))){
					if(temp[0]->node_type == NOTEQUAL){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifne %s%d-%d\n", "DO", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == EQUAL){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifeq %s%d-%d\n", "DO", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == GE){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifge %s%d-%d\n", "DO", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == GT){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifgt %s%d-%d\n", "DO", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == LE){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		ifle %s%d-%d\n", "DO", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
					else if(temp[0]->node_type == LT){
						sprintf(jasmin, "		isub\n");
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
						sprintf(jasmin, "		iflt %s%d-%d\n", "DO", tnoflabel, nofnest);
						fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
					}
				}
				else{
					if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R'))){
						fprintf(stdout, "[Checking Error] Can't use real number in expression\n");
						err++;
						res = 1;
						goto Next;
					}
					else{
						if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S'))){
							fprintf(stdout, "[Checking Error] Can't use string in expression\n");
							err++;
							res = 1;
							goto Next;
						}
						else{
							fprintf(stdout, "[Checking Error] Wrong type between LHS & RHS\n");
							err++;
							res = 1;
							goto Next;
						}
					}
				}
			}
			sprintf(jasmin, "		goto %s%d-%d\n", "ENDWHILE", tnoflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;

			sprintf(jasmin, "	%s%d-%d:\n", "DO", tnoflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			nofnest++;  //  NOF
			symlook(temp[1], scope, retval);
			nofnest--;  //  NOF
			sprintf(jasmin, "		goto %s%d-%d\n", "WHILE", tnoflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			sprintf(jasmin, "	%s%d-%d:\n", "ENDWHILE", tnoflabel, nofnest);
			fwrite(jasmin, sizeof(char), strlen(jasmin), ofile);
			
			goto Next;
		}
		else if(current->node_type == IDENTIFIER){  //  function & procedure
			temp[0] = current;
			if((Ltype = symcheck(temp[0], scope, retval)) != NULL);
			else{
				fprintf(stdout, "[Checking Error] Error occured, some error in function or procedure\n");
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
				fprintf(stdout, "[Checking Error] Error occured, expect a previous begin\n");
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
