
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
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
#include <string.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>

#include "controller.h"
#include "proto.h"

#define MAX_SLOT	(9)

/******************************/

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;

int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

mmlFontContext 		gl_fc;
mmlFont 			SansCondensedBoldP;

char				msgbuf[400];

extern long background[];

char gl_titlestr[] = "NUON Controller Dump";

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

typedef struct
{
	char	a[4];
	char	b[4];
	char	l[4];
	char	r[4];
	char	start[4];
	char	select[4];
	char	up[4];
	char	down[4];
	char	left[4];
	char	right[4];
	char	c_up[4];
	char	c_down[4];
	char	c_left[4];
	char	c_right[4];
	char	xaxis[8];
	char	yaxis[8];
	char	status[8];
	char	reset[4];
	char	properties[12];
	char	raw[12];
	char	remote_buttons[100];
} Controller_Status_Strings;

Controller_Status_Strings theControllerStatus[9];

void get_controller_data()
{
int i,ii, si;
char *c;

	for( i = 0; i < 9; i++ )
	{
		if( i > 0 )
			_DeviceDetect(i);

		// If no controller connected, then zero out all fields.
		// Not required, but it gives us a prettier display.
		if( _Controller[i].status == 0 )
		{
			_Controller[i].buttons = 0;
			_Controller[i].d1.xAxis = 0;
			_Controller[i].d2.yAxis = 0;
			_Controller[i].d3.xAxis2 = 0;
			_Controller[i].d4.yAxis2 = 0;
			_Controller[i].d5.quadjoyX = 0;
			_Controller[i].d6.quadjoyY = 0;         
		}

		msprintf( theControllerStatus[i].a, "%d", ButtonA(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].b, "%d", ButtonB(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].l, "%d", ButtonL(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].r, "%d", ButtonR(_Controller[i]) ? 1: 0 );

		msprintf( theControllerStatus[i].start, "%d", ButtonStart(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].select, "%d", ButtonZ(_Controller[i]) ? 1: 0 );

		msprintf( theControllerStatus[i].up, "%d", ButtonUp(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].down, "%d", ButtonDown(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].left, "%d", ButtonLeft(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].right, "%d", ButtonRight(_Controller[i]) ? 1: 0 );

		msprintf( theControllerStatus[i].c_up, "%d", ButtonCUp(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].c_down, "%d", ButtonCDown(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].c_left, "%d", ButtonCLeft(_Controller[i]) ? 1: 0 );
		msprintf( theControllerStatus[i].c_right, "%d", ButtonCRight(_Controller[i]) ? 1: 0 );

		msprintf( theControllerStatus[i].xaxis, "%d", _Controller[i].d1.xAxis );
		msprintf( theControllerStatus[i].yaxis, "%d", _Controller[i].d2.yAxis );

		msprintf( theControllerStatus[i].status, "%d", _Controller[i].status );
		msprintf( theControllerStatus[i].reset, "%d", Joystick_Reset(_Controller[i]) );

		msprintf( theControllerStatus[i].properties, "0x%08x", _Controller[i].properties );

		msprintf( theControllerStatus[i].raw, "%02x %02x %02x %02x", 	(int)_Controller[i].d3.xAxis2 & 0xff, 
																		(int)_Controller[i].d4.yAxis2 & 0xff, 
																		(int)_Controller[i].d5.spinner1 & 0xff, 
																		(int)_Controller[i].d6.spinner2 & 0xff );

		if( i == 0 )
		{
			c = theControllerStatus[0].remote_buttons;

			strcpy( c, "Bit 31 - " );
            si = strlen(c);

			for( ii = 31; ii >= 24; ii-- )
			{
				if( _Controller[0].remote_buttons & (1<<ii) )
					c[si++] = '1';
				else
					c[si++] = '0';
			}
			c[si++] = '-';

			for( ii = 23; ii >= 16; ii-- )
			{
				if( _Controller[0].remote_buttons & (1<<ii) )
					c[si++] = '1';
				else
					c[si++] = '0';
			}
			c[si++] = '-';
			
			for( ii = 15; ii >= 8; ii-- )
			{
				if( _Controller[0].remote_buttons & (1<<ii) )
					c[si++] = '1';
				else
					c[si++] = '0';
			}
			c[si++] = '-';
			
			for( ii = 7; ii >= 0; ii-- )
			{
				if( _Controller[0].remote_buttons & (1<<ii) )
					c[si++] = '1';
				else
					c[si++] = '0';
			}

            c[si++] = 0;
			strcat(c," - Bit 0");         
		}
	}
}



void print_controller_data()
{
int 		i, xpos;
void 		*scr;
long		dmaflags;
int 		ypos;
int 		ystart = 160;
int 		step1 = 15;
int 		ystep = 30;
int 		ystep2 = 20;
	
	scr = gl_screenbuffers[gl_drawbuffer].memP;
	dmaflags = gl_screenbuffers[gl_drawbuffer].dmaFlags;

	for( i = 0; i < 9; i++ )
	{
		ypos = ystart + (i * ystep);
		
		xpos = 50;
        
		DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].a );			xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].b );			xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].l );			xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].r );
        
		xpos = 125;
		DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].start );		xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].select );
        
		xpos = 170;
		DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].up );			xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].down );		xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].left );		xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].right );
       
		xpos = 245;
		DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].c_up );		xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].c_down );		xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].c_left );		xpos += step1;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].c_right );

        xpos = 320;
		DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].xaxis );
        
		xpos = 373;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].yaxis );

        xpos = 427;
		DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].status );

        xpos = 458;
        DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].properties );

		xpos = 567;
		DebugWS(dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[i].raw );
	}

	xpos = (SCREENWIDTH / 2) - (52 * 8 / 2);
	ypos += ystep2;
	DebugWS( dmaflags, scr, xpos, ypos, clr_white, theControllerStatus[0].remote_buttons ); 	
	
	xpos = (SCREENWIDTH / 2) - (17 * 8 / 2);
	ypos += ystep2 - 2;
	DebugWS( dmaflags, scr, xpos, ypos, clr_white, "IR Remote Control" ); 


	{
	static unsigned char brightness;
	mmlColor clr;

		brightness += 2;
		if( brightness > 240 )
			brightness = 16;

		clr = clr_blue & 0x00FFFFFF;
		clr |= (((long)brightness) << 24);
		
		xpos = (SCREENWIDTH / 2) - (20 * 8 / 2);
		DebugWS( dmaflags, scr, xpos, 25, clr, gl_titlestr ); 
	}
}

int main(void)
{
	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	/* Setup fonts */
//	mmlInitFontContext( &gl_gc, &gl_sysRes, &gl_fc, 4096 );
//	SansCondensedBoldP = mmlAddFont( gl_fc, "SansCondendedBold", eTrueType, SansCondensedBold_TTF, 70000 );

	init_screenbuffers();

	_VidSync(0);
	
	/* Draw screen & do stuff */
	while(1)
	{
		// Draw background image		
		draw_picture(background,0,0,SCREENWIDTH,SCREENHEIGHT,SCREENWIDTH,SCREENHEIGHT);

		get_controller_data();
		print_controller_data();      

		// Request screen swap at next VBLANK
		swap_screenbuffers();

		_VidSync(0);
	}


/* Release allocated memory */

	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[0], &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[1], &gl_sysRes, 1 );

/* and exit! */

	return 0;
}

