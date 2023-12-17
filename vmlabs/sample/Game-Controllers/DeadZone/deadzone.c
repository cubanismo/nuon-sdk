/*
 * Deadzone - Shows how to implement a center "dead zone" for
 * analog joystick controllers.
 *
 * 
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdarg.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>
#include <nuon/bios.h>
#include <nuon/mml2d.h>

////////////////////////////////////////////////////////////////////////////
// defaults for things
////////////////////////////////////////////////////////////////////////////

#define SCREENWIDTH			(392)
#define SCREENHEIGHT 		(240)

#define LEFT_MARGIN			(40)

#define JOY_DEAD_X			(16)
#define JOY_DEAD_Y			(16)

#define BACKGROUNDCOLOR 	(0x60808000)  /* darkish grey */
#define BALLCOLOR 			(0xc0ff0000)
#define TEXTCOLOR 			kYellow

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

mmlGC						gl_gc;
mmlSysResources 			gl_sysRes;
int							gl_displaybuffer;	// index into gl_screenbuffers[] array
int							gl_drawbuffer;
mmlDisplayPixmap			gl_screenbuffers[2];

////////////////////////////////////////////////////////////////////////////
// Swap draw and display buffers.  Takes effect next VBLANK
////////////////////////////////////////////////////////////////////////////

void swap_screenbuffers()
{
int tmp;

	tmp = gl_displaybuffer;
	gl_displaybuffer = gl_drawbuffer;
	gl_drawbuffer = tmp;
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
// Initialize the draw/display buffers, clear the memory, put one up!
////////////////////////////////////////////////////////////////////////////

void init_screenbuffers()
{
	// Initialize index values for gl_screenbuffers[] array
	gl_displaybuffer = 0;
	gl_drawbuffer = 1;

	// Create each buffer

	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_displaybuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_drawbuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );

	// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
// Erase the screen by drawing 8x8 rectangle blocks; 
// Not perfectly efficient, but pretty good
////////////////////////////////////////////////////////////////////////////

void ClearScreen(mmlDisplayPixmap *scrn)
{
long x, y;

    for (x = 0; x < scrn->wide; x += 8)
	{
		for (y = 0; y < scrn->high; y += 8)
		{
			_DMABiLinear(scrn->dmaFlags|DMA_DIRECT_BIT, scrn->memP, (8<<16)|x, (8<<16)|y, (void *)BACKGROUNDCOLOR);
		}
    }
}

////////////////////////////////////////////////////////////////////////////
// Draw a simple sprite (just a colored square) at the designated location.
////////////////////////////////////////////////////////////////////////////

#define SPRITE_WIDTH 4
#define SPRITE_HEIGHT 4

/*
 * draws a sprite centered at (xpos, ypos)
 * assumes that higher level code has already checked for
 * bounding conditions
 */
void DrawSprite(mmlDisplayPixmap *scrn, int xpos, int ypos)
{
    xpos -= SPRITE_WIDTH/2;
    ypos -= SPRITE_WIDTH/2;

    _DMABiLinear( scrn->dmaFlags|DMA_DIRECT_BIT, scrn->memP, (SPRITE_WIDTH<<16)|xpos, (SPRITE_HEIGHT<<16)|ypos, (void *)BALLCOLOR);
}

////////////////////////////////////////////////////////////////////////////
// This takes the raw joystick values and adjusts them to create a
// deadzone in the center.
////////////////////////////////////////////////////////////////////////////

void adjust_for_joystick_deadzone( int x_deadzone, int y_deadzone, int *joy_x, int *joy_y )
{
register int x, y;

	x = *joy_x;
	y = *joy_y;

	if( x > 0  && x < x_deadzone )
		x = 0;
	else if( x > 0 )
		x -= x_deadzone;

	if( x < 0 && x > (-x_deadzone) )
		x = 0;
	else if( x < 0 )
		x += x_deadzone;

	if( y > 0 && y < y_deadzone )
		y = 0;
	else if( y > 0 )
		y -= y_deadzone;

	if( y < 0 && y > (-y_deadzone) )
		y = 0;
	else if( y < 0 )
		y += y_deadzone;

	*joy_x = x;
	*joy_y = y;
}

////////////////////////////////////////////////////////////////////////////
// 
////////////////////////////////////////////////////////////////////////////

int main(void)
{
int deltax, deltay, xpos, ypos;
int minx, miny, maxx, maxy;
int has_analogstick;
char buf[SPRINTF_MAX];
mmlDisplayPixmap *theScreen;


	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );	

	// Point the video hardware at the display buffer
	init_screenbuffers();
	theScreen = &gl_screenbuffers[gl_drawbuffer];
	ClearScreen(theScreen);

    xpos = SCREENWIDTH/2;
    ypos = SCREENHEIGHT/2;
    minx = 16;
    miny = 16;
    maxx = SCREENWIDTH - (minx+1);
    maxy = SCREENHEIGHT - (miny+1);

	for(;;)
	{
		// Set up screen pointer
		theScreen = &gl_screenbuffers[gl_drawbuffer];
		ClearScreen(theScreen);
		
		msprintf(buf, "Buttons: %08x", _Controller[1].buttons );
		DebugWS(theScreen->dmaFlags, theScreen->memP, LEFT_MARGIN, 30, TEXTCOLOR, buf);
		
		/* update position based on analog joystick values */
		/* these are signed 8 bit values */
		has_analogstick = _Controller[1].properties & CTRLR_ANALOG1;

		if( has_analogstick )
		{
			deltax = JoyXAxis(_Controller[1]);
			deltay = JoyYAxis(_Controller[1]);
	
			// We want "y" to increase to the bottom of the screen
			deltay = -deltay;

			adjust_for_joystick_deadzone( JOY_DEAD_X, JOY_DEAD_Y, &deltax, &deltay );
			
			// Scale back the joystick values to create a delta, then update position
			xpos += deltax / 4;
			ypos += deltay / 4;
		
			// Make sure sprite is still on screen
			// Wrap around to other side when hit boundary
			if (xpos < minx)
				xpos = maxx;
			else if (xpos > maxx)
				xpos = minx;
		
			if (ypos < miny)
				ypos = maxy;
			else if (ypos > maxy)
				ypos = miny;
		
			/* update sprite */
			DrawSprite(theScreen, xpos, ypos);

			msprintf( buf, "X: %d", deltax );
			DebugWS(theScreen->dmaFlags, theScreen->memP, LEFT_MARGIN, 45, TEXTCOLOR, buf);
			msprintf( buf, "Y: %d", deltay );
			DebugWS(theScreen->dmaFlags, theScreen->memP, LEFT_MARGIN, 60, TEXTCOLOR, buf);
	
			DebugWS(theScreen->dmaFlags, theScreen->memP, LEFT_MARGIN, 160, TEXTCOLOR, "This program implements a deadzone" );
			DebugWS(theScreen->dmaFlags, theScreen->memP, LEFT_MARGIN, 175, TEXTCOLOR, "for the analog joystick in order to" );
			DebugWS(theScreen->dmaFlags, theScreen->memP, LEFT_MARGIN, 190, TEXTCOLOR, "ignore tiny movements or slightly" );
			DebugWS(theScreen->dmaFlags, theScreen->memP, LEFT_MARGIN, 205, TEXTCOLOR, "uncentered positions." );
		}
		else
		{
			DebugWS(theScreen->dmaFlags, theScreen->memP, LEFT_MARGIN, 100, TEXTCOLOR, "No analog joystick detected" );
		}
	
		swap_screenbuffers();
		_VidSync(0);
	}

    return 0;
}

