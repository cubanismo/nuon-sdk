/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

// Lighting-related OpenGL API calling code
#include "gl.h"
#include "mpedefs.h"
#include "context.h"
#include "globals.h"
#include "glutils.h"
#include <nuon/mutil.h>
#include <stdio.h>
#include <stdarg.h>

void glColorMaterial(GLenum face, GLenum mode) {
#ifdef GL_TRACE_API
	printf("glColorMaterial(%s, %s)\n", GLConstantString(face), GLConstantString(mode));
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glColorMaterial: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif
}

void glGetLightfv(GLenum light, GLenum pname, GLfloat *params) {
int lnum;
#ifdef GL_TRACE_API
	printf("glGetLightfv(%s, %s, %p)\n", GLConstantString(light), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetLightfv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Get appropriate light index
	lnum = light - GL_LIGHT0;
#ifdef DEBUG
	if ((lnum < 0) || (lnum >= MAX_LIGHTS)) {
		printf("glGetLightfv: Invalid light.\n");
		gc->errorCode = GL_INVALID_ENUM;
	}
#endif

	// Affect appropriate parameter
	switch (pname) {
	case GL_AMBIENT:
		params[0] = (float)(gc->light[lnum].c_amb.r) / GLCOLORMAX;
		params[1] = (float)(gc->light[lnum].c_amb.g) / GLCOLORMAX;
		params[2] = (float)(gc->light[lnum].c_amb.b) / GLCOLORMAX;
		params[3] = (float)(gc->light[lnum].c_amb.a) / GLCOLORMAX;
		break;

	case GL_DIFFUSE:
		params[0] = (float)(gc->light[lnum].c_dif.r) / GLCOLORMAX;
		params[1] = (float)(gc->light[lnum].c_dif.g) / GLCOLORMAX;
		params[2] = (float)(gc->light[lnum].c_dif.b) / GLCOLORMAX;
		params[3] = (float)(gc->light[lnum].c_dif.a) / GLCOLORMAX;
		break;

	case GL_SPECULAR:
		params[0] = (float)(gc->light[lnum].c_spec.r) / GLCOLORMAX;
		params[1] = (float)(gc->light[lnum].c_spec.g) / GLCOLORMAX;
		params[2] = (float)(gc->light[lnum].c_spec.b) / GLCOLORMAX;
		params[3] = (float)(gc->light[lnum].c_spec.a) / GLCOLORMAX;
		break;

	case GL_POSITION:
		params[0] = (float)(gc->light[lnum].pos.x) / (1 << GLXYZWMODELSHIFT);
		params[1] = (float)(gc->light[lnum].pos.y) / (1 << GLXYZWMODELSHIFT);
		params[2] = (float)(gc->light[lnum].pos.z) / (1 << GLXYZWMODELSHIFT);
		params[3] = (float)(gc->light[lnum].pos.w) / (1 << GLXYZWMODELSHIFT);
		break;

	case GL_SPOT_DIRECTION:
		params[0] = gc->light[lnum].dir.x;
		params[1] = gc->light[lnum].dir.y;
		params[2] = gc->light[lnum].dir.z;
		params[3] = gc->light[lnum].dir.w;
		break;

	case GL_SPOT_EXPONENT:
		params[0] = gc->light[lnum].exponent;
		break;

	case GL_SPOT_CUTOFF:
		params[0] = gc->light[lnum].cutoff;
		break;

	case GL_CONSTANT_ATTENUATION:
		params[0] = gc->light[lnum].kc;
		break;

	case GL_LINEAR_ATTENUATION:
		params[0] = gc->light[lnum].kl;
		break;

	case GL_QUADRATIC_ATTENUATION:
		params[0] = gc->light[lnum].kq;
		break;

#ifdef DEBUG
	default:
		printf("glGetLightfv: Invalid lighting parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
#endif
	}
}

void glGetLightiv(GLenum light, GLenum pname, GLint *params) {
int lnum;
#ifdef GL_TRACE_API
	printf("glGetLightiv(%s, %s, %p)\n", GLConstantString(light), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetLightiv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Get appropriate light index
	lnum = light - GL_LIGHT0;
#ifdef DEBUG
	if ((lnum < 0) || (lnum >= MAX_LIGHTS)) {
		printf("glGetLightiv: Invalid light.\n");
		gc->errorCode = GL_INVALID_ENUM;
	}
#endif

	// Affect appropriate parameter
	switch (pname) {
	case GL_AMBIENT:
		params[0] = FixMul(0x7fffffff, gc->light[lnum].c_amb.r, GLCOLORSHIFT);
		params[1] = FixMul(0x7fffffff, gc->light[lnum].c_amb.g, GLCOLORSHIFT);
		params[2] = FixMul(0x7fffffff, gc->light[lnum].c_amb.b, GLCOLORSHIFT);
		params[3] = FixMul(0x7fffffff, gc->light[lnum].c_amb.a, GLCOLORSHIFT);
		break;

	case GL_DIFFUSE:
		params[0] = FixMul(0x7fffffff, gc->light[lnum].c_dif.r, GLCOLORSHIFT);
		params[1] = FixMul(0x7fffffff, gc->light[lnum].c_dif.g, GLCOLORSHIFT);
		params[2] = FixMul(0x7fffffff, gc->light[lnum].c_dif.b, GLCOLORSHIFT);
		params[3] = FixMul(0x7fffffff, gc->light[lnum].c_dif.a, GLCOLORSHIFT);
		break;

	case GL_SPECULAR:
		params[0] = FixMul(0x7fffffff, gc->light[lnum].c_spec.r, GLCOLORSHIFT);
		params[1] = FixMul(0x7fffffff, gc->light[lnum].c_spec.g, GLCOLORSHIFT);
		params[2] = FixMul(0x7fffffff, gc->light[lnum].c_spec.b, GLCOLORSHIFT);
		params[3] = FixMul(0x7fffffff, gc->light[lnum].c_spec.a, GLCOLORSHIFT);
		break;

	case GL_POSITION:
		params[0] = gc->light[lnum].pos.x >> GLXYZWMODELSHIFT;
		params[1] = gc->light[lnum].pos.y >> GLXYZWMODELSHIFT;
		params[2] = gc->light[lnum].pos.z >> GLXYZWMODELSHIFT;
		params[3] = gc->light[lnum].pos.w >> GLXYZWMODELSHIFT;
		break;

	case GL_SPOT_DIRECTION:
		params[0] = gc->light[lnum].dir.x;
		params[1] = gc->light[lnum].dir.y;
		params[2] = gc->light[lnum].dir.z;
		params[3] = gc->light[lnum].dir.w;
		break;

	case GL_SPOT_EXPONENT:
		params[0] = gc->light[lnum].exponent;
		break;

	case GL_SPOT_CUTOFF:
		params[0] = gc->light[lnum].cutoff;
		break;

	case GL_CONSTANT_ATTENUATION:
		params[0] = gc->light[lnum].kc;
		break;

	case GL_LINEAR_ATTENUATION:
		params[0] = gc->light[lnum].kl;
		break;

	case GL_QUADRATIC_ATTENUATION:
		params[0] = gc->light[lnum].kq;
		break;

#ifdef DEBUG
	default:
		printf("glGetLightiv: Invalid lighting parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
#endif
	}


}

void glGetMaterialfv(GLenum face, GLenum pname, GLfloat *params) {
GLMaterial *mp;		// Source material pointer;
#ifdef GL_TRACE_API
	printf("glGetMaterialfv(%s, %s, %p)\n", GLConstantString(face), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetMaterialfv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine material pointer
	switch (face) {
	case GL_FRONT:
		mp = &(gc->frontMaterial);
		break;

	case GL_BACK:
		mp = &(gc->backMaterial);
		break;

	default:
#ifdef DEBUG
		printf("glGetMaterialfv: Invalid face choice.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	// Determine if material property is valid or not
	switch (pname) {

	case GL_AMBIENT:
		params[0] = mp->c_amb.r / GLCOLORMAX;
		params[1] = mp->c_amb.g / GLCOLORMAX;
		params[2] = mp->c_amb.b / GLCOLORMAX;
		params[3] = mp->c_amb.a / GLCOLORMAX;
		break;

	case GL_DIFFUSE:
		params[0] = mp->c_dif.r / GLCOLORMAX;
		params[1] = mp->c_dif.g / GLCOLORMAX;
		params[2] = mp->c_dif.b / GLCOLORMAX;
		params[3] = mp->c_dif.a / GLCOLORMAX;
		break;

	case GL_SPECULAR:
		params[0] = mp->c_spec.r / GLCOLORMAX;
		params[1] = mp->c_spec.g / GLCOLORMAX;
		params[2] = mp->c_spec.b / GLCOLORMAX;
		params[3] = mp->c_spec.a / GLCOLORMAX;
		break;

	case GL_EMISSION:
		params[0] = mp->c_emis.r / GLCOLORMAX;
		params[1] = mp->c_emis.g / GLCOLORMAX;
		params[2] = mp->c_emis.b / GLCOLORMAX;
		params[3] = mp->c_emis.a / GLCOLORMAX;
		break;

	case GL_SHININESS:
		params[0] =  mp->shininess;
		break;

	default:
#ifdef DEBUG
	printf("glGetMaterialfv: Invalid property.\n");
	gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glGetMaterialiv(GLenum face, GLenum pname, GLint *params) {
GLMaterial *mp;		// Source material pointer;
#ifdef GL_TRACE_API
	printf("glGetMaterialiv(%s, %s, %p)\n", GLConstantString(face), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glGetMaterialiv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine material pointer
	switch (face) {
	case GL_FRONT:
		mp = &(gc->frontMaterial);
		break;

	case GL_BACK:
		mp = &(gc->backMaterial);
		break;

	default:
#ifdef DEBUG
		printf("glGetMaterialiv: Invalid face choice.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	// Determine if material property is valid or not
	switch (pname) {

	case GL_AMBIENT:
		params[0] = FixMul(mp->c_amb.r, 0x7fffffff, GLCOLORSHIFT);
		params[1] = FixMul(mp->c_amb.g, 0x7fffffff, GLCOLORSHIFT);
		params[2] = FixMul(mp->c_amb.b, 0x7fffffff, GLCOLORSHIFT);
		params[3] = FixMul(mp->c_amb.a, 0x7fffffff, GLCOLORSHIFT);
		break;

	case GL_DIFFUSE:
		params[0] = FixMul(mp->c_dif.r, 0x7fffffff, GLCOLORSHIFT);
		params[1] = FixMul(mp->c_dif.g, 0x7fffffff, GLCOLORSHIFT);
		params[2] = FixMul(mp->c_dif.b, 0x7fffffff, GLCOLORSHIFT);
		params[3] = FixMul(mp->c_dif.a, 0x7fffffff, GLCOLORSHIFT);
		break;

	case GL_SPECULAR:
		params[0] = FixMul(mp->c_spec.r, 0x7fffffff, GLCOLORSHIFT);
		params[1] = FixMul(mp->c_spec.g, 0x7fffffff, GLCOLORSHIFT);
		params[2] = FixMul(mp->c_spec.b, 0x7fffffff, GLCOLORSHIFT);
		params[3] = FixMul(mp->c_spec.a, 0x7fffffff, GLCOLORSHIFT);
		break;

	case GL_EMISSION:
		params[0] = FixMul(mp->c_emis.r, 0x7fffffff, GLCOLORSHIFT);
		params[1] = FixMul(mp->c_emis.g, 0x7fffffff, GLCOLORSHIFT);
		params[2] = FixMul(mp->c_emis.b, 0x7fffffff, GLCOLORSHIFT);
		params[3] = FixMul(mp->c_emis.a, 0x7fffffff, GLCOLORSHIFT);
		break;

	case GL_SHININESS:
		params[0] =  mp->shininess;
		break;

	default:
#ifdef DEBUG
	printf("glGetMaterialiv: Invalid property.\n");
	gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glLightModelf(GLenum pname, GLfloat param) {
#ifdef GL_TRACE_API
	printf("glLightModelf(%s, %f)\n", GLConstantString(pname), param);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLightModelf: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Set appropriate param
	switch (pname) {
	case GL_LIGHT_MODEL_LOCAL_VIEWER:
	case GL_LIGHT_MODEL_TWO_SIDE:
		return;
	case GL_LIGHT_MODEL_AMBIENT:
	default:
#ifdef DEBUG
		printf("glLightModelf: Invalid enumeration.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glLightModelfv(GLenum pname, const GLfloat *params) {
#ifdef GL_TRACE_API
	printf("glLightModelfv(%s, %p)\n", GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLightModelfv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Set appropriate param
	switch (pname) {
	case GL_LIGHT_MODEL_AMBIENT:
		gc->lightModelAmbient.r = GLCOLORMAX * params[0];
		gc->lightModelAmbient.g = GLCOLORMAX * params[1];
		gc->lightModelAmbient.b = GLCOLORMAX * params[2];
		gc->lightModelAmbient.a = GLCOLORMAX * params[3];
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		return;
	case GL_LIGHT_MODEL_LOCAL_VIEWER:
	case GL_LIGHT_MODEL_TWO_SIDE:
		return;
	default:
#ifdef DEBUG
		printf("glLightModelfv: Invalid enumeration.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glLightModeli(GLenum pname, GLint param) {
#ifdef GL_TRACE_API
	printf("glLightModeli(%s, %d)\n", GLConstantString(pname), param);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLightModeli: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Set appropriate param
	switch (pname) {
	case GL_LIGHT_MODEL_LOCAL_VIEWER:
	case GL_LIGHT_MODEL_TWO_SIDE:
		return;
	case GL_LIGHT_MODEL_AMBIENT:
	default:
#ifdef DEBUG
		printf("glLightModeli: Invalid enumeration.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glLightModeliv(GLenum pname, const GLint *params) {
#ifdef GL_TRACE_API
	printf("glLightModeliv(%s, %p)\n", GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLightModeliv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Set appropriate param
	switch (pname) {
	case GL_LIGHT_MODEL_AMBIENT:
		gc->lightModelAmbient.r = FixMul((1 << GLCOLORSHIFT), params[0], 31);
		gc->lightModelAmbient.g = FixMul((1 << GLCOLORSHIFT), params[1], 31);
		gc->lightModelAmbient.b = FixMul((1 << GLCOLORSHIFT), params[2], 31);
		gc->lightModelAmbient.a = FixMul((1 << GLCOLORSHIFT), params[3], 31);
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		return;
	case GL_LIGHT_MODEL_LOCAL_VIEWER:
	case GL_LIGHT_MODEL_TWO_SIDE:
		return;
	default:
#ifdef DEBUG
		printf("glLightModeliv: Invalid enumeration.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glLightf(GLenum light, GLenum pname, GLfloat param) {
int lnum;
#ifdef GL_TRACE_API
	printf("glLightf(%s, %s, %f)\n", GLConstantString(light), GLConstantString(pname), param);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLightf: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Get appropriate light index
	lnum = light - GL_LIGHT0;
#ifdef DEBUG
	if ((lnum < 0) || (lnum >= MAX_LIGHTS)) {
		printf("glLightf: Invalid light.\n");
		gc->errorCode = GL_INVALID_ENUM;
	}
#endif

	// Affect appropriate parameter
	switch (pname) {
	case GL_SPOT_EXPONENT:
		gc->light[lnum].exponent = param;
		break;

	case GL_SPOT_CUTOFF:
		gc->light[lnum].cutoff = param;
		break;

	case GL_CONSTANT_ATTENUATION:
		gc->light[lnum].kc = param;
		break;

	case GL_LINEAR_ATTENUATION:
		gc->light[lnum].kl = param;
		break;

	case GL_QUADRATIC_ATTENUATION:
		gc->light[lnum].kq = param;
		break;

#ifdef DEBUG
	default:
		printf("glLightf: Invalid lighting parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
#endif
	}
}

void glLightfv(GLenum light, GLenum pname, const GLfloat *params) {
int lnum;
float x, y, z, w;
#ifdef GL_TRACE_API
	printf("glLightfv(%s, %s, %p)\n", GLConstantString(light), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLightfv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Get appropriate light index
	lnum = light - GL_LIGHT0;
#ifdef DEBUG
	if ((lnum < 0) || (lnum >= MAX_LIGHTS)) {
		printf("glLightfv: Invalid light.\n");
		gc->errorCode = GL_INVALID_ENUM;
	}
#endif

	// Affect appropriate parameter
	switch (pname) {
	case GL_AMBIENT:
		gc->light[lnum].c_amb.r = GLCOLORMAX * params[0];
		gc->light[lnum].c_amb.g = GLCOLORMAX * params[1];
		gc->light[lnum].c_amb.b = GLCOLORMAX * params[2];
		gc->light[lnum].c_amb.a = GLCOLORMAX * params[3];
		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_DIFFUSE:
		gc->light[lnum].c_dif.r = GLCOLORMAX * params[0];
		gc->light[lnum].c_dif.g = GLCOLORMAX * params[1];
		gc->light[lnum].c_dif.b = GLCOLORMAX * params[2];
		gc->light[lnum].c_dif.a = GLCOLORMAX * params[3];
		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_AMBIENT_AND_DIFFUSE:
		gc->light[lnum].c_amb.r = GLCOLORMAX * params[0];
		gc->light[lnum].c_amb.g = GLCOLORMAX * params[1];
		gc->light[lnum].c_amb.b = GLCOLORMAX * params[2];
		gc->light[lnum].c_amb.a = GLCOLORMAX * params[3];
		gc->light[lnum].c_dif = gc->light[lnum].c_amb;
		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_SPECULAR:
		gc->light[lnum].c_spec.r = GLCOLORMAX * params[0];
		gc->light[lnum].c_spec.g = GLCOLORMAX * params[1];
		gc->light[lnum].c_spec.b = GLCOLORMAX * params[2];
		gc->light[lnum].c_spec.a = GLCOLORMAX * params[3];
		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_POSITION:
		x = (gc->modelviewMatrix.m11 * params[0] +
			gc->modelviewMatrix.m12 * params[1] +
			gc->modelviewMatrix.m13 * params[2] +
			gc->modelviewMatrix.m14 * params[3]) / (1 << GLTRIGSHIFT);
		y = (gc->modelviewMatrix.m21 * params[0] +
			gc->modelviewMatrix.m22 * params[1] +
			gc->modelviewMatrix.m23 * params[2] +
			gc->modelviewMatrix.m24 * params[3]) / (1 << GLTRIGSHIFT);
		z = (gc->modelviewMatrix.m31 * params[0] +
			gc->modelviewMatrix.m32 * params[1] +
			gc->modelviewMatrix.m33 * params[2] +
			gc->modelviewMatrix.m34 * params[3]) / (1 << GLTRIGSHIFT);
		w = (gc->modelviewMatrix.m41 * params[0] +
			gc->modelviewMatrix.m42 * params[1] +
			gc->modelviewMatrix.m43 * params[2] +
			gc->modelviewMatrix.m44 * params[3]) / (1 << GLTRIGSHIFT);

		gc->light[lnum].pos.x = ((1 << GLXYZWMODELSHIFT) - 1) * x;
		gc->light[lnum].pos.y = ((1 << GLXYZWMODELSHIFT) - 1) * y;
		gc->light[lnum].pos.z = ((1 << GLXYZWMODELSHIFT) - 1) * z;
		gc->light[lnum].pos.w = ((1 << GLXYZWMODELSHIFT) - 1) * w;

		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
	
		break;

	case GL_SPOT_DIRECTION:
		gc->light[lnum].dir.x = params[0];
		gc->light[lnum].dir.y = params[1];
		gc->light[lnum].dir.z = params[2];
		gc->light[lnum].dir.w = 0.0f;
		break;

	case GL_SPOT_EXPONENT:
		gc->light[lnum].exponent = params[0];
		break;

	case GL_SPOT_CUTOFF:
		gc->light[lnum].cutoff = params[0];
		break;

	case GL_CONSTANT_ATTENUATION:
		gc->light[lnum].kc = params[0];
		break;

	case GL_LINEAR_ATTENUATION:
		gc->light[lnum].kl = params[0];
		break;

	case GL_QUADRATIC_ATTENUATION:
		gc->light[lnum].kq = params[0];
		break;

#ifdef DEBUG
	default:
		printf("glLightfv: Invalid lighting parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
#endif
	}
}

void glLighti(GLenum light, GLenum pname, GLint param) {
int lnum;
#ifdef GL_TRACE_API
	printf("glLighti(%s, %s, %d)\n", GLConstantString(light), GLConstantString(pname), param);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLighti: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Get appropriate light index
	lnum = light - GL_LIGHT0;
#ifdef DEBUG
	if ((lnum < 0) || (lnum >= MAX_LIGHTS)) {
		printf("glLighti: Invalid light.\n");
		gc->errorCode = GL_INVALID_ENUM;
	}
#endif

	// Affect appropriate parameter
	switch (pname) {
	case GL_SPOT_EXPONENT:
		gc->light[lnum].exponent = param;
		break;

	case GL_SPOT_CUTOFF:
		gc->light[lnum].cutoff = param;
		break;

	case GL_CONSTANT_ATTENUATION:
		gc->light[lnum].kc = param;
		break;

	case GL_LINEAR_ATTENUATION:
		gc->light[lnum].kl = param;
		break;

	case GL_QUADRATIC_ATTENUATION:
		gc->light[lnum].kq = param;
		break;

#ifdef DEBUG
	default:
		printf("glLighti: Invalid lighting parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
#endif
	}
}

void glLightiv(GLenum light, GLenum pname, const GLint *params) {
int lnum;
float x, y, z, w;
#ifdef GL_TRACE_API
	printf("glLightiv(%s, %s, %p)\n", GLConstantString(light), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glLightiv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Get appropriate light index
	lnum = light - GL_LIGHT0;
#ifdef DEBUG
	if ((lnum < 0) || (lnum >= MAX_LIGHTS)) {
		printf("glLightiv: Invalid light.\n");
		gc->errorCode = GL_INVALID_ENUM;
	}
#endif

	// Affect appropriate parameter
	switch (pname) {
	case GL_AMBIENT:
		gc->light[lnum].c_amb.r = FixMul(1 << GLCOLORSHIFT, params[0], 31);
		gc->light[lnum].c_amb.g = FixMul(1 << GLCOLORSHIFT, params[1], 31);
		gc->light[lnum].c_amb.b = FixMul(1 << GLCOLORSHIFT, params[2], 31);
		gc->light[lnum].c_amb.a = FixMul(1 << GLCOLORSHIFT, params[3], 31);
		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_DIFFUSE:
		gc->light[lnum].c_dif.r = FixMul(1 << GLCOLORSHIFT, params[0], 31);
		gc->light[lnum].c_dif.g = FixMul(1 << GLCOLORSHIFT, params[1], 31);
		gc->light[lnum].c_dif.b = FixMul(1 << GLCOLORSHIFT, params[2], 31);
		gc->light[lnum].c_dif.a = FixMul(1 << GLCOLORSHIFT, params[3], 31);
		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_AMBIENT_AND_DIFFUSE:
		gc->light[lnum].c_amb.r = FixMul(1 << GLCOLORSHIFT, params[0], 31);
		gc->light[lnum].c_amb.g = FixMul(1 << GLCOLORSHIFT, params[1], 31);
		gc->light[lnum].c_amb.b = FixMul(1 << GLCOLORSHIFT, params[2], 31);
		gc->light[lnum].c_amb.a = FixMul(1 << GLCOLORSHIFT, params[3], 31);
		gc->light[lnum].c_dif = gc->light[lnum].c_amb;
		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_SPECULAR:
		gc->light[lnum].c_spec.r = FixMul(1 << GLCOLORSHIFT, params[0], 31);
		gc->light[lnum].c_spec.g = FixMul(1 << GLCOLORSHIFT, params[1], 31);
		gc->light[lnum].c_spec.b = FixMul(1 << GLCOLORSHIFT, params[2], 31);
		gc->light[lnum].c_spec.a = FixMul(1 << GLCOLORSHIFT, params[3], 31);
		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_POSITION:
		x = FixMul(gc->modelviewMatrix.m11, params[0], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m12, params[1], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m13, params[2], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m14, params[3], GLTRIGSHIFT);
		y = FixMul(gc->modelviewMatrix.m21, params[0], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m22, params[1], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m23, params[2], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m24, params[3], GLTRIGSHIFT);
		z = FixMul(gc->modelviewMatrix.m31, params[0], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m32, params[1], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m33, params[2], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m34, params[3], GLTRIGSHIFT);
		w = FixMul(gc->modelviewMatrix.m41, params[0], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m42, params[1], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m43, params[2], GLTRIGSHIFT) +
			FixMul(gc->modelviewMatrix.m44, params[3], GLTRIGSHIFT);

		gc->light[lnum].pos.x = x;
		gc->light[lnum].pos.y = y;
		gc->light[lnum].pos.z = z;
		gc->light[lnum].pos.w = w;

		if (gc->lightingEnable && gc->light[lnum].enable) gc->validationFlags |= VAL_LIGHTING;

		break;

	case GL_SPOT_DIRECTION:
		gc->light[lnum].dir.x = params[0];
		gc->light[lnum].dir.y = params[1];
		gc->light[lnum].dir.z = params[2];
		gc->light[lnum].dir.w = 0.0f;
		break;

	case GL_SPOT_EXPONENT:
		gc->light[lnum].exponent = params[0];
		break;

	case GL_SPOT_CUTOFF:
		gc->light[lnum].cutoff = params[0];
		break;

	case GL_CONSTANT_ATTENUATION:
		gc->light[lnum].kc = params[0];
		break;

	case GL_LINEAR_ATTENUATION:
		gc->light[lnum].kl = params[0];
		break;

	case GL_QUADRATIC_ATTENUATION:
		gc->light[lnum].kq = params[0];
		break;

#ifdef DEBUG
	default:
		printf("glLightiv: Invalid lighting parameter.\n");
		gc->errorCode = GL_INVALID_ENUM;
		return;
#endif
	}
}

void glMaterialf(GLenum face, GLenum pname, GLfloat param) {
GLMaterial *fp, *bp;		// Front and back material pointers;

#ifdef GL_TRACE_API
	printf("glMaterialf(%s, %s, %f)\n", GLConstantString(face), GLConstantString(pname), param);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glMaterialf: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine material pointers
	switch (face) {
	case GL_FRONT:
		fp = bp = &(gc->frontMaterial);
		break;

	case GL_BACK:
		fp = bp = &(gc->backMaterial);
		break;

	case GL_FRONT_AND_BACK:
		fp = &(gc->frontMaterial);
		bp = &(gc->backMaterial);
		break;

	default:
#ifdef DEBUG
		printf("glMaterialf: Invalid face choice.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	// Determine if material property is valid or not
	switch (pname) {
	case GL_SHININESS:
		if (param != fp->shininess) {
			fp->shininess = bp->shininess = param;
			gc->validationFlags |= VAL_MATERIAL_SHININESS;
		}
		break;

	default:
#ifdef DEBUG
	printf("glMaterialf: Invalid property.\n");
	gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glMaterialfv(GLenum face, GLenum pname, const GLfloat *params) {
GLMaterial *fp, *bp;		// Front and back material pointers;
#ifdef GL_TRACE_API
	printf("glMaterialfv(%s, %s, %p)\n", GLConstantString(face), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glMaterialfv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine material pointers
	switch (face) {
	case GL_FRONT:
		fp = bp = &(gc->frontMaterial);
		break;

	case GL_BACK:
		fp = bp = &(gc->backMaterial);
		break;

	case GL_FRONT_AND_BACK:
		fp = &(gc->frontMaterial);
		bp = &(gc->backMaterial);
		break;

	default:
#ifdef DEBUG
		printf("glMaterialfv: Invalid face choice.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	// Determine if material property is valid or not
	switch (pname) {
	case GL_AMBIENT:
		fp->c_amb.r = bp->c_amb.r = params[0] * GLCOLORMAX;
		fp->c_amb.g = bp->c_amb.g = params[1] * GLCOLORMAX;
		fp->c_amb.b = bp->c_amb.b = params[2] * GLCOLORMAX;
		fp->c_amb.a = bp->c_amb.a = params[3] * GLCOLORMAX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_DIFFUSE:
		fp->c_dif.r = bp->c_dif.r = params[0] * GLCOLORMAX;
		fp->c_dif.g = bp->c_dif.g = params[1] * GLCOLORMAX;
		fp->c_dif.b = bp->c_dif.b = params[2] * GLCOLORMAX;
		fp->c_dif.a = bp->c_dif.a = params[3] * GLCOLORMAX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_AMBIENT_AND_DIFFUSE:
		fp->c_amb.r = bp->c_amb.r = fp->c_dif.r = bp->c_dif.r = params[0] * GLCOLORMAX;
		fp->c_amb.g = bp->c_amb.g = fp->c_dif.g = bp->c_dif.g = params[1] * GLCOLORMAX;
		fp->c_amb.b = bp->c_amb.b = fp->c_dif.b = bp->c_dif.b = params[2] * GLCOLORMAX;
		fp->c_amb.a = bp->c_amb.a = fp->c_dif.a = bp->c_dif.a = params[3] * GLCOLORMAX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_SPECULAR:
		fp->c_spec.r = bp->c_spec.r = params[0] * GLCOLORMAX;
		fp->c_spec.g = bp->c_spec.g = params[1] * GLCOLORMAX;
		fp->c_spec.b = bp->c_spec.b = params[2] * GLCOLORMAX;
		fp->c_spec.a = bp->c_spec.a = params[3] * GLCOLORMAX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_EMISSION:
		fp->c_emis.r = bp->c_emis.r = params[0] * GLCOLORMAX;
		fp->c_emis.g = bp->c_emis.g = params[1] * GLCOLORMAX;
		fp->c_emis.b = bp->c_emis.b = params[2] * GLCOLORMAX;
		fp->c_emis.a = bp->c_emis.a = params[3] * GLCOLORMAX;
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_SHININESS:
		if (params[0] != fp->shininess) {
			fp->shininess = bp->shininess = params[0];
			gc->validationFlags |= VAL_MATERIAL_SHININESS;
		}
		break;

	default:
#ifdef DEBUG
	printf("glMaterialfv: Invalid property.\n");
	gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glMateriali(GLenum face, GLenum pname, GLint param) {
GLMaterial *fp, *bp;		// Front and back material pointers;
#ifdef GL_TRACE_API
	printf("glMateriali(%s, %s, %d)\n", GLConstantString(face), GLConstantString(pname), param);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glMateriali: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine material pointers
	switch (face) {
	case GL_FRONT:
		fp = bp = &(gc->frontMaterial);
		break;

	case GL_BACK:
		fp = bp = &(gc->backMaterial);
		break;

	case GL_FRONT_AND_BACK:
		fp = &(gc->frontMaterial);
		bp = &(gc->backMaterial);
		break;

	default:
#ifdef DEBUG
		printf("glMateriali: Invalid face choice.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	// Determine if material property is valid or not
	switch (pname) {
	case GL_SHININESS:
		if (param != fp->shininess) {
			fp->shininess = bp->shininess = param;
			gc->validationFlags |= VAL_MATERIAL_SHININESS;
		}
		break;

	default:
#ifdef DEBUG
	printf("glMateriali: Invalid property.\n");
	gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}

void glMaterialiv(GLenum face, GLenum pname, const GLint *params) {
GLMaterial *fp, *bp;		// Front and back material pointers;
#ifdef GL_TRACE_API
	printf("glMaterialiv(%s, %s, %p)\n", GLConstantString(face), GLConstantString(pname), params);
#endif

#ifdef DEBUG
	// Check if within begin/end block
	if (gc->beginEndFlag) {
		printf("glMaterialiv: cannot execute within begin/end block.\n");
		gc->errorCode = GL_INVALID_OPERATION;
		return;
	}
#endif

	// Determine material pointers
	switch (face) {
	case GL_FRONT:
		fp = bp = &(gc->frontMaterial);
		break;

	case GL_BACK:
		fp = bp = &(gc->backMaterial);
		break;

	case GL_FRONT_AND_BACK:
		fp = &(gc->frontMaterial);
		bp = &(gc->backMaterial);
		break;

	default:
#ifdef DEBUG
		printf("glMaterialiv: Invalid face choice.\n");
		gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}

	// Determine if material property is valid or not
	switch (pname) {
	case GL_AMBIENT:
		fp->c_amb.r = bp->c_amb.r = FixMul(params[0], (1 << GLCOLORSHIFT), 31);
		fp->c_amb.g = bp->c_amb.g = FixMul(params[1], (1 << GLCOLORSHIFT), 31);
		fp->c_amb.b = bp->c_amb.b = FixMul(params[2], (1 << GLCOLORSHIFT), 31);
		fp->c_amb.a = bp->c_amb.a = FixMul(params[3], (1 << GLCOLORSHIFT), 31);
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_DIFFUSE:
		fp->c_dif.r = bp->c_dif.r = FixMul(params[0], (1 << GLCOLORSHIFT), 31);
		fp->c_dif.g = bp->c_dif.g = FixMul(params[1], (1 << GLCOLORSHIFT), 31);
		fp->c_dif.b = bp->c_dif.b = FixMul(params[2], (1 << GLCOLORSHIFT), 31);
		fp->c_dif.a = bp->c_dif.a = FixMul(params[3], (1 << GLCOLORSHIFT), 31);
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_AMBIENT_AND_DIFFUSE:
		fp->c_amb.r = bp->c_amb.r = fp->c_dif.r = bp->c_dif.r = FixMul(params[0], (1 << GLCOLORSHIFT), 31);
		fp->c_amb.g = bp->c_amb.g = fp->c_dif.g = bp->c_dif.g = FixMul(params[1], (1 << GLCOLORSHIFT), 31);
		fp->c_amb.b = bp->c_amb.b = fp->c_dif.b = bp->c_dif.b = FixMul(params[2], (1 << GLCOLORSHIFT), 31);
		fp->c_amb.a = bp->c_amb.a = fp->c_dif.a = bp->c_dif.a = FixMul(params[3], (1 << GLCOLORSHIFT), 31);
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_SPECULAR:
		fp->c_spec.r = bp->c_spec.r = FixMul(params[0], (1 << GLCOLORSHIFT), 31);
		fp->c_spec.g = bp->c_spec.g = FixMul(params[1], (1 << GLCOLORSHIFT), 31);
		fp->c_spec.b = bp->c_spec.b = FixMul(params[2], (1 << GLCOLORSHIFT), 31);
		fp->c_spec.a = bp->c_spec.a = FixMul(params[3], (1 << GLCOLORSHIFT), 31);
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_EMISSION:
		fp->c_emis.r = bp->c_emis.r = FixMul(params[0], (1 << GLCOLORSHIFT), 31);
		fp->c_emis.g = bp->c_emis.g = FixMul(params[1], (1 << GLCOLORSHIFT), 31);
		fp->c_emis.b = bp->c_emis.b = FixMul(params[2], (1 << GLCOLORSHIFT), 31);
		fp->c_emis.a = bp->c_emis.a = FixMul(params[3], (1 << GLCOLORSHIFT), 31);
		if (gc->lightingEnable) gc->validationFlags |= VAL_LIGHTING;
		break;

	case GL_SHININESS:
		if (params[0] != fp->shininess) {
			fp->shininess = bp->shininess = params[0];
			gc->validationFlags |= VAL_MATERIAL_SHININESS;
		}
		break;

	default:
#ifdef DEBUG
	printf("glMaterialiv: Invalid property.\n");
	gc->errorCode = GL_INVALID_ENUM;
#endif
		return;
	}
}
