/*
 * Copyright (c) 2001, VM Labs, Inc., All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 */

#include "vmballs.h"
#include "proto.h"

/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;

int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

mmlAppPixmap		gl_spritedata;

Ball_Position		*theCurrentBall;				// Working pointer into BallList[]
Ball_Position		BallList[MAX_NUMBALLS];	
int					BallCount = START_NUMBALLS;

extern long 		background[];
extern long			spritedata[];

mmlDisplayPixmap	theSpriteImage;

SPR_IMAGE_INFO		theSpriteData;

/***************************************************************************/
/* Initialize ball objects                                                 */
/***************************************************************************/
/* To do: Change position & velocity to 16.16 values to allow fractional   */
/* velocity and directions.                                                */
/***************************************************************************/

static void create_balls(Ball_Position *theBall)
{
int	spritenum;

	for (spritenum = 0; spritenum < BallCount; spritenum++)
	{
		theBall->x  = BOUNDARY + (rand() % (SCREENWIDTH-(BOUNDARY*2)));
		theBall->y  = BOUNDARY + (rand() % (SCREENHEIGHT-(BOUNDARY*2)));

		theBall->dx = (rand() % MAX_OBJECT_SPEED) + 1;
		if( rand() & 0x0001 )
			theBall->dx = -theBall->dx;

		theBall->dy = (rand() % MAX_OBJECT_SPEED) + 1;
		if( rand() & 0x0001 )
			theBall->dy = -theBall->dy;

		theBall->rotation = 0;
		theBall->rotation_speed = ((0x10000) / 360) * (rand() % MAX_OBJECT_ROTATION);

		theBall->scale = 0x10000;
		
		theBall->scale_speed = (rand() % 0x2000);
		if( rand() & 0x0001 )
			theBall->scale_speed = -(theBall->scale_speed);

		theBall->sprite = SPRCreateSprite( &theSpriteData, 0, 0, SPRITE_WIDTH, SPRITE_HEIGHT );

		// Add to display list
		SPRAddSprite( theBall->sprite,
					  theBall->x, theBall->y,
					  theBall->rotation,
					  theBall->scale, theBall->scale, 
					  kSpriteSimpleTrans,
					  0x108080ff, 	// Transparent color = black w/alpha of 0xff
					  spritenum );
		theBall++;
	}
}

void draw_balls(int stepcount)
{
int spritenum, ii, x, y;

	theCurrentBall = BallList;

	for (spritenum = 0; spritenum < BallCount; spritenum++, theCurrentBall++)
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

			// Increment rotation of sprite
			theCurrentBall->rotation += theCurrentBall->rotation_speed;

			// Increment scale
			theCurrentBall->scale += theCurrentBall->scale_speed;

			if( theCurrentBall->scale < MIN_SPRITE_SCALE )
			{
				theCurrentBall->scale = MIN_SPRITE_SCALE;
				theCurrentBall->scale_speed = -(theCurrentBall->scale_speed);
			}

			if( theCurrentBall->scale > MAX_SPRITE_SCALE )
			{
				theCurrentBall->scale = MAX_SPRITE_SCALE;
				theCurrentBall->scale_speed = -(theCurrentBall->scale_speed);
			}         
		}

		theCurrentBall->x = x;
		theCurrentBall->y = y;

		// Update sprite position & rotation
		SPRSetSpriteXY( theCurrentBall->sprite, theCurrentBall->x, theCurrentBall->y );
		SPRSetSpriteRotation( theCurrentBall->sprite, theCurrentBall->rotation ); 
		SPRSetSpriteScale( theCurrentBall->sprite, theCurrentBall->scale, theCurrentBall->scale );
	}
}

/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

int main(void)
{
int	frametimer;

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

    /* Use MPEs 0,1 and 2 for rendering, 16 pixel slices */   
    SPRInit(0,2,16);

	// Create a pixmap to describe our sprite image
	mmlInitDisplayPixmaps( &theSpriteImage, &gl_sysRes, SPRITE_WIDTH, SPRITE_HEIGHT, e888Alpha, 1, NULL );

	// Copy sprite image to DMA format in SDRAM
	copy_sprite_to_sdram( spritedata, &theSpriteImage );

	// Create a sprite image
	SPRSetSourceImage( theSpriteImage.memP, theSpriteImage.dmaFlags, 
					   theSpriteImage.wide, theSpriteImage.wide, 
					   &theSpriteData );

	// Initialize the list of balls
	create_balls(BallList);

	/* Start off vblank synchronization */
	Vblanksync(0);
	frametimer = 1;

	/* Draw screen & do stuff */
	while(1)
	{
		// Draw background image
		draw_picture(background,0,0,SCREENWIDTH,SCREENHEIGHT,SCREENWIDTH,SCREENHEIGHT);

		// Set sprite library to point at the rendering framebuffer
		SPRSetDestScreen(gl_screenbuffers[gl_drawbuffer].memP, 
						 gl_screenbuffers[gl_drawbuffer].dmaFlags,  
						 0,  0,  SCREENWIDTH-1,  SCREENHEIGHT-1, 
						 kBlack);

		// Update list of objects!
		draw_balls(frametimer);

		// Draw the sprites
		SPRDraw( 0, 1 );

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


