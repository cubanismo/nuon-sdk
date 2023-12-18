/*
 * Test of printf functions and PC file server
 * written by Mike Fulton, VM Labs, Inc.
 *
 * You must use "-fs" option when loading this with MLOAD
 * See MAKEFILE for more info.
 *
 * Copyright (c) 2000 VM Labs, Inc.  All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc.
 */

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
FILE *pcfile;
char linebuf[300];

	printf( "\n\n\n" );
	printf( "Hello PC console!  We're going to open a file on \n" );
	printf( "the PC, read it line by line, and print it back to\n" );
	printf( "the PC console!\n\n" );
	printf( "---------------------------------------------------\n\n" );

	pcfile = fopen( "fstest.c", "r" );

	if( pcfile )
	{
		while( ! feof(pcfile) )
		{
			// read a string from PC
			fgets( linebuf, 299, pcfile );
			
			// Make sure we're null-terminated
			linebuf[299] = 0;

			// print string back to PC
			printf( "%s", linebuf );
		}
	}
	fclose(pcfile);

	printf( "\n\n\n" );
	printf( "---------------------------------------------------\n\n" );
	printf( "OK, we're done now.  You can hit \042Q\042 or Control-C on\n" );
	printf( "your PC's keyboard to break out out of the file server.\n" );
	printf( "Just ignore any error message that it prints.\n" );
	printf( "\n\n\n" );

	fflush(stdout);

	return 0;
}
