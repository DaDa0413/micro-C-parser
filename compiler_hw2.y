/*	Definition section */
%{
#include <stdio.h>
#include <stdlib.h>
#include "config.h"
#include <string.h>

//defined in lex
extern int yylineno;
extern int yylex();
extern void yyerror(char *);

//buffer and flag
extern int scope;
extern int table_flag;
extern int semantic_error_flag;
extern int syntactic_error_flag;
extern char* yytext;   // Get current token from lex
extern char buf[256];  // Get current code line from lex
extern char table_buf[1024];
extern char error_buf[128];

char temp[100];
table symbol_table[30];
function_table func_table[10];
int symbol_table_index = -1;
int func_table_index = -1;

/* Symbol table function */
int check_symbol(char *name, int scope);
int check_func_symbol(char *name, int defining);
int lookup_symbol(char *name);
int lookup_func_symbol(char *name);
void create_symbol();
void insert_symbol(char *name, int kind, int type);
void insert_func_symbol(char *name, int kind, int type, int param_count, char *param, int defining);
void dump_symbol();
void dump_function();
%}

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
	struct _const_value
	{
    	int i_val;
	    double f_val;
    	char* string;
    	int b_val;
	}const_value;
	struct _param
	{
		int param_count;
		char param[10];
	}param;
	char* id;
	char declare_type;
}

/* Token without return */
 
 /* Relational Operator*/
%token '>' '<' MTE LTE EQ NE 
 /* Boolean Operator*/
%token AND OR '!'
 /* Algorithmatic Operator */
%right '+' '-' '*' '/' '%' INC DEC
 /* Assignmental Operator */
%right '=' ADDASGN SUBASGN MULASGN DIVASGN MODASGN
 /* Others Operator */
%token '(' ')' '{' '}' '[' ']' ',' ';'
 /* Keywords*/
%token PRINT IF ELSE FOR WHILE RET

/* Token with return, which need to sepcify type */
%token <declare_type> INT FLOAT BOOL STRING VOID
%token <const_value> I_CONST F_CONST STR_CONST TRUE FALSE
%token <id> ID END_OF_FILE
/* Nonterminal with return, which need to sepcify type */
%type <const_value> initializer term
%type <const_value> expression_stat expression2 expression3 expression4 expression5 func_stat bool_stat
%type <id> assign_stat
%type <declare_type> type
%type <param> declare_function_param
/* Yacc will start at this nonterminal */
%start program

/* Grammar section */
%%

program
    : stat	program{ }
    | END_OF_FILE	{ dump_function(); }
	|
;

stat
    : declaration
	| assign_stat 
	| expression_stat ';'
	| func_stat
	| return_stat
	| compound_stat
;

declaration
    : type ID '=' initializer ';'
	{
		//insert global variable to func_symbol
		if(scope != 0)
			insert_symbol($2, var_kind, $1);
		else
		{
			char temp[10] = {0};
			insert_func_symbol($2, var_kind, $1, 0, temp, 1);
		}
	}
	| type ID ';' 
	{
		if(scope != 0)
			insert_symbol($2, var_kind, $1);
		else
		{
			char temp[10] = {0};
			insert_func_symbol($2, var_kind, $1, 0, NULL, 1);
		}
	}
	| type ID '(' declare_function_param ')' ';' 
	{ 
		insert_func_symbol($2, func_kind, $1, $4.param_count, $4.param, 0);
		//dump_symbol(symbol_table); 
	}
	| type ID '(' declare_function_param ')' block 
	{ 
		insert_func_symbol($2, func_kind, $1, $4.param_count, $4.param, 1);
		dump_symbol(symbol_table); 
	}
;

declare_function_param
	: declare_function_param ',' type ID 
	{
		++$$.param_count;
		$$.param[$$.param_count - 1] = $3;
		insert_symbol($4, param_kind, $3);
	}
	| type ID 
	{
		//The reason we increase scope here
		//is beacuse we want param to be the same scope as variable
		//However, we decrease scope in lex
		/*++scope;*/
		$$.param_count = 1;
		memset($$.param, 0, sizeof($$.param));
		$$.param[0] = $1;
		insert_symbol($2, param_kind, $1);
	}
	| 
	{
		$$.param_count = 0; 
        memset($$.param, 0, sizeof($$.param));
	}
;

block
	: '{' program '}'	{}
;

assign_stat
	: ID '=' initializer ';'
	{
		if(!lookup_symbol($1))
		{
			sprintf(error_buf, "Undeclared variable %s", $1);
			semantic_error_flag = 1;
		}
	}
	| ID ADDASGN initializer ';'
	{
		if(!lookup_symbol($1))
		{
			sprintf(error_buf, "Undeclared variable %s", $1);
			semantic_error_flag = 1;
		}
	}
	| ID SUBASGN initializer ';'
	{
		if(!lookup_symbol($1))
		{
			sprintf(error_buf, "Undeclared variable %s", $1);
			semantic_error_flag = 1;
		}
	}
	| ID MULASGN initializer ';'
	{
		if(!lookup_symbol($1))
		{
			sprintf(error_buf, "Undeclared variable %s\n", $1);
			semantic_error_flag = 1;
		}
	}
	| ID DIVASGN initializer ';'
	{
		if(!lookup_symbol($1))
		{
			sprintf(error_buf, "Undeclared variable %s\n", $1);
			semantic_error_flag = 1;
		}
	}
	| ID MODASGN initializer ';'
	{
		if(!lookup_symbol($1))
		{
			sprintf(error_buf, "Undeclared variable %s\n", $1);
			semantic_error_flag = 1;
		}
	}
;

initializer
	: expression_stat
;

term
    : I_CONST 	{ $$ = $1; }	
	| '-' I_CONST 
	{
		$2.i_val = -$2.i_val; 
		$$ = $2;
	}
	| F_CONST 	{ $$ = $1; }
	| '-' F_CONST 
	{ 
		$2.f_val = -$2.f_val; 
		$$ = $2;
	}
	| STR_CONST { $$ = $1; }
	| ID 		
	{
		if(!lookup_symbol($1))
		{
			sprintf(error_buf, "Undeclared variable %s", $1);
			semantic_error_flag = 1;
		}
	}
	| TRUE
	| FALSE
;

expression_stat
	: expression2 '+' expression_stat
	| expression2 '-' expression_stat
	| expression2
;

expression2
	: expression3 '*' expression2
	| expression3 '/' expression2
	| expression3 '%' expression2
	| expression3
;

expression3
	: INC expression4 {}
	| DEC expression4 {}
	| expression4
;

expression4
	: expression5 INC
	| expression5 DEC
	| expression5
;

expression5
	: term
	| '(' expression_stat ')' {}

func_stat
	: ID '(' func_param ')' ';'
	{
		if(!lookup_func_symbol($1))
		{
			sprintf(error_buf, "Undeclared function %s", $1);
			semantic_error_flag = 1;
		}
	}
	/*| compound_stat		/* Put compound statements here because if, while and print are kinda function */
	| ID '(' error ')'
	{
		sprintf(error_buf, "Undeclared function %s", $1);
		semantic_error_flag = 1;
		yyerrok;
	}
;

func_param
	: func_param ',' term 
	| term
	|
;

compound_stat
    : IF '(' bool_stat ')' block else_stat
	| WHILE '(' bool_stat ')' block
	| print_func
;

else_stat
	: ELSE else_stat_postfix
	|
;

else_stat_postfix
	: IF '(' bool_stat ')' block else_stat
	| block
;
bool_stat
	: expression_stat '>' expression_stat{}
	| expression_stat '<' expression_stat{}
	| expression_stat MTE expression_stat{}
	| expression_stat LTE expression_stat{}
	| expression_stat EQ expression_stat{}
	| expression_stat NE expression_stat{}
	| TRUE
	| FALSE
;

print_func
    : PRINT '(' print_param ')' ';' { }
;

print_param
	: ID
	{
		if(!lookup_symbol($1))
		{
			sprintf(error_buf, "Undeclared variable %s", $1);
			semantic_error_flag = 1;
		}
	}
	| STR_CONST
;

return_stat
	: RET term ';'
;

type
    : INT { $$ = int_type; }
    | FLOAT { $$ = float_type; }
    | BOOL  { $$ = bool_type; }
    | STRING { $$ = string_type; }
    | VOID { $$ = void_type; }
;

%%

/* C code section */
int main(int argc, char** argv)
{
    yylineno = 0;
	create_symbol();
	yyparse();
	printf("\nTotal lines: %d \n",yylineno);

    return 0;
}
//TODO
void yyerror(char *s)
{
	/*
    printf("\n|-----------------------------------------------|\n");
    printf("| Error found in line %d: %s\n", yylineno + 1, buf);
    printf("| %s", s);
    printf("\n|-----------------------------------------------|\n\n");*/
	printf("%d: %s\n", yylineno, buf);
	if(semantic_error_flag)
	{
    	printf("\n|-----------------------------------------------|\n");
    	printf("| Error found in line %d: %s\n", yylineno, buf);
	    printf("| %s", error_buf);
    	printf("\n|-----------------------------------------------|\n\n");
	}
    printf("\n|-----------------------------------------------|\n");
    printf("| Error found in line %d: %s\n", yylineno, buf);
	printf("| %s", "syntax error");
    printf("\n|-----------------------------------------------|\n\n");
	memset(error_buf, 0, sizeof(error_buf));
	semantic_error_flag = 0;
	syntactic_error_flag = 1;
}

void create_symbol() 
{
	memset(symbol_table, 0, sizeof(symbol_table));
	memset(func_table, 0, sizeof(func_table));
}

//Index     Name      Kind        Type      Scope     Attribute
//Needed to be put to symbol table
//the param - symbol_table here is just a pointer to working table
void insert_symbol(char *name, int kind, int type)
{
	//symbol redeclare
	if(check_symbol(name, scope))
	{
		sprintf(error_buf, "Redeclared variable %s", name);
		semantic_error_flag = 1;
		return;
	}
	++symbol_table_index;
	symbol_table[symbol_table_index].index = symbol_table_index;
	strcpy(symbol_table[symbol_table_index].name, name);
	symbol_table[symbol_table_index].kind = kind;
	symbol_table[symbol_table_index].type = type;
	symbol_table[symbol_table_index].scope = (kind == param_kind ? scope + 1 : scope);
}

void insert_func_symbol(char *name, int kind, int type, int param_count, char *param, int defining)
{
	//function redeclare or redifinition
	if(check_func_symbol(name, defining))
	{
		sprintf(error_buf, "Redeclared function %s", name);
		semantic_error_flag = 1;
		return;
	}
	++func_table_index;
	func_table[func_table_index].index = func_table_index;
	strcpy(func_table[func_table_index].name, name);
	func_table[func_table_index].kind = kind;
	func_table[func_table_index].type = type;
	func_table[func_table_index].scope = scope;
	func_table[func_table_index].attr_count = param_count;
	/*func_table[func_table_index].attr = param;*/
	memcpy(func_table[func_table_index].attr, param, sizeof(param));
	func_table[func_table_index].defined = defining;
}

int check_symbol(char *name, int scope)
{
	for(int i = 0; i <= symbol_table_index; ++i)
	{		
/*		printf("check:%s %s %d %d\n", symbol_table[i].name, name, symbol_table[i].scope, scope);*/
		if(!strcmp(symbol_table[i].name, name) && symbol_table[i].scope == scope)
			return 1;
	}
	return 0;
}

//if it is illegal
//return 1
int check_func_symbol(char *name, int defining)
{
	for(int i = 0; i < func_table_index; ++i)
	{
		if(!strcmp(name, func_table[i].name))
		{
			if(defining == 0)
				return 1;
			else if(!func_table[i].defined)
				return 0;
			else
				return 1;
		}
	}
	return 0;
}

int lookup_symbol(char *name)
{
	for(int i = 0; i <= symbol_table_index; ++i)
	{
		if(!strcmp(name, symbol_table[i].name))
			return 1;
	}
	return 0;
}

//if name exists
//return 1
//otherwise return 0
int lookup_func_symbol(char *name)
{
	for(int i = 0; i <= func_table_index; ++i)
	{
		if(!strcmp(name, func_table[i].name));
			return 1;
	}
	return 0;
}

void dump_symbol() {
	memset(table_buf, 0, sizeof(table_buf));
	table_buf[0] = '\0';
    sprintf(temp, "\n%-10s%-10s%-12s%-10s%-10s%-10s\n\n",
           "Index", "Name", "Kind", "Type", "Scope", "Attribute");
	strcat(table_buf, temp);

	//Record the last index of outer scope
	int index_of_outer_scope = 0;
	int print_index = 0;
	for(int i = 0; i <= symbol_table_index; ++i)
	{
		//We only need to print current scope
		//We add scope with 1 is because scope has been decreased by lex upon reading in it
		if(symbol_table[i].scope != scope + 1)
		{
			index_of_outer_scope = i;
			continue;
		}
		sprintf(temp, "%-10d%-10s", print_index++, symbol_table[i].name);
		strcat(table_buf, temp);
		switch(symbol_table[i].kind)
		{
			case param_kind:
				sprintf(temp, "%-12s", "parameter");
				strcat(table_buf, temp);
				break;
			case var_kind:
				sprintf(temp, "%-12s", "variable");
				strcat(table_buf, temp);
				break;
			case func_kind:
				sprintf(temp, "%-12s", "function");
				strcat(table_buf, temp);
				break;
		}
		switch(symbol_table[i].type)
		{
			case int_type:
				sprintf(temp, "%-10s", "int");
				strcat(table_buf, temp);
				break;
			case float_type:
				sprintf(temp, "%-10s", "float");
				strcat(table_buf, temp);
				break;
			case bool_type:
				sprintf(temp, "%-10s", "bool");
				strcat(table_buf, temp);
				break;
			case string_type:
				sprintf(temp, "%-10s", "string");
				strcat(table_buf, temp);
                break;
			case void_type:
				sprintf(temp, "%-10s", "void");
				strcat(table_buf, temp);
                break;
		}
		sprintf(temp, "%-10d\n", symbol_table[i].scope);
		strcat(table_buf, temp);
	}
	sprintf(temp, "\n");
	strcat(table_buf, temp);
	
	//Clear current scope
	//and reset the symbol_table_index
	for(int i = index_of_outer_scope; i <= symbol_table_index; ++i)
		memset(&symbol_table[i], 0, sizeof(symbol_table[i]));
	symbol_table_index = index_of_outer_scope;

	table_flag = 1;
}


void dump_function() {
    printf("\n%-10s%-10s%-12s%-10s%-10s%-10s\n\n",
           "Index", "Name", "Kind", "Type", "Scope", "Attribute");
	for(int i = 0; i <= func_table_index; ++i)
	{
		printf("%-10d%-10s", i, func_table[i].name);
		switch(func_table[i].kind)
		{
			case var_kind:
				printf("%-12s", "variable");
				break;
			case func_kind:
				printf("%-12s", "function");
				break;
		}
		switch(func_table[i].type)
		{
			case int_type:
				printf("%-10s", "int");
				break;
			case float_type:
				printf("%-10s", "float");
				break;
			case bool_type:
				printf("%-10s", "bool");
				break;
			case string_type:
				printf("%-10s", "string");
                break;
			case void_type:
				printf("%-10s", "void");
                break;
		}
		printf("%-10d", symbol_table[i].scope);
		if(func_table[i].attr_count != 0)		
			switch(func_table[i].attr[0])
			{
				case int_type:
					printf("%s", "int");
					break;
				case float_type:
					printf("%s", "float");
					break;
				case bool_type:
					printf("%s", "bool");
					break;
				case string_type:
					printf("%s", "string");
            	    break;
				case void_type:
					printf("%s", "void");
	                break;
			}
		for(int j = 1; j < func_table[i].attr_count; ++j)
		{
			switch(func_table[i].attr[j])
			{
				case int_type:
					printf("%s", ", int");
					break;
				case float_type:
					printf("%s", ", float");
					break;
				case bool_type:
					printf("%s", ", bool ");
					break;
				case string_type:
					printf("%-10s", ", string ");
            	    break;
				case void_type:
					printf("%-10s", ", void ");
	                break;
			}
		}
		printf("\n");
	}
	printf("\n");
}


