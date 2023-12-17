/*
 * 
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdlib.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>

#include "dmacalls.h"

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void odma_command(void *cmd)
{
register volatile long *dcachestatus = 	(long *)0x20500FF8;
register volatile long *odmactrl = 	(long *)0x20500500;
register long *odmacptr = 			(long *)0x20500510;

	while( *dcachestatus & 0xF0000000 );	// Make sure we don't hit 
											// DCACHE / ODMA bug
	
	while( *odmactrl & 0x0000001F);			// Wait for PENDING and BUSY bits to clear
	
	*odmacptr = (long)cmd;					// Issue command
}

void mdma_command(void *cmd)
{
register volatile long *mdmactrl = 	(long *)0x20500600;
register long *mdmacptr = 			(long *)0x20500610;

	while( *mdmactrl & 0x00000010 );		// Wait for PENDING and BUSY bits to clear
	*mdmacptr = (long)cmd;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void odma_clear(void)
{
register volatile long *odmactrl = 	(long *)0x20500500;

	while( *odmactrl & 0x0000001F );
}

void mdma_clear(void)
{
register volatile long *mdmactrl = 	(long *)0x20500600;

	while( *mdmactrl & 0x0000001F );
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int odma_status(void)
{
register volatile long *odmactrl = 	(long *)0x20500500;

	return( *odmactrl & 0x0000000F );
}

int mdma_status(void)
{
register volatile long *mdmactrl = 	(long *)0x20500600;

	return( *mdmactrl & 0x0000000F );
}


