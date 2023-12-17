/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

// Miscellaneous OpenGL API calling code: if I couldn't find someplace
// else for it, or it's stubbed out code, then it's probably here
#include "gl.h"
#include "mpedefs.h"
#include "context.h"
#include "globals.h"
#include "glutils.h"
#include "debug.h"
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <stdio.h>
#include <stdarg.h>

extern void ValidateGC(void);
extern void FlushVertexBuffer(void);

void glAccum(GLenum op, GLfloat value) {

}

void glAlphaFunc(GLenum func, GLclampf ref) {

}

GLboolean glAreTexturesResident(GLsizei n, const GLuint *textures, GLboolean *residences) {

	return 0;
}

void glArrayElement(GLint i) {

}


void glBindTexture(GLenum target, GLuint texture) {

}

void glBitmap(GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, const GLubyte *bitmap) {

}

void glBlendFunc(GLenum sfactor, GLenum dfactor)
{
#ifdef GL_TRACE_API
	printf("glBlendFunc(%d, %d)\n", sfactor, dfactor);
#endif

#ifdef DEBUG

	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glBlendFunc: already within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}

	switch (sfactor) {
	case GL_ZERO:
	case GL_ONE:
	case GL_DST_COLOR:
	case GL_ONE_MINUS_DST_COLOR:
	case GL_SRC_ALPHA:
	case GL_ONE_MINUS_SRC_ALPHA:
	case GL_DST_ALPHA:
	case GL_ONE_MINUS_DST_ALPHA:
	case GL_SRC_ALPHA_SATURATE:
		break;
	default:
		gc->errorCode = GL_INVALID_ENUM;
		printf("glBlendFunc:invalid sfactor\n");
		return;
	}
	
	switch (dfactor) {
	case GL_ZERO:
	case GL_ONE:
	case GL_SRC_COLOR:
	case GL_ONE_MINUS_SRC_COLOR:
	case GL_SRC_ALPHA:
	case GL_ONE_MINUS_SRC_ALPHA:
	case GL_DST_ALPHA:
	case GL_ONE_MINUS_DST_ALPHA:
		break;
	default:
		gc->errorCode = GL_INVALID_ENUM;
		printf("glBlendFunc:invalid dfactor\n");
		return;
	}

#endif

	if ((sfactor != gc->blendSrcFactor) || (dfactor != gc->blendDstFactor)) {
		gc->blendSrcFactor = sfactor;
		gc->blendDstFactor = dfactor;
		if (gc->blendEnable) gc->validationFlags |= VAL_PIPELINE;
	}
}

void glCallList(GLuint list) {

}

void glCallLists(GLsizei n, GLenum type, const GLvoid *lists) {

}


void glClear(GLbitfield mask)
{
	long dmaFlags, x, y;
	mmlDisplayPixmap *pp;
	GLuint c;
	int transfer;
	void *memP;

	// Validate parameters if debug mode
#ifdef DEBUG
	if (mask & (~(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_ACCUM_BUFFER_BIT | GL_STENCIL_BUFFER_BIT))) {
		printf("Invalid Parameters: glClear()\n");
		gc->errorCode = GL_INVALID_VALUE;
		return;
	}

	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glClear: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Echo back API calls if trace active
#ifdef GL_TRACE_API
	printf("glClear(0x%x)\n", mask);
#endif

	// Get current color buffer pixmap pointer
	switch (gc->drawBuffer) {
	case GL_BACK:
	case GL_FRONT:		
		break;
	default:
		return;
	}

	pp = gc->screenBuffer[gc->renderBuffer];
	transfer = (pp->dmaFlags >> 4) & 0x0000000f;
	dmaFlags = pp->dmaFlags | DMA_DIRECT_BIT;
	memP = pp->memP;

	switch (mask) {

	// Perform regular screen clear but inhibit Z-write
	case GL_COLOR_BUFFER_BIT:

		// Modify clear Color based on current pixel format
		switch (transfer) {
		case 4:
		case 6:
		case 8:
			c = gc->clearColorYCrCb;
			break;
		case 5:
		case 9:
		case 10:
		case 11:
		case 13:
		case 14:
		default:
			c = gc->clearColorYCrCb >> 16;
			break;
		}

		// Only inhibit z-write if depth buffer is present
		switch (transfer) {
		case 5:
		case 6:
		case 9:
		case 10:
		case 11:
		case 13:
		case 14:
			dmaFlags |= 0x0000000e;
			break;
		default:
			break;
		}

		WaitForAllMPEs();

		for (x = 0; x < pp->wide; x += 8) {
			for (y = 0; y < pp->high; y += 8) {
				   _DMABiLinear(dmaFlags, memP, (8<<16)|x, (8<<16)|y, (void *)c);
			}
		}

		break;

	case GL_DEPTH_BUFFER_BIT:

		// Check if depth buffer is present, and set transfer if so to clear Z-buffer only
		switch (transfer) {

		// Single buffered 16.16
		case 5:
			transfer = 0 << 4;
			break;

		// Single buffered 32 bit
		case 6:
			transfer = 7 << 4;
			break;

		// Triple-buffered 16.16
		case 9:
		case 10:
		case 11:
			transfer = 12 << 4;
			break;

		// Double-buffered 16.16
		case 13:
		case 14:
			transfer = 15 << 4;
			break;

		// Format does not include a Z-buffer
		default:
			return;
		}

		dmaFlags = (dmaFlags & 0xffffff01) | transfer;
		c = gc->clearDepth;

		WaitForAllMPEs();

		for (x = 0; x < pp->wide; x += 8) {
			for (y = 0; y < pp->high; y += 8) {
				   _DMABiLinear(dmaFlags, memP, (8<<16)|x, (8<<16)|y, (void *)c);
			}
		}
		break;

	case GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT:

		// Determine clear color/clear depth combo
		switch (transfer) {
		case 5:
		case 9:
		case 10:
		case 11:
		case 13:
		case 14:
			c = gc->clearColorYCrCb | (gc->clearDepth >> 16);
			break;
		default:
			c = gc->clearColorYCrCb;
			break;
		}

		WaitForAllMPEs();

		// Perform first clear (or only clear if in a 16.16 mode)
		for (x = 0; x < pp->wide; x += 8) {
			for (y = 0; y < pp->high; y += 8) {
				_DMABiLinear(dmaFlags, memP, (8<<16)|x, (8<<16)|y, (void *)c);
			}
		}

		// Check for extra z-clear if pixel type 6
		if (transfer == 6) {

			transfer = 7 << 4;
			dmaFlags = (dmaFlags & 0xffffff01) | transfer;
			c = gc->clearDepth;

			for (x = 0; x < pp->wide; x += 8) {
				for (y = 0; y < pp->high; y += 8) {
					   _DMABiLinear(dmaFlags, memP, (8<<16)|x, (8<<16)|y, (void *)c);
				}
			}
		}
		break;
	}
}

void glClearAccum(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {

}

void glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha)
{
#ifdef GL_TRACE_API
	printf("glClearColor(%5.3f, %5.3f, %5.3f, %5.3f)\n", red, green, blue, alpha);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glClearColor: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Clamp colors
	if (red < 0.0f)
		red = 0.0f;
	else if (red > 1.0f)
		red = 1.0f;
	if (green < 0.0f)
		green = 0.0f;
	else if (green > 1.0f)
		green = 1.0f;
	if (blue < 0.0f)
			blue = 0.0f;
	else if (blue > 1.0f)
		blue = 1.0f;
	if (alpha < 0.0f)
		alpha = 0.0f;
	else if (alpha > 1.0f)
		alpha = 1.0f;

	// Create integer color equivalents
	gc->clearColor.r = GLCOLORMAX * red;
	gc->clearColor.g = GLCOLORMAX * green;
	gc->clearColor.b = GLCOLORMAX * blue;
	gc->clearColor.a = GLCOLORMAX * alpha;

	// Set clear color
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
}

void glClearDepth(GLclampd depth) {
#ifdef GL_TRACE_API
	printf("glClearDepth(%f)\n", depth);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glClearDepth: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Set clear depth
	if (depth < 0.0)
		gc->clearDepth = 0x0;
	else if (depth >= 1.0)
		gc->clearDepth = 0xffffffff;
	else
		gc->clearDepth = 0xffffffff * depth;
}

void glClearIndex(GLfloat c) {

}

void glClearStencil(GLint s) {

}

void glClipPlane(GLenum plane, const GLdouble *equation) {

}

void glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha) {

}

void glColorPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {

}

void glCopyPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum type) {

}

void glCopyTexImage1D(GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLint border) {

}

void glCopyTexImage2D(GLenum target, GLint level, GLenum internalFormat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border) {

}

void glCopyTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width) {

}

void glCopyTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height) {

}

void glCullFace(GLenum mode) {

}

void glDeleteLists(GLuint list, GLsizei range) {

}

void glDeleteTextures(GLsizei n, const GLuint *textures) {

}

void glDepthFunc(GLenum func)
{
#ifdef GL_TRACE_API
	printf("glDepthFunc(%s)\n", GLConstantString(func));
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glClearDepth: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}

	switch (func) {
	case GL_NEVER:
	case GL_LESS:
	case GL_EQUAL:
	case GL_LEQUAL:
	case GL_GREATER:
	case GL_NOTEQUAL:
	case GL_GEQUAL:
	case GL_ALWAYS:
		break;
	default:
		gc->errorCode = GL_INVALID_ENUM;
		printf("glDepthFunc: Invalid depth function.\n");
		return;
	}
#endif

	if (gc->depthFunction != func) {
		gc->depthFunction = func;
		if (gc->depthTestEnable) gc->validationFlags |= VAL_PIPELINE | VAL_RENDER_BUFFER;
	}
}

void glDepthMask(GLboolean flag)
{
#ifdef GL_TRACE_API
	printf("glDepthMask(%d)\n", flag);
#endif

	// Check if within begin/end block
#ifdef DEBUG
	if (gc->beginEndFlag) {
		printf("glDepthMask: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	if (gc->depthMask != flag) {
		gc->depthMask = flag;
		gc->validationFlags |= VAL_PIPELINE;
		// VAL_RENDERBUFFER flag is not set because there is no hardware support for depth mask
	}
}

void glDepthRange(GLclampd zNear, GLclampd zFar) {

#ifdef GL_TRACE_API
	printf("glDepthRange(%f, %f)\n", zNear, zFar);
#endif

	// Check if within begin/end block
#ifdef DEBUG
	if (gc->beginEndFlag) {
		printf("glDepthRange: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Clamp zNear and zFar
	if (zNear < 0.0)
		zNear = 0.0;
	else if (zNear > 1.0)
		zNear = 1.0;
	if (zFar < 0.0)
		zFar = 0.0;
	else if (zFar > 1.0)
		zFar = 1.0;

	// Set z range
	gc->zNear = zNear;
	gc->zFar = zFar;

	// Set validation flag
	gc->validationFlags |= VAL_VIEWPORT;
}

void glDisable(GLenum cap) {
#ifdef GL_TRACE_API
	printf("glDisable(%s)\n", GLConstantString(cap));
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glDisable: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	switch (cap) {
	case GL_ALPHA_TEST:
		break;

	case GL_BLEND:
		if (gc->blendEnable) {
			gc->blendEnable = GL_FALSE;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

	case GL_CULL_FACE:
		break;

	case GL_CHROMAKEY_EXT:
		if (gc->chromakeyEnable) {
			gc->chromakeyEnable = GL_FALSE;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

	case GL_DEPTH_TEST:

		if (gc->depthTestEnable) {
			gc->depthTestEnable = GL_FALSE;
			gc->validationFlags |= VAL_PIPELINE | VAL_RENDER_BUFFER;
		}
		break;

	case GL_DITHER:
		break;

	case GL_FOG:
		if (gc->fogEnable) {
			gc->fogEnable = GL_FALSE;
			gc->validationFlags &= ~VAL_FOG;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

	case GL_LIGHTING:
		if (gc->lightingEnable) {
			gc->lightingEnable = GL_FALSE;
			gc->validationFlags &= ~VAL_LIGHTING;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

	case GL_LIGHT0:
	case GL_LIGHT1:
	case GL_LIGHT2:
	case GL_LIGHT3:
	case GL_LIGHT4:
	case GL_LIGHT5:
	case GL_LIGHT6:
	case GL_LIGHT7:
		if (gc->light[cap - GL_LIGHT0].enable) {
			gc->light[cap - GL_LIGHT0].enable = GL_FALSE;
			if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		}
		break;

	case GL_TEXTURE_1D:
		if (gc->texture1DEnable) {
			gc->texture1DEnable = GL_FALSE;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

	case GL_TEXTURE_2D:
		if (gc->texture2DEnable) {
			gc->texture2DEnable = GL_FALSE;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

#ifdef DEBUG
	default:
		gc->errorCode = GL_INVALID_ENUM;
		printf("Unsupported glDisable capability.\n");
		return;
#endif
	}
}

void glDisableClientState(GLenum array) {

}

void glDrawArrays(GLenum mode, GLint first, GLsizei count) {

}

void glDrawBuffer(GLenum mode) {
#ifdef GL_TRACE_API
	printf("glDrawBuffer(%s)\n", GLConstantString(mode));
#endif

#ifdef GL_DEBUG_API
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glDrawBuffer: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}

	switch (mode) {

	// Valid possibilities
	case GL_NONE:
	case GL_FRONT:
	case GL_BACK:
		break;

	// Unimplemented possibilities
	case GL_LEFT:
	case GL_RIGHT:
	case GL_FRONT_LEFT:
	case GL_FRONT_RIGHT:
	case GL_BACK_LEFT:
	case GL_BACK_RIGHT:
	case GL_FRONT_AND_BACK:
		printf("Unimplemented glDrawBuffer setting\n");
		return;

	default:
		printf("Invalid glDrawBuffer call\n");
		return;
	}
#endif

	// Check for single buffering
	if ((mode == GL_BACK) && (gc->numBuffers == 1))
		mode = GL_FRONT;

	// Set drawbuffer and set appropriate validation flag
	if (mode != gc->drawBuffer) {
		gc->validationFlags |= VAL_RENDER_BUFFER;
		gc->drawBuffer = mode;
		switch (gc->drawBuffer) {
		case GL_NONE:
			printf("Unimplemented glDrawBuffer setting\n");
			return;
		case GL_FRONT:
			gc->renderBuffer = gc->frontBuffer;
			break;
		case GL_BACK:
			gc->renderBuffer = gc->backBuffer;
			break;
		}
	}
}

void glDrawElements(GLenum mode, GLsizei count, GLenum type, const GLvoid *indices) {

}

void glDrawPixels(GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels) {

}

void glEdgeFlag(GLboolean flag) {

}

void glEdgeFlagPointer(GLsizei stride, const GLvoid *pointer) {

}

void glEdgeFlagv(const GLboolean *flag) {

}

void glEnable(GLenum cap) {
#ifdef GL_TRACE_API
	printf("glEnable(%s)\n", GLConstantString(cap));
#endif

	// Check if within begin/end block
#ifdef DEBUG
	if (gc->beginEndFlag) {
		printf("glEnable: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Pick appropriate capability
	switch (cap) {
	case GL_ALPHA_TEST:
		break;

	case GL_BLEND:
		if (!(gc->blendEnable)) {
			gc->blendEnable = GL_TRUE;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

	case GL_CULL_FACE:
		break;

	case GL_CHROMAKEY_EXT:
		if (!(gc->chromakeyEnable)) {
			gc->chromakeyEnable = GL_TRUE;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

	case GL_DEPTH_TEST:
		if (!(gc->depthTestEnable)) {
			gc->depthTestEnable = GL_TRUE;
			gc->validationFlags |= VAL_PIPELINE | VAL_RENDER_BUFFER;
		}
		break;

	case GL_DITHER:
		break;

	case GL_FOG:
		if (!(gc->fogEnable)) {
			gc->fogEnable = GL_TRUE;
			gc->validationFlags |= VAL_FOG | VAL_PIPELINE;
		}
		break;

	case GL_LIGHTING:
		if (!gc->lightingEnable) {
			gc->lightingEnable = GL_TRUE;
			gc->validationFlags |= VAL_LIGHTING | VAL_PIPELINE;
		}
		break;

	case GL_LIGHT0:
	case GL_LIGHT1:
	case GL_LIGHT2:
	case GL_LIGHT3:
	case GL_LIGHT4:
	case GL_LIGHT5:
	case GL_LIGHT6:
	case GL_LIGHT7:
		if (!gc->light[cap - GL_LIGHT0].enable) {
			gc->light[cap - GL_LIGHT0].enable = GL_TRUE;
			if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		}
		break;

	case GL_TEXTURE_1D:
		if (!gc->texture1DEnable) {
			gc->texture1DEnable = GL_TRUE;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

	case GL_TEXTURE_2D:
		if (!gc->texture2DEnable) {
			gc->texture2DEnable = GL_TRUE;
			gc->validationFlags |= VAL_PIPELINE;
		}
		break;

#ifdef DEBUG
	default:
		gc->errorCode = GL_INVALID_ENUM;
		printf("Unsupported glDisable capability.\n");
		return;
#endif
	}
}

void glEnableClientState(GLenum array) {

}

void glEndList(void) {

}

void glEvalCoord1d(GLdouble u) {

}

void glEvalCoord1dv(const GLdouble *u) {

}

void glEvalCoord1f(GLfloat u) {

}

void glEvalCoord1fv(const GLfloat *u) {

}

void glEvalCoord2d(GLdouble u, GLdouble v) {

}

void glEvalCoord2dv(const GLdouble *u) {

}

void glEvalCoord2f(GLfloat u, GLfloat v) {

}

void glEvalCoord2fv(const GLfloat *u) {

}

void glEvalMesh1(GLenum mode, GLint i1, GLint i2) {

}

void glEvalMesh2(GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2) {

}

void glEvalPoint1(GLint i) {

}

void glEvalPoint2(GLint i, GLint j) {

}

void glFeedbackBuffer(GLsizei size, GLenum type, GLfloat *buffer) {

}

void glFinish(void) {
#ifdef GL_TRACE_API
	printf("glFinish()\n");
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glFinish: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	if (gc->validationFlags != 0) {
		ValidateGC();
	}

	FlushVertexBuffer();

	WaitForAllMPEs();

	gc->vertexCounter = 0;
	gc->vertexStartCounter = 0;
	gc->vertexEntryCounter = 0;
	gc->vertexEntryStartCounter = 0;
}

void glFlush(void)
{
#ifdef GL_TRACE_API
	printf("glFlush()\n");
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glFlush: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	if (gc->validationFlags != 0) {
		ValidateGC();
	}

	FlushVertexBuffer();
}

void glFogf(GLenum pname, GLfloat param) {
#ifdef GL_TRACE_API
	printf("glFogf(%s, %f)\n", GLConstantString(pname), param);
#endif

	// Set appropriate enum
	switch (pname) {
	case GL_FOG_MODE:
		switch ((int)param) {
		case GL_LINEAR:
		case GL_EXP:
		case GL_EXP2:
			if (gc->fogMode != (int)param) {
				gc->fogMode = (int)param;
				gc->validationFlags |= VAL_FOG;
			}
			break;
		default:
#ifdef DEBUG
		printf("glFogf: Invalid fog mode.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		}
		break;

	case GL_FOG_DENSITY:
		gc->fogDensity = (int)param;
		break;

	case GL_FOG_START:
		gc->fogStart = (int)(param * (1 << GLXYZWCLIPSHIFT));
		gc->validationFlags |= VAL_FOG;
		break;

	case GL_FOG_END:
		gc->fogEnd = (int)(param * (1 << GLXYZWCLIPSHIFT));
		gc->validationFlags |= VAL_FOG;
		break;

	case GL_FOG_INDEX:
		break;

	default:
		gc->errorCode = GL_INVALID_ENUM;
#ifdef DEBUG
		printf("glFogf: Invalid enum.\n");
#endif
	}
}

void glFogfv(GLenum pname, const GLfloat *params) {
#ifdef GL_TRACE_API
	printf("glFogfv(%s, %p)\n", GLConstantString(pname), params);
#endif

	// Set appropriate enum
	switch (pname) {
	case GL_FOG_MODE:
		switch ((int)params[0]) {
		case GL_LINEAR:
		case GL_EXP:
		case GL_EXP2:
			if (gc->fogMode != (int)params[0]) {
				gc->fogMode = (int)params[0];
				gc->validationFlags |= VAL_FOG;
			}
			break;
		default:
#ifdef DEBUG
		printf("glFogfv: Invalid fog mode.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		}
		break;

	case GL_FOG_DENSITY:
		gc->fogDensity = (int)params[0];
		break;

	case GL_FOG_START:
		gc->fogStart = (int)(params[0] * (1 << GLXYZWCLIPSHIFT));
		gc->validationFlags |= VAL_FOG;
		break;

	case GL_FOG_END:
		gc->fogEnd = (int)(params[0] * (1 << GLXYZWCLIPSHIFT));
		gc->validationFlags |= VAL_FOG;
		break;

	case GL_FOG_COLOR:
		gc->fogColor.r = (int)(params[0] * GLCOLORMAX);
		gc->fogColor.g = (int)(params[1] * GLCOLORMAX);
		gc->fogColor.b = (int)(params[2] * GLCOLORMAX);
		gc->fogColor.a = (int)(params[3] * GLCOLORMAX);
		break;

	case GL_FOG_INDEX:
		break;

	default:
		gc->errorCode = GL_INVALID_ENUM;
#ifdef DEBUG
		printf("glFogfv: Invalid enum.\n");
#endif
	}
}

void glFogi(GLenum pname, GLint param) {
#ifdef GL_TRACE_API
	printf("glFogi(%s, %d)\n", GLConstantString(pname), param);
#endif

	// Set appropriate enum
	switch (pname) {
	case GL_FOG_MODE:
		switch ((int)param) {
		case GL_LINEAR:
		case GL_EXP:
		case GL_EXP2:
			if (gc->fogMode != param) {
				gc->fogMode = param;
				gc->validationFlags |= VAL_FOG;
			}
			break;
		default:
#ifdef DEBUG
		printf("glFogi: Invalid fog mode.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		}
		break;

	case GL_FOG_DENSITY:
		gc->fogDensity = (int)param;
		break;

	case GL_FOG_START:
		gc->fogStart = param << GLXYZWCLIPSHIFT;
		gc->validationFlags |= VAL_FOG;
		break;

	case GL_FOG_END:
		gc->fogEnd = param << GLXYZWCLIPSHIFT;
		gc->validationFlags |= VAL_FOG;
		break;

	case GL_FOG_INDEX:
		break;

	default:
		gc->errorCode = GL_INVALID_ENUM;
#ifdef DEBUG
		printf("glFogi: Invalid enum.\n");
#endif
	}
}

void glFogiv(GLenum pname, const GLint *params) {
#ifdef GL_TRACE_API
	printf("glFogiv(%s, %p)\n", GLConstantString(pname), params);
#endif

	// Set appropriate enum
	switch (pname) {
	case GL_FOG_MODE:
		switch ((int)params[0]) {
		case GL_LINEAR:
		case GL_EXP:
		case GL_EXP2:
			if (gc->fogMode != params[0]) {
				gc->fogMode = params[0];
				gc->validationFlags |= VAL_FOG;
			}
			break;
		default:
#ifdef DEBUG
		printf("glFogiv: Invalid fog mode.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		}
		break;

	case GL_FOG_DENSITY:
		gc->fogDensity = (int)params[0];
		break;

	case GL_FOG_START:
		gc->fogStart = params[0] << GLXYZWCLIPSHIFT;
		gc->validationFlags |= VAL_FOG;
		break;

	case GL_FOG_END:
		gc->fogEnd = params[0] << GLXYZWCLIPSHIFT;
		gc->validationFlags |= VAL_FOG;
		break;

	case GL_FOG_COLOR:
		gc->fogColor.r = FixMul(params[0], 1 << GLCOLORSHIFT, 31);
		gc->fogColor.g = FixMul(params[1], 1 << GLCOLORSHIFT, 31);
		gc->fogColor.b = FixMul(params[2], 1 << GLCOLORSHIFT, 31);
		gc->fogColor.a = FixMul(params[3], 1 << GLCOLORSHIFT, 31);
		break;

	case GL_FOG_INDEX:
		break;

	default:
		gc->errorCode = GL_INVALID_ENUM;
#ifdef DEBUG
		printf("glFogiv: Invalid enum.\n");
#endif
	}
}

void glFrontFace(GLenum mode) {

}


GLuint glGenLists(GLsizei range) {

	return 0;
}

void glGenTextures(GLsizei n, GLuint *textures) {

}


// Gets parameters for further encoding by type
static int mglGetFloatv(GLenum pname, GLfloat *params) {


	// Return appropriate parameter(s)
	switch (pname) {
	case GL_ALPHA_BITS:
		switch (gc->pixelType) {
		case e655:
		case e655Z:
			params[0] = 0.0f;
			return 1;
		case e888Alpha:
		case e888AlphaZ:
			params[0] = 8.0f;
			return 1;
		default:
			// shouldn't happen
			DEBUG_ASSERT(0);
			return 0;
		}

	case GL_ALPHA_TEST:
		params[0] = (float)GL_FALSE;
		return 1;

	case GL_ALPHA_TEST_FUNC:
		params[0] = (float)GL_ALWAYS;
		return 1;

	case GL_ALPHA_TEST_REF:
		params[0] = 0.0f;
		return 1;

	case GL_ATTRIB_STACK_DEPTH:
		params[0] = 0.0f;
		return 1;

	case GL_BLEND:
		params[0] = (float)(gc->blendEnable);
		return 1;

	case GL_BLEND_DST:
		params[0] =  gc->blendDstFactor;
		return 1;

	case GL_BLEND_SRC:
		params[0] = gc->blendSrcFactor;
		return 1;

	case GL_CLIENT_ATTRIB_STACK_DEPTH:
		params[0] = 0.0f;
		return 1;

	case GL_COLOR_CLEAR_VALUE:
		params[0] = gc->clearColor.r / GLCOLORMAX;
		params[1] = gc->clearColor.g / GLCOLORMAX;
		params[2] = gc->clearColor.b / GLCOLORMAX;
		params[3] = gc->clearColor.a / GLCOLORMAX;
		return 4;

	case GL_CULL_FACE:
		params[0] = (float)GL_TRUE;		// Violates standard (should default to GL_FALSE), will fix (1/22/99)
		return 1;

	case GL_CULL_FACE_MODE:
		params[0] = (float)GL_BACK;
		return 1;

	case GL_CURRENT_COLOR:
		params[0] = gc->currentColor.r / GLCOLORMAX;
		params[1] = gc->currentColor.g / GLCOLORMAX;
		params[2] = gc->currentColor.b / GLCOLORMAX;
		params[3] = gc->currentColor.a / GLCOLORMAX;
		return 4;

	case GL_CURRENT_NORMAL:
		params[0] = gc->currentNormal.x / (1 << GLNORMALSHIFT);
		params[1] = gc->currentNormal.y / (1 << GLNORMALSHIFT);
		params[2] = gc->currentNormal.z / (1 << GLNORMALSHIFT);
		return 3;

	case GL_CURRENT_TEXTURE_COORDS:
		params[0] = gc->currentVertexS / (1 << GLTEXCOORDSHIFT);
		params[1] = gc->currentVertexT / (1 << GLTEXCOORDSHIFT);
		params[2] = 0.0f;
		params[3] = 1.0f;
		return 4;

	case GL_DEPTH_BITS:
		switch (gc->pixelType) {
		case e655Z:
			params[0] = 16.0f;
			return 1;

		case e888AlphaZ:
			params[0] = 32.0f;
			return 1;

		case e655:
		case e888Alpha:
			params[0] = 0.0f;
			return 1;

		default:
			// shouldn't happen
			DEBUG_ASSERT(0);
			return 0;
		}

	case GL_DEPTH_CLEAR_VALUE:
		params[0] = gc->clearDepth / 0xffffffff;
		return 1;

	case GL_DEPTH_FUNC:
		params[0] = gc->depthFunction;
		return 1;

	case GL_DEPTH_RANGE:
		params[0] = gc->zNear;
		params[1] = gc->zFar;
		return 2;

	case GL_DEPTH_TEST:
		params[0] = gc->depthTestEnable;
		return 1;

	case GL_DEPTH_WRITEMASK:
		params[0] = gc->depthMask;
		return 1;

	case GL_DITHER:
		params[0] = GL_FALSE;
		return 1;

	case GL_DOUBLEBUFFER:
		params[0] = GL_TRUE;
		return 1;

	case GL_FRONT_FACE:
		params[0] = GL_CCW;
		return 1;

	case GL_LIGHT0:
	case GL_LIGHT1:
	case GL_LIGHT2:
	case GL_LIGHT3:
	case GL_LIGHT4:
	case GL_LIGHT5:
	case GL_LIGHT6:
	case GL_LIGHT7:
		params[0] = gc->light[pname - GL_LIGHT0].enable;
		return 1;

	case GL_LIGHTING:
		params[0] = gc->lightingEnable;
		return 1;

	case GL_LIGHT_MODEL_AMBIENT:
		params[0] = gc->lightModelAmbient.r / GLCOLORMAX;
		params[1] = gc->lightModelAmbient.g / GLCOLORMAX;
		params[2] = gc->lightModelAmbient.b / GLCOLORMAX;
		params[3] = gc->lightModelAmbient.a / GLCOLORMAX;
		return 4;

	case GL_LIGHT_MODEL_LOCAL_VIEWER:
		params[0] = GL_FALSE;
		return 1;

	case GL_LIGHT_MODEL_TWO_SIDE:
		params[0] = GL_FALSE;
		return 1;

	case GL_MATRIX_MODE:
		params[0] = (float)gc->currentMatrix;
		return 1;

	case GL_MAX_LIGHTS:
		params[0] = MAX_LIGHTS;
		return 1;

	case GL_MAX_MODELVIEW_STACK_DEPTH:
		params[0] = (float)GL_MVMATRIXSTACK_DEPTH;
		return 1;

	case GL_MAX_PROJECTION_STACK_DEPTH:
		params[0] = (float)GL_PRMATRIXSTACK_DEPTH;
		return 1;

	case GL_MAX_TEXTURE_SIZE:
		params[0] = 64;
		return 1;

	case GL_MAX_TEXTURE_STACK_DEPTH:
		params[0] = (float)GL_TXMATRIXSTACK_DEPTH;
		return 1;

	case GL_MAX_VIEWPORT_DIMS:
		params[0] = gc->screenBuffer[0]->wide;		// all screens same width
		params[1] = gc->screenBuffer[0]->high;		// all screens same height
		return 2;

	case GL_MODELVIEW_MATRIX:
		params[0] = gc->modelviewMatrix.m11 / (1 << GLTRIGSHIFT);
		params[1] = gc->modelviewMatrix.m21 / (1 << GLTRIGSHIFT);
		params[2] = gc->modelviewMatrix.m31 / (1 << GLTRIGSHIFT);
		params[3] = gc->modelviewMatrix.m41 / (1 << GLTRIGSHIFT);
		params[4] = gc->modelviewMatrix.m12 / (1 << GLTRIGSHIFT);
		params[5] = gc->modelviewMatrix.m22 / (1 << GLTRIGSHIFT);
		params[6] = gc->modelviewMatrix.m32 / (1 << GLTRIGSHIFT);
		params[7] = gc->modelviewMatrix.m42 / (1 << GLTRIGSHIFT);
		params[8] = gc->modelviewMatrix.m13 / (1 << GLTRIGSHIFT);
		params[9] = gc->modelviewMatrix.m23 / (1 << GLTRIGSHIFT);
		params[10] = gc->modelviewMatrix.m33 / (1 << GLTRIGSHIFT);
		params[11] = gc->modelviewMatrix.m34 / (1 << GLTRIGSHIFT);
		params[12] = gc->modelviewMatrix.m14 / (1 << GLTRIGSHIFT);
		params[13] = gc->modelviewMatrix.m24 / (1 << GLTRIGSHIFT);
		params[14] = gc->modelviewMatrix.m34 / (1 << GLTRIGSHIFT);
		params[15] = gc->modelviewMatrix.m44 / (1 << GLTRIGSHIFT);
		return 16;

	case GL_MODELVIEW_STACK_DEPTH:
		params[0] = gc->mvMatrixStackDepth + 1;
		return 1;

	case GL_NORMALIZE:
		params[0] = GL_FALSE;
		return 1;

	case GL_PROJECTION_MATRIX:
		params[0] = gc->projectionMatrix.m11 / (1 << GLTRIGSHIFT);
		params[1] = gc->projectionMatrix.m21 / (1 << GLTRIGSHIFT);
		params[2] = gc->projectionMatrix.m31 / (1 << GLTRIGSHIFT);
		params[3] = gc->projectionMatrix.m41 / (1 << GLTRIGSHIFT);
		params[4] = gc->projectionMatrix.m12 / (1 << GLTRIGSHIFT);
		params[5] = gc->projectionMatrix.m22 / (1 << GLTRIGSHIFT);
		params[6] = gc->projectionMatrix.m32 / (1 << GLTRIGSHIFT);
		params[7] = gc->projectionMatrix.m42 / (1 << GLTRIGSHIFT);
		params[8] = gc->projectionMatrix.m13 / (1 << GLTRIGSHIFT);
		params[9] = gc->projectionMatrix.m23 / (1 << GLTRIGSHIFT);
		params[10] = gc->projectionMatrix.m33 / (1 << GLTRIGSHIFT);
		params[11] = gc->projectionMatrix.m34 / (1 << GLTRIGSHIFT);
		params[12] = gc->projectionMatrix.m14 / (1 << GLTRIGSHIFT);
		params[13] = gc->projectionMatrix.m24 / (1 << GLTRIGSHIFT);
		params[14] = gc->projectionMatrix.m34 / (1 << GLTRIGSHIFT);
		params[15] = gc->projectionMatrix.m44 / (1 << GLTRIGSHIFT);
		return 16;

	case GL_PROJECTION_STACK_DEPTH:
		params[0] = gc->prMatrixStackDepth + 1;
		return 1;

	case GL_SUBPIXEL_BITS:
		params[0] = GLXYZSCREENSHIFT;
		return 1;

	case GL_TEXTURE_1D:
		params[0] = gc->texture1DEnable;
		return 1;

	case GL_TEXTURE_1D_BINDING:
		params[0] = gc->current1DObjectID;
		return 1;

	case GL_TEXTURE_2D:
		params[0] = gc->texture2DEnable;
		return 1;

	case GL_TEXTURE_2D_BINDING:
		params[0] = gc->current2DObjectID;
		return 1;

	case GL_TEXTURE_MATRIX:
		params[0] = gc->textureMatrix.m11 / (1 << GLTRIGSHIFT);
		params[1] = gc->textureMatrix.m21 / (1 << GLTRIGSHIFT);
		params[2] = gc->textureMatrix.m31 / (1 << GLTRIGSHIFT);
		params[3] = gc->textureMatrix.m41 / (1 << GLTRIGSHIFT);
		params[4] = gc->textureMatrix.m12 / (1 << GLTRIGSHIFT);
		params[5] = gc->textureMatrix.m22 / (1 << GLTRIGSHIFT);
		params[6] = gc->textureMatrix.m32 / (1 << GLTRIGSHIFT);
		params[7] = gc->textureMatrix.m42 / (1 << GLTRIGSHIFT);
		params[8] = gc->textureMatrix.m13 / (1 << GLTRIGSHIFT);
		params[9] = gc->textureMatrix.m23 / (1 << GLTRIGSHIFT);
		params[10] = gc->textureMatrix.m33 / (1 << GLTRIGSHIFT);
		params[11] = gc->textureMatrix.m34 / (1 << GLTRIGSHIFT);
		params[12] = gc->textureMatrix.m14 / (1 << GLTRIGSHIFT);
		params[13] = gc->textureMatrix.m24 / (1 << GLTRIGSHIFT);
		params[14] = gc->textureMatrix.m34 / (1 << GLTRIGSHIFT);
		params[15] = gc->textureMatrix.m44 / (1 << GLTRIGSHIFT);
		return 16;

	case GL_TEXTURE_STACK_DEPTH:
		params[0] = gc->txMatrixStackDepth + 1;
		return 1;

	case GL_VIEWPORT:
		params[0] = gc->viewportX;
		params[1] = gc->viewportY;
		params[2] = gc->viewportWidth;
		params[3] = gc->viewportHeight;
		return 4;
	}

	// Nothing found
	return 0;
}

void glGetBooleanv(GLenum pname, GLboolean *params) {
int size;			// Number of returned parameters
float lparams[32];	// Local parameter structure

#ifdef GL_TRACE_API
	printf("glGetBooleanv(%s, %p)\n", GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetBooleanv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Do get operation
	size = mglGetFloatv(pname, lparams);

	// Check for valid enum
	if (size == 0) {
#ifdef DEBUG
		printf("glGetBooleanv: invalid enum.\n");
#endif
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	if (lparams[0] == 0.0f)
		params[0] = GL_FALSE;
	else
		params[0] = GL_TRUE;
}

void glGetClipPlane(GLenum plane, GLdouble *equation) {

}

void glGetDoublev(GLenum pname, GLdouble *params) {
int i, size;		// Number of returned parameters
float lparams[32];	// Local parameter structure

#ifdef GL_TRACE_API
	printf("glGetDoublev(%s, %p)\n", GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetDoublev: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Do get operation
	size = mglGetFloatv(pname, lparams);

	// Check for valid enum
	if (size == 0) {
#ifdef DEBUG
		printf("glGetDoublev: invalid enum.\n");
#endif
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	for (i = 0; i < size; i++)
		params[i] = lparams[i];

}

GLenum glGetError (void) {
GLenum i = gc->errorCode;
#ifdef GL_TRACE_API
	printf("glGetError()\n");
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetError: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return 0;
	}
#endif

	gc->errorCode = GL_NO_ERROR;
	return i;
}

// Returns float parameters in fixed point format
void glGetFixedv(GLenum pname, long *params) {
float lparams[32];
int i, size;
#ifdef GL_TRACE_API
	printf("glGetFixedv(%s, %p)\n", GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetFixedv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
	}
#endif


	// Calculate float to fixed point conversion factor
	switch (pname) {
	case GL_MODELVIEW_MATRIX:
		params[0] = gc->modelviewMatrix.m11;
		params[1] = gc->modelviewMatrix.m21;
		params[2] = gc->modelviewMatrix.m31;
		params[3] = gc->modelviewMatrix.m41;
		params[4] = gc->modelviewMatrix.m12;
		params[5] = gc->modelviewMatrix.m22;
		params[6] = gc->modelviewMatrix.m32;
		params[7] = gc->modelviewMatrix.m42;
		params[8] = gc->modelviewMatrix.m13;
		params[9] = gc->modelviewMatrix.m23;
		params[10] = gc->modelviewMatrix.m33;
		params[11] = gc->modelviewMatrix.m43;
		params[12] = gc->modelviewMatrix.m14;
		params[13] = gc->modelviewMatrix.m24;
		params[14] = gc->modelviewMatrix.m34;
		params[15] = gc->modelviewMatrix.m44;
		break;

	case GL_PROJECTION_MATRIX:
		params[0] = gc->projectionMatrix.m11;
		params[1] = gc->projectionMatrix.m21;
		params[2] = gc->projectionMatrix.m31;
		params[3] = gc->projectionMatrix.m41;
		params[4] = gc->projectionMatrix.m12;
		params[5] = gc->projectionMatrix.m22;
		params[6] = gc->projectionMatrix.m32;
		params[7] = gc->projectionMatrix.m42;
		params[8] = gc->projectionMatrix.m13;
		params[9] = gc->projectionMatrix.m23;
		params[10] = gc->projectionMatrix.m33;
		params[11] = gc->projectionMatrix.m43;
		params[12] = gc->projectionMatrix.m14;
		params[13] = gc->projectionMatrix.m24;
		params[14] = gc->projectionMatrix.m34;
		params[15] = gc->projectionMatrix.m44;
		break;

	case GL_TEXTURE_MATRIX:
		params[0] = gc->textureMatrix.m11;
		params[1] = gc->textureMatrix.m21;
		params[2] = gc->textureMatrix.m31;
		params[3] = gc->textureMatrix.m41;
		params[4] = gc->textureMatrix.m12;
		params[5] = gc->textureMatrix.m22;
		params[6] = gc->textureMatrix.m32;
		params[7] = gc->textureMatrix.m42;
		params[8] = gc->textureMatrix.m13;
		params[9] = gc->textureMatrix.m23;
		params[10] = gc->textureMatrix.m33;
		params[11] = gc->textureMatrix.m43;
		params[12] = gc->textureMatrix.m14;
		params[13] = gc->textureMatrix.m24;
		params[14] = gc->textureMatrix.m34;
		params[15] = gc->textureMatrix.m44;
		break;

	case GL_CURRENT_COLOR:
		params[0] = gc->currentColor.r;
		params[1] = gc->currentColor.g;
		params[2] = gc->currentColor.b;
		params[3] = gc->currentColor.a;
		break;

	case GL_LIGHT_MODEL_AMBIENT:
		params[0] = gc->lightModelAmbient.r;
		params[1] = gc->lightModelAmbient.g;
		params[2] = gc->lightModelAmbient.b;
		params[3] = gc->lightModelAmbient.a;
		break;

	default:

		size = mglGetFloatv(pname, lparams);

		if (size == 0) {
	#ifdef DEBUG
			printf("glGetFixedv: invalid enum.\n");
	#endif
			gc->errorCode = GL_INVALID_ENUM;
			return;
		}

		for (i = 0; i < size; i++)
			params[i] = lparams[i];

		break;
	}

}

void glGetFloatv(GLenum pname, GLfloat *params) {
int i, size;		// Number of returned parameters
float lparams[32];	// Local parameter structure

#ifdef GL_TRACE_API
	printf("glGetFloatv(%s, %p)\n", GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetFloatv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Do get operation
	size = mglGetFloatv(pname, lparams);

	// Check for valid enum
	if (size == 0) {
#ifdef DEBUG
		printf("glGetFloatv: invalid enum.\n");
#endif
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Copy returned parameters
	for (i = 0; i < size; i++)
		params[i] = lparams[i];
}

void glGetIntegerv(GLenum pname, GLint *params) {
int i, size;		// Number of returned parameters
float lparams[32];	// Local parameter structure
int mult = 1;		// Returned parameter multiplier

#ifdef GL_TRACE_API
	printf("glGetIntegerv(%s, %p)\n", GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetError: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Perform get operation
	size = mglGetFloatv(pname, lparams);

	// Check for valid enum
	if (size == 0) {
#ifdef DEBUG
		printf("glGetIntegerv: invalid enum.\n");
#endif
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Calculate float to fixed point conversion factor
	switch (pname) {

	case GL_CURRENT_COLOR:
	case GL_LIGHT_MODEL_AMBIENT:
		mult = 0x7fffffff;
		break;

	default:
		break;
	}

	// Copy returned parameters
	for (i = 0; i < size; i++)
		params[i] = lparams[i] * mult;
}

void glGetMapdv(GLenum target, GLenum query, GLdouble *v) {

}

void glGetMapfv(GLenum target, GLenum query, GLfloat *v) {

}

void glGetMapiv(GLenum target, GLenum query, GLint *v) {

}

void glGetPixelMapfv(GLenum map, GLfloat *values) {

}

void glGetPixelMapuiv(GLenum map, GLuint *values) {

}
void glGetPixelMapusv(GLenum map, GLushort *values) {

}

void glGetPointerv(GLenum pname, GLvoid* *params) {

}

void glGetPolygonStipple(GLubyte *mask) {

}

const GLubyte * glGetString(GLenum pname) {
#ifdef GL_TRACE_API
	printf("glGetString(%s)\n", GLConstantString(pname));
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetString: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return NULL;
	}
#endif

	switch (pname) {
	case GL_VENDOR:
		return "VM Labs";
	case GL_RENDERER:
#ifdef DEBUG
		return "mGL Debug Build";
#else
		return "mGL";
#endif
	case GL_VERSION:
		return "0.66";
	case GL_EXTENSIONS:
		return "GL_EXT_FIXEDPOINT_PARAMETERS";
	default:
#ifdef DEBUG
		printf("glGetString: Invalid string name.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return NULL;
	}
}

void glGetTexEnvfv(GLenum target, GLenum pname, GLfloat *params) {

}

void glGetTexEnviv(GLenum target, GLenum pname, GLint *params) {

}

void glGetTexGendv(GLenum coord, GLenum pname, GLdouble *params) {

}

void glGetTexGenfv(GLenum coord, GLenum pname, GLfloat *params) {

}

void glGetTexGeniv(GLenum coord, GLenum pname, GLint *params) {

}

void glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, GLvoid *pixels) {

}

void glGetTexLevelParameterfv(GLenum target, GLint level, GLenum pname, GLfloat *params) {

}

void glGetTexLevelParameteriv(GLenum target, GLint level, GLenum pname, GLint *params) {

}

void glGetTexParameterfv(GLenum target, GLenum pname, GLfloat *params) {
GLTextureObject	*tp;

#ifdef GL_TRACE_API
	printf("glGetTexParameterfv(%s, %s, %p)\n", GLConstantString(target), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetTexParameterfv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine appropriate texture object
	switch (target) {
	case GL_TEXTURE_1D:
		tp = gc->current1DObject;
		break;

	case GL_TEXTURE_2D:
		tp = gc->current2DObject;
		break;

	default:
#ifdef DEBUG
		printf("glGetTexParameterfv: Invalid texture target.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	switch (pname) {
		case GL_TEXTURE_MAG_FILTER:
			params[0] = tp->magFilter;
			break;

		case GL_TEXTURE_MIN_FILTER:
			params[0] = tp->minFilter;
			break;

		// For now, only texture tiling is allowed
		case GL_TEXTURE_WRAP_S:
		case GL_TEXTURE_WRAP_T:
			params[0] = GL_REPEAT;
			break;

		// Texture border color not implemented
		case GL_TEXTURE_BORDER_COLOR:
			params[0] = params[1] = params[2] = params[3] = 0x7fffffff;
			break;

		// Texture priority not used, but may be so someday
		case GL_TEXTURE_PRIORITY:
			params[0] = tp->priority;
			break;

		default:
#ifdef DEBUG
			printf("glGetTexParameterfv: Invalid texture parameter.\n");
			gc->errorCode = GL_INVALID_ENUM;
#endif
			return;
	}
}

void glGetTexParameteriv(GLenum target, GLenum pname, GLint *params) {
GLTextureObject	*tp;

#ifdef GL_TRACE_API
	printf("glGetTexParameteriv(%s, %s, %p)\n", GLConstantString(target), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetTexParameteriv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine appropriate texture object
	switch (target) {
	case GL_TEXTURE_1D:
		tp = gc->current1DObject;
		break;

	case GL_TEXTURE_2D:
		tp = gc->current2DObject;
		break;

	default:
#ifdef DEBUG
		printf("glGetTexParameteriv: Invalid texture target.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	switch (pname) {
		case GL_TEXTURE_MAG_FILTER:
			params[0] = tp->magFilter;
			break;

		case GL_TEXTURE_MIN_FILTER:
			params[0] = tp->minFilter;
			break;

		// For now, only texture tiling is allowed
		case GL_TEXTURE_WRAP_S:
		case GL_TEXTURE_WRAP_T:
			params[0] = GL_REPEAT;
			break;

		// Texture border color not implemented
		case GL_TEXTURE_BORDER_COLOR:
			params[0] = params[1] = params[2] = params[3] = 0x7fffffff;
			break;

		// Texture priority not used, but may be so someday
		case GL_TEXTURE_PRIORITY:
			params[0] = tp->priority;
			break;

		default:
#ifdef DEBUG
			printf("glGetTexParameteriv: Invalid texture parameter.\n");
			gc->errorCode = GL_INVALID_ENUM;
#endif
			return;
	}
}

void glHint(GLenum target, GLenum mode) {
#ifdef GL_TRACE_API
	printf("glHint(%s, %s\n", GLConstantString(target), GLConstantString(mode));
#endif
}

void glIndexMask(GLuint mask) {

}

void glIndexPointer(GLenum type, GLsizei stride, const GLvoid *pointer) {

}

void glIndexd(GLdouble c) {

}

void glIndexdv(const GLdouble *c) {

}

void glIndexf(GLfloat c) {

}

void glIndexfv(const GLfloat *c) {

}

void glIndexi(GLint c) {

}

void glIndexiv(const GLint *c) {

}

void glIndexs(GLshort c) {

}

void glIndexsv(const GLshort *c) {

}

void glIndexub(GLubyte c) {

}

void glIndexubv(const GLubyte *c) {

}

void glInitNames(void) {

}

void glInterleavedArrays(GLenum format, GLsizei stride, const GLvoid *pointer) {

}

GLboolean glIsEnabled(GLenum cap) {

	return GL_FALSE;
}

GLboolean glIsList(GLuint list) {\

	return GL_FALSE;
}

GLboolean glIsTexture(GLuint texture) {

	return GL_FALSE;
}

void glLineStipple(GLint factor, GLushort pattern) {

}

void glLineWidth(GLfloat width) {

}

void glListBase(GLuint base) {

}

void glLoadName(GLuint name) {

}

void glLogicOp(GLenum opcode) {
#ifdef DEBUG
	printf("Warning: glLogicOp not implemented on Merlin architecture.\n");
#endif
#ifdef GL_TRACE_API
	printf("glLogicOp(%d)\n", opcode);
#endif
}

void glMap1d(GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, const GLdouble *points) {

}

void glMap1f(GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, const GLfloat *points) {

}

void glMap2d(GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, const GLdouble *points) {

}

void glMap2f(GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, const GLfloat *points) {

}

void glMapGrid1d(GLint un, GLdouble u1, GLdouble u2) {

}

void glMapGrid1f(GLint un, GLfloat u1, GLfloat u2) {

}

void glMapGrid2d(GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2) {

}

void glMapGrid2f(GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2) {

}

void glNewList(GLuint list, GLenum mode) {

}

void glNormalPointer(GLenum type, GLsizei stride, const GLvoid *pointer) {

}

void glPassThrough(GLfloat token) {

}

void glPixelMapfv(GLenum map, GLsizei mapsize, const GLfloat *values) {

}

void glPixelMapuiv(GLenum map, GLsizei mapsize, const GLuint *values) {

}

void glPixelMapusv(GLenum map, GLsizei mapsize, const GLushort *values) {

}

void glPixelStoref(GLenum pname, GLfloat param) {

}

void glPixelStorei(GLenum pname, GLint param) {

}

void glPixelTransferf(GLenum pname, GLfloat param) {

}

void glPixelTransferi(GLenum pname, GLint param) {

}

void glPixelZoom(GLfloat xfactor, GLfloat yfactor) {

}

void glPointSize(GLfloat size) {

}

void glPolygonMode(GLenum face, GLenum mode) {

}

void glPolygonOffset(GLfloat factor, GLfloat units) {

}

void glPolygonStipple(const GLubyte *mask) {

}

void glPopAttrib(void) {

}

void glPopClientAttrib(void) {

}

void glPopName(void) {

}

void glPrioritizeTextures(GLsizei n, const GLuint *textures, const GLclampf *priorities) {

}

void glPushAttrib(GLbitfield mask) {

}

void glPushClientAttrib(GLbitfield mask) {

}

void glPushName(GLuint name) {

}

void glRasterPos2d(GLdouble x, GLdouble y) {

}

void glRasterPos2dv(const GLdouble *v) {

}

void glRasterPos2f(GLfloat x, GLfloat y) {

}

void glRasterPos2fv(const GLfloat *v) {

}

void glRasterPos2i(GLint x, GLint y) {

}

void glRasterPos2iv(const GLint *v) {

}

void glRasterPos2s(GLshort x, GLshort y) {

}

void glRasterPos2sv(const GLshort *v) {

}

void glRasterPos3d(GLdouble x, GLdouble y, GLdouble z) {

}

void glRasterPos3dv(const GLdouble *v) {

}

void glRasterPos3f(GLfloat x, GLfloat y, GLfloat z) {

}

void glRasterPos3fv(const GLfloat *v) {

}

void glRasterPos3i(GLint x, GLint y, GLint z) {

}

void glRasterPos3iv(const GLint *v) {

}

void glRasterPos3s(GLshort x, GLshort y, GLshort z) {

}

void glRasterPos3sv(const GLshort *v) {

}

void glRasterPos4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w) {

}

void glRasterPos4dv(const GLdouble *v) {

}

void glRasterPos4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {

}

void glRasterPos4fv(const GLfloat *v) {

}

void glRasterPos4i(GLint x, GLint y, GLint z, GLint w) {

}

void glRasterPos4iv(const GLint *v) {

}

void glRasterPos4s(GLshort x, GLshort y, GLshort z, GLshort w) {

}

void glRasterPos4sv(const GLshort *v) {

}

void glReadBuffer(GLenum mode) {

}

void glReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid *pixels) {

}

void glRectd(GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2) {

}

void glRectdv(const GLdouble *v1, const GLdouble *v2) {

}

void glRectf(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2) {

}

void glRectfv(const GLfloat *v1, const GLfloat *v2) {

}

void glRecti(GLint x1, GLint y1, GLint x2, GLint y2) {

}

void glRectiv(const GLint *v1, const GLint *v2) {

}

void glRects(GLshort x1, GLshort y1, GLshort x2, GLshort y2) {

}

void glRectsv(const GLshort *v1, const GLshort *v2) {

}

GLint glRenderMode(GLenum mode) {

	return 0;
}

void glScissor(GLint x, GLint y, GLsizei width, GLsizei height) {

}

void glSelectBuffer(GLsizei size, GLuint *buffer) {

}

void glShadeModel(GLenum mode) {

}

void glStencilFunc(GLenum func, GLint ref, GLuint mask) {

}

void glStencilMask(GLuint mask) {

}

void glStencilOp(GLenum fail, GLenum zfail, GLenum zpass) {

}

void glTexCoordPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {

}

void glTexEnvf(GLenum target, GLenum pname, GLfloat param) {
#ifdef GL_TRACE_API
	printf("glTexEnvf(%s, %s, %s)\n", GLConstantString(target), GLConstantString(pname), GLConstantString((int)param));
#endif

#ifdef DEBUG
	// Check for valid target
	if (target != GL_TEXTURE_ENV) {
		printf("glTexEnvf: Invalid target.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Check for valid parameter name
	if (pname != GL_TEXTURE_ENV_MODE) {
		printf("glTexEnvf: Invalid parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Check for valid values
	switch ((int)param) {
	case GL_MODULATE:
	case GL_REPLACE:
		break;
	case GL_DECAL:
	case GL_BLEND:
		printf("glTexEnvf: %s texture environment mode not yet supported.\n", GLConstantString(param));
		return;
	default:
		printf("glTexEnvf: Invalid texture parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

#endif

	// Set texture environment mode if appropriate
	if (gc->textureEnvMode != (int)param) {
		gc->textureEnvMode = (int)param;
		gc->validationFlags |= VAL_PIPELINE;
	}
}

void glTexEnvfv(GLenum target, GLenum pname, const GLfloat *params) {
#ifdef GL_TRACE_API
	printf("glTexEnvfv(%s, %s, %p)\n", GLConstantString(target), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check for valid target
	if (target != GL_TEXTURE_ENV) {
		printf("glTexEnvfv: Invalid target.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Check for valid parameter name
	if ((pname != GL_TEXTURE_ENV_MODE) && (pname != GL_TEXTURE_ENV_COLOR)) {
		printf("glTexEnvfv: Invalid parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}
#endif

	// Check for valid values
	if (pname == GL_TEXTURE_ENV_MODE) {
#ifdef DEBUG
		switch ((int)(*params)) {
		case GL_MODULATE:
		case GL_REPLACE:
			break;
		case GL_DECAL:
		case GL_BLEND:
			printf("glTexEnvfv: %s texture environment mode not yet supported.\n", GLConstantString((int)(*params)));
			return;
		default:
			printf("glTexEnvfv: Invalid texture parameter.\n");
			gc->errorCode = GL_INVALID_ENUM;
			return;
		}
#endif
		// Set texture environment mode if appropriate
		if (gc->textureEnvMode != (int)(*params)) {
			gc->textureEnvMode = (int)(*params);
			gc->validationFlags |= VAL_PIPELINE;
		}
	}
#ifdef DEBUG
	else
		printf("glTeEnvfv: GL_TEXTURE_ENV_COLOR currently unsupported.\n");
#endif
}

void glTexEnvi(GLenum target, GLenum pname, GLint param) {
#ifdef GL_TRACE_API
	printf("glTexEnvi(%s, %s, %s)\n", GLConstantString(target), GLConstantString(pname), GLConstantString(param));
#endif

#ifdef DEBUG
	// Check for valid target
	if (target != GL_TEXTURE_ENV) {
		printf("glTexEnvi: Invalid target.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Check for valid parameter name
	if (pname != GL_TEXTURE_ENV_MODE) {
		printf("glTexEnvi: Invalid parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Check for valid values
	switch (param) {
	case GL_MODULATE:
	case GL_REPLACE:
		break;
	case GL_DECAL:
	case GL_BLEND:
		printf("glTexEnvi: %s texture environment mode not yet supported.\n", GLConstantString(param));
		return;
	default:
		printf("glTexEnvi: Invalid texture parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

#endif

	// Set texture environment mode if appropriate
	if (gc->textureEnvMode != param) {
		gc->textureEnvMode = param;
		gc->validationFlags |= VAL_PIPELINE;
	}
}

void glTexEnviv(GLenum target, GLenum pname, const GLint *params) {
#ifdef GL_TRACE_API
	printf("glTexEnvfv(%s, %s, %p)\n", GLConstantString(target), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check for valid target
	if (target != GL_TEXTURE_ENV) {
		printf("glTexEnvf: Invalid target.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Check for valid parameter name
	if ((pname != GL_TEXTURE_ENV_MODE) && (pname != GL_TEXTURE_ENV_COLOR)) {
		printf("glTexEnviv: Invalid parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}
#endif

	// Check for valid values
	if (pname == GL_TEXTURE_ENV_MODE) {
#ifdef DEBUG
		switch (*params) {
		case GL_MODULATE:
		case GL_REPLACE:
			break;
		case GL_DECAL:
		case GL_BLEND:
			printf("glTexEnviv: %s texture environment mode not yet supported.\n", GLConstantString(*params));
			return;
		default:
			printf("glTexEnviv: Invalid texture parameter.\n");
			gc->errorCode = GL_INVALID_ENUM;
			return;
		}
#endif
		// Set texture environment mode if appropriate
		if (gc->textureEnvMode != *params) {
			gc->textureEnvMode = *params;
			gc->validationFlags |= VAL_PIPELINE;
		}
	}
#ifdef DEBUG
	else
		printf("glTexEnviv: GL_TEXTURE_ENV_COLOR currently unsupported.\n");
#endif
}

void glTexGend(GLenum coord, GLenum pname, GLdouble param) {

}

void glTexGendv(GLenum coord, GLenum pname, const GLdouble *params) {

}

void glTexGenf(GLenum coord, GLenum pname, GLfloat param) {

}

void glTexGenfv(GLenum coord, GLenum pname, const GLfloat *params) {

}

void glTexGeni(GLenum coord, GLenum pname, GLint param) {

}

void glTexGeniv(GLenum coord, GLenum pname, const GLint *params) {

}

void glTexImage1D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const GLvoid *pixels) {

}

void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid *pixels) {

}

void glTexParameterf(GLenum target, GLenum pname, GLfloat param) {
GLTextureObject	*tp;

#ifdef GL_TRACE_API
	printf("glTexParameterf(%s, %s, %f)\n", GLConstantString(target), GLConstantString(pname), param);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glTexParameterf: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine appropriate texture object
	switch (target) {
	case GL_TEXTURE_1D:
		tp = gc->current1DObject;
		break;

	case GL_TEXTURE_2D:
		tp = gc->current2DObject;
		break;

	default:
#ifdef DEBUG
		printf("glTexParameterf: Invalid texture target.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	switch (pname) {
		case GL_TEXTURE_MAG_FILTER:
#ifdef DEBUG
			switch ((int)param) {
			case GL_NEAREST:
			case GL_LINEAR:
				break;
			default:
				printf("glTexParameterf: Invalid texture parameter for GL_TEXTURE_MAG_FILTER.\n");
				gc->errorCode = GL_INVALID_ENUM;
			}
#endif
			tp->magFilter = (int)param;
			break;

		case GL_TEXTURE_PRIORITY:
			tp->priority = param;
			break;

		case GL_TEXTURE_MIN_FILTER:
#ifdef DEBUG
			switch ((int)param) {
			case GL_NEAREST:
			case GL_NEAREST_MIPMAP_NEAREST:
			case GL_NEAREST_MIPMAP_LINEAR:
			case GL_LINEAR:
			case GL_LINEAR_MIPMAP_NEAREST:
			case GL_LINEAR_MIPMAP_LINEAR:
				break;
			default:
				printf("glTexParameterf: Invalid texture parameter for GL_TEXTURE_MIN_FILTER.\n");
				gc->errorCode = GL_INVALID_ENUM;
			}
#endif
			if (tp->minFilter != (int)param) {
				tp->minFilter = (int)param;
				gc->validationFlags |= VAL_PIPELINE;
			}
			break;

		case GL_TEXTURE_WRAP_S:
		case GL_TEXTURE_WRAP_T:
		case GL_TEXTURE_BORDER_COLOR:
			break;

		default:
#ifdef DEBUG
			printf("glTexParameterf: Invalid texture parameter.\n");
			gc->errorCode = GL_INVALID_ENUM;
#endif
			return;
	}
}

void glTexParameterfv (GLenum target, GLenum pname, const GLfloat *params) {
GLTextureObject	*tp;

#ifdef GL_TRACE_API
	printf("glTexParameterfv(%s, %s, %p)\n", GLConstantString(target), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glTexParameterfv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine appropriate texture object
	switch (target) {
	case GL_TEXTURE_1D:
		tp = gc->current1DObject;
		break;

	case GL_TEXTURE_2D:
		tp = gc->current2DObject;
		break;

	default:
#ifdef DEBUG
		printf("glTexParameterfv: Invalid texture target.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	switch (pname) {
		case GL_TEXTURE_MAG_FILTER:
#ifdef DEBUG
			switch ((int)params[0]) {
			case GL_NEAREST:
			case GL_LINEAR:
				break;
			default:
				printf("glTexParameterf: Invalid texture parameter for GL_TEXTURE_MAG_FILTER.\n");
				gc->errorCode = GL_INVALID_ENUM;
			}
#endif
			tp->magFilter = (int)params[0];
			break;

		case GL_TEXTURE_PRIORITY:
			tp->priority = params[0];
			break;

		case GL_TEXTURE_MIN_FILTER:
#ifdef DEBUG
			switch ((int)params[0]) {
			case GL_NEAREST:
			case GL_NEAREST_MIPMAP_NEAREST:
			case GL_NEAREST_MIPMAP_LINEAR:
			case GL_LINEAR:
			case GL_LINEAR_MIPMAP_NEAREST:
			case GL_LINEAR_MIPMAP_LINEAR:
				break;
			default:
				printf("glTexParameterf: Invalid texture parameter for GL_TEXTURE_MIN_FILTER.\n");
				gc->errorCode = GL_INVALID_ENUM;
			}
#endif
			if (tp->minFilter != (int)params[0]) {
				tp->minFilter = (int)params[0];
				gc->validationFlags |= VAL_PIPELINE;
			}
			break;

		case GL_TEXTURE_WRAP_S:
		case GL_TEXTURE_WRAP_T:
		case GL_TEXTURE_BORDER_COLOR:
			break;

		default:
#ifdef DEBUG
			printf("glTexParameterfv: Invalid texture parameter.\n");
			gc->errorCode = GL_INVALID_ENUM;
#endif
			return;
	}
}

void glTexParameteri(GLenum target, GLenum pname, GLint param) {
GLTextureObject	*tp;

#ifdef GL_TRACE_API
	printf("glTexParameteri(%s, %s, %d)\n", GLConstantString(target), GLConstantString(pname), param);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glTexParameteri: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine appropriate texture object
	switch (target) {
	case GL_TEXTURE_1D:
		tp = gc->current1DObject;
		break;

	case GL_TEXTURE_2D:
		tp = gc->current2DObject;
		break;

	default:
#ifdef DEBUG
		printf("glTexParameteri: Invalid texture target.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	switch (pname) {
		case GL_TEXTURE_MAG_FILTER:
#ifdef DEBUG
			switch ((int)param) {
			case GL_NEAREST:
			case GL_LINEAR:
				break;
			default:
				printf("glTexParameterf: Invalid texture parameter for GL_TEXTURE_MAG_FILTER.\n");
				gc->errorCode = GL_INVALID_ENUM;
			}
#endif
			tp->magFilter = (int)param;
			break;

		case GL_TEXTURE_PRIORITY:
			tp->priority = param;
			break;

		case GL_TEXTURE_MIN_FILTER:
#ifdef DEBUG
			switch ((int)param) {
			case GL_NEAREST:
			case GL_NEAREST_MIPMAP_NEAREST:
			case GL_NEAREST_MIPMAP_LINEAR:
			case GL_LINEAR:
			case GL_LINEAR_MIPMAP_NEAREST:
			case GL_LINEAR_MIPMAP_LINEAR:
				break;
			default:
				printf("glTexParameterf: Invalid texture parameter for GL_TEXTURE_MIN_FILTER.\n");
				gc->errorCode = GL_INVALID_ENUM;
			}
#endif
			if (tp->minFilter != (int)param) {
				tp->minFilter = (int)param;
				gc->validationFlags |= VAL_PIPELINE;
			}
			break;

		case GL_TEXTURE_WRAP_S:
		case GL_TEXTURE_WRAP_T:
		case GL_TEXTURE_BORDER_COLOR:
			break;

		default:
#ifdef DEBUG
			printf("glTexParameteri: Invalid texture parameter.\n");
			gc->errorCode = GL_INVALID_ENUM;
#endif
			return;
	}
}

void glTexParameteriv(GLenum target, GLenum pname, const GLint *params) {
GLTextureObject	*tp;

#ifdef GL_TRACE_API
	printf("glTexParameteriv(%s, %s, %p)\n", GLConstantString(target), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glTexParameteriv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine appropriate texture object
	switch (target) {
	case GL_TEXTURE_1D:
		tp = gc->current1DObject;
		break;

	case GL_TEXTURE_2D:
		tp = gc->current2DObject;
		break;

	default:
#ifdef DEBUG
		printf("glTexParameteriv: Invalid texture target.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	switch (pname) {
		case GL_TEXTURE_MAG_FILTER:
#ifdef DEBUG
			switch (params[0]) {
			case GL_NEAREST:
			case GL_LINEAR:
				break;
			default:
				printf("glTexParameterf: Invalid texture parameter for GL_TEXTURE_MAG_FILTER.\n");
				gc->errorCode = GL_INVALID_ENUM;
			}
#endif
			tp->magFilter = params[0];
			break;

		case GL_TEXTURE_PRIORITY:
			tp->priority = params[0];
			break;

		case GL_TEXTURE_MIN_FILTER:
#ifdef DEBUG
			switch (params[0]) {
			case GL_NEAREST:
			case GL_NEAREST_MIPMAP_NEAREST:
			case GL_NEAREST_MIPMAP_LINEAR:
			case GL_LINEAR:
			case GL_LINEAR_MIPMAP_NEAREST:
			case GL_LINEAR_MIPMAP_LINEAR:
				break;
			default:
				printf("glTexParameterf: Invalid texture parameter for GL_TEXTURE_MIN_FILTER.\n");
				gc->errorCode = GL_INVALID_ENUM;
			}
#endif
			if (tp->minFilter != params[0]) {
				tp->minFilter = params[0];
				gc->validationFlags |= VAL_PIPELINE;
			}
			break;

		case GL_TEXTURE_WRAP_S:
		case GL_TEXTURE_WRAP_T:
		case GL_TEXTURE_BORDER_COLOR:
			break;

		default:
#ifdef DEBUG
			printf("glTexParameteriv: Invalid texture parameter.\n");
			gc->errorCode = GL_INVALID_ENUM;
#endif
			return;
	}
}

void glTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const GLvoid *pixels) {

}

void glTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const GLvoid *pixels) {

}

void glVertexPointer(GLint size, GLenum type, GLsizei stride, const GLvoid *pointer) {

}

void glViewport(GLint x, GLint y, GLsizei width, GLsizei height) {

	// Echo back API calls if trace active
#ifdef GL_TRACE_API
	printf("glViewport(%d, %d, %d, %d)\n", x, y, width, height);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glViewport: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}

	if ((x < 0) || (x >= gc->screenBuffer[0]->wide) || (y < 0) || (y >= gc->screenBuffer[0]->high) ||
	    (width < 0) || (width > gc->screenBuffer[0]->wide) || (x + width > gc->screenBuffer[0]->wide) ||
	    (height < 0) || (height > gc->screenBuffer[0]->high) || (y + height > gc->screenBuffer[0]->high)) {
		printf("glViewport: Invalid viewport settings.\n");
		gc->errorCode = GL_INVALID_VALUE;
	}
#endif

	// save viewport parameters
	gc->viewportX = x;
	gc->viewportY = y;
	gc->viewportWidth = width;
	gc->viewportHeight = height;

	// Set validation flag
	gc->validationFlags |= VAL_VIEWPORT;
}


