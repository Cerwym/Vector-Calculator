%{
#include <stdio.h>
#include "SymbolTable.h"
#include "Vector.h"

int yylex ();
void yyerror (char const*);

// Prototypes for calculation functions
struct Vector3f* VectorAdd(struct Vector3f *vec1, struct Vector3f *vec2);
struct Vector3f* VectorSubtract(struct Vector3f *vec1, struct Vector3f *vec2);
struct Vector3f* ScalarMultiply(struct Vector3f *vec, double number);
%}

%union
{
	double number;
	struct Vector3f *vector3;
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
%type <vector3> vector
%type <vector3> calculation

// Production evaluation precadence
%left '-' '+'
%left '*'

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
			if($1 == 0)
			{
				// Calculation returned an error
				printf("error: Don't know what to do\n");
			}
			else
			{
				// Calculation returned ok so set the value of result
				setValue("result", $1); 
			}
		}
	// Displaying an identifier
	| DISPLAY IDENTIFIER NEWLINE 
		{ 
			struct Vector3f *vec = malloc(sizeof(*vec));
			// If we got the value of the identifier
			if(getValue($2, vec))
				printf(" = (%g, %g, %g)\n", vec->x, vec->y, vec->z);
			else
				printf("error: Couldn't find %s\n", $2);
		}
	// Setting an identifier to a calculation (which could be an identifier or user entered vector)
	| IDENTIFIER '=' calculation NEWLINE
		{ 		
			// If calculation didnt return an error
			if($3 != 0)
			{
				// If we are trying to set the keyword result
				if(!strcmp($1, "result"))
				{
					printf("error: result is a keyword and can't be assigned\n");
				}
				else
				{
					// Set the value and output what it was set to
					setValue($1, $3);
					printf("%s is now (%g, %g, %g)\n", $1, $3->x, $3->y, $3->z);
				}
			}
		}
	// Handle user only entering an integer or floating point number
	| NUM NEWLINE 
		{
			printf("Please enter a vector\n");
		}		
	// Handle trying to set a vector to an integer or floating point number
	| IDENTIFIER '=' NUM NEWLINE
		{ 		
			printf("error: Variable must be set to a vector\n");
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
	// Can be just a vector for recursion
	vector { $$ = $1; }
	// Scalar multiplication with vector first
	| calculation '*' inNum 
		{ 
			if($1 == 0) { $$ = 0; }
			else { $$ = ScalarMultiply($1, $3); }
		}
	// Scalar multiplication with scalar value first
	| inNum '*' calculation 
		{ 
			if($3 == 0) { $$ = 0; }
			else { $$ = ScalarMultiply($3, $1); }
		}
	// Vector addition
	| calculation '+' calculation 
		{ 
			if($1 == 0 || $3 == 0) { $$ = 0; }
			else { $$ = VectorAdd($1, $3);}
		}
	// Vector subtraction
	| calculation '-' calculation 
		{ 
			if($1 == 0 || $3 == 0) { $$ = 0; }
			else { $$ = VectorSubtract($1, $3); }
		}
	;

vector :
	// Vector surrounded with parenthesis
	OPENCLOSE inNum ',' inNum ',' inNum OPENCLOSE 
		{
			struct Vector3f *vec = malloc(sizeof(*vec));
			vec->x = $2;
			vec->y = $4;
			vec->z = $6;
			$$ = vec;
		}
	// Vector without parenthesis
	| inNum ',' inNum ',' inNum 
		{
			struct Vector3f *vec = malloc(sizeof(*vec));
			vec->x = $1;
			vec->y = $3;
			vec->z = $5;
			$$ = vec;
		}
	| IDENTIFIER 
		{
			struct Vector3f *vec = malloc(sizeof(*vec));
			if(getValue($1, vec))
			{
				$$ = vec;
			}
			else
			{
				$$ = 0;
				printf("Couldn't find %s\n", $1);
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

// Adds 2 vectors together, outputs, then returns the result
struct Vector3f* VectorAdd(struct Vector3f *vec1, struct Vector3f *vec2)
{
	struct Vector3f *result = malloc(sizeof(*result));
	printf("\t(%g, %g, %g) + (%g, %g, %g)\n", vec1->x, vec1->y, vec1->z, vec2->x, vec2->y, vec2->z);
	result->x = vec1->x+vec2->x;
	result->y = vec1->y+vec2->y;
	result->z = vec1->z+vec2->z;
	printf("\t= (%g, %g, %g)\n", result->x, result->y, result->z);
	return result;
}

// subtracts 2 vectors, outputs, then returns the result
struct Vector3f* VectorSubtract(struct Vector3f *vec1, struct Vector3f *vec2)
{
	struct Vector3f *result = malloc(sizeof(*result));
	printf("\t(%g, %g, %g) - (%g, %g, %g)\n", vec1->x, vec1->y, vec1->z, vec2->x, vec2->y, vec2->z);
	result->x = vec1->x-vec2->x;
	result->y = vec1->y-vec2->y;
	result->z = vec1->z-vec2->z;
	printf("\t= (%g, %g, %g)\n", result->x, result->y, result->z);
	return result;
}

// Performs scalar multiplication, outputs, then returns the result
struct Vector3f* ScalarMultiply(struct Vector3f *vec, double number)
{
	struct Vector3f *result = malloc(sizeof(*result));
	printf("\t(%g, %g, %g) * %g\n", vec->x, vec->y, vec->z, number);
	result->x = vec->x*number;
	result->y = vec->y*number;
	result->z = vec->z*number;
	printf("\t= (%g, %g, %g)\n", result->x, result->y, result->z);
	return result;
}
