//
//  NewSymbolTable.h
//  0901632VectorCalc
//
//  Created by Peter Lockett on 11/01/2013.
//  Copyright (c) 2013 Peter Lockett. All rights reserved.
//

#ifndef _901632VectorCalc_NewSymbolTable_h
#define _901632VectorCalc_NewSymbolTable_h

#include "Vector.h"

// Data structure to hold an entry in the symbol table
struct symbolNode
{
	char *name;	// Variable name
	struct Vector3 *value; // Variable value
	struct symbolNode *next; // Next entry in the symbol table
};
typedef struct symbolNode symbolEntry;

// Function prototypes
symbolEntry *findEntry (char *id);
symbolEntry* addId (char *id);

// Sets v to the value of the specified identifier
int getValue (char *id, struct Vector3 *v);
// sets the identifier to the value in v
void setValue (char *id, struct Vector3 *v);


#endif
