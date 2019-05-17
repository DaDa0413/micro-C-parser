/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    MTE = 258,
    LTE = 259,
    EQ = 260,
    NE = 261,
    AND = 262,
    OR = 263,
    INC = 264,
    DEC = 265,
    ADDASGN = 266,
    SUBASGN = 267,
    MULASGN = 268,
    DIVASGN = 269,
    MODASGN = 270,
    PRINT = 271,
    IF = 272,
    ELSE = 273,
    FOR = 274,
    WHILE = 275,
    RET = 276,
    INT = 277,
    FLOAT = 278,
    BOOL = 279,
    STRING = 280,
    VOID = 281,
    I_CONST = 282,
    F_CONST = 283,
    STR_CONST = 284,
    TRUE = 285,
    FALSE = 286,
    ID = 287,
    END_OF_FILE = 288
  };
#endif
/* Tokens.  */
#define MTE 258
#define LTE 259
#define EQ 260
#define NE 261
#define AND 262
#define OR 263
#define INC 264
#define DEC 265
#define ADDASGN 266
#define SUBASGN 267
#define MULASGN 268
#define DIVASGN 269
#define MODASGN 270
#define PRINT 271
#define IF 272
#define ELSE 273
#define FOR 274
#define WHILE 275
#define RET 276
#define INT 277
#define FLOAT 278
#define BOOL 279
#define STRING 280
#define VOID 281
#define I_CONST 282
#define F_CONST 283
#define STR_CONST 284
#define TRUE 285
#define FALSE 286
#define ID 287
#define END_OF_FILE 288

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 44 "compiler_hw2.y" /* yacc.c:1909  */

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

#line 137 "y.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
