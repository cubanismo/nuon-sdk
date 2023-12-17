/*
 * 
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdio.h>
#include <nuon/gl.h>
#include <nuon/mml2d.h>

#define NUM_BUFFERS 2

#define D0			(4 << GLXYZWMODELSHIFT)
#define D1			((3 * D0) >> 1)

#define YCBA0		0xff00007f
#define YCBA1		0x00ff007f
#define YCBA2		0x0000ff7f
#define YCBA3		0xffff007f
#define YCBA4		0xff00ff7f

static GLTexture *texture0 = NULL;
static GLTexture *texture1 = NULL;

static void SetProjection(void)
{
	double d, near, far;

	const double fovy	= 45.0;	// deg
	const double aspect	= 1.5;

	d = D0 / (double)(1 << GLXYZWMODELSHIFT);
	near = 10.0;
	far = near + 4.0 * d;

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(fovy, aspect, near, far);

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	glTranslated(0.0, 0.0, -0.5 * (near + far));
}

static void InitTexture0(void)
{
	int i0, i1, j0, j1, n, texelOffset, c;

	const int texDim = 64;	// must be divisible by 8 for loop below
	const int chkDim =  8;	// must be divisible by 8 for loop below

	texture0 = mglNewTexture(texDim, texDim, eClut4, GL_FALSE);

	texture0->clut[0] = mglColorFromRGB(0, 0, 0);
	texture0->clut[1] = mglColorFromRGB(255, 255, 255);

	n = texDim / chkDim;

	for (i0 = 0; i0 < n; i0++) {
		for (j0 = 0; j0 < n; j0++) {
			for (i1 = 0; i1 < chkDim; i1++) {
				for (j1 = 0; j1 < chkDim; j1 += 8) {
					texelOffset = texDim * (chkDim * i0 + i1) + chkDim * j0 + j1;
					c = ((i0 + j0) & 0x1) ? 0x11111111 : 0x00000000;
					*(texture0->pbuffer + (texelOffset >> 3)) = c;
				}
			}
		}
	}
}

static void
InitTexture1(void)
{
	int i, c;

	extern long texture1_data[];

	texture1 = mglInitBMPTexture(texture1_data, 1, 0);

	for (i = 0; i < texture1->clutSize; i++) {
		c = texture1->clut[i];
		c &= 0xffffff00;
		c |= 0x000000ef;
		texture1->clut[i] = c;
	}
}

static void DrawOpaqueObject(void)
{
	// VERTEX_XYZWUVN; normal will be ignored since lighting is disabled
	static const long vertexBuffer[] = {
		-D1,	-D1,	0,	1<<GLXYZWMODELSHIFT,	                 0,	                 0, 0,	0,
		+D1,	-D1,	0,	1<<GLXYZWMODELSHIFT,	1<<GLTEXCOORDSHIFT,	                 0,	0,	0,
		-D1,	+D1,	0,	1<<GLXYZWMODELSHIFT,	                 0,	1<<GLTEXCOORDSHIFT,	0,	0,
		+D1,	+D1,	0,	1<<GLXYZWMODELSHIFT,	1<<GLTEXCOORDSHIFT,	1<<GLTEXCOORDSHIFT,	0,	0,
		-D1,	+D1,	0,	1<<GLXYZWMODELSHIFT,	                 0,	1<<GLTEXCOORDSHIFT,	0,	0,
		+D1,	-D1,	0,	1<<GLXYZWMODELSHIFT,	1<<GLTEXCOORDSHIFT,	                 0,	0,	0,
	};

	const int vertexCount = sizeof(vertexBuffer) / (8 * sizeof(long));

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glEnable(GL_TEXTURE_2D);
	mglSetTexture(texture0);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, vertexBuffer, vertexCount, 1);
	glDisable(GL_TEXTURE_2D);
}

// faces of the cube should really be drawn in back-to-front order
static void DrawTransparentObject(void)
{
	// VERTEX_XYZC
	static const long vertexBuffer0[] = {

		// +x face
		+D0, -D0, -D0, YCBA0,
		+D0, +D0, -D0, YCBA0,
		+D0, -D0, +D0, YCBA0,
		+D0, +D0, -D0, YCBA0,
		+D0, +D0, +D0, YCBA0,
		+D0, -D0, +D0, YCBA0,

		// -x face
		-D0, +D0, -D0, YCBA1,
		-D0, -D0, -D0, YCBA1,
		-D0, +D0, +D0, YCBA1,
		-D0, -D0, -D0, YCBA1,
		-D0, -D0, +D0, YCBA1,
		-D0, +D0, +D0, YCBA1,

		// +y face
		+D0, +D0, -D0, YCBA2,
		-D0, +D0, -D0, YCBA2,
		+D0, +D0, +D0, YCBA2,
		-D0, +D0, -D0, YCBA2,
		-D0, +D0, +D0, YCBA2,
		+D0, +D0, +D0, YCBA2,

		// -y face
		-D0, -D0, -D0, YCBA3,
		+D0, -D0, -D0, YCBA3,
		-D0, -D0, +D0, YCBA3,
		+D0, -D0, -D0, YCBA3,
		+D0, -D0, +D0, YCBA3,
		-D0, -D0, +D0, YCBA3,

		// +z face
		-D0, +D0, +D0, YCBA4,
		-D0, -D0, +D0, YCBA4,
		+D0, +D0, +D0, YCBA4,
		-D0, -D0, +D0, YCBA4,
		+D0, -D0, +D0, YCBA4,
		+D0, +D0, +D0, YCBA4,
	};

	const int vertexCount0 = sizeof(vertexBuffer0) / (4 * sizeof(long));

	// VERTEX_XYZWUVN; normal will be ignored since lighting is disabled
	static const long vertexBuffer1[] = {
		// -z face	
		-D0,	-D0,	-D0,	1<<GLXYZWMODELSHIFT,	                 0,	                 0, 0,	0,
		-D0,	+D0,	-D0,	1<<GLXYZWMODELSHIFT,	                 0,	1<<GLTEXCOORDSHIFT,	0,	0,
		+D0,	-D0,	-D0,	1<<GLXYZWMODELSHIFT,	1<<GLTEXCOORDSHIFT,	                 0,	0,	0,
		-D0,	+D0,	-D0,	1<<GLXYZWMODELSHIFT,	                 0,	1<<GLTEXCOORDSHIFT,	0,	0,
		+D0,	+D0,	-D0,	1<<GLXYZWMODELSHIFT,	1<<GLTEXCOORDSHIFT,	1<<GLTEXCOORDSHIFT,	0,	0,
		+D0,	-D0,	-D0,	1<<GLXYZWMODELSHIFT,	1<<GLTEXCOORDSHIFT,	                 0,	0,	0,	
	};

	const int vertexCount1 = sizeof(vertexBuffer1) / (8 * sizeof(long));

	glDepthMask(GL_FALSE);
	glEnable(GL_BLEND);

	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZC, vertexBuffer0, vertexCount0, 1);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glEnable(GL_TEXTURE_2D);
	mglSetTexture(texture1);
	mglDrawBuffer(GL_TRIANGLES, VERTEX_XYZWUVN, vertexBuffer1, vertexCount1, 1);
	glDisable(GL_TEXTURE_2D);

	glDepthMask(GL_TRUE);
	glDisable(GL_BLEND);
}

int main(void)
{
	mmlSysResources sysRes;
	mmlDisplayPixmap screen[NUM_BUFFERS];

	float angle0		=  0.0f;	// deg
	float angle0Step	=  0.0f;	// deg
	float angle1		=  0.0f;	// deg
	float angle1Step	=  1.0f;	// deg
	float angle2		=  0.0f;	// deg
	float angle2Step	=  1.0f;	// deg

	// initialize 2D API

	mmlPowerUpGraphics(&sysRes);
	mmlInitDisplayPixmaps(screen, &sysRes, 360, 240, e655Z, NUM_BUFFERS, NULL);

	// initialize OpenGL API

	mglInit(screen, eNoVideoFilter, NUM_BUFFERS, 1);
	glViewport(3, 3, 354, 234);	// slightly inset in order to avoid fixed point roundoff error during clipping
	glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
	glClearDepth(1.0f);
	glDepthFunc(GL_LESS);
	glEnable(GL_DEPTH_TEST);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

	InitTexture0();
	InitTexture1();
	SetProjection();

	// loop

	while (1)
	{
		// draw

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		DrawOpaqueObject();

		glPushMatrix();
		glRotatef(angle2, 0.0f, 0.0f, 1.0f);
		glRotatef(angle1, 0.0f, 1.0f, 0.0f);
		glRotatef(angle0, 1.0f, 0.0f, 0.0f);
		DrawTransparentObject();
		glPopMatrix();

		mglSwapBuffers();

#if (NUM_BUFFERS < 3)
		mglVideoSync();
#endif

		// increment rotation

		angle0 += angle0Step;

		if (angle0 > 360.0f) {
			angle0 -=360.0f;
		} else if (angle0 < -360.0f) {
			angle0 += 360.0f;
		}

		angle1 += angle1Step;

		if (angle1 > 360.0f) {
			angle1 -=360.0f;
		} else if (angle1 < -360.0f) {
			angle1 += 360.0f;
		}

		angle2 += angle2Step;

		if (angle2 > 360.0f) {
			angle2 -=360.0f;
		} else if (angle2 < -360.0f) {
			angle2 += 360.0f;
		}
	}
}
