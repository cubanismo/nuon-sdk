
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 7/12/99 */
/* m2dBox Objects
	An m2dBox is a rectangle outline that can be drawn, saved,
	shown, etc, much like the arrow objects.
	The major use is for a rubber-banding box that can be used
	of focus attention on part of a screen.  It needs to be
	quick.
	Saved pixels are kept in sysram, rather than in SDRAM.
	
	width and height specify the number of pixels in the outside lines
	linewidth pixels are inset on all borders
	left and top specify the coordinates of the outside left top corner
	
	Version 1 does not support antialiasing
	Version 1 does not support aspect-ratio correction
	Version 1 only works on 16bit and 32 bit displaypixmaps.
*/
#include "../../nuon/mml2d.h"
#include <stdlib.h>
#include <assert.h>
//#include <nuon/m2types.h>
//#include <nuon/m2pub.h>
//#include <nuon/mlpixmap.h>

static inline void DrawRow(mmlGC *gcP, mmlDisplayPixmap *destP, int x, int y, int num, mmlColor color)
{
	while( num > 0 )
	{
		m2dSmallFill( gcP, destP, x, y, color, num > 64 ? 64 : num, 1 );
		num -= 64;
		x += 64;
	}
}

static inline void DrawCol(mmlGC *gcP, mmlDisplayPixmap *destP, int x, int y, int num, mmlColor color)
{
	while( num > 0 )
	{
		m2dSmallFill( gcP, destP, x, y, color, 1, num > 64 ? 64 : num );
		num -= 64;
		y += 64;
	}
}
/* Use smallFill to draw an outline of a rectangle.
   left, top, width, height specify outside dimensions.
   linewidth is inset
*/
static inline void DrawBox(mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP, int width,
	int height, int lineWidth, int left, int top, mmlColor color )
{
	int j;
	for( j=0; j<lineWidth; ++j )
	{
		DrawRow( gcP, destP, left, top+j, width, color );
		DrawRow( gcP, destP, left, top+height-1-j, width, color );
		DrawCol( gcP, destP, left+j, top, height, color );
		DrawCol( gcP, destP, left+width-1-j, top, height, color );
	}
	bP->visibleQ = 1;
}

static inline void CopyRow( mmlGC *gcP, mmlDisplayPixmap *destP, int x, int y, int num, uint8* p, int size )
{
	while( num > 0 )
	{
		m2dWritePixels( gcP, (uint32*)p, destP, x, y, num > 64 ? 64 : num, 0 );
		num -= 64;
		p += 64*size;
		x += 64;		
	}

}

static inline void CopyCol( mmlGC *gcP, mmlDisplayPixmap *destP, int x, int y, int num, uint8* p, int size )
{
	while( num > 0 )
	{
		m2dWritePixels( gcP, (uint32*)p, destP, x, y, num > 64 ? 64 : num, 1 );
		num -= 64;
		p += 64*size;
		y += 64;		
	}
}

static inline void RestoreBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP )
{
	int j;
	long* p = bP->memP;
	for( j=0; j<bP->lineWidth; ++j )
	{
		CopyRow( gcP, destP, bP->left, bP->top+j, bP->width, (uint8*)p, bP->pixSizeBytes );
		p +=  bP->rowSizeLongs;
		CopyRow( gcP, destP, bP->left, bP->top+bP->height-1-j, bP->width, (uint8*)p, bP->pixSizeBytes );
		p +=  bP->rowSizeLongs;
		CopyCol( gcP, destP, bP->left+j, bP->top, bP->height, (uint8*)p, bP->pixSizeBytes );
		p +=  bP->colSizeLongs;
		CopyCol( gcP, destP, bP->left+bP->width-1-j, bP->top, bP->height, (uint8*)p, bP->pixSizeBytes );
		p +=  bP->colSizeLongs;
	}
	bP->visibleQ = 0;
}

static inline void SaveRow( mmlGC *gcP, mmlDisplayPixmap *destP, int x, int y, int num, uint8* p, int size )
{
	while( num > 0 )
	{
		m2dReadPixels( gcP, (uint32*)p, destP, x, y, num > 64 ? 64 : num, 0 );
		num -= 64;
		p += 64*size;
		x += 64;		
	}
}

static inline void SaveCol( mmlGC *gcP, mmlDisplayPixmap *destP, int x, int y, int num, uint8* p, int size )
{
	while( num > 0 )
	{
		m2dReadPixels( gcP, (uint32*)p, destP, x, y, num > 64 ? 64 : num, 1 );
		num -= 64;
		p += 64*size;
		y += 64;		
	}
}
 
/* Save the pixels that will be overwritten by a box with these dimensions.
*/
static inline void SaveBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP, int width,
	int height, int lineWidth, int left, int top )
{
	int j;
	long* p = bP->memP;
	for( j=0; j<lineWidth; ++j )
	{
		SaveRow( gcP, destP, left, top+j, width, (uint8*)p, bP->pixSizeBytes );
		p +=  bP->rowSizeLongs;
		SaveRow( gcP, destP, left, top+height-1-j, width, (uint8*)p, bP->pixSizeBytes );
		p +=  bP->rowSizeLongs;
		SaveCol( gcP, destP, left+j, top, height, (uint8*)p, bP->pixSizeBytes );
		p +=  bP->colSizeLongs;
		SaveCol( gcP, destP, left+width-1-j, top, height, (uint8*)p, bP->pixSizeBytes );
		p +=  bP->colSizeLongs;
	}
}

/* Allocate enough Sysram memory for a box to be drawn on destination pixmap,
 with specified maximum dimensions */
mmlStatus m2dInitBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP, int maxWidth, int maxHeight, int maxLineWidth )
{
	int sizeBytes;
	assert( gcP != NULL &&
			destP != NULL &&
			bP != NULL );
	bP->pixSizeBytes = mlpFormatToSize( PIXFORMAT( destP->properties ) ) >> 3;
	bP->rowSizeLongs = (maxWidth * bP->pixSizeBytes + 3)>>2;
	bP->colSizeLongs = (maxHeight * bP->pixSizeBytes + 3)>>2;
	sizeBytes = 4 * maxLineWidth *  2 * (bP->rowSizeLongs + bP->colSizeLongs);
	bP->memP = malloc( sizeBytes );
	if( bP->memP == NULL ) return eSysMemAllocFail;
	bP->maxWidth = maxWidth;
	bP->maxHeight = maxHeight;
	bP->maxLineWidth = maxLineWidth;
	bP->visibleQ = 0;
	return eOK;
}
/* Draw a box in the pixmap with the specified dimensions and colors. 
But first, erase any existing lines, and also save the pixels that will
be overwritten by this box.
*/
void m2dDrawBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP, int width,
	int height, int lineWidth, int left, int top, mmlColor color )
{
	assert( gcP != NULL &&
			destP != NULL &&
			bP != NULL );
	assert( width <= bP->maxWidth &&
			height <= bP->maxHeight &&
			lineWidth <= bP->maxLineWidth );	
	assert( width > 0 && height > 0 && lineWidth > 0 );		
	if( bP->visibleQ == 1 )
	{
		RestoreBox(gcP, destP, bP );
	}
	SaveBox(gcP, destP, bP, width, height, lineWidth, left, top );
	DrawBox(gcP, destP, bP, width, height, lineWidth, left, top, color );
	bP->width = width;
	bP->height = height;
	bP->lineWidth = lineWidth;
	bP->color = color;
	bP->left = left;
	bP->top = top;
}

/* Erase the drawn box positioned at left,top */
void m2dEraseBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP )
{
	assert( gcP != NULL &&
			destP != NULL &&
			bP != NULL );
	assert( bP->visibleQ == 1 );
	RestoreBox( gcP, destP, bP );
}

void m2dRedrawBox( mmlGC *gcP, mmlDisplayPixmap *destP, m2dBox* bP )
{
	assert( gcP != NULL &&
			destP != NULL &&
			bP != NULL );
	assert( bP->visibleQ == 0 );
	DrawBox(gcP, destP, bP, bP->width, bP->height, bP->lineWidth, bP->left, bP->top, bP->color );
}

/* Release memory allocated for box, but not box object itself */
void m2dReleaseBox( m2dBox* bP )
{
	assert( bP != NULL && bP->memP != NULL );
	free( bP->memP );
	bP->memP = NULL;
	bP->visibleQ = 0;
}


	
	
	
	
	  