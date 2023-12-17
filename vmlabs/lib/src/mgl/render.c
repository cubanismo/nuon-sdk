/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

#include <nuon/bios.h>
#include "gl.h"
#include "globals.h"
#include "glutils.h"
#include "debug.h"

extern void ValidateGC(void);
extern void ValidateMPE(int);

extern const int vertexSize[];

GLbitfield RenderDirect(GLenum, const long *, long, int);

// TEMPORARY: develop format converters as needed and plug them into this table
// rendering this way will be slow!!
// indices are [inputVertexFormat][expectedVertexFormat]
static GLbitfield (*RenderIndirect[VERTEX_FORMAT_COUNT][VERTEX_FORMAT_COUNT])
                        (GLenum, const long *, long, int) = {

    // VERTEX_XYZWUVN
    {
        RenderDirect,                           // VERTEX_XYZWUVN
        NULL,                                   // VERTEX_XYZC
        NULL,                                   // VERTEX_XYZN
    },

    // VERTEX_XYZC
    {
        NULL,                                   // VERTEX_XYZWUVN
        RenderDirect,                           // VERTEX_XYZC
        NULL,                                   // VERTEX_XYZN
    },

    // VERTEX_XYZN
    {
        NULL,                                   // VERTEX_XYZWUVN
        NULL,                                   // VERTEX_XYZC
        RenderDirect,                           // VERTEX_XYZN
    },
};

// a _DCacheSync() is assumed to have been performed
// vertexBufferSize is in scalars
GLbitfield RenderDirect(GLenum vertexFormat, const long *vertexBuffer,
                long vertexBufferSize, int numMPEs)
{
    int mpeIndex, vertexBlockSize, i;
    long packet[4];
    GLMPE *mpe;
    GLbitfield bitfield;

    if (numMPEs <= 0) {
        numMPEs = 1;
    } else if (numMPEs > gc->numMPEs) {
        numMPEs = gc->numMPEs;
    }

    bitfield = 0;

    vertexBlockSize = 6 * vertexSize[vertexFormat];                     // two triangles

    packet[0] = (long)vertexBuffer;                                     // vertex pointer
    packet[1] = numMPEs * vertexBlockSize;                              // stride in scalars
    packet[2] = vertexBufferSize;                                       // buffer size in scalars
    packet[3] = 0;                                                      // unused

    for (i = 0; (i < numMPEs) && (packet[2] > 0); i++) {

        mpeIndex = WaitForAnyMPE();
        bitfield |= 1 << mpeIndex;
        mpe = &(gc->mpe[mpeIndex]);

        if (mpe->validationFlags != 0) {
            ValidateMPE(mpeIndex);
        }

        DEBUG_ASSERT(packet[2] > 0);

        mpe->taskCounter++;
        _CommSendInfo(mpe->commBusId, MPE_TASK_RENDER, packet);

        packet[0] += vertexBlockSize << 2;                              // advance vertex pointer
        packet[2] -= vertexBlockSize;                                   // decrement buffer size
    }

    return bitfield;
}

// a _DCacheSync() is assumed to have been performed
GLbitfield mglDrawBuffer(GLenum mode, GLenum vertexFormat, const long *vertexBuffer,
            long vertexCount, int numMPEs)
{
    long vertexBufferSize;
    GLbitfield (*fn)(GLenum, const long *, long, int);
    GLbitfield bitfield = 0;

#ifdef GL_TRACE_API
    printf("mglDrawBuffer(%s)\n", GLConstantString(mode));
#endif

#ifdef DEBUG

    switch (mode) {
    case GL_POINTS:
    case GL_LINES:
    case GL_LINE_STRIP:
    case GL_LINE_LOOP:
        printf("Error: unimplemented mode for mglDrawBuffer()\n");
        gc->errorCode = GL_INVALID_OPERATION;   // good enough
        return;
    case GL_TRIANGLES:
        break;
    case GL_TRIANGLE_STRIP:
    case GL_TRIANGLE_FAN:
    case GL_QUADS:
    case GL_QUAD_STRIP:
    case GL_POLYGON:
        printf("Error: unimplemented mode for mglDrawBuffer()\n");
        gc->errorCode = GL_INVALID_OPERATION;   // good enough
        return;
    default:
        printf("Error: invalid mode for mglDrawBuffer()\n");
        gc->errorCode = GL_INVALID_ENUM;
        return;
    }

    if (gc->beginEndFlag) {
        printf("mglDrawBuffer: already within begin/end block.\n");
        gc->errorCode = GL_INVALID_OPERATION;
        return;
    }

#endif

    if (vertexCount == 0) {
        return bitfield;
    }

    DEBUG_ASSERT((0 <= vertexFormat) && (vertexFormat < VERTEX_FORMAT_COUNT));

    // Check for primitive change

    if (mode != gc->primitive) {
        gc->primitive = mode;
        gc->validationFlags |= VAL_PIPELINE;
    }

    // Validate GC

    if (gc->validationFlags != 0) {
        ValidateGC();
    }

    // Render geometry

    vertexBufferSize = vertexCount * vertexSize[vertexFormat];

    if (vertexFormat == gc->vertexFormat) {

        bitfield = RenderDirect(vertexFormat, vertexBuffer, vertexBufferSize, numMPEs);

    } else {

        fn = RenderIndirect[vertexFormat][gc->vertexFormat];

        if (fn != NULL) {
            bitfield = (*fn)(vertexFormat, vertexBuffer, vertexBufferSize, numMPEs);
        } else {
#ifdef DEBUG
            printf("Error: Given vertex format %d, but need vertex format %d\n", vertexFormat, gc->vertexFormat);
#endif
            gc->errorCode = GL_INVALID_OPERATION;   // good enough
        }
    }

    return bitfield;
}
