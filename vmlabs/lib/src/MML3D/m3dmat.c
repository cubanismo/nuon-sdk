/*
 * Copyright (C) 1997-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

/*
 * functions for manipulating materials
 *
 */
/* $Id: m3dmat.c,v 1.12 2001/10/18 22:28:16 ersmith Exp $ */

#include <stdlib.h>
#include <nuon/dma.h>
#include <nuon/mml2d.h>
#include <assert.h>
#include "m3d.h"

/*
 * create a texture from a pixmap
 * CAVEAT: can't do CLUT materials (yet)
 */
void
m3dInitMaterialFromPixmap(m3dMaterial *mat, mmlDisplayPixmap *pmap)
{
    mat->dmaflags = pmap->dmaFlags | DMA_READ_BIT;
    mat->dataptr = pmap->memP;
    mat->width = pmap->wide;
    mat->height = pmap->high;
    mat->matflags = 0;
}

/*
 * create a texture from a color
 */
void
m3dInitMaterialFromColor(m3dMaterial *mat, mmlColor color)
{
    mat->dmaflags = (1<<16)|(2<<4) | DMA_PIXEL_READ;
    mat->dataptr = (void *)color;
    mat->width = 1;
    mat->height = 1;
    mat->matflags = M3D_MATERIAL_SOLID;
}

#if 0
/*
 * create a mip-map from an array of textures
 * the textures should be laid out with
 * the smallest texture first
 */

m3dMaterial *
m3dMakeMipMap(int numtexs, m3dMaterial **texs)
{
    int level;

    m3dMaterial *mipmap, *ptr;

    ptr = mipmap = malloc(numtexs*sizeof(*mipmap));
    if (!mipmap) return mipmap;

    for (level = numtexs-1; level >= 0; --level) {
	*ptr = *texs[0]; texs++;
	ptr->matflags &= ~M3D_MIPMAPLEVEL;
	ptr->matflags |= (level << M3D_MIPMAPLEVEL_BITS);
	ptr++;
    }
    return mipmap;
}
#endif
