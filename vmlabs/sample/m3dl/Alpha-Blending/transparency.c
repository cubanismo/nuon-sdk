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

#include <stdlib.h>
#include <stdio.h>					//printf() error output
#include <nuon/mml2d.h>
#include <nuon/bios.h>				//Bios
#include <nuon/mutil.h>				//FixSinCos()
#include <nuon/msprintf.h>			//msprintf() output
#include <nuon/dma.h>				//DebugWS output
#include <malloc.h>					//malloc
#include "transparency.h"

extern	mdBYTE	BackgroundMBIhiycc[];

char str[300];
mdDRAWCONTEXT	dcx[3];				//1 (0 GRB, 1 YCC)


////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define TEXT_COLOR_HILITE_RED		((kRed & 0x00FFFFFF)|0xC0000000)	//(0xA32C9C00)
#define TEXT_COLOR_HILITE_BLUE		((kBlue & 0x00FFFFFF)|0xC0000000)
#define TEXT_COLOR_HILITE_GREEN		((kGreen & 0x00FFFFFF)|0xC0000000)
#define TEXT_COLOR					((kWhite & 0x00FFFFFF)|0xC0000000)	// (0xC0D46400)

#define TEXT_HEIGHT					(18)

void print(int x, int y, char *str, int hilite)
{
mdTILE txbg;
int len;

	len = strlen(str) * 9;
	len += 6;
    
	// Set background tile...
	mdSetScrRECT( &txbg.sr, (x - 2)<<4, (y - 2)<<4, mdGetFarZ(), len<<4, 20<<4 );

	switch( hilite-1 )
	{
		case -1:
		{
			mdSetRGBA(&txbg.color, 64, 64, 64, 0 );				// Dark Grey
			mdDrawTile(mpTILE_FZ, &txbg.sr, &txbg.color );
			mdDrawSync();

			DebugWS(dcx[0].buf[dcx[0].actbuf].dmaflags, (mdUINT32*)(dcx[0].buf[dcx[0].actbuf].sdramaddr), x, y, TEXT_COLOR, str );
		}
		break;

		case 0:
		{
			mdSetRGBA(&txbg.color, 96, 0, 0, 0 );				// Dark Red
			mdDrawTile(mpTILE_FZ, &txbg.sr, &txbg.color );
			mdDrawSync();
			
			DebugWS(dcx[0].buf[dcx[0].actbuf].dmaflags, (mdUINT32*)(dcx[0].buf[dcx[0].actbuf].sdramaddr), x, y, TEXT_COLOR_HILITE_RED, str );
		}
		break;

		case 1:
		{
			mdSetRGBA(&txbg.color, 0, 96, 0, 0 );               // Dark Green
			mdDrawTile(mpTILE_FZ, &txbg.sr, &txbg.color );
			mdDrawSync();
			
			DebugWS(dcx[0].buf[dcx[0].actbuf].dmaflags, (mdUINT32*)(dcx[0].buf[dcx[0].actbuf].sdramaddr), x, y, TEXT_COLOR_HILITE_GREEN, str );
		}
		break;

		case 2:
		{
			mdSetRGBA(&txbg.color, 0, 0, 96, 0 );               // Dark Blue
			mdDrawTile(mpTILE_FZ, &txbg.sr, &txbg.color );
			mdDrawSync();
			
			DebugWS(dcx[0].buf[dcx[0].actbuf].dmaflags, (mdUINT32*)(dcx[0].buf[dcx[0].actbuf].sdramaddr), x, y, TEXT_COLOR_HILITE_BLUE, str );
		}
		break;


		case 3:
		{
			mdSetRGBA(&txbg.color, 192, 192, 192, 0 );				// Light Grey
			mdDrawTile(mpTILE_FZ, &txbg.sr, &txbg.color );
			mdDrawSync();
			
			DebugWS(dcx[0].buf[dcx[0].actbuf].dmaflags, (mdUINT32*)(dcx[0].buf[dcx[0].actbuf].sdramaddr), x, y, kBlack, str );
		}
		break;
	}

}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int	main()
{
	//Reserve YCC Drawcontext
	mdINT32		sdramlen;				//Length of video sdram buffer
	mdBYTE		*sdramaddr;				//Address of video sdram buffer
	mdIMAGE		background;				//Background Image
	mdIMAGEDATA	bgimgdata;				//Single Image
	mdBITMAP	bgbitmap;				//Single Bitmap
	mdUINT32	zcmpflags;				//Backup of Z comparator flags
	mdINT32		loop;
	mdINT32		frames;
	mdQUAD 		overlay;
	int 		i, debounce, zpos, corner, comp;
	int			val_x, val_y, comp_x, comp_y;
	mdTRANSMODE	tmode;
	md2DOT30	bgmult;

	//Reserve YCC Drawcontext
	//NUMBUFFERS are 16BitColor+16BitZ (4 bytes/pixel)
	sdramlen = NUMBUFFERS*(SCR_WIDTH*SCR_HEIGHT*4);
	sdramaddr = (mdBYTE*)_MemAlloc(sdramlen,512,kMemSDRAM);
	if (sdramaddr == mdNULL)
	{
		printf("Error: Unable to allocate SDRAM buffer\n");
		fflush(stdout);
	};
	
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
	background.u0	= 0<<10;
	background.v0	= 0<<10;
	background.uofs	= 1<<10;
	background.vofs	= 1<<10;
	
	//Clear display before making it active
	mdClearDisp(dcx, &background.color);
	mdDrawSync();

	//Turn On Display	
	_VidSetup((mdUINT32 *)(dcx[0].buf[dcx[0].actbuf].sdramaddr), dcx[0].buf[dcx[0].actbuf].dmaflags, dcx[0].dispw, dcx[0].disph,eTwoTapVideoFilter);
	
	//Wait till it is active & set lastfield counter
	dcx[0].lastfield = _VidSync(1);

	//Set loop & dummy #of frames
	loop = 1;
	frames = 1;

#define OVERLAY_X1	(100)
#define OVERLAY_Y1	(100)
#define OVERLAY_X2	(600)
#define OVERLAY_Y2	(380)

	// Setup overlay rectangle
	zpos = mdGetNearZ() + 0x08000000;
	mdSetScrVector(&overlay.v[0], OVERLAY_X1<<4, OVERLAY_Y1<<4, zpos );
	mdSetScrVector(&overlay.v[1], OVERLAY_X2<<4, OVERLAY_Y1<<4, zpos );
	mdSetScrVector(&overlay.v[2], OVERLAY_X1<<4, OVERLAY_Y2<<4, zpos );
	mdSetScrVector(&overlay.v[3], OVERLAY_X2<<4, OVERLAY_Y2<<4, zpos );
	overlay.u0 = 0;
	overlay.v0 = 0;
	overlay.u1 = 0x0400;
	overlay.v1 = 0;
	overlay.u2 = 0;
	overlay.v2 = 0x0400;
	overlay.u3 = 0x0400;
	overlay.v3 = 0x0400;
	overlay.tex = 0; 
	mdSetRGBA( &overlay.c[0], 128, 128, 128, 0 );
	mdSetRGBA( &overlay.c[1], 128, 128, 128, 128 );
	mdSetRGBA( &overlay.c[2], 128, 128, 128, 128 );
	mdSetRGBA( &overlay.c[3], 128, 128, 128, 255 );
  
	corner = 0;
	comp = 0;
	debounce = 0;
	tmode = 0;
	bgmult = 0x40000000;

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
		
		mdDrawSync();
		//Restore original Z Buffer comparison flags
		dcx[0].zcmpflags[0] = zcmpflags;

		//Activate the render context with Z comparison
		mdActiveDrawContext(&dcx[0]);
		
#define CONTROLLER_DEBOUNCE (2)

		if( debounce == 0 )
		{
			if( ButtonLeft(_Controller[1]) )
			{
				corner--;
				if( corner < 0 )
					corner = 3;

				debounce = CONTROLLER_DEBOUNCE;
			}
			else if( ButtonRight(_Controller[1]) )
			{
				corner++;
				if( corner > 3 )
					corner = 0;

				debounce = CONTROLLER_DEBOUNCE;
			}
	
			if( ButtonUp(_Controller[1]) )
			{
				comp--;
				if( comp < 0 )
					comp = 3;

				debounce = CONTROLLER_DEBOUNCE;
			}
			else if( ButtonDown(_Controller[1]) )
			{
				comp++;
				if( comp > 3 )
					comp = 0;

				debounce = CONTROLLER_DEBOUNCE;
			}
	
			if( ButtonL(_Controller[1]) )
			{
				switch(comp)
				{
					case 0:
						overlay.c[corner].r--;
						break;
					
					case 1:
						overlay.c[corner].g--;
						break;
					
					case 2:
						overlay.c[corner].b--;
						break;
					
					case 3:
						overlay.c[corner].a--;
						break;
				}

				debounce = CONTROLLER_DEBOUNCE;
			}
			else if( ButtonR(_Controller[1]) )
			{
				switch(comp)
				{
					case 0:
						overlay.c[corner].r++;
						break;
					
					case 1:
						overlay.c[corner].g++;
						break;
					
					case 2:
						overlay.c[corner].b++;
						break;
					
					case 3:
						overlay.c[corner].a++;
						break;
				}

				debounce = CONTROLLER_DEBOUNCE;
			}

			if( ButtonCUp(_Controller[1]) )
			{
				switch(comp)
				{
					case 0:
						overlay.c[corner].r = 255;
						break;
					
					case 1:
						overlay.c[corner].g = 255;
						break;
					
					case 2:
						overlay.c[corner].b = 255;
						break;
					
					case 3:
						overlay.c[corner].a = 255;
						break;
				}

				debounce = CONTROLLER_DEBOUNCE;
			}
			else if( ButtonCDown(_Controller[1]) )
			{
				switch(comp)
				{
					case 0:
						overlay.c[corner].r = 0;
						break;
					
					case 1:
						overlay.c[corner].g = 0;
						break;
					
					case 2:
						overlay.c[corner].b = 0;
						break;
					
					case 3:
						overlay.c[corner].a = 0;
						break;
				}

				debounce = CONTROLLER_DEBOUNCE;
			}

			if( ButtonCRight(_Controller[1]) )
			{
				switch(comp)
				{
					case 0:
						overlay.c[corner].r += 32;
						break;
					
					case 1:
						overlay.c[corner].g += 32;
						break;
					
					case 2:
						overlay.c[corner].b += 32;
						break;
					
					case 3:
						overlay.c[corner].a += 32;
						break;
				}

				debounce = CONTROLLER_DEBOUNCE;
			}
			else if( ButtonCLeft(_Controller[1]) )
			{
				switch(comp)
				{
					case 0:
						overlay.c[corner].r -= 32;
						break;
					
					case 1:
						overlay.c[corner].g -= 32;
						break;
					
					case 2:
						overlay.c[corner].b -= 32;
						break;
					
					case 3:
						overlay.c[corner].a -= 32;
						break;
				}

				debounce = CONTROLLER_DEBOUNCE;
			}

			if( ButtonStart(_Controller[1]) )
			{
				tmode++;
				if( tmode > TRANSMODE_SUBTRACTIVE )
					tmode = TRANSMODE_NORMAL;

				mdSetTransparencyMode(tmode, bgmult );

				debounce = CONTROLLER_DEBOUNCE;
			}
			
			if( ButtonZ(_Controller[1]) )
			{
				bgmult += 0x10000000;
				
				mdSetTransparencyMode(tmode, bgmult );

				debounce = CONTROLLER_DEBOUNCE;
			}
		}
		else
		{
			debounce--;
		}

		mdDrawPoly( mpQUAD_GA, (mdScrV3 *)&overlay.v, (mdCOLOR *)&overlay.c, overlay.tex, (mdUINT32 *)&overlay.u0 );
	
		//Wait for drawing to finish
		mdDrawSync();

		sprintf( str, "tmode = %d, mult = 0x%08x", tmode, bgmult );
		print( OVERLAY_X1, OVERLAY_Y1 - (TEXT_HEIGHT * 3), str, 0 );
		
		// Print information around transparent rectangle

		for( i = 0; i < 4; i++ )
		{
            msprintf(str, " %d,%d,%d,%d ", (int)overlay.c[i].r & 0xFF, (int)overlay.c[i].g & 0xff, (int)overlay.c[i].b & 0xff, (int)overlay.c[i].a & 0xff );
		
			switch( i )
			{
				case 0:
					comp_x = OVERLAY_X1;
					comp_y = OVERLAY_Y1 - (TEXT_HEIGHT * 2);
					val_x = OVERLAY_X1;
					val_y = OVERLAY_Y1 - TEXT_HEIGHT;
					break;
				
				case 1:
					comp_x = OVERLAY_X2 - (strlen(str) * 8);
					comp_y = OVERLAY_Y1 - (TEXT_HEIGHT * 2);
                    val_x = OVERLAY_X2 - (strlen(str) * 8);
					val_y = OVERLAY_Y1 - TEXT_HEIGHT;
					break;
	
				case 2:
					comp_x = OVERLAY_X1;
					comp_y = OVERLAY_Y2 + TEXT_HEIGHT;
                    val_x = OVERLAY_X1;
					val_y = OVERLAY_Y2;
					break;
				
				case 3:
				default:
					comp_x = OVERLAY_X2 - (strlen(str) * 8);
					comp_y = OVERLAY_Y2 + TEXT_HEIGHT;
                    val_x = OVERLAY_X2 - (strlen(str) * 8);
					val_y = OVERLAY_Y2;
					break;
			}
			
			print( val_x, val_y, str, (corner==i ? comp+1 : 0) );

			if( i == corner )
			{
				switch( comp )
				{
					case 0:
						print( comp_x, comp_y, " Red   ", comp+1 );
						break;
					case 1:
						print( comp_x, comp_y, " Green ", comp+1 );
						break;
					case 2:
						print( comp_x, comp_y, " Blue  ", comp+1 );
						break;
					case 3:
						print( comp_x, comp_y, " Alpha ", comp+1 );
						break;
				}
			}
		}

		//Swap drawcontext
		frames = SwapDrawBufYCC(dcx);
	}; //while
	return 0;
}

