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
#include "node.h"
#include "symtab.h"

/* Called by yyparse on error.  */

int res = 0, err = 0, B_E = 0;
nodeType AST, TEMP;
sym_node I, R, S;

void symdestroy(int scope);  //  destroy symble table
sym_node symcheck(nodeType current, int scope, nodeType retval);  //  check the type with no assignment
sym_node RHSsymcheck(nodeType current, int scope, nodeType retval);  //  check the type in RHS
sym_node LHSsymcheck(nodeType current, int scope, nodeType retval);  //  check the type in LHS
int Ievaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval);  //  test and evaluate the expression whether it is integer or not
float Revaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval);  //  test and evaluate the expression whether it is real number or not
sym_node RHSsymlook(nodeType current, int scope, nodeType retval, int* isvalue);  // run through the RHS, and seperate it to digit number, real number, string, variable, and expression. then, call RHSsymcheck and LHSsymcheck to do the type checking.
void symlook(nodeType current, int scope, nodeType retval);  //  run through the whole AST, and find out the VAR, FUNCTION, PROCEDURE, and PROGRAM declaration. others are ASSIGNMENT, IF, WHILE, PBEGIN, and END tokens.

void yyerror (char const *s)
{
	extern char *yytext;
	extern int line_no;
	fprintf(stderr, "[Syntactic analyzer error] %s at line %d symbol '%s'\n", s, line_no, yytext);
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
		$$ = new_node_i(REALNUMBER, $2);
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

void symdestroy(int scope)
{
	sym_node ptr = scope_display[scope];

	while(ptr != NULL){
		scope_display[scope] = ptr->scope;

		fprintf(stdout, "Remove node %s %s %d\n", ptr->cate, ptr->name, scope);
		rm_sym_node(ptr);  //  **********

		ptr = scope_display[scope];
	}
}

sym_node symcheck(nodeType current, int scope, nodeType retval)
{
	sym_node ptr;
	int current_scope = scope, para, isvalue;
	sym_node Ttype;

	do{
		ptr = scope_display[current_scope];
		while(ptr != NULL){
			if(strcmp(ptr->name, current->node_text) == 0){
				if(strcmp(ptr->cate, "PROGRAM") == 0){
					fprintf(stdout, "** Program symbal %s can't be used here **\n", ptr->name);
					return NULL;
				}
				else if(strcmp(ptr->cate, "VAR") == 0){
					fprintf(stdout, "** Var symbal %s can't be used here **\n", ptr->name);
					return NULL;
				}
				else{
					fprintf(stdout, "** Find symbal %s **\n", ptr->name);
					//  function procedure parameter
					if((strcmp(ptr->cate, "FUNCTION") == 0) || (strcmp(ptr->cate, "PROCEDURE") == 0)){
						para = ptr->para;
						current = current->l_child;
						while(current != NULL){
							if((para--) == 0){
								if(strcmp(ptr->cate, "FUNCTION") == 0)
									fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
								else
									fprintf(stdout, "** Wrong number of parameter in procedure %s **\n", ptr->name);
								return NULL;
							}
							if((Ttype = RHSsymlook(current, scope, retval, &isvalue)) == NULL){
								if(strcmp(ptr->cate, "FUNCTION") == 0)
									fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
								else
									fprintf(stdout, "** Wrong number of parameter in procedure %s **\n", ptr->name);
								return NULL;
							}
							do{
								current = current->r_sibling;
								if(current == NULL)
									break;
							}while(current->node_type == LBRAC);
						}
						if(para != 0){
							if(strcmp(ptr->cate, "FUNCTION") == 0)
								fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
							else
								fprintf(stdout, "** Wrong number of parameter in procedure %s **\n", ptr->name);
							return NULL;
						}
						else
							return ptr;
					}
					//  no need array bound
					return ptr;
				}
			}
			ptr = ptr->scope;
		}
	}while(current_scope--);
	
	fprintf(stdout, "** Undeclared symbal %s **\n", current->node_text);
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
					return NULL;
				}
				else if(strcmp(ptr->cate, "PROGRAM") == 0){
					fprintf(stdout, "** Program symbal %s can't be RHS **\n", ptr->name);
					return NULL;
				}
				else{
					if((ptr->init == 0) && (retval == NULL)){
						fprintf(stdout, "** Use %s after initialization **\n", ptr->name);
						return NULL;
					}

					fprintf(stdout, "** Find symbal %s in RHS **\n", ptr->name);
					//  function parameter
					if((strcmp(ptr->cate, "FUNCTION") == 0)){
						para = ptr->para;
						current = current->l_child;
						while(current != NULL){
							if((para--) == 0){
								fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
								return NULL;
							}
							if((Ttype = RHSsymlook(current, scope, retval, &isvalue)) == NULL){
								fprintf(stdout, "** Wrong parameter in function %s **\n", ptr->name);
								return NULL;
							}
							do{
								current = current->r_sibling;
								if(current == NULL)
									break;
							}while(current->node_type == LBRAC);
						}
						if(para != 0){
							fprintf(stdout, "** Wrong number of parameter in function %s **\n", ptr->name);
							return NULL;
						}
						else
							return ptr;
					}
					//  array bound
					else{
						array = ptr->array;
						current = current->r_sibling;
						while(current != NULL){
							if(current->node_type == LBRAC){
								if((array--) == 0){
									fprintf(stdout, "** Wrong number of dimension symbal %s in RHS **\n", ptr->name);
									return NULL;
								}
								if((Ttype = RHSsymlook(current->l_child, scope, retval, &isvalue)) == NULL){  //XXXX
									fprintf(stdout, "** Wrong expression in array %s of RHS **\n", ptr->name);
									return NULL;
								}
								if((Ttype->type[0] != 'i') && (Ttype->type[0] != 'I')){
									fprintf(stdout, "** Wrong parameter type in array %s of RHS **\n", ptr->name);
									return NULL;
								}
								else{
									if(isvalue == 0){
										current = current->r_sibling;
										continue;
									}

									if(Ttype->ivalue < ptr->bound[i++]){
										fprintf(stdout, "** Out of bound %s of RHS **\n", ptr->name);
										return NULL;
									}
									if(Ttype->ivalue > ptr->bound[i++]){
										fprintf(stdout, "** Out of bound %s of RHS **\n", ptr->name);
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
						return ptr;
					}
					else{
						fprintf(stdout, "** Function symbal %s can't be LHS **\n", ptr->name);
						return NULL;
					}
				}
				else if(strcmp(ptr->cate, "PROCEDURE") == 0){
					fprintf(stdout, "** Procedure symbal %s can't be LHS **\n", ptr->name);
					return NULL;
				}
				else if(strcmp(ptr->cate, "PROGRAM") == 0){
					fprintf(stdout, "** Program symbal %s can't be LHS **\n", ptr->name);
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
								return NULL;
							}
							if((Ttype = RHSsymlook(current->l_child, scope, retval, &isvalue)) == NULL){  //XXXX
								fprintf(stdout, "** Wrong expression in array %s of LHS **\n", ptr->name);
								return NULL;
							}
							if((Ttype->type[0] != 'i') && (Ttype->type[0] != 'I')){
								fprintf(stdout, "** Wrong parameter type in array %s of LHS **\n", ptr->name);
								return NULL;
							}
							else{
								if(isvalue == 0){
									current = current->r_sibling;
									continue;
								}
								
								if(Ttype->ivalue < ptr->bound[i++]){
									fprintf(stdout, "** Out of bound %s of LHS **\n", ptr->name);
									return NULL;
								}
								if(Ttype->ivalue > ptr->bound[i++]){
									fprintf(stdout, "** Out of bound %s of LHS **\n", ptr->name);
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
	return NULL;
}

int Ievaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval)
{
	int aa, bb;
	sym_node ptr;
	
	if(a->node_type == DIGSEQ)
		aa = a->node_ivalue;
	else if(a->node_type == IDENTIFIER || a->node_type == FUNCTION){
		if((ptr = RHSsymcheck(a, scope, retval)) == NULL){  //  Undeclared
			*check = 4;
			return 0;
		}
		if((ptr->type[0] == 'i') || (ptr->type[0] == 'I'))  //  toupper
			*check = 1;
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
	
	if(b->node_type == DIGSEQ)
		bb = b->node_ivalue;
	else if(b->node_type == IDENTIFIER || b->node_type == FUNCTION){
		if((ptr = RHSsymcheck(b, scope, retval)) == NULL){  //  Undeclared
			*check = 4;
			return 0;
		}
		if((ptr->type[0] == 'i') || (ptr->type[0] == 'I'))  //  toupper
			*check = 1;
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
		if(op->node_type == PLUS)
			return aa+bb;
		else if(op->node_type == MINUS)
			return aa-bb;
		else if(op->node_type == STAR)
			return aa*bb;
		else{
			if(bb == 0){  //  divided by zero
				*check = 3;
				return 0;
			}
			return aa/bb;
		}
	}
	return 0;
}

float Revaluate(nodeType op, nodeType a, nodeType b, int scope, int* check, nodeType retval)
{
	float aa, bb;
	sym_node ptr;

	if(a->node_type == REALNUMBER)
		aa = a->node_fvalue;
	else if(a->node_type == DIGSEQ)
		aa = a->node_ivalue;
	else if(a->node_type == IDENTIFIER || a->node_type == FUNCTION){
		if((ptr = RHSsymcheck(a, scope, retval)) == NULL){  //  Undeclared
			*check = 4;
			return 0;
		}
		if((ptr->type[0] == 'i') || (ptr->type[0] == 'I') || (ptr->type[0] == 'r') || (ptr->type[0] == 'R'))  //  toupper
			*check = 1;
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
	
	if(b->node_type == REALNUMBER)
		bb = b->node_fvalue;
	else if(b->node_type == DIGSEQ)
		bb = b->node_ivalue;
	else if(b->node_type == IDENTIFIER || b->node_type == FUNCTION){
		if((ptr = RHSsymcheck(b, scope, retval)) == NULL){  //  Undeclared
			*check = 4;
			return 0;
		}
		if((ptr->type[0] == 'i') || (ptr->type[0] == 'I') || (ptr->type[0] == 'r') || (ptr->type[0] == 'R'))  //  toupper
			*check = 1;
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
		if(op->node_type == PLUS)
			return aa+bb;
		else if(op->node_type == MINUS)
			return aa-bb;
		else if(op->node_type == STAR)
			return aa*bb;
		else{
			if(bb == 0){  //  divided by zero
				*check = 3;
				return 0;
			}
			return aa/bb;
		}
	}
	return 0;
}

sym_node RHSsymlook(nodeType current, int scope, nodeType retval, int* isvalue)
{
	int check = 0, ians = 0;
	float fans = 0;
	sym_node Ttype = NULL;
	nodeType temp;
	
	*isvalue = 0;
	if(current->node_type == IDENTIFIER){
		if((Ttype = RHSsymcheck(current, scope, retval)) == NULL){
			check = 4;
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
//		if((Ttype->type[0] == 's') || (Ttype->type[0] == 'S')){
//			check = 1;
//			Ttype = S;
//			goto Next;
//		}
	}

	if(current->node_type == DIGSEQ){
		ians = current->node_ivalue;
		*isvalue = 1;
		Ttype = I;
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

//	if(current->node_type == CHARACTER_STRING);
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
	char *cate = NULL, *type = NULL, *name = NULL;
	int array = 0, para = 0, i = 0;
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
			if(new_sym_node(cate, name, type, array, bound, scope) == NULL)  //  **********
				fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
			else
				fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
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
		type = (char*)malloc(strlen(current->node_text)+1);
		strcpy(type, current->node_text);
		
		current = current->r_sibling;
		name = (char*)malloc(strlen(current->node_text)+1);
		strcpy(name, current->node_text);
		if((Ttype = new_sym_node(cate, name, type, array, NULL, scope)) == NULL){  //  **********
			fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
			if(origin->r_sibling != NULL)
				symlook(origin->r_sibling, scope, retval);
			return;
		}
		else
			fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
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
				name = (char*)malloc(strlen(temp[1]->node_text)+1);
				strcpy(name, temp[1]->node_text);
				if(new_sym_node(cate, name, type, array, NULL, scope) == NULL)  //  **********
					fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
				else{
					fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
					para++;  //  nmber of parameter
				}
				free(name);
				temp[1] = temp[1]->r_sibling;
			}
			temp[0] = temp[0]->r_sibling;
		}
		Ttype->para = para;  //  insert the number of parameter into function IDENTIFIER
		free(cate);
		free(type);
		
		current = origin->l_child->r_sibling->r_sibling;
		if(current != NULL)
			symlook(current, scope, origin->l_child->r_sibling);

		symdestroy(scope);
		fprintf(stdout, "Close scope %d\n", scope);
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

		if((Ttype = new_sym_node(cate, name, NULL, array, NULL, scope)) == NULL){  //  **********
			fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
			if(origin->r_sibling != NULL)
				symlook(origin->r_sibling, scope, retval);
			return;
		}
		else
			fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
		free(cate);
		free(name);

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
				if(temp[1]->node_type != IDENTIFIER)
					break;
				name = (char*)malloc(strlen(temp[1]->node_text)+1);
				strcpy(name, temp[1]->node_text);
				if(new_sym_node(cate, name, type, array, NULL, scope) == NULL)  //  **********
					fprintf(stdout, "** Duplicate symbal %s %s **\n", cate, name);
				else{
					fprintf(stdout, "New node %s %s %d\n", cate, name, scope);
					para++;  //  number of parameter
				}
				free(name);
				temp[1] = temp[1]->r_sibling;
			}
			temp[0] = temp[0]->r_sibling;
		}
		Ttype->para = para;  //  insert the number of parameter into function IDENTIFIER
		free(cate);
		free(type);
		
		current = origin->l_child->r_sibling->r_sibling;
		if(current != NULL)
			symlook(current, scope, origin->l_child->r_sibling);

		symdestroy(scope);
		fprintf(stdout, "Close scope %d\n", scope);
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
				goto Next;
			}
			temp[0] = temp[0]->r_sibling;
			while(temp[0]->node_type == LBRAC)
				temp[0] = temp[0]->r_sibling;

			if((Rtype = RHSsymlook(temp[0], scope, retval, &isvalue)) == NULL){
				fprintf(stdout, "** Wrong RHS **\n");
				goto Next;
			}
			Ltype->init = 1;
			
			if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I')));
			else{
				if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R')));
				else{
					if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S')));
					else
						fprintf(stdout, "** Wrong type between LHS & RHS **\n");
				}
			}
			goto Next;
		}
		else if(current->node_type == IF){
			temp[0] = current->l_child;
			
			if((temp[0]->node_type == NOTEQUAL) || (temp[0]->node_type == EQUAL) || (temp[0]->node_type == GE) || (temp[0]->node_type == GT) || (temp[0]->node_type == LE) || (temp[0]->node_type == LT)){  //  factor
				if((Ltype = RHSsymlook(temp[0]->l_child, scope, retval, &isvalue)) == NULL){
					fprintf(stdout, "** Wrong expression in if statement **\n");
					goto Next;
				}
				if((Rtype = RHSsymlook(temp[0]->l_child->r_sibling, scope, retval, &isvalue)) == NULL){
					fprintf(stdout, "** Wrong expression in if statement **\n");
					goto Next;
				}

				if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I')));
				else{
					if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R')));
					else{
						if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S')));
						else{
							fprintf(stdout, "** Wrong type between LHS & RHS **\n");
							goto Next;			
						}
					}
				}
			}
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;
			
			symlook(temp[1], scope, retval);
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;
			
			symlook(temp[1], scope, retval);

			goto Next;
		}
		else if(current->node_type == WHILE){
			temp[0] = current->l_child;
			
			if((temp[0]->node_type == NOTEQUAL) || (temp[0]->node_type == EQUAL) || (temp[0]->node_type == GE) || (temp[0]->node_type == GT) || (temp[0]->node_type == LE) || (temp[0]->node_type == LT)){  //  factor
				if((Ltype = RHSsymlook(temp[0]->l_child, scope, retval, &isvalue)) == NULL){
					fprintf(stdout, "** Wrong expression in if statement **\n");
					goto Next;
				}
				if((Rtype = RHSsymlook(temp[0]->l_child->r_sibling, scope, retval, &isvalue)) == NULL){
					fprintf(stdout, "** Wrong expression in if statement **\n");
					goto Next;
				}

				if(((Ltype->type[0] == 'i') || (Ltype->type[0] == 'I')) && ((Rtype->type[0] == 'i') || (Rtype->type[0] == 'I')));
				else{
					if(((Ltype->type[0] == 'r') || (Ltype->type[0] == 'R')) && ((Rtype->type[0] == 'r') || (Rtype->type[0] == 'R')));
					else{
						if(((Ltype->type[0] == 's') || (Ltype->type[0] == 'S')) && ((Rtype->type[0] == 's') || (Rtype->type[0] == 'S')));
						else{
							fprintf(stdout, "** Wrong type between LHS & RHS **\n");
							goto Next;
						}
					}
				}
			}
			temp[0] = temp[0]->r_sibling;
			temp[1] = temp[0]->l_child;

			symlook(temp[1], scope, retval);
			
			goto Next;
		}
		else if(current->node_type == IDENTIFIER){
			temp[0] = current;
			Ltype = symcheck(temp[0], scope, retval);

			goto Next;
		}
		else if(current->node_type == PBEGIN){
			B_E++;
			fprintf(stdout, "** Begin **\n");
			goto Next;
		}
		else if(current->node_type == END){  //  when the scope is closed, delete the correspond sym_node
			if(--B_E < 0)
				fprintf(stdout, "** Error occured, expect a previous begin **\n");
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
	fprintf(stderr, "open file.\n");
	if(argc>1 && freopen(argv[1],"r",stdin)==NULL){
		return 1;
	}

//	fprintf(stderr, "call yyparse\n\n********** START  PARGING **********\n\n");

	yyparse();

	fprintf(stdout, "after call yyparse, res = %d, err = %d.\n\n********** Abstract Syntax Tree **********\n\n", res, err);
	print_AST(AST);
	fprintf(stdout, "\n\n********** Abstract Syntax Tree **********\n\n");

	fprintf(stdout, "\n\n********** Symbol Table Checking **********\n\n");
	fprintf(stdout, "Create symbal table\n");
	I = new_sym_node("VAR", "RHSvalue-Integer", "INTEGER", 0, NULL, 9);  //  *****
	R = new_sym_node("VAR", "RHSvalue-Real", "REAL", 0, NULL, 9);  //  *****
	S = new_sym_node("VAR", "RHSvalue-String", "STRING", 0, NULL, 9);  //  *****
	symlook(AST, 0, NULL);
	symdestroy(0);
	rm_sym_node(I);
	rm_sym_node(R);
	rm_sym_node(S);
	fprintf(stdout, "Destroy symbal table\n");
	fprintf(stdout, "\n********** Symbol Table Checking **********\n\n");

	if (res==0)
		fprintf(stderr, "SUCCESS\n");
	else
		fprintf(stderr, "ERROR\n");
}
#include "lex.yy.c"
