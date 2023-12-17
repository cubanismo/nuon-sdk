
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 10/20/98
 * Made TAJ's DrawLinePlus a real merlin rendering proc.
 */
 
#include "mrpproto.h"
#include "parblock.h"
#include "mrptypes.h"
#include "pixmacro.h"

mrpStatus DrawLinePlus(int environs, DrawLineParamBlock* externParP, int lineType, int arg3)
{
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	DrawLineParamBlock* internParP;
 	int* tileBaseP;
 	int* endP;

 	int parSizeLongs = (sizeof(DrawLineParamBlock)+3)>>2;

 //	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&internParP, (uint8**)&tileBaseP, &endP ) )
 // 		mrpSysRamMove( parSizeLongs, (char*) internParP, (char*) externParP, odmaP, kSysReadFlag, 1 );
 // 	else internParP = externParP;
 	mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&internParP, (uint8**)&tileBaseP, &endP );
 	mrpSysRamMove( parSizeLongs, (char*) internParP, (char*) externParP, odmaP, kSysReadFlag, 1 );
	_SetLocalVar( internParP->dma__cmdAddr, mdmaP);
	_SetLocalVar( internParP->odmacmdAddr, odmaP);
	_SetLocalVar( internParP->genbufAddr, tileBaseP);

	switch( lineType )
	{
	case eaaline1:
		draw_line1( environs, internParP, 0, arg3 );
		break;
	case eaaline2:
		draw_line2( environs, internParP, 0, arg3 );
		break;
	case eaaline3:
		draw_line3( environs, internParP, 0, arg3 );
		break;
	case eaaline4:
		draw_line4( environs, internParP, 0, arg3 );
		break;
	case eaaline5:
		draw_line5( environs, internParP, 0, arg3 );
		break;
	case eaaline6:
		draw_line6( environs, internParP, 0, arg3 );
		break;
	case eaaline3clut:
		draw_line3clut( environs, internParP, 0, arg3 );
		break;
	case eaaline7clut:
		draw_line7clut( environs, internParP, 0, arg3 );
		break;
	}

	return eFinished;
}

mrpStatus DrawEllipsePlus(int environs, DrawEllipseParamBlock* externParP, int ellipseType, int arg3)
{
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	DrawEllipseParamBlock* internParP;
 	int* tileBaseP;
 	int* endP;

 	int parSizeLongs = (sizeof(DrawEllipseParamBlock)+3)>>2;

 	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&internParP, (uint8**)&tileBaseP, &endP ) )
  		mrpSysRamMove( parSizeLongs, (char*) internParP, (char*) externParP, odmaP, kSysReadFlag, 1 );
  	else internParP = externParP;
  	
	_SetLocalVar( internParP->dma__cmdAddr, mdmaP);
	_SetLocalVar( internParP->genbufAddr, tileBaseP);

	switch( ellipseType )
	{
	case eellipse1:
	    draw_ellipse( environs, internParP, 0, 0 );
		break;
	case eellipseclut8:
		draw_clut_ellipse( environs, internParP, 0, arg3 );
		break;
    }

	return eFinished;
}

