/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 */
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>
#include <nuon/dma.h>
#include <nuon/joystick.h>
#include <nuon/video.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>
#include "nuon/termemu.h"

#define SCREEN_WIDTH 360
#define SCREEN_HEIGHT 240

#define OSD_SCREEN_WIDTH 360
#define OSD_SCREEN_HEIGHT 240

mmlGC gc;
mmlDisplayPixmap main_screen,osd_screen;
void *mainFrameBuffer,*osdFrameBuffer;

/*
 * the sky background
 */
 
/* how many MPEs to use for rendering. Has to match the YSTEPSIZE in sky.s !!! */
#define SKY_MPES 2

long skycodesize;
long skydatasize;
long renderMPE[SKY_MPES];

extern long skycode_start[], skycode_size[];
extern long skyram_start[], skyram_size[];


/*
 * set up data structures for sky rendering
 */
int
InitSkyDraw(void)
{
    int i;

    for (i = 0; i < SKY_MPES; i++) {
		renderMPE[i] = _MPEAlloc(0);  /* We need a completely free MPEs */
		if (renderMPE[i]<0)
			return -1;
	}	
		
    skycodesize = (long)skycode_size;
    skydatasize = (long)skyram_size;

    /* start up the sky code */
    for (i = 0; i < SKY_MPES; i++) {
		StartMPE(renderMPE[i], skycode_start, (long)skycodesize, skyram_start, (long)skyram_size);
    }
	return 0;
}

/*
 * start drawing the sky with MPEs
 */

void
StartSkyDraw(long dmaflags, void *dmabase)
{
    long packet[4];
    int i, id;

    /* start up the sky MPEs */
    for (i = 0; i < SKY_MPES; i++) {
		id = renderMPE[i];

		/* send it its marching orders */
		packet[0] = dmaflags;
		packet[1] = (long)dmabase;
		packet[2] = i;  /* starty */
		packet[3] = SCREEN_HEIGHT/SKY_MPES; /* ycount */
		CommSend(id, packet);
    }
}


int main()
{
   	mmlSysResources sysRes;
	VidDisplay display;
	VidChannel mainchannel;
    VidChannel osdchannel;
	int i,fr;
	char temp[256];

	mainFrameBuffer=_MemAlloc(SCREEN_WIDTH*SCREEN_HEIGHT*4,256,kMemSDRAM);
	osdFrameBuffer =_MemAlloc(OSD_SCREEN_WIDTH*OSD_SCREEN_HEIGHT*4,256,kMemSDRAM);
	
/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );


    mmlInitDisplayPixmaps( &main_screen, &sysRes, SCREEN_WIDTH, SCREEN_HEIGHT, e888Alpha, 1, mainFrameBuffer );
    mmlInitDisplayPixmaps( &osd_screen, &sysRes, OSD_SCREEN_WIDTH, OSD_SCREEN_HEIGHT, e655, 1, osdFrameBuffer );


	display.dispwidth = SCREEN_WIDTH;
	display.dispheight = SCREEN_HEIGHT;
	display.bordcolor=0x20100000;
	display.progressive=0;
	for(i=0;i<6;i++)
		display.reserved[i]=0;
	
	mainchannel.dmaflags=main_screen.dmaFlags;
	mainchannel.base=main_screen.memP;
	mainchannel.dest_xoff = -1;
	mainchannel.dest_yoff = -1;
	mainchannel.dest_width = 720;
	mainchannel.dest_height = 480;
	mainchannel.src_xoff = 0;
	mainchannel.src_yoff = 0;
	mainchannel.src_width = SCREEN_WIDTH;
	mainchannel.src_height = SCREEN_HEIGHT;
	mainchannel.clut_select=0;
	mainchannel.alpha=0;
	mainchannel.vfilter=VID_VFILTER_2TAP;
	mainchannel.hfilter=VID_HFILTER_4TAP;
	for(i=0;i<5;i++)
		mainchannel.reserved[i]=0;





	osdchannel.dmaflags=osd_screen.dmaFlags;
	osdchannel.base=osd_screen.memP;
	osdchannel.dest_xoff = -1;
	osdchannel.dest_yoff = -1;
	osdchannel.dest_width = 720;
	osdchannel.dest_height = 480;
	osdchannel.src_xoff = 0;
	osdchannel.src_yoff = 0;
	osdchannel.src_width = OSD_SCREEN_WIDTH;
	osdchannel.src_height = OSD_SCREEN_HEIGHT;
	osdchannel.clut_select=0;
	osdchannel.alpha=0;
	osdchannel.vfilter=VID_VFILTER_NONE;
	osdchannel.hfilter=VID_HFILTER_4TAP;
	for(i=0;i<5;i++)
		osdchannel.reserved[i]=0;


	m2dFillColr( &gc, &main_screen, NULL, kBlue );
	m2dFillColr( &gc, &osd_screen, NULL, 0x00 );
	
	_VidConfig ( &display, &mainchannel, &osdchannel, 0L); 

	InitTerminalX(0,(int)osd_screen.memP,osdchannel.dest_width,osdchannel.dest_height,osd_screen.dmaFlags,0);
	Print("Sky by YaK",kBlack,0x00);

	if (InitSkyDraw()<0)
	{
		Print("Failed to allocate MPEs!",kRed,0x00);
		for(;;);
	}
	StartSkyDraw(main_screen.dmaFlags, main_screen.memP);
	fr=0;
	for(;;)
	{
		_VidSync(1);
		StartSkyDraw(main_screen.dmaFlags, main_screen.memP);
		sprintf(temp,"Frames: %d",fr++);
		PrintStatus(temp,kYellow,0x00);
	}
}
