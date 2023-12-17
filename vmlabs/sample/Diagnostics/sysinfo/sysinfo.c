
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include <nuon/dma.h>
#include <nuon/bios.h>
#include <nuon/mutil.h>
#include <nuon/mml2d.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define SCREENWIDTH (512)
#define SCREENHEIGHT (480)

#define TOP_MARGIN		(35)
#define LEFT_MARGIN		(60)

#define	LEFT_INDENT		(25)

#define RIGHT_MARGIN	(SCREENWIDTH - LEFT_MARGIN)
#define BOTTOM_MARGIN	(SCREENHEIGHT - TOP_MARGIN)

#define FGCOLOR 0xc0808000  /* white */
#define BGCOLOR 0x40808000  /* grey */


char buf1[300];
char buf2[300];
char buf3[300];
char buf4[300];
char buf5[300];
char biosinfostring[1000];

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void ClearScreen(mmlDisplayPixmap *scrn)
{
long x, y;

    for (x = 0; x < scrn->wide; x += 8)
	{
		for (y = 0; y < scrn->high; y += 8)
		{
			_raw_plotpixel(scrn->dmaFlags, scrn->memP, (8<<16)|x, (8<<16)|y, BGCOLOR);
		}
    }
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int is_whitespace(char *txt)
{
	if( *txt == ' ' )			// Space
		return 1;
	
	else if( *txt == 0x09 )		// Tab
		return 1;

	else if( *txt == 0x0d )		// Carriage return
		return 1;

	else if( *txt == 0x0a )		// Linefeed
		return 1;

	return 0;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


int main()
{
struct BiosInfo *biosinfo;
int xpos, ypos;
int lineheight = 16;
int paragraph_space = 22;

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );	

	// Point the video hardware at the display buffer
	mmlInitDisplayPixmaps( &gl_screen, &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
    ClearScreen(&gl_screen);
	mmlSimpleVideoSetup(&gl_screen, &gl_sysRes, eFourTapVideoFilter);
	
	biosinfo = _BiosGetInfo();
    
	/* Write our messages */
	
	ypos = TOP_MARGIN;

	DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN, ypos, kBlue, "BIOS Version Information" );
    ypos +=  paragraph_space;
	
	sprintf( buf1, "BIOS Version = %d.%02d", biosinfo->major_version, biosinfo->minor_version );
	DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN + LEFT_INDENT, ypos, FGCOLOR, buf1 );
	ypos +=  paragraph_space;

    sprintf( buf2, "OEM Revision = %02d", biosinfo->oem_revision );
	DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN + LEFT_INDENT, ypos, FGCOLOR, buf2 );
	ypos +=  paragraph_space;

    sprintf( buf3, "VML Revision = %02d", biosinfo->vm_revision );
	DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN + LEFT_INDENT, ypos, FGCOLOR, buf3 );
	ypos +=  paragraph_space;

    sprintf( buf4, "Build Date = %s", biosinfo->date_string );
	DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN + LEFT_INDENT, ypos, FGCOLOR, buf4 );
	ypos +=  paragraph_space;

    sprintf( buf5, "Info: " );
    DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN + LEFT_INDENT, ypos, FGCOLOR, buf5 );

	strncpy( biosinfostring, biosinfo->info_string, 1000 );
	xpos = LEFT_MARGIN + LEFT_INDENT + (6*8);
   
	{
	char *startpos, *termpos;
	int x_right, finished;
	char wrap_char;
		
		startpos = biosinfostring;
		termpos = startpos;
		finished = 0;
	
		do
		{
			// Step forward from "startpos" until we go past right margin
			do
			{
				termpos++;
				wrap_char = *termpos;
				*termpos = 0;
	
				x_right = xpos + (strlen(startpos) * 9);
	
				*termpos = wrap_char;
			}
			while( (x_right < RIGHT_MARGIN) && *termpos );

			// Step back from right margin until we find word wrap position
			if( *termpos )
			{
				do
				{
					termpos--;
					if (is_whitespace( termpos ) )
						break;
				}
				while( termpos >= startpos );         
			}
			else
			{
				finished = 1;
			}
	
			wrap_char = *termpos;
			*termpos = 0;
	
			// Let's see if everything fits.
			DebugWS( gl_screen.dmaFlags, gl_screen.memP, xpos, ypos, FGCOLOR, startpos );
	
			*termpos = wrap_char;
			startpos = ++termpos;
	
			xpos = LEFT_MARGIN + LEFT_INDENT + (strlen(buf5) * 9);
			ypos += lineheight;
		}
		while( *termpos && (! finished) );
	}

	ypos += paragraph_space;
	
	
	{
	long *icachectl = (long *)0x20500FFC;
	long *dcachectl = (long *)0x20500FF8;
	long val;
	
		val = *icachectl;
		sprintf( buf1, "I-Cache = 0x%08lx", val & 0xFFF );
	
		val = *dcachectl;
		sprintf( buf2, "D-Cache = 0x%08lx", val & 0xFFF );
	
		/* write our messages */
		DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN, ypos, kBlue,"Cache configuration values");
		ypos += paragraph_space;

		DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN + LEFT_INDENT, ypos, FGCOLOR, buf1 );
		ypos += paragraph_space;

		DebugWS(gl_screen.dmaFlags, gl_screen.memP, LEFT_MARGIN + LEFT_INDENT, ypos, FGCOLOR, buf2 );
		ypos += paragraph_space;
	}

	// Reset screen height to stretch contents to fit
	gl_screen.high = ypos + paragraph_space;
	mmlSimpleVideoSetup(&gl_screen, &gl_sysRes, eFourTapVideoFilter);
	
	// Loop forever
	while(1);

	/* Never get here */
	return 0;
}

