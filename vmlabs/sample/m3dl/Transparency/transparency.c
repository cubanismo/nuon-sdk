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

#include <m3dl/m3dl.h>

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define NUMBUFFERS			(3)			//2 Double, 3 Triple Buffering
#define M3DL_STARTMPE		(1)			//M3DL Start Render MPE
#define M3DL_NUMMPE			(2)			//M3DL Number of Rendering MPEs

#define SCREENWIDTH			(720)
#define SCREENHEIGHT		(480)

#define OVERLAY_X1			(328)
#define OVERLAY_Y1			(208)
#define OVERLAY_X2			(392)
#define OVERLAY_Y2			(272)

#define BOUNDARY			(24)
#define WALL_TOP			(16)
#define WALL_LEFT			BOUNDARY
#define WALL_RIGHT			(SCREENWIDTH-BOUNDARY)
#define WALL_BOTTOM			(SCREENHEIGHT-16)
#define	MAX_OBJECT_SPEED	(0x20)


////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define MAX_SPRITES	(21)

typedef struct
{
	long		x, y;			/* current point */
	long		dx, dy;			/* amount of movement per frame */

} Sprite_Position;

Sprite_Position	theSprites[MAX_SPRITES];

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

char 			str[300];
mdDRAWCONTEXT	dcx[3];				// 1 (0 GRB, 1 YCC)

mdIMAGEDATA		bgimgdata;			// Single Image
mdBITMAP		bgbitmap;			// Single Bitmap
mdQUAD 			overlay;

char			texbuffer[6000];

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

extern	mdBYTE	BackgroundImage[];
extern  mdBYTE  SpriteData[];
extern  mdBYTE  SpriteData2[];
extern  mdBYTE  SpriteData3[];

mdTEXTURE	*theTexture;
mdBITMAP	*theTextureBitmap;
mdTEXTURE	*theTexture2;
mdBITMAP	*theTexture2Bitmap;
mdTEXTURE	*theTexture3;
mdBITMAP	*theTexture3Bitmap;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

static void create_sprites(Sprite_Position *theSprite);
void draw_sprites(int stepcount);

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


#define TEXT_COLOR_HILITE_RED		((kRed & 0x00FFFFFF)|0xC0000000)	//(0xA32C9C00)
#define TEXT_COLOR_HILITE_BLUE		((kBlue & 0x00FFFFFF)|0xC0000000)
#define TEXT_COLOR_HILITE_GREEN		((kGreen & 0x00FFFFFF)|0xC0000000)
#define TEXT_COLOR					((kWhite & 0x00FFFFFF)|0xC0000000)	// (0xC0D46400)

#define TEXT_HEIGHT					(18)

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void print(int x, int y, char *str )
{
mdTILE txbg;
int len;

	// The vector font chars are 9 pixels wide each...
	len = strlen(str) * 9;

	// Give ourselves a little extra room
	len += 6;
    
	// Set background tile...
	mdSetScrRECT( &txbg.sr, (x - 2)<<4, (y - 2)<<4, mdGetFarZ(), len<<4, 20<<4 );

	mdSetRGBA(&txbg.color, 64, 64, 64, 0 );				// Dark Grey
	mdDrawTile(mpTILE_FZ, &txbg.sr, &txbg.color );
	mdDrawSync();

	DebugWS(dcx[0].buf[dcx[0].actbuf].dmaflags, (mdUINT32*)(dcx[0].buf[dcx[0].actbuf].sdramaddr), x, y, TEXT_COLOR, str );
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void draw_background_image(mdIMAGE *bgi )
{
mdUINT32	zcmpflags;				//Backup of Z comparator flags

	//Set Background
	//Backup Z Buffer comparison flags
	zcmpflags = dcx[0].zcmpflags[0];

	//Disable Z Buffer comparison (always write Z)
	dcx[0].zcmpflags[0] = WR_Z;

	//Activate the render context with Z overwrite
	mdActiveDrawContext(&dcx[0]);

	//Render Image and write FARZ into ZBuffer (Z value set in bgi.sr)
	mdDrawImage(mpIMG, &bgi->sr, &bgi->color, bgi->img, (mdUINT32*)&bgi->u0);
	
	// Wait for it to finish...
	mdDrawSync();
	
	//Restore original Z Buffer comparison flags
	dcx[0].zcmpflags[0] = zcmpflags;

	//Activate the render context with Z comparison
	mdActiveDrawContext(&dcx[0]);
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
int 		frames;
int			text_y, text_dy;

	//Reserve YCC Drawcontext
	//NUMBUFFERS are 16BitColor+16BitZ (4 bytes/pixel)
	sdramlen = NUMBUFFERS*(SCREENWIDTH*SCREENHEIGHT*4);
	sdramaddr = (mdBYTE*)_MemAlloc(sdramlen,512,kMemSDRAM);
	if (sdramaddr == mdNULL)
	{
		printf("Error: Unable to allocate SDRAM buffer\n");
		fflush(stdout);
	};
	
	mdSetBufYCC16B_WITHZ(dcx, sdramaddr, NUMBUFFERS,SCREENWIDTH,SCREENHEIGHT,0,0,SCREENWIDTH,SCREENHEIGHT);

	//Setup MPR Chain
	mdSetupMPRChain(M3DL_STARTMPE,M3DL_NUMMPE);

	//Setup View Frustum (Even in 2D, NearZ & FarZ need to be initialised)
	mdSetFrustum((60<<16)/360, SCREENWIDTH, SCREENHEIGHT, ((4<<16)/3), 16<<16, 4096<<16);

	//Clear background color
	mdSetRGBA(&background.color,0,0,0,0);
	//Set screen coordinates
	mdSetScrRECT(&background.sr,dcx[0].rendx<<4,dcx[0].rendy<<4,mdGetFarZ(),dcx[0].rendw<<4,dcx[0].rendh<<4);

	//Setup Background Image (if any)
	mdImageDataFromMBI(BackgroundImage,0,&bgimgdata,&bgbitmap);
	
	//Set image data
	background.img = &bgimgdata;
	
	//UV setup (no tiling, no flipping)
	background.u0	= 0<<10;
	background.v0	= 0<<10;
	background.uofs	= 1<<10;
	background.vofs	= 1<<10;

	// Get pointers to buffers, align to 16-byte boundaries
	theTexture = (mdTEXTURE *)(((long)texbuffer + 64) & 0xFFFFFFF0);
	theTextureBitmap = (mdBITMAP *)(((long)theTexture + 64 + sizeof(mdTEXTURE)) & 0xFFFFFFF0);
	
	theTexture2 = (mdTEXTURE *)(((long)texbuffer + 2000) & 0xFFFFFFF0);
	theTexture2Bitmap = (mdBITMAP *)(((long)theTexture2 + 64 + sizeof(mdTEXTURE)) & 0xFFFFFFF0);
	
	theTexture3 = (mdTEXTURE *)(((long)texbuffer + 4000) & 0xFFFFFFF0);
	theTexture3Bitmap = (mdBITMAP *)(((long)theTexture3 + 64 + sizeof(mdTEXTURE)) & 0xFFFFFFF0);
	
	
	// Setup textures
	mdTextureFromMBM( SpriteData, 0, theTexture, theTextureBitmap );
	mdTextureFromMBM( SpriteData2, 0, theTexture2, theTexture2Bitmap );
	mdTextureFromMBM( SpriteData3, 0, theTexture3, theTexture3Bitmap );

	//Clear display before making it active
	mdClearDisp(dcx, &background.color);
	mdDrawSync();

	//Turn On Display	
	_VidSetup((mdUINT32 *)(dcx[0].buf[dcx[0].actbuf].sdramaddr), dcx[0].buf[dcx[0].actbuf].dmaflags, dcx[0].dispw, dcx[0].disph, eFourTapVideoFilter);
	
	//Wait till it is active & set lastfield counter
	dcx[0].lastfield = _VidSync(1);
	
	// Setup the UV coordinates that will be used by everything
	overlay.u0 = 0;
	overlay.v0 = 0;
	overlay.u1 = 0x0400;
	overlay.v1 = 0;
	overlay.u2 = 0;
	overlay.v2 = 0x0400;
	overlay.u3 = 0x0400;
	overlay.v3 = 0x0400;
	overlay.tex = 0; 

#if 0
	// Setup the corner colors, even though they won't be used by a textured QUAD
	mdSetRGBA( &overlay.c[0], 128, 128, 128, 0 );
	mdSetRGBA( &overlay.c[1], 128, 128, 128, 0 );
	mdSetRGBA( &overlay.c[2], 128, 128, 128, 255 );
	mdSetRGBA( &overlay.c[3], 128, 128, 128, 0 );
#endif

	// Initialize the position and movement for all the sprites
	create_sprites(theSprites);

	frames = 1;
	text_dy = 1;
	text_y = 40;

	//Loop the loop
	while (1)
	{
		draw_background_image( &background );
		draw_sprites(frames);

		//Wait for drawing to finish
		mdDrawSync();

#if 0
		str[0] = '0' + frames;
		str[1] = 0;
		print( 660, 30, str );
#endif

		// Draw some text on top...
		print( 50, text_y, "These sprites use textures with a transparent background color..." );
		text_y += text_dy;

		if( (text_y > (SCREENHEIGHT-40)) || (text_y < 40) )
			text_dy = -(text_dy);

		// Swap frame buffers
		frames = SwapDrawBufYCC(dcx);
	};

	return 0;
}

/***************************************************************************/
/* Initialize sprite objects                                               */
/***************************************************************************/

static void create_sprites(Sprite_Position *theSprite)
{
int	i;

	for (i = 0; i < MAX_SPRITES; i++)
	{
		theSprite->x  = BOUNDARY + (rand() % (SCREENWIDTH-(BOUNDARY*2)));
		theSprite->y  = BOUNDARY + (rand() % (SCREENHEIGHT-(BOUNDARY*2)));

		// Convert X/Y to M3DL 28.4 format
		theSprite->x <<= 4;
		theSprite->y <<= 4;

		theSprite->dx = (rand() % MAX_OBJECT_SPEED) + 0x10;
        if( rand() & 0x0001 )
			theSprite->dx = -theSprite->dx;

		theSprite->dy = (rand() % MAX_OBJECT_SPEED) + 0x10;
        if( rand() & 0x0001 )
			theSprite->dy = -theSprite->dy;

		theSprite++;
	}

	fflush( stdout );
}

/***************************************************************************/
/* Draw sprite objects.  Alternate between available textures              */
/* Don't forget that coordinates are shifted left 4 places for M3DL        */
/***************************************************************************/

void draw_sprites(int stepcount)
{
int i, ii, x, y, x2, y2, zpos;
Sprite_Position *theCurrentSprite;

	theCurrentSprite = theSprites;

	for (i = 0; i < MAX_SPRITES; i++, theCurrentSprite++)
	{
		x = theCurrentSprite->x;
		y = theCurrentSprite->y;

		// Increment positions once for each field that went by in last loop
		// This isn't very efficient, by the way.
		for( ii = 0; ii < stepcount; ii ++ )
		{
			/* detect reflection */
			x += theCurrentSprite->dx;
			y += theCurrentSprite->dy;

			if( x > (WALL_RIGHT<<4) || x < (BOUNDARY<<4) )
				theCurrentSprite->dx = -(theCurrentSprite->dx);

			if( y > (WALL_BOTTOM<<4) || y < (BOUNDARY<<4) )
				theCurrentSprite->dy = -(theCurrentSprite->dy);	
		}

		theCurrentSprite->x = x;
		theCurrentSprite->y = y;

		// Set Z-depth according to sprite number, so that the sprites are prioritized
		zpos = mdGetNearZ() + (i * 1000);

		// Get coordinate for opposite corner by adding size
		x2 = x + (64 << 4);
		y2 = y + (64 << 4);

		// Set up the screen vectors for the QUAD primitive
		mdSetScrVector(&overlay.v[0], x, y, zpos );
		mdSetScrVector(&overlay.v[1], x2, y, zpos );
		mdSetScrVector(&overlay.v[2], x, y2, zpos );
		mdSetScrVector(&overlay.v[3], x2, y2, zpos );

		// Figure out which texture to use and draw the sprite
		switch( i % 3 )
		{
			case 0:
				mdDrawPoly( mpQUAD_BT, (mdScrV3 *)&overlay.v, (mdCOLOR *)&overlay.c, theTexture, (mdUINT32 *)&overlay.u0 );
				break;

			case 1:
				mdDrawPoly( mpQUAD_BT, (mdScrV3 *)&overlay.v, (mdCOLOR *)&overlay.c, theTexture2, (mdUINT32 *)&overlay.u0 );
				break;

			case 2:
				mdDrawPoly( mpQUAD_BT, (mdScrV3 *)&overlay.v, (mdCOLOR *)&overlay.c, theTexture3, (mdUINT32 *)&overlay.u0 );
				break;

			default:
				mdDrawPoly( mpQUAD_G, (mdScrV3 *)&overlay.v, (mdCOLOR *)&overlay.c, theTexture3, (mdUINT32 *)&overlay.u0 );
				break;
		}
	}
}

