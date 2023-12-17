/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/
/* Line Drawing Code & Ellipse Drawing Code
 * Wrappers for Jeff Minter aaline functions ...
 * tag & rwb 9/23/98
 */
#include "m2config.h"
#include "../mrplib/parblock.h"
#include "../../nuon/mml2d.h"
#include "../../nuon/mrpcodes.h"
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>

// Maps (0 - 0xff, origin at 0) to (0xffff - 0, origin at 0xffff)
#define MAP_TO_FFFF_ALPHA(alpha) (0xffff - ((alpha)*0x101)) // 0xffff - ((alpha)*0xffff/0xff

// Maps (0 - 0xff) to (0xffffffff - 0)
#define MAP_TO_FFFFFFFF_ALPHA(alpha) (0xffffffff - ((alpha)*0x1010101)) // 0xffff - ((alpha)*0xffffffff/0xff

void m2dInitLineStyle( mmlGC* gcP, m2dLineStyle* lineS, mmlColor color, int32 thick, uint32 alpha,
	m2dLineKind lineKind )
{
    assert( lineS != NULL );
    assert( gcP != NULL );
    lineS->lineKind   =	lineKind;
    lineS->foreColor  =	color;
	lineS->foreColor2  = gcP->defaultLS.foreColor2;
	lineS->colorBlend1 = gcP->defaultLS.colorBlend1;
	lineS->colorBlend2 = gcP->defaultLS.colorBlend2;

	lineS->alpha	  = alpha;
    lineS->thick	  = thick;

	lineS->lineRandNum[0] = gcP->defaultLS.lineRandNum[0];
	lineS->lineRandNum[1] = gcP->defaultLS.lineRandNum[1];
	lineS->lineRandNum[2] = gcP->defaultLS.lineRandNum[2];
	lineS->lineRandNum[3] = gcP->defaultLS.lineRandNum[3];
}

void m2dInitEllipseStyle( mmlGC* gcP, m2dEllipseStyle* circleS, f16Dot16 ratio,
	mmlColor color1, f24Dot8 xScale, f24Dot8 yScale, uint32 alpha, int32 fill) 
{
	assert( circleS != NULL );
    assert( gcP != NULL );
	circleS->width = ratio;
	circleS->foreColor = color1;
//	circleS->foreColor2 = color2;
    circleS->xScale = xScale;
    circleS->yScale = yScale;
	circleS->alpha = alpha;
	circleS->fill = fill;
}

void InitLineParamBlock(mmlDisplayPixmap* destP, DrawLineParamBlock* parP, int thick,
	mmlColor color1, mmlColor color2, uint32 alpha, int32 colorBlend1, int32 colorBlend2,
	int* lineRandNum, uint32 nClutAlpha)
{
    mmlPixFormat pix;

    // check if enough memory in bytes is available in dtram:
    // (4 * memory_in_longs_used > INTDATA_DTRAM_AVAIL)
    assert ( (sizeof(DrawLineParamBlock) + 4*(_DMA_BUFFSIZE + 12)) <= _localRamSize );

#if (DEBUG == 1)
	memset(parP, 0xac, sizeof(DrawLineParamBlock));
#endif

    pix = PIXFORMAT(destP->properties);

    // if pixmap is of type e655, change dmaFlag type from 2 to 8
	if( pix == e655 )
	{
		parP->dmaFlags = (destP->dmaFlags ^ 0x20) | 0x80;
	}
	else
		parP->dmaFlags = destP->dmaFlags;

     // Jeff's line routines assume that input width ("thick") is 1/2 of total width:
    thick = (thick+1)>>1;

    // process clut mode
    if(pix==eClut8)
    {
        int idxPerWid = ((nClutAlpha-1)<<28)/thick; // do <<28 to preserve the fractional part of the division

        if(idxPerWid > 0x10000000)
            parP->idxPerWidth = 0x10000000; 
        else
            parP->idxPerWidth = idxPerWid;

        // shift color values to make room for colorBlends
        color1 <<= 8;
	    color2 <<= 8;
    }


//  (parP->object).color1 = color1|MAP_TO_FF_ALPHA(colorBlend1);
//	(parP->object).color2 = color2|MAP_TO_FF_ALPHA(colorBlend2);
 
//  NOTE: MAP_TO_FF_ALPHA is not necessary since Jeff Minter's code expects blend values in the NORMAL mode-
//        "0xff" means more opaque than 00, and input values are in this mode
    (parP->object).color1 = color1|colorBlend1;
	(parP->object).color2 = color2|colorBlend2;

    parP->destAdr = destP->memP;

    parP->xHiLoClip = (destP->wide - 1) << 16; // shift << 16 so low 16 bits contains 0, the low clip value
	parP->yHiLoClip = (destP->high - 1) << 16;

	(parP->rzinfData).baseMPE = 0;
	(parP->rzinfData).height = destP->high;
	(parP->rzinfData).totRenderMPE = 1;

    (parP->object).translucRadius = (MAP_TO_FFFF_ALPHA(alpha)<<16) | thick;
	(parP->object).pList = 0;

	parP->randNum[0] = lineRandNum[0];
	parP->randNum[1] = lineRandNum[1];
	parP->randNum[2] = lineRandNum[2];
	parP->randNum[3] = lineRandNum[3];
}


void InitEllipseParamBlock(eBool fixAspect, mmlDisplayPixmap* destP, DrawEllipseParamBlock* parP,
	mmlColor color1, mmlColor color2, f24Dot8 xScale, f24Dot8 yScale, uint32 alpha, int32 fill,
    uint32 width, uint32 nClutAlpha)
{
    mmlPixFormat pix;

    // check if enough memory in bytes is available in dtram:
    // (4 * memory_in_longs_used > INTDATA_DTRAM_AVAIL)
    // Do: 2*_DMA_ELPSE_BUFFSIZE since 1 buffer is used for left-side and another buffer is used for right-side.
    assert ( (sizeof(DrawEllipseParamBlock) + 4*(2*_DMA_ELPSE_BUFFSIZE + 12)) <= _localRamSize );

#if (DEBUG == 1)
	memset(parP, 0xac, sizeof(DrawEllipseParamBlock));
#endif

	parP->destAdr = destP->memP;

/* if pixmap is of type e655, change dmaFlag type from 2 to 8 */
	if( (destP->dmaFlags & 0xF0) == 0x20 )
	{
		parP->dmaFlags = (destP->dmaFlags ^ 0x20) | 0x80;
	}
	else
		parP->dmaFlags = destP->dmaFlags;

    pix = PIXFORMAT(destP->properties);
    // process clut mode
    if(pix==eClut8)
    {
        int idxPerWid = ((nClutAlpha-1)<<28)/width; // do <<28 to preserve the fractional part of the division

        if(idxPerWid > 0x10000000)
            parP->idxPerWidth = 0x10000000; 
        else
            parP->idxPerWidth = idxPerWid;
    }

	parP->xHiLoClip = (destP->wide - 1) << 16;
	parP->yHiLoClip = (destP->high - 1) << 16;

	(parP->rzinfData).baseMPE = 0;
	(parP->rzinfData).height = destP->high;
	(parP->rzinfData).totRenderMPE = 1;

	(parP->object).color1 = color1;
	(parP->object).color2 = color2;

	if(fixAspect == eFalse)
		(parP->object).scalex_y = (xScale<<16) | yScale;
	else
		(parP->object).scalex_y = (((xScale*X_ASPECT)/Y_ASPECT)<<16) | yScale;

	(parP->object).alpha = MAP_TO_FFFFFFFF_ALPHA(alpha);

	assert(fill == 1 || fill == 0);
	(parP->object).fill = fill;
}

	
void m2dDrawLine( mmlGC* gcP, mmlDisplayPixmap* destP, int32 xBeg,
	 int32 yBeg, int32 xEnd, int32 yEnd )                               
{
    DrawLineParamBlock* parP = (DrawLineParamBlock*)malloc( sizeof (DrawLineParamBlock) );
	assert(parP != NULL);
	InitLineParamBlock(destP, parP, gcP->defaultLS.thick, gcP->defaultLS.foreColor, gcP->defaultLS.foreColor2, gcP->defaultLS.alpha, 
		gcP->defaultLS.colorBlend1, gcP->defaultLS.colorBlend2, gcP->defaultLS.lineRandNum,
        gcP->nClutAlpha);

	if(gcP->fixAspect == eFalse)
	{
		(parP->object).startx_y = (xBeg<<16) | yBeg;
		(parP->object).endx_y = (xEnd<<16) | yEnd;
	}
	else
	{
		(parP->object).startx_y = (((xBeg*X_ASPECT)/Y_ASPECT)<<16) | yBeg;
		(parP->object).endx_y = (((xEnd*X_ASPECT)/Y_ASPECT)<<16) | yEnd;
	}
    
	mmlExecutePrimitive( gcP, eDrawLinePlus,
		parP, sizeof(DrawLineParamBlock), gcP->defaultLS.lineKind, 0);
}

void m2dDrawStyledLine(mmlGC *gcP, mmlDisplayPixmap *destP, m2dLineStyle *sP,
	 int xBeg, int yBeg, int xEnd, int yEnd)
{
    DrawLineParamBlock* parP = (DrawLineParamBlock*)malloc( sizeof (DrawLineParamBlock) );
	assert(parP != NULL);
	InitLineParamBlock(destP, parP, sP->thick, sP->foreColor, sP->foreColor2, sP->alpha, 
		sP->colorBlend1, sP->colorBlend2, sP->lineRandNum, gcP->nClutAlpha);

	if(gcP->fixAspect == eFalse)
	{
		(parP->object).startx_y = (xBeg<<16) | yBeg;
		(parP->object).endx_y = (xEnd<<16) | yEnd;
	}
	else
	{
		(parP->object).startx_y = (((xBeg*X_ASPECT)/Y_ASPECT)<<16) | yBeg;
		(parP->object).endx_y = (((xEnd*X_ASPECT)/Y_ASPECT)<<16) | yEnd;
	}

	mmlExecutePrimitive( gcP, eDrawLinePlus,
		parP, sizeof(DrawLineParamBlock), sP->lineKind, 0);

}

void m2dDrawPolyLine(mmlGC *gcP, mmlDisplayPixmap *destP, int32 xc, int32 yc,
	f24Dot8 xscale, f24Dot8 yscale, int32 angle, int32* pPtsLst)
{
//	m2dPrimitive lineType = eUnimp;
    DrawLineParamBlock* parP = (DrawLineParamBlock*)malloc( sizeof (DrawLineParamBlock) );
	assert(parP != NULL);
	InitLineParamBlock(destP, parP, gcP->defaultLS.thick, gcP->defaultLS.foreColor, gcP->defaultLS.foreColor2, gcP->defaultLS.alpha, 
		gcP->defaultLS.colorBlend1, gcP->defaultLS.colorBlend2, gcP->defaultLS.lineRandNum,
        gcP->nClutAlpha);
	
	if(gcP->fixAspect == eFalse)
	{
		(parP->object).startx_y = (xc<<16) | yc;
		(parP->object).scalex_y = (xscale<<16) | yscale;
	}
	else
	{
		(parP->object).startx_y = (((xc*X_ASPECT)/Y_ASPECT)<<16) | yc;
		(parP->object).scalex_y = (((xscale*X_ASPECT)/Y_ASPECT)<<16) | yscale;
	}

	(parP->object).rotAngle = angle;
	(parP->object).pList = pPtsLst;

	mmlExecutePrimitive( gcP, eDrawLinePlus,
		parP, sizeof(DrawLineParamBlock), gcP->defaultLS.lineKind, 0);
}

// Code to create fast ellipses on an 8 bit screen
// quickndirty - just get a filled version of Abrash's implementation running
// a = width along x-axis
// b = width along y-axis
// x,y are center
// color is index to color palette (assume it is already setup), repeat it
// 4 times when calling - ie, index color val of 8 = 0x08080808;
// NOTE: only for eClut8 mode, and only does filled ellipses!
// My tests indicate that we draw about 210 ellipses per second.  About 99% of
// the time is taken in mmlExecutPrimitive callse.  There's definitely a lot of
// room for improvement, but since this is stopgap, the effort may not be 
// worth it right now.
void m2dDrawEllipse8(mmlGC *gc, mmlDisplayPixmap *V, int a, int b, int x, int y, mmlColor color)
{
  int d; // our decision variable
  int x_incr, y_incr, curr_y, curr_x;
  int a_sqr = a * a;
  int b_sqr = b * b;
  FillClutParamBlock* parP = malloc( sizeof(FillClutParamBlock) );
  
  assert ( parP != NULL);

  // the following values only need to be set once during the algorithm
  parP->destBufferAdr = V->memP;
  parP->destFlags = ( V->dmaFlags & 0xFF08F0 ) | ePixDma;
  parP->numRows = 1;
  parP->fillData = color;

  // draw 4 arcs for which x axis is the major axis

  // plot our two initial pixels
  parP->destLeftCol = x;
  parP->destTopRow = y + b;
  parP->rowLength = 1;
  mmlExecutePrimitive( gc, eFillClut, parP, 
							  sizeof(FillClutParamBlock), 0, 0);
  parP->destTopRow = y - b;
  mmlExecutePrimitive( gc, eFillClut, parP, 
							  sizeof(FillClutParamBlock), 0, 0);	

  y_incr = a_sqr * 2 * b;
  x_incr = 0;
  curr_x = 0;
  curr_y = b;

  // init our decision var to f(0,b-0.5) -> near top of ellipse
  d = a_sqr / 4 - a_sqr * b;

  for(;;)
  {
	 d += x_incr + b_sqr;
	 if ( d >= 0 ) { // choose next y pixel
		y_incr -= a_sqr * 2;
		d -= y_incr;
		curr_y--;
	 }

	 x_incr += b_sqr * 2;
	 curr_x++;
	 if (x_incr >= y_incr)
		break;	// x isn't the major axis

	 parP->destLeftCol = x - curr_x;
	 parP->destTopRow = y - curr_y;
	 parP->rowLength = (curr_x * 2) + 1;
	 mmlExecutePrimitive( gc, eFillClut, parP, 
								 sizeof(FillClutParamBlock), 0, 0);
	 parP->destTopRow = y + curr_y;
	 mmlExecutePrimitive( gc, eFillClut, parP, 
								 sizeof(FillClutParamBlock), 0, 0);
  }

  // Now draw cases where y is the major axis...
  parP->destLeftCol = x - a;
  parP->destTopRow = y;
  parP->rowLength = a * 2 + 1;
  mmlExecutePrimitive( gc, eFillClut, parP, 
							  sizeof(FillClutParamBlock), 0, 0);

  curr_x = a;
  curr_y = 0;

  x_incr = b_sqr * 2 * a;
  y_incr = 0;
  d = b_sqr / 4 - b_sqr * a;

  for(;;)
  {
	 d += y_incr + a_sqr;
	 if ( d >= 0) { // advance to next X coord
		x_incr -= b_sqr * 2;
		d = d - x_incr;
		curr_x--;
	 }

	 y_incr += a_sqr * 2;
	 curr_y++;
		
	 if (y_incr > x_incr)
		break; // done ellipse

	 if (curr_x < 0) {
		parP->destLeftCol = x + curr_x;
	   parP->rowLength = (curr_x * -2) + 1;
	 }
	 else { 
		parP->destLeftCol = x - curr_x;
		parP->rowLength = (curr_x * 2) + 1;
	 }
	 parP->destTopRow = y - curr_y;
    mmlExecutePrimitive( gc, eFillClut, parP, 
		 					    sizeof(FillClutParamBlock), 0, 0);
	 parP->destTopRow = y + curr_y;	  
    mmlExecutePrimitive( gc, eFillClut, parP, 
		 					    sizeof(FillClutParamBlock), 0, 0);
  }
}

void m2dDrawEllipse(mmlGC *gcP, mmlDisplayPixmap *destP, int32 xc, int32 yc, int32 rad)
{
    mmlPixFormat pix;
    uint32 width;

    DrawEllipseParamBlock* parP = (DrawEllipseParamBlock*)malloc( sizeof (DrawEllipseParamBlock) );
	assert(parP != NULL);

    // Jeff's ellipse routine assumes that input width ("thick") is 1/2 of total width:
    width = (gcP->defaultES.width + 1)>>1;

    InitEllipseParamBlock(gcP->fixAspect, destP, parP,
		gcP->defaultES.foreColor, gcP->defaultES.foreColor2, gcP->defaultES.xScale, gcP->defaultES.yScale,
		gcP->defaultES.alpha, gcP->defaultES.fill, width, gcP->nClutAlpha);
	
	if(gcP->fixAspect == eFalse)
	    (parP->object).xc_yc = (xc<<16) | yc;
	else
	    (parP->object).xc_yc = (((xc*X_ASPECT)/Y_ASPECT)<<16) | yc;

	(parP->object).rad_width = (rad<<16) | width;
   
    pix = PIXFORMAT(destP->properties);
    // process clut mode
    if(pix==eClut8)
    	mmlExecutePrimitive( gcP, eDrawEllipsePlus,
    		parP, sizeof(DrawEllipseParamBlock), eellipseclut8, 0);
    else
    	mmlExecutePrimitive( gcP, eDrawEllipsePlus,
    		parP, sizeof(DrawEllipseParamBlock), eellipse1, 0);
}

void m2dDrawStyledEllipse(mmlGC *gcP, mmlDisplayPixmap *destP, m2dEllipseStyle *sP, int32 xc, int32 yc, int32 rad)
{
    mmlPixFormat pix;
    uint32 width;
    DrawEllipseParamBlock* parP = (DrawEllipseParamBlock*)malloc( sizeof (DrawEllipseParamBlock) );
	assert(parP != NULL);

    // Jeff's line routines assume that input width ("thick") is 1/2 of total width:
    width = (sP->width + 1)>>1;

	InitEllipseParamBlock(gcP->fixAspect, destP, parP,
		sP->foreColor, sP->foreColor2, sP->xScale, sP->yScale,
		sP->alpha, sP->fill, width, gcP->nClutAlpha);
	
	if(gcP->fixAspect == eFalse)
	    (parP->object).xc_yc = (xc<<16) | yc;
	else
	    (parP->object).xc_yc = (((xc*X_ASPECT)/Y_ASPECT)<<16) | yc;

	(parP->object).rad_width = (rad<<16) | width;
   
    pix = PIXFORMAT(destP->properties);
    // process clut mode
    if(pix==eClut8)
    	mmlExecutePrimitive( gcP, eDrawEllipsePlus,
    		parP, sizeof(DrawEllipseParamBlock), eellipseclut8, 0);
    else
    	mmlExecutePrimitive( gcP, eDrawEllipsePlus,
    		parP, sizeof(DrawEllipseParamBlock), eellipse1, 0);
}

void SetQuadArcClips(int32* left, int32* right, int32* top, int32* bottom, int32 quadrant, int32 xc, int32 yc,
    eBool fixAspect, f24Dot8 xScale, f24Dot8 yScale, uint16 wide, uint16 high, int32 rad)
{
    int32  windowRight, windowBottom;
    int32  xRad, yRad;                // width of x radius & y radius
    int32  truexScale;

    if(fixAspect == eTrue)
    {
		xc = (xc*X_ASPECT)/Y_ASPECT;
        truexScale = (xScale * X_ASPECT)/Y_ASPECT;
    }
    else
        truexScale = xScale;

    xRad = (truexScale * rad) >> 8;
    yRad = (yScale * rad) >> 8;
   
	// set clipping edges to draw the right quad arc: Quadrants are numbered clockwise, to be consistent with the left-handed
	// coordinate system. Quadrant 1 is lower right, Quad 2 is lower left, Quad 3 is uppper left,
	// Quad 4 is upper right. 
	if(quadrant == 1 || quadrant == 4)
    {
        *left = xc;
        *right = xc + xRad;
    }
    else if(quadrant == 2 || quadrant == 3)
    {
        *right = xc;
        *left = xc - xRad;
    }

	if(quadrant == 1 || quadrant == 2)
    {
        *top = yc;
        *bottom = yc + yRad;
    }
    else if(quadrant == 3 || quadrant == 4)
    {
        *bottom = yc;
        *top = yc - yRad;
    }

    // compare clipping edges with window edges
    if (*left < 0)
        *left = 0;

    windowRight = wide - 1;
    if (*right > windowRight)
        *right = windowRight;

    if (*top < 0)
        *top = 0;

    windowBottom = high - 1;
    if (*bottom > windowBottom)
        *bottom = windowBottom;
}

// NOTE: Both m2dDrawQuadArc & m2dDrawStyledQuadArc draw arcs by setting the clipping parameters to
// clip in an arc instead of the entire ellipse.
void m2dDrawQuadArc(mmlGC *gcP, mmlDisplayPixmap *destP, int32 xc, int32 yc, int32 rad, int32 quadrant)
{
    mmlPixFormat pix;
    uint32 width;
	int32 left, right, top, bottom;  // clipping values

    DrawEllipseParamBlock* parP = (DrawEllipseParamBlock*)malloc( sizeof (DrawEllipseParamBlock) );
	assert(parP != NULL);
	assert(quadrant>=1 && quadrant<=4);

     // Jeff's line routines assume that input width ("thick") is 1/2 of total width:
    width = (gcP->defaultES.width + 1)>>1;

	InitEllipseParamBlock(gcP->fixAspect, destP, parP,
		gcP->defaultES.foreColor, gcP->defaultES.foreColor2, gcP->defaultES.xScale, gcP->defaultES.yScale,
		gcP->defaultES.alpha, gcP->defaultES.fill, width, gcP->nClutAlpha);

    left=right=top=bottom=0;
    SetQuadArcClips(&left, &right, &top, &bottom, quadrant, xc, yc,
        gcP->fixAspect, gcP->defaultES.xScale, gcP->defaultES.yScale, destP->wide, destP->high, rad);
	parP->xHiLoClip = (right<<16) | left;
	parP->yHiLoClip = (bottom<<16) | top;

    (parP->object).xc_yc = (xc<<16) | yc;
	(parP->object).rad_width = (rad<<16) | width;
   
    pix = PIXFORMAT(destP->properties);
    // process clut mode
    if(pix==eClut8)
    	mmlExecutePrimitive( gcP, eDrawEllipsePlus,
    		parP, sizeof(DrawEllipseParamBlock), eellipseclut8, 0);
    else
    	mmlExecutePrimitive( gcP, eDrawEllipsePlus,
    		parP, sizeof(DrawEllipseParamBlock), eellipse1, 0);
}


void m2dDrawStyledQuadArc(mmlGC *gcP, mmlDisplayPixmap *destP, m2dEllipseStyle *sP, int32 xc, int32 yc, int32 rad, int32 quadrant)
{
    mmlPixFormat pix;
    uint32 width;
	int32 left, right, top, bottom;  // clipping values

    DrawEllipseParamBlock* parP = (DrawEllipseParamBlock*)malloc( sizeof (DrawEllipseParamBlock) );
	assert(parP != NULL);
	assert(quadrant>=1 && quadrant<=4);

     // Jeff's line routines assume that input width ("thick") is 1/2 of total width:
    width = (sP->width + 1)>>1;

    InitEllipseParamBlock(gcP->fixAspect, destP, parP,
		sP->foreColor, sP->foreColor2, sP->xScale, sP->yScale,
		sP->alpha, sP->fill, width, gcP->nClutAlpha);
	
    left=right=top=bottom=0;
    SetQuadArcClips(&left, &right, &top, &bottom, quadrant, xc, yc,
        gcP->fixAspect, sP->xScale, sP->yScale, destP->wide, destP->high, rad);
	parP->xHiLoClip = (right<<16) | left;
	parP->yHiLoClip = (bottom<<16) | top;

    (parP->object).xc_yc = (xc<<16) | yc;
	(parP->object).rad_width = (rad<<16) | width;
   
    pix = PIXFORMAT(destP->properties);
    // process clut mode
    if(pix==eClut8)
    	mmlExecutePrimitive( gcP, eDrawEllipsePlus,
    		parP, sizeof(DrawEllipseParamBlock), eellipseclut8, 0);
    else
    	mmlExecutePrimitive( gcP, eDrawEllipsePlus,
    		parP, sizeof(DrawEllipseParamBlock), eellipse1, 0);
}
