
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Auxiliary functions for managing unscaleable bitmap font (ufnt)
files.
rwb 10/25/99
*/

#include "../../nuon/mml2d.h"
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "ufnt.h"
#include "../mltxt/mltxtpriv.h"

#ifdef LITTLE_ENDIAN

/* ByteSwapUFnt - byte swap a ufnt file */
static void ByteSwapUFnt( ufnt* fP )
{
    locator* locP;
    locator* loc2P;
    nameTable* nameP;
    infoTable* infoP;
    cacheTable* cacheP;
    cacheEntry* entryP;
    uint32 *intP;
    int cnt,cnt2;
    /* swap32(&fP->xTab.id); already swapped before call */
    swap32(&fP->xTab.flags);
    swap32(&fP->xTab.numTables);
    locP = fP->xTab.table;
    cnt = fP->xTab.numTables;
    while (--cnt >= 0) {
        swap32(&locP->tag);
        swap32(&locP->offset);
        switch (locP->tag) {
        case 'NAME':
            nameP = (nameTable*)((char *)fP + 4 * locP->offset);
            swap32(&nameP->numStrings);
            loc2P = nameP->name;
            cnt2 = nameP->numStrings;
            while (--cnt2 >= 0) {
                swap32(&loc2P->tag);
                swap32(&loc2P->offset);
                ++loc2P;
            }
            break;
        case 'INFO':
            infoP = (infoTable*)((char *)fP + 4 * locP->offset);
            swap32(&infoP->numSizes);
            swap32(&infoP->firstCode);
            swap32(&infoP->lastCode);
            intP = infoP->sizes;
            cnt2 = infoP->numSizes;
            while (--cnt2 >= 0) {
                swap32(intP);
                ++intP;
            }
            break;
        case 'BITS':
            break;
        case 'STYL':
            break;
        default:
            if ((locP->tag & 0xffff0000) == ('C0xx' & 0xffff0000)) {
                cacheP = (cacheTable*)((char *)fP + 4 * locP->offset);
                swap32(&cacheP->pointsize);
                swap32(&cacheP->scale);
                swap32(&cacheP->metrics.columnHeight);
                swap32(&cacheP->metrics.base);
                swap32(&cacheP->metrics.ascent);
                swap32(&cacheP->metrics.descent);
                swap32(&cacheP->metrics.maxWidth);
                swap32(&cacheP->metrics.ttPointSize);
                swap32(&cacheP->metrics.firstCharCode);
                swap32(&cacheP->metrics.lastCharCode);
                swap32(&cacheP->metrics.numCharacters);
                entryP = cacheP->entry;
                cnt2 = cacheP->metrics.numCharacters;
                while (--cnt2 >= 0) {
                    swap32(&entryP->offset);
                    swap16(&entryP->left);
                    swap16(&entryP->right);
                    swap16(&entryP->width);
                    swap16(&entryP->entrySize);
                    ++entryP;
                }
            }
            break;
        }
        ++locP;
    }
}

/* swap32 - byte swap a 32 bit value */
void swap32( uint32 *px )
{
    *px = ((*px << 24) & 0xff000000)
        | ((*px <<  8) & 0x00ff0000)
        | ((*px >>  8) & 0x0000ff00)
        | ((*px >> 24) & 0x000000ff);
}

/* swap16 - byte swap a 16 bit value */
void swap16( uint16 *px )
{
    *px = ((*px << 8) & 0xff00)
        | ((*px >> 8) & 0x00ff);
}

#endif

/* return address of table whose tag == id
Assumes locator offsets have already been converted to pointers.
*/
void* ufnGetAdr( locator tab[], int numTables, uint32 id )
{
	while( numTables-- > 0 )
	{
		if( tab[numTables].tag == id )
			return (void*)tab[numTables].offset;
	}
	return NULL;
}
/* make a cache table tag for a specific size */
uint32	ufnMakeCacheTag( int size )
{
	uint32 tag = 'C';
	tag = (tag<<8) | '0';
	assert( (size & 0xFFFF0000) == 0 );
	tag = (tag<<16) | size;
	return tag;
}

/*
 Convert a ufnt file (containing offsets) to a NUON
glyphcache (containing pointers) at the same address.
*/
void ufnOff2ptr( ufnt* fP )
{
	int nTables, j, byteOffset, numSizes, numEntries;
	nameTable* nameP;
	infoTable* infoP;
	cacheTable* cacheP;
	pixTable* pixP;

#ifdef LITTLE_ENDIAN
    ByteSwapUFnt( fP );
#endif
    
    assert( fP->xTab.flags == 1 );
	nTables = fP->xTab.numTables;
	for( j=0; j<nTables; ++j )
	{
		int byteOffset = 4*fP->xTab.table[j].offset;
		fP->xTab.table[j].offset = ((uint32)fP) + byteOffset; 
	}
	nameP = ufnGetAdr( fP->xTab.table, nTables, 'NAME' );
	assert( nameP != NULL );
	for( j=0; j<nameP->numStrings; ++j )
	{
		byteOffset = 4*nameP->name[j].offset;
		nameP->name[j].offset = ((uint32)nameP) + byteOffset ;
	}
	infoP = ufnGetAdr( fP->xTab.table, nTables, 'INFO');
	assert( infoP != NULL );
	pixP = ufnGetAdr( fP->xTab.table, nTables, 'BITS');
	numSizes = infoP->numSizes;
	numEntries = infoP->lastCode - infoP->firstCode + 1;
	while( numSizes-- > 0 )
	{
		int size = infoP->sizes[numSizes];
		uint32 tag = ufnMakeCacheTag( size );
		cacheP = ufnGetAdr( fP->xTab.table, nTables, tag );
		assert( cacheP != NULL );
		for(j=0; j<numEntries; ++j )
		{
			byteOffset = 4*cacheP->entry[j].offset;
			cacheP->entry[j].offset = ((uint32)pixP) + byteOffset;
		}
	}
	fP->xTab.flags |= kConverted;
}

/* WARNING!!!
   The functions below have not been made host byte order independant
*/

/* utility functions to capture existing NUON caches (e.g. ones 
created by rendering T2K fonts) and write them out as a
ufnt file.
*/

/* Allocate space for and create a contents table for a ufnt file. */
static int makeContents(int nameSize, int numSizes, int sizes[], int numChars, uint32** tableP )
{
	int size = sizeof( contentsTable ) + (2 + numSizes)*sizeof( locator );
	uint32* tp = calloc( size, 1 );
	uint32 prefix, offset, csize;
	int j;
	offset = size/4;
	*tableP = tp;
	*tp++ = 'NUON';
	*tp++ = 1;
	*tp++ = 3 + numSizes;
	*tp++ = 'NAME';
	*tp++ = offset;
	offset += (nameSize/4);
	*tp++ = 'INFO';
	*tp++ = offset;
	offset += (sizeof( infoTable ) + (numSizes - 1)*sizeof( uint32 ) )/4;
	/* Now do cache tables */
	prefix = 'C0'<<16;
	csize = ( sizeof( cacheTable ) + (numChars - 1)*sizeof( cacheEntry ) )/4;
	for( j=0; j<numSizes; ++j )
	{
		*tp++ = prefix | sizes[j];
		*tp++ = offset;
		offset += csize;
	}
	*tp++ = 'BITS';
	*tp++ = offset;
	return 4*( tp - *tableP );
}

/* Make a name table that only has a font name and a style name */
static int makeName( textCode* fnam, textCode* snam, uint32** tableP )
{
	int size1 = (2*strlen( fnam ) + 1) & ~1; /*length in unicode characters aligned to long */
	int size2 = (2*strlen( snam ) + 1) & ~1;
	int size  = 4 + size1 + size2 + 2*sizeof( locator );
	uint32* tp = calloc( size, 1 );
	uint32* lp;
	int offset, numlongs, j; 
	*tableP = tp;
	*tp++	= 2;
	*tp++	= 'NAME';
	offset	= 5;		/* 2 * num locators + 1 */
	*tp++	= offset;
	offset	+= size1;
	*tp++	= 'STYL';
	*tp++	= offset;
	numlongs = (strlen( fnam ) + 3)/4;
	lp = (uint32*)fnam;
	for( j=0; j<numlongs; ++j )
	{
		uint32 val = *lp++;
		uint32 v1 = (val & 0xFF000000) >> 8;
		uint32 v2 = (val & 0x00FF0000) >> 16;
		uint32 v3 = (val & 0x0000FF00) << 8;
		uint32 v4 = (val & 0x000000FF);
		*tp++ = v1 | v2;
		*tp++ = v3 | v4;
	} 
	numlongs = (strlen( snam ) + 3)/4;
	lp = (uint32*)snam;
	for( j=0; j<numlongs; ++j )
	{
		uint32 val = *lp++;
		uint32 v1 = (val & 0xFF000000) >> 8;
		uint32 v2 = (val & 0x00FF0000) >> 16;
		uint32 v3 = (val & 0x0000FF00) << 8;
		uint32 v4 = (val & 0x000000FF);
		*tp++ = v1 | v2;
		*tp++ = v3 | v4;
	}
	return 4*(tp - *tableP); 
}							
/* Create a ufnt file for specific mmlfont.  Should only be used when the 
   pixdata only contains pixels for this font.
 */
void ufnCapture( mmlFontContext fcP, mmlFont font )
{
	FILE *fp;
	int numCharacters, nameSize, cacheTableSize;
	int tableSize;		
	int numSizes = 0;
	int sizes[10];
	textCode *fontname;
	glyphCache *cP, *cacheP;
	uint32 pixOffset;
	
	uint32 *nameP, *tableP;
	cacheP = NULL;
	cP = fcP->firstCacheP;
	/* how many sizes are cached */
	while( cP != NULL )
	{
		if( cP->fontP == font && numSizes < 10 )
		{
			cacheP = cP;
			sizes[numSizes++] = cP->fontSize;
		}
		cP = cP->nextCache;
	}
	assert( numSizes > 0 );
	/* make & hold name table */
	mmlGetFontName( font, &fontname );
	nameSize = makeName( fontname, "regular", &nameP );
	
	/* make contents table */
	numCharacters = cacheP->metrics.numCharacters;
	cacheTableSize = sizeof( glyphCache )
		+ (numCharacters-1)*sizeof( glyphProp );
	
	fp = fopen( "ufnt.dat", "wb" );
	tableSize = makeContents( nameSize, numSizes, sizes, numCharacters, &tableP ); 	
	fwrite( tableP, tableSize, 1, fp );
	free( tableP );
	/* write name table */
	fwrite( nameP, nameSize, 1, fp );
	free( nameP );
	/* write info table */
	fwrite( &numSizes, 4, 1, fp );
	fwrite( &cacheP->metrics.firstCharCode, 4, 1, fp );
	fwrite( &cacheP->metrics.lastCharCode, 4, 1, fp );
	fwrite( sizes, 4, numSizes, fp );
	/* write cache tables */
	cP = fcP->firstCacheP;
	pixOffset = 0;
	while( cP != NULL )
	{
		if( cP->fontP == font && numSizes < 10 )
		{
			int j;
			fwrite( cP, 4, 19, fp );	/* write cachetable header */
			for(j=0; j<numCharacters; ++j)
			{
				glyphProp entry = cP->entry[j];
				entry.pixData = (uint32*)pixOffset;
				pixOffset += entry.entrySizeLongs;
				fwrite( &entry, sizeof( glyphProp ), 1, fp );
			}
		}
		cP = cP->nextCache;
	}
	/* write pixdata (BITS) table */
	cP = fcP->firstCacheP;
	while( cP != NULL )
	{
		int j;
		if( cP->fontP == font )
		{
			for( j=0; j<numCharacters; ++j )
			{
				uint32* p = cP->entry[j].pixData;
				if( p != NULL )
				{
					int numbytes = 4 * cP->entry[j].entrySizeLongs;
					fwrite( p, numbytes, 1, fp );
				}
			}
		}
		cP = cP->nextCache;
	}
	fclose( fp );
}
	
		
	
	
 

