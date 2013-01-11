//
//  SymbolTable.h
//  0901632VectorCalc
//
//  Created by Peter Lockett on 11/01/2013.
//  Copyright (c) 2013 Peter Lockett. All rights reserved.
//
#include "Vector.h"

union symbolValue
{
	double scalarnum;
	struct Vector3 vector;
};

enum symbolType
{ SYMBOL_UNDECLARED = 0, SYMBOL_SCALAR = 1, SYMBOL_VECTOR = 2};

// Data structure to hold an entry in the symbol table
struct symbolNode
{
	char *name;	// Variable name
	enum symbolType type; // Variable type
	union symbolValue *value; // Variable value
	struct symbolNode *next; // Next entry in the symbol table
};
typedef struct symbolNode symbolEntry;

// Function prototypes
symbolEntry *findEntry (char *id);
symbolEntry* addId (char *id);

// Sets v to the value of the specified identifier
enum symbolType getValue (char *id, union symbolValue *v);
// sets the identifier to the value in v
void setValue (char *id, union symbolValue v, enum symbolType type);

