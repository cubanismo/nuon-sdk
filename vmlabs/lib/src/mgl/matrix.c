/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

// Matrix manipulation code.  Here is where API calls for
// matrix manipulation reside.
#include "gl.h"
#include <nuon/mutil.h>
#include <stdio.h>
#include <stdarg.h>
#include <math.h>
#include "context.h"
#include "globals.h"
#include "mpedefs.h"
#include "glutils.h"

void glFrustum(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar) {
double dx = right - left;
double dy = top - bottom;
double dz = zFar - zNear;
Matrix4 *md;
Matrix4 mt;
GLint e1, e2, e3, e4;

#ifdef GL_TRACE_API
	printf("glFrustum(%f, %f, %f, %f, %f, %f)\n", left, right, bottom, top, zNear, zFar);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glFrustum: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
		md = &gc->textureMatrix;
		break;
	default:
		return;
	}

	// Copy current matrix
	mt = *md;

	// Create new destination matrix

	// First row
	e1 = (2.0 * zNear / dx) * (1 << GLXYZWMODELSHIFT);
	e3 = ((right + left) / dx) * (1 << GLXYZWMODELSHIFT);
	md->m11 = FixMul(e1, mt.m11, GLXYZWMODELSHIFT) + FixMul(e3, mt.m31, GLXYZWMODELSHIFT);
	md->m12 = FixMul(e1, mt.m12, GLXYZWMODELSHIFT) + FixMul(e3, mt.m32, GLXYZWMODELSHIFT);
	md->m13 = FixMul(e1, mt.m13, GLXYZWMODELSHIFT) + FixMul(e3, mt.m33, GLXYZWMODELSHIFT);
	md->m14 = FixMul(e1, mt.m14, GLXYZWMODELSHIFT) + FixMul(e3, mt.m34, GLXYZWMODELSHIFT);

	// Second row
	e2 = (2.0 * zNear / dy) * (1 << GLXYZWMODELSHIFT);
	e3 = ((top + bottom) / dy) * (1 << GLXYZWMODELSHIFT);
	md->m21 = FixMul(e2, mt.m21, GLXYZWMODELSHIFT) + FixMul(e3, mt.m31, GLXYZWMODELSHIFT);
	md->m22 = FixMul(e2, mt.m22, GLXYZWMODELSHIFT) + FixMul(e3, mt.m32, GLXYZWMODELSHIFT);
	md->m23 = FixMul(e2, mt.m23, GLXYZWMODELSHIFT) + FixMul(e3, mt.m33, GLXYZWMODELSHIFT);
	md->m24 = FixMul(e2, mt.m24, GLXYZWMODELSHIFT) + FixMul(e3, mt.m34, GLXYZWMODELSHIFT);

	// Third row
	e3 = (-(zFar + zNear) / dz) * (1 << GLXYZWMODELSHIFT);
	e4 = (-2.0 * zFar * zNear / dz) * (1 << GLXYZWMODELSHIFT);
	md->m31 = FixMul(e3, mt.m31, GLXYZWMODELSHIFT) + FixMul(e4, mt.m41, GLXYZWMODELSHIFT);
	md->m32 = FixMul(e3, mt.m32, GLXYZWMODELSHIFT) + FixMul(e4, mt.m42, GLXYZWMODELSHIFT);
	md->m33 = FixMul(e3, mt.m33, GLXYZWMODELSHIFT) + FixMul(e4, mt.m43, GLXYZWMODELSHIFT);
	md->m34 = FixMul(e3, mt.m34, GLXYZWMODELSHIFT) + FixMul(e4, mt.m44, GLXYZWMODELSHIFT);

	// Fourth row
	md->m41 = -mt.m31;
	md->m42 = -mt.m32;
	md->m43 = -mt.m33;
	md->m44 = -mt.m34;
}

// Changes the current matrix to an identity matrix
void glLoadIdentity(void) {
register Matrix4* m;

#ifdef GL_TRACE_API
	printf("glLoadIdentity()\n");
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLoadIdentity: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		m = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		m = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		m = &gc->textureMatrix;
		break;
	}

	// Set appropriate matrix to identity
	m->m11 = m->m22 = m->m33 = m->m44 = (1 << GLTRIGSHIFT);
	m->m12 = m->m13 = m->m14 = m->m21 = m->m23 = m->m24 =
	m->m31 = m->m32 = m->m34 = m->m41 = m->m42 = m->m43 = 0;
}

void glLoadMatrixd(register const GLdouble *m) {
register Matrix4* md;

#ifdef GL_TRACE_API
	printf("glLoadMatrixd(%p)\n", m);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLoadMatrixd: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	// Set appropriate matrix
	md->m11 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m21 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m31 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m41 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m12 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m22 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m32 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m42 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m13 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m23 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m33 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m43 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m14 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m24 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m34 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
	md->m44 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5);
}

void glLoadMatrixf(register const GLfloat *m) {
register Matrix4* md;

#ifdef GL_TRACE_API
	printf("glLoadMatrixf(%p)\n", m);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLoadMatrixf: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	// Set appropriate matrix
	md->m11 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m21 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m31 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m41 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m12 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m22 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m32 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m42 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m13 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m23 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m33 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m43 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m14 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m24 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m34 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
	md->m44 = ((*m++) * (1 << GLTRIGSHIFT) + 0.5f);
}

void glLoadMatrixfpExt(register const GLint *m) {
Matrix4 *md;
#ifdef GL_TRACE_API
	printf("glLoadMatrixfpExt(%p)\n", m);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLoadMatrixfpExt: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	// Set appropriate matrix
	md->m11 = *m++;
	md->m21 = *m++;
	md->m31 = *m++;
	md->m41 = *m++;
	md->m12 = *m++;
	md->m22 = *m++;
	md->m32 = *m++;
	md->m42 = *m++;
	md->m13 = *m++;
	md->m23 = *m++;
	md->m33 = *m++;
	md->m43 = *m++;
	md->m14 = *m++;
	md->m24 = *m++;
	md->m34 = *m++;
	md->m44 = *m++;
}

void glMatrixMode (GLenum mode) {

#ifdef GL_TRACE_API
	printf("glMatrixMode(%s)\n", GLConstantString(mode));
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glMatrixMode: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif


#ifdef DEBUG
	switch (mode) {
	case GL_MODELVIEW:
	case GL_PROJECTION:
	case GL_TEXTURE:
		break;
	default:
		printf("Invalid Parameters: glMatrixMode()\n");
		return;
	}
#endif

	// Set appropriate active matrix
	gc->currentMatrix = mode;
}

void glMultMatrixd(register const GLdouble *m) {
Matrix4* md;
register GLint e1, e2, e3, e4;
register GLint m11, m12, m13, m14;
register GLint m21, m22, m23, m24;
register GLint m31, m32, m33, m34;
register GLint m41, m42, m43, m44;

#ifdef GL_TRACE_API
	printf("glMultMatrixd(%p)\n", m);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glMultMatrixd: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	// Perform multiplication in 18.14 fixed point (a conscious decision on
	// the part of the designer, so sue me)
	m11 = md->m11;
	m12 = md->m12;
	m13 = md->m13;
	m14 = md->m14;
	m21 = md->m21;
	m22 = md->m22;
	m23 = md->m23;
	m24 = md->m24;
	m31 = md->m31;
	m32 = md->m32;
	m33 = md->m33;
	m34 = md->m34;
	m41 = md->m41;
	m42 = md->m42;
	m43 = md->m43;
	m44 = md->m44;

	// Generate first column
	e1 = *m * (1 << GLTRIGSHIFT) + 0.5;
	e2 = *(m + 1) * (1 << GLTRIGSHIFT) + 0.5;
	e3 = *(m + 2) * (1 << GLTRIGSHIFT) + 0.5;
	e4 = *(m + 3) * (1 << GLTRIGSHIFT) + 0.5;
	md->m11 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m21 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m31 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m41 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);

	// Generate second column
	e1 = *(m + 4) * (1 << GLTRIGSHIFT) + 0.5;
	e2 = *(m + 5) * (1 << GLTRIGSHIFT) + 0.5;
	e3 = *(m + 6) * (1 << GLTRIGSHIFT) + 0.5;
	e4 = *(m + 7) * (1 << GLTRIGSHIFT) + 0.5;
	md->m12 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m22 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m32 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m42 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);


	// Generate third column
	e1 = *(m + 8) * (1 << GLTRIGSHIFT) + 0.5;
	e2 = *(m + 9) * (1 << GLTRIGSHIFT) + 0.5;
	e3 = *(m + 10) * (1 << GLTRIGSHIFT) + 0.5;
	e4 = *(m + 11) * (1 << GLTRIGSHIFT) + 0.5;
	md->m13 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m23 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m33 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m43 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);

	// Generate fourth column
	e1 = *(m + 12) * (1 << GLTRIGSHIFT) + 0.5;
	e2 = *(m + 13) * (1 << GLTRIGSHIFT) + 0.5;
	e3 = *(m + 14) * (1 << GLTRIGSHIFT) + 0.5;
	e4 = *(m + 15) * (1 << GLTRIGSHIFT) + 0.5;
	md->m14 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m24 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m34 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m44 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);
}

void glMultMatrixf(const GLfloat *m) {
Matrix4* md;
register GLint e1, e2, e3, e4;
register GLint m11, m12, m13, m14;
register GLint m21, m22, m23, m24;
register GLint m31, m32, m33, m34;
register GLint m41, m42, m43, m44;

#ifdef GL_TRACE_API
	printf("glMultMatrixf(%p)\n", m);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glMultMatrixf: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	// Perform multiplication in fixed point (a conscious decision on
	// the part of the designer, so sue me (SML 8/29/98))
	m11 = md->m11;
	m12 = md->m12;
	m13 = md->m13;
	m14 = md->m14;
	m21 = md->m21;
	m22 = md->m22;
	m23 = md->m23;
	m24 = md->m24;
	m31 = md->m31;
	m32 = md->m32;
	m33 = md->m33;
	m34 = md->m34;
	m41 = md->m41;
	m42 = md->m42;
	m43 = md->m43;
	m44 = md->m44;

	// Generate first column
	e1 = *m * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e2 = *(m + 1) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e3 = *(m + 2) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e4 = *(m + 3) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	md->m11 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m21 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m31 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m41 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);

	// Generate second column
	e1 = *(m + 4) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e2 = *(m + 5) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e3 = *(m + 6) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e4 = *(m + 7) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	md->m12 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m22 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m32 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m42 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);


	// Generate third column
	e1 = *(m + 8) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e2 = *(m + 9) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e3 = *(m + 10) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e4 = *(m + 11) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	md->m13 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m23 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m33 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m43 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);

	// Generate fourth column
	e1 = *(m + 12) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e2 = *(m + 13) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e3 = *(m + 14) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	e4 = *(m + 15) * (float)(1 << GLTRIGSHIFT) + 0.5f;
	md->m14 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m24 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m34 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m44 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);
}

void glMultMatrixfpExt(const GLint *m) {
Matrix4* md;
register GLint e1, e2, e3, e4;
register GLint m11, m12, m13, m14;
register GLint m21, m22, m23, m24;
register GLint m31, m32, m33, m34;
register GLint m41, m42, m43, m44;

#ifdef GL_TRACE_API
	printf("glMultMatrixfp(%p)\n", m);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glMultMatrixf: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	// Perform multiplication in fixed point (a conscious decision on
	// the part of the designer, so sue me (SML 8/29/98))
	m11 = md->m11;
	m12 = md->m12;
	m13 = md->m13;
	m14 = md->m14;
	m21 = md->m21;
	m22 = md->m22;
	m23 = md->m23;
	m24 = md->m24;
	m31 = md->m31;
	m32 = md->m32;
	m33 = md->m33;
	m34 = md->m34;
	m41 = md->m41;
	m42 = md->m42;
	m43 = md->m43;
	m44 = md->m44;

	// Generate first column
	e1 = *m;
	e2 = *(m + 1);
	e3 = *(m + 2);
	e4 = *(m + 3);
	md->m11 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m21 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m31 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m41 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);

	// Generate second column
	e1 = *(m + 4);
	e2 = *(m + 5);
	e3 = *(m + 6);
	e4 = *(m + 7);
	md->m12 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m22 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m32 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m42 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);


	// Generate third column
	e1 = *(m + 8);
	e2 = *(m + 9);
	e3 = *(m + 10);
	e4 = *(m + 11);
	md->m13 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m23 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m33 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m43 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);

	// Generate fourth column
	e1 = *(m + 12);
	e2 = *(m + 13);
	e3 = *(m + 14);
	e4 = *(m + 15);
	md->m14 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT) +
				FixMul(m14, e4, GLTRIGSHIFT);
	md->m24 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT) +
				FixMul(m24, e4, GLTRIGSHIFT);
	md->m34 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT) +
				FixMul(m34, e4, GLTRIGSHIFT);
	md->m44 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT) +
				FixMul(m44, e4, GLTRIGSHIFT);
}


void glOrtho(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar) {
GLint dx = (2 << GLTRIGSHIFT) / (right - left);
GLint dy = (2 << GLTRIGSHIFT) / (top - bottom);
GLint dz = (-2 << GLTRIGSHIFT) / (zFar - zNear);
GLint tx = (-1 << GLTRIGSHIFT) * (right + left) / (right - left);
GLint ty = (-1 << GLTRIGSHIFT) * (top + bottom) / (top - bottom);
GLint tz = (-1 << GLTRIGSHIFT) * (zFar + zNear) / (zFar - zNear);
Matrix4 *md;
GLint e1, e2, e3, e4;

#ifdef GL_TRACE_API
	printf("glOrtho(%f, %f, %f, %f, %f, %f)\n", left, right, bottom, top, zNear, zFar);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glOrtho: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
		md = &gc->textureMatrix;
		break;
	default:
		return;
	}

	// Generate new matrix
	e1 = md->m41;
	e2 = md->m42;
	e3 = md->m43;
	e4 = md->m44;
	md->m11 = FixMul(dx, md->m11, GLTRIGSHIFT) + FixMul(tx, e1, GLTRIGSHIFT);
	md->m12 = FixMul(dx, md->m12, GLTRIGSHIFT) + FixMul(tx, e2, GLTRIGSHIFT);
	md->m13 = FixMul(dx, md->m13, GLTRIGSHIFT) + FixMul(tx, e3, GLTRIGSHIFT);
	md->m14 = FixMul(dx, md->m14, GLTRIGSHIFT) + FixMul(tx, e4, GLTRIGSHIFT);
	md->m21 = FixMul(dy, md->m21, GLTRIGSHIFT) + FixMul(ty, e1, GLTRIGSHIFT);
	md->m22 = FixMul(dy, md->m22, GLTRIGSHIFT) + FixMul(ty, e2, GLTRIGSHIFT);
	md->m23 = FixMul(dy, md->m23, GLTRIGSHIFT) + FixMul(ty, e3, GLTRIGSHIFT);
	md->m24 = FixMul(dy, md->m24, GLTRIGSHIFT) + FixMul(ty, e4, GLTRIGSHIFT);
	md->m31 = FixMul(dz, md->m31, GLTRIGSHIFT) + FixMul(tz, e1, GLTRIGSHIFT);
	md->m32 = FixMul(dz, md->m32, GLTRIGSHIFT) + FixMul(tz, e2, GLTRIGSHIFT);
	md->m33 = FixMul(dz, md->m33, GLTRIGSHIFT) + FixMul(tz, e3, GLTRIGSHIFT);
	md->m34 = FixMul(dz, md->m34, GLTRIGSHIFT) + FixMul(tz, e4, GLTRIGSHIFT);
}

void glPopMatrix(void) {
Matrix4 *ms, *md;
#ifdef GL_TRACE_API
	printf("glPopMatrix()\n");
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glPopMatrix: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
#ifdef DEBUG
		if (gc->mvMatrixStackDepth == 0) {
			gc->errorCode = GL_STACK_UNDERFLOW;
			printf("ModelView matrix stack underflow.\n");
			return;
		}
#endif
		ms = &gc->mvMatrixStack[--gc->mvMatrixStackDepth];
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
#ifdef DEBUG
		if (gc->prMatrixStackDepth == 0) {
			gc->errorCode = GL_STACK_UNDERFLOW;
			printf("Projection matrix stack underflow.\n");
			return;
		}
#endif
		ms = &gc->prMatrixStack[--gc->prMatrixStackDepth];
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
#ifdef DEBUG
		if (gc->txMatrixStackDepth == 0) {
			gc->errorCode = GL_STACK_UNDERFLOW;
			printf("Texture matrix stack underflow.\n");
			return;
		}
#endif
		ms = &gc->txMatrixStack[--gc->txMatrixStackDepth];
		break;
	}

	// Copy matrix off of stack
	*md = *ms;
}

void glPushMatrix(void) {
Matrix4 *ms, *md;
#ifdef GL_TRACE_API
	printf("glPushMatrix()\n");
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glPushMatrix: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		ms = &gc->modelviewMatrix;
#ifdef DEBUG
		if (gc->mvMatrixStackDepth == GL_MVMATRIXSTACK_DEPTH) {
			gc->errorCode = GL_STACK_OVERFLOW;
			printf("ModelView matrix stack overflow.\n");
			return;
		}
#endif
		md = &gc->mvMatrixStack[gc->mvMatrixStackDepth++];
		break;
	case GL_PROJECTION:
		ms = &gc->projectionMatrix;
#ifdef DEBUG
		if (gc->prMatrixStackDepth == GL_PRMATRIXSTACK_DEPTH) {
			gc->errorCode = GL_STACK_OVERFLOW;
			printf("Projection matrix stack overflow.\n");
			return;
		}
#endif
		md = &gc->prMatrixStack[gc->prMatrixStackDepth++];
		break;
	case GL_TEXTURE:
	default:
		ms = &gc->textureMatrix;
#ifdef DEBUG
		if (gc->txMatrixStackDepth == GL_TXMATRIXSTACK_DEPTH) {
			gc->errorCode = GL_STACK_OVERFLOW;
			printf("Texture matrix stack overflow.\n");
			return;
		}
#endif
		md = &gc->txMatrixStack[gc->txMatrixStackDepth++];
		break;
	}

	// Copy matrix onto stack
	*md = *ms;
}

void glRotated(GLdouble angle, GLdouble x, GLdouble y, GLdouble z) {
GLint ix = x * (double)(1 << GLTRIGSHIFT) + 0.5;
GLint iy = y * (double)(1 << GLTRIGSHIFT) + 0.5;
GLint iz = z * (double)(1 << GLTRIGSHIFT) + 0.5;
Matrix4 *md;
register GLint e1, e2, e3;
GLint m11, m12, m13, m14;
GLint m21, m22, m23, m24;
GLint m31, m32, m33, m34;
GLint m41, m42, m43, m44;
GLint c, s, c1;

#ifdef GL_TRACE_API
	printf("glRotated(%9.5f, %9.5f, %9.5f, %9.5f)\n", angle, x, y, z);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glRotated: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	angle *= -65536.0 / 360.0;			// Degrees to 16.16 rotations conversion and
										// right-handed system flip.
	FixSinCos((int)angle, &s, &c);
	c1 = 0x40000000 - c;

	// Copy Destination matrix into temporary spot
	m11 = md->m11;
	m12 = md->m12;
	m13 = md->m13;
	m14 = md->m14;
	m21 = md->m21;
	m22 = md->m22;
	m23 = md->m23;
	m24 = md->m24;
	m31 = md->m31;
	m32 = md->m32;
	m33 = md->m33;
	m34 = md->m34;
	m41 = md->m41;
	m42 = md->m42;
	m43 = md->m43;
	m44 = md->m44;

	// Calculate first column
	e1 = (FixMul(FixMul(ix, ix, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(ix, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(iz, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(ix, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(iy, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	md->m11 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m21 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m31 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m41 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate second column
	e1 = (FixMul(FixMul(ix, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(iz, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(iy, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(iy, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(ix, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	md->m12 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m22 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m32 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m42 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate third column
	e1 = (FixMul(FixMul(ix, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(iy, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(iy, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(ix, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(iz, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	md->m13 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m23 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m33 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m43 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate fourth column
	md->m14 = 	m14;
	md->m24 = 	m24;
	md->m34 = 	m34;
	md->m44 = 	m44;
}

void glRotatef(GLfloat angle, GLfloat x, GLfloat y, GLfloat z) {
GLint ix = x * (float)(1 << GLTRIGSHIFT) + 0.5f;
GLint iy = y * (float)(1 << GLTRIGSHIFT) + 0.5f;
GLint iz = z * (float)(1 << GLTRIGSHIFT) + 0.5f;
Matrix4 *md;
register GLint e1, e2, e3;
GLint m11, m12, m13, m14;
GLint m21, m22, m23, m24;
GLint m31, m32, m33, m34;
GLint m41, m42, m43, m44;
GLint c, s, c1;

#ifdef GL_TRACE_API
	printf("glRotatef(%9.5f, %9.5f, %9.5f, %9.5f)\n", angle, x, y, z);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glRotatef: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	angle *= -65536.0f / 360.0f;		// Degrees to 16.16 rotations conversion
										// and right-handed system flip.
	FixSinCos((int)angle, &s, &c);
	c1 = 0x40000000 - c;

	// Copy Destination matrix into temporary spot
	m11 = md->m11;
	m12 = md->m12;
	m13 = md->m13;
	m14 = md->m14;
	m21 = md->m21;
	m22 = md->m22;
	m23 = md->m23;
	m24 = md->m24;
	m31 = md->m31;
	m32 = md->m32;
	m33 = md->m33;
	m34 = md->m34;
	m41 = md->m41;
	m42 = md->m42;
	m43 = md->m43;
	m44 = md->m44;

	// Calculate first column
	e1 = (FixMul(FixMul(ix, ix, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(ix, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(iz, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(ix, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(iy, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	md->m11 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m21 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m31 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m41 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate second column
	e1 = (FixMul(FixMul(ix, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(iz, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(iy, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(iy, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(ix, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	md->m12 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m22 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m32 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m42 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate third column
	e1 = (FixMul(FixMul(ix, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(iy, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(iy, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(ix, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(iz, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	md->m13 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m23 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m33 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m43 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate fourth column
	md->m14 = 	m14;
	md->m24 = 	m24;
	md->m34 = 	m34;
	md->m44 = 	m44;
}

void glRotatefpExt(GLint angle, GLint x, GLint y, GLint z) {
GLint ix = x << (GLTRIGSHIFT - GLXYZWMODELSHIFT);
GLint iy = y << (GLTRIGSHIFT - GLXYZWMODELSHIFT);
GLint iz = z << (GLTRIGSHIFT - GLXYZWMODELSHIFT);
Matrix4 *md;
register GLint e1, e2, e3;
GLint m11, m12, m13, m14;
GLint m21, m22, m23, m24;
GLint m31, m32, m33, m34;
GLint m41, m42, m43, m44;
GLint c, s, c1;

#ifdef GL_TRACE_API
	printf("glRotatefpExt(0x%x, 0x%x, 0x%x, 0x%x)\n", angle, x, y, z);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glRotatefpExt: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		md = &gc->textureMatrix;
		break;
	}

	FixSinCos(-angle, &s, &c);
	c1 = 0x40000000 - c;

	// Copy Destination matrix into temporary spot
	m11 = md->m11;
	m12 = md->m12;
	m13 = md->m13;
	m14 = md->m14;
	m21 = md->m21;
	m22 = md->m22;
	m23 = md->m23;
	m24 = md->m24;
	m31 = md->m31;
	m32 = md->m32;
	m33 = md->m33;
	m34 = md->m34;
	m41 = md->m41;
	m42 = md->m42;
	m43 = md->m43;
	m44 = md->m44;

	// Calculate first column
	e1 = (FixMul(FixMul(ix, ix, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(ix, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(iz, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(ix, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(iy, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	md->m11 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m21 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m31 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m41 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate second column
	e1 = (FixMul(FixMul(ix, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(iz, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(iy, iy, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(iy, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(ix, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	md->m12 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m22 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m32 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m42 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate third column
	e1 = (FixMul(FixMul(ix, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) - FixMul(iy, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e2 = (FixMul(FixMul(iy, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + FixMul(ix, s, GLTRIGSHIFT)) >> (30 - GLTRIGSHIFT);
	e3 = (FixMul(FixMul(iz, iz, GLTRIGSHIFT), c1, GLTRIGSHIFT) + c) >> (30 - GLTRIGSHIFT);
	md->m13 = 	FixMul(m11, e1, GLTRIGSHIFT) +
				FixMul(m12, e2, GLTRIGSHIFT) +
				FixMul(m13, e3, GLTRIGSHIFT);
	md->m23 = 	FixMul(m21, e1, GLTRIGSHIFT) +
				FixMul(m22, e2, GLTRIGSHIFT) +
				FixMul(m23, e3, GLTRIGSHIFT);
	md->m33 = 	FixMul(m31, e1, GLTRIGSHIFT) +
				FixMul(m32, e2, GLTRIGSHIFT) +
				FixMul(m33, e3, GLTRIGSHIFT);
	md->m43 = 	FixMul(m41, e1, GLTRIGSHIFT) +
				FixMul(m42, e2, GLTRIGSHIFT) +
				FixMul(m43, e3, GLTRIGSHIFT);

	// Calculate fourth column
	md->m14 = 	m14;
	md->m24 = 	m24;
	md->m34 = 	m34;
	md->m44 = 	m44;
}

void glScaled(GLdouble x, GLdouble y, GLdouble z) {
GLint ix = x * (1 << GLTRIGSHIFT) + 0.5;
GLint iy = y * (1 << GLTRIGSHIFT) + 0.5;
GLint iz = z * (1 << GLTRIGSHIFT) + 0.5;
Matrix4 *mp;

#ifdef GL_TRACE_API
	printf("glScaled(%9.5f, %9.5f, %9.5f)\n", x, y, z);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glScaled: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		mp = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		mp = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		mp = &gc->textureMatrix;
		break;
	}

	// Perform calculation
	mp->m11 = FixMul(ix, mp->m11, GLTRIGSHIFT);
	mp->m12 = FixMul(ix, mp->m12, GLTRIGSHIFT);
	mp->m13 = FixMul(ix, mp->m13, GLTRIGSHIFT);
	mp->m14 = FixMul(ix, mp->m14, GLTRIGSHIFT);
	mp->m21 = FixMul(iy, mp->m21, GLTRIGSHIFT);
	mp->m22 = FixMul(iy, mp->m22, GLTRIGSHIFT);
	mp->m23 = FixMul(iy, mp->m23, GLTRIGSHIFT);
	mp->m24 = FixMul(iy, mp->m24, GLTRIGSHIFT);
	mp->m31 = FixMul(iz, mp->m31, GLTRIGSHIFT);
	mp->m32 = FixMul(iz, mp->m32, GLTRIGSHIFT);
	mp->m33 = FixMul(iz, mp->m33, GLTRIGSHIFT);
	mp->m34 = FixMul(iz, mp->m34, GLTRIGSHIFT);
}

void glScalef(GLfloat x, GLfloat y, GLfloat z) {
GLint ix = x * (1 << GLTRIGSHIFT) + 0.5f;
GLint iy = y * (1 << GLTRIGSHIFT) + 0.5f;
GLint iz = z * (1 << GLTRIGSHIFT) + 0.5f;
Matrix4 *mp;

#ifdef GL_TRACE_API
	printf("glScalef(%9.5f, %9.5f, %9.5f)\n", x, y, z);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glScalef: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		mp = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		mp = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		mp = &gc->textureMatrix;
		break;
	}

	// Perform calculation
	mp->m11 = FixMul(ix, mp->m11, GLTRIGSHIFT);
	mp->m12 = FixMul(ix, mp->m12, GLTRIGSHIFT);
	mp->m13 = FixMul(ix, mp->m13, GLTRIGSHIFT);
	mp->m14 = FixMul(ix, mp->m14, GLTRIGSHIFT);
	mp->m21 = FixMul(iy, mp->m21, GLTRIGSHIFT);
	mp->m22 = FixMul(iy, mp->m22, GLTRIGSHIFT);
	mp->m23 = FixMul(iy, mp->m23, GLTRIGSHIFT);
	mp->m24 = FixMul(iy, mp->m24, GLTRIGSHIFT);
	mp->m31 = FixMul(iz, mp->m31, GLTRIGSHIFT);
	mp->m32 = FixMul(iz, mp->m32, GLTRIGSHIFT);
	mp->m33 = FixMul(iz, mp->m33, GLTRIGSHIFT);
	mp->m34 = FixMul(iz, mp->m34, GLTRIGSHIFT);
}

void glTranslated(GLdouble x, GLdouble y, GLdouble z) {
GLint ix = x * (1 << GLTRIGSHIFT) + 0.5;
GLint iy = y * (1 << GLTRIGSHIFT) + 0.5;
GLint iz = z * (1 << GLTRIGSHIFT) + 0.5;
Matrix4 *mp;

#ifdef GL_TRACE_API
	printf("glTranslated(%9.5f, %9.5f, %9.5f)\n", x, y, z);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glTranslated: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		mp = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		mp = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		mp = &gc->textureMatrix;
		break;
	}

	// Perform translation
	mp->m14 += FixMul(ix, mp->m11, GLTRIGSHIFT) + FixMul(iy, mp->m12, GLTRIGSHIFT) + FixMul(iz, mp->m13, GLTRIGSHIFT);
	mp->m24 += FixMul(ix, mp->m21, GLTRIGSHIFT) + FixMul(iy, mp->m22, GLTRIGSHIFT) + FixMul(iz, mp->m23, GLTRIGSHIFT);
	mp->m34 += FixMul(ix, mp->m31, GLTRIGSHIFT) + FixMul(iy, mp->m32, GLTRIGSHIFT) + FixMul(iz, mp->m33, GLTRIGSHIFT);
	mp->m44 += FixMul(ix, mp->m41, GLTRIGSHIFT) + FixMul(iy, mp->m42, GLTRIGSHIFT) + FixMul(iz, mp->m43, GLTRIGSHIFT);
}

void glTranslatef(GLfloat x, GLfloat y, GLfloat z) {
GLint ix = x * (1 << GLTRIGSHIFT) + 0.5f;
GLint iy = y * (1 << GLTRIGSHIFT) + 0.5f;
GLint iz = z * (1 << GLTRIGSHIFT) + 0.5f;
Matrix4 *mp;

#ifdef GL_TRACE_API
	printf("glTranslatef(%9.5f, %9.5f, %9.5f)\n", x, y, z);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glTranslatef: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		mp = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		mp = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		mp = &gc->textureMatrix;
		break;
	}

	// Perform translation
	mp->m14 += FixMul(ix, mp->m11, GLTRIGSHIFT) + FixMul(iy, mp->m12, GLTRIGSHIFT) + FixMul(iz, mp->m13, GLTRIGSHIFT);
	mp->m24 += FixMul(ix, mp->m21, GLTRIGSHIFT) + FixMul(iy, mp->m22, GLTRIGSHIFT) + FixMul(iz, mp->m23, GLTRIGSHIFT);
	mp->m34 += FixMul(ix, mp->m31, GLTRIGSHIFT) + FixMul(iy, mp->m32, GLTRIGSHIFT) + FixMul(iz, mp->m33, GLTRIGSHIFT);
	mp->m44 += FixMul(ix, mp->m41, GLTRIGSHIFT) + FixMul(iy, mp->m42, GLTRIGSHIFT) + FixMul(iz, mp->m43, GLTRIGSHIFT);
}

void glTranslatefpExt(GLint x, GLint y, GLint z) {
GLint ix = x << (GLTRIGSHIFT - GLXYZWMODELSHIFT);
GLint iy = y << (GLTRIGSHIFT - GLXYZWMODELSHIFT);
GLint iz = z << (GLTRIGSHIFT - GLXYZWMODELSHIFT);
Matrix4 *mp;

#ifdef GL_TRACE_API
	printf("glTranslatefpExt(0x%x, 0x%x, 0x%x)\n", x, y, z);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glTranslatefpExt: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		mp = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		mp = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
	default:
		mp = &gc->textureMatrix;
		break;
	}

	// Perform translation
	mp->m14 += FixMul(ix, mp->m11, GLTRIGSHIFT) + FixMul(iy, mp->m12, GLTRIGSHIFT) + FixMul(iz, mp->m13, GLTRIGSHIFT);
	mp->m24 += FixMul(ix, mp->m21, GLTRIGSHIFT) + FixMul(iy, mp->m22, GLTRIGSHIFT) + FixMul(iz, mp->m23, GLTRIGSHIFT);
	mp->m34 += FixMul(ix, mp->m31, GLTRIGSHIFT) + FixMul(iy, mp->m32, GLTRIGSHIFT) + FixMul(iz, mp->m33, GLTRIGSHIFT);
	mp->m44 += FixMul(ix, mp->m41, GLTRIGSHIFT) + FixMul(iy, mp->m42, GLTRIGSHIFT) + FixMul(iz, mp->m43, GLTRIGSHIFT);
}

void gluPerspective(GLdouble fovy, GLdouble aspect, GLdouble zNear, GLdouble zFar)
{
	double f = 1.0 / tan((3.14159265 * fovy) / (180.0 * 2.0));
	Matrix4 *md;
	Matrix4 mt;
	GLint e1, e2, e3, e4;

#ifdef GL_TRACE_API
	printf("gluPerspective(%f, %f, %f, %f,)\n", fovy, aspect, zNear, zFar);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glFrustum: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Select appropriate matrix
	switch (gc->currentMatrix) {
	case GL_MODELVIEW:
		md = &gc->modelviewMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;
	case GL_PROJECTION:
		md = &gc->projectionMatrix;
		gc->validationFlags |= VAL_TOTAL_MATRIX;
		break;
	case GL_TEXTURE:
		md = &gc->textureMatrix;
		break;
	default:
		return;
	}

	// Copy current matrix
	mt = *md;

	// Create new destination matrix

	e1 = (f / aspect) * (1 << GLXYZWMODELSHIFT);
	e2 = f * (1 <<GLXYZWMODELSHIFT);
	e3 = ((zFar + zNear) / (zNear - zFar)) * (1 << GLXYZWMODELSHIFT);
	e4 = (2.0 * zFar * zNear / (zNear - zFar)) * (1 << GLXYZWMODELSHIFT);

	// First row
	md->m11 = FixMul(mt.m11, e1, GLXYZWMODELSHIFT);
	md->m12 = FixMul(mt.m12, e2, GLXYZWMODELSHIFT);
	md->m13 = FixMul(mt.m13, e3, GLXYZWMODELSHIFT) - mt.m14;
	md->m14 = FixMul(mt.m13, e4, GLXYZWMODELSHIFT);

	// Second row
	md->m21 = FixMul(mt.m21, e1, GLXYZWMODELSHIFT);
	md->m22 = FixMul(mt.m22, e2, GLXYZWMODELSHIFT);
	md->m23 = FixMul(mt.m23, e3, GLXYZWMODELSHIFT) - mt.m24;
	md->m24 = FixMul(mt.m23, e4, GLXYZWMODELSHIFT);

	// Third row
	md->m31 = FixMul(mt.m31, e1, GLXYZWMODELSHIFT);
	md->m32 = FixMul(mt.m32, e2, GLXYZWMODELSHIFT);
	md->m33 = FixMul(mt.m33, e3, GLXYZWMODELSHIFT) - mt.m34;
	md->m34 = FixMul(mt.m33, e4, GLXYZWMODELSHIFT);

	// Fourth row
	md->m41 = FixMul(mt.m41, e1, GLXYZWMODELSHIFT);
	md->m42 = FixMul(mt.m42, e2, GLXYZWMODELSHIFT);
	md->m43 = FixMul(mt.m43, e3, GLXYZWMODELSHIFT) - mt.m44;
	md->m44 = FixMul(mt.m43, e4, GLXYZWMODELSHIFT);
}

