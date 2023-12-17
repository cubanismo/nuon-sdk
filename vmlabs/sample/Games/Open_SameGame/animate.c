
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include "sg.h"


// animate_group2 is based on highlight3 code; we only draw the tiles
// which are being animated and leave everything else as is: the
// score, the other tiles.  Note that the cursor disappears during the
// animation sequence (fix this).
//
int animate_group2(mmlFontContext fc, mmlFont sysP, int group_num, int old_group_num, int n_colours, int count, int mode)
{
  extern struct Balls Balls;
  extern int PixMap;
  extern mmlDisplayPixmap screen[3];
  extern m2dRect balltable[5][4];
  extern m2dRect animtable[8][10];

  int i, j, k, n, sp1, sp2, old_PixMap;
  sp1 = 0;
  sp2 = 0;

  for (k = 0; k < NUM_ANIM_STEPS; k++){

    // slow things down a bit; if table is larger then the tiles take
    // longer to draw, so don't pause as long
    if (COL_NUM < 13)
      pause_a_bit(0.085);
    else
      pause_a_bit(0.05);

    // switch screens
    old_PixMap = PixMap;
    PixMap = (PixMap < 2) ? (PixMap+1) : 0;
    // copy in the old screen the first 3 times
    if (k < 3){
      MyCopyRect(0, 0, SOURCE_WIDTH-1, SOURCE_HEIGHT-1, &screen[old_PixMap], 
		 0, 0, &screen[PixMap]);
    }

    // draw balls with predetermined group highlighted and animated; as
    // this is the only thing happening we don't have to redraw the rest
    // of the screen
    for (i = 0; i < COL_NUM; i++)
      for (j = 0; j < ROW_NUM; j++){

	// in game mode it is possible that the last group to be
	// high-lighted is the old_group_num (this happens if we press
	// A right after moving the cursor from one group to another);
	// so lets make sure, for k=0, that the old group is redrawn
	if ((mode == 1) && (k == 0) && (Balls.group[i][j] == old_group_num)){
	  n = Balls.colour[i][j];
	  sp1 = (Balls.special[i][j] == 0) ? 0 : 2;
	  // Currently no animated tiles are using transparancy, but future
	  // versions of SameGame might.
	  if (TILE_TRANSPARENCY == 1){
	    myCopyRectDisBlend(&gc, &balls, &screen[PixMap], &balltable[n][1+sp1], 
			  m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }else{
	    myCopyRectDis(&gc, &balls, &screen[PixMap], &balltable[n][1+sp1], 
			  m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }
	}

	if (Balls.group[i][j] == group_num){
	  // determine the type of tile
	  n = Balls.colour[i][j];
	  // the special tiles are located below the regular tiles in
	  // the tga file; sp2 gives the offset
	  sp2 = (Balls.special[i][j] == 0) ? 0 : 4;

	  // draw the animated version of the tiles
	  if (TILE_TRANSPARENCY == 1){
	    myCopyRectDisBlend(&gc, &anim, &screen[PixMap], &animtable[n+sp2][k], 
			  m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }else{
	    myCopyRectDis(&gc, &anim, &screen[PixMap], &animtable[n+sp2][k], 
			  m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }
	}
      }

    /*************************************************************/
    // DISPLAY SCREEN
    My_ConfigMain(&video_ch, &screen[PixMap], 0, 0 );
    if (VFILT_4TAP == 1){
      video_ch.vfilter = VID_VFILTER_4TAP;
    }else{
      video_ch.vfilter = VID_VFILTER_2TAP;
    }
    _VidConfig(&display, &video_ch, (void *)0, (void *)0);
      /*************************************************************/

  }  // end k loop

  return 0;
}
