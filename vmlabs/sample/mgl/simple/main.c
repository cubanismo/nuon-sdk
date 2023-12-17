/* Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
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
#include <nuon/mutil.h>

#define PIXEL_TYPE		e655Z
#define NUM_BUFFERS		2

int main(void)
{
	mmlSysResources sysRes;
	mmlDisplayPixmap screen[NUM_BUFFERS], *pp;
	float f[4];
	unsigned int fgcolor;
	int retval;

	float angle0	= 0.0f;	// deg
	float angle1	= 0.0f;	// deg
	float angleStep	= 1.0f;	// deg

	const int d = 1 << 10;

	const float oneOverSqrt3 = 0.57735027f;

	// Generate text colors

	if (PIXEL_TYPE != e655Z) {
		fgcolor = mglColorFromRGB(0, 200, 200);
	} else {
		fgcolor = mglColor16FromRGB(0, 200, 200);
	}

	// initialize 2D API

	mmlPowerUpGraphics(&sysRes);
	mmlInitDisplayPixmaps(screen, &sysRes, 360, 240, PIXEL_TYPE, NUM_BUFFERS, NULL);

	// initialize OpenGL API

	retval = mglInit(screen, eNoVideoFilter, NUM_BUFFERS, 1);
#ifdef	DEBUG
	printf ("Retval is: %i.\n", retval); fflush(stdout);
#endif

	glViewport(3, 3, 354, 234);	// slightly inset in order to avoid fixed point roundoff
								// error during clipping.
	glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
	glClearDepth(1.0f);
	glEnable(GL_DEPTH_TEST);

  	f[0] = 0.0f; f[1] = 0.0f; f[2] = 0.0f; f[3] = 1.0f;
	glMaterialfv(GL_FRONT, GL_AMBIENT, f);
	f[0] = 1.0f; f[1] = 1.0f; f[2] = 1.0f; f[3] = 1.0f;
	glMaterialfv(GL_FRONT, GL_DIFFUSE, f);
	f[0] = 0.0f; f[1] = 0.0f; f[2] = 0.0f; f[3] = 1.0f;
	glMaterialfv(GL_FRONT, GL_SPECULAR, f);

	f[0] = 0.0f; f[1] = 0.0f; f[2] = 0.0f; f[3] = 1.0f;
	glLightfv(GL_LIGHT0, GL_AMBIENT, f);
	f[0] = 1.0f; f[1] = 1.0f; f[2] = 1.0f; f[3] = 1.0f;
	glLightfv(GL_LIGHT0, GL_DIFFUSE, f);
	f[0] = 0.0f; f[1] = 0.0f; f[2] = 0.0f; f[3] = 1.0f;
	glLightfv(GL_LIGHT0, GL_SPECULAR, f);
	f[0] = -1.0f; f[1] = 0.0f; f[2] = 0.0f; f[3] = 0.0f;
	glLightfv(GL_LIGHT0, GL_POSITION, f);
	glEnable(GL_LIGHT0);

	glEnable(GL_LIGHTING);

	// loop

	glMatrixMode(GL_PROJECTION);
	gluPerspective(45.0, 1.5, 5.0, 500.0);	// don't allow zNear < 1.01
	glMatrixMode(GL_MODELVIEW);
	glTranslatef(0.0f, 0.0f, -7.0f);

#if	defined(DEBUG)
	printf( "Got to the loop.\n" ); fflush(stdout);
#endif
	while (1)
	{
		// draw

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		glPushMatrix();
		glRotatef(angle1, 0.0f, 1.0f, 0.0f);
		glRotatef(angle0, 0.0f, 0.0f, 1.0f);

		glBegin(GL_TRIANGLES);

		glNormal3f(-1.0f, 0.0f, 0.0f);
		glVertex3fp(0, 0, 0);
		glVertex3fp(0, 0, d);
		glVertex3fp(0, d, 0);

		glNormal3f(0.0f, -1.0f, 0.0f);
		glVertex3fp(0, 0, 0);
		glVertex3fp(d, 0, 0);
		glVertex3fp(0, 0, d);

		glNormal3f(0.0f, 0.0f, -1.0f);
		glVertex3fp(0, 0, 0);
		glVertex3fp(0, d, 0);
		glVertex3fp(d, 0, 0);

		glNormal3f(oneOverSqrt3, oneOverSqrt3, oneOverSqrt3);
		glVertex3fp(d, 0, 0);
		glVertex3fp(0, d, 0);
		glVertex3fp(0, 0, d);

		glEnd();

		glPopMatrix();

		// Grab a pointer to the back buffer and print some stuff

		pp = mglGetBuffer(GL_BACK);
		DebugWS(pp->dmaFlags, pp->memP, 32, 20, fgcolor, "simple test");

		// done drawing

		mglSwapBuffers();

		// Wait for video sync if double buffered, else move on
#if (NUM_BUFFERS < 3)
		mglVideoSync();
#endif

		// update rotation

		angle0 += angleStep;
		angle1 += angleStep;
#if	defined(DEBUG)
		printf ( "looping...\n" ); fflush(stdout);
#endif
	}
}
