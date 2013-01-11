//
//  SymbolTable.c
//  0901632VectorCalc
//
//  Created by Peter Lockett on 11/01/2013.
//  Copyright (c) 2013 Peter Lockett. All rights reserved.
//
#include <stdlib.h>
#include "SymbolTable.h"
#include <string.h>

// The most recent entry in the symbol table
symbolEntry *symbolTable = NULL;

// Returns the requested entry
// or null if not found
symbolEntry *findEntry (char *id) 
{
	// Start checking at the newest entry
	symbolEntry *found = symbolTable;
	
	// when found is null weve reached the end of the table
	while (found!=NULL && strcmp(id,found->name)) 
	{
		found = found->next;
	}
	return found;
}

// Adds the specified identifier to the symbol table
symbolEntry* addId (char *id)
{
	symbolEntry *newEntry;
	newEntry = (symbolEntry*) malloc (sizeof(symbolEntry));
	newEntry->name = id;
	newEntry->value = malloc(sizeof(*newEntry->value));
	newEntry->next = symbolTable;	// set the next entry to the current newest
	symbolTable = newEntry;			// set the symbol table to this entry
	return newEntry;
}

// Returns the value of the specified identifier
enum symbolType getValue (char *id, union symbolValue *v)
{
	symbolEntry *entry = findEntry (id); // Look for identifier in symbol table
	if (entry == NULL) return 0;	// Identifier not found return 0 for false
	if (entry->type == SYMBOL_VECTOR)
	{
		v->vector.x = entry->value->vector.x;			// Set values
		v->vector.y = entry->value->vector.y;
		v->vector.z = entry->value->vector.z;
		
		return SYMBOL_VECTOR;
	}
	
	if (entry->type == SYMBOL_SCALAR)
	{
		v->scalarnum = entry->value->scalarnum;
		
		return SYMBOL_SCALAR;
	}
	
	return SYMBOL_UNDECLARED;						// Return 1 for true
}

// Sets the value of the specified identifier to the specified value
void setValue (char *id, union symbolValue v, enum symbolType type)
{
	symbolEntry *entry = findEntry (id); // Look for the specified identifier
	if (entry == NULL)		// If it wasnt found
	{
		entry = addId(id);	// Create it
	}
	entry->type = type;
	if (type == SYMBOL_SCALAR)
	{
		entry->value->scalarnum = v.scalarnum;
	}
	else if (type == SYMBOL_VECTOR)
	{
		entry->value->vector = v.vector;
	}
}
