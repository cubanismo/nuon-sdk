/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "sg.h"


// Draw the table with group number group_num hilighted.  Singleton
// groups have group number -1; active groups have numbers between 1
// and num_of_groups; note that we are passing group_num = -2 in the
// case that no group is to be highlighted

// This version of high_lite copies blits instead of drawing
// circles; it redraws the entire table each time
int high_lite_group2(int group_num)
{
  extern struct Balls Balls;
  extern int PixMap;
  extern m2dRect balltable[5][4];

  int i, j, n, sp, x, y;

  sp = 0;

  // copy the entire background
  MyCopyRect(0, 0, SOURCE_WIDTH-1, SOURCE_HEIGHT-1, &background, 
             0, 0, &screen[PixMap]);

  // draw balls with a predetermined group highlited
  for (i = 0; i < COL_NUM; i++)
    for (j = 0; j < ROW_NUM; j++){
      if (Balls.colour[i][j] != -99){
	n = Balls.colour[i][j];
	sp = (Balls.special[i][j] == 0) ? 0 : 2;
	if (Balls.group[i][j] == group_num){
	  // draw the highlighted version of the balls (white background)
	  if (TILE_TRANSPARENCY == 1){
	    myCopyRectDisBlend(&gc, &balls, &screen[PixMap], &balltable[n][0+sp], 
		 m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }else{
	    myCopyRectDis(&gc, &balls, &screen[PixMap], &balltable[n][0+sp], 
                 m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }
	}else{
	  // draw default version of balls (grey background)
	  if (TILE_TRANSPARENCY == 1){
	  myCopyRectDisBlend(&gc, &balls, &screen[PixMap], &balltable[n][1+sp], 
                 m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));

	  }else{
	  myCopyRectDis(&gc, &balls, &screen[PixMap], &balltable[n][1+sp], 
                 m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }
	}
      }else{  
	// when Balls.colour = -99 we blit in a copy of the background
	x = UP_LEFT_X+(i*SQU_WIDTH);
	y = UP_LEFT_Y+(j*SQU_WIDTH);
	// adjusted to copy in a "mat" which is separate from the backgrnd
	MyCopyRect(x, y, x+SQU_WIDTH-1, y+SQU_WIDTH-1, &background, 
		   x, y, &screen[PixMap]);
      }
    }

  return 0;
}


// this version of high_lite_group2 only draws the balls which have
// changed since the last draw; specifically, we copy the image from
// the last buffer and then make changes such as when a new group is
// to be highlighted and old one isn't *or* if the cursor has moved
//
int high_lite_group3(int group_num, int old_group_num, int toggled, int cur_moved, int old_cur_x, int old_cur_y)
{
  extern struct Balls Balls;
  extern int PixMap;
  extern m2dRect balltable[5][4];

  int i, j, n, sp;
  int x, y;
  int old_PixMap;
  int row[4], col[4], shifted_x, shifted_y;

  sp = 0;

  old_PixMap = (PixMap > 0) ? (PixMap-1) : 2;

  // copy the entire previous screen over (probably could get away with
  // only copying the balls table and the mat)
  MyCopyRect(0, 0, SCRN_WIDTH-1, SCRN_HEIGHT-1, &screen[old_PixMap], 
	     0, 0, &screen[PixMap]);
  // and copy in the bottom of the background (which has no score 
  // information) so that the scores will look correct when copied to
  MyCopyRect(0, SCORE_Y, SOURCE_WIDTH-1, SOURCE_HEIGHT-1, &background, 
	     0, SCORE_Y, &screen[PixMap]);

  // Only redraw if group_num has changed or if a special tile has
  // been toggled; in the case that the cursor has moved but stayed on
  // the same group, the code further below will take care of it
  if ((group_num != old_group_num) || (toggled == 1)){
    
    // redraw old_group_num and group_num 
    for (i = 0; i < COL_NUM; i++){
      for (j = 0; j < ROW_NUM; j++){
	
	sp = (Balls.special[i][j] == 0) ? 0 : 2;
	
	if ((Balls.group[i][j] == old_group_num) || (toggled == 1)){
	  //      if ((Balls.group[i][j] == old_group_num)){
	  n = Balls.colour[i][j];
	  if (n != -99){
	    if (TILE_TRANSPARENCY == 1){
	      // copy in the background (so the white highlight is
	      // copied over) we have to do this whenever the
	      // background shows through the tiles such as the Balls
	      // version
	      x = UP_LEFT_X+(i*SQU_WIDTH);
	      y = UP_LEFT_Y+(j*SQU_WIDTH);
	      MyCopyRect(x, y, x+SQU_WIDTH-1, y+SQU_WIDTH-1, &background, 
			 x, y, &screen[PixMap]);
	      // now copy in the ball tile
	      myCopyRectDisBlend(&gc, &balls, &screen[PixMap], &balltable[n][1+sp], 
		   m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	    }else{
	      // now copy in the ball tile
	      myCopyRectDis(&gc, &balls, &screen[PixMap], &balltable[n][1+sp], 
		     m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	    }
	  }
	}
	
	// draw the highlighted version of the balls (white background)
	if ( (group_num != -2) && (Balls.group[i][j] == group_num) ){
	  n = Balls.colour[i][j];
	  if (TILE_TRANSPARENCY == 1){
	    myCopyRectDisBlend(&gc, &balls, &screen[PixMap], &balltable[n][0+sp], 
		     m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }else{
	    myCopyRectDis(&gc, &balls, &screen[PixMap], &balltable[n][0+sp], 
                     m2dSetPoint(UP_LEFT_X+(i*SQU_WIDTH),UP_LEFT_Y+(j*SQU_WIDTH)));
	  }
	}
	
      }
    }

  } // end of "if ((group_num != old_group_num) || (toggled == 1)){"


  // REDRAW SOME SQUARES IF THE CURSOR HAS MOVED
  // To Do: revamp this clunky code
  if (cur_moved == 1){

    // from the x,y coordinates and using the width of the cursor
    // (plus a little bit more) we determine which cells/balls to
    // redraw

    // shift the table 
    shifted_x = old_cur_x - UP_LEFT_X;
    shifted_y = old_cur_y - UP_LEFT_Y;

    // adding "4" seems to make the problem better. the problem being
    // that diagonal moves of the cursor sometimes leave a ghost. I've
    // reduced CUR_SPEED which has helped and added 4 to CURSOR_RAD
    // below.

    row[0] = (int)( (shifted_y-(CURSOR_RAD+4)) / SQU_WIDTH );
    col[0] = (int)( (shifted_x-(CURSOR_RAD+4)) / SQU_WIDTH );

    row[1] = (int)( (shifted_y-(CURSOR_RAD+4)) / SQU_WIDTH );
    col[1] = (int)( (shifted_x+(CURSOR_RAD+4)) / SQU_WIDTH );

    row[2] = (int)( (shifted_y+(CURSOR_RAD+4)) / SQU_WIDTH );
    col[2] = (int)( (shifted_x+(CURSOR_RAD+4)) / SQU_WIDTH );

    row[3] = (int)( (shifted_y+(CURSOR_RAD+4)) / SQU_WIDTH );
    col[3] = (int)( (shifted_x-(CURSOR_RAD+4)) / SQU_WIDTH );

    // a kludge so that we don't pick an out of bounds cell
    // hmm, my math above must be off in that this is happening OR
    // the ball is off the table when the calculations are done
    for (i = 0; i < 4; i++){
      if (row[i] == ROW_NUM)
	row[i] = row[i]-1;
      if (col[i] == COL_NUM)
	col[i] = col[i]-1;
    }

    // redraw the cells; ignoring fact we may be drawing the same cell
    // twice or four times 
    for (i = 0; i < 4; i++){
      // copy in the appropiate square from the background mat;
      // orginally this only happened when Balls.colour[][] = -99
      // below, but then in the case of transparancy (Balls version)
      // the cursor wasn't being erased
      x = UP_LEFT_X+(col[i]*SQU_WIDTH);
      y = UP_LEFT_Y+(row[i]*SQU_WIDTH);
      MyCopyRect(x, y, x+SQU_WIDTH-1, y+SQU_WIDTH-1, &background, 
		 x, y, &screen[PixMap]);

      sp = (Balls.special[col[i]][row[i]] == 0) ? 0 : 2;

      if (Balls.colour[col[i]][row[i]] != -99){
	if (Balls.group[col[i]][row[i]] != group_num){
	  // draw the ball with grey background
	  n = Balls.colour[col[i]][row[i]];
	  if (TILE_TRANSPARENCY == 1){
	    myCopyRectDisBlend(&gc, &balls, &screen[PixMap], &balltable[n][1+sp], 
			  m2dSetPoint(UP_LEFT_X+(col[i]*SQU_WIDTH),
				      UP_LEFT_Y+(row[i]*SQU_WIDTH)));
	  }else{
	    myCopyRectDis(&gc, &balls, &screen[PixMap], &balltable[n][1+sp], 
			  m2dSetPoint(UP_LEFT_X+(col[i]*SQU_WIDTH),
				      UP_LEFT_Y+(row[i]*SQU_WIDTH)));
	  }
	}else{
	  // draw highlighted version of ball
	  n = Balls.colour[col[i]][row[i]];
	  if (TILE_TRANSPARENCY == 1){
	  myCopyRectDisBlend(&gc, &balls, &screen[PixMap], &balltable[n][0+sp], 
			 m2dSetPoint(UP_LEFT_X+(col[i]*SQU_WIDTH),
                         UP_LEFT_Y+(row[i]*SQU_WIDTH)));
	  }else{
	  myCopyRectDis(&gc, &balls, &screen[PixMap], &balltable[n][0+sp], 
			 m2dSetPoint(UP_LEFT_X+(col[i]*SQU_WIDTH),
                         UP_LEFT_Y+(row[i]*SQU_WIDTH)));
	  }
	}
      }
    }
  } // if cursor has moved

  return 0;
}


// copies in the cursor with centre at (x,y); cursor is found in
// extra.tga
int draw_cursor2(int cur_x, int cur_y)
{
  extern int PixMap;

  MyCopyRectTrans(CUR_L_X, CUR_L_Y, CUR_R_X, CUR_R_Y, &playagain, 
           cur_x-CURSOR_RAD, cur_y-CURSOR_RAD, &screen[PixMap]);

  return 0;
}


// copies mat onto the background displaypixmap; in future we'll
// have a choice of mats plus (maybe) a choice of dimensions and
// positions where to place the mat
int copy_mat_to_backgrnd(int i)
{

  if (i < NUM_MATS){
    MyCopyRect(0, 0, MAT_WIDTH-1, MAT_HEIGHT-1, &mats[i], 
    	       UP_LEFT_X, UP_LEFT_Y, &background);
  }

  return 0;
}



