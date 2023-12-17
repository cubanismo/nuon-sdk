/*
 * Faster mml2dCopyRectDis
 *
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>
#include <stdio.h>

void
myCopyRectDis(mmlGC *gc, mmlDisplayPixmap *srcP, mmlDisplayPixmap *destP, m2dRect *r, m2dPoint corner)
{
  unsigned char *localmem;
  int x, y;
  int wide, high, laststep;
  int srcx, srcy;
  int destx, desty;
  int stepx, stepy;
  
  localmem = _MemLocalScratch(0);
  srcx = r->leftTop.x;
  srcy = r->leftTop.y;
  wide = r->rightBot.x - srcx + 1;
  high = r->rightBot.y - srcy + 1;
  destx = corner.x;
  desty = corner.y;

  /* figure out suitable steps */
  laststep = 0;  // assume stepx and stepy divide evenly into wide and high
  if (wide <= 64) {
    stepx = wide; stepy = 1;
  } else if (high <= 64) {
    stepx = 1; stepy = high;
  } else if (((wide & 7) == 0) && ((high & 7) == 0)) {
    stepx = stepy = 8;
  } else {
    /* we know wide and high are both bigger than 64 */
    /* laststep will be the remainder of the draw on each line */
    stepx = 64; stepy = 1;
    laststep = wide - stepx * (wide / stepx);
  }

  for (y = 0; y < high; y += stepy) {
    for (x = 0; x < wide - laststep; x += stepx) {
      _DMABiLinear(srcP->dmaFlags | DMA_PIXEL_READ, srcP->memP,
		   (stepx << 16)|(srcx+x), (stepy<<16)|(srcy+y), localmem);
      _DMABiLinear(destP->dmaFlags, destP->memP,
		   (stepx << 16)|(destx+x), (stepy<<16)|(desty+y), localmem);
    }

    if (laststep) {
      _DMABiLinear(srcP->dmaFlags | DMA_PIXEL_READ, srcP->memP,
		   (laststep << 16)|(srcx+x), (stepy<<16)|(srcy+y), localmem);
      _DMABiLinear(destP->dmaFlags, destP->memP,
		   (laststep << 16)|(destx+x), (stepy<<16)|(desty+y), localmem);
    }

  }
}


// a CopyRectDis which handles blending (and hence transparency)
void
myCopyRectDisBlend(mmlGC *gc, mmlDisplayPixmap *srcP, mmlDisplayPixmap *destP, m2dRect *r, m2dPoint corner)
{
  unsigned char *localmem;
  unsigned char *localmem2;
  int x, y;
  int wide, high, laststep;
  int srcx, srcy;
  int destx, desty;
  int stepx, stepy;

  int i;
  int alpha;  
  int yy, cr, cb;
  unsigned char *ptr;
  unsigned char *ptr2;

  localmem = _MemLocalScratch(0);
  localmem2 = localmem + 256;  // dma up to 64 pixels = 256 bytes
  srcx = r->leftTop.x;
  srcy = r->leftTop.y;
  wide = r->rightBot.x - srcx + 1;
  high = r->rightBot.y - srcy + 1;
  destx = corner.x;
  desty = corner.y;

  /* figure out suitable steps */
  laststep = 0;  // assume stepx and stepy divide evenly into wide and high
  if (wide <= 64) {
    stepx = wide; stepy = 1;
  } else if (high <= 64) {
    stepx = 1; stepy = high;
  } else if (((wide & 7) == 0) && ((high & 7) == 0)) {  // div by 8
    stepx = stepy = 8;
  } else {
    /* we know wide and high are both bigger than 64 */
    /* laststep will be the remainder of the draw on each line */
    stepx = 64; stepy = 1;
    laststep = wide - stepx * (wide / stepx);
  }

  for (y = 0; y < high; y += stepy) {
    for (x = 0; x < wide - laststep; x += stepx) {
      // read in src and dest
      _DMABiLinear(srcP->dmaFlags | DMA_PIXEL_READ, srcP->memP,
		   (stepx<<16)|(srcx+x), (stepy<<16)|(srcy+y), localmem);
      _DMABiLinear(destP->dmaFlags | DMA_PIXEL_READ, destP->memP,
		   (stepx<<16)|(destx+x), (stepy<<16)|(desty+y), localmem2);

      // to do adjust cr cb by subtracting 128
      // then finding alpha, then adding 128
      // change names of ptrs to reflect src and dest

      // can't change value of localmem and localmem2 so make a copy
      ptr = localmem;
      ptr2 = localmem2;
	
      for (i = 0; i < (stepx*stepy); i++){
	// get alpha value from src; keep it as an int
	alpha = (ptr[3] & 255);
	
	// blend src and dest colours based on the alpha value in src (localmem)
	yy = ( ( (255-alpha)*(ptr[0] & 255) ) + (alpha * (ptr2[0] & 255)) + 127 ) / 255;
	cr = ( ( (255-alpha)*(ptr[1] & 255) ) + (alpha * (ptr2[1] & 255)) + 127 ) / 255;
	cb = ( ( (255-alpha)*(ptr[2] & 255) ) + (alpha * (ptr2[2] & 255)) + 127 ) / 255;

	// copy new values to src (localmem)
	ptr[0] = yy; // yy
	ptr[1] = cr; // cr
	ptr[2] = cb; // cb
	ptr[3] = 0;  // make alpha value opaque since the colour is being copied to dest

	// increment pointers
	ptr  += 4;
	ptr2 += 4;
      } 

      // copy to dest
      _DMABiLinear(destP->dmaFlags, destP->memP,
		   (stepx<<16)|(destx+x), (stepy<<16)|(desty+y), localmem);
    }

    if (laststep) {
      _DMABiLinear(srcP->dmaFlags | DMA_PIXEL_READ, srcP->memP,
		   (laststep<<16)|(srcx+x), (stepy<<16)|(srcy+y), localmem);
      _DMABiLinear(destP->dmaFlags | DMA_PIXEL_READ, destP->memP,
		   (laststep<<16)|(destx+x), (stepy<<16)|(desty+y), localmem2);
      // can't change value of localmem and localmem2 so make a copy
      ptr = localmem;
      ptr2 = localmem2;

      for (i = 0; i < laststep; i++){
	// get alpha value from src; keep it as an int
	alpha = (ptr[3] & 255);
	// blend src and dest colours based on the alpha value in src (localmem)
	yy = ( ( (255-alpha)*(ptr[0] & 255) ) + (alpha * (ptr2[0] & 255)) + 127 ) / 255;
	cr = ( ( (255-alpha)*(ptr[1] & 255) ) + (alpha * (ptr2[1] & 255)) + 127 ) / 255;
	cb = ( ( (255-alpha)*(ptr[2] & 255) ) + (alpha * (ptr2[2] & 255)) + 127 ) / 255;
	// copy new values to src (localmem)
	ptr[0] = yy; //yy;
	ptr[1] = cr; //cr;
	ptr[2] = cb; //cb;
	ptr[3] = 0;  // make alpha value opaque since the colour is being copied to dest
	// increment pointers
	ptr  += 4;
	ptr2 += 4;
      } 
      // copy to dest
      _DMABiLinear(destP->dmaFlags, destP->memP,
		   (laststep<<16)|(destx+x), (stepy<<16)|(desty+y), localmem);
    } // if laststep

  }  // y loop
}

