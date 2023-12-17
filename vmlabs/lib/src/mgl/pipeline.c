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
#include "context.h"
#include "globals.h"
#include "glutils.h"
#include "debug.h"
#include <nuon/bios.h>
#include <nuon/mutil.h>
#include <stdio.h>
#include <stdarg.h>
#include <math.h>

// maps vertex format into vertex size in scalars
const int vertexSize[VERTEX_FORMAT_COUNT] = {
	8,		// VERTEX_XYZWUVN		x, y, z, w, u, v are scalars; nx, ny, nz are shorts, last short is wasted
	4,		// VERTEX_XYZC			x, y, z are scalars; G, R, B, A are packed together into a scalar
	4,		// VERTEX_XYZN			x, y, z are scalars; nx, ny, nz are packed together into a scalar
};

// maps vertex format into normal offset in scalars; see vertexSize comments for format info
static const int normalOffset[VERTEX_FORMAT_COUNT] = {
	6,		// VERTEX_XYZWUVN
	0,		// VERTEX_XYZC
	3,		// VERTEX_XYZN
};

// v input and output with GLNORMALSHIFT frac bits
static void Normalize(long v[3])
{
	long i;
	const long b = 16; // seems like a good choice given that we don't know how big |v| is

	i = FixMul(v[0], v[0], GLNORMALSHIFT) + FixMul(v[1], v[1], GLNORMALSHIFT) + FixMul(v[2], v[2], GLNORMALSHIFT);
	i = FixRSqrt(i, GLNORMALSHIFT, b);

	v[0] = FixMul(v[0], i, b);
	v[1] = FixMul(v[1], i, b);
	v[2] = FixMul(v[2], i, b);
}

static void ValidateGCDMA(void)
{
	mmlDisplayPixmap *pp;

	// maps depthFunction-GL_NEVER into hardware depth test flags
	// GL_NEVER, GL_LESS, ..., GL_ALWAYS are contiguous; see gl.h
	static const unsigned long depthTestFlags[8] = {
		0,		// GL_NEVER				unsupported in hardware
		3 << 1,	// GL_LESS
		5 << 1,	// GL_EQUAL
		1 << 1,	// GL_LEQUAL
		6 << 1,	// GL_GREATER
		2 << 1,	// GL_NOTEQUAL
		4 << 1,	// GL_GEQUAL
		0 << 1,	// GL_ALWAYS
	};

	pp = gc->screenBuffer[gc->renderBuffer];
	gc->dmaData[0] = pp->dmaFlags;

	if (gc->depthTestEnable) {
		gc->dmaData[0] |= depthTestFlags[gc->depthFunction-GL_NEVER];
	} else {
//CGRIMM broken		gc->dmaData[0] |= 7 << 1;
	}

	gc->dmaData[1] = (unsigned long)(pp->memP);
}

static void ValidateGCLighting(void)
{
	GLLight *light;
	GLMaterial *mat;
	Color c, d, s;
	int i, j, numEnabled;
	long l[3], v[3], h[3];

	// Handle directional lights

	numEnabled = 0;
	j = 0;
	mat = &(gc->frontMaterial);
	c = gc->lightModelAmbient;

	for (i = 0; i < MAX_LIGHTS; i++) {

		light = &(gc->light[i]);

		if (light->enable && (light->pos.w == 0)) {

			// Increment enabled light count

			numEnabled++;

			// Store modelspace light direction and specular vector

			DEBUG_ASSERT(GLNORMALSHIFT >= GLXYZWMODELSHIFT);
			v[0] = light->pos.x << (GLNORMALSHIFT - GLXYZWMODELSHIFT);
			v[1] = light->pos.y << (GLNORMALSHIFT - GLXYZWMODELSHIFT);
			v[2] = light->pos.z << (GLNORMALSHIFT - GLXYZWMODELSHIFT);

			Normalize(v); // could do this in glLight* when light->pos.w == 0

			l[0] =	FixMul(gc->modelviewMatrix.m11, v[0], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m21, v[1], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m31, v[2], GLTRIGSHIFT);
			l[1] =	FixMul(gc->modelviewMatrix.m12, v[0], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m22, v[1], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m32, v[2], GLTRIGSHIFT);
			l[2] =	FixMul(gc->modelviewMatrix.m13, v[0], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m23, v[1], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m33, v[2], GLTRIGSHIFT);

			Normalize(l);

			v[2] += 1 << GLNORMALSHIFT;

			h[0] =	FixMul(gc->modelviewMatrix.m11, v[0], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m21, v[1], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m31, v[2], GLTRIGSHIFT);
			h[1] =	FixMul(gc->modelviewMatrix.m12, v[0], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m22, v[1], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m32, v[2], GLTRIGSHIFT);
			h[2] =	FixMul(gc->modelviewMatrix.m13, v[0], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m23, v[1], GLTRIGSHIFT) +
					FixMul(gc->modelviewMatrix.m33, v[2], GLTRIGSHIFT);

			Normalize(h);

			gc->lightData[j++] = (l[0] << 16) | (l[1] & 0xffff);
			gc->lightData[j++] = (l[2] << 16) | (h[0] & 0xffff);
			gc->lightData[j++] = (h[1] << 16) | (h[2] & 0xffff);

			// Store diffuse and specular colors

			d.r = FixMul(light->c_dif.r,  mat->c_dif.r,  GLCOLORSHIFT);
			d.g = FixMul(light->c_dif.g,  mat->c_dif.g,  GLCOLORSHIFT);
			d.b = FixMul(light->c_dif.b,  mat->c_dif.b,  GLCOLORSHIFT);

			s.r = FixMul(light->c_spec.r, mat->c_spec.r, GLCOLORSHIFT);
			s.g = FixMul(light->c_spec.g, mat->c_spec.g, GLCOLORSHIFT);
			s.b = FixMul(light->c_spec.b, mat->c_spec.b, GLCOLORSHIFT);

			if (gc->lighter == LightI) {
				gc->lightData[j++] = (COLOR_I16(d.r, d.g, d.b) << 16) | COLOR_I16(s.r, s.g, s.b);
			} else {
				gc->lightData[j++] = (COLOR_GRB655(d.r, d.g, d.b) << 16) | COLOR_GRB655(s.r, s.g, s.b);
			}

			// Update constant color

			c.r += light->c_amb.r;
			c.g += light->c_amb.g;
			c.b += light->c_amb.b;
		}
	}

	j = LIGHT_DATA_SIZE - 3;

	// Store normal pointer and stride

	gc->lightData[j++] = (long)MPEVertexCache + (normalOffset[gc->vertexFormat] << 2);
	gc->lightData[j++] = vertexSize[gc->vertexFormat] << 2;

	// Store constant color and light count

	c.r = mat->c_emis.r + FixMul(c.r, mat->c_amb.r, GLCOLORSHIFT);
	c.g = mat->c_emis.g + FixMul(c.g, mat->c_amb.g, GLCOLORSHIFT);
	c.b = mat->c_emis.b + FixMul(c.b, mat->c_amb.b, GLCOLORSHIFT);

	if (c.r > GLCOLORMAX) c.r = GLCOLORMAX;
	if (c.g > GLCOLORMAX) c.g = GLCOLORMAX;
	if (c.b > GLCOLORMAX) c.b = GLCOLORMAX;

	if (gc->lighter == LightI) {
		gc->lightData[j++] = (COLOR_I16(c.r, c.g, c.b) << 16) | numEnabled;
	} else {
		gc->lightData[j++] = (COLOR_GRB655(c.r, c.g, c.b) << 16) | numEnabled;
	}
}

static void ValidateGCSpecularLUT(void)
{
	// use doubles because powf seems to return large negative numbers on underflow
	// also, note the definition of SPECULAR_LUT_ENTRIES in mpedefs.h

	double dx, x, shininess, y;
	int i;
	short *p;

	const short maxSpec = 0x4000;

	dx = 1.0 / (double)(SPECULAR_LUT_ENTRIES - 1);
	shininess = gc->frontMaterial.shininess;
	p = (short *)(gc->specularLUTData);

	*p++ = 0x0000;

	for (i = 1; i < SPECULAR_LUT_ENTRIES - 2; i++) {
		x = (i + 1) * dx;
		y = pow(x, shininess);
		*p++ = (short)(maxSpec * y);
	}

	*p++ = maxSpec;
	*p = maxSpec;
}

static void ValidateGCTotalMatrix(void)
{
	gc->totalMatrixData[ 0] =	FixMul(gc->projectionMatrix.m11, gc->modelviewMatrix.m11, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m12, gc->modelviewMatrix.m21, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m13, gc->modelviewMatrix.m31, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m14, gc->modelviewMatrix.m41, GLTRIGSHIFT);
	gc->totalMatrixData[ 1] =	FixMul(gc->projectionMatrix.m11, gc->modelviewMatrix.m12, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m12, gc->modelviewMatrix.m22, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m13, gc->modelviewMatrix.m32, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m14, gc->modelviewMatrix.m42, GLTRIGSHIFT);
	gc->totalMatrixData[ 2] =	FixMul(gc->projectionMatrix.m11, gc->modelviewMatrix.m13, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m12, gc->modelviewMatrix.m23, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m13, gc->modelviewMatrix.m33, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m14, gc->modelviewMatrix.m43, GLTRIGSHIFT);
	gc->totalMatrixData[ 3] =	FixMul(gc->projectionMatrix.m11, gc->modelviewMatrix.m14, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m12, gc->modelviewMatrix.m24, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m13, gc->modelviewMatrix.m34, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m14, gc->modelviewMatrix.m44, GLTRIGSHIFT);
	gc->totalMatrixData[ 4] =	FixMul(gc->projectionMatrix.m21, gc->modelviewMatrix.m11, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m22, gc->modelviewMatrix.m21, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m23, gc->modelviewMatrix.m31, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m24, gc->modelviewMatrix.m41, GLTRIGSHIFT);
	gc->totalMatrixData[ 5] =	FixMul(gc->projectionMatrix.m21, gc->modelviewMatrix.m12, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m22, gc->modelviewMatrix.m22, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m23, gc->modelviewMatrix.m32, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m24, gc->modelviewMatrix.m42, GLTRIGSHIFT);
	gc->totalMatrixData[ 6] =	FixMul(gc->projectionMatrix.m21, gc->modelviewMatrix.m13, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m22, gc->modelviewMatrix.m23, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m23, gc->modelviewMatrix.m33, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m24, gc->modelviewMatrix.m43, GLTRIGSHIFT);
	gc->totalMatrixData[ 7] =	FixMul(gc->projectionMatrix.m21, gc->modelviewMatrix.m14, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m22, gc->modelviewMatrix.m24, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m23, gc->modelviewMatrix.m34, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m24, gc->modelviewMatrix.m44, GLTRIGSHIFT);
	gc->totalMatrixData[ 8] =	FixMul(gc->projectionMatrix.m31, gc->modelviewMatrix.m11, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m32, gc->modelviewMatrix.m21, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m33, gc->modelviewMatrix.m31, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m34, gc->modelviewMatrix.m41, GLTRIGSHIFT);
	gc->totalMatrixData[ 9] =	FixMul(gc->projectionMatrix.m31, gc->modelviewMatrix.m12, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m32, gc->modelviewMatrix.m22, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m33, gc->modelviewMatrix.m32, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m34, gc->modelviewMatrix.m42, GLTRIGSHIFT);
	gc->totalMatrixData[10] =	FixMul(gc->projectionMatrix.m31, gc->modelviewMatrix.m13, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m32, gc->modelviewMatrix.m23, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m33, gc->modelviewMatrix.m33, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m34, gc->modelviewMatrix.m43, GLTRIGSHIFT);
	gc->totalMatrixData[11] =	FixMul(gc->projectionMatrix.m31, gc->modelviewMatrix.m14, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m32, gc->modelviewMatrix.m24, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m33, gc->modelviewMatrix.m34, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m34, gc->modelviewMatrix.m44, GLTRIGSHIFT);
	gc->totalMatrixData[12] =	FixMul(gc->projectionMatrix.m41, gc->modelviewMatrix.m11, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m42, gc->modelviewMatrix.m21, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m43, gc->modelviewMatrix.m31, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m44, gc->modelviewMatrix.m41, GLTRIGSHIFT);
	gc->totalMatrixData[13] =	FixMul(gc->projectionMatrix.m41, gc->modelviewMatrix.m12, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m42, gc->modelviewMatrix.m22, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m43, gc->modelviewMatrix.m32, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m44, gc->modelviewMatrix.m42, GLTRIGSHIFT);
	gc->totalMatrixData[14] =	FixMul(gc->projectionMatrix.m41, gc->modelviewMatrix.m13, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m42, gc->modelviewMatrix.m23, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m43, gc->modelviewMatrix.m33, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m44, gc->modelviewMatrix.m43, GLTRIGSHIFT);
	gc->totalMatrixData[15] =	FixMul(gc->projectionMatrix.m41, gc->modelviewMatrix.m14, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m42, gc->modelviewMatrix.m24, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m43, gc->modelviewMatrix.m34, GLTRIGSHIFT) +
								FixMul(gc->projectionMatrix.m44, gc->modelviewMatrix.m44, GLTRIGSHIFT);
}

static void ValidateGCViewport(void)
{
	// Note that z range is scaled down by a factor of 1/128 to account for fixed point roundoff error in
	// clipping code (SML 10/9/98).

	gc->viewportData[0] =
		((unsigned long)(1 << GLZDEPTHSHIFT) - 1) * (127.0f * (gc->zFar - gc->zNear) / (2.0 * 128.0f));
	gc->viewportData[1] = ((unsigned long)(1 << GLZDEPTHSHIFT) - 1) * ((gc->zFar + gc->zNear) / 2.0);
	gc->viewportData[2] = ((gc->viewportWidth / 2) << 16) | (gc->viewportX + gc->viewportWidth / 2);
	gc->viewportData[3] = ((-gc->viewportHeight / 2) << 16) |
		((gc->screenBuffer[0]->high - gc->viewportY - 1) - gc->viewportHeight / 2);
}

static inline int Blend(void)
{
	return	gc->blendEnable &&
			(gc->blendSrcFactor == GL_SRC_ALPHA) &&
			(gc->blendDstFactor == GL_ONE_MINUS_SRC_ALPHA) &&
			gc->depthTestEnable &&
			(gc->depthFunction == GL_LESS);
}

static void ValidateGCPipeline(void)
{
	GLTextureObject	*tp;

	switch (gc->primitive) {

	case GL_TRIANGLES:

		if (gc->texture2DEnable || gc->texture1DEnable) {

			gc->vertexFormat = VERTEX_XYZWUVN;
			gc->loader = LoadV8Triangles;
			gc->loader_size = (long)LoadV8Triangles_size;

			if (gc->lightingEnable && (gc->textureEnvMode == GL_MODULATE)) {

				if (gc->lighter != LightI) {
					gc->validationFlags |= VAL_LIGHTING;
				}

				gc->lighter = LightI;
				gc->lighter_size = (long)LightI_size;

			} else {

				gc->lighter = NULL;
				gc->lighter_size = 0;
			}

			gc->transformer = TransformXYZW8;
			gc->transformer_size = (long)TransformXYZW8_size;
			gc->trivia = TrivialV8Triangle;
			gc->trivia_size = (long)TrivialV8Triangle_size;

			tp = gc->texture2DEnable ? gc->current2DObject : gc->current1DObject;

			switch (tp->minFilter) {

			case GL_NEAREST:
			case GL_NEAREST_MIPMAP_NEAREST:
			case GL_NEAREST_MIPMAP_LINEAR:

				switch (gc->textureEnvMode) {

				case GL_MODULATE:

					switch (tp->texture[0]->pixelType) {

					case e655:
					case e888Alpha:

						if (gc->fogEnable) {
							gc->clipper = ClipXYZWUVIFTriangle;
							gc->clipper_size = (long)ClipXYZWUVIFTriangle_size;
						} else {
							gc->clipper = ClipXYZWUVITriangle;
							gc->clipper_size = (long)ClipXYZWUVITriangle_size;
						}

						gc->rasterizer = RasterSTI;
						gc->rasterizer_size = (long)RasterSTI_size;

						break;

					case eClut4:
					case eClut8:

						if (gc->fogEnable) {
							gc->clipper = ClipXYZWUVIFTriangle;
							gc->clipper_size = (long)ClipXYZWUVIFTriangle_size;
						} else {
							gc->clipper = ClipXYZWUVITriangle;
							gc->clipper_size = (long)ClipXYZWUVITriangle_size;
						}

						if (gc->chromakeyEnable) {
							gc->rasterizer = RasterSTPKI;
							gc->rasterizer_size = (long)RasterSTPKI_size;
						} else {
							gc->rasterizer = RasterSTPI;
							gc->rasterizer_size = (long)RasterSTPI_size;
						}

						break;

					default:
						// shouldn't happen
						DEBUG_ASSERT(0);
						break;
					}

					break;

				case GL_REPLACE:

					switch (tp->texture[0]->pixelType) {

					case e655:
					case e888Alpha:

						if (gc->fogEnable) {
							gc->clipper = ClipXYZWUVIFTriangle;
							gc->clipper_size = (long)ClipXYZWUVIFTriangle_size;
						} else {
							gc->clipper = ClipXYZWUVITriangle;
							gc->clipper_size = (long)ClipXYZWUVITriangle_size;
						}

						gc->rasterizer = RasterST;
						gc->rasterizer_size = (long)RasterST_size;

						break;

					case eClut4:
					case eClut8:

						if (gc->fogEnable) {
							gc->clipper = ClipXYZWUVIFTriangle;
							gc->clipper_size = (long)ClipXYZWUVIFTriangle_size;
						} else {
							gc->clipper = ClipXYZWUVITriangle;
							gc->clipper_size = (long)ClipXYZWUVITriangle_size;
						}

						if (gc->chromakeyEnable) {
							gc->rasterizer = RasterSTPK;
							gc->rasterizer_size = (long)RasterSTPK_size;
						} else {
							gc->rasterizer = RasterSTP;
							gc->rasterizer_size = (long)RasterSTP_size;
						}

						break;

					default:
						// shouldn't happen
						DEBUG_ASSERT(0);
						break;
					}

					break;

				default:
					// shouldn't happen
					DEBUG_ASSERT(0);
					break;
				}

				break;

			case GL_LINEAR:
			case GL_LINEAR_MIPMAP_NEAREST:
			case GL_LINEAR_MIPMAP_LINEAR:

				switch (gc->textureEnvMode) {
				case GL_MODULATE:

					switch (gc->current2DObject->texture[0]->pixelType) {

					case e655:
					case e888Alpha:

						if (gc->fogEnable) {
							gc->clipper = ClipXYZWUVIFTriangle;
							gc->clipper_size = (long)ClipXYZWUVIFTriangle_size;
						} else {
							gc->clipper = ClipXYZWUVITriangle;
							gc->clipper_size = (long)ClipXYZWUVITriangle_size;
						}

						gc->rasterizer = RasterSTFI;
						gc->rasterizer_size = (long)RasterSTFI_size;

						break;

					case eClut4:
					case eClut8:

						if (gc->fogEnable) {
							gc->clipper = ClipXYZWUVIFTriangle;
							gc->clipper_size = (long)ClipXYZWUVIFTriangle_size;
						} else {
							gc->clipper = ClipXYZWUVITriangle;
							gc->clipper_size = (long)ClipXYZWUVITriangle_size;
						}

						if (gc->chromakeyEnable) {
							gc->rasterizer = RasterSTFPKI;
							gc->rasterizer_size = (long)RasterSTFPKI_size;
						} else {
							gc->rasterizer = RasterSTFPI;
							gc->rasterizer_size = (long)RasterSTFPI_size;
						}

						break;

					default:
						// shouldn't happen
						DEBUG_ASSERT(0);
						break;
					}

					break;

				case GL_REPLACE:

					switch (gc->current2DObject->texture[0]->pixelType) {

					case e655:
					case e888Alpha:

						if (gc->fogEnable) {
							gc->clipper = ClipXYZWUVIFTriangle;
							gc->clipper_size = (long)ClipXYZWUVIFTriangle_size;
						} else {
							gc->clipper = ClipXYZWUVITriangle;
							gc->clipper_size = (long)ClipXYZWUVITriangle_size;
						}

						gc->rasterizer = RasterSTF;
						gc->rasterizer_size = (long)RasterSTF_size;

						break;

					case eClut4:
					case eClut8:

						if (gc->fogEnable) {
							gc->clipper = ClipXYZWUVIFTriangle;
							gc->clipper_size = (long)ClipXYZWUVIFTriangle_size;
						} else {
							gc->clipper = ClipXYZWUVITriangle;
							gc->clipper_size = (long)ClipXYZWUVITriangle_size;
						}

						if (Blend()) {
							if (gc->depthMask) {
								gc->rasterizer = RasterSTFPB2;
								gc->rasterizer_size = (long)RasterSTFPB2_size;
							} else {
								gc->rasterizer = RasterSTFPB;
								gc->rasterizer_size = (long)RasterSTFPB_size;
							}
						} else if (gc->chromakeyEnable) {
							gc->rasterizer = RasterSTFPK;
							gc->rasterizer_size = (long)RasterSTFPK_size;
						} else {
							gc->rasterizer = RasterSTFP;
							gc->rasterizer_size = (long)RasterSTFP_size;
						}

						break;

					default:
						// shouldn't happen
						DEBUG_ASSERT(0);
						break;
					}

					break;

				default:
					// shouldn't happen
					DEBUG_ASSERT(0);
					break;
				}

				break;

			default:
				// shouldn't happen
				DEBUG_ASSERT(0);
				break;
			}

		} else {

			gc->loader = LoadV4Triangles;
			gc->loader_size = (long)LoadV4Triangles_size;
			gc->transformer = TransformXYZ4;
			gc->transformer_size = (long)TransformXYZ4_size;
			gc->trivia = TrivialV4Triangle;
			gc->trivia_size = (long)TrivialV4Triangle_size;
			gc->clipper = ClipXYZWCTriangle;
			gc->clipper_size = (long)ClipXYZWCTriangle_size;

			if (gc->lightingEnable) {

				if (gc->lighter == LightI) {
					gc->validationFlags |= VAL_LIGHTING;
				}

				gc->vertexFormat = VERTEX_XYZN;
				gc->lighter = LightGRB;
				gc->lighter_size = (long)LightGRB_size;
				gc->rasterizer = RasterC;
				gc->rasterizer_size = (long)RasterC_size;

			} else {

				gc->vertexFormat = VERTEX_XYZC;
				gc->lighter = NULL;
				gc->lighter_size = 0;

				if (Blend()) {
					if (gc->depthMask) {
						gc->rasterizer = RasterCB2;
						gc->rasterizer_size = (long)RasterCB2_size;
					} else {
						gc->rasterizer = RasterCB;
						gc->rasterizer_size = (long)RasterCB_size;
					}
				} else {
					gc->rasterizer = RasterC;
					gc->rasterizer_size = (long)RasterC_size;
				}
			}
		}

		break;

	default:
		// shouldn't happen
		DEBUG_ASSERT(0);
		break;
	}
}

void ValidateGC(void)
{
	int mpeIndex;
	long syncFlag = GL_FALSE;

	// Check for pipeline change. This can affect VAL_LIGHTING.

	if (gc->validationFlags & VAL_PIPELINE) {
		ValidateGCPipeline();
	}

	// Check for DMA parameters change

	if (gc->validationFlags & VAL_RENDER_BUFFER) {
		ValidateGCDMA();
		syncFlag = GL_TRUE;
	}

	// Check for fog parameters change

	if (gc->validationFlags & VAL_FOG) {
		gc->fogData[0] = gc->fogEnd;
		gc->fogData[1] = FixDiv(0x40000000, gc->fogStart - gc->fogEnd, 10);
		syncFlag = GL_TRUE;
	}

	// Check for lighting parameters change

	if (gc->validationFlags & VAL_LIGHTING) {
		ValidateGCLighting();
		syncFlag = GL_TRUE;
	}

	if (gc->validationFlags & VAL_MATERIAL_SHININESS) {
		ValidateGCSpecularLUT();
		syncFlag = GL_TRUE;
	}

	// Check for total transformation matrix change

	if (gc->validationFlags & VAL_TOTAL_MATRIX) {
		ValidateGCTotalMatrix();
		syncFlag = GL_TRUE;
	}

	// Check for viewport change

	if (gc->validationFlags & VAL_VIEWPORT) {
		ValidateGCViewport();
		syncFlag = GL_TRUE;
	}

	// Check for texture change. For now, consider only level 0 of the current 2D texture.

	if (gc->validationFlags & VAL_TEXTURE) {

		GLTexture *tp = gc->current2DObject->texture[0];

		if (tp->dCacheSync) {
			syncFlag = GL_TRUE;
			tp->dCacheSync = GL_FALSE;
		}
	}

	// Update MPE validation flags

	for (mpeIndex = 0; mpeIndex < gc->numMPEs; mpeIndex++) {
		gc->mpe[mpeIndex].validationFlags |= gc->validationFlags;
	}

	// Clear GC validation flags

	gc->validationFlags = 0;

	// Check for cache flush

	if (syncFlag) {
		_DCacheSync();
	}
}

// This routine assumes that the designated MPE is either uninitialized or is waiting for a
// work assignment from the controlling MPE.
//
void ValidateMPE(int mpeIndex)
{
	GLMPE *mpe;
	GLTexture *tp;
	int load;
	long val, dstAddr;

	mpe = &(gc->mpe[mpeIndex]);

	// check to see if MPE requires basic initialization

	if (mpe->validationFlags & VAL_MPE_INVALIDATED) {

		// stop MPE

		_MPEStop(mpe->commBusId);

		// load manager code

		DEBUG_ASSERT((long)Manager_size <= MANAGER_OVERLAY_MAX_SIZE);
		DMAToMPE(mpeIndex, (void *)MANAGER_OVERLAY_ORIGIN, Manager_start, (long)Manager_size >> 2);

		if (mpe->minibios) {
			DEBUG_ASSERT((long)Comm0_size <= COMM_OVERLAY_MAX_SIZE);
			DMAToMPE(mpeIndex, (void *)COMM_OVERLAY_ORIGIN, Comm0_start, (long)Comm0_size >> 2);
		} else {
			DEBUG_ASSERT((long)Comm_size <= COMM_OVERLAY_MAX_SIZE);
			DMAToMPE(mpeIndex, (void *)COMM_OVERLAY_ORIGIN, Comm_start, (long)Comm_size >> 2);
		}

		// load data

		DEBUG_ASSERT((long)Data_size <= DATA_OVERLAY_MAX_SIZE);
		DMAToMPE(mpeIndex, (void *)DATA_OVERLAY_ORIGIN, Data_start, (long)Data_size >> 2);

		// Miscellaneous pre-start initialization. The MPE task counter is set to one because the MPE
		// event handler will generate an MPE_TASK_COMPLETE comm bus packet as soon as it starts running.

		if (!mpe->minibios) {

			_MPEWriteRegister(mpe->commBusId, (void *)0x205007e0, MPE_TASK_COMPLETE);	// comminfo

			val = (1 << 13) | gc->commBusId;
			_MPEWriteRegister(mpe->commBusId, (void *)0x205007f0, val);					// commctl
		}

		val = (1 << 28) | (gc->pixelType << 20);
		_MPEWriteRegister(mpe->commBusId, (void *)0x205002a0, val);						// linpixctl

		DMAToMPE(mpeIndex, MPEController, &(mpe->initData), 2);

		mpe->validationFlags	= ~VAL_MPE_INVALIDATED;
		mpe->taskCounter		= 1;
		mpe->loader				= NULL;
		mpe->lighter			= NULL;
		mpe->transformer		= NULL;
		mpe->trivia				= NULL;
		mpe->clipper			= NULL;
		mpe->rasterizer			= NULL;

		// start MPE and wait for comm bus packet

		_MPERun(mpe->commBusId, (void *)EventHandler);
		WaitForMPE(mpeIndex);
	}

	// Check for DMA parameters change

	if (mpe->validationFlags & VAL_RENDER_BUFFER) {
		DMAToMPE(mpeIndex, MPEDMAFlags, gc->dmaData, 2);
	}

	// Check for fog change

	if (mpe->validationFlags & VAL_FOG) {
		DMAToMPE(mpeIndex, MPEFogParameter, gc->fogData, 2);
	}

	// Check for lighting changes

	if (mpe->validationFlags & VAL_LIGHTING) {
		DMAToMPE(mpeIndex, MPELights, gc->lightData, LIGHT_DATA_SIZE);
	}

	if (mpe->validationFlags & VAL_MATERIAL_SHININESS) {
		DMAToMPE(mpeIndex, MPESpecularLUT, gc->specularLUTData, SPECULAR_LUT_SIZE);
	}

	// Check for matrix change

	if (mpe->validationFlags & VAL_TOTAL_MATRIX) {
		DMAToMPE(mpeIndex, MPEMatrix, gc->totalMatrixData, 16);
	}

	// Check for viewport change

	if (mpe->validationFlags & VAL_VIEWPORT) {
		DMAToMPE(mpeIndex, MPEViewport, gc->viewportData, 4);
	}

	// Check for texture change. For now, consider only level 0 of the current 2D texture.

	if (mpe->validationFlags & VAL_TEXTURE) {
		tp = gc->current2DObject->texture[0];
		DEBUG_ASSERT(tp->size <= MAX_TEX_MEM); // pixmap + clut
		DMAToMPE(mpeIndex, MPETextureCache, tp->pbuffer, tp->size);
		DMAToMPE(mpeIndex, MPETextureInfo, tp->mpeInfo, 3);
	}

	// Check for pipeline changes

	if (mpe->validationFlags & VAL_PIPELINE) {

		// Load vertex loader

		dstAddr = VERTEX_LOADER_OVERLAY_ORIGIN;
		load = mpe->loader != gc->loader;

		if (load) {
			mpe->loader = gc->loader;
			DMAToMPE(mpeIndex, (void *)dstAddr, gc->loader, gc->loader_size >> 2);
		}

		dstAddr += gc->loader_size;

		// Load vertex lighter

		load |= mpe->lighter != gc->lighter;

		if (load) {
			mpe->lighter = gc->lighter;
			if (gc->lighter != NULL) {
				DMAToMPE(mpeIndex, (void *)dstAddr, gc->lighter, gc->lighter_size >> 2);
			}
		}

		dstAddr += gc->lighter_size;

		// Load vertex transformer

		load |= mpe->transformer != gc->transformer;

		if (load) {
			mpe->transformer = gc->transformer;
			DMAToMPE(mpeIndex, (void *)dstAddr, gc->transformer, gc->transformer_size >> 2);
		}

		dstAddr += gc->transformer_size;

		// Load trivial accept/reject code

		load |= mpe->trivia != gc->trivia;

		if (load) {
			mpe->trivia = gc->trivia;
			DMAToMPE(mpeIndex, (void *)dstAddr, gc->trivia, gc->trivia_size >> 2);
		}

		DEBUG_ASSERT((dstAddr + gc->trivia_size) <= CLIPPER_OVERLAY_ORIGIN);

		// Load clipper

		if (mpe->clipper != gc->clipper) {
			mpe->clipper = gc->clipper;
			DEBUG_ASSERT(gc->clipper_size <= CLIPPER_OVERLAY_MAX_SIZE);
			DMAToMPE(mpeIndex, (void *)CLIPPER_OVERLAY_ORIGIN, gc->clipper, gc->clipper_size >> 2);
		}

		// Load polygon rasterizer

		if (mpe->rasterizer != gc->rasterizer) {
			mpe->rasterizer = gc->rasterizer;
			DEBUG_ASSERT(gc->rasterizer_size <= RASTERIZER_OVERLAY_MAX_SIZE);
			DMAToMPE(mpeIndex, (void *)RASTERIZER_OVERLAY_ORIGIN, gc->rasterizer, gc->rasterizer_size >> 2);
		}
	}

	// Clear validation flags

	mpe->validationFlags = 0;
}

void mglInvalidateMPE(int commBusId)
{
	int mpeIndex;

	for (mpeIndex = 0; mpeIndex < gc->numMPEs; mpeIndex++) {
		if (gc->mpe[mpeIndex].commBusId == commBusId) {
			WaitForMPE(mpeIndex);
			StopMPE(commBusId);
			gc->mpe[mpeIndex].validationFlags |= VAL_MPE_INVALIDATED;
			break;
		}
	}
}

void mglInvalidateAllMPEs(void)
{
	int mpeIndex;

	for (mpeIndex = 0; mpeIndex < gc->numMPEs; mpeIndex++) {
		WaitForMPE(mpeIndex);
		StopMPE(gc->mpe[mpeIndex].commBusId);
		gc->mpe[mpeIndex].validationFlags |= VAL_MPE_INVALIDATED;
	}
}
