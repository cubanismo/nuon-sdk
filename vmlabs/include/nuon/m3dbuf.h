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
 * Definitions of a 3D data buffer
 *
 * Each entry in the buffer occupies
 * a vector in the buffer. The
 * third longword of the vector
 * gives the type, unless the entry
 * is a vertex or vertex normal,
 * in which case its type is given
 * implicitly by a preceding
 * M3D_POLY command.
 *
 * Possible entry types:
 * M3D_MATRIX:
 *    specifies a transformation
 *    matrix.
 * The next 4 vectors then contain
 * the rows and columns for the
 * matrix.
 *
 * M3D_POLY:
 * buf[0] is the number of points.
 * buf[1] is the texture to use.
 * buf[2] and buf[3] are reserved.
 *
 * The next 2*buf[1] vectors give the points.
 * Each point occupies two vectors; the
 * vertex position itself, and the vertex
 * normal.
 *
 * For now, only 3 points are supported
 * by the triangle load routine.
 */

#ifndef M3DBUF_H
#define M3DBUF_H

#ifndef M3DMATERIAL_H
#include "m3dmat.h"
#endif

#define M3D_MATRIX 1
#define M3D_POLY 2

typedef struct m3dBufEntry {
    long buf[3];
    long type;
} m3dBufEntry;

/*
 * the buffer has some state associated with
 * it:
 * "maxentries" is the maximum number of entries
 * currently allocated for the buffer
 * "numentries" is the current number of entries
 * in the buffer
 * "state" keeps track of what we're currently
 * doing to the buffer; for example, if we're
 * adding triangles or polygons or not.
 * "material" is the current material for the buffer
 */
typedef struct m3dBuf {
    int maxentries;
    int numentries;
    int state;
    int curpoly;
    m3dreal nx, ny, nz;  	/* current normal vector entries */
    m3dreal tu, tv;      	/* current texture map coordinates */
    m3dMaterial *material;
    m3dBufEntry *entries;	// Vector aligned pointer 
    m3dBufEntry *realentries;	// Raw pointer
} m3dBuf;


/*
 * defines for m3dHint
 */

/* kind of texture filtering to use */
#define M3D_TEXTURE_FILTER 1
# define M3D_NONE 0
# define M3D_BILERP 1
# define M3D_TRILERP 2
# define M3D_OTHER_FILTER 3

/* kind of edge anti-aliasing to do */
#define M3D_EDGE_AA 2
# define M3D_EDGE_VMLABS 1  /* VM Labs' special edge anti-aliasing */
# define M3D_EDGE_ONLY   2  /* ONLY show edges */

/* a hint to say whether or not we want to use the
 * current MPE
 */
#define M3D_MPE_USAGE 3
# define M3D_MPE_USE_SELF   0  /* use this MPE first */
# define M3D_MPE_USE_OTHERS 1  /* prefer to use other MPEs first */

/*
 * "hint" about texture types -- this is a kludge!
 */
#define M3D_PIXEL_MPEG 99

/*
 * functions to do various things to a buffer
 */

/* initialize a buffer */
void m3dInitBuf(m3dBuf *buf);

/* free a buffer */
void m3dFreeBuf(m3dBuf *buf);

/* force a buffer to have room for at least N entries;
   if force_shrink is non-zero, it will shrink a buffer,
   otherwise buffer can only get larger
*/
void m3dSizeBuf(m3dBuf *buf, int N, int force_shrink);

/* set material to use for a buffer */
void m3dSetMaterial(m3dBuf *buf, m3dMaterial *mat);

/* start adding a triangle to a buffer */
void m3dStartTriangle(m3dBuf *buf);

/* finish adding a triangle to a buffer */
void m3dEndTriangle(m3dBuf *buf);

/* add a vertex to a polygon */
void m3dAddVertex(m3dBuf *buf, m3dreal x, m3dreal y, m3dreal z);

/* add a normal vector to a polygon */
void m3dAddNormal(m3dBuf *buf, m3dreal x, m3dreal y, m3dreal z);

/* add texture map coordinates to a polygon */
void m3dAddTextureCoords(m3dBuf *buf, m3dreal u, m3dreal v);

#define m3dAddVertex3f(buf, x,y,z) m3dAddVertex(buf, M3DF(x),M3DF(y),M3DF(z))
#define m3dAddNormal3f(buf, x,y,z) m3dAddNormal(buf, M3DF(x),M3DF(y),M3DF(z))
#define m3dAddTextureCoords2f(buf, u,v) m3dAddTextureCoords(buf, M3DF(u),M3DF(v))



/* set hints about how to render */
/* the "what" field says what we want to hint about
 * (e.g. perspective correction, texture filtering, etc.);
 * the "how" field says how we want it rendered
 */
void m3dHint(int what, int how);

/* execute (i.e. draw) a buffer */
void m3dExecuteBuffer(mmlGC *gc, mmlDisplayPixmap *region,
		      m2dRect *rect, m3dBuf *buf, m3dMatrix *obj,
		      m3dCamera *cam, m3dLightData *lights);


/* end a scene */
void m3dEndScene(mmlGC *gc, mmlDisplayPixmap *region, m2dRect *rect);

/* initialize the 3D library with how many MPEs to use */
void m3dInit(mmlSysResources *sr, int nummpes);

#endif
