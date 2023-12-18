/*
 * Copyright (c) 2000 VM Labs, Inc.
 * All rights reserved.
 *
 * Confidential and Proprietary Information of VM Labs, Inc.
 */

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#include "vidoverlay.h"

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void ClearScreen(mmlDisplayPixmap *scrn, mmlColor clr)
{
long x, y;

    for (x = 0; x < scrn->wide; x += 8)
	{
		for (y = 0; y < scrn->high; y += 8)
		{
			_raw_plotpixel(scrn->dmaFlags, scrn->memP, (8<<16)|x, (8<<16)|y, clr);
		}
    }
}

void ClearLines(mmlDisplayPixmap *scrn, mmlColor clr, int y_start, int y_end)
{
long x, y;

    for (x = 0; x < scrn->wide; x += 8)
	{
		for (y = y_start; y < y_end; y++ )
		{
			_raw_plotpixel(scrn->dmaFlags, scrn->memP, (8<<16)|x, (1<<16)|y, clr);
		}
    }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

static int redraw_text = 1;

void test_controller(void)
{
int i;

	// If button "A" is pressed on any controller, including
	// the IR remote, then set flag to redraw the text

	for( i = 0; i <= 8; i++ )
	{
		if( ButtonA(_Controller[i]) )
		{
			redraw_text = 1;
			break;
		}
	}
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int draw_alpha_text( mmlDisplayPixmap *ovl, int x, int y, mmlColor clr )
{
	DebugWS(ovl->dmaFlags,ovl->memP, x, y, clr, "Text uses 32-bit overlay channel." );
	
	y += 16;
	DebugWS(ovl->dmaFlags,ovl->memP, x, y, clr, "This does a fade out by reprinting " );
	
	y += 16;
	DebugWS(ovl->dmaFlags,ovl->memP, x, y, clr, "the text with different alpha " );
	
	y += 16;
	DebugWS(ovl->dmaFlags,ovl->memP, x, y, clr, "channel values " );
	
	return y;
}

void create_display(mmlDisplayPixmap *draw, mmlDisplayPixmap *ovl)
{
int text_x, text_y;
mmlColor fade_text_color;
static int fade_text;

	// Clear the screen
	ClearScreen( draw, MAIN_BACKGROUND );

	// Draw some lines
	m2dInitLineStyle( &gl_gc, &gl_gc.defaultLS, mmlColorFromRGB(255,0,0), (linewidths ? 2 : 1), 0, eLine1 );	
	m2dDraw2DLine( &gl_gc, draw, 0, 0, screenwidth, screenheight );
	m2dDraw2DLine( &gl_gc, draw, screenwidth, 0, 0, screenheight );
	
	m2dInitLineStyle( &gl_gc, &gl_gc.defaultLS, mmlColorFromRGB(0,255,0), (linewidths ? 5 : 1), 0, eLine1 );	
	m2dDraw2DLine( &gl_gc, draw, (screenwidth/2), 0, (screenwidth/2), screenheight );
	
	m2dInitLineStyle( &gl_gc, &gl_gc.defaultLS, mmlColorFromRGB(0,0,255), (linewidths ? 5 : 1), 0, eLine1 );	
	m2dDraw2DLine( &gl_gc, draw, 0, (screenheight/2), screenwidth, (screenheight/2) );

	if( redraw_text )
	{
		redraw_text = 0;
		fade_text = 255;
		fade_text_color = OVERLAY_TEXTCOLOR;

		text_x = 70;
		text_y = 30;
        DebugWS( ovl->dmaFlags, ovl->memP, text_x, text_y, kCyan, "Overlay video channel demo" );
		
		text_x = 30;
		text_y = 100;
		draw_alpha_text( ovl, text_x, text_y, fade_text_color );
	}

	////////////////////////////////////////////////////////////////////////
	// Since it's pretty easy, we do a neato-keen text fade out using the alpha channel
	////////////////////////////////////////////////////////////////////////

	if( fade_text )
	{
		fade_text -= 2;
		if( fade_text < 0 )
			fade_text = 0;
		
		if( fade_text )
		{
			fade_text_color = (OVERLAY_TEXTCOLOR & 0xffffff00) | (255 - fade_text);
	
			text_x = 30;
			text_y = 100;
			draw_alpha_text( ovl, text_x, text_y, fade_text_color );
		}
		else
		{
			ClearLines(ovl, OVERLAY_BACKGROUND, 100, 190 );
		}
	}
}

