
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* mmlSequence functions
 * rwb 6/25/99
 * A simple method of capturing a series of mrp command
 * blocks, and sending the sequence as a single mrp to
 * be executed.
 */
 
#include "../mrplib/parblock.h"
//#include <nuon/m2pub.h>
#include "../../nuon/mml2d.h"
#include "../../nuon/mrpcodes.h"
#include <assert.h>
#include <stddef.h>
#include <stdlib.h>


/* Allocate a vector of numCmds MrpCommand blocks. 
Set gc->sequence to this sequence.
Return eOK or eSysMemAllocFail
*/
mmlStatus mmlOpenSeq( mmlGC* gcP, mmlSequence* seqP, int numCmds )
{
	assert( seqP != NULL && numCmds >= 0 );
	if( numCmds == 0 ) numCmds = 8;
	seqP->cmdP = malloc( numCmds * sizeof( MrpCommand ));
	if( seqP->cmdP == NULL ) return eSysMemAllocFail;
	seqP->maxCommands = numCmds;
	seqP->numCommands = 0;
	gcP->sequence = seqP;
	return eOK;
}
/* Open an mmlsequence to append (up to numMoreCmds) additional mrpcommands.
   Set gc->sequence to this sequence.
   Possibly get more memory for command vector.
	Return eOK or eSysMemAllocFail
*/
mmlStatus mmlReopenSeq( mmlGC* gcP, mmlSequence* seqP, int numMoreCmds )
{
	int newMax;
	assert( seqP != NULL && numMoreCmds >= 0 && seqP->cmdP != NULL );
	newMax = seqP->numCommands + numMoreCmds;
	if( newMax > seqP->maxCommands )
	{
		MrpCommand* temp = realloc(seqP->cmdP, newMax * sizeof( MrpCommand ));	
		if( temp == NULL ) return eSysMemAllocFail;
		seqP->cmdP = temp;
		seqP->maxCommands = newMax;
	}
	gcP->sequence = seqP;
	return eOK;
}
/* Set gcP->sequence to NULL, so that future mrp commands
 * are directly executed, rather than captured in sequence.
 * Command sequence is retained for future play.
 * Compare with Release.
 */
void mmlCloseSeq( mmlGC* gcP, mmlSequence* seqP )
{
	assert( gcP->sequence == seqP );
	gcP->sequence = NULL;
}
/* Release memory for series of mrp commands.
 * If sequence is currently open, close it.
 */
void mmlReleaseSeq( mmlGC* gcP, mmlSequence* seqP )
{
	int j;
	assert( seqP != NULL && seqP->cmdP != NULL );
	for( j=0; j<seqP->numCommands; ++j )
	{
		MrpCommand* temp = (MrpCommand*)seqP->cmdP + j; 
		free( temp->parBlockAdr );
	}
	free( seqP->cmdP );	
	if( gcP->sequence == seqP )
		gcP->sequence = NULL;
	seqP->cmdP = NULL;
	seqP->maxCommands = 0;
}	
void mmlExecuteSeq( mmlGC* gcP, mmlSequence* seqP )
{
	mmlExecutePrimitive( gcP, eExecSequence, seqP->cmdP,
	 	seqP->numCommands * sizeof( MrpCommand ), seqP->numCommands, 0 );
}

mmlStatus SeqAddCmd( mmlSequence* seqP, long funcode, long parBlockP,
	long arg2, long arg3 )
{
	long* ptr;
	if( seqP->numCommands >= seqP->maxCommands )
	{
		int newMax = seqP->maxCommands + 8;
		MrpCommand* temp = realloc(seqP->cmdP, newMax * sizeof( MrpCommand ));
		if( temp == NULL ) return eSysMemAllocFail;
		seqP->cmdP = temp;
		seqP->maxCommands = newMax;
	}
	ptr = (long*)((uint8*)seqP->cmdP + seqP->numCommands * sizeof( MrpCommand ));
	*ptr++ = funcode;
	*ptr++ = parBlockP;
	*ptr++ = arg2;
	*ptr++ = arg3;	
	++seqP->numCommands;
	return eOK;
}










