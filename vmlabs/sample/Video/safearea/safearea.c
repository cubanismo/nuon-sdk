/*
 * Copyright (c) 1995-1998, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 *
 * Written by Mike Fulton
 *
 * Program to determine safe area versus overscan area
 */

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <nuon/mml2d.h>

#include <nuon/bios.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>


/*
 * defaults for things
 */

#define SCREENWIDTH 		(720)
#define SCREENHEIGHT 		(480)
#define DMA_XFER_TYPE 		(4)

#define FGCOLOR 			(0xc0808000)		/* white */
#define FG2COLOR 			(0xa0808000)		/* white */
#define BGCOLOR 			(0x60808000)		/* grey */

#define TEXTSIZE			(40)

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

mmlGC               gl_gc;
mmlSysResources     gl_sysRes;
mmlDisplayPixmap    gl_screenbuffers[2];
int                 gl_drawbuffer, gl_displaybuffer;

mmlFontContext      gl_fc;
mmlFont             sysP;

extern uint8		SysFont[];

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int Vblanksync(int count);
void text( int x, int y, int height, mmlColor forecolor, mmlColor backcolor, char *buf );
void line(int x1, int y1, int x2, int y2);
void init_screenbuffers(void);
void swap_screenbuffers(void);

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


void fill_background(mmlGC *gcP, mmlDisplayPixmap *screen)
{
	mmlColor clr;
	int x, y;
	int yclr;

	for ( y = SCREENHEIGHT; y >= 0; y-- )
	{
		yclr = (y * 255) / SCREENHEIGHT;
		clr = mmlColorFromRGB( yclr, yclr, yclr );

		// In order to be BUS-friendly, we must avoid doing DMA of more than 64 long
		// words... so divide each scanline into chunks of 32 pixels

		x = 0;
		while ( x < SCREENWIDTH )
		{
			_raw_plotpixel( screen->dmaFlags, screen->memP, x|(60<<16), y|(1<<16), clr );
			x += 60;
		}
	}
}


int main( )
{
	mmlAppPixmap source, clutSource;
	char buf[300];
	int debounce_period;
	int box_x, box_y, box_w, box_h;
	int xpos, ypos;
	int center_x, center_y;

// Initialize the system resources and graphics context to a default state.
	mmlPowerUpGraphics( &gl_sysRes );
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	mmlInitFontContext( &gl_gc, &gl_sysRes, &gl_fc, 40000);
	sysP = mmlAddFont( gl_fc, "sysFont", eT2K, SysFont, 40000 );

// Initialize our variables!
	box_x = 20;
	box_y = 20;
	box_w = SCREENWIDTH - (20 + 20);
	box_h = SCREENHEIGHT - (20 + 20);

	center_x = SCREENWIDTH / 2;
	center_y = SCREENHEIGHT / 2;

	debounce_period = 0;

	while ( 1 )
	{
		// Set all the pixels in the display pixmap
		fill_background(&gl_gc, &gl_screenbuffers[gl_drawbuffer]);

		/* Initialize line buffer pointers for text display */

		if ( ButtonZ(_Controller[1] ) )
		{
			debounce_period = 10;
		}

		if ( ButtonA(_Controller[1]) )
		{
			if ( ButtonUp(_Controller[1] ) )
			{
				if ( ! debounce_period )
				{
					center_y -= 1;
					debounce_period = 1;
				}
			}

			if ( ButtonDown(_Controller[1] ) )
			{
				if ( ! debounce_period )
				{
					center_y += 1;
					debounce_period = 1;
				}
			}

			if ( ButtonLeft(_Controller[1] ) )
			{
				if ( ! debounce_period )
				{
					center_x -= 1;
					debounce_period = 1;
				}
			}

			if ( ButtonRight(_Controller[1] ) )
			{
				if ( ! debounce_period )
				{
					center_x += 1;
					debounce_period = 1;
				}
			}
		}
		else
		{
			if ( ButtonUp(_Controller[1] ) )
			{
				if ( ! debounce_period )
				{
					box_y -= 1;
					debounce_period = 1;
				}
			}

			if ( ButtonDown(_Controller[1] ) )
			{
				if ( ! debounce_period )
				{
					box_y += 1;
					debounce_period = 1;
				}
			}

			if ( ButtonLeft(_Controller[1] ) )
			{
				if ( ! debounce_period )
				{
					box_x -= 1;
					debounce_period = 1;
				}
			}

			if ( ButtonRight(_Controller[1] ) )
			{
				if ( ! debounce_period )
				{
					box_x += 1;
					debounce_period = 1;
				}
			}
		}

		if ( ButtonCUp(_Controller[1] ) )
		{
			if ( ! debounce_period )
			{
				box_h += 1;
				debounce_period = 1;
			}
		}

		if ( ButtonCDown(_Controller[1] ) )
		{
			if ( ! debounce_period )
			{
				box_h -= 1;
				debounce_period = 1;
			}
		}

		if ( ButtonCLeft(_Controller[1] ) )
		{
			if ( ! debounce_period )
			{
				box_w -= 1;
				debounce_period = 1;
			}
		}

		if ( ButtonCRight(_Controller[1] ) )
		{
			if ( ! debounce_period )
			{
				box_w += 1;
				debounce_period = 1;
			}
		}

		// Draw box around safe area
		m2dInitLineStyle(&gl_gc, &gl_gc.defaultLS, mmlColorFromRGB(255,0,0), 5, 0x8000, eLine3 );
		line( box_x, box_y, (box_x + box_w), box_y );
		line( (box_x + box_w), box_y, (box_x + box_w), (box_y + box_h) );
		line( (box_x + box_w), (box_y + box_h), box_x, (box_y + box_h) );
		line( box_x, (box_y + box_h), box_x, box_y );

		// Draw moveable CENTER lines
		m2dInitLineStyle(&gl_gc, &gl_gc.defaultLS, mmlColorFromRGB(0,255,0), 2, 0x8000, eLine3 );
		line( center_x, 0, center_x, SCREENHEIGHT );
		line( 0, center_y, SCREENWIDTH, center_y );

		// Draw fixed CENTER lines
		m2dInitLineStyle(&gl_gc, &gl_gc.defaultLS, mmlColorFromRGB(0,0,255), 2, 0x8000, eLine3 );
		line( (SCREENWIDTH / 2), 0, (SCREENWIDTH / 2), SCREENHEIGHT );
		line( 0, (SCREENHEIGHT / 2), SCREENWIDTH, (SCREENHEIGHT / 2) );

		xpos = box_x + 20;
		ypos = box_y + 20;

		// Draw some text
		sprintf(buf, "x = %d,  y = %d", box_x, box_y );
		text( xpos, ypos, TEXTSIZE, kBlue, kGray, buf );
		ypos += TEXTSIZE;

		sprintf(buf, "w = %d,  h: %d", box_w, box_h );
		text( xpos, ypos, TEXTSIZE, kBlue, kGray, buf );

		ypos = center_y + 10;
		sprintf(buf, "Center X,Y = (%d,%d)", center_x, center_y );
		text( xpos, ypos, TEXTSIZE, kBlue, kGray, buf );

		// Request screen swap at next VBLANK
		swap_screenbuffers();

		// Wait for buffer swap to take place before we loop
		_VidSync(0);

		if ( debounce_period )
			debounce_period--;
	}


// Release allocated memory

	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers, &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&source, &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&clutSource, &gl_sysRes, 1 );

	return 0;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void text( int x, int y, int height, mmlColor forecolor, mmlColor backcolor, char *buf )
{
	m2dRect r;

	m2dSetRect( &r, x, y, SCREENWIDTH, SCREENHEIGHT );

	mmlSetTextProperties( gl_fc, sysP, height, forecolor, backcolor, eBlend, 0, 0 );

	mmlSimpleDrawText( gl_fc,  &gl_screenbuffers[gl_drawbuffer], buf, strlen(buf), &r );
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void line(int x1, int y1, int x2, int y2)
{
	m2dDraw2DLine( &gl_gc, &gl_screenbuffers[gl_drawbuffer], x1, y1, x2, y2 );
}

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

// Create & clear each buffer

	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_displaybuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_drawbuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );

// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eNoVideoFilter ); // eTwoTapVideoFilter);
}

