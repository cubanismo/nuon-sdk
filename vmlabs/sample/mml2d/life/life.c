/* Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission 
 */
 

/* This is an implementation of the game of life invented by 
John H. Conway.  This description is from Scientific Americand
April 1999 p. 41 42 by Mark Alpert : 

In the game, you start with a pattern of checkers on the grid -- these
represent the "live" cells.  You then remove each checker that has one
or no neighboring checkers or four or more neighbors (these cells
"die" from loneliness or overcrowding).  Checkers with two or three
neighbors remain on the board.  In addition, new cells are "born" -- a
checker is added to each empty space that is adjacent to exactly three
checkers.  By applying these rules repeatedly, one can create an
amazing variety of Life forms, including "gliders" and "spaceships"
that steadily move across the grid.

*/

#include "aux2d.h"
#include "auxvid.h"
#include <nuon/mml2d.h>
#include <stdio.h>
#include <stdlib.h>

/* We bounce back and forth between grid A and grid B.
Each grid is W wide x H high.
*/

#define H 48
#define W 64

/* Some graphics settings */
#define BASE (void*)0x40000000
#define BASE_TOP (0x40000000 + 2*1024*1024)
#define DEFAULT_BORDER_COLOR kBlack

int births =0;
int deaths = 0;

/* return the number of live nighbors (0 to 8). Cells on
edge of grid only count neighboring cells in grid */
int neighbors( int x[H][W], int row, int col )
{
	int n = 0;
	int rowMin = row == 0 ? 0 : row-1;
	int rowMax = row == H-1 ? H-1 : row+1;
	int colMin = col == 0 ? 0 : col-1;
	int colMax = col == W-1 ? W-1 : col+1;
	int j,k;
	
	for( j=rowMin; j<=rowMax; ++j )
		for( k=colMin; k<=colMax; ++k)
			if( j != row || k != col )
				if( x[j][k] != 0 ) ++n;
	return n;
}

/* update the state of one grid from another grid
*/
void newGeneration( int x[H][W], int y[H][W] )
{
	int row, col;
	for( row = 0; row<H; ++row )
		for( col=0; col<W; ++col )
		{
			int n = neighbors( x, row, col );
			int v = x[row][col];
			if( v > 8 ) v = 8;
			if( v > 0 )
			{
				if( n == 2 || n== 3 )
					y[row][col] = v+1;
				else
				{
					y[row][col] = 0;
					++deaths;
				}
			}
			else if( n == 3 )
			{
				y[row][col] = 1;
				++births;
			}
			else y[row][col] = 0;
		}
}

/* initialize grid */
void initGrid( int x[H][W] )
{
	int row, col;
	int thresh = 5;
	for( row = 0; row<H; ++row)
		for( col=0; col<W; ++col )
			if( rand()%10 > thresh )
			{
				 x[row][col] = 1;
				 ++births;
			}
			else x[row][col] = 0;
}

void drawGrid(mmlGC* gc, mmlDisplayPixmap* screen, int grid[H][W], int object)           /* Function to print the array. */
{
        int y,x;
        int xsize = 18;
        int ysize = 16;
        int row, col;
        m2dRect r;
        int xStart = 0;
        int yStart = 0;
 	mmlColor colors[10] = { kGray, kCyan, kBlue, kGreen, kWhite, kYellow, kRed, kMagenta, kBlack, kBlack };
        
        for (y=0;y < H; y++)
        {
        	row = yStart + y*ysize;
            for (x=0;x < W; x++)
            {
          		col = xStart + x*xsize;
   //       		object = 0;
          		if( row + ysize <= 480 &&
          			col+xsize <=720 )
          		switch( object )
          		{
          		case 2:
          		case 1:
          		case 0:
	         		m2dSetRect( &r, col, row, col+xsize-1, row+ysize-1 );
	          		m2dFillColr(gc, screen, &r, colors[grid[y][x]] );
	          		break;
/* NOT SUPPORTED in SDK > 0.87 
	          	case 1:
	 			gc->defaultES.foreColor = colors[grid[y][x]];
	 	 		gc->defaultES.fill = 1;
				gc->defaultES.width = 1; 			
	  			m2dDrawEllipse( gc, screen, col, row, xsize/2 );
	  			break;

	          	case 2:
	 			gc->defaultES.foreColor = colors[grid[y][x]];
	 			gc->defaultES.fill = 0;
	 			gc->defaultES.width = 0xd000; 			
	  			m2dDrawEllipse( gc, screen, col, row, xsize/2 );
	  			break;
*/
  			}
          	}
        }
}

int main( )
{
	int X[H][W], Y[H][W];
	int object;

     	mmlSysResources sysRes;
    	mmlGC gc;
    	mmlFontContext fc;
    	mmlFont sysP;
    	mmlDisplayPixmap screen, osd;
    	VidDisplay display;
    	VidChannel mainch, osdch;
 	mmlColor ycc[256];

/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );
/* Setup fonts */
	mmlInitFontContext( &gc, &sysRes, &fc, 4096 );
	sysP = mmlAddFont( fc, "sysFont", eT2K, SysFont, SysFontEnd-SysFont );

/* Initialize a single display pixmap as a framebuffer to be used as main channel
   720 pixels wide by 480 lines tall, using 16 bit YCC-alpha pixels. */
    mmlInitDisplayPixmaps( &screen, &sysRes, 720, 480, e888Alpha, 1, NULL );
/* Set all the pixels in the main channel display pixmap to gray */
	m2dFillColr( &gc, &screen, NULL, kGray );
 /* Initialize the display configuration */
    memset(&display, 0, sizeof(display));
    display.dispwidth = -1;
    display.dispheight = -1;
    display.bordcolor = DEFAULT_BORDER_COLOR;
    display.progressive = 0;

/* Initialize the main channel from the main display pixmap */
	mmlConfigMain( &mainch, &screen, 0, 0 );
/* Initialize a single display pixmap as a CLUT framebuffer to be used as overlay channel
*/
    mmlInitDisplayPixmaps( &osd, &sysRes, 720, 240, eClut8, 1, NULL );
/* Create a color palette to be used in osd channel and write it to VDG */
	makePalette1( ycc );
	ycc[1] = kBlack | 0xA0;
	ycc[2] = kBlack | 0x60;
	ycc[3] = kBlack | 0x00;
	ycc[200] = kBlue | 0xF0;
	ycc[201] = kBlue | 0xF0;
	ycc[202] = kBlue | 0xE0;
	ycc[203] = kBlue | 0xD0;
	ycc[204] = kBlue | 0xC0;
	ycc[205] = kBlue | 0xB0;
	ycc[206] = kBlue | 0xA0;
	ycc[207] = kBlue | 0x90;
	ycc[208] = kBlue | 0x80; 
	ycc[209] = kBlue | 0x70;
	ycc[210] = kBlue | 0x60;
	ycc[211] = kBlue | 0x50;
	ycc[212] = kBlue | 0x40;
	ycc[213] = kBlue | 0x30;
	ycc[214] = kBlue | 0x20;
	ycc[215] = kBlue | 0x10;
	ycc[216] = kBlue | 0x00; 
	ycc[217] = kBlack | 0x60;
	ycc[218] = kBlack | 0x80; 

	mmlSetClut( ycc, 0, 255 );
  	 
/* Set all the pixels in the osd channel display pixmap to transparent */
	m2dFillColr( &gc, &osd, NULL, 0 );
/* Initialize the osd channel from the osd display pixmap */
	mmlConfigOSD( &osdch, &osd, 0, 240, 1 );

/* Configure the VDG channels and activate them */
    _VidConfig(&display, &mainch, &osdch, (void *)0);
/* Draw a translucent rect */
	{
		m2dRect s;
		m2dSetRect( &s, 480, 112, 649, 177 );
		m2dFillColr( &gc, &osd, &s, (217<<24) | (218<<16) | (217<<8) | 218 );
	}
     
/* Draw some text in OSD plane */
	{
		m2dRect r;
		m2dSetRect( &r, 500, 112, 720, 240 );
		gc.textBase = 200;
		gc.textDiv = 4;
		gc.textMin = 216;
		gc.textMax = 216; 
	      gc.defaultES.alpha = 0;
		mmlSetTextProperties( fc, sysP, 72, 216, 200, eClutAlpha, 0, 0 ); 
		mmlSimpleDrawText( fc, &osd, "NUON", 4, &r );
	}
/* Draw an ellipse in OSD plane 	
 		gc.defaultES.foreColor = 218;
 		gc.defaultES.fill = 1;
		gc.defaultES.width = 1; 			
		m2dDrawEllipse( &gc, &osd, 480, 112, 4 );
*/
	
	while( 1 )
	{
		births = deaths = 0;	
		initGrid( X );
		m2dFillColr( &gc, &screen, NULL, kGray );
		object = rand( )%3;
		while( births - deaths > 400 )
		{
			drawGrid( &gc, &screen, X, object );
			newGeneration( X, Y );
			drawGrid( &gc, &screen, Y, object );
			newGeneration( Y, X );
		}
	}
	return 0;
}
	

			
	
