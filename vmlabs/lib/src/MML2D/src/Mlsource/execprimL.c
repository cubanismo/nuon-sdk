
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* rwb 7/1/99
This is the bottleneck that connects the mml API (or another API) 
to MRP's.  In some cases the connection is simply a function call.
In other cases, it involves sending comm bus packets and creating
parameter blocks in shared memory.
*/

#include "m2config.h"
//#include <nuon/m2pub.h>
#include "../../nuon/mml2d.h"
#include "../../nuon/mrpcodes.h"
#include <nuon/bios.h>
#include <nuon/comm.h>
#include <nuon/cache.h>
#include <stddef.h>
#include <assert.h>
#include <stdlib.h>

#if( USE_DISPATCHER == 0 )

typedef int mrpStatus;
typedef mrpStatus (*mrpFunc)(uint32 a, void* b, int c, int d );

extern mrpStatus SdramFill( );
extern mrpStatus BiCopy( );
extern mrpStatus CopUnClut( );
extern mrpStatus CopSDClut( );
extern mrpStatus CopyTile8( );
extern mrpStatus CopyTileAll( );
extern mrpStatus FillClut( );
extern mrpStatus CopySDRAM();
extern mrpStatus Copy32to16( );
extern mrpStatus CopyRectFast( );
extern mrpStatus CopyRect16( );
extern mrpStatus CopyRGBFast( );
extern mrpStatus UnImp( );

int	mrpProc[ ] [2]= {
	{(int)SdramFill, eSdramFill },
	{(int)CopySDRAM, eDCopy },	
	{(int)BiCopy, eBiCopy },
	{(int)CopUnClut, eCopyToClut },
	{(int)CopSDClut, eCopySDClut },
	{(int)CopyTile8, eCopyTile8 },
	{(int)CopyTileAll, eCopyTileAll },
	{(int)FillClut, eFillClut },
	{(int)CopyRectFast, eCopyRectFast }, 
	{(int)CopyRGBFast, eCopyRGBFast }, 
	{(int)Copy32to16, eCopy32 }, 
	{(int)CopyRect16, eCopyRect16 }, 
	{(int)UnImp, 0xFFFF}
};

#endif

int findAddress( int tab[][2], int index )
{
	int j=0;
	do
	{
		if( tab[j][1] == index ) return tab[j][0];
		if( tab[j][1] == 0xFFFF ) return tab[j][0];
	}while( ++j );
	return 0;
}

/* Version 2 to Create a environs variable to pass to mrp's.
 * rwb 9/27/01
 * Need more bits to describe Aries3 address space
 * 13-0 : vector offset of beginning of graphics tile memory
 * 27-14 : size of graphics tile memory (divided by 128 )
 * 28	: l => load parameter block into local memory
*/

uint32 makeEnvirons( void* address, int amount, int load )
{
	uint32 env = ((int)address) - 0x20100000;
	env >>= 4;
	amount >>= 4;
	env |= ((amount-1)<< 14 );
	if( load )
		env |= (1<<28);
	return env;
}


/* Create a environs variable to pass to mrp's.
 *  8-0 : vector offset of beginning of graphics tile memory
 * 13-9 : size of graphics tile memory (divided by 128 )
 * 14	: l => load parameter block into local memory

#define kReadParBlock 0x4000
uint32 makeEnvirons( void* address, int amount, int load )
{
	uint32 env = ((int)address) - 0x20100000;
	env >>= 4;
	amount >>= 7;
	env |= ((amount-1)<< 9 );
	if( load )
		env |= kReadParBlock;
	return env;
}	
*/
/* Cause an mml primitive rendering module to be executed.
 * Different versions are required for different platforms.
 * All take same API.
 */
/* Shared Memory Platform.
 * Merlin can read Host Memory, but address must be translated.
 * Make Com Packet containing:
 	 	merlin address of primitive code in Packet[0]
		merlin address of parameter block in Packet[1]
		optional argument in Packet[2]
		optional argument in Packet[3]
 * Send to Merlin Dispatch MPE
 * Assume Merlin Primitive will DMA par block into MPE.
 */
mmlStatus mmlExecutePrimitive(mmlGC* gcP, uint32 prim, void* paramBlockP,
	 int parSize, uint32 option2, uint32 option3 )
#if( USE_DISPATCHER == 1 )
{
	extern void _DCacheSync();
	extern void _comm_send( long p0, long p1, long p2, long p3, int target );
	long ack[4];
		int info;
		_DCacheSync();
	   	_comm_send( prim,
		(uint32)paramBlockP,
		option2,
		option3,
			gcP->sysResP->DispatcherId );
		_CommRecvInfo(&info, ack );
	assert( ack[0] == prim && ack[1] == (long)paramBlockP ); 
		if( prim != eExecSequence ) free( paramBlockP );
		return eOK;
}
#else
{
	extern void _DCacheSync();
	mrpFunc doit = (mrpFunc)findAddress( mrpProc, prim );
	uint32 environs;

	/* _localRamPtr and _localRamSize were set up by
	   PowerUpGraphics */
	environs = makeEnvirons( _localRamPtr, _localRamSize, 0 );
	if( prim >= eNoParBlockStart && prim <= eNoParBlockEnd )
		doit( environs, paramBlockP, option2, option3 );
	else
	{
		_DCacheSync();
/* used only to test effect of small caches
Set the size of IRAM and DTRAM cache to be 1K
asm( "st_s #1, dcachectl	"::);
asm( "st_s #1, icachectl	"::);
*/		
		doit( environs, paramBlockP, option2, option3 );
		free( paramBlockP );
	}
	return eOK;	
}
#endif

