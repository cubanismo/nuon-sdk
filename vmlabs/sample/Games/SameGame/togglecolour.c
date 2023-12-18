/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */


#include "sg.h"

int toggle_colour(int cur_x, int cur_y)
{
  extern struct Balls Balls;
  int col, row;

  // determine the row and col
  col = (int)((cur_x - UP_LEFT_X)/SQU_WIDTH);
  row = (int)((cur_y - UP_LEFT_Y)/SQU_WIDTH);

  if (Balls.special[col][row] == 1){
    // change the colour of the ball
    Balls.colour[col][row] =
             (Balls.colour[col][row] < 3) ? Balls.colour[col][row] + 1 : 0;
    return 1;
  }

  // 0 is returned if no special ball in that row or column
  return 0; 
}
