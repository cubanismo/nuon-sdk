
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include "sg.h"

// a ftn which combines two m2dSetRect and myCopyRectDis
//
void MyCopyRect(int upleft_x, int upleft_y, int botright_x, int botright_y,
                mmlDisplayPixmap *srcPtr, int pt_x, int pt_y, mmlDisplayPixmap *dstPtr)
{
  m2dRect r;

  // set up the rectangle which we want to grab from the source pixmap
  m2dSetRect( &r, upleft_x, upleft_y, botright_x, botright_y );

  // myCopyRectDis is a faster version of m2dCopyRectDis
  myCopyRectDis( &gc, srcPtr, dstPtr, &r, m2dSetPoint(pt_x, pt_y) );
}


// use this ftn to copy cursor or ball pointer; anything which uses
// transparancy
void MyCopyRectTrans(int upleft_x,int upleft_y, int botright_x, int botright_y,
              mmlDisplayPixmap *srcPtr, int pt_x, int pt_y, mmlDisplayPixmap *dstPtr)
{
  m2dRect r;

  m2dSetRect( &r, upleft_x, upleft_y, botright_x, botright_y );
  myCopyRectDisBlend( &gc, srcPtr, dstPtr, &r, m2dSetPoint(pt_x, pt_y) );
}
