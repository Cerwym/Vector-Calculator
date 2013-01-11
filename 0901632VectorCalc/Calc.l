
digit [0-9]
letter [a-zA-Z]

%{
	#include <stdio.h>
	#include "y.tab.h"

	void yyerror (char const*);
%}

%%
[dD]isplay { return DISPLAY; }

[(){}\[\]] { return OPENCLOSE; }

	/* Matches an integer or floating point number */
{digit}+("."{digit}*)?	{ 
							sscanf (yytext, "%lf", &yylval.number);
							return NUM;
						}
	
	/* Matches an identifier name starting with letters and optional numbers */
{letter}+{digit}*		{ 
							yylval.string = (char*)malloc (yyleng+1);
							strcpy (yylval.string, yytext);
							return IDENTIFIER; 
						}

	/* Matches an identifier name starting with numbers with compulsory letters */
{digit}+{letter}+		{
							yylval.string = (char*)malloc (yyleng+1);
							strcpy (yylval.string, yytext);
							return IDENTIFIER; 
						}
	
	/* Needed for calculations and vector parsing */
[,+-=*]					{	return *yytext;	}

	/* Ignore white space and tabs */
[ \t]	;

	/* Indicates end of an expression */
\n						{	return NEWLINE;	}

.						{	yyerror ("Invalid character found.");	}

%%

int yywrap() {
    return 1;
}
