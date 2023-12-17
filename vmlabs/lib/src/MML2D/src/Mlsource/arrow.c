
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* rwb 1/15/98 */
/* Arrow Objects
	An m2dArrow is a fundamental object in the MML Graphics Engine,
	similar to pixmaps. It can be initialized, copied to, shown,
	hidden, and moved.  The video memory for a Arrow is always in
	Merlin SDRAM, as is the video memory of the portion saved before
	drawing.
	
Version 1.
	Arrow must be associated with a single mmlDisplayPixmap. It is always
	888Alpha and is only associated with 888Alpha DisplayPixmaps.
	Arrows are rectangles of any size.
	Alpha value of 0 means opaque. Alpha value of FF is completely transparent.
	
Improvements:
	Storage for arrow and screen-saving should be combined. Because SDRAM must
	be allocated in 512 byte chunks, and pixmaps must always be multiples of
	8 pixels wide, this could save much SDRAM.
 */
#include "../../nuon/mml2d.h"
#include <nuon/bios.h>
#include <stdlib.h>
 
#define kBytesPerPixel 4

mmlStatus m2dInitArrow(mmlSysResources* srP, m2dArrow* aP, uint32 wide, uint32 high )
{
	int bytesPerPixel = kBytesPerPixel;
	int numWide1 = (wide + 7) & ~7;
	int numHigh = high;
	int wide1 = ( wide + 7 ) & ~7;
	int size = wide1 * high * bytesPerPixel;
	aP->imageP = _MemAlloc( size, 512, 1 );
	if( aP->imageP == 0 ) return eMerMemAllocFail;
	aP->dmaFlags	= wide1<<13 | 0xC040;
	aP->wide	= wide;
	aP->high	= high;
	size = numWide1 * numHigh * bytesPerPixel;
	aP->restoreP = _MemAlloc( size, 512, 1 );
	if( aP->restoreP == 0 ) return eMerMemAllocFail;
	aP->screenP 	= NULL;
	aP->left	= (short)kIgnore;
	aP->top		= (short)kIgnore;
	return eOK;
}  

/* Set a pixel in an arrow to a particular color. The color includes
an alpha value. 0 = opaque. FF = transparent.  */

void m2dSetArrowPixel( mmlGC* gcP, m2dArrow* aP, int x, int y, mmlColor c )
{
	m2dDrawPoint( gcP, (mmlDisplayPixmap*)aP, x, y, c );
} 

/* Display an Arrow at a specific coordinate in a specific displayPixmap.  Save the current 
contents of the view beneath the Arrow for later restoration.  Do an alpha
blend of the Arrow with the existing contents.
	Note that the actual area saved is taller and wider than the source image,
by the border amounts.  left and top are the coordinates of the Arrow image,
not of the saved image.
*/
void m2dShowArrow( mmlGC* gcP, m2dArrow* aP, mmlDisplayPixmap* destP, coord left, coord top )
{
	m2dRect restore;
	void *arrowP;
	uint32 dmaFlags;
	uint32 blend = gcP->disCopyBlend;
	
	restore.leftTop.x = left;
	restore.leftTop.y = top;
	restore.rightBot.x = left + aP->wide - 1;
	restore.rightBot.y = top + aP->high - 1;
	
	/* Save the rectangle that will be overwritten */
	arrowP = aP->imageP;
	dmaFlags = aP->dmaFlags;
	aP->dmaFlags &= 0xFF00FFFF;
	aP->dmaFlags |= (((aP->wide+7) & ~7) << 13);
	aP->imageP = aP->restoreP;
	gcP->disCopyBlend = 0;
	m2dCopyRectDis( gcP, destP, (mmlDisplayPixmap*)aP, &restore, m2dSetPoint( 0, 0 ));
	
	/* Display the arrow */
	aP->left	= left;
	aP->top		= top;
	aP->imageP	= arrowP;
	aP->dmaFlags	= dmaFlags;
	gcP->disCopyBlend = 1;
	m2dCopyRectDis( gcP, (mmlDisplayPixmap*)aP, destP, NULL, m2dSetPoint( left, top ));
	aP->screenP	= destP;
	gcP->disCopyBlend = blend;
}
/* Hide an Arrow; Leave it ready for redrawing */
void m2dHideArrow( mmlGC* gcP, m2dArrow* aP )
{
	m2dRect restore;
	void *arrowP;
	uint32 dmaFlags;
	uint32 blend = gcP->disCopyBlend;

	/* restore the previously saved region */
	restore.leftTop.x = 0;
	restore.leftTop.y = 0;
	restore.rightBot.x = aP->wide - 1;
	restore.rightBot.y = aP->high - 1;
	arrowP = aP->imageP;
	dmaFlags = aP->dmaFlags;
	aP->dmaFlags &= 0xFF00FFFF;
	aP->dmaFlags |= (((aP->wide+7) & ~7) << 13);
	aP->imageP = aP->restoreP;
	gcP->disCopyBlend = 0;
	m2dCopyRectDis( gcP, (mmlDisplayPixmap*)aP, aP->screenP, &restore,
		 m2dSetPoint( aP->left, aP->top));	
	aP->imageP = arrowP;
	aP->dmaFlags = dmaFlags;
	gcP->disCopyBlend = blend;
}
/* Redraw a currently hidden arrow in it's previous position */
void m2dRedrawArrow( mmlGC* gcP, m2dArrow* aP )
{	
	m2dShowArrow( gcP, aP, aP->screenP, aP->left, aP->top );	
}
/* Move an Arrow from old position to new position in (possibly different) pixmap.
*/
void m2dMoveArrow( mmlGC* gcP, m2dArrow* aP, mmlDisplayPixmap* destP,
	coord newLeft, coord newTop )
{
	m2dHideArrow( gcP, aP );
	m2dShowArrow( gcP, aP, destP, newLeft, newTop );
}

void m2dDeleteArrow( mmlSysResources* srP, m2dArrow* aP )
{
	int wide1 = (aP->wide+7) & ~7;
	int size = kBytesPerPixel *wide1 * aP->high;
	int numWide1 = (aP->wide+7) & ~7;
	_MemFree( aP->imageP );
	size = numWide1 * aP->high * kBytesPerPixel;
	_MemFree( aP->restoreP );
	aP->screenP 	= NULL;
	aP->left	= (short)kIgnore;
	aP->top		= (short)kIgnore;
}



