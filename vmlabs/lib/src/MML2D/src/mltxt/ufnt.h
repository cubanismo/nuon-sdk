
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* header file that defines the tables contained in 
a file that contains an unscalable (bitmap) font.
rwb 10/25/99
*/

#ifndef __UFNT_H_
#define __UFNT_H_

#include "../../nuon/mml2d.h"
#include "../mltxt/mltxtpriv.h"

#ifdef LITTLE_ENDIAN
#define SWAP32(x)   swap32(x)
#define SWAP16(x)   swap16(x)
extern void swap32(uint32 *px);
extern void swap16(uint16 *px);
#else
#define SWAP32(x)   (x)
#define SWAP16(x)   (x)
#endif

#define kConverted 0x100;

typedef struct
{
uint32			tag;
uint32			offset;
} locator;

typedef struct
{
uint32			id;
uint32			flags;
uint32			numTables;
locator			table[1];
} contentsTable;

typedef struct
{
uint32			numSizes;
uint32			firstCode;
uint32			lastCode;
uint32			sizes[1];
} infoTable;

typedef struct
{
uint32			numStrings;
locator			name[1];
} nameTable;

typedef struct
{
uint32			offset;
f12Dot4			left;
f12Dot4			right;
uint16			width;
uint16			entrySize;
} cacheEntry;

typedef struct
{
uint32			res1[2];
uint32			pointsize;
uint32			res2;
uint32			scale;
uint32			res3[5];
mmlLayoutMetrics		metrics;
cacheEntry		entry[1];
} cacheTable;

typedef struct
{
uint32			pixdata[1];
} pixTable;

typedef struct
{
contentsTable	xTab;
nameTable		nTab;
infoTable		iTab;
cacheTable		cTab[1];
pixTable		pTab;		
} ufnt;

/* private prototypes for use by mltxt lib functions */
void* ufnGetAdr( locator tab[], int numTables, uint32 id );
uint32	ufnMakeCacheTag( int size );
void ufnOff2ptr( ufnt* fP );
void ufnCapture( mmlFontContext fcP, mmlFont font );

#endif

