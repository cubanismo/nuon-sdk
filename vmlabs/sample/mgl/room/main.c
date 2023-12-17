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

#include <nuon/gl.h>
#include <stdio.h>
#include <stdarg.h>
#include <math.h>
#include <stdlib.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>
#include <nuon/bios.h>

// Miscellaneous defines
#define PIXEL_TYPE	e655Z
#define NUM_BUFFERS	3
#define NUM_MPES	0		// number of MPEs to be used for rendering; 0 means use as many as possible

// Forward declarations
extern void InitNewroom29();
extern void DrawNewroom29();

int main(void)
{
	char buff[128];
	mmlSysResources sysRes;
	mmlDisplayPixmap screen[NUM_BUFFERS], *pp;
	int joy_shot = 0, joy_now = 0, joy_old = 0, joy_rudder = 0, joy_stabilizer = 0;
	int iangle = 45;
	float xpos = 22.0f, ypos = 49.0f, zpos = 17.0f;
	int lightingFlag = TRUE;
	float st, ct;
	long renderTime;
	long _oldfieldcount;
	unsigned int bgcolor, fgcolor;

	float lightPos[4] = { 0.0f, 0.7071f, 0.7071f, 0.0f };

	// Generate text colors
	if (PIXEL_TYPE != e655Z) {
		bgcolor = mglColorFromRGB(0, 200, 0);
		fgcolor = mglColorFromRGB(0, 200, 200);
	} else {
		bgcolor = mglColor16FromRGB(0, 200, 0);
		fgcolor = mglColor16FromRGB(0, 200, 200);
	}

	// Initialize 2D API
	mmlPowerUpGraphics(&sysRes);
	mmlInitDisplayPixmaps(screen, &sysRes, 360, 240, PIXEL_TYPE, NUM_BUFFERS, NULL);

	// Initialize OpenGL API

	mglInit(screen, eNoVideoFilter, NUM_BUFFERS, NUM_MPES);
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClearDepth(1.0f);

	// Initialize and set textures
	InitNewroom29();

	// Set up joystick
	joy_shot = joy_now = _Controller[1].buttons;

	// Set up rendering mode
	glLoadIdentity();
	glDrawBuffer(GL_BACK);
	glDepthFunc(GL_LESS);
	glEnable(GL_DEPTH_TEST);
	//glEnable(GL_FOG);
	glFogf(GL_FOG_START, 200.0f);
	glFogf(GL_FOG_END, 500.0f);
	glEnable(GL_TEXTURE_2D);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glMatrixMode(GL_PROJECTION);
	gluPerspective(45.0, 1.5, 5.0, 500.0);		// Don't allow zNear < 1.01 or so or bad things will happen
	glMatrixMode(GL_MODELVIEW);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPos); // light moves with viewer
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glMaterialf(GL_FRONT, GL_SHININESS, 2.0f);

	// Set viewport slightly inset in order to avoid fixed point roundoff
	// error during clipping.
	glViewport(3, 3, 354, 234);

	// Rendering loop

	while (1) {
			
		/*
		 * Render
		 */

		_oldfieldcount = _VidSync(-1);

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glLoadIdentity();
		glRotatef((float)iangle, 0.0f, 1.0f, 0.0f);
		glTranslatef(-xpos, -ypos, -zpos);
        DrawNewroom29();
		glFinish();

		pp = mglGetBuffer(GL_BACK);
		renderTime = _VidSync(-1) - _oldfieldcount;
		sprintf(buff, "%ld", renderTime);
		DebugWS(pp->dmaFlags, pp->memP, 64, 184, fgcolor, buff);

		mglSwapBuffers();

		/*
		 * React to joypad movements
		 */

		joy_now = _Controller[1].buttons;
		joy_shot = (joy_old ^ joy_now) & joy_now;
		joy_old = joy_now;

		// Flip filtering mode
		if (joy_shot & JOY_B) {
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		} else if (joy_shot & JOY_A) {
			glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		}

		// Flip texturing on/off
		if (joy_shot & JOY_Z) {

			lightingFlag = !lightingFlag;

			if (lightingFlag) {
				glEnable(GL_LIGHTING);
				glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
			} else {
				glDisable(GL_LIGHTING);
				glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
			}
		}

		if (renderTime == 0) renderTime = 1;

		// rotate left/right
		if (joy_now & JOY_C_LEFT) {
			iangle -= renderTime;
			while (iangle <  0) iangle += 360;
		} else if (joy_now & JOY_C_RIGHT) {
			iangle += renderTime;
			while (iangle >= 360) iangle -= 360;
		}

		// move up/down
		if (joy_now & JOY_C_UP) {
			ypos += 0.8 * renderTime;
			if (ypos > 98.0f) ypos = 98.0f;
		} else if (joy_now & JOY_C_DOWN) {
			ypos -= 0.8 * renderTime;
			if (ypos < 0.0f) ypos = 0.0f;
		}

		// Reset demo
		if (joy_now & JOY_START) {
			iangle = 0;
			xpos = 22.0f;
			ypos = 49.0f;
			zpos = 17.0f;
		}

		// move forward/back/left/right
		if (joy_now & JOY_UP) {
			joy_stabilizer = 2;
		} else if (joy_now & JOY_DOWN) {
			joy_stabilizer = -2;
		} else if (joy_now & JOY_LEFT) {
			joy_rudder = -2;
		} else if (joy_now & JOY_RIGHT) {
			joy_rudder = 2;
		}

		st = sin(iangle * (3.14159265f / 180.0f));
		ct = cos(iangle * (3.14159265f / 180.0f));
	
		xpos += renderTime * (ct * joy_rudder + st * joy_stabilizer);
		zpos -= renderTime * (-st * joy_rudder + ct * joy_stabilizer);

		joy_rudder = 0;
		joy_stabilizer = 0;

		// Wait for video sync if double buffered, else move on
#if (NUM_BUFFERS < 3)
		mglVideoSync();
#endif
	}
}


