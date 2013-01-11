//
//  Calc.y
//  0901632VectorCalc
//
//  Created by Peter Lockett on 11/01/2013.
//  Copyright (c) 2013 Peter Lockett. All rights reserved.
//
%{
#include <stdio.h>
#include <string.h>
#include "Vector.h"
#include "SymbolTable.h"

int yylex ();
void yyerror (char const*);

struct Vector3 VectorCalculation(struct Vector3 v1, struct Vector3 v2, int flag, double num);
%}

%union
{
	double number;
	union symbolValue value;
	char* string;
}

// Tokens that dont return a value
%token NEWLINE
%token DISPLAY
%token OPENCLOSE

// Tokens that return with a value
%token <number> NUM
%token <string> IDENTIFIER

// Productions that return a value
%type <number> inNum
%type <number> scalar
%type <value> vector
%type <value> calculation

// Production evaluation precadence
%left '-' '+'
%left '*'
%left '^'

%%

// Recursion to allow multiple input
input :
	input expression
	| expression
	;
	
expression :
	// A single calculation
	calculation NEWLINE 
	{
		// Calculation returned ok so set the value of result
		setValue("result", $1, SYMBOL_VECTOR);
	}
	// Displaying an identifier
	| DISPLAY IDENTIFIER NEWLINE 
		{
			union symbolValue value;
			// If we got the value of the identifier
			enum symbolType type = getValue($2, &value);
			if (type == SYMBOL_VECTOR)
			{
				printf(" = (%g, %g, %g)\n", value.vector.x, value.vector.y, value.vector.z);
			}
			if (type == SYMBOL_SCALAR)
			{
				printf("Scalar value is %f", value.scalarnum);
			}
			else
				printf("error: Couldn't find %s\n", $2);
		}
	// Setting an identifier to a calculation (which could be an identifier or user entered vector)
	| IDENTIFIER '=' calculation NEWLINE
		{
			// If we are trying to set the keyword result
			if(!strcmp($1, "result"))
			{
				printf("error: result is a keyword and can't be assigned\n");
			}
			else
			{
				union symbolValue v;
				v.vector = $3.vector;
				// Set the value and output what it was set to
				setValue($1, v, SYMBOL_VECTOR);
				printf("%s is now (%g, %g, %g)\n", $1, $3.vector.x, $3.vector.y, $3.vector.z);
			}
		}
	| IDENTIFIER '=' inNum NEWLINE
		{
			union symbolValue v;
			v.scalarnum = $3;
			setValue($1, v, SYMBOL_SCALAR);
			printf(" = %f\n", $3);
	
		}
	// Handle user only entering an integer or floating point number
	| NUM NEWLINE 
		{
			printf("Please enter a vector\n");
		}
	// Handle trying to set the keyword display
	| DISPLAY '=' calculation NEWLINE
		{
			printf("error: display is a keyword and can not be assigned\n");
		}
	// Handle trying to set a variable to the keyword display
	| IDENTIFIER '=' DISPLAY NEWLINE
		{
			printf("error: display is a keyword\n");
		}
	;

calculation :
	// To allow for recursion, a calculation can also be a vector
	vector
	{
		$$ = $1;
	}
	// Perform a scalar multiplication with the vector first
	| calculation '*' scalar
		{
			struct Vector3 temp;
			$$.vector = VectorCalculation($1.vector, temp, 3, $3);
			
		}
	// Perform a scalar multiplication with the scalar value first
	| scalar '*' calculation
	{
		struct Vector3 temp;
				$$.vector = VectorCalculation($3.vector, temp, 3, $1);
			
		}
	// perform an addition of 2 vectors
	| calculation '+' calculation 
		{
				$$.vector = VectorCalculation($1.vector, $3.vector, 1, 0);
			
		}
	// perform a subtraction of 2 vectors
	| calculation '-' calculation 
		{ 
				$$.vector = VectorCalculation($1.vector, $3.vector, 2, 0);
			
		}
	// perform a cross product multiplication on two vectors
	| calculation '^' calculation
		{
				$$.vector = VectorCalculation($1.vector, $3.vector, 4, 0);
		}
	;

scalar :
		inNum
		{
			$$ = $1;
		}
	|	IDENTIFIER
		{
			union symbolValue value;
			enum symbolType type = getValue($1, &value);
	
			if(type == SYMBOL_SCALAR)
			{
				$$ = value.scalarnum;
			}
			else
			{
				printf("type mismatch, variable is not a scalar");
			}
		}

vector :
	// Vector surrounded with parenthesis e.g peter = (1,1,1)
	OPENCLOSE inNum ',' inNum ',' inNum OPENCLOSE 
		{
			struct Vector3 *vec = malloc(sizeof(*vec));
			vec->x = $2;
			vec->y = $4;
			vec->z = $6;
			$$.vector = *vec; // Changed this
		}
	| IDENTIFIER 
		{
			union symbolValue value;
			enum symbolType type = getValue($1, &value);
			
			if(type == SYMBOL_VECTOR)
			{
				$$.vector = value.vector;
			}
		}
	;
	
inNum :
	// To support negative and positive numbers
	NUM { $$ = $1; }
	| '-' NUM { $$ = -$2; }
	;

%%

int main()
{
	yyparse ();
	return 0;
}

void yyerror (char const *msg) 
{
	printf ("%s \n", msg);
}

// One function to do addition, subtraction and scalar multiplication. Could possibly have moved to C++ to enable function templates.
struct Vector3 VectorCalculation(struct Vector3 v1, struct Vector3 v2, int flag, double num)
{
	struct Vector3 result;
	// 1 - Addition, 2 - Subtraction, 3 - Scalar Multiplication, 4 - Cross Product
	if (flag == 1)
	{
		// Addition, adds v(ector)'s 1 and 2 together
		printf("\t(%g, %g, %g) + (%g, %g, %g)\n", v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
		result.x = v1.x + v2.x;
		result.y = v1.y + v2.y;
		result.z = v1.z + v2.z;
		printf("\t= (%g, %g, %g)\n", result.x, result.y, result.z);
	}
	if (flag == 2)
	{
		// Subtraction, subtracts v(ector)'s 1 and two
		printf("\t(%g, %g, %g) - (%g, %g, %g)\n", v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
		result.x = v1.x - v2.x;
		result.y = v1.y - v2.y;
		result.z = v1.z - v2.z;
		printf("\t= (%g, %g, %g)\n", result.x, result.y, result.z);
	}
	
	if (flag == 3)
	{
		// Scalar Multiplcation, multiples each element in the vector by the parameter num
		printf("\t(%g, %g, %g) * %g\n", v1.x, v1.y, v1.z, num);
		result.x = v1.x * num;
		result.y = v1.y * num;
		result.z = v1.z * num;
		printf("\t= (%g, %g, %g)\n", result.x, result.y, result.z);
	}
	
	if (flag == 4)
	{
		// Cross product multiplcation
		printf("\t(%g, %g, %g) X (%g, %g, %g)\n", v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
		result.x = ((v1.y * v2.z) - (v1.z * v2.y));
		result.y = ((v1.z * v2.x) - (v1.x * v2.z));
		result.z = ((v1.x * v2.y) - (v1.y * v2.x));
		printf("\t= (%g, %g, %g)\n", result.x, result.y, result.z);
	}
	return result;
}
