/*
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
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>

#include "showpic.h"
#include "proto.h"

#include "dmacalls.h"


////////////////////////////////////////////////////////////////////////////
// Draw the background image.
////////////////////////////////////////////////////////////////////////////

#define DMA_SEGMENT_LENGTH	(45)	// Presumes that 1 pixel = 1 longword
#define DMA_SEGMENT_COUNT	(2)

void draw_picture(long *picture)
{
long *theScanline, scratchsize;
int xx, yy;
OtherBusDMACommand *oDMA_cmd1, *oDMA_cmd2;

	// Get address of internal memory scratch buffer
	// to use for DMA command buffers and image buffer
	long *cmdbuf = _MemLocalScratch((void *)&scratchsize);
	long *imgbuf = cmdbuf + IMAGE_BUF_OFFSET;
    
	oDMA_cmd1 = (OtherBusDMACommand *)&cmdbuf[ODMA_CMDBUF1];
	oDMA_cmd2 = (OtherBusDMACommand *)&cmdbuf[ODMA_CMDBUF2];

	cmdbuf[MDMA_CMDBUF1 + 0] = gl_screenbuffers[gl_drawbuffer].dmaFlags;		// Flags
	cmdbuf[MDMA_CMDBUF2 + 0] = gl_screenbuffers[gl_drawbuffer].dmaFlags;		// Flags

	cmdbuf[MDMA_CMDBUF1 + 1] = (long)gl_screenbuffers[gl_drawbuffer].memP;	// Destination buffer
	cmdbuf[MDMA_CMDBUF2 + 1] = (long)gl_screenbuffers[gl_drawbuffer].memP;	// Destination buffer

	oDMA_cmd1->flags = (1<<13) | (DMA_SEGMENT_LENGTH << 16);		// flags = READ, # longs
	oDMA_cmd2->flags = (1<<13) | (DMA_SEGMENT_LENGTH << 16);

	theScanline = picture;

	//////////////////////////////////////////////////////////////////////////////
	// DMA COMMAND BUFFER NOTE:
	//////////////////////////////////////////////////////////////////////////////
	// For main bus DMA, we switch between 3 separate command buffers.
	// For Other bus DMA, we have another 3 separate command buffers.
	//////////////////////////////////////////////////////////////////////////////
	// This avoids the problem of overwriting a command buffer that hasn't
	// been executed yet.
	//////////////////////////////////////////////////////////////////////////////

	// Reads & writes are interleaved for maximum throughput
	// Image size must be evenly divisible by
	// (DMA_SEGMENT_LENGTH * DMA_SEGMENT_COUNT)

	for( yy = 0; yy < SCREENHEIGHT; yy++ )
	{
		for( xx = 0; xx < SCREENWIDTH; xx+= (DMA_SEGMENT_LENGTH * DMA_SEGMENT_COUNT) )
		{											
			// Wait for write from previous pass of loop to finish
			while( mdma_status() >= DMA_SEGMENT_COUNT );
	
	// Read 1st section
			oDMA_cmd1->ram_address = theScanline;
			oDMA_cmd1->mpe_address = imgbuf;
			odma_command(oDMA_cmd1);
	
			while( mdma_status() >= DMA_SEGMENT_COUNT );
	
	// Read 2nd section
			oDMA_cmd2->ram_address = theScanline + DMA_SEGMENT_LENGTH;
			oDMA_cmd2->mpe_address = imgbuf + DMA_SEGMENT_LENGTH;
			odma_command(oDMA_cmd2);
	
			while( odma_status() >= DMA_SEGMENT_COUNT );
	
	// Write 1st section
			cmdbuf[MDMA_CMDBUF1 + 2] = (xx)|(DMA_SEGMENT_LENGTH<<16);
			cmdbuf[MDMA_CMDBUF1 + 3] = (yy)|(1<<16);
			cmdbuf[MDMA_CMDBUF1 + 4] = (long)imgbuf;
			mdma_command(&cmdbuf[MDMA_CMDBUF1]);
	
			while( odma_status() >= DMA_SEGMENT_COUNT );
	
	// Write 2nd section
			cmdbuf[MDMA_CMDBUF2 + 2] = (xx+DMA_SEGMENT_LENGTH)|(DMA_SEGMENT_LENGTH<<16);
			cmdbuf[MDMA_CMDBUF2 + 3] = (yy)|(1<<16);
			cmdbuf[MDMA_CMDBUF2 + 4] = (long)(imgbuf+DMA_SEGMENT_LENGTH);
			mdma_command(&cmdbuf[MDMA_CMDBUF2]);
		
			// Increment pointer to next scanline
			theScanline += (DMA_SEGMENT_LENGTH * DMA_SEGMENT_COUNT);
		}
	}

	// Let DMA completely finish before we leave!
	while( mdma_status() );
}

////////////////////////////////////////////////////////////////////////////
// Clear the screen... Divide into segments
////////////////////////////////////////////////////////////////////////////

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

