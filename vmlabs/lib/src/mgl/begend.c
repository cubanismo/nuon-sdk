/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/


// Begin/End Code: If it's meant to be called between
// a begin and an end, and it's not inquiring into the OpenGL
// state, it's probably here
#include "gl.h"
#include "mpedefs.h"
#include "context.h"
#include "globals.h"
#include "glutils.h"
#include "debug.h"
#include <nuon/mutil.h>
#include <stdio.h>
#include <stdarg.h>

extern void RenderDirect(GLenum, const long *, long, int);

void FlushVertexBuffer(void)
{
	if ((gc->vertexCounter - gc->vertexStartCounter) > 0) {

		// Synchronize cache
		_DCacheSync();

		// Render geometry
		RenderDirect(gc->vertexFormat, (long *)&(gc->vertexBuffer[gc->vertexEntryStartCounter]),
			gc->vertexEntryCounter - gc->vertexEntryStartCounter, 1);

		// Check if wait is required
		if (gc->vertexEntryCounter == MAX_VERTS * 8) {
			gc->vertexCounter = 0;
			gc->vertexEntryCounter = 0;
			WaitForAllMPEs();
		}

		// Set starting counter
		gc->vertexStartCounter = gc->vertexCounter;
		gc->vertexEntryStartCounter = gc->vertexEntryCounter;
	}
}

void glBegin(GLenum mode) {
#ifdef GL_TRACE_API
	printf("glBegin(%s)\n", GLConstantString(mode));
#endif

#ifdef DEBUG
	switch (mode) {
	case GL_POINTS:
	case GL_LINES:
	case GL_LINE_STRIP:
	case GL_LINE_LOOP:
	case GL_TRIANGLES:
	case GL_TRIANGLE_STRIP:
	case GL_TRIANGLE_FAN:
	case GL_QUADS:
	case GL_QUAD_STRIP:
	case GL_POLYGON:
		break;
	default:
		printf("Invalid mode: glBegin\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
	}

	// Check if already within begin/end block
	if (gc->beginEndFlag) {
		printf("glBegin: already within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
	}
#endif
	// Signal primitive validation if primitive changed
	if (mode != gc->primitive) {
		gc->validationFlags |= VAL_PIPELINE;
		gc->primitive = mode;
	}

	// flush state

	glFlush();

	// Signal presence within begin/end block
	gc->beginEndFlag = GL_TRUE;
}

void glColor3b(GLbyte red, GLbyte green, GLbyte blue) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3b(%d, %d, %d)\n", (GLint)red, (GLint)green, (GLint)blue);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 7);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 7);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 7);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3bv(const GLbyte *v) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3bv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 7);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 7);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 7);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3d(GLdouble red, GLdouble green, GLdouble blue) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3d(%f, %f, %f)\n", red, green, blue);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = GLCOLORMAX * red;
	g = gc->currentColor.g = GLCOLORMAX * green;
	b = gc->currentColor.b = GLCOLORMAX * blue;
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3dv(const GLdouble *v) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3dv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = GLCOLORMAX * v[0];
	g = gc->currentColor.g = GLCOLORMAX * v[1];
	b = gc->currentColor.b = GLCOLORMAX * v[2];
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3f(GLfloat red, GLfloat green, GLfloat blue) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3f(%f, %f, %f)\n", red, green, blue);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = GLCOLORMAX * red;
	g = gc->currentColor.g = GLCOLORMAX * green;
	b = gc->currentColor.b = GLCOLORMAX * blue;
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3fv(const GLfloat *v) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3fv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = GLCOLORMAX * v[0];
	g = gc->currentColor.g = GLCOLORMAX * v[1];
	b = gc->currentColor.b = GLCOLORMAX * v[2];
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3i(GLint red, GLint green, GLint blue) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3i(%d, %d, %d)\n", (GLint)red, (GLint)green, (GLint)blue);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red,  31);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 31);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 31);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);

}

void glColor3iv(const GLint *v) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3iv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0],  31);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 31);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 31);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3s(GLshort red, GLshort green, GLshort blue) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3s(%d, %d, %d)\n", (GLint)red, (GLint)green, (GLint)blue);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red,  15);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 15);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 15);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3sv (const GLshort *v) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3sv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0],  15);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 15);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 15);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3ub(GLubyte red, GLubyte green, GLubyte blue) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3ub(%u, %u, %u)\n", (GLuint)red, (GLuint)green, (GLuint)blue);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 8);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 8);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 8);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3ubv (const GLubyte *v) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3ubv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 8);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 8);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 8);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3ui(GLuint red, GLuint green, GLuint blue) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3ui(%u, %u, %u)\n", (GLuint)red, (GLuint)green, (GLuint)blue);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 32);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 32);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 32);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3uiv (const GLuint *v) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3uiv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 32);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 32);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 32);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3us(GLushort red, GLushort green, GLushort blue) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3us(%u, %u, %u)\n", (GLuint)red, (GLuint)green, (GLuint)blue);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 16);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 16);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 16);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor3usv (const GLushort *v) {
GLuint r, g, b;
#ifdef GL_TRACE_API
	printf("glColor3usv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 16);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 16);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 16);
	gc->currentColor.a = GLCOLORMAX;
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, GLCOLORMAX);
}

void glColor4b(GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4b(%d, %d, %d, %d)\n", (GLint)red, (GLint)green, (GLint)blue, (GLint)alpha);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 7);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 7);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 7);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, alpha, 7);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4bv (const GLbyte *v) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4bv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 7);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 7);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 7);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, v[3], 7);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4d(GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4d(%f, %f, %f, %f)\n", red, green, blue, alpha);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = (GLuint)(GLCOLORMAX * red);
	g = gc->currentColor.g = (GLuint)(GLCOLORMAX * green);
	b = gc->currentColor.b = (GLuint)(GLCOLORMAX * blue);
	a = gc->currentColor.a = (GLuint)(GLCOLORMAX * alpha);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4dv (const GLdouble *v) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4dv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = (GLuint)(GLCOLORMAX * v[0]);
	g = gc->currentColor.g = (GLuint)(GLCOLORMAX * v[1]);
	b = gc->currentColor.b = (GLuint)(GLCOLORMAX * v[2]);
	a = gc->currentColor.a = (GLuint)(GLCOLORMAX * v[3]);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4f(%f, %f, %f, %f)\n", red, green, blue, alpha);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = (GLuint)(GLCOLORMAX * red);
	g = gc->currentColor.g = (GLuint)(GLCOLORMAX * green);
	b = gc->currentColor.b = (GLuint)(GLCOLORMAX * blue);
	a = gc->currentColor.a = (GLuint)(GLCOLORMAX * alpha);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4fv (const GLfloat *v) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4fv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = (GLuint)(GLCOLORMAX * v[0]);
	g = gc->currentColor.g = (GLuint)(GLCOLORMAX * v[1]);
	b = gc->currentColor.b = (GLuint)(GLCOLORMAX * v[2]);
	a = gc->currentColor.a = (GLuint)(GLCOLORMAX * v[3]);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4i(GLint red, GLint green, GLint blue, GLint alpha) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4i(%d, %d, %d, %d)\n", red, green, blue, alpha);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 31);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 31);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 31);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, alpha, 31);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4iv(const GLint *v) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4iv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 31);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 31);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 31);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, v[3], 31);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4s (GLshort red, GLshort green, GLshort blue, GLshort alpha) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4s(%d, %d, %d, %d)\n", (GLint)red, (GLint)green, (GLint)blue, (GLint)alpha);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 15);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 15);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 15);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, alpha, 15);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4sv(const GLshort *v) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4sv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 15);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 15);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 15);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, v[3], 15);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4ub (GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4ub(%u, %u, %u, %u)\n", (GLuint)red, (GLuint)green, (GLuint)blue, (GLuint)alpha);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 8);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 8);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 8);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, alpha, 8);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4ubv(const GLubyte *v) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4ubv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 15);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 15);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 15);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, v[3], 15);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4ui (GLuint red, GLuint green, GLuint blue, GLuint alpha) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4ui(%u, %u, %u, %u)\n", (GLuint)red, (GLuint)green, (GLuint)blue, (GLuint)alpha);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 32);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 32);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 32);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, alpha, 32);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4uiv(const GLuint *v) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4uiv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 32);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 32);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 32);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, v[3], 32);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4us (GLushort red, GLushort green, GLushort blue, GLushort alpha) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor3us(%u, %u, %u, %u)\n", (GLuint)red, (GLuint)green, (GLuint)blue, (GLuint)alpha);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, red, 16);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, green, 16);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, blue, 16);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, alpha, 16);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glColor4usv(const GLushort *v) {
GLuint r, g, b, a;
#ifdef GL_TRACE_API
	printf("glColor4usv(%p)\n", v);
#endif

	// Convert RGB components to internal format
	r = gc->currentColor.r = FixMul(1 << GLCOLORSHIFT, v[0], 16);
	g = gc->currentColor.g = FixMul(1 << GLCOLORSHIFT, v[1], 16);
	b = gc->currentColor.b = FixMul(1 << GLCOLORSHIFT, v[2], 16);
	a = gc->currentColor.a = FixMul(1 << GLCOLORSHIFT, v[3], 16);
	gc->currentVertexColor = COLOR_GRB888Alpha(r, g, b, a);
}

void glEnd (void) {
#ifdef GL_TRACE_API
	printf("glEnd()\n");
#endif

	// Check if within begin/end block
#ifdef DEBUG
	if (!gc->beginEndFlag) {
		printf("glEnd: Not within Begin/End block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif
	gc->beginEndFlag = GL_FALSE;

	FlushVertexBuffer();
}

void glNormal3b(GLbyte nx, GLbyte ny, GLbyte nz) {
#ifdef GL_TRACE_API
	printf("glNormal3b(%d, %d, %d)\n", nx, ny, nz);
#endif

	gc->currentNormal.x = nx << (GLNORMALSHIFT - 7);
	gc->currentNormal.y = ny << (GLNORMALSHIFT - 7);
	gc->currentNormal.z = nz << (GLNORMALSHIFT - 7);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3bv(const GLbyte *v) {
#ifdef GL_TRACE_API
	printf("glNormal3bv(%p)\n", v);
#endif

	gc->currentNormal.x = *v++ << (GLNORMALSHIFT - 7);
	gc->currentNormal.y = *v++ << (GLNORMALSHIFT - 7);
	gc->currentNormal.z = *v++ << (GLNORMALSHIFT - 7);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3d(GLdouble nx, GLdouble ny, GLdouble nz) {
#ifdef GL_TRACE_API
	printf("glNormal3d(%f, %f, %f)\n", nx, ny, nz);
#endif

	gc->currentNormal.x = nx * (1 << GLNORMALSHIFT);
	gc->currentNormal.y = ny * (1 << GLNORMALSHIFT);
	gc->currentNormal.z = nz * (1 << GLNORMALSHIFT);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3dv(const GLdouble *v) {
#ifdef GL_TRACE_API
	printf("glNormal3fv(%p)\n", v);
#endif

	gc->currentNormal.x = *v++ * (1 << GLNORMALSHIFT);
	gc->currentNormal.y = *v++ * (1 << GLNORMALSHIFT);
	gc->currentNormal.z = *v++ * (1 << GLNORMALSHIFT);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3f(GLfloat nx, GLfloat ny, GLfloat nz) {
#ifdef GL_TRACE_API
	printf("glNormal3f(%f, %f, %f)\n", nx, ny, nz);
#endif

	gc->currentNormal.x = nx * (1 << GLNORMALSHIFT);
	gc->currentNormal.y = ny * (1 << GLNORMALSHIFT);
	gc->currentNormal.z = nz * (1 << GLNORMALSHIFT);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3fv(const GLfloat *v) {
#ifdef GL_TRACE_API
	printf("glNormal3fv(%p)\n", v);
#endif

	gc->currentNormal.x = *v++ * (1 << GLNORMALSHIFT);
	gc->currentNormal.y = *v++ * (1 << GLNORMALSHIFT);
	gc->currentNormal.z = *v++ * (1 << GLNORMALSHIFT);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3i(GLint nx, GLint ny, GLint nz) {
#ifdef GL_TRACE_API
	printf("glNormal3i(%d, %d, %d)\n", nx, ny, nz);
#endif

	gc->currentNormal.x = nx >> (31 - GLNORMALSHIFT);
	gc->currentNormal.y = ny >> (31 - GLNORMALSHIFT);
	gc->currentNormal.z = nz >> (31 - GLNORMALSHIFT);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3iv(const GLint *v) {
#ifdef GL_TRACE_API
	printf("glNormal3iv(%p)\n", v);
#endif

	gc->currentNormal.x = *v++ >> (31 - GLNORMALSHIFT);
	gc->currentNormal.y = *v++ >> (31 - GLNORMALSHIFT);
	gc->currentNormal.z = *v++ >> (31 - GLNORMALSHIFT);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3s(GLshort nx, GLshort ny, GLshort nz) {
#ifdef GL_TRACE_API
	printf("glNormal3s(%d, %d, %d)\n", nx, ny, nz);
#endif

	gc->currentNormal.x = nx >> (15 - GLNORMALSHIFT);
	gc->currentNormal.y = ny >> (15 - GLNORMALSHIFT);
	gc->currentNormal.z = nz >> (15 - GLNORMALSHIFT);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glNormal3sv(const GLshort *v) {
#ifdef GL_TRACE_API
	printf("glNormal3sv(%p)\n", v);
#endif

	gc->currentNormal.x = *v++ >> (15 - GLNORMALSHIFT);
	gc->currentNormal.y = *v++ >> (15 - GLNORMALSHIFT);
	gc->currentNormal.z = *v++ >> (15 - GLNORMALSHIFT);
	gc->currentVertexNormal = ((gc->currentNormal.x << (30 - GLNORMALSHIFT)) & 0xffe00000) |
							  ((gc->currentNormal.y << (30 - GLNORMALSHIFT - 11)) & 0x001ffc00) |
							  ((gc->currentNormal.z >> (-(30 - GLNORMALSHIFT - 22))) & 0x000003ff);
}

void glTexCoord1d(GLdouble s) {
#ifdef GL_TRACE_API
	printf("glTexCoord1d(%f)\n", s);
#endif

	// Set new texture coordinate
	gc->currentVertexS = (GLint)((1 << GLTEXCOORDSHIFT) * s) & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1dv (const GLdouble *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord1dv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = (GLint)((1 << GLTEXCOORDSHIFT) * v[0]) & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1f(GLfloat s) {
#ifdef GL_TRACE_API
	printf("glTexCoord1f(%f)\n", s);
#endif

	// Set new texture coordinate
	gc->currentVertexS = (GLint)((1 << GLTEXCOORDSHIFT) * s) & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1fv(const GLfloat *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord1fv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = (GLint)((1 << GLTEXCOORDSHIFT) * v[0]) & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1i(GLint s) {
#ifdef GL_TRACE_API
	printf("glTexCoord1i(%d)\n", s);
#endif

	// Set new texture coordinate
	gc->currentVertexS = ((1 << GLTEXCOORDSHIFT) * s) & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1iv(const GLint *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord1iv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = ((1 << GLTEXCOORDSHIFT) * v[0]) & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1s(GLshort s) {
#ifdef GL_TRACE_API
	printf("glTexCoord1s(%d)\n", s);
#endif

	// Set new texture coordinate
	gc->currentVertexS = ((1 << GLTEXCOORDSHIFT) * s) & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1sv(const GLshort *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord1sv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = ((1 << GLTEXCOORDSHIFT) * v[0]) & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1fp(GLint s) {
#ifdef GL_TRACE_API
	printf("glTexCoord1fp(%d)\n", s);
#endif

	// Set new texture coordinate
	gc->currentVertexS = s & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord1fpv(const GLint *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord1fpv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = v[0] & 0xffffffc0;
	gc->currentVertexT = 0;
}

void glTexCoord2d(GLdouble s, GLdouble t) {
#ifdef GL_TRACE_API
	printf("glTexCoord2d(%f, %f)\n", s, t);
#endif

	// Set new texture coordinate
	gc->currentVertexS = (GLint)((1 << GLTEXCOORDSHIFT) * s) & 0xffffffc0;
	gc->currentVertexT = (1 << GLTEXCOORDSHIFT) * t;
}

void glTexCoord2dv (const GLdouble *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord2dv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = (GLint)((1 << GLTEXCOORDSHIFT) * v[0]) & 0xffffffc0;
	gc->currentVertexT = (1 << GLTEXCOORDSHIFT) * v[1];
}

void glTexCoord2f(GLfloat s, GLfloat t) {
#ifdef GL_TRACE_API
	printf("glTexCoord2f(%f, %f)\n", s, t);
#endif

	// Set new texture coordinate
	gc->currentVertexS = (GLint)((1 << GLTEXCOORDSHIFT) * s) & 0xffffffc0;
	gc->currentVertexT = (1 << GLTEXCOORDSHIFT) * t;
}

void glTexCoord2fv(const GLfloat *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord2fv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = (GLint)((1 << GLTEXCOORDSHIFT) * v[0]) & 0xffffffc0;
	gc->currentVertexT = (1 << GLTEXCOORDSHIFT) * v[1];
}

void glTexCoord2i (GLint s, GLint t) {
#ifdef GL_TRACE_API
	printf("glTexCoord2i(%d, %d)\n", s, t);
#endif

	// Set new texture coordinate
	gc->currentVertexS = ((1 << GLTEXCOORDSHIFT) * s) & 0xffffffc0;
	gc->currentVertexT = (1 << GLTEXCOORDSHIFT) * t;
}

void glTexCoord2iv(const GLint *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord2iv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = ((1 << GLTEXCOORDSHIFT) * v[0]) & 0xffffffc0;
	gc->currentVertexT = (1 << GLTEXCOORDSHIFT) * v[1];
}

void glTexCoord2s(GLshort s, GLshort t) {
#ifdef GL_TRACE_API
	printf("glTexCoord2s(%d, %d)\n", s, t);
#endif

	// Set new texture coordinate
	gc->currentVertexS = ((1 << GLTEXCOORDSHIFT) * s) & 0xffffffc0;
	gc->currentVertexT = (1 << GLTEXCOORDSHIFT) * t;
}

void glTexCoord2sv(const GLshort *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord2sv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = ((1 << GLTEXCOORDSHIFT) * v[0]) & 0xffffffc0;
	gc->currentVertexT = (1 << GLTEXCOORDSHIFT) * v[1];
}

void glTexCoord2fp(GLint s, GLint t) {
#ifdef GL_TRACE_API
	printf("glTexCoord2f(%d, %d)\n", s, t);
#endif

	// Set new texture coordinate
	gc->currentVertexS = s & 0xffffffc0;
	gc->currentVertexT = t;
}

void glTexCoord2fpv(const GLint *v) {
#ifdef GL_TRACE_API
	printf("glTexCoord2fpv(%p)\n", v);
#endif

	// Set new texture coordinate
	gc->currentVertexS = v[0] & 0xffffffc0;
	gc->currentVertexT = v[1];
}

void glTexCoord3d(GLdouble s, GLdouble t, GLdouble r) {

}

void glTexCoord3dv(const GLdouble *v) {

}

void glTexCoord3f(GLfloat s, GLfloat t, GLfloat r) {

}

void glTexCoord3fv(const GLfloat *v) {

}

void glTexCoord3i(GLint s, GLint t, GLint r) {

}

void glTexCoord3iv(const GLint *v) {

}

void glTexCoord3s(GLshort s, GLshort t, GLshort r) {

}

void glTexCoord3sv(const GLshort *v) {

}

void glTexCoord4d(GLdouble s, GLdouble t, GLdouble r, GLdouble q) {

}

void glTexCoord4dv(const GLdouble *v) {

}

void glTexCoord4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q) {

}

void glTexCoord4fv(const GLfloat *v) {

}

void glTexCoord4i(GLint s, GLint t, GLint r, GLint q) {

}

void glTexCoord4iv(const GLint *v) {

}

void glTexCoord4s(GLshort s, GLshort t, GLshort r, GLshort q) {

}

void glTexCoord4sv(const GLshort *v) {

}

void glVertex2d(GLdouble x, GLdouble y) {

}

void glVertex2dv(const GLdouble *v) {

}

void glVertex2f(GLfloat x, GLfloat y) {

}

void glVertex2fv(const GLfloat *v) {

}

void glVertex2i(GLint x, GLint y) {

}

void glVertex2iv(const GLint *v) {

}

void glVertex2s(GLshort x, GLshort y) {

}

void glVertex2sv(const GLshort *v) {

}

void glVertex3d(GLdouble x, GLdouble y, GLdouble z) {
register GLint *p = &(gc->vertexBuffer[gc->vertexEntryCounter]);
#ifdef GL_TRACE_API
	printf("glVertex3d(%f, %f, %f)\n", x, y, z);
#endif

#ifdef DEBUG
	if (!(gc->beginEndFlag)) {
		printf("glVertex3d: cannot execute outside of begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Grab vertex information
	switch (gc->vertexFormat) {

	case VERTEX_XYZWUVN:
		*p++ = (GLint)(x * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(y * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(z * (1 << GLXYZWMODELSHIFT));
		*p++ = 1 << GLXYZWMODELSHIFT;
		*p++ = gc->currentVertexS;
		*p++ = gc->currentVertexT;
		*p++ = (gc->currentNormal.x << 16) | (gc->currentNormal.y & 0x0000ffff);
		*p++ = gc->currentNormal.z << 16;
		gc->vertexEntryCounter += 8;
		break;

	case VERTEX_XYZC:
		*p++ = (GLint)(x * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(y * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(z * (1 << GLXYZWMODELSHIFT));
		*p++ = gc->currentVertexColor;
		gc->vertexEntryCounter += 4;
		break;

	case VERTEX_XYZN:
		*p++ = (GLint)(x * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(y * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(z * (1 << GLXYZWMODELSHIFT));
		*p++ = gc->currentVertexNormal;
		gc->vertexEntryCounter += 4;
		break;

	default:
		// shouldn't happen
		DEBUG_ASSERT(0);
		break;
	}

	// Check for flush

	gc->vertexCounter++;

	if (gc->vertexEntryCounter == MAX_VERTS * 8) {
		FlushVertexBuffer();
	}
}

void glVertex3dv(const GLdouble *v) {
register GLint *p = &(gc->vertexBuffer[gc->vertexEntryCounter]);
#ifdef GL_TRACE_API
	printf("glVertex3dv(%p)\n", v);
#endif

#ifdef DEBUG
	if (!(gc->beginEndFlag)) {
		printf("glVertex3dv: cannot execute outside of begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Grab vertex information
	switch (gc->vertexFormat) {

	case VERTEX_XYZWUVN:
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = 1 << GLXYZWMODELSHIFT;
		*p++ = gc->currentVertexS;
		*p++ = gc->currentVertexT;
		*p++ = (gc->currentNormal.x << 16) | (gc->currentNormal.y & 0x0000ffff);
		*p++ = gc->currentNormal.z << 16;
		gc->vertexEntryCounter += 8;
		break;

	case VERTEX_XYZC:
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = gc->currentVertexColor;
		gc->vertexEntryCounter += 4;
		break;

	case VERTEX_XYZN:
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = gc->currentVertexNormal;
		gc->vertexEntryCounter += 4;
		break;

	default:
		// shouldn't happen
		DEBUG_ASSERT(0);
		break;
	}

	// Check for flush

	gc->vertexCounter++;

	if (gc->vertexEntryCounter == MAX_VERTS * 8) {
		FlushVertexBuffer();
	}
}

void glVertex3f(GLfloat x, GLfloat y, GLfloat z) {
register GLint *p = &(gc->vertexBuffer[gc->vertexEntryCounter]);
#ifdef GL_TRACE_API
	printf("glVertex3f(%f, %f, %f)\n", x, y, z);
#endif

#ifdef DEBUG
	if (!(gc->beginEndFlag)) {
		printf("glVertex3f: cannot execute outside of begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Grab vertex information
	switch (gc->vertexFormat) {

	case VERTEX_XYZWUVN:
		*p++ = (GLint)(x * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(y * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(z * (1 << GLXYZWMODELSHIFT));
		*p++ = 1 << GLXYZWMODELSHIFT;
		*p++ = gc->currentVertexS;
		*p++ = gc->currentVertexT;
		*p++ = (gc->currentNormal.x << 16) | (gc->currentNormal.y & 0x0000ffff);
		*p++ = gc->currentNormal.z << 16;
		gc->vertexEntryCounter += 8;
		break;

	case VERTEX_XYZC:
		*p++ = (GLint)(x * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(y * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(z * (1 << GLXYZWMODELSHIFT));
		*p++ = gc->currentVertexColor;
		gc->vertexEntryCounter += 4;
		break;

	case VERTEX_XYZN:
		*p++ = (GLint)(x * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(y * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)(z * (1 << GLXYZWMODELSHIFT));
		*p++ = gc->currentVertexNormal;
		gc->vertexEntryCounter += 4;
		break;

	default:
		// shouldn't happen
		DEBUG_ASSERT(0);
		break;
	}

	// Check for flush

	gc->vertexCounter++;

	if (gc->vertexEntryCounter == MAX_VERTS * 8) {
		FlushVertexBuffer();
	}
}

void glVertex3fv(const GLfloat *v) {
register GLint *p = &(gc->vertexBuffer[gc->vertexEntryCounter]);
#ifdef GL_TRACE_API
	printf("glVertex3fv(%p)\n", v);
#endif

#ifdef DEBUG
	if (!(gc->beginEndFlag)) {
		printf("glVertex3fv: cannot execute outside of begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Grab vertex information
	switch (gc->vertexFormat) {

	case VERTEX_XYZWUVN:
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = 1 << GLXYZWMODELSHIFT;
		*p++ = gc->currentVertexS;
		*p++ = gc->currentVertexT;
		*p++ = (gc->currentNormal.x << 16) | (gc->currentNormal.y & 0x0000ffff);
		*p++ = gc->currentNormal.z << 16;
		gc->vertexEntryCounter += 8;
		break;

	case VERTEX_XYZC:
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = gc->currentVertexColor;
		gc->vertexEntryCounter += 4;
		break;

	case VERTEX_XYZN:
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = (GLint)((*v++) * (1 << GLXYZWMODELSHIFT));
		*p++ = gc->currentVertexNormal;
		gc->vertexEntryCounter += 4;
		break;

	default:
		// shouldn't happen
		DEBUG_ASSERT(0);
		break;
	}

	// Check for flush

	gc->vertexCounter++;

	if (gc->vertexEntryCounter == MAX_VERTS * 8) {
		FlushVertexBuffer();
	}
}

void glVertex3i(GLint x, GLint y, GLint z) {
#ifdef GL_TRACE_API
	printf("glVertex3i(%d, %d, %d)\n", x, y, z);
#endif


}

void glVertex3iv(const GLint *v) {
#ifdef GL_TRACE_API
	printf("glVertex3iv(%p)\n", v);
#endif


}

void glVertex3s (GLshort x, GLshort y, GLshort z) {
#ifdef GL_TRACE_API
	printf("glVertex3s(%d, %d, %d)\n", x, y, z);
#endif


}

void glVertex3sv (const GLshort *v) {
#ifdef GL_TRACE_API
	printf("glVertex3sv(%p)\n", v);
#endif

}

void glVertex3fp(GLint x, GLint y, GLint z) {
register GLint *p = &(gc->vertexBuffer[gc->vertexEntryCounter]);
#ifdef GL_TRACE_API
	printf("glVertex3fp(%d, %d, %d)\n", x, y, z);
#endif

#ifdef DEBUG
	if (!(gc->beginEndFlag)) {
		printf("glVertex3fp: cannot execute outside of begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Grab vertex information
	switch (gc->vertexFormat) {

	case VERTEX_XYZWUVN:
		*p++ = x;
		*p++ = y;
		*p++ = z;
		*p++ = 1 << GLXYZWMODELSHIFT;
		*p++ = gc->currentVertexS;
		*p++ = gc->currentVertexT;
		*p++ = (gc->currentNormal.x << 16) | (gc->currentNormal.y & 0x0000ffff);
		*p++ = gc->currentNormal.z << 16;
		gc->vertexEntryCounter += 8;
		break;

	case VERTEX_XYZC:
		*p++ = x;
		*p++ = y;
		*p++ = z;
		*p++ = gc->currentVertexColor;
		gc->vertexEntryCounter += 4;
		break;

	case VERTEX_XYZN:
		*p++ = x;
		*p++ = y;
		*p++ = z;
		*p++ = gc->currentVertexNormal;
		gc->vertexEntryCounter += 4;
		break;

	default:
		// shouldn't happen
		DEBUG_ASSERT(0);
		break;
	}

	// Check for flush

	gc->vertexCounter++;

	if (gc->vertexEntryCounter == MAX_VERTS * 8) {
		FlushVertexBuffer();
	}
}

void glVertex3fpv(const GLint *v) {
register GLint *p = &(gc->vertexBuffer[gc->vertexEntryCounter]);
#ifdef GL_TRACE_API
	printf("glVertex3fpv(%p)\n", v);
#endif

#ifdef DEBUG
	if (!(gc->beginEndFlag)) {
		printf("glVertex3fpv: cannot execute outside of begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Grab vertex information
	switch (gc->vertexFormat) {

	case VERTEX_XYZWUVN:
		*p++ = *v++;
		*p++ = *v++;
		*p++ = *v++;
		*p++ = 1 << GLXYZWMODELSHIFT;
		*p++ = gc->currentVertexS;
		*p++ = gc->currentVertexT;
		*p++ = (gc->currentNormal.x << 16) | (gc->currentNormal.y & 0x0000ffff);
		*p++ = gc->currentNormal.z << 16;
		gc->vertexEntryCounter += 8;
		break;

	case VERTEX_XYZC:
		*p++ = *v++;
		*p++ = *v++;
		*p++ = *v++;
		*p++ = gc->currentVertexColor;
		gc->vertexEntryCounter += 4;
		break;

	case VERTEX_XYZN:
		*p++ = *v++;
		*p++ = *v++;
		*p++ = *v++;
		*p++ = gc->currentVertexNormal;
		gc->vertexEntryCounter += 4;
		break;

	default:
		// shouldn't happen
		DEBUG_ASSERT(0);
		break;
	}

	// Check for flush

	gc->vertexCounter++;

	if (gc->vertexEntryCounter == MAX_VERTS * 8) {
		FlushVertexBuffer();
	}
}

void glVertex4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w) {

}

void glVertex4dv(const GLdouble *v) {

}

void glVertex4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {
#ifdef GL_TRACE_API
	printf("glVertex4f(%f, %f, %f, %f)\n", x, y, z, w);
#endif


}

void glVertex4fv(const GLfloat *v) {

}

void glVertex4i(GLint x, GLint y, GLint z, GLint w) {

}

void glVertex4iv(const GLint *v) {

}

void glVertex4s(GLshort x, GLshort y, GLshort z, GLshort w) {

}

void glVertex4sv(const GLshort *v) {

}

