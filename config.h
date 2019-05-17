#ifndef _config
#define _config
#define int_type 1
#define float_type 2
#define bool_type 3
#define string_type 4
#define void_type 5

#define param_kind 1
#define var_kind 2
#define func_kind 3

/*typedef struct _const_type const_type;
struct _const_type
{
	int i_val;
    double f_val;
    char* string;
    int b_val;
};*/

typedef struct _table
{
	char index;
	char name[20];
	char kind;
	char type;
	char scope;
}table;
typedef struct _function_table
{
	char index;
	char name[20];
	char kind;
	char type;
	char scope;
	char attr[10];
	char attr_count;
	char defined;	
}function_table;
#endif
