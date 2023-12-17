/*
 * Copyright (C) 1995-2001 VM Labs, Inc.
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
 * lib3d.h
 * various definitions for the 3D pipeline interface
 *
 */

/* fixed point numbers; this is really just for
 * documentation purposes, C doesn't know about
 * fixed point arithmetic
 */

typedef long fix16;
typedef long fix30;


/*
 * a structure representing a parameter block for a 3D
 * pipeline
 *
 * this structure should be in 1-1 correspondence with
 * the data structure given in "param.s"; see that
 * file for more complete documentation
 */
typedef struct m3dParams {
    long dmaFlags;      /* dma flags for the draw */
    void *dmaBaseAddr;   /* base address for the draw */
    short minx;
    short maxx;
    short miny;
    short maxy;

    long cur_mpe;
    long reserved1;
    long total_mpes;
    long num_polys;     /* number of polygons in the model_data segment */

    m3dCamera camera;
    m3dreal center_x;
    m3dreal center_y;

    void *model_data;
    long reserved2;

    /* pointers to pipeline component functions */
    /* there are NUM_PIPE_FUNCS of these */
    /* currently these are:
     *   top level pipeline
     *   polygon load function
     *   vertex transform function
     *   perspective function
     *   clip code calculation function
     *   clipping function
     *   vertex lighting function
     *   polygon draw function
     *   pixel generating function
     *   reciprocal function
     */

    #define NUM_PIPE_FUNCS 9
    void *pipe_funcs[NUM_PIPE_FUNCS];

    long reserved3;

    /* lighting information */
    m3dLightData lights;

    /* up to 8 clipping planes */
    m3dClipPlane clip_plane[8];

    /* table used for the "recip" function */
    long reciptable[64];

} m3dParams;


/*
 * a structure representing a pipeline component
 * "start" is a pointer to the start of the code,
 * "end" is a pointer to the end of the code.
 * NOTE: the type is misleading here; in fact
 * the code may not end on a long boundary (strictly
 * speaking "short *" would be more appropriate).
 * But by imposing the restriction that the code start
 * on a longword boundary, we can use much more
 * efficient long word copies rather than short
 * copies.
 */

typedef struct pipe_piece {
    long *start, *end;
} PipeComponent;

/*
 * defines for the pipe components
 */
#define TOP_PART 0
#define LOADPOLY_PART 1
#define XFORM_PART 2
#define PERSP_PART 3
#define CALCCLIP_PART 4
#define DOCLIP_PART 5
#define LIGHT_PART 6
#define DRAWPOLY_PART 7
#define PIXEL_PART 8
#define RECIP_PART 9

long *Build3DPipe(PipeComponent *piece, m3dParams *param);
void Free3DPipe(long *pipe);

void Run3DPipe(int mpe_array[], int num_mpes, long *pipe, m3dParams *param);
