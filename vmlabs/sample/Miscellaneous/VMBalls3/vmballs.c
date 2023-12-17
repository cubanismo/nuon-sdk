/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 */

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>

#include "vmballs.h"
#include "proto.h"

/******************************/

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;

int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

mmlAppPixmap		gl_spritedata;

char				msgbuf[400];

Ball_Position		*theCurrentBall;				// Working pointer into BallList[]
Ball_Position		BallList[MAX_NUMBALLS];	
int					BallCount = 50;

extern long 		background[];

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

static void create_balls(Ball_Position *pos);

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

int ParseControllerInput(int c)
{
static int inputdelay = 0;

	if( inputdelay )
	{
		inputdelay--;	// Debounce period
	}
	else
	{
		if( ButtonCUp(_Controller[1]) )
		{
			c++;
			if( c > MAX_NUMBALLS )
				c = MAX_NUMBALLS;
	
			inputdelay = INPUTDELAY_PERIOD;
		}
		else if (ButtonCDown(_Controller[1]) )
		{
			c--;
			if( c < 0 )
				c = 0;
        
			inputdelay = INPUTDELAY_PERIOD;
		}
		else if( ButtonR(_Controller[1]) )
		{
			c += 10;
			if( c > MAX_NUMBALLS )
				c = MAX_NUMBALLS;
	
			inputdelay = INPUTDELAY_PERIOD;
		}
		else if (ButtonL(_Controller[1]) )
		{
			c -= 10;
			if( c < 0 )
				c = 0;
	
			inputdelay = INPUTDELAY_PERIOD;
		}
	}

	return c;
}


void draw_balls(int stepcount)
{
int i, ii, x, y;

	theCurrentBall = BallList;

	for (i = 0; i < BallCount; i++, theCurrentBall++)
	{
		x = theCurrentBall->x;
		y = theCurrentBall->y;

		/* Increment positions once for each field that went by in last loop */
		for( ii = 0; ii < stepcount; ii ++ )
		{
			/* detect reflection */
			x += theCurrentBall->dx;
			y += theCurrentBall->dy;

			if( x > WALL_RIGHT || x < BOUNDARY )
				theCurrentBall->dx = -(theCurrentBall->dx);

			if( y > WALL_BOTTOM || y < BOUNDARY )
				theCurrentBall->dy = -(theCurrentBall->dy);	
		}

		theCurrentBall->x = x;
		theCurrentBall->y = y;

		/* Draw something at X,Y */
		plot_object( theCurrentBall );
	}
}



int main(void)
{
int	frametimer;

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	/* Create a sprite! */
	mmlInitAppPixmaps( &gl_spritedata, &gl_sysRes, SPRITE_WIDTH, SPRITE_HEIGHT, e888Alpha, 1, spritedata );

	/* set initial geometries */
	create_balls(BallList);


	/* set initial output string & other things */
	msgbuf[0] = 0;

	/* Start off vblank synchronization */
	Vblanksync(0);
	frametimer = 1;

	/* Draw screen & do stuff */
	while(1)
	{
		// Draw background image
		draw_picture(background,0,0,SCREENWIDTH,SCREENHEIGHT,SCREENWIDTH,SCREENHEIGHT);

		// Process joystick input!
		BallCount = ParseControllerInput(BallCount);

		// draw the list of objects!
		draw_balls(frametimer);

		// Request screen swap at next VBLANK
		swap_screenbuffers();

		// How long did this frame take?  (Used to increment ball position)
		frametimer = Vblanksync(-2);

		// Wait for buffer swap to take place before we loop
		Vblanksync(0);
	}


/* Release allocated memory */

	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[0], &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[1], &gl_sysRes, 1 );

/* and exit! */

	return 0;
}

/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

int Vblanksync(int count)
{
static int vbsync_startfield = 0;

	/* If count is positive, then we'll wait for either the next VBLANK, */
	/* or for the n'th VBLANK since the last one we waited for. */

	if( count >= 0 )
	{
		/* Wait for next field to start, then exit */
		if( count == 0 )
		{
			/* Get field of starting position... */
			vbsync_startfield = _VidSync(-1);
	
			while(_VidSync(-1) == vbsync_startfield );
			return(_VidSync(-1));
		}

		/* Wait for specified number of vblanks since last Vblanksync(-1) or Vblanksync(n>=0) */
		else
		{
			while(_VidSync(-1) < (vbsync_startfield+count) );

			/* Before we leave, get current count */
			vbsync_startfield = _VidSync(-1);

			return(_VidSync(-1));
		}

	}

	/* if count == -1, then return the current field counter value */

	else if( count == -1 )
	{
		/* Return current field */
		return(_VidSync(-1));
	}

	/* If count == -2, then return the number of fields since the last */
	/* time we waited for synchronization */

	else if( count == -2 )
	{
		/* return # fields since last sync */
		return(_VidSync(-1) - vbsync_startfield );
	}
	return(-1);
}


/***************************************************************************/
/* Initialize ball objects                                                 */
/***************************************************************************/
/* To do: Change position & velocity to 16.16 values to allow fractional   */
/* velocity and directions.                                                */
/***************************************************************************/

static void create_balls(Ball_Position *theBall)
{
int	i;

	for (i = 0; i < MAX_NUMBALLS; i++)
	{
		theBall->x  = BOUNDARY + (rand() % (SCREENWIDTH-(BOUNDARY*2)));
		theBall->y  = BOUNDARY + (rand() % (SCREENHEIGHT-(BOUNDARY*2)));

		theBall->dx = (rand() % MAX_OBJECT_SPEED) + 1;
        if( rand() & 0x0001 )
			theBall->dx = -theBall->dx;

		theBall->dy = (rand() % MAX_OBJECT_SPEED) + 1;
        if( rand() & 0x0001 )
			theBall->dy = -theBall->dy;

		theBall++;
	}
}
