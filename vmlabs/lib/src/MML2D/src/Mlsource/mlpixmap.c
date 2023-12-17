
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Public Pixmap and View Calls
 * rwb Completely revised 9/25/97
 * ers Modified to use mutil sdram allocation
 *     functions if ON_MERLIN is set
 * rwb 4/14/98 - changed to new config defines
 * rwb 4/9/00 - replaced SDRAM calls with bios calls
 */
#include "m2config.h"
#include "../../nuon/mml2d.h"
#include <stdlib.h>
#include <assert.h>
#include <nuon/bios.h>
#define SDRAMLO 0x40000000
#define SDRAMHI 0x80000000

/* Calculate the size (in BITS!) of a pixel in the frame buffer.
PixType is the mmlPixType which corresponds to the first 6 Pixel Data Types (aka Pixel Map Type)
described in the DMA section. It is NOT the Pixel Mode number described in the Video section.
Combine with numBuffers to get true video requirement for each pixel.
*/ 
uint8 mlpFormatToSize( mmlPixFormat pix )
{
    static uint8 size[] = {0,4,16,8,32,32,64,16,16,16};
	assert( pix > eMinFormat && pix < eMaxFormat );
    return size[ pix  ];
}

/* Convert mmlFormat to Merlin Pixel type */
uint8 mlpFormatToType( mmlPixFormat pix )
{
	static uint8 dataType[] = {0,1,2,3,4,5,6,2,2,2};
	assert( pix > eMinFormat && pix < eMaxFormat );
	return dataType[ pix ];
}

/*** START PUBLIC FUNCTIONS  ***/
/* Set global values for address and size of memory available to app
for local dtram scratch memory, system memory, and video memory.
At this time, only local dtram values are set.
If any address is set to 0, a default value is supplied.
Call this function prior to mmlPowerUpGraphics.
If function is not called, default values are provided.
*/
void mmlMemConfig( void* localStart, int localSize,
						void* sysStart, int sysSize,
						void* vidStart, int vidSize )
{
	_localRamPtr = localStart;
	_localRamSize = localSize;	
}

/* Power up needs to fill in global HostInterface structure,
and needs to load dispatcher into appropriate mpe
*/
void mmlPowerUpGraphics( mmlSysResources* srP )
{
	textCode* sysFontName = "C:\\Fonts\\ps39c.pfr";
	textCode* sysFontLocation = (textCode*)malloc( strlen( sysFontName ) + 1 );
	if (!_localRamPtr)
	    _localRamPtr = _MemLocalScratch(&_localRamSize);
//	assert( _localRamSize >= 512 );
	strcpy( sysFontLocation, sysFontName ); 
	srP->NumFonts					= 1;
	srP->platform				= kGamePlatform;
	srP->intDataAvailDtram		= _localRamSize;
	srP->intDataAdr				= _localRamPtr;
	srP->DispatcherId			= DISPATCHER_ID;
}

/* Initialize an array of application pixmaps */
mmlStatus mmlInitAppPixmaps( mmlAppPixmap* sP, mmlSysResources* srP, int wide, int high ,
		mmlPixFormat pix, int numBuffers, void* memP )
{
	int map, size;
    assert( sP != NULL && high > 0 && wide > 0 );
    size = (high * wide * mlpFormatToSize( pix )) >> 3;
	for( map=0; map<numBuffers; ++map )
	{
		sP->dmaFlags	= wide << 16;
		sP->wide		= wide;
		sP->high		= high;
		sP->properties	= pix<<kPixShift | numBuffers<<kNBufShift | eSquare;
		sP->yccClutP	= NULL;
		if( memP == NULL )
		{
			sP->memP = (void*)malloc( size );
			if( sP->memP == NULL ) return eSysMemAllocFail;
			sP->properties |= eNeedsFreeing;
		}
		else sP->memP = (void*)((uint32)memP + map*size);
		++sP;
	}
	return eOK;
}

mmlStatus mmlInitDisplayPixmaps( mmlDisplayPixmap* sP, mmlSysResources* srP, int wide, int high ,
	mmlPixFormat pix, int numBuffers, void* memP )
{
	int map, size, transfer;
	int pixsize;
	mmlStatus stat = 0;
	int clusterval;
	void* adr = 0;

    assert( sP != NULL && 
        high > 0 && wide > 0 && (wide%8 == 0) &&
		(pix != eClut8 || wide%16 == 0 ) &&
		(pix != eClut4 || wide%32 == 0 ) &&
		(memP == NULL || (memP >= (void*)SDRAMLO && memP < (void*)SDRAMHI ) )
		    );
    pixsize = mlpFormatToSize(pix);
    size = (high * wide * pixsize) >> 3;

    /* set the cluster bit only if it's valid for this combination
       of width and pixel type */
    switch (pix) {
    case eClut4:
	clusterval = ((wide%64) == 0) ? eCluster : 0;
	break;
    case eClut8:
	clusterval = ((wide%32) == 0) ? eCluster : 0;
	break;
    case e655:
    case e655Z:
	clusterval = ((wide%16) == 0) ? eCluster : 0;
	break;
    case e888Alpha:
    case e888AlphaZ:
	clusterval = eCluster;
	break;
    default:
	clusterval = 0;
	break;
    }
	for( map=0; map<numBuffers; ++map )
	{
		if( pix == e655Z && numBuffers == 2 )
		{
			transfer = 13 + map;
			size = 3 * size/2;
		}
		else if( pix == e655Z && numBuffers == 3 )
		{
			transfer = 9 + map;
			size = 4 * size/2;
		}
		else transfer = mlpFormatToType( pix );

		sP->dmaFlags	= (wide << 13) |  ePixDma | clusterval | (transfer<<4) ; 
		sP->wide	= wide;
		sP->high	= high;
		sP->properties	= pix<<kPixShift | numBuffers<<kNBufShift | eDisplayMap | eTV;
		sP->yccClutP	= NULL;
		if( memP == NULL )
		{
			if( !( pix == e655Z && map > 0 ) ) /* allocate all first time thru loop */
			{
				adr = _MemAlloc( size, 512, 1);
				if( adr == NULL ) stat |= eMerMemAllocFail;
				else stat |= eOK;
			}
			sP->memP = adr;
			sP->properties |= eNeedsFreeing;
		}
		else
		{
			stat = eOK;
			if( pix == e655Z )
				sP->memP = memP;
			else
				sP->memP = (void*)((uint32)memP + map*size);
		}
		++sP;
	}
	return stat;
}


/* Release all memory, locks, semaphores associated with this pixmap
or array of pixmaps.  If an array was initialized with a single call,
it should be released with a single call to release.
*/
void mmlReleasePixmaps( mmlPixmap* sP, mmlSysResources* srP, int numPixmaps )
{
	int n, map;
    assert( sP != NULL );
	n = numPixmaps;
	for( map=0; map<n; ++map )
	{
		if( sP->properties & eNeedsFreeing )
		{
			int pix	= PIXFORMAT( sP->properties );
			int displayQ = sP->properties & eDisplayMap;
			if( displayQ && !(pix == e655Z && map > 0 ) )
				_MemFree( sP->memP );
			else if( !displayQ )
				free( sP->memP );
		}
		sP->memP = NULL;
		++sP;
	}
}
/* Associate a clut with a pixmap
 */
void mmlSetPixmapClut( mmlPixmap* sP, mmlColor* clutP )
{
	assert( PIXFORMAT(sP->properties) == eClut4  ||
			PIXFORMAT(sP->properties) == eClut8
			);
	sP->yccClutP = clutP;
}

