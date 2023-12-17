/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

#include "gl.h"
#include "mpedefs.h"
#include "mpemisc.h"
#include "glutils.h"
#include "debug.h"
#include <stdlib.h>
#include <stdarg.h>
#include <nuon/sdram.h>
#include <nuon/bios.h>
#include "globals.h"

extern void ValidateGC(void);
extern void FlushVertexBuffer(void);

GLint mglInit(mmlDisplayPixmap *screen, GLint pixelFilter, GLint numBuffers, GLint numMPEs)
{
	int mpeIndex, i, j;
	GLMPE *mpe;

	DEBUG_ASSERT(((long)MPEDMACache1 ^ (long)MPEDMACache2) == DMA_CACHE_EOR);	// see mpe_data.s

	// Attempt to allocate context
	gc = (GLContext *)calloc(1, sizeof(GLContext));					// gc memory initialized to 0
	if (gc == NULL) {
#ifdef DEBUG
		printf("mglInit: Memory allocation failure.\n");
#endif
		mglEnd();
		return -1; // failure
	}

	// set up context
	gc->pixelType = (screen[0].properties & 0xf0) >> 4;				// all screens same pixel type
	gc->validationFlags= ~0;
	gc->commBusId = GetCommBusId();

	// initialize MPE data structures

	if (numMPEs <= 0 || numMPEs > MAX_RENDERING_MPES) {
		numMPEs = MAX_RENDERING_MPES;
	}

	gc->numMPEs = 0;

	for (mpeIndex = 0; mpeIndex < numMPEs; mpeIndex++) {

		mpe = &(gc->mpe[mpeIndex]);
		mpe->commBusId = _MPEAlloc(0);						// try to get an MPE without minibios

		if (mpe->commBusId < 0) {
		    mpe->commBusId = _MPEAlloc(MPE_HAS_MINI_BIOS);	// try to get an MPE with minibios
			if (mpe->commBusId < 0) break;
		    mpe->minibios = GL_TRUE;
		} else {
		    mpe->minibios = GL_FALSE;
		}

		mpe->validationFlags |= VAL_MPE_INVALIDATED;
		mpe->initData[0] = gc->commBusId;
		mpe->initData[1] = (GLuint)&(mpe->taskCounter);
		gc->numMPEs++;
	}

	if (gc->numMPEs < 1) {
#ifdef DEBUG
		printf("mglInit: MPE allocation failure.\n");
#endif
		mglEnd();
		return -1; // failure
	}

	// Set up comm bus interrupt
	gc->oldCommRecvInterrupt = _IntSetVector(kIntrCommRecv, CommRecvInterrupt);

	// Initialize test functions
	gc->depthFunction = GL_LESS;
	gc->depthMask = GL_TRUE;

	// Initialize matrices
	gc->modelviewMatrix.m11 = gc->projectionMatrix.m11 = gc->textureMatrix.m11 =
	gc->modelviewMatrix.m22 = gc->projectionMatrix.m22 = gc->textureMatrix.m22 =
	gc->modelviewMatrix.m33 = gc->projectionMatrix.m33 =  gc->textureMatrix.m33 =
	gc->modelviewMatrix.m44 = gc->projectionMatrix.m44 = gc->textureMatrix.m44 = 1 << GLTRIGSHIFT;
	gc->currentMatrix = GL_MODELVIEW;

	// Initialize vertex data
	gc->currentVertex = -1;

	// Initialize vertex normal data
	gc->currentVertexNormal = 0x00004000;
	gc->currentNormal.z = 1 << GLNORMALSHIFT;

	// Initialize vertex color data
	gc->currentColor.r = gc->currentColor.g = gc->currentColor.b = gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor =
		COLOR_GRB888Alpha(gc->currentColor.r, gc->currentColor.g, gc->currentColor.b, gc->currentColor.a);

	gc->primitive = GL_TRIANGLES;

	switch (gc->pixelType) {
	case e655:
	case e655Z:
		gc->clearColorYCrCb = mglColor16FromRGB(gc->clearColor.r, gc->clearColor.g, gc->clearColor.b);
		break;

	case e888Alpha:
	case e888AlphaZ:
		gc->clearColorYCrCb = mglColorFromRGB(gc->clearColor.r, gc->clearColor.g, gc->clearColor.b);
		break;

	default:
		// shouldn't happen
		DEBUG_ASSERT(0);
		break;
	}

	gc->clearDepth = 0xffffffff;

	// Set up video
	gc->numBuffers = numBuffers;
	for (i = 0; i < numBuffers; i++) {
		gc->screenBuffer[i]= &screen[i];
	}

	gc->frontBuffer = 0;
	gc->backBuffer = 1;
	if (gc->numBuffers > 1) {
		gc->drawBuffer = GL_BACK;
		gc->renderBuffer = 1;
	}
	else {
		gc->drawBuffer = GL_FRONT;
		gc->renderBuffer = 0;
	}

    gc->vidMainChannel.dest_xoff = -1;
    gc->vidMainChannel.dest_yoff = -1;
    gc->vidMainChannel.dest_width = 720;
    gc->vidMainChannel.dest_height = 480;
    gc->vidMainChannel.src_width = gc->screenBuffer[0]->wide;		// all screens same width
    gc->vidMainChannel.src_height = gc->screenBuffer[0]->high;		// all screens same height
    gc->vidMainChannel.vfilter = pixelFilter;
    gc->vidMainChannel.hfilter = VID_HFILTER_4TAP;

	// Initialize viewport
	gc->viewportWidth = gc->screenBuffer[0]->wide;					// all screens same width
	gc->viewportHeight = gc->screenBuffer[0]->high;					// all screens same height
	gc->zFar = 1.0;

	// Initialize blending parameters
	gc->blendSrcFactor = GL_ONE;
	gc->blendDstFactor = GL_ZERO;

	// Initialize fog parameters
	gc->fogEnd = 1 << GLXYZWCLIPSHIFT;
	gc->fogDensity = 1;

	// Initialize lighting model and lights

	gc->lightModelAmbient.r = 0.2f * GLCOLORMAX;
	gc->lightModelAmbient.g = 0.2f * GLCOLORMAX;
	gc->lightModelAmbient.b = 0.2f * GLCOLORMAX;
	gc->lightModelAmbient.a = GLCOLORMAX;

	for (i = 0; i < MAX_LIGHTS; i++) {
		gc->light[i].c_amb.a = GLCOLORMAX;
		gc->light[i].c_dif.a = GLCOLORMAX;
		gc->light[i].pos.z = 1 << GLXYZWMODELSHIFT;
		gc->light[i].dir.z = -1.0f;
		gc->light[i].kc = 1.0f;
		gc->light[i].cutoff = 180.0f;
	}

	gc->light[0].c_dif.r = GLCOLORMAX;
	gc->light[0].c_dif.g = GLCOLORMAX;
	gc->light[0].c_dif.b = GLCOLORMAX;
	gc->light[0].c_spec = gc->light[0].c_dif;

	// Initialize materials
	gc->frontMaterial.c_amb.r = gc->backMaterial.c_amb.r = 0.2f * GLCOLORMAX;
	gc->frontMaterial.c_amb.g = gc->backMaterial.c_amb.g = 0.2f * GLCOLORMAX;
	gc->frontMaterial.c_amb.b = gc->backMaterial.c_amb.b = 0.2f * GLCOLORMAX;
	gc->frontMaterial.c_amb.a = gc->backMaterial.c_amb.a = GLCOLORMAX;
	gc->frontMaterial.c_dif.r = gc->backMaterial.c_dif.r = 0.8f * GLCOLORMAX;
	gc->frontMaterial.c_dif.g = gc->backMaterial.c_dif.g = 0.8f * GLCOLORMAX;
	gc->frontMaterial.c_dif.b = gc->backMaterial.c_dif.b = 0.8f * GLCOLORMAX;
	gc->frontMaterial.c_dif.a = gc->backMaterial.c_dif.a = GLCOLORMAX;
	gc->frontMaterial.c_spec.r = gc->backMaterial.c_spec.r = 0.8f * GLCOLORMAX;
	gc->frontMaterial.c_spec.g = gc->backMaterial.c_spec.g = 0.8f * GLCOLORMAX;
	gc->frontMaterial.c_spec.b = gc->backMaterial.c_spec.b = 0.8f * GLCOLORMAX;
	gc->frontMaterial.c_spec.a = gc->backMaterial.c_spec.a = GLCOLORMAX;
	gc->frontMaterial.c_emis.a = gc->backMaterial.c_emis.a = GLCOLORMAX;

	// Initialize texture object list

	gc->texObj = (GLTextureObject *)malloc(TEXTUREOBJECTGROWTHFACTOR * sizeof(GLTextureObject));

	if (gc->texObj == NULL) {
#ifdef DEBUG
		printf("Memory allocation failure for texture object list.\n");
#endif
		mglEnd();
		return -1; // failure
	}
	gc->textureObjects = TEXTUREOBJECTGROWTHFACTOR;
	gc->current2DObject = &(gc->texObj[0]);
	gc->current1DObject = &(gc->texObj[0]);
	for (i = 0; i < gc->textureObjects; i++) {
		gc->texObj[i].levels = 0;
		gc->texObj[i].boundFlag = GL_FALSE;
		gc->texObj[i].ID = -1;
		gc->texObj[i].priority = 0x40000000;		// Maximum priority
		gc->texObj[i].target = GL_TEXTURE_2D;
		gc->texObj[i].textureMode = GL_YCC16_EXT;
		gc->texObj[i].minFilter = GL_NEAREST_MIPMAP_LINEAR;
		gc->texObj[i].magFilter = GL_LINEAR;
		for (j = 0; j < 5; j++)
			gc->texObj[i].texture[j] = NULL;
	}

	// Initialize default texture object 0

	gc->defaultTexture = mglNewTexture(4, 4, e655, GL_FALSE);
	DEBUG_ASSERT(gc->defaultTexture != NULL);

	for (i = 0; i < 8; i++)
		gc->defaultTexture->pbuffer[i] = 0xde10de10;			// 2x2 white 16 bit pixels

	gc->texObj[0].ID = 0;
	gc->texObj[0].boundFlag = GL_TRUE;
	gc->texObj[0].levels = 1;
	gc->texObj[0].texture[0] = gc->defaultTexture;

	// Set default TexEnv mode
	gc->textureEnvMode = GL_MODULATE;

	// Return success
	return 0;
}

// Allocates a new texture
GLTexture *mglNewTexture(GLuint width, GLuint height, GLuint pixelType, GLuint sdramFlag) {

	GLuint size, n, clutOffset, clutSize, uvxyctl;
	GLTexture *tp;

	// Get texture info. The alignment computations assume that MPETextureCache is aligned to a
	// 1 kbyte boundary.

	clutOffset = 0;
	clutSize = 0;

	switch (pixelType) {

		case eClut4:
			size = (width >> 1) * height;			// pixmap
			n = size & 63;
			if (n > 0) size += 64 - n;				// padding for 64-byte CLUT alignment
			clutOffset = size;
			clutSize = 16;							// in scalars
			size += 4 * clutSize;					// CLUT
			uvxyctl = eClut4 << 20;
			break;

		case eClut8:
			size = width * height;					// pixmap
			n = size & 1023;
			if (n > 0) size += 1024 - n;			// padding for 1024-byte CLUT alignment
			clutOffset = size;
			clutSize = 256;							// in scalars
			size += 4 * clutSize;					// CLUT
			uvxyctl = eClut8 << 20;
			break;

		case e655:
			size = (width << 1) * height;			// pixmap
			uvxyctl = (1 << 28) | (e655 << 20);
			break;

		case e888Alpha:
			size = (width << 2) * height;			// pixmap
			uvxyctl = (1 << 28) | (e888Alpha << 20);
			break;

		case eClut4GRB888Alpha:
			size = (width >> 1) * height;			// pixmap
			n = size & 63;
			if (n > 0) size += 64 - n;				// padding for 64-byte CLUT alignment
			clutOffset = size;
			clutSize = 16;							// in scalars
			size += 4 * clutSize;					// CLUT
			uvxyctl = eClut4 << 20;
			break;

		case eClut8GRB888Alpha:
			size = width * height;					// pixmap
			n = size & 1023;
			if (n > 0) size += 1024 - n;			// padding for 1024-byte CLUT alignment
			clutOffset = size;
			clutSize = 256;							// in scalars
			size += 4 * clutSize;					// CLUT
			uvxyctl = eClut8 << 20;
			break;

		case eGRB655:
			size = (width << 1) * height;			// pixmap
			uvxyctl = e655 << 20;
			break;

		case eGRB888Alpha:
			size = (width << 2) * height;			// pixmap
			uvxyctl = e888Alpha << 20;
			break;

		default:
#ifdef DEBUG
			printf("Texture pixel buffer allocation failure.\n");
#endif
			return NULL;
	}

	// Allocate memory

	tp = (GLTexture *)malloc(sizeof(GLTexture));

	if (tp == NULL) {
#ifdef DEBUG
		printf("Texture struct allocation failure.\n");
#endif
		return NULL;
	}

	if (sdramFlag) {
		tp->pbuffer = (GLuint *)SDRAMAlloc(size);
	} else {
		tp->pbuffer = (GLuint *)malloc(size);
	}

	if (tp->pbuffer == NULL) {
#ifdef DEBUG
		printf("Texture data allocation failure.\n");
#endif
		free(tp);
		return NULL;
	}

	// Fill in remaining fields in texture struct
	
	tp->width = width;
	tp->height = height;
	tp->size = size >> 2;
	tp->pixelType = pixelType;
	tp->clut = (clutSize > 0) ? (tp->pbuffer + (clutOffset >> 2)) : NULL;
	tp->clutSize = clutSize;
	tp->mpeInfo[0] = uvxyctl | (tile(width) << 16) | (tile(height) << 12) | width;		// uvctl, xyctl
	tp->mpeInfo[1] = (clutSize > 0) ? ((GLuint)MPETextureCache + clutOffset) : 0;		// clutbase
	tp->mpeInfo[2] =
		((45+GLXYZWCLIPSHIFT-GLMINZSHIFT-16+GLTEXCOORDSHIFT-textureShift(width))<<8) |	// s, t shifts
		(45+GLXYZWCLIPSHIFT-GLMINZSHIFT-16+GLTEXCOORDSHIFT-textureShift(height));
	tp->dCacheSync = GL_TRUE;

	return tp;
}

void mglDeleteTexture(GLTexture *tp)
{
	if (tp == NULL) return;

	if (gc->texObj[0].texture[0] == tp) {

		gc->texObj[0].texture[0] = gc->defaultTexture;

		if (gc->texture1DEnable || gc->texture2DEnable) {

			gc->validationFlags |= VAL_TEXTURE;

			if (tp->pixelType != gc->defaultTexture->pixelType) {
				gc->validationFlags |= VAL_PIPELINE;
			}
		}
	}

	if (tp->pbuffer != NULL) {
		if (IS_SDRAM(tp->pbuffer)) {
			SDRAMFree(tp->pbuffer);
		} else {
			free(tp->pbuffer);
		}
	}

	free(tp);
}

void mglSetTexture(GLTexture *tp)
{
	GLTexture *oldtp = gc->texObj[0].texture[0];

	gc->texObj[0].texture[0] = (tp != NULL) ? tp : gc->defaultTexture;
	gc->texObj[0].levels = 1;

	if (gc->texture1DEnable || gc->texture2DEnable) {

		gc->validationFlags |= VAL_TEXTURE;

		if (gc->texObj[0].texture[0]->pixelType != oldtp->pixelType) {
			gc->validationFlags |= VAL_PIPELINE;
		}
	}
}

// Shuts down mgl and releases context
GLint mglEnd(void)
{
	int i, j, mpeIndex;

	// ensure that graphics context is allocated

	if (gc == NULL) {
		return -1;
	}

	// free textures

	if (gc->defaultTexture != NULL) {
		mglDeleteTexture(gc->defaultTexture);
	}

	if (gc->texObj) {

		for (i = 0; i < gc->textureObjects; i++) {
			if (gc->texObj[i].boundFlag) {
				for (j = 0; j < gc->texObj[i].levels; j++) {
					if (gc->texObj[i].texture[j] != gc->defaultTexture) {
						mglDeleteTexture(gc->texObj[i].texture[j]);
					}
				}
			}
		}

		free(gc->texObj);
	}

	// restore old comm bus interrupt

	if (gc->oldCommRecvInterrupt != NULL) {
		_IntSetVector(kIntrCommRecv, gc->oldCommRecvInterrupt);
	}

	// free MPEs

	for (mpeIndex = 0; mpeIndex < gc->numMPEs; mpeIndex++) {
	    _MPEStop(gc->mpe[mpeIndex].commBusId);
	    _MPEFree(gc->mpe[mpeIndex].commBusId);
	}

	// free graphics context

	free(gc);

	return 0;
}

// Returns DMA flags for render buffer
GLuint mglGetDMAFlags(void) {
	return gc->screenBuffer[gc->renderBuffer]->dmaFlags;
}

// Swaps display buffers
GLint mglSwapBuffers(void) {

	mmlDisplayPixmap *pp;

#ifdef GL_TRACE_API
	printf("mglSwapBuffers()\n");
#endif

	// finish all rendering

	if (gc->validationFlags != 0) {
		ValidateGC();
	}

	FlushVertexBuffer();

	WaitForAllMPEs();

	// Check for pending buffer swap and sit on it if so
	while (_VidSync(-1) == gc->fieldcount);

	// Advance draw buffers
	gc->frontBuffer++;
	if (gc->frontBuffer == gc->numBuffers)
		gc->frontBuffer = 0;
	gc->backBuffer++;
	if (gc->backBuffer == gc->numBuffers)
		gc->backBuffer = 0;

	// Determine new rendering buffer
	switch (gc->drawBuffer) {
	case GL_FRONT:
	case GL_FRONT_LEFT:
	case GL_FRONT_RIGHT:
	case GL_FRONT_AND_BACK:
		gc->renderBuffer = gc->frontBuffer;
		break;
	case GL_BACK:
	case GL_BACK_LEFT:
	case GL_BACK_RIGHT:
		gc->renderBuffer = gc->backBuffer;
		break;
	case GL_NONE:
		gc->renderBuffer = -1;
	}

	// Invalidate render buffer
	gc->validationFlags |= VAL_RENDER_BUFFER;

	// Set new display RAM
	pp = gc->screenBuffer[gc->frontBuffer];
    gc->vidMainChannel.dmaflags = pp->dmaFlags;
    gc->vidMainChannel.base = pp->memP;
    _VidConfig(NULL, &(gc->vidMainChannel), NULL, NULL);

	gc->fieldcount = _VidSync(-1);
	return 1;
}

// Holds until buffer swap
GLint mglVideoSync(void) {
	// Wait for video sync
	while (_VidSync(-1) == gc->fieldcount);
	return 1;
}

// Returns address of a specified buffer
mmlDisplayPixmap *mglGetBuffer(GLint buffer) {

	// Return appropriate buffer pointer
	switch (buffer) {
	case GL_FRONT:
		return gc->screenBuffer[gc->frontBuffer];
		break;
	case GL_BACK:
		return gc->screenBuffer[gc->backBuffer];
		break;
	default:
		return NULL;
	}
}
