/* Main Code BALLSDEMO


Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


#include <stdio.h>
#include <stdlib.h>

#include <m3dl/m3dl.h>

#include <nuon/video.h>
#include <nuon/joystick.h>
#include <nuon/dma.h>
#include <nuon/msprintf.h>
#include <nuon/mutil.h>

typedef struct {
  mdUINT16 	x,y;
	mdUINT16 	dx,dy;
	mdCOLOR	 	color;
}	NFO;

#define MAXOBJ 2000
#define WALL_X ((360-16)<<4)
#define WALL_Y ((240-16)<<4)

extern char bol_start[];

int	main()
{
	/*Texture Info*/
	mdTEXTURE		texture[10];		//Maximum 10 Textures
	mdBITMAP		bitmap[10];			//Maximum 10 bitmaps


	/*Structures for testing different Screen Modes*/
	mdDRAWCONTEXT 	dcx[2];				//Draw Context Structures
	mdBYTE*			sdramaddr;			//Help variable
	mdUINT32		sdramlen;			//Help variable

	/*Miscellaneous*/
	mdUINT32		loop;
	mdUINT32		frames;				//Number of Frames elapsed
	mdUINT32 		i;	   				//Useful Counter

	//Output
	static char		tellme[255];

	NFO				postab[MAXOBJ];

	//More test
	mdUINT32		bilinear, alpha, color;
	mdUINT32		numspr;

	//Primitives
	mdSPRITE 		s;
	mdTILE 			cleartile;
	mdCOLOR 		dcolor;


	// Use this as a theoretical address for the screen buffers
	sdramaddr = (mdBYTE*)0x40000000;
	
	// Do this once to get the required size
	sdramlen = mdSetBufGRB16B_NOZ_YCC32B(dcx,(sdramaddr), 360, 240, 20, 20, 320, 200);
	
	// Now allocate the memory
	sdramaddr = (mdBYTE*)_MemAlloc(sdramlen,512,kMemSDRAM);
	if (sdramaddr == mdNULL)
	{
		exit(-1);
	}

	// Now setup the screen again using the allocated buffer
	sdramlen = mdSetBufGRB16B_NOZ_YCC32B(dcx,(sdramaddr), 360, 240, 20, 20, 320, 200);	
	
	VidSetup((mdBYTE *)(dcx[1].buf[dcx[1].actbuf].sdramaddr),
						dcx[1].buf[dcx[1].actbuf].dmaflags, dcx[1].dispw, dcx[1].disph,0);

	sdramaddr += sdramlen;

	// Setup Test Texture
	mdTextureFromMBM((mdBYTE *)bol_start,(sdramaddr),texture,bitmap);

	//setup sprite
	s.sr.w			=	(16*1)<<4;
	s.sr.h			=	(16*1)<<4;
 	s.tex = &texture[0];
	s.u0 		= 0<<10;
	s.v0 		= 0<<10;
	s.uofs	= (1)<<10;
	s.vofs	= (1)<<10;

	//Syncronize with VBlank
	frames = 1; loop = 1;
	_VidSync(1);

	//Setup MPR
	mdSetupMPRChain(1,2);

	//Clear complete rendermemory
	mdSetRGB(&dcolor,0,0,0);
	mdClearDraw(dcx, &dcolor);

	//Clear complete displaymemory
	mdSetRGB(&dcolor,0,0,0);
	mdClearDisp(dcx, &dcolor);

	mdDrawSync();								//Wait for ClearScreen

	//Setup Clear Screen Sprite (Only Rendering Window)
	mdSetRGB(&cleartile.color,0,0,0);
	mdSetScrRECT(&cleartile.sr,dcx[0].rendx<<4,dcx[0].rendy<<4,1,dcx[0].rendw<<4,dcx[0].rendh<<4);

	//setup
	bilinear = 1;
	alpha = 0;
	color = 0;
	numspr = 1;

//printf( "initializing objects\n" ); fflush(stdout);

	//init
	for ( i=0 ; i<MAXOBJ ; i++ )
	{
		postab[i].x = rand()%WALL_X;
		postab[i].y = rand()%WALL_X;
		postab[i].dx = (rand()%(4<<4))+1;
		postab[i].dy = (rand()%(4<<4))+1;
		
		mdSetRGBA(&postab[i].color, \
						 (rand()%(255-84-32))+64, (rand()%(255-84-32))+64, \
						 (rand()%(255-84-32))+64, (rand()%(255-64))+32 );
	}



//	printf( "Entering main loop\n" ); fflush(stdout);

	while (loop) {
		//Set MPR Screen Buffer
		mdActiveDrawContext(&dcx[0]);

		//Clear Rendering Window
		mdDrawTile(mpTILE_F, &cleartile.sr, &cleartile.color);

		if (ButtonRight(_Controller[1])) {
			numspr++;
			if ( numspr > MAXOBJ ) {
				numspr = MAXOBJ;
			}
		};
		if (ButtonLeft(_Controller[1])) {
			numspr--;
			if ( numspr < 1 )			{
				numspr = 1;
			}
		};
		if (ButtonCRight(_Controller[1])) {
			s.sr.w += ((1<<4)*frames);
		};
		if (ButtonCLeft(_Controller[1])) {
			if ( s.sr.w >= ((1<<4)*frames))
				s.sr.w -= ((1<<4)*frames);
			else
				s.sr.w = 0;
		};
		if (ButtonCDown(_Controller[1])) {
			s.sr.h += ((1<<4)*frames);
		};
		if (ButtonCUp(_Controller[1])) {
			if ( s.sr.h >= ((1<<4)*frames))
				s.sr.h -= ((1<<4)*frames);
			else
				s.sr.h = 0;
		};
		if (ButtonR(_Controller[1])) {
			bilinear = 0;
		};
		if (ButtonL(_Controller[1])) {
			bilinear = 1;
		};
		if (ButtonA(_Controller[1])) {
			alpha = 1;
		};
		if (ButtonB(_Controller[1])) {
			alpha = 0;
		};
		if (ButtonStart(_Controller[1])) {
			color = 1;
		};
		if (ButtonZ(_Controller[1])) {
			color = 0;
		};

		mdDrawSync();								//Wait for ClearScreen

		for (i=0; i < (numspr);i++) {
			if (( s.sr.x = (postab[i].x += (frames*postab[i].dx))%WALL_X*2) >= WALL_X ) {
				s.sr.x = (WALL_X*2)-s.sr.x;
			}
			if (( s.sr.y = (postab[i].y += (frames*postab[i].dy))%WALL_Y*2) >= WALL_Y ) {
				s.sr.y = (WALL_Y*2)-s.sr.y;
			}
			s.color = postab[i].color;

			if (bilinear) {
				if (alpha) {
					if (color) {
						mdDrawSprite(mpSPRT_BFA, &s.sr, &s.color, s.tex, (mdUINT32*)&s.u0);
					} else {
						mdDrawSprite(mpSPRT_BA, &s.sr, &s.color, s.tex, (mdUINT32*)&s.u0);
					}; //if
				} else {
					if (color) {
						mdDrawSprite(mpSPRT_BF, &s.sr, &s.color, s.tex, (mdUINT32*)&s.u0);
					} else {
						mdDrawSprite(mpSPRT_B, &s.sr, &s.color, s.tex, (mdUINT32*)&s.u0);
					}; //if
				}; //if
			} else {
				if (alpha) {
					if (color) {
						mdDrawSprite(mpSPRT_FA, &s.sr, &s.color, s.tex, (mdUINT32*)&s.u0);
					} else {
						mdDrawSprite(mpSPRT_A, &s.sr, &s.color, s.tex, (mdUINT32*)&s.u0);
					}; //if
				} else {
					if (color) {
						mdDrawSprite(mpSPRT_F, &s.sr, &s.color, s.tex, (mdUINT32*)&s.u0);
					} else {
						mdDrawSprite(mpSPRT, &s.sr, &s.color, s.tex, (mdUINT32*)&s.u0);
					}; //if
				}; //if
			}; //else
		}; //for i

		mdDrawSync();								//Wait for Draw Execution

		msprintf(tellme, "SPRITES %d",numspr);
		DebugWS(dcx[0].buf[dcx[0].actbuf].dmaflags, (mdUINT32*)(dcx[0].buf[dcx[0].actbuf].sdramaddr), 24, 36, 0xC0FF8000,tellme);

		//SWAPBUF
		frames = SwapDrawBufGRB(dcx);

	}; //while

	return 0;
}

