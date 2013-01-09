#include "Vector.h"

// Data structure to hold an entry in the symbol table
struct symbolNode
{
	char *name;	// Variable name
	struct Vector3f *value; // Variable value
	struct symbolNode *next; // Next entry in the symbol table
};
typedef struct symbolNode symbolEntry;

// Function prototypes
symbolEntry *findEntry (char *id);
symbolEntry* addId (char *id);

// Sets v to the value of the specified identifier
int getValue (char *id, struct Vector3f *v);
// sets the identifier to the value in v
void setValue (char *id, struct Vector3f *v);
