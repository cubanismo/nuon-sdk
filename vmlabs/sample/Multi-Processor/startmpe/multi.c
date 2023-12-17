/*
 * Hello World - Shows minimum screen setup & text output
 *
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
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

/******************************/

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;

int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

mmlColor			clr_black;
mmlColor			clr_white;
mmlColor			clr_red;
mmlColor			clr_blue;
mmlColor			clr_green;
mmlColor			clr_cyan;
mmlColor			clr_magenta;
mmlColor			clr_yellow;
mmlColor			clr_orange;
mmlColor			clr_pink;

/******************************/

#define SCREENWIDTH			(360)
#define SCREENHEIGHT		(240)
#define PIXELMODE			(4)

#define MY_DMAFLAGS (((SCREENWIDTH/8)<<16)|DMA_PIXEL_WRITE|DMA_CLUSTER_BIT|(PIXELMODE<<4))

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

long mdmacmd1[5];
long mdmacmd2[5];
long mdmacmd3[5];

extern long drawbar[];
extern long size_drawbar[];

int main(void);
int Vblanksync(int count);
void clearscreen(mmlDisplayPixmap *scrn);
void swap_screenbuffers();
void init_screenbuffers();

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

int main(void)
{
int	frametimer;
int	ypos;
int	mpe1, mpe2, mpe3;

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );


	// Create some color definitions   
	clr_white = mmlColorFromRGB(255,255,255);
	clr_black = mmlColorFromRGB(0,0,0);
	clr_red = mmlColorFromRGB(255,0,0);
	clr_blue = mmlColorFromRGB(0,0,255);
	clr_green = mmlColorFromRGB(0,255,0);

	init_screenbuffers();

	/* Start off vblank synchronization */
	_VidSync(0);
	frametimer = 1;

        /* allocate MPEs */
        /* IMPORTANT NOTE:
         * Because we do not plan to use the disc, we can shut down the
         * MiniBIOS which controls the drive. If we did want to do e.g.
         * streaming audio from the disc, we would have to make a version
         * of our MPE assembly language code which could co-exist with
         * the MiniBIOS, and load that code into the MiniBIOS MPE.
         */
        _MediaShutdownMPE();  /* shut down the MiniBIOS */

        /* now get any 3 MPEs */
        mpe1 = _MPEAlloc(0);
        mpe2 = _MPEAlloc(0);
        mpe3 = _MPEAlloc(0);

        if (mpe3 < 0) {
            /* an error happened... for now, just punt */
        }

        ypos = 99;
	/* Draw screen & do stuff */
	while(1)
	{
		ypos++;
		if (ypos > 150) ypos = 100;

		// Clear screen
		clearscreen(&gl_screenbuffers[gl_drawbuffer]);

		mdmacmd1[0] = (SCREENWIDTH/8) << 16 | (PIXELMODE << 4) | DMA_PIXEL_WRITE | DMA_CLUSTER_BIT | (1 << 27);
        mdmacmd2[0] = mdmacmd1[0];
        mdmacmd3[0] = mdmacmd1[0];

		mdmacmd1[1] = (long)gl_screenbuffers[gl_drawbuffer].memP;
		mdmacmd2[1] = (long)gl_screenbuffers[gl_drawbuffer].memP;
        mdmacmd3[1] = (long)gl_screenbuffers[gl_drawbuffer].memP;

		mdmacmd1[2] = 0 | (SCREENWIDTH << 16);
		mdmacmd2[2] = 0 | (SCREENWIDTH << 16);
		mdmacmd3[2] = 0 | (SCREENWIDTH << 16);

		mdmacmd1[3] = (ypos + 0)  | (10<<16);
		mdmacmd2[3] = (ypos + 20) | (10<<16);
		mdmacmd3[3] = (ypos + 40) | (10<<16);
		
		mdmacmd1[4] = clr_red;
		mdmacmd2[4] = clr_blue;
		mdmacmd3[4] = clr_green;

		StartMPE( mpe1, drawbar, (int)size_drawbar, mdmacmd1, 20 );
		StartMPE( mpe2, drawbar, (int)size_drawbar, mdmacmd2, 20 );
		StartMPE( mpe3, drawbar, (int)size_drawbar, mdmacmd3, 20 );

		// Request screen swap at next VBLANK
		swap_screenbuffers();

		// Wait for buffer swap to take place before we loop
		_VidSync(0);
	}


/* Release allocated memory */

	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[0], &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[1], &gl_sysRes, 1 );

/* and exit! */

	return 0;
}

void mdma_command(void *cmd)
{
register volatile long *mdmactrl = 	(long *)0x20500600;
register long *mdmacptr = 			(long *)0x20500610;

	while( *mdmactrl & 0x00000010 );		// Wait for PENDING and BUSY bits to clear
	*mdmacptr = (long)cmd;
}

int mdma_status(void)
{
register volatile long *mdmactrl = 	(long *)0x20500600;

	return( *mdmactrl & 0x0000000F );
}

/***************************************************************************/
/* Clear the screen...                                                     */
/***************************************************************************/

// Offsets into scratch buffer for commands and image data

#define MDMA_CMDBUF1		(0)
#define MDMA_CMDBUF2		(8)

void clearscreen(mmlDisplayPixmap *scrn)
{
long x, y;
int buf;
long *cmd;
long scratchsize;

	long *cmdbuf = _MemLocalScratch((void *)&scratchsize);

	buf = 0;

	cmdbuf[MDMA_CMDBUF1 + 0] = scrn->dmaFlags | DMA_DIRECT_BIT;	// Flags
	cmdbuf[MDMA_CMDBUF1 + 1] = (long)scrn->memP;				// Destination buffer
	cmdbuf[MDMA_CMDBUF1 + 4] = (long)clr_black;					// Source data for write to SDRAM
	
	cmdbuf[MDMA_CMDBUF2 + 0] = scrn->dmaFlags | DMA_DIRECT_BIT;	// Flags
	cmdbuf[MDMA_CMDBUF2 + 1] = (long)scrn->memP;				// Destination buffer
	cmdbuf[MDMA_CMDBUF2 + 4] = (long)clr_black;					// Source data for write to SDRAM
	
	for (x = 0; x < SCREENWIDTH; x += 8)
	{
		for (y = 0; y < SCREENHEIGHT; y += 8)
		{
			switch( buf++ )
			{
			case 0:
				cmd = &cmdbuf[MDMA_CMDBUF1];
				break;
			default:
				cmd = &cmdbuf[MDMA_CMDBUF2];
				buf = 0;
				break;
			}

			while( mdma_status() >= 2 );	// Make sure we don't have more than 2 going at once
			
			cmd[2] = (x)|(8<<16);			// X-offset = x, width = 8
			cmd[3] = (y)|(8<<16);			// Y-offset = y, height = 8
			
			mdma_command(cmd);         
		}
	}
}

/***************************************************************************/
/* Swap draw and display buffers.  Takes effect next VBLANK                */
/***************************************************************************/

void swap_screenbuffers()
{
int tmp;

	tmp = gl_displaybuffer;
	gl_displaybuffer = gl_drawbuffer;
	gl_drawbuffer = tmp;
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}


/***************************************************************************/
/* Initialize the draw/display buffers, clear the memory, put one up!      */
/***************************************************************************/

void init_screenbuffers()
{
mmlDisplayPixmap *dp;

	// Initialize index values for gl_screenbuffers[] array
	gl_displaybuffer = 0;
	gl_drawbuffer = 1;

	// Create each buffer

	dp = &gl_screenbuffers[gl_displaybuffer];
	mmlInitDisplayPixmaps( dp, &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );

	dp = &gl_screenbuffers[gl_drawbuffer];
	mmlInitDisplayPixmaps( dp, &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );

	// Clear both buffers
	clearscreen(&gl_screenbuffers[gl_displaybuffer]);
	clearscreen(&gl_screenbuffers[gl_drawbuffer]);

	// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}
