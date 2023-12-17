/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

#include "gl.h"
#include "context.h"
#include "globals.h"
#include "glutils.h"
#include "debug.h"
#include <nuon/bios.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <stdlib.h>
#include <stdarg.h>

#if defined(DEBUG) || defined(GL_TRACE_API)
unsigned char *GLConstantString(int cons) {
    switch(cons) {

    // Fog types
    case GL_FOG_MODE:
        return "GL_FOG_MODE";
    case GL_FOG_DENSITY:
        return "GL_FOG_DENSITY";
    case GL_FOG_START:
        return "GL_FOG_START";
    case GL_FOG_END:
        return "GL_FOG_END";
    case GL_FOG_COLOR:
        return "GL_FOG_COLOR";
    case GL_FOG_INDEX:
        return "GL_FOG_INDEX";

    // Matrix types
    case GL_MODELVIEW:
        return "GL_MODELVIEW";
    case GL_PROJECTION:
        return "GL_PROJECTION";
    case GL_TEXTURE:
        return "GL_TEXTURE";

    // Get String stuff
    case GL_VENDOR:
        return "GL_VENDOR";
    case GL_VERSION:
        return "GL_VERSION";
    case GL_RENDERER:
        return "GL_RENDERER";
    case GL_EXTENSIONS:
        return "GL_EXTENSIONS";

    // Enables
    case GL_ALPHA_TEST:
        return "GL_ALPHA_TEST";
    case GL_BLEND:
        return "GL_BLEND";
    case GL_CULL_FACE:
        return "GL_CULL_FACE";
    case GL_DEPTH_TEST:
        return "GL_DEPTH_TEST";
    case GL_DITHER:
        return "GL_DITHER";
    case GL_LIGHTING:
        return "GL_LIGHTING";
    case GL_LIGHT0:
        return "GL_LIGHT0";
    case GL_LIGHT1:
        return "GL_LIGHT1";
    case GL_LIGHT2:
        return "GL_LIGHT2";
    case GL_LIGHT3:
        return "GL_LIGHT3";
    case GL_LIGHT4:
        return "GL_LIGHT4";
    case GL_LIGHT5:
        return "GL_LIGHT5";
    case GL_LIGHT6:
        return "GL_LIGHT6";
    case GL_LIGHT7:
        return "GL_LIGHT7";
    case GL_TEXTURE_1D:
        return "GL_TEXTURE_1D";
    case GL_TEXTURE_2D:
        return "GL_TEXTURE_2D";

    // Filtering modes
    case GL_LINEAR:
        return "GL_LINEAR";
    case GL_NEAREST:
        return "GL_NEAREST";
    case GL_LINEAR_MIPMAP_NEAREST:
        return "GL_LINEAR_MIPMAP_NEAREST";
    case GL_NEAREST_MIPMAP_NEAREST:
        return "GL_NEAREST_MIPMAP_NEAREST";

    // Depth/Alpha tests
    case GL_ALWAYS:
        return "GL_ALWAYS";
    case GL_NEVER:
        return "GL_NEVER";
    case GL_LESS:
        return "GL_LESS";
    case GL_LEQUAL:
        return "GL_LEQUAL";
    case GL_EQUAL:
        return "GL_EQUAL";
    case GL_GEQUAL:
        return "GL_GEQUAL";
    case GL_GREATER:
        return "GL_GREATER";
    case GL_NOTEQUAL:
        return "GL_NOTEQUAL";

    // Primitives
    case GL_POINTS:
        return "GL_POINTS";
    case GL_LINES:
        return "GL_LINES";
    case GL_LINE_LOOP:
        return "GL_LINE_LOOP";
    case GL_LINE_STRIP:
        return "GL_LINE_STRIP";
    case GL_TRIANGLES:
        return "GL_TRIANGLES";
    case GL_TRIANGLE_STRIP:
        return "GL_TRIANGLE_STRIP";
    case GL_TRIANGLE_FAN:
        return "GL_TRIANGLE_FAN";
    case GL_QUADS:
        return "GL_QUADS";
    case GL_QUAD_STRIP:
        return "GL_QUAD_STRIP";
    case GL_POLYGON:
        return "GL_POLYGON";

    // Clear screen stuff
//  case GL_COLOR_BUFFER_BIT:
//      return "GL_COLOR_BUFFER_BIT";
    case GL_DEPTH_BUFFER_BIT:
        return "GL_DEPTH_BUFFER_BIT";

    // Lighting model/Material stuff
    case GL_LIGHT_MODEL_AMBIENT:
        return "GL_LIGHT_MODEL_AMBIENT";
    case GL_LIGHT_MODEL_LOCAL_VIEWER:
        return "GL_LIGHT_MODEL_LOCAL_VIEWER";
    case GL_LIGHT_MODEL_TWO_SIDE:
        return "GL_LIGHT_MODEL_TWO_SIDE";
    case GL_EMISSION:
        return "GL_EMISSION";
    case GL_AMBIENT:
        return "GL_AMBIENT";
    case GL_DIFFUSE:
        return "GL_DIFFUSE";
    case GL_AMBIENT_AND_DIFFUSE:
        return "GL_AMBIENT_AND_DIFFUSE";
    case GL_SPECULAR:
        return "GL_SPECULAR";
    case GL_SHININESS:
        return "GL_SHININESS";
    case GL_POSITION:
        return "GL_POSITION";
    case GL_SPOT_DIRECTION:
        return "GL_SPOT_DIRECTION";
    case GL_SPOT_EXPONENT:
        return "GL_SPOT_EXPONENT";
    case GL_SPOT_CUTOFF:
        return "GL_SPOT_CUTOFF";
    case GL_CONSTANT_ATTENUATION:
        return "GL_CONSTANT_ATTENUATION";
    case GL_LINEAR_ATTENUATION:
        return "GL_LINEAR_ATTENUATION";
    case GL_QUADRATIC_ATTENUATION:
        return "GL_QUADRATIC_ATTENUATION";
    case GL_FRONT:
        return "GL_FRONT";
    case GL_BACK:
        return "GL_BACK";
    case GL_FRONT_AND_BACK:
        return "GL_FRONT_AND_BACK";
    default:
        return "UNKNOWN";
    }
}

#endif

// Returns 24 bit YCrCbAlpha color with Alpha = 0
GLuint mglColorFromRGB(GLuint r, GLuint g, GLuint b) {
    GLuint color;
    GLuint y  =  (4899 * r + 9617 * g + 1868 * b) >> 8;
    GLuint cr =  (8192 * r - 6865 * g - 1327 * b + 8192 * 256) >> 8;
    GLuint cb = (-2769 * r - 5423 * g + 8192 * b + 8192 * 256) >> 8;

    // Make sure components are in legal range
    if (y < 0)
        y = 0;
    if (y > 16384)
        y = 16384;
    if (cr < 0)
        cr = 0;
    if (cr > 16384)
        cr = 16384;
    if (cb < 0)
        cb = 0;
    if (cb > 16384)
        cb = 16384;

    /* 0.5 added below to force rounding */
    y  = ((y  * 219 + 8192) >> 14) + 16;
    cr = ((cr * 224 + 8192) >> 14) + 16;
    cb = ((cb * 224 + 8192) >> 14) + 16;
    color = (y<<24) | (cr << 16 ) | (cb << 8);
    return color;
}


// Returns 16 bit YCrCb color in upper 16 bits
GLuint mglColor16FromRGB(GLuint r, GLuint g, GLuint b) {
    GLuint color;
    GLuint y  =  (4899 * r + 9617 * g + 1868 * b) >> 8;
    GLuint cr =  (8192 * r - 6865 * g - 1327 * b + 8192 * 256) >> 8;
    GLuint cb = (-2769 * r - 5423 * g + 8192 * b + 8192 * 256) >> 8;

    // Make sure components are in legal range
    if (y < 0)
        y = 0;
    if (y > 16384)
        y = 16384;
    if (cr < 0)
        cr = 0;
    if (cr > 16384)
        cr = 16384;
    if (cb < 0)
        cb = 0;
    if (cb > 16384)
        cb = 16384;

    y  = ((y  * 55) >> 14) + 4;
    cr = ((cr * 28 + 8192) >> 14) + 2;
    cb = ((cb * 28 + 8192) >> 14) + 2;
    color = (y<<26) | (cr << 21 ) | (cb << 16);
    return color;
}

// dstAddr is a relative address
// srcAddr is an absolute address
// size is in scalars
// a _DCacheSync() is assumed to have been performed
//
void DMAToMPE(int mpeIndex, void *dstAddr, const void *srcAddr, long size)
{
    long blockSize, flags, extra, i;
    void *baseAddr, *intAddr;

    blockSize = IS_SDRAM(srcAddr) ? 64 : 32;
    flags = (1 << 28) | (blockSize << 16) | (1 << 13);
    baseAddr = (void *)srcAddr;
    intAddr = dstAddr + (gc->mpe[mpeIndex].commBusId << 23);
    extra = size & (blockSize - 1);
    size -= extra;

    for (i = 0; i < size; i += blockSize) {
        _DMALinear(flags, baseAddr, intAddr);
        baseAddr += blockSize << 2;
        intAddr += blockSize << 2;
    }

    if (extra != 0) {
        flags = (1 << 28) | (extra << 16) | (1 << 13);
        _DMALinear(flags, baseAddr, intAddr);
    }
}

void WaitForMPE(int mpeIndex)
{
    GLMPE *mpe = &(gc->mpe[mpeIndex]);

    // mpe->taskCounter is declared volatile
    while (mpe->taskCounter != 0)
        ;
}

int WaitForAnyMPE(void)
{
    int mpeIndex;

    while (1) {
        for (mpeIndex = 0; mpeIndex < gc->numMPEs; mpeIndex++) {
            if (gc->mpe[mpeIndex].taskCounter == 0) {
                return mpeIndex;
            }
        }
    }
}

void WaitForAllMPEs(void)
{
    int mpeIndex;

    for (mpeIndex = 0; mpeIndex < gc->numMPEs; mpeIndex++) {
        WaitForMPE(mpeIndex);
    }
}

void mglWaitForMPEs(GLbitfield mpes)
{
    int mpeIndex;

    for (mpeIndex = 0; mpeIndex < gc->numMPEs; mpeIndex++) {
        if (mpes & (1 << mpeIndex)) {
            WaitForMPE(mpeIndex);
        }
    }
}

GLint mglCountIdleMPEs(void)
{
    int mpeIndex;
    int n = 0;

    for (mpeIndex = 0; mpeIndex < gc->numMPEs; mpeIndex++) {
        n += gc->mpe[mpeIndex].taskCounter == 0;
    }

    return 0;
}
