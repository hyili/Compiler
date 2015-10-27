//enum {ARRAY, ASSIGNMENT, CHARACTER_STRING, COLON, COMMA, DIGSEQ, DO, DOT, DOTDOT, ELSE, END, EQUAL, ERROR, FUNCTION, GE, GOTO, GT, IDENTIFIER, 
//	IF, IN, LBRAC, LE, LPAREN, LT, MINUS, NOT, NOTEQUAL, OF, PBEGIN, PLUS, PROCEDURE, PROGRAM, RBRAC, REALNUMBER, RPAREN, SEMICOLON, SLASH, 
//	STAR, STARSTAR, STRING, THEN, UPARROW, VAR, WHILE, NIDENTIFIER, EXPOPRST, INTEGER, REAL, INVALIDSYM};

typedef struct nodeType* nodeType;
struct nodeType {
	nodeType r_sibling;
	nodeType l_child;

	int node_type;
	int node_ivalue;
	float node_fvalue;
	char* node_text;
};

nodeType new_node(int node_type_I)
{
	nodeType current = (nodeType)malloc(sizeof(struct nodeType));
	current->node_type = node_type_I;
	return current;
}

nodeType new_node_i(int node_type_I, int node_ivalue_I)
{
	nodeType current = (nodeType)malloc(sizeof(struct nodeType));
	current->node_type = node_type_I;
	current->node_ivalue = node_ivalue_I;
	return current;
}

nodeType new_node_f(int node_type_I, float node_fvalue_I)
{
	nodeType current = (nodeType)malloc(sizeof(struct nodeType));
	current->node_type = node_type_I;
	current->node_fvalue = node_fvalue_I;
	return current;
}

nodeType new_node_t(int node_type_I, char *node_text_I)
{
	nodeType current = (nodeType)malloc(sizeof(struct nodeType));
	current->node_type = node_type_I;
	if(node_text_I != NULL){
		current->node_text = (char*)malloc(strlen(node_text_I)+1);
		strcpy(current->node_text, node_text_I);
		free(node_text_I);
	}
	return current;
}

nodeType new_r_sibling(nodeType origin, nodeType r_sibling_I)
{
	nodeType current = origin;
	while(current->r_sibling != NULL)
		current = current->r_sibling;
	current->r_sibling = r_sibling_I;
	return origin;
}

nodeType new_l_child(nodeType origin, nodeType l_child_I)
{
	origin->l_child = l_child_I;
	return origin;
}

nodeType new_family_2(nodeType origin, nodeType l_child_I, nodeType r_sibling_I1)
{
	new_l_child(origin, l_child_I);
	new_r_sibling(l_child_I, r_sibling_I1);
	return origin;
}

nodeType new_family_3(nodeType origin, nodeType l_child_I, nodeType r_sibling_I1, nodeType r_sibling_I2)
{
	new_l_child(origin, l_child_I);
	new_r_sibling(l_child_I, r_sibling_I1);
	new_r_sibling(r_sibling_I1, r_sibling_I2);
	return origin;
}

nodeType new_family_4(nodeType origin, nodeType l_child_I, nodeType r_sibling_I1, nodeType r_sibling_I2, nodeType r_sibling_I3)
{
	new_l_child(origin, l_child_I);
	new_r_sibling(l_child_I, r_sibling_I1);
	new_r_sibling(r_sibling_I1, r_sibling_I2);
	new_r_sibling(r_sibling_I2, r_sibling_I3);
	return origin;
}

nodeType new_family_5(nodeType origin, nodeType l_child_I, nodeType r_sibling_I1, nodeType r_sibling_I2, nodeType r_sibling_I3, nodeType r_sibling_I4)
{
	new_l_child(origin, l_child_I);
	new_r_sibling(l_child_I, r_sibling_I1);
	new_r_sibling(r_sibling_I1, r_sibling_I2);
	new_r_sibling(r_sibling_I2, r_sibling_I3);
	new_r_sibling(r_sibling_I3, r_sibling_I4);
	return origin;
}

void rm_nodeType(nodeType current)
{
	current->r_sibling = NULL;
	current->l_child = NULL;
	free(current->node_text);
	free(current);
}

void print_AST(nodeType current)
{
	fprintf(stdout, "\n%4d, %10d, %.6f", current->node_type, current->node_ivalue, current->node_fvalue);
	if(current->node_text != NULL)
		fprintf(stdout, ", %s", current->node_text);
	fprintf(stdout, "\n\n");
	
	if(current->l_child != NULL){
		fprintf(stdout, "-> l_child <-");
		print_AST(current->l_child);
	}
	if(current->r_sibling != NULL){
		fprintf(stdout, "-> r_sibling <-");
		print_AST(current->r_sibling);
	}

	fprintf(stdout, "-> return <-");

/*	if(current->r_sibling != NULL && current->l_child != NULL){
		fprintf(stdout, "-> l_child <-");	
		print_AST(current->l_child);
		fprintf(stdout, "-> r_sibling <-");	
		print_AST(current->r_sibling);
	}
	else if(current->r_sibling != NULL && current->l_child == NULL){
		fprintf(stdout, "-> r_sibling <-");
		print_AST(current->r_sibling);
	}
	else if(current->r_sibling == NULL && current->l_child != NULL){
		fprintf(stdout, "-> l_child <-");
		print_AST(current->l_child);
	}
	
	fprintf(stdout, "-> return <-");*/
}
