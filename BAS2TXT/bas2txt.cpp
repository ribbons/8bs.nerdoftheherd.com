/***
/*****************************************************************************/
/* Basic to Text -  Liam Corner March 1992                                   */
/*                                                                           */
/* Converts a tokenised BBC BASIC V file into a text file                    */
/* Does not convert GOTO (or GOSUB) line numbers, but nobody uses those      */
/* anymore, do they :-)                                                      */
/* Please correct any silly mistakes/omissions                               */
/*****************************************************************************


Submitted-by: zenith@dcs.warwick.ac.uk

Here's a little C program I knocked up to convert tokenised BASIC programs to
text files.  They are already available for Archies, but this one is machine
independent.  It can be quite useful for looking at downloaded files on UNIX
or other networked machines.  Basically one HUGE switch construct.  Hope
somebody finds it useful.

	Liam Corner
	csubt@csv.warwick.ac.uk
	zenith@dcs.warwick.ac.uk

 1.01 - added -n switch
 1.5  - by Robert Schmidt (March 1997).
		Using C++ iostreams.
		Loops and procedures indentation (-i option)
		Adding space after most keywords (-s option)
		Reading file name arguments instead of stdin.
		Proper output of all line numbers (thanks to Dan Little!).
		Decent output of "strings", with control characters as "[0xnn]".
 1.6 -	by Mark Usher (17.08.1997)
		Changed to BASIC I / II
		Changed the keyword token routine
		Output now goes to file + ".txt" instead of to the console.
 1.7 -	by Mark Usher (07.02.1999)
		Various improvements, including:
		stopping "double spaces" when the pretty space option is being used.
		changes to the command line parameters
		addition of explictly using BASIC I or BASIC II
		addition of help parameter
		some general tidying up.
***/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <fstream.h>
#include <strstrea.h>
#include <iomanip.h>

ifstream fin;
ofstream fout;

char buffer[1000];
strstream line(buffer, 1000, ios::in);

int indent_level = 0,	/* default indentation level */
	line_number(),		
    prev_indent = 0,
	linenumber = 0,
	pretty_post_space = 0,
	token_set = 2,				/* default token keyword set to be used */
	display_line_numbers=1,		/* default for the -n option is ON ie display line numbers */
	do_pretty_spaces=0,			/* default for the -s option is OFF ie no pretty spaces */
	do_indentation=0;			/* default for the -i option is OFF ie no indentation */

/* BASIC I Token Definitions &80 - &FF */
char BASIC_I_TOKENS[128][10] = 
	{ /*		 0 / 8		1 / 9		2 / A		3 / B		4 / C		5 / D		6 / E		7 / F       */
	  /* 0x80 */ "AND",		"DIV",		"EOR",		"MOD",		"OR",		"ERROR",	"LINE",		"OFF",
	  /* 0x88 */ "STEP",	"SPC",		"TAB(",		"ELSE",		"THEN",		"",			"",			"PTR",
	  /* 0x90 */ "PAGE",	"TIME",		"LOMEM",	"HIMEM",	"ABS",		"ACS",		"ADVAL",	"ASC",
	  /* 0x98 */ "ASN",		"ATN",		"BGET",		"COS",		"COUNT",	"DEG",		"ERL",		"ERR",
	  /* 0xA0 */ "EVAL",	"EXP",		"EXT",		"FALSE",	"FN",		"GET",		"INKEY",	"INSTR(", 
	  /* 0xA8 */ "INT",		"LEN",		"LN",		"LOG",		"NOT",		"OPENIN",	"OPENOUT",	"PI",
	  /* 0xB0 */ "POINT(",	"POS",		"RAD",		"RND",		"SGN",		"SIN",		"SQR",		"TAN",
	  /* 0xB8 */ "TO",		"TRUE",		"USR",		"VAL",		"VPOS",		"CHR$",		"GET$",		"INKEY$",
	  /* 0xC0 */ "LEFT$(",	"MID$(",	"RIGHT$(",	"STR$",		"STRING$(", "EOF",		"AUTO",		"DELETE", 
	  /* 0xC8 */ "LOAD",	"LIST",		"NEW",		"OLD",		"RENUMBER",	"SAVE",		"",			"PTR",
	  /* 0xD0 */ "PAGE",	"TIME",		"LOMEM",	"HIMEM",	"SOUND",	"BPUT",		"CALL",		"CHAIN",
	  /* 0xD8 */ "CLEAR",	"CLOSE",	"CLG",		"CLS",		"DATA",		"DEF",		"DIM",		"DRAW",
	  /* 0xE0 */ "END",		"ENDPROC",	"ENVELOPE",	"FOR",		"GOSUB",	"GOTO",		"GCOL",		"IF",
	  /* 0xE8 */ "INPUT",	"LET",		"LOCAL",	"MODE",		"MOVE",		"NEXT",		"ON",		"VDU",
	  /* 0xF0 */ "PLOT",	"PRINT",	"PROC",		"READ",		"REM",		"REPEAT",	"REPORT",	"RESTORE",
	  /* 0xF8 */ "RETURN",	"RUN",		"STOP",		"COLOUR",	"TRACE",	"UNTIL",	"WIDTH",	"" };


/* BASIC II Token Definitions &80 - &FF
OPENIN is now &BE
new keyword OPENUP at &AD replacing OPENIN in BASIC I
new keyword OSCLI at &FF
*/
	
char BASIC_II_TOKENS[128][10] = 
	{ /*		 0 / 8		1 / 9		2 / A		3 / B		4 / C		5 / D		6 / E		7 / F       */
	  /* 0x80 */ "AND",		"DIV",		"EOR",		"MOD",		"OR",		"ERROR",	"LINE",		"OFF",
	  /* 0x88 */ "STEP",	"SPC",		"TAB(",		"ELSE",		"THEN",		"",			"OPENIN",	"PTR",
	  /* 0x90 */ "PAGE",	"TIME",		"LOMEM",	"HIMEM",	"ABS",		"ACS",		"ADVAL",	"ASC",
	  /* 0x98 */ "ASN",		"ATN",		"BGET",		"COS",		"COUNT",	"DEG",		"ERL",		"ERR",
	  /* 0xA0 */ "EVAL",	"EXP",		"EXT",		"FALSE",	"FN",		"GET",		"INKEY",	"INSTR(", 
	  /* 0xA8 */ "INT",		"LEN",		"LN",		"LOG",		"NOT",		"OPENUP",	"OPENOUT",	"PI",
	  /* 0xB0 */ "POINT(",	"POS",		"RAD",		"RND",		"SGN",		"SIN",		"SQR",		"TAN",
	  /* 0xB8 */ "TO",		"TRUE",		"USR",		"VAL",		"VPOS",		"CHR$",		"GET$",		"INKEY$",
	  /* 0xC0 */ "LEFT$(",	"MID$(",	"RIGHT$(",	"STR$",		"STRING$(", "EOF",		"AUTO",		"DELETE", 
	  /* 0xC8 */ "LOAD",	"LIST",		"NEW",		"OLD",		"RENUMBER",	"SAVE",		"",			"PTR",
	  /* 0xD0 */ "PAGE",	"TIME",		"LOMEM",	"HIMEM",	"SOUND",	"BPUT",		"CALL",		"CHAIN",
	  /* 0xD8 */ "CLEAR",	"CLOSE",	"CLG",		"CLS",		"DATA",		"DEF",		"DIM",		"DRAW",
	  /* 0xE0 */ "END",		"ENDPROC",	"ENVELOPE",	"FOR",		"GOSUB",	"GOTO",		"GCOL",		"IF",
	  /* 0xE8 */ "INPUT",	"LET",		"LOCAL",	"MODE",		"MOVE",		"NEXT",		"ON",		"VDU",
	  /* 0xF0 */ "PLOT",	"PRINT",	"PROC",		"READ",		"REM",		"REPEAT",	"REPORT",	"RESTORE",
	  /* 0xF8 */ "RETURN",	"RUN",		"STOP",		"COLOUR",	"TRACE",	"UNTIL",	"WIDTH",	"OSCLI" };

#ifdef WIN32
	char *help_string=
	"\nBBC BASIC I & II to ASCII text conversion. v1.07 32bit\n\n" \
	"Syntax: BAS2TXT [/n /s /i] [/1 or /2] [filename]\n\n" \
	"/n : Output without line numbers\n" \
	"/s : Output with extra spacing\n" \
	"/i : Output with indentation\n" \
	"/1 and /2 may be used to force the program to use either the BASIC I\n" \
	"or the BASIC II token set. Default is BASIC II.\n";
#else
	char *help_string=
	"\nBBC BASIC I & II to ASCII text conversion. v1.07 16bit\n\n" \
	"Syntax: BAS2TXT [/n /s /i] [/1 or /2] [filename]\n\n" \
	"/n : Output without line numbers\n" \
	"/s : Output with extra spacing\n" \
	"/i : Output with indentation\n" \
	"/1 and /2 may be used to force the program to use either the BASIC I\n" \
	"or the BASIC II token set. Default is BASIC II.\n";
#endif
	
int getchr()
{
	unsigned char ch;
	fin.read(&ch,1);
	return ch;
}

int line_number ()
{
    int inChar=getchr(), temp;
    if ((inChar != EOF) && (inChar != 255))
	{
		temp=getchr();
		getchr();
		if (display_line_numbers)
			linenumber = (inChar<<8)+temp;
		return (1);
    }
    else
		return (0);
}

void inline_line_number ()
{
	int num1 = getchr(), num2 = getchr(), num3 = getchr();
    int result = num2 - 0x40;
	switch(num1) {
		case 0x54: break;
		case 0x44: result += 64; break;
		case 0x74: result += 128; break;
		case 0x64: result += 192; break;
	}
	result += (num3 - 0x40) * 256;
	line << result;
}

void keyword (int token)
{

	switch (token_set)
	{
	case 1 :
		line << BASIC_I_TOKENS[token-128];
		break;
	case 2 :
		line << BASIC_II_TOKENS[token-128];
		break;
	default :
		line << BASIC_II_TOKENS[token-128];
		break;
	}

	switch (token)
	{
		case 0x8a : pretty_post_space = 0;	break;	/* TAB		
													   REM		
													   USR		
													   UNTIL
													   AND
													   CALL
													   ENDPROC
													   LOCAL
													   REPEAT
													   CHR$    */
		case 0xA4 : pretty_post_space = 0; 
					indent_level--;			break;	/* FN		*/
		case 0xA7 : pretty_post_space = 0;	break;	/* INSTR(	*/
		case 0xB0 : pretty_post_space = 0;	break;	/* POINT(	*/
		case 0xC0 : pretty_post_space = 0;	break;	/* LEFT$(	*/
		case 0xC1 : pretty_post_space = 0;	break;	/* MID$(	*/
		case 0xC2 : pretty_post_space = 0;	break;	/* RIGHT$(	*/
		case 0xC4 : pretty_post_space = 0;	break;	/* STRING$(	*/
		case 0xF2 : pretty_post_space = 0;	break;	/* PROC		*/
		case 0xDD : indent_level++;			break;	/* DEF		*/
		case 0xE3 : indent_level++;			break;	/* FOR		*/
		case 0xF5 : indent_level++;			break;	/* REPEAT	*/
		case 0xE1 : indent_level--;			break;	/* ENDPROC	*/
		case 0xED : indent_level--;			break;	/* NEXT		*/
		case 0xFD : indent_level--;			break;	/* UNTIL	*/
		case 0x8D : inline_line_number();	break;	/* signifies the next 3 bytes are a reference to a line number */
	}

}

void convert_file()
{
	int inChar = getchr();

	while (fin && line_number()) {
		int quotes = 0;
		do {
			inChar = getchr();
			if (inChar == '"')
				quotes = !quotes;

			if (inChar !=32 && pretty_post_space==1)				/* add a post space if one is required */
				line << " ";										/* by the last keyword that was output */

			pretty_post_space = 0;

			if (inChar==13 || !fin)
			{
				line << '\0';
				if (display_line_numbers)
				{
					fout << setw(5) << linenumber;
					if (do_pretty_spaces)							/* add a space after the line number if the */
						fout << " ";								/* pretty spaces -s option is on */
				}

				if (do_indentation)
				{
					int indent = indent_level;
					if (indent_level > prev_indent)
						indent = prev_indent;
					for (int i=0;i<indent;i++)
						fout << "  ";
				}

				fout << line.str() << endl;
				line.seekp(0, ios::beg);
				line.seekg(0, ios::beg);
				line.clear();
				prev_indent = indent_level;
			}
			else if (inChar<32)
				line << " [0x"<< hex << inChar << dec << "] ";		/* control character so output it in hex and dec */

			else if (inChar>126 && !quotes)
			{
				pretty_post_space = do_pretty_spaces && 0x01;		/* set a pretty post space if the option is set
																	   This can be reset to 0 in the keyword function */
				keyword(inChar);									/* get the keyword for the token held in inChar */
			}
			else
				line << char(inChar);
		}
		while (fin && inChar != 13);
	}

}

void main (int argc,char *argv[])
  {
    int i;
	char inFile[255];
	char outFile[255];

	if (argc == 1 )													/* no arguemnts have been supplied */
	{
		printf(help_string);										/* display the default help screen */
		exit(0);
	}

		
	if ( strcmp (argv[1], "/?" ) == 0)								/* display syntax only */
	{
		printf(help_string);										/* display the default help screen */
		exit(0);
	}
	
	for (i = 1; i < argc; i++)
	{
		if (argv[i][0] == '/' )										/* parameter */
		{																
			switch (toupper( argv[i][1]))
			{
			case 'N':												/* /n display line numbers */
				display_line_numbers=0;
				break;
			case 'S' :
				do_pretty_spaces=1;									/* /s pretty spaces */
				break;
			case 'I' :
				do_indentation=1;									/* /i program listing indentation */
				break;
			case '1' :
				token_set=1;										/* /1 keyword token set for BASIC I */
				break;
			case '2' :
				token_set=2;										/* /2 keyword token set for BASIC II */
				break;
			default :
				break;
			}
			argv[i][0] = '\0';										/* Clear arguement */
		}
		else														/* must be the filename */
			strcpy(inFile, argv[i]);
	}

	strcpy(outFile, inFile);
	strcat(outFile, ".txt");
	
	fin.open(inFile, ios::in | ios::nocreate | ios::binary);
	if (!fin) {
		cerr << "Cannot open " << inFile << ".\n\n";				/* check that the source file is valid */
		exit(1);
	}

	fout.open(outFile, ios::out);
	if (!fout) {
		cerr << "File " << outFile << " is invalid.\n\n";			/* check that the target file is valid */
		exit(1);
	}

	convert_file();
    
	fin.close();
	fout.close();
}

