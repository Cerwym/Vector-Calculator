#include <stdlib.h>
#include "SymbolTable.h"

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
int getValue (char *id, struct Vector3f *v) 
{
	symbolEntry *entry = findEntry (id); // Look for identifier in symbol table
	if (entry == NULL) return 0;	// Identifier not found return 0 for false
	v->x = entry->value->x;			// Set values
	v->y = entry->value->y;
	v->z = entry->value->z;
	return 1;						// Return 1 for true
}

// Sets the value of the specified identifier to the specified value
void setValue (char *id, struct Vector3f *v) 
{
	symbolEntry *entry = findEntry (id); // Look for the specified identifier
	if (entry == NULL)		// If it wasnt found
	{
		entry = addId(id);	// Create it
	}
	entry->value->x = v->x; // Set the values
	entry->value->y = v->y;
	entry->value->z = v->z;
}