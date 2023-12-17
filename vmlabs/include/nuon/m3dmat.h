/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
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
 * definitions for materials
 *
 * a "material" is primarily a
 * texture map. It consists of:
 * width
 * height
 * dma flags
 * a reserved word
 * and then width*height*pixel size
 * bytes of actual texture data.
 *
 */

#ifndef M3DMATERIAL_H
#define M3DMATERIAL_H

/*
 * a material for 3d texture mapping
 */
typedef struct m3dMaterial {
    short width;
    short height;
    int matflags;  /* various material flags */
    int dmaflags;  /* dma flags of the texture */
    void *dataptr; /* pointer to data, or the direct color itself if M3D_MATERIAL_SOLID */
} m3dMaterial;

/* material flags */
/* flag to indicate solid color material */
#define M3D_MATERIAL_SOLID 1
/* mip-map level is in bits 31-28 */
#define M3D_MIPMAPLEVEL 0xf0000000
#define M3D_MIPMAPLEVEL_BITS 28



/* functions for manipulating materials */
void m3dInitMaterialFromColor(m3dMaterial *mat, mmlColor color);

/* create a texture from a JPEG */
void m3dInitMaterialFromJPEG(m3dMaterial *mat, mmlSysResources *sr,
			     void *jpegStart, int jpegSize, mmlPixFormat pix);

/* create a texture from a pixmap */
void m3dInitMaterialFromPixmap(m3dMaterial *mat, mmlDisplayPixmap *pmap);

/* create a mip-map from a JPEG */
void m3dInitMipMapFromJPEG(m3dMaterial *mat, int maxLevel, mmlSysResources *sr,
			   void *jpegStart, int jpegSize, mmlPixFormat pix);


/* create a solid color texture */
m3dMaterial *m3dSolidColorMaterial(mmlColor color);

#endif
