/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/*
 * Main Code BACKGROUND DEMO
 */

#include <nuon/bios.h>					//Bios
#include <nuon/mutil.h>					//FixSinCos()
#include <nuon/msprintf.h>				//msprintf() output
#include <nuon/dma.h>					//DebugWS output

#include <malloc.h>						//malloc
#include "bground.h"

extern	mdBYTE	BackgroundMBIhiycc[];
extern	mdBYTE	BackgroundMBIloycc[];
extern	mdBYTE	BackgroundMBIhigrb[];
extern	mdBYTE	BackgroundMBIlogrb[];

extern	mdBYTE	BallMBMhiycc[];
extern	mdBYTE	BallMBMhigrb[];

void	*AlignMalloc(unsigned long size,unsigned long align)
{
long	addr;

	//Allocate size + (align-1) bytes
	addr = (long)(malloc(size+(align-1)));

	if (addr == 0)
	{
		exit(-1);
	}; //if

	//Round addr to NEXT multiple of align if not already aligned
	addr = ((addr+align-1)/align)*align;

	return (void*)addr;
}; //AlignMalloc()


int	main()
{
	//Reserve YCC Drawcontext
	mdDRAWCONTEXT	dcx[1];					//1 (0 GRB, 1 YCC)

	mdINT32		sdramlen;					//Length of video sdram buffer
	mdBYTE		*sdramaddr;					//Address of video sdram buffer
	mdIMAGE		background;					//Background Image
	mdIMAGEDATA	bgimgdata;					//Single Image
	mdBITMAP	bgbitmap;					//Single Bitmap
	mdUINT32	zcmpflags;					//Backup of Z comparator flags
	mdINT32		loop;
	mdINT32		frames;

#if (DISPLAYFRAMES == 1)
	char	emptystr[SPRINTF_MAX]; 			//String
#endif
	
	mdINT32	i,j;							//for counter

	md28DOT4	balloffset;					//Ball offset (for init)
	md16DOT16	ballangle;					//Ball angle
	mdINT32		ballactive[BALLCOLORS];	  	//#of active balls/color
	BALLNFO		ball[BALLCOLORS][MAXBALLS];	//4 Different colors
	mdINT32		numtex,numbm;				//Number of Textures, Bitmaps
	mdTEXTURE	*balltex;					//Ball textures
	mdBITMAP	*ballbm;					//Ball bitmaps

	//Reserve YCC Drawcontext
	//NUMBUFFERS are 16BitColor+16BitZ (4 bytes/pixel)

	sdramlen = NUMBUFFERS*(SCR_WIDTH*SCR_HEIGHT*4);
	sdramaddr = (mdBYTE*)_MemAlloc(sdramlen,512,kMemSDRAM);
	
	if (sdramaddr == mdNULL)
	{
		exit(-1);
	}

	mdSetBufYCC16B_WITHZ(dcx, sdramaddr, NUMBUFFERS,SCR_WIDTH,SCR_HEIGHT,0,0,SCR_WIDTH,SCR_HEIGHT);

	//Setup MPR Chain
	mdSetupMPRChain(M3DL_STARTMPE,M3DL_NUMMPE);

	//Setup View Frustum (Even in 2D, NearZ & FarZ need to be initialised)
	mdSetFrustum((60<<16)/360, SCR_WIDTH, SCR_HEIGHT, ((4<<16)/3), 16<<16, 4096<<16);

	//Clear background color
	mdSetRGBA(&background.color,0,0,0,0);
	//Set screen coordinates
	mdSetScrRECT(&background.sr,dcx[0].rendx<<4,dcx[0].rendy<<4,mdGetFarZ(),dcx[0].rendw<<4,dcx[0].rendh<<4);

	//Setup Background Image (if any)
	mdImageDataFromMBI(BackgroundMBIhiycc,0,&bgimgdata,&bgbitmap);
	
	//Set image data
	background.img = &bgimgdata;
	//UV setup (no tiling, no flipping)
	background.u0		= 0<<10;
	background.v0		= 0<<10;
	background.uofs	= 1<<10;
	background.vofs	= 1<<10;

	//Clear display before making it active
	mdClearDisp(dcx, &background.color);

	//Get Ball textures
	mdGetMBMInfo(BallMBMhiycc,&numtex,&numbm);
	if ((numtex > 0) && (numbm > 0))
	{
		balltex = (mdTEXTURE *)AlignMalloc(numtex*sizeof(mdTEXTURE),8);
		ballbm = (mdBITMAP *)AlignMalloc(numbm*sizeof(mdBITMAP),8);
		mdTextureFromMBM(BallMBMhiycc,0,balltex,ballbm);
	}; //if

	//Clear Ball arrays
	for (i=0;i<BALLCOLORS;i++)
	{
		//Clear #of elements
		ballactive[i] = 0;
	}; //For i

	//Initialise balls at startup
	ballangle = 0;
	balloffset = 0;

	for (i=0;i<BALLSACTIVE;i++)
	{
		mdINT32	color;

		//Randomize color
		color = i & (BALLCOLORS-1);

		//Insert ball in table
		ball[color][ballactive[color]].angle = ballangle;
		ball[color][ballactive[color]].distance = balloffset;
		ballactive[color]++;		//Increment #of elements

		//Update angle & spacing
		ballangle += BALLANGLE;
		balloffset += BALLSPACING;
	}; //for i

	//Clear rotation angle
	ballangle = 0;

	//Turn On Display
	mdDrawSync();
	_VidSetup((mdUINT32 *)(dcx[0].buf[dcx[0].actbuf].sdramaddr),
						dcx[0].buf[dcx[0].actbuf].dmaflags, dcx[0].dispw, dcx[0].disph,0);
	//Wait till it is active & set lastfield counter
	dcx[0].lastfield = _VidSync(1);


	//Set loop & dummy #of frames
	loop = 1;
	frames = 1;

	//Loop the loop
	while (loop)
	{
		//Set Background
		//Backup Z Buffer comparison flags
		zcmpflags = dcx[0].zcmpflags[0];

		//Disable Z Buffer comparison (always write Z)
		dcx[0].zcmpflags[0] = WR_Z;

		//Activate the render context with Z overwrite
		mdActiveDrawContext(&dcx[0]);

		//Render Image and write FARZ into ZBuffer (Z value set in background.sr)
		mdDrawImage(mpIMG, &background.sr, &background.color, background.img, (mdUINT32*)&background.u0);

		//Restore original Z Buffer comparison flags
		dcx[0].zcmpflags[0] = zcmpflags;

		//Activate the render context with Z comparison
		mdActiveDrawContext(&dcx[0]);

		//Update balls
		ballangle += ((frames<<16)/360);

		//Wait for Clear/Background to finish
		mdDrawSync();

		//Render balls
		for (i=0;i<BALLCOLORS;i++)
		{
			md2DOT30	sine,cosine;
			mdScrRECT	sr;
			mdUINT32	uv[2];

			//Z in middle of nearz & farz
			sr.z = (mdGetFarZ()>>1)+(mdGetNearZ()>>1);
			//32x32
			sr.w = (32<<4);
			sr.h = (32<<4);
			//Set uv
			uv[0] = 0;
			uv[1] = ((1<<10)<<16)|(1<<10);

			//Loop on per color base
			for (j=0;j<ballactive[i];j++)
			{
				FixSinCos(ball[i][j].angle+ballangle,&sine,&cosine);
				sr.x = ((SCR_WIDTH<<4)>>1)+FixMul(ball[i][j].distance,cosine,30)-(sr.w>>1);
				sr.y = ((SCR_HEIGHT<<4)>>1)-FixMul(ball[i][j].distance,sine,30)-(sr.h>>1);
				mdDrawSprite(mpSPRT,&sr,mdNULL,&balltex[i],uv);
			}; //for j
		}; //for i

#if (DISPLAYFRAMES == 1)
			msprintf(emptystr,"frames %d",frames);
			DebugWS(dcx[0].buf[dcx[0].actbuf].dmaflags, (mdUINT32*)(dcx[0].buf[dcx[0].actbuf].sdramaddr), (SCR_WIDTH>>3), (SCR_HEIGHT>>3), 0xC0FF8000,emptystr);
#endif

		//Swap drawcontext
		frames = SwapDrawBufYCC(dcx);
	}; //while
	return 0;
}

