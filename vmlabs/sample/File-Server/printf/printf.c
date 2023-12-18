/*
 * Test of printf functions and PC file server
 *
 * See MAKEFILE for info on using MLOAD file server option
 *
 * Copyright (c) 2000 VM Labs, Inc.  All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc.
 */

#include <stdio.h>
#include <stdlib.h>

int main(void)
{
	printf( "Hello PC console!  This is the NUON file server.\n" );
	fflush(stdout);
	return 0;
}
