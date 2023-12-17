/*
 * Copyright (C) 1995-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

//#define NO_VIDEO
//#define NO_JPEG
/* $Id: test.c,v 1.40 2001/10/18 22:28:19 ersmith Exp $ */

/*
 * Sample C code for invoking the 3D rendering
 * pipeline.
 * 
 */

#define _OLD_JOYSTICK
#include <stdio.h>
#include <stdarg.h>
#include <math.h>
#include <stdlib.h>
#include "nuon/mml2d.h"
#include <nuon/msprintf.h>
#include <nuon/mutil.h>
#include <nuon/joystick.h>
#include <nuon/bios.h>

#include "m3d.h"

/* define "BPP" to the bits per pixel of the
   output data type */

#define BPP 16
//#define BPP 32

#if (BPP == 32)
#define PIXEL_TYPE e888AlphaZ
#define NUM_BUFFERS 2
#else
/* there's enough memory to triple buffer */
#define PIXEL_TYPE e655Z
#define NUM_BUFFERS 3
#endif

//#define TEXTURE_PIXEL_TYPE e655
#define TEXTURE_PIXEL_TYPE e888Alpha

#ifndef MAXCUBES
#define MAXCUBES 20
#endif

//#define INIT_CUBES MAXCUBES
#define INIT_CUBES 1

//#define SCALE 256
#define SCALE 16

struct cube {
    m3dreal pos[3];
    m3dreal angle[3];
    m3dreal vel[3];
    m3dreal anglevel[3];
} cube[MAXCUBES];


#ifndef SCRNWIDTH
#define SCRNWIDTH 352
#define SCRNHEIGHT 240
#endif

/* size of border -- make this a multiple of 4. 8 works fine */
#define BORDERSIZE 16



static int fps;


/*
 * make a model of a cube
 * return the number of polygons in the model
 */

static void
face(m3dBuf *buf, float nx, float ny, float nz)
{
    float ax, ay, az;
    float bx, by, bz;
    float x, y, z;
    int flip;

    ax = ay = az = 0.0;
    bx = by = bz = 0.0;

    if (nz != 0) {
	ax = -SCALE*nz;
	by = -SCALE*nz;
	x = -ax; y = -by;
	z = SCALE*nz;
	flip = (nz < 0.0);
    } else if (ny != 0) {
	az = -SCALE*ny;
	bx = -SCALE*ny;
	z = -az; x = -bx;
	y = SCALE*ny;
	flip = (ny < 0.0);
    } else {
	ay = -SCALE*nx;
	bz = -SCALE*nx;
	y = -ay; z = -bz;
	x = SCALE*nx;
	flip = (nx < 0.0);
    }

    if (flip) {
#if 1
	m3dStartTriangle(buf);
	m3dAddNormal3f(buf, nx, ny, nz);
	m3dAddTextureCoords2f(buf, 0.0, 0.0);
	m3dAddVertex3f(buf, x, y, z);
	m3dAddTextureCoords2f(buf, 1.0, 0.0);
	m3dAddVertex3f(buf, x + 2*ax, y + 2*ay, z + 2*az);
	m3dAddTextureCoords2f(buf, 0.0, 1.0);
	m3dAddVertex3f(buf, x + 2*bx, y + 2*by, z + 2*bz);
	m3dEndTriangle(buf);
#endif
#if 1
	m3dStartTriangle(buf);
	m3dAddNormal3f(buf, nx, ny, nz);
	m3dAddTextureCoords2f(buf, 1.0, 1.0);
	m3dAddVertex3f(buf, x + 2*(ax+bx), y + 2*(ay+by), z + 2*(az+bz));
	m3dAddTextureCoords2f(buf, 0.0, 1.0);
	m3dAddVertex3f(buf, x + 2*bx, y + 2*by, z + 2*bz);
	m3dAddTextureCoords2f(buf, 1.0, 0.0);
	m3dAddVertex3f(buf, x + 2*ax, y + 2*ay, z + 2*az);
	m3dEndTriangle(buf);
#endif
    } else {
	m3dStartTriangle(buf);
	m3dAddNormal3f(buf, nx, ny, nz);
	m3dAddTextureCoords2f(buf, 0.0, 0.0);
	m3dAddVertex3f(buf, x, y, z);
	m3dAddTextureCoords2f(buf, 0.0, 1.0);
	m3dAddVertex3f(buf, x + 2*bx, y + 2*by, z + 2*bz);
	m3dAddTextureCoords2f(buf, 1.0, 0.0);
	m3dAddVertex3f(buf, x + 2*ax, y + 2*ay, z + 2*az);
	m3dEndTriangle(buf);

	m3dStartTriangle(buf);
	m3dAddNormal3f(buf, nx, ny, nz);
	m3dAddTextureCoords2f(buf, 1.0, 1.0);
	m3dAddVertex3f(buf, x + 2*(ax+bx), y + 2*(ay+by), z + 2*(az+bz));
	m3dAddTextureCoords2f(buf, 1.0, 0.0);
	m3dAddVertex3f(buf, x + 2*ax, y + 2*ay, z + 2*az);
	m3dAddTextureCoords2f(buf, 0.0, 1.0);
	m3dAddVertex3f(buf, x + 2*bx, y + 2*by, z + 2*bz);
	m3dEndTriangle(buf);
    }
}


extern short catpix128_start[], catpix128_size[];

m3dMaterial *face1, *face2, *face3;
m3dMaterial red, blue;
m3dMaterial cat_mipmap[5];

/* used for toggling mipmaps on/off -- this is a hack */
m3dMaterial bigcat, mipmap_first;

int
MakeModel(mmlSysResources *sr, m3dBuf *buf)
{
    m3dInitMaterialFromColor(&red, mmlColorFromRGB(200, 0, 0));
    m3dInitMaterialFromColor(&blue, mmlColorFromRGB(0, 0, 200));
#ifdef NO_JPEG
    m3dInitMaterialFromColor(cat_mipmap,mmlColorFromRGB(200,200,200));
#else
    m3dInitMipMapFromJPEG(cat_mipmap, 5, sr, catpix128_start, (int)catpix128_size, TEXTURE_PIXEL_TYPE);
#endif

    /* hack: the highest leveled number of a mipmap is the
       biggest image, and is also able to stand alone as a texture */
    bigcat = cat_mipmap[4];
    mipmap_first = cat_mipmap[0];  /* save first image */

    face1 = &cat_mipmap[0];
    face2 = &red;
    face3 = &blue;

    m3dInitBuf(buf);

#if 1
    m3dSetMaterial(buf, face1);
    face(buf, 1.0, 0.0, 0.0);
    face(buf, -1.0, 0.0, 0.0);
#endif

#if 1
    m3dSetMaterial(buf, face1);
    face(buf, 0.0, 1.0, 0.0);
    face(buf, 0.0, -1.0, 0.0);
#endif

#if 1
    m3dSetMaterial(buf, face1);
    face(buf, 0.0, 0.0, 1.0);
    face(buf, 0.0, 0.0, -1.0);
#endif

    return 12;
}


m3dreal MaxPos[3];
m3dreal MinPos[3];

/*
 * initialize a cube
 */

#define DEGREE M3DF(1.0/360.0)

void
InitCube(struct cube *C)
{
    int i;
    int range;

    for (i = 0; i < 3; i++) {
	range = (MaxPos[i] - MinPos[i]) >> 16;
	C->pos[i] = MinPos[i] + M3DI((rand() % range));
	C->vel[i] = M3DI( SCALE - (rand() % (2*SCALE)) )/8;
	C->angle[i] = (rand() % 360) * DEGREE;
	C->anglevel[i] = (((rand() % 15) - 7) * DEGREE)/4;
    }
}


void
MoveCube(int frames, struct cube *C)
{
    int i;

    for (i = 0; i < 3; i++) {
	C->pos[i] += frames * C->vel[i];
	if (C->pos[i] < MinPos[i]) {
	    C->pos[i] = MinPos[i];
	    C->vel[i] = -C->vel[i];
	} else if (C->pos[i] > MaxPos[i]) {
	    C->pos[i] = MaxPos[i];
	    C->vel[i] = -C->vel[i];
	}

	C->angle[i] += frames * C->anglevel[i];
    }
}

void
CubeMatrix(struct cube *C, m3dMatrix *M)
{
    /* set up the rotation part of the matrix */
    m3dEulerMatrix(M, C->angle[0], C->angle[1], C->angle[2]);
    /* now position the matrix */
    m3dPlaceMatrix(M, C->pos[0], C->pos[1], C->pos[2]);
}

mmlSysResources sysRes;
mmlDisplayPixmap the_screen[3];
int drawBuffer = 0;
m3dMatrix test_model_matrix;

/*
 * wait for video
 * returns the number of elapsed fields
 * since the last sync
 */

int
VideoSync(void)
{
#ifdef NO_VIDEO
    return 1;
#else
    static int frames;
    static int lastfield;
    static int lastsecond;
    int ret;

    int curfield;

    /* we want to view the buffer we just finished
       drawing */

    /* set the video to point at the drawn buffer */
    mmlSimpleVideoSetup(&the_screen[drawBuffer], &sysRes, eNoVideoFilter);

    /* find out how many fields have been drawn */
//    curfield = _VidSync(-1);
    curfield = _VidSync(1);

    /* remember that we've drawn a frame */
    frames++;

    /* have more than 60 fields (1 second) passed? */
    if (curfield - lastsecond >= 60) {
	fps = frames;
	frames = 0;
	lastsecond = curfield;
    }

    /* draw to a new buffer */
    drawBuffer++;
    if (drawBuffer >= NUM_BUFFERS)
	drawBuffer = 0;

#if NUM_BUFFERS == 2
    /* wait until a new field starts (so it's no longer
       showing the field we're going to draw on) */
    curfield = _VidSync(0);
#endif

    ret = curfield - lastfield;
    while (ret == 0) {
	curfield = _VidSync(-1);
	ret = curfield - lastfield;
    }
    lastfield = curfield;
    return ret;
#endif
}

m3dLightData the_lights;
m3dCamera the_camera;

int
main(int argc, char **argv)
{
    mmlGC gc;
    static char buf[SPRINTF_MAX];
    int numpolys;
    int modelpolys;
    int frames;
    m3dBuf test_model;
    m3dreal camx, camy, camz;
    m3dreal camxrot, camyrot, camzrot;
    m3dMatrix camM;
    int i;
    long joystick;
    long oldjoystick;
    long edge;
    int numcubes;
    int use_mipmap;
    int use_bilerp;
    int use_edgeaa;
    mmlColor bgcolor;
    mmlColor fgcolor;
    mmlColor bordercolor;
    m2dRect drawRect;
    unsigned long starttime, endtime, elapsedtime;
    unsigned long secs, usecs;

    mmlPowerUpGraphics( &sysRes );
#if RUN_IN_PLACE
    /* indicate that we will use only ourselves -- no
       other MPEs */
    m3dInit(&sysRes, 0);
#else
    m3dInit(&sysRes, 4 );
#endif

    mmlInitGC(&gc, &sysRes);

    /* initialize display */
    mmlInitDisplayPixmaps( the_screen, &sysRes, SCRNWIDTH, SCRNHEIGHT, PIXEL_TYPE,
			   NUM_BUFFERS, NULL);

    /* set up the foreground and background colors */
    bordercolor = mmlColorFromRGB(128,128,128);
    bgcolor = mmlColorFromRGB(40, 40, 240);
    fgcolor = mmlColorFromRGB(128, 40, 40);

    /* set up the drawing rectangle */
    m2dSetRect(&drawRect, BORDERSIZE, BORDERSIZE, SCRNWIDTH-BORDERSIZE,
	       SCRNHEIGHT-BORDERSIZE );


    /* make the model we're going to use */
    modelpolys = MakeModel(&sysRes, &test_model);

    /* set up the lighting model */
    m3dInitLights(&the_lights, M3DF(0.2));
    m3dAddDirectionalLight(&the_lights, M3DF(0.40824829), M3DF(0.408424829),
			   M3DF(0.81649658), M3DF(0.7));

    /* set up max & min positions for the cubes */
    /* X */
    MinPos[0] = M3DI(-8*SCALE); MaxPos[0] = M3DI(8*SCALE);

    /* Y */
    MinPos[1] = M3DI(-8*SCALE); MaxPos[1] = M3DI(8*SCALE);

    /* Z */
    MinPos[2] =  M3DI(8*SCALE); MaxPos[2] = M3DI(30*SCALE);


    /* miscellaneous setup */
    use_mipmap = 1;
    use_bilerp = 0;
    use_edgeaa = 0;

    oldjoystick = _Controller[1].buttonset;
#ifndef NO_VIDEO
    InitTimer();
#endif

reinit:
    numcubes = INIT_CUBES;

    /* initialize the camera, and place it at 0,0,0 (default) */
    m3dInitCamera(&the_camera, M3DF(1.0), M3DI(10000));
    camx = camy = 0;
    camz = M3DI(-SCALE);
    camxrot = camyrot = camzrot = 0;

    /* initialize cubes */
    /* cube 0 is special, let's have the joystick control it */
    cube[0].vel[0] = cube[0].vel[1] = cube[0].vel[2] = 0;

#if 0
    cube[0].pos[0] = 0x00040000;
    cube[0].pos[1] = 0;
    cube[0].pos[2] = 0x00124000;
    cube[0].angle[0] = 0x00013320;
    cube[0].angle[1] = 0x0004b94e;
    cube[0].angle[2] = 0;
#else
    cube[0].pos[0] = 0;
    cube[0].pos[1] = 0;
    cube[0].pos[2] = M3DI(9*SCALE);
    cube[0].angle[0] = 30*DEGREE;
    cube[0].angle[1] = -30*DEGREE;
    cube[0].angle[2] = 0;
#endif

    cube[0].anglevel[0] = cube[0].anglevel[1] = cube[0].anglevel[2] = 0;

    for (i = 1; i < MAXCUBES; i++) {
	InitCube(&cube[i]);
    }

    for (i = 0; i < NUM_BUFFERS; i++) {
	m2dFillColr(&gc, &the_screen[i], NULL, bordercolor);
    }

    for(;;) {
	long zstep, xstep;

	numpolys = 0;

	/* set up the camera */
	m3dEulerMatrix(&camM, camxrot, camyrot, camzrot);
	m3dPlaceMatrix(&camM, camx, camy, camz);
	m3dSetCameraMatrix(&the_camera, &camM);

	/* figure out hints, etc. */
	if (use_bilerp) {
	    m3dHint(M3D_TEXTURE_FILTER, M3D_BILERP);
	} else {
	    m3dHint(M3D_TEXTURE_FILTER, M3D_NONE);
	}

	if (use_edgeaa) {
	    m3dHint(M3D_EDGE_AA, M3D_EDGE_VMLABS);
	} else {
	    m3dHint(M3D_EDGE_AA, M3D_NONE);
	}

#ifdef NO_VIDEO
	frames = 1;
	starttime = 1;
#else
	frames = VideoSync();

	GetTimer(&secs, &usecs);

	/* calculate time in 10s of microseconds (we're not
	   really microsecond accurate) */
	starttime = secs*100000 + (usecs + 5)/10;
#endif

	/* do animation for models */
	for (i = 1; i < numcubes; i++) {
	    MoveCube(frames, &cube[i]);
	}

	m2dFillColr(&gc, &the_screen[drawBuffer], &drawRect, bgcolor);

	/* now render them */
	for (i = 0; i < numcubes; i++) {
	    CubeMatrix(&cube[i], &test_model_matrix);
	    m3dExecuteBuffer(&gc, &the_screen[drawBuffer], &drawRect, &test_model,
			     &test_model_matrix, &the_camera, &the_lights);
	    numpolys += modelpolys;
	}

	/* finish rendering */
	m3dEndScene(&gc, &the_screen[drawBuffer], &drawRect);

#ifdef NO_VIDEO
	endtime = 2;
#else
	GetTimer(&secs,&usecs);

	/* calculate time in 10s of microseconds (we're not
	   really microsecond accurate) */
	endtime = (secs*100000) + (usecs+5)/10;
#endif
	elapsedtime = endtime - starttime;

	/* check joystick */
	joystick = _Controller[1].buttonset;

	/* figure out which buttons have just been pushed */
	edge = (joystick ^ oldjoystick) & joystick;


	/* camera motion */
#define STEP (SCALE*(0xf0<<6))
	if (joystick & JOY_UP) {
	    camz += frames*STEP;
	} else if (joystick & JOY_DOWN) {
	    camz -= frames*STEP;
	}
	if (joystick & JOY_LEFT) {
	    camyrot -= frames * DEGREE;
	} else if (joystick & JOY_RIGHT) {
	    camyrot += frames * DEGREE;
	}

	/* now move user controlled cube */
	xstep = _Controller[1].xAxis & ~0xf;
	zstep = _Controller[1].yAxis & ~0xf;

	cube[0].pos[0] += frames * SCALE * (xstep << 6);
	cube[0].pos[2] += frames * SCALE * (zstep << 6);


	if (joystick & JOY_C_UP) {
	    cube[0].angle[0] -= frames * DEGREE;
	} else if (joystick & JOY_C_DOWN) {
	    cube[0].angle[0] += frames * DEGREE;
	}
	if (joystick & JOY_C_LEFT) {
	    cube[0].angle[1] -= frames * DEGREE;
	} else if (joystick & JOY_C_RIGHT) {
	    cube[0].angle[1] += frames * DEGREE;
	}

	if (joystick & (JOY_L)) {
	    if (numcubes < MAXCUBES) 
		numcubes++;
	}

	if (edge & JOY_START) {
	    goto reinit;
	}

	/* toggle edge-antialiasing */
	if (edge & JOY_A) {
	    use_edgeaa = !use_edgeaa;
	}

	/* toggle mip-mapping */
	if (edge & JOY_R) {
	    use_mipmap = !use_mipmap;
	    if (use_mipmap) {
		*face1 = mipmap_first;
	    } else {
		*face1 = bigcat;
	    }
	}

	/* toggle filtering */
	if (edge & JOY_B) {
	    use_bilerp = !use_bilerp;
	}

#define FGCOLOR 0xa2100000

	if (joystick & JOY_A) {
	    sprintf(buf, "edgeaa %s", use_edgeaa ? "on" : "off");
	    DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 32, 
		    FGCOLOR, buf);
	}

	if (joystick & JOY_R) {
	    sprintf(buf, "mipmap %s", use_mipmap ? "on" : "off");
	    DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 32, FGCOLOR,
		    buf);
	}

	if (joystick & JOY_B) {
	    sprintf(buf, "bilerp %s", use_bilerp ? "on" : "off");
	    DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 32, FGCOLOR,
		    buf);
	}

	if (joystick & (JOY_Z)) {
	    /* debugging info */
	    sprintf(buf, "%5d polys", numpolys);
	    DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 48, FGCOLOR, 
		    buf);

	    sprintf(buf, "%5d fps", fps);
	    DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 64, FGCOLOR, 
		    buf);

	    sprintf(buf, "start %ld end %ld", starttime, endtime);
	    DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 80, FGCOLOR, 
		    buf);

	    sprintf(buf, "%5ld draw", elapsedtime);
	    DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 96, FGCOLOR, 
		    buf);
	}

	oldjoystick = joystick;

    }

    return 0;
}
