/*
 * Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 * Written by Mike Fulton
 *
 * Program to draw a YCrCb colorspace square
 */

#include <nuon/mml2d.h>
#include <nuon/dma.h>
#include <nuon/bios.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>
#include <stdio.h>

#define YSTART			(25)	// Y-pos of top of color square

#define X_TEXT1			(55)	// X-pos of "Y" value display
#define Y_TEXT1_TOP		(25)	// Y-pos of top of "Y" value display area
#define Y_TEXT1_BOTTOM	(70)	// Y-pos of bottom of "Y" value display area
    
#define Y_MIN			(16)	// Minimum LUMA (Y) value
#define Y_MAX			(235)	// Maximum LUMA (Y) value

#define	SCREENWIDTH		(720)
#define SCREENHEIGHT	(310)



mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;


void text_background(mmlGC *gcP, mmlDisplayPixmap *screen)
{
mmlColor clr;
int yy, y;

	clr = mmlColorFromRGB( 40, 40, 40 );
	for( y = Y_TEXT1_BOTTOM; y >= YSTART; y-- )
	{
		yy = (y * 255) / SCREENHEIGHT;

		clr = mmlColorFromRGB( yy, yy, yy );
		_raw_plotpixel( screen->dmaFlags, screen->memP, X_TEXT1|(40<<16), y|(1<<16), clr );
	}
}



void fill_background(mmlGC *gcP, mmlDisplayPixmap *screen)
{
mmlColor clr;
int x, y, w, yy;

	for( y = SCREENHEIGHT; y >= 0; y-- )
	{
		yy = (y * 255) / SCREENHEIGHT;

		clr = mmlColorFromRGB( yy, yy, yy );

		for( x = 0; x < SCREENWIDTH; x+= 60 )
		{
			w = (SCREENWIDTH - x) > 60 ? 60 : (SCREENWIDTH - x);
            
            _raw_plotpixel( screen->dmaFlags, screen->memP, x|(w<<16), y|(1<<16), clr );
		}
	}
}


int main( )
{
mmlAppPixmap source, clutSource;
int xx, yy;
int cr, cb, y;
mmlColor ycrcb;
char buf[800];
static unsigned char clr = 0;
int	auto_change = 1;
int redraw = 0;

// Initialize the system resources and graphics context to a default state.
	mmlPowerUpGraphics( &gl_sysRes );
	mmlInitGC( &gl_gc, &gl_sysRes );

	// Initialize a single display pixmap as a framebuffer
	// 720 pixels wide by 480 lines tall, using 32 bit YCC-alpha pixels.
	mmlInitDisplayPixmaps( &gl_screen, &gl_sysRes, 720, 300, e888Alpha, 1, 0L );

	// show the sample pixmap
	mmlSimpleVideoSetup(&gl_screen, &gl_sysRes, eTwoTapVideoFilter);

	// Set all the pixels in the display pixmap
	fill_background(&gl_gc, &gl_screen);

	_DeviceDetect(1);

	y = 80;

	while(1)
	{
		if( redraw )
		{	
			// Redraw the portion of the background where our text goes
			text_background(&gl_gc, &gl_screen);
			
			msprintf(buf, "%d", y );
			
			DebugWS(gl_screen.dmaFlags, gl_screen.memP, X_TEXT1 + 5, Y_TEXT1_TOP + 10, 0x80800000|(clr++<<8), buf );
			
			if( auto_change )
				DebugWS(gl_screen.dmaFlags, gl_screen.memP, X_TEXT1 + 5, Y_TEXT1_TOP + 25, 0x80800000|(clr++<<8), "auto" );
			
			DebugWS(gl_screen.dmaFlags, gl_screen.memP, (SCREENWIDTH/2)-(31*8/2), YSTART + (240-16) + 0, 0x00800000, "Press Start To Toggle AUTO mode" );
			DebugWS(gl_screen.dmaFlags, gl_screen.memP, (SCREENWIDTH/2)-(42*8/2), YSTART + (240-16) + 15, 0x00800000, "Use D-PAD UP or DOWN to change brightness" );
	
			for( cr = 16; cr < 240; cr++ )
			{
				xx = (50 + cr) * 2;
	
				for( cb = 16; cb < 240; cb++ )
				{
					yy = YSTART + cb - 16;
	
					ycrcb = mmlColorFromYCC( y, cr, cb );
					_raw_plotpixel( gl_screen.dmaFlags, gl_screen.memP, (xx)|(2<<16), (yy)|(1<<16), ycrcb );
				}
			}

			redraw = 0;
		}

		if( ! auto_change )
		{
			if( ButtonUp( _Controller[1] ) )
			{
				y++;
				if( y > Y_MAX )
					y = Y_MIN;
				
				redraw = 1;
			}
			else if( ButtonDown( _Controller[1] ) )
			{
				y--;
				if( y < Y_MIN )
					y = Y_MAX;
				
				redraw = 1;
			}
		}
		else
		{
			y++;
			if( y > Y_MAX )
				y = Y_MIN;
			
			redraw = 1;
		}

		if( ButtonStart( _Controller[1] ) )
		{
			auto_change = 1 - auto_change;

			// Wait for button to be released
			while(ButtonStart(_Controller[1]) );
		}

	}

	// Endless loop!
	while(1);

	// Release allocated memory

	mmlReleasePixmaps( (mmlPixmap*)&gl_screen, &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&source, &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&clutSource, &gl_sysRes, 1 );

	return 0;
}
