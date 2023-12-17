/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include <nuon/bios.h>

int main()
{
	// The "/udf" at the beginning tells it the file is on the DVD
	// The remainder is the actual pathname on the disc

	_LoadGame( "/udf/NUON/nuon.run" );

	/* Never get here */
	return 0;
}
