/*
 * Sample C code for invoking the 3D rendering
 * pipeline to do a walk through demo.
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
#include <stdarg.h>
#include <math.h>
#include <stdlib.h>

#include <nuon/mml2d.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>
#include <nuon/bios.h>
#include <nuon/m3d.h>

/**************************************************************************/

#define Joystick_Buttons() (_Controller[1].buttons)

/**************************************************************************/

#define PIXEL_TYPE e655Z

// This mode doesn't work for some reason
//#define PIXEL_TYPE e888AlphaZ

#ifndef MAXCUBES
#define MAXCUBES 20
#endif

//#define SCALE 256
#define SCALE 80

struct cube {
    m3dreal pos[3];
    m3dreal angle[3];
    m3dreal vel[3];
    m3dreal anglevel[3];
} cube[MAXCUBES];


/**************************************************************************/

#ifndef SCRNWIDTH
#define SCRNWIDTH 360
#define SCRNHEIGHT 240
#endif

#define BORDERSIZE 4	// size of border -- make this a multiple of 4

/**************************************************************************/

#if (PIXEL_TYPE == e888AlphaZ)
#define NUM_BUFFERS 2
#else
/* there's enough memory to triple buffer */
#define NUM_BUFFERS 3
#endif

/**************************************************************************/

mmlSysResources sysRes;
mmlDisplayPixmap the_screen[3];

int drawBuffer = 0;

m3dMatrix test_model_matrix;
m3dLightData the_lights;
m3dCamera the_camera;

static int fps;

/**************************************************************************/

/*
 * make the model we're going to walk through
 * return the number of polygons in the model
 */

m3dMaterial default_material;
m3dMaterial material_0x122813;
m3dMaterial material_0x163172;
m3dMaterial material_0x1d231d;

m3dMaterial material_0x32391c;
m3dMaterial material_0x4d3c2c;
m3dMaterial material_0x57412e;

m3dMaterial material_0x6e0501;
m3dMaterial material_0x725d5f;
m3dMaterial material_0x946530;

m3dMaterial material_0x99230d;
m3dMaterial material_0xfdcd9d;
m3dMaterial material_0xffffff;

extern m3dBuf model;

/**************************************************************************/

int MakeModel(mmlSysResources *sr, m3dBuf *buf)
{
    m3dInitMaterialFromColor(&default_material, mmlColorFromRGB(200, 200, 200));

    m3dInitMaterialFromColor(&material_0x122813, mmlColorFromRGB(0x12, 0x28, 0x13)); /* trees */
    m3dInitMaterialFromColor(&material_0x163172, mmlColorFromRGB(0x16, 0x31, 0x72)); /* pool water */
    m3dInitMaterialFromColor(&material_0x1d231d, mmlColorFromRGB(0x1d, 0x23, 0x1d)); /* building frame */

    m3dInitMaterialFromColor(&material_0x32391c, mmlColorFromRGB(0x32, 0x39, 0x1c)); /* ground */
    m3dInitMaterialFromColor(&material_0x4d3c2c, mmlColorFromRGB(0x4d, 0x3c, 0x2c)); /* building parts */
    m3dInitMaterialFromColor(&material_0x57412e, mmlColorFromRGB(0x57, 0x41, 0x2e)); /* pool sides */

    m3dInitMaterialFromColor(&material_0x6e0501, mmlColorFromRGB(0x6e, 0x05, 0x01));
    m3dInitMaterialFromColor(&material_0x725d5f, mmlColorFromRGB(0x72, 0x5d, 0x5f));
    m3dInitMaterialFromColor(&material_0x946530, mmlColorFromRGB(0x94, 0x65, 0x30)); /* paths */

    m3dInitMaterialFromColor(&material_0x99230d, mmlColorFromRGB(0x99, 0x23, 0x0d));
    m3dInitMaterialFromColor(&material_0xfdcd9d, mmlColorFromRGB(0xfd, 0xcd, 0x9d));
    m3dInitMaterialFromColor(&material_0xffffff, mmlColorFromRGB(0xff, 0xff, 0xff));

    *buf = model;

    return buf->numentries/7;
}

/**************************************************************************/


m3dreal MaxPos[3];
m3dreal MinPos[3];

/* initialize a cube */

#define DEGREE M3DF(1.0/360.0)

void InitCube(struct cube *C)
{
    int i;
    int range;

    for (i = 0; i < 3; i++)
	{
		range = (MaxPos[i] - MinPos[i]) >> 16;
		C->pos[i] = MinPos[i] + M3DI((rand() % range));
		C->vel[i] = M3DI( SCALE - (rand() % (2*SCALE)) )/8;
		C->angle[i] = (rand() % 360) * DEGREE;
		C->anglevel[i] = (((rand() % 15) - 7) * DEGREE)/4;
    }
}

/**************************************************************************/

void MoveCube(int frames, struct cube *C)
{
    int i;

    for (i = 0; i < 3; i++)
	{
		C->pos[i] += frames * C->vel[i];
		if (C->pos[i] < MinPos[i])
		{
			C->pos[i] = MinPos[i];
			C->vel[i] = -C->vel[i];
		}
		else if (C->pos[i] > MaxPos[i])
		{
			C->pos[i] = MaxPos[i];
			C->vel[i] = -C->vel[i];
		}

		C->angle[i] += frames * C->anglevel[i];
    }
}

/**************************************************************************/

void CubeMatrix(struct cube *C, m3dMatrix *M)
{
    /* set up the rotation part of the matrix */
    m3dEulerMatrix(M, C->angle[0], C->angle[1], C->angle[2]);

	/* now position the matrix */
    m3dPlaceMatrix(M, C->pos[0], C->pos[1], C->pos[2]);
}

/**************************************************************************/

/*
 * wait for video
 * returns the number of elapsed fields
 * since the last sync
 */

int VideoSync(void)
{
static int frames;
static int lastfield;
static int lastsecond;
int curfield;

    /* we want to view the buffer we just finished
       drawing */

    /* set the video to point at the drawn buffer */
    mmlSimpleVideoSetup(&the_screen[drawBuffer], &sysRes, eNoVideoFilter);

    /* remember that we've drawn a frame */
    frames++;


    /* find out how many fields have been drawn */
    curfield = _VidSync(-1);

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
    while (curfield == _VidSync(-1))
	;
    curfield = _VidSync(-1) - lastfield;
#else
    do {
	curfield = _VidSync(-1) - lastfield;
    } while (curfield == 0);
#endif

    lastfield = _VidSync(-1);
    return curfield;
}


/**************************************************************************/

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
	char numcubesincremented = 0;
    mmlColor bgcolor;
    mmlColor fgcolor;
    m2dRect drawRect;

    mmlPowerUpGraphics( &sysRes );

#if RUN_IN_PLACE
    /* indicate that we will use only ourselves -- no
       other MPEs */
    m3dInit(&sysRes, 0);
#else
    m3dInit(&sysRes, 4);
#endif

    mmlInitGC(&gc, &sysRes);

    /* initialize display */
    mmlInitDisplayPixmaps( the_screen, &sysRes, SCRNWIDTH, SCRNHEIGHT, PIXEL_TYPE,
			   NUM_BUFFERS, NULL);

    /* set up the foreground and background colors */
    bgcolor = mmlColorFromRGB(128, 128, 128);
    fgcolor = mmlColorFromRGB(240, 80, 80);

    /* set up the drawing rectangle */
    m2dSetRect(&drawRect, 0, 0, SCRNWIDTH-1, SCRNHEIGHT-1);


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
    numcubes = 1;
    use_mipmap = 1;
    use_bilerp = 0;
    use_edgeaa = 0;

	/* Get initial joystick button values */
	oldjoystick = Joystick_Buttons();

reinit:
    /* initialize the camera, and place it at 0,0,0 (default) */
    m3dInitCamera(&the_camera, M3DF(1.0), M3DI(10000));
    camx = camy = 0;
    camz = M3DI(-SCALE);
    camxrot = camyrot = camzrot = 0;

	/* initialize cubes */
    /* cube 0 is special, let's have the joystick control it */
    cube[0].vel[0] = cube[0].vel[1] = cube[0].vel[2] = 0;

    cube[0].pos[0] = 0;
    cube[0].pos[1] = 0;
    cube[0].pos[2] = M3DI(9*SCALE);
    cube[0].angle[0] = 30*DEGREE;
    cube[0].angle[1] = -30*DEGREE;
    cube[0].angle[2] = 0;

    cube[0].anglevel[0] = cube[0].anglevel[1] = cube[0].anglevel[2] = 0;

    for (i = 1; i < MAXCUBES; i++)
		InitCube(&cube[i]);

    for(;;)
	{
	long zstep, xstep;

		numpolys = 0;
	
		/* set up the camera */
		m3dEulerMatrix(&camM, camxrot, camyrot, camzrot);
		m3dPlaceMatrix(&camM, camx, camy, camz);
		m3dSetCameraMatrix(&the_camera, &camM);
	
		frames = VideoSync();
		m2dFillColr(&gc, &the_screen[drawBuffer], NULL, bgcolor);

		/* figure out hints, etc. */
		if (use_bilerp)
		{
			m3dHint(M3D_TEXTURE_FILTER, M3D_BILERP);
		}
		else
		{
			m3dHint(M3D_TEXTURE_FILTER, M3D_NONE);
		}
	
		if (use_edgeaa)
		{
			m3dHint(M3D_EDGE_AA, M3D_EDGE_VMLABS);
		}
		else
		{
			m3dHint(M3D_EDGE_AA, M3D_NONE);
		}
	
		/* do animation for models */
		/* then render them */
		for (i = 0; i < numcubes; i++)
		{
			if (i > 0)
				MoveCube(frames, &cube[i]);
	
			CubeMatrix(&cube[i], &test_model_matrix);

			m3dExecuteBuffer(&gc, &the_screen[drawBuffer], &drawRect, &test_model,
					 &test_model_matrix, &the_camera, &the_lights);
	
			numpolys += modelpolys;
		}
	
		/* finish rendering */
		m3dEndScene(&gc, &the_screen[drawBuffer], &drawRect);
	
		/* check joystick */
		joystick = Joystick_Buttons();
	
		/* figure out which buttons have just been pushed */
		edge = (joystick ^ oldjoystick) & joystick;
	
		/* camera motion */
	
#define STEP (SCALE*(0xf0<<6))
	
		if (joystick & JOY_UP)
		{
			camz += frames * STEP;
		}
		else if (joystick & JOY_DOWN)
		{
			camz -= frames * STEP;
		}

		if (joystick & JOY_LEFT)
		{
			camyrot -= frames * DEGREE;
		}
		else if (joystick & JOY_RIGHT)
		{
			camyrot += frames * DEGREE;
		}
	
		/* now move user controlled cube */
		xstep = JoyXAxis(_Controller[1]);
		zstep = JoyYAxis(_Controller[1]);
	
		cube[0].pos[0] += frames * SCALE * (xstep << 6);
		cube[0].pos[2] += frames * SCALE * (zstep << 6);
	
	
		if (joystick & JOY_C_UP)
		{
			cube[0].angle[0] -= frames * DEGREE;
		}
		else if (joystick & JOY_C_DOWN)
		{
			cube[0].angle[0] += frames * DEGREE;
		}
		
		if (joystick & JOY_C_LEFT)
		{
			cube[0].angle[1] -= frames * DEGREE;
		}
		else if (joystick & JOY_C_RIGHT)
		{
			cube[0].angle[1] += frames * DEGREE;
		}
	
		if (joystick & JOY_L) {
				// make sure we increment only once per button push
			if ((!numcubesincremented) && (numcubes < MAXCUBES)) {
				numcubes++;
				numcubesincremented = 1;
			}
		}
		else {
			numcubesincremented = 0;
		}
	
		if (edge & JOY_START)
		{
			numcubes = 1;
			goto reinit;
		}
	
		/* toggle edge-antialiasing */
		if (edge & JOY_A)
		{
			use_edgeaa = !use_edgeaa;
		}
	
		/* toggle filtering */
		if (edge & JOY_B)
		{
			use_bilerp = !use_bilerp;
		}

		if (edge & JOY_R) {
			use_mipmap = !use_mipmap;
		}
	
#define FGCOLOR 0xa2100000
	
		if (joystick & JOY_A)
		{
			sprintf(buf, "edgeaa %s", use_edgeaa ? "on" : "off");
			DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 32, FGCOLOR, buf);
		}
	
		if (joystick & JOY_R)
		{
			sprintf(buf, "mipmap %s", use_mipmap ? "on" : "off");
			DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 32, FGCOLOR, buf);
		}
	
		if (joystick & JOY_L)
		{
			sprintf(buf, "cubes: %3d", numcubes);
			DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 32, FGCOLOR, buf);
		}
	
		if (joystick & JOY_B)
		{
			sprintf(buf, "bilerp %s", use_bilerp ? "on" : "off");
			DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 32, FGCOLOR, buf);
		}
	
		if (joystick & (JOY_Z))
		{
			/* debugging info */
			sprintf(buf, "%5d polys", numpolys);
			DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 48, FGCOLOR, buf);
	
			sprintf(buf, "%5d fps", fps);
			DebugWS(the_screen[drawBuffer].dmaFlags, the_screen[drawBuffer].memP, 32, 64, FGCOLOR, buf);
		}
	
		oldjoystick = joystick;
	
    }

    return 0;
}
