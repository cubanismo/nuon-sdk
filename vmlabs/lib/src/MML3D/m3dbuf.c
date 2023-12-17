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
 * MML 3D execute buffer routines
 *
 */

//#define DEBUG
/* $Id: m3dbuf.c,v 1.44 2001/10/18 22:28:16 ersmith Exp $ */

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <nuon/mutil.h>
#include <nuon/mml2d.h>
#include <nuon/mpe.h>

#include "m3d.h"
#include "lib3d.h"

#define MAX_MPES 4

/*
; Z comparison mode for DMA
; inhibit if target > transfer
; i.e. write if new pixel > old pixel
; this means we should clear the Z buffer to 0, and
; actually write 1/Z into the buffer rather than Z itself
*/

#define DMA_ZMODE 4

/* buffer entry types */
#define M3D_POLY_ENTRY 1

/* various buffer states */
#define STATE_QUIET 0
#define STATE_POLY 1


/* number of entries to add to the buffer when it needs to grow */
#define GROWAMOUNT 1024

static m3dMaterial defaultmaterial;

static void
m3dERROR(char *str)
{
    extern void write(int, void *, int);
    write(2, str, strlen(str));
    for(;;)
	;
}

static void
_m3dAddEntry(m3dBuf *buf, m3dBufEntry *entry)
{
    m3dBufEntry *newentries;

	// Expand execute buffer if too small, keeping each entry vector-aligned
    if (buf->numentries >= buf->maxentries) {
		newentries = realloc(buf->realentries, 16 + (buf->numentries+GROWAMOUNT)*sizeof(*entry));
		if (!newentries)
		    m3dERROR("out of memory");
		buf->maxentries += GROWAMOUNT;
		buf->realentries = newentries;
		buf->entries = (m3dBufEntry *)(((long)(buf->realentries) + 15) & 0xfffffff0);
    }
    buf->entries[buf->numentries] = *entry;
    buf->numentries++;
}

void
m3dInitBuf(m3dBuf *buf)
{
    buf->numentries = 0;
    buf->maxentries = 0;
    buf->entries = buf->realentries = NULL;
    buf->curpoly = 0;
    buf->state = STATE_QUIET;

    buf->material = &defaultmaterial;
}

void
m3dFreeBuf(m3dBuf *buf)
{
    free(buf->entries);
    m3dInitBuf(buf);
}

// Resets a buffer's entries to zero without releasing the RAM
void
m3dRecycleBuf(m3dBuf *buf)
{
	buf->numentries = 0;
	buf->curpoly = 0;
	buf->state = STATE_QUIET;
	buf->material = &defaultmaterial;
}

// Force a buffer to be a certain size
// If force_shrink is 1, the buffer will be shrunk to
// fit the size, otherwise what you'll get is
// a buffer that's at least the size requested
//
void
m3dSizeBuf(m3dBuf *buf, int size, int force_shrink)
{
    m3dBufEntry *newentries;

    /* if the number requested is larger than the number
       of entries we have, grow the buffer */
    /* if force_shrink is set, force the buffer to be
       resized */
    if (size >= buf->maxentries || force_shrink) {
	newentries = realloc(buf->entries, size*sizeof(newentries[0]));
	if (!newentries)
	    m3dERROR("out of memory in m3dSizeBuf");
	buf->entries = newentries;
	buf->maxentries = size;
	/* if force_shrink was used, we may lose buffer entries;
	   dunno how to warn the user about this! */
	if (buf->numentries > buf->maxentries)
	    buf->numentries = buf->maxentries;

    }
}

// Set current material for the buffer
void
m3dSetMaterial(m3dBuf *buf, m3dMaterial *mat)
{
    buf->material = mat;
}

void
m3dStartTriangle(m3dBuf *buf)
{
    m3dBufEntry ent;

    if (buf->state != STATE_QUIET) {
	m3dERROR("StartTriangle: bad state");
	return;
    }
    buf->state = STATE_POLY;
    buf->curpoly = buf->numentries;
    buf->nx = buf->ny = M3DI(0);
    buf->nz = M3DI(-1);
    buf->tu = buf->tv = M3DI(0);

    ent.type = M3D_POLY_ENTRY;
    ent.buf[0] = 0;
    ent.buf[1] = (long)buf->material;
    _m3dAddEntry(buf, &ent);
}

void
m3dEndTriangle(m3dBuf *buf)
{
    if (buf->state == STATE_QUIET) {
		m3dERROR("EndTriangle: bad state");
		return;
    }
    buf->state = STATE_QUIET;
 	if (buf->entries[buf->curpoly].buf[0] != 3) {
		m3dERROR("wrong number of vertices");
    }
}

void
m3dAddTextureCoords(m3dBuf *buf, m3dreal u, m3dreal v)
{
    buf->tu = u << 8;
    buf->tv = v << 8;
}

void
m3dAddNormal(m3dBuf *buf, m3dreal x, m3dreal y, m3dreal z)
{
    buf->nx = (-x) << 14;
    buf->ny = (-y) << 14;
    buf->nz = (-z) << 14;
}

#if 0
// assembly language version in m3dadd.s used now
void
m3dAddVertex(m3dBuf *buf, m3dreal x, m3dreal y, m3dreal z)
{
    m3dBufEntry *newentries;
    m3dreal *p;
    int c = buf->numentries;

    // Check if size limit breached
    if (c + 1 >= buf->maxentries) {
	newentries = realloc(buf->entries, (c + GROWAMOUNT) * sizeof(*newentries));
	if (!newentries)
	    m3dERROR("out of memory");
	buf->maxentries += GROWAMOUNT;
	buf->entries = newentries;
    }

    // Now add everything
    p = (m3dreal *)&buf->entries[c];
    *p++ = x;
    *p++ = y;
    *p++ = z;
    *p++ = buf->tu;
    *p++ = buf->nx;
    *p++ = buf->ny;
    *p++ = buf->nz;
    *p++ = buf->tv;
    buf->numentries += 2;

    // increment count of points
    buf->entries[buf->curpoly].buf[0]++;
}
#endif

extern long pipe_init[], pipe_end[];
extern long reciplo[], reciplo_end[];
extern long reciphi[], reciphi_end[];
extern long loadpoly_init[], loadpoly_end[];
extern long xformlo_init[], xformlo_end[];
extern long xformhi_init[], xformhi_end[];
extern long calcclip_init[], calcclip_end[];
extern long doclip_init[], doclip_end[];
extern long light_init[], light_end[];
extern long persp_init[], persp_end[];

extern long drawpoly_init[], drawpoly_end[];

extern long pixel_init[], pixel_end[];
extern long bilerp_init[], bilerp_end[];
extern long mpegpixel_init[], mpegpixel_end[];

#if INCLUDE_EDGEAA
extern long aadrawpoly_init[], aadrawpoly_end[];
extern long aapixel_init[], aapixel_end[];
extern long aabilerp_init[], aabilerp_end[];
#endif

/*
 * List of MPEs allocated and used
 */

int m3dNumMPEs = 0;

/* list of MPEs we can run on */
/* this list cannot include ourselves */

static int mpe_list[MAX_MPES];

static long *cur_3d_pipe;
static int pipe_changed;

static PipeComponent pipe_parts[] = {
    { pipe_init, pipe_end },
    { loadpoly_init, loadpoly_end },
    { xformlo_init, xformlo_end },
    { persp_init, persp_end },
    { calcclip_init, calcclip_end },
    { doclip_init, doclip_end },
    { light_init, light_end },
    { drawpoly_init, drawpoly_end },
    { pixel_init, pixel_end },
    { reciphi, reciphi_end },
    { NULL, NULL }
};


/* various hint information */
static int texture_filter = M3D_NONE;
static int edge_aa = M3D_NONE;
static int pixel_type = 0;

static void (*end_scene_fn)(mmlGC *gc, mmlDisplayPixmap *region, m2dRect *rect);
static void null_end_scene(mmlGC *, mmlDisplayPixmap *, m2dRect *);
static void vmlabs_end_scene(mmlGC *, mmlDisplayPixmap *, m2dRect *);
static void edgeonly_end_scene(mmlGC *, mmlDisplayPixmap *, m2dRect *);

/* give a hint to the renderer about how pixels should
 * be drawn
 */

#if !INCLUDE_EDGEAA
#define aabilerp_init bilerp_init
#define aabilerp_end bilerp_end
#endif

void m3dHint(int what, int how)
{
    int *valptr;
    long *func_start, *func_end;

    switch(what) {
    case M3D_MPE_USAGE:
	/* ignore this hint, it's obsolete */
	return;
    case M3D_TEXTURE_FILTER:
	valptr = &texture_filter;
	break;
    case M3D_EDGE_AA:
	valptr = &edge_aa;
	break;
    case M3D_PIXEL_MPEG:
        valptr = &pixel_type;
        break;
    default:
	/* illegal value */
	return;
    }

    if (*valptr == how)
	return;   /* no change in pipeline */

    *valptr = how;

    /* rebuild pipeline */

    /* figure out polygon drawing function */
    if (edge_aa == M3D_NONE) {
	func_start = drawpoly_init;
	func_end = drawpoly_end;
    } else {
#if INCLUDE_EDGEAA
	func_start = aadrawpoly_init;
	func_end = aadrawpoly_end;
#else
	func_start = drawpoly_init;
	func_end = drawpoly_end;
#endif
    }

    if (pipe_parts[DRAWPOLY_PART].start != func_start) {
	pipe_parts[DRAWPOLY_PART].start = func_start;
	pipe_parts[DRAWPOLY_PART].end = func_end;
	pipe_changed = 1;
    }

    /* figure out pixel drawing function */
    if (pixel_type != 0) {
        /* MPEG pixels!! */
        func_start = mpegpixel_init;
        func_end = mpegpixel_end;
    } else {
        if (texture_filter == M3D_NONE) {
            if (edge_aa == M3D_NONE) {
                func_start = pixel_init;
                func_end = pixel_end;
            } else {
                func_start = aabilerp_init;
                func_end = aabilerp_end;
            }
        } else {
            if (edge_aa == M3D_NONE) {
                func_start = bilerp_init;
                func_end = bilerp_end;
            } else {
                func_start = aabilerp_init;
                func_end = aabilerp_end;
            }
        }
    }

    if (pipe_parts[PIXEL_PART].start != func_start) {
	pipe_parts[PIXEL_PART].start = func_start;
	pipe_parts[PIXEL_PART].end = func_end;
	pipe_changed = 1;
    }

    /* figure out end-of-scene code */
    if (edge_aa == M3D_EDGE_VMLABS) {
	end_scene_fn = vmlabs_end_scene;
    } else if (edge_aa == M3D_EDGE_ONLY) {
	end_scene_fn = edgeonly_end_scene;
    } else {
	end_scene_fn = null_end_scene;
    }
}

/*
 * execute a buffer
 */

#define MIN_Z 4

#ifdef DEBUG
long m3dNumCalls;
#endif

static m3dParams myparms __attribute__(( section("data"), aligned(16) ));

void
m3dExecuteBuffer(mmlGC *gc, mmlDisplayPixmap *pixmap, m2dRect *rect, m3dBuf *buf, m3dMatrix *objM,
		 m3dCamera *cam, m3dLightData *lights)
{
    int i, j;

    extern m3dParams initparam;

#if 1
    m3dParams *parms;

    parms = &myparms;
#else
    m3dParams parms[1];
#endif
    if (pipe_changed && cur_3d_pipe) {
	Free3DPipe(cur_3d_pipe);
	cur_3d_pipe = 0;
    }

    if (!cur_3d_pipe) {
	cur_3d_pipe = Build3DPipe(pipe_parts, &initparam);
	pipe_changed = 0;
    }

    /* initialize parameter block data */
    *parms = initparam;

    /* set up destination render */
    parms->dmaFlags = pixmap->dmaFlags | (DMA_ZMODE << 1);
    parms->dmaBaseAddr = pixmap->memP;
    parms->minx = rect->leftTop.x;
    parms->miny = rect->leftTop.y;
    parms->maxx = rect->rightBot.x;
    parms->maxy = rect->rightBot.y;

    /* set up the viewing parameters -- the camera matrix
       is assumed to carry the world->camera transfrom,
       and the object matrix the object->world transfrom
     */
    m3dMatrixMultiply(&parms->camera.matrix, &cam->matrix, objM);

    /* lights are in world space -- transform them to
       camera space */
    parms->lights.ambient = lights->ambient;
    parms->lights.numlights = lights->numlights;
    for (i = 0; i < lights->numlights; i++) {
	m3dMatrix *M = &cam->matrix;
	parms->lights.li[i].x = FixMul(M->r[0][0],lights->li[i].x,M3D_SHIFT) +
	    FixMul(M->r[0][1],lights->li[i].y,M3D_SHIFT) +
	    FixMul(M->r[0][2],lights->li[i].z,M3D_SHIFT);
	parms->lights.li[i].y = FixMul(M->r[1][0],lights->li[i].x,M3D_SHIFT) +
	    FixMul(M->r[1][1],lights->li[i].y,M3D_SHIFT) +
	    FixMul(M->r[1][2],lights->li[i].z,M3D_SHIFT);
	parms->lights.li[i].z = FixMul(M->r[2][0],lights->li[i].x,M3D_SHIFT) +
	    FixMul(M->r[2][1],lights->li[i].y,M3D_SHIFT) +
	    FixMul(M->r[2][2],lights->li[i].z,M3D_SHIFT);
	parms->lights.li[i].intense = lights->li[i].intense;
    }

    /* the rendering pipeline wants 2.30 numbers */
    for (i = 0; i < 3; i++) {
	for (j = 0; j < 3; j++) {
	    parms->camera.matrix.r[i][j] = parms->camera.matrix.r[i][j] << 14;
	}
    }

    parms->camera.backClip = cam->backClip;
    parms->camera.focalLength = FixMul(cam->focalLength, (rect->rightBot.x - rect->leftTop.x), 0);
    parms->center_x = M3DI((rect->rightBot.x + rect->leftTop.x)/2);
    parms->center_y = M3DI((rect->rightBot.y + rect->leftTop.y)/2);

    parms->model_data = buf->entries;

    /* set up the clipping planes */

    /*	each clipping plane is a small vector P such that P*(x,y,z,1) >= 0 iff
     *  (x,y,z) is on the visible side of the plane.
     *  the clipping planes are calculated in the order
     *     z >= MIN_Z
     *     x >= 0
     *     x < width
     *     y >= 0
     *     y < height
     *     z < back
     *
     * It is important that the z>=1 clipping plane come first, since if a polygon
     * needs clipping against this plane, it is very likely that the resulting
     * (clipped) polygon will have to be clipped against all other planes.
     */

    memset(parms->clip_plane, 0, sizeof(parms->clip_plane));

    /* calculate plane for z >= MIN_Z
     * i.e. z - MIN_Z >= 0
     */
    parms->clip_plane[0].nz = 1;
    parms->clip_plane[0].nd = -MIN_Z;

    /* calculate plane for x >= minx
     * the perspective transform is x = xcenter + (focald*x)/z
     * so we want x*focald + z*xcenter >= minx * z
     * i.e. x * focald + z * (xcenter - minx) >= 0
     */
    parms->clip_plane[1].nx = (parms->camera.focalLength >> 16);
    parms->clip_plane[1].nz = (parms->center_x >> 16) - (rect->leftTop.x+1);

    /* for x < maxx, we need x*focald + (xcenter-maxx)*z < 0, i.e.
       x*(-focald) + (maxx - xcenter)*z >= 0 */
    parms->clip_plane[2].nx = -(parms->camera.focalLength>>16);
    parms->clip_plane[2].nz = (rect->rightBot.x) - (parms->center_x >> 16);

    /* calculate plane for y >= miny
     * the perspective transform is y = ycenter + (focald*y)/z
     * i.e. y * focald + z * (ycenter - miny) >= 0
     */
    parms->clip_plane[3].ny = (parms->camera.focalLength >> 16);
    parms->clip_plane[3].nz = (parms->center_y >> 16) - (rect->leftTop.y+1);

    /* for x < maxx, we need y*focald + (ycenter-maxy)*z < 0, i.e.
       y*(-focald) + (maxy - ycenter)*z >= 0 */
    parms->clip_plane[4].ny = -(parms->camera.focalLength>>16);
    parms->clip_plane[4].nz = (rect->rightBot.y) - (parms->center_y >> 16);

    /* finally, for z < MAX_Z => z - MAX_Z < 0 => -z + MAX_Z >= 0 */
    parms->clip_plane[5].nz = -1;
    parms->clip_plane[5].nd = (parms->camera.backClip >> 16);


    /* there are 7 entries per triangle: 1 for the header,
       plus 2 per each of 3 points */
    parms->num_polys = buf->numentries/7;

#ifdef DEBUG
    m3dNumCalls++;
#endif

#if RUN_IN_PLACE
    if (m3dRunInPlace) {
	RunPipe( pipe_init-1, parms, sizeof(*parms), m3dNumMPEs, mpe_list );
    } else {
	RunPipe( cur_3d_pipe, parms, sizeof(*parms), m3dNumMPEs, mpe_list );
    }
#else
    Run3DPipe(mpe_list, m3dNumMPEs, cur_3d_pipe, parms);
#endif
}

/*
 * finish drawing a scene
 */

/* trivial version -- does nothing */
static void
null_end_scene(mmlGC *gc, mmlDisplayPixmap *pixmap, m2dRect *rect)
{
}

/* fancier version -- does edge anti-aliasing */
/* but only in 32+32, for now */

static void
vmlabs_end_scene(mmlGC *gc, mmlDisplayPixmap *pixmap, m2dRect *rect)
{
#if INCLUDE_EDGEAA
    extern long aacode_start[], aacode_size[], vm_aadummy[];
    long *dummy;
    int numlines;
    int pixtype;
    int mpes, i;
    int run_self;
    static struct aaregion {
	long dmaFlags;
	void *dmaBaseAddr;
	short minx;
	short maxx;
	short miny;
	short maxy;
    } region[4];

    /* do-nothing code to make sure we link with aaend.s */
    dummy = vm_aadummy;

    /* figure out pixel type; if it's not e888AlphaZ, then
     * punt (for now)
     */
    pixtype = (pixmap->dmaFlags >> 4) & 0xf;
    if (pixtype != 6)
	return;

    /* figure out how many MPEs to use */
    mpes = m3dNumMPEs;
    if (mpes > MAX_MPES)
	mpes = MAX_MPES;
    else if (mpes < 1)
	mpes = 1;


    /* set up the regions to anti-alias */
    /* also note that we have to overlap 1 line per region */
    /* this calculation will end up leaving a little bit of uncovered area
       at the bottom, but in fact aaend.s is a bit sloppy and it's probably
       good to have this protection against overflow! */

    numlines = ((rect->rightBot.y - rect->leftTop.y))/mpes - 1;

    run_self = -1;
    for (i = 0; i < mpes; i++) {
	region[i].dmaFlags = pixmap->dmaFlags;
	region[i].dmaBaseAddr = pixmap->memP;
	region[i].minx = rect->leftTop.x;
	region[i].maxx = rect->rightBot.x;
	region[i].miny = rect->leftTop.y + i*numlines;
	region[i].maxy = region[i].miny + numlines + 1;
	if (mpe_list[i] <= 0)
	    run_self = i;
	else {
	    StartMPE(mpe_list[i], aacode_start, (int)aacode_size, &region[i], sizeof(region[i]));
	}
    }

    if (run_self >= 0) {
	_trampoline(aacode_start, (int)aacode_size, &region[run_self], sizeof(region[0]));
    }

    /* wait for the other MPEs to finish */
    for (i = 0; i < mpes; i++) {
	if (mpe_list[i] > 0)
	    WaitMPE(mpe_list[i]);
    }
#endif
}

/* eliminate all BUT edges */
static void
edgeonly_end_scene(mmlGC *gc, mmlDisplayPixmap *pixmap, m2dRect *rect)
{
#if INCLUDE_EDGEAA
    extern long edgcode_start[], edgcode_size[], vm_aadummy[];
    long *dummy;
    int numlines;
    int pixtype;
    int mpes, i;
    int run_self;
    static struct aaregion {
	long dmaFlags;
	void *dmaBaseAddr;
	short minx;
	short maxx;
	short miny;
	short maxy;
    } region[4];

    /* do-nothing code to make sure we link with aaend.s */
    dummy = vm_aadummy;

    /* figure out pixel type; if it's not e888AlphaZ, then
     * punt (for now)
     */
    pixtype = (pixmap->dmaFlags >> 4) & 0xf;
    if (pixtype != 6)
	return;

    /* figure out how many MPEs to use */
    mpes = m3dNumMPEs;
    if (mpes > MAX_MPES)
	mpes = MAX_MPES;
    else if (mpes < 1)
	mpes = 1;


    /* set up the regions to anti-alias */
    /* also note that we have to overlap 1 line per region */
    /* this calculation will end up leaving a little bit of uncovered area
       at the bottom, but in fact aaend.s is a bit sloppy and it's probably
       good to have this protection against overflow! */

    numlines = ((rect->rightBot.y - rect->leftTop.y))/mpes - 1;

    run_self = -1;
    for (i = 0; i < mpes; i++) {
	region[i].dmaFlags = pixmap->dmaFlags;
	region[i].dmaBaseAddr = pixmap->memP;
	region[i].minx = rect->leftTop.x;
	region[i].maxx = rect->rightBot.x;
	region[i].miny = rect->leftTop.y + i*numlines;
	region[i].maxy = region[i].miny + numlines + 1;
	if (mpe_list[i] <= 0)
	    run_self = i;
	else {
	    StartMPE(mpe_list[i], edgcode_start, (int)edgcode_size, &region[i], sizeof(region[i]));
	}
    }

    if (run_self >= 0) {
	_trampoline(edgcode_start, (int)edgcode_size, &region[run_self], sizeof(region[0]));
    }

    /* wait for the other MPEs to finish */
    for (i = 0; i < mpes; i++) {
	if (mpe_list[i] > 0)
	    WaitMPE(mpe_list[i]);
    }
#endif
}

void
m3dEndScene(mmlGC *gc, mmlDisplayPixmap *pix, m2dRect *rect)
{
    if (end_scene_fn)
	(*end_scene_fn)(gc, pix, rect);
}

/*
 * initialization function
 * parameter:
 * -1 to use all available MPEs
 * 0 to use only this MPE, and to run
 * code in place
 * n to use at most n MPEs (including
 * the current MPE)
 *
 * FIXME: this should really set some fields
 * in the mmlSysResources structure!
 */

void
m3dInit(mmlSysResources *sr, int mpes)
{
    static int do_only_once = 0;
    int i;
    int num;

    /* stuff that should only be done once */
    if (!do_only_once) {
	/* make a grey default material */
	m3dInitMaterialFromColor(&defaultmaterial, 0x80808000);

	do_only_once = 1;
    }

    /* other things; in particular, we are
       allowed to re-set the number of MPEs to
       use */

    /* free any MPEs we allocated earlier */
    for (i = 0; i < m3dNumMPEs; i++) {
        _MPEFree(mpe_list[i]);
    }

    /* figure out how many MPEs to use */
    if (mpes < 0) {
	mpes = MAX_MPES;
    } else if (mpes == 0) {
        /* this doesn't work any more! */
        _exit(0x1111);
    } else {
	if (mpes > MAX_MPES)
	    mpes = MAX_MPES;
    }
    m3dNumMPEs = mpes;

    /* now allocate the MPEs */
    /* the rendering code will work fine with or without
       the mini-bios (it doesn't use the comm bus or
       interrupts) but unfortunately we can just ask
       for "any old MPE"; we have to ask for
       "with mini-bios" and "without mini-bios"
       seperately */

    i = 0;

#if 0
    /* the code may not really be compatible with the mini-bios */
    /* first, try to get a mini-bios MPE */
    num = _MPEAlloc(MPE_HAS_MINI_BIOS);
    if (num >= 0) {
	mpe_list[i] = num;
	i++;
    }
#endif
    /* now try to get any other MPEs we need */
    for (; i < m3dNumMPEs; i++) {
        num = _MPEAlloc(0);
        if (num == -1) {  /* no more MPEs */
            break;
        } else {
            mpe_list[i] = num;
        }
    }
    m3dNumMPEs = i;

    if (cur_3d_pipe) {
	Free3DPipe(cur_3d_pipe);
	cur_3d_pipe = (long *)0;
    }
}
