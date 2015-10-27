#define NHASH 52
#define NSCPE 10

typedef struct sym_node* sym_node;
struct sym_node{
	sym_node var;  //  syms with same name  --  no use
	sym_node scope;  //  syms in the same scope
	sym_node hash;  //  linked list in the hash table  --  no use

	char* cate;
	char* name;
	char* type;
	int array;
	int para;
	
	int* bound;
	int init;
	char* text;
	int ivalue;
	float fvalue;
};
sym_node hash_table[NHASH], scope_display[NSCPE];

void rm_sym_node(sym_node current)
{
	current->var = NULL;
	current->scope = NULL;
	current->hash = NULL;
	free(current->cate);
	free(current->name);
	free(current->type);
	free(current);
}

int analysis(sym_node current, int scope)
{
	int i = scope;
	
	sym_node ptr = scope_display[i];
	if(ptr == NULL)
		scope_display[i] = current;
	else{
		do{
			if(strcmp(ptr->name, current->name) == 0){
				rm_sym_node(current);
				return 1;
			}
			ptr = ptr->scope;
		}while(ptr != NULL);

		current->scope = scope_display[i];
		scope_display[i] = current;
	}

	return 0;
}

sym_node new_sym_node(char* cate, char* name, char* type, int array, int* bound, int scope)
{
	int i;
	sym_node current = (sym_node)malloc(sizeof(struct sym_node));
	if(cate != NULL){
		current->cate = (char*)malloc(strlen(cate)+1);
		strcpy(current->cate, cate);
	}
	if(name != NULL){
		current->name = (char*)malloc(strlen(name)+1);
		strcpy(current->name, name);
	}
	if(type != NULL){
		current->type = (char*)malloc(strlen(type)+1);
		strcpy(current->type, type);
	}
	if(bound != NULL){
		current->bound = (int*)malloc(2*array*sizeof(int));
		for(i = 0; i < 2*array; i+=2){
			current->bound[i] = bound[i];
			current->bound[i+1] = bound[i+1];
		}
	}
	current->array = array;
	current->init = 0;
	current->para = 0;
	
	return analysis(current, scope)?NULL:current;
}
