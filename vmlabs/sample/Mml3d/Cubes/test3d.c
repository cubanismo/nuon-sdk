/*
 * Sample C code for invoking the 3D rendering
 * pipeline.
 *
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission 
 */

#include <stdio.h>
#include <stdarg.h>
#include <math.h>
#include <stdlib.h>

#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>
#include <nuon/bios.h>
#include <nuon/m3d.h>

#define BPP 16

#if BPP == 16
#define PIXEL_TYPE e655Z
#else
#define PIXEL_TYPE e888AlphaZ
#endif

#define SCRNWIDTH 360
#define SCRNHEIGHT 240

#define MAXCUBES 20
#define SCALE 256

struct cube {
    m3dreal pos[3];
    m3dreal angle[3];
    m3dreal vel[3];
    m3dreal anglevel[3];
} cube[MAXCUBES];



/* do double or triple buffering based on the
 * size of memory needed
 */
#if (BPP != 16) || (SCRNWIDTH == 720)
#define NUM_BUFFERS 2
#else
/* there's enough memory to triple buffer */
#define NUM_BUFFERS 3
#endif

/*
 * This creates one face of a model,
 * by drawing two triangles perpendicular
 * to the normal vector. The vertices of
 * the triangles must be oriented CLOCKWISE
 * in the right handed coordinate system with
 * x increasing the the right of the screen,
 * y increasing towards the bottom of the screen,
 * and z increasing into the screen;
 * the normal vector should point away from
 * the polygon towards the viewer when the polygon
 * is visible
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
	m3dStartTriangle(buf);
	m3dAddNormal3f(buf, nx, ny, nz);
	m3dAddTextureCoords2f(buf, 0.0, 0.0);
	m3dAddVertex3f(buf, x, y, z);
	m3dAddTextureCoords2f(buf, 1.0, 0.0);
	m3dAddVertex3f(buf, x + 2*ax, y + 2*ay, z + 2*az);
	m3dAddTextureCoords2f(buf, 0.0, 1.0);
	m3dAddVertex3f(buf, x + 2*bx, y + 2*by, z + 2*bz);
	m3dEndTriangle(buf);

	m3dStartTriangle(buf);
	m3dAddNormal3f(buf, nx, ny, nz);
	m3dAddTextureCoords2f(buf, 1.0, 1.0);
	m3dAddVertex3f(buf, x + 2*(ax+bx), y + 2*(ay+by), z + 2*(az+bz));
	m3dAddTextureCoords2f(buf, 0.0, 1.0);
	m3dAddVertex3f(buf, x + 2*bx, y + 2*by, z + 2*bz);
	m3dAddTextureCoords2f(buf, 1.0, 0.0);
	m3dAddVertex3f(buf, x + 2*ax, y + 2*ay, z + 2*az);
	m3dEndTriangle(buf);
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


/*
 * make a model of a cube
 * return the number of polygons in the model
 */

m3dMaterial *face1, *face2, *face3;
m3dMaterial red, blue, green;

int
MakeModel(mmlSysResources *sr, m3dBuf *buf)
{
    m3dInitMaterialFromColor(&red, mmlColorFromRGB(200, 0, 0));
    m3dInitMaterialFromColor(&blue, mmlColorFromRGB(0, 0, 200));
    m3dInitMaterialFromColor(&green, mmlColorFromRGB(0, 200, 0));

    face1 = &green;
    face2 = &red;
    face3 = &blue;

    m3dInitBuf(buf);

    m3dSetMaterial(buf, face3);
    face(buf, 1.0, 0.0, 0.0);
    face(buf, -1.0, 0.0, 0.0);

    m3dSetMaterial(buf, face2);
    face(buf, 0.0, 1.0, 0.0);
    face(buf, 0.0, -1.0, 0.0);

    m3dSetMaterial(buf, face1);
    face(buf, 0.0, 0.0, 1.0);
    face(buf, 0.0, 0.0, -1.0);

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
    /* create the matrix using the euler angles
       in the cube structure */
     m3dEulerMatrix(M, C->angle[0], C->angle[1], C->angle[2]);
    /* now position the matrix */
    m3dPlaceMatrix(M, C->pos[0], C->pos[1], C->pos[2]);
}

/* variable to keep track of frames per second */
static int fps;

/* the output screens (up to three, for triple buffering) */
mmlDisplayPixmap the_screen[3];
int drawBuffer = 0;  /* which screen is selected */

/* system resources */
mmlSysResources sysRes;

/* drawing matrix */
m3dMatrix test_model_matrix;

/*
 * wait for a frame to be drawn
 */

int
VideoSync(void)
{
static int frames;
static int lastfield;
static int lastsecond;
int curfield;

    /* we want to view the buffer we just finished drawing */

    /* set the video to point at the drawn buffer */
    mmlSimpleVideoSetup(&the_screen[drawBuffer], &sysRes, eNoVideoFilter);

    /* remember that we've drawn a frame */
    frames++;

    /* find out how many fields have been drawn */
    curfield = _VidSync(-1);

    /* have more than 60 fields (1 second) passed? */
    if (curfield - lastsecond >= 60)
	{
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
    do
	{
		curfield = _VidSync(-1) - lastfield;
    }
	while (curfield == 0);
#endif

    lastfield = _VidSync(-1);
    return curfield;
}

int
main(int argc, char **argv)
{
    mmlGC gc;
    int frames;
    m3dBuf test_model;
    m3dLightData the_lights;
    m3dCamera the_camera;
    int i;
    long joystick;
    long oldjoystick;
    long edge;
    int numcubes;
    int use_edgeaa;
    mmlColor bgcolor;
    mmlColor fgcolor;
    m2dRect drawRect;

    /* Initialize the system resources and graphics context to a default state. */
    mmlPowerUpGraphics( &sysRes );
    mmlInitGC( &gc, &sysRes );
    m3dInit(&sysRes, 4);

	/* initialize display */
    mmlInitDisplayPixmaps( the_screen, &sysRes, SCRNWIDTH, SCRNHEIGHT, PIXEL_TYPE, NUM_BUFFERS, NULL);

    /* set up the foreground and background colors */
    bgcolor = mmlColorFromRGB(128, 128, 128);
    fgcolor = mmlColorFromRGB(240, 80, 80);

    /* set up the drawing rectangle */
    m2dSetRect(&drawRect, 0, 0, SCRNWIDTH-1, SCRNHEIGHT-1);

	/* make the model we're going to use */
    MakeModel(&sysRes, &test_model);

    /* set up the lighting model */
    m3dInitLights(&the_lights, M3DF(0.2));
    m3dAddDirectionalLight(&the_lights, M3DF(0.40824829), M3DF(0.408424829),
			   M3DF(0.81649658), M3DF(0.7));

    /* initialize the camera */
    m3dInitCamera(&the_camera, M3DF(1.0), M3DI(10000));

    /* set up max & min positions for the cubes */
    /* X */
    MinPos[0] = M3DI(-8*SCALE); MaxPos[0] = M3DI(8*SCALE);
    /* Y */
    MinPos[1] = M3DI(-8*SCALE); MaxPos[1] = M3DI(8*SCALE);
    /* Z */
    MinPos[2] =  M3DI(8*SCALE); MaxPos[2] = M3DI(30*SCALE);

    /* miscellaneous setup */
    numcubes = 10;   /* start with this many cubes */
    use_edgeaa = 0;

    oldjoystick = _Controller[1].buttons;

reinit:
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

    /* initialize the rest of the cubes */
    for (i = 1; i < MAXCUBES; i++)
	{
		InitCube(&cube[i]);
    }

    /***************************************************
      The main loop
     ***************************************************/

    for(;;)
	{
	long zstep, xstep;
	
		/* wait for video synchronization */
		frames = VideoSync();
	
		/* clear the screen */
		m2dFillColr(&gc, &the_screen[drawBuffer], NULL, bgcolor);
	
		/* figure out hints for rendering */
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
		}
	
		/* finish rendering */
		m3dEndScene(&gc, &the_screen[drawBuffer], &drawRect);
	
		/* check joystick */
		joystick = _Controller[1].buttons;
	
		/* figure out which buttons have just been pushed */
		edge = (joystick ^ oldjoystick) & joystick;
	
		/* then move user controlled cube */
		xstep = JoyXAxis(_Controller[1]) & ~0xf;
		zstep = JoyYAxis(_Controller[1]) & ~0xf;
	
		cube[0].pos[0] += frames * SCALE * (xstep << 6);
		cube[0].pos[2] += frames * SCALE * (zstep << 6);
	
#define STEP (SCALE*(1<<12))
	
		if (ButtonUp(_Controller[1]))
		{
			cube[0].pos[1] -= frames * STEP;
		}
		else if (ButtonDown(_Controller[1]))
		{
			cube[0].pos[1] += frames * STEP;
		}
	
		if (ButtonLeft(_Controller[1]))
		{
			cube[0].pos[0] -= frames * STEP;
		}
		else if (ButtonRight(_Controller[1]))
		{
			cube[0].pos[0] += frames * STEP;
		}
	
		if (ButtonCUp(_Controller[1]))
		{
			cube[0].angle[0] -= frames * DEGREE;
		}
		else if (ButtonCDown(_Controller[1]))
		{
			cube[0].angle[0] += frames * DEGREE;
		}
	
		if (ButtonCLeft(_Controller[1]))
		{
			cube[0].angle[1] -= frames * DEGREE;
		}
		else if (ButtonCRight(_Controller[1]))
		{
			cube[0].angle[1] += frames * DEGREE;
		}
	
		if (ButtonL(_Controller[1]))
		{
			if (numcubes < MAXCUBES)
			numcubes++;
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
	
		oldjoystick = joystick;
    }

    return 0;
}
