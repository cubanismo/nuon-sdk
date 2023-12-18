/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

// here are various ftns which count the number of
// (something) in the table of tiles


#include "sg.h"

// given a colour returns the number of tiles of that colour
int colour_stats(int colour_number)
{
  extern struct Balls Balls;
  int i, j;
  int n = 0;
  
  for (i = 0; i < COL_NUM; i++){
    for (j = 0; j < ROW_NUM; j++){
      if (Balls.colour[i][j] == colour_number)
	n = n + 1;
    }
  }
    
  return n;
}

// given a group number, ftn returns size of that group 
int group_stats(int group_num)
{
  extern struct Balls Balls;
  int i, j;
  int n = 0;

  for (i = 0; i < COL_NUM; i++){
    for (j = 0; j < ROW_NUM; j++){
      if (Balls.group[i][j] == group_num)
	n = n + 1;
    }
  }
  
  return n;
}

// ftn returns 0 if no special balls left in the ball table; 1
// otherwise
int num_special_balls()
{
  extern struct Balls Balls;
  int i, j;

  for (i = 0; i < COL_NUM; i++)
    for (j = 0; j < ROW_NUM; j++)
      if (Balls.special[i][j] == 1){
	return 1;
      }

  return 0;
}

// ftn returns the colour of a given group; -1
// if can't find the group
// it doesn't check to see if the colour is not one of 0,..,3
int det_colour_frm_groupnum(int group_num)
{
  extern struct Balls Balls;
  int i, j;

  for (i = 0; i < COL_NUM; i++)
    for (j = 0; j < ROW_NUM; j++)
      if (Balls.group[i][j] == group_num)
	if ((Balls.colour[i][j] > -1) && (Balls.colour[i][j] < 4))
	  return Balls.colour[i][j];

  return -1;
}


// ftn returns number of balls left in the table
int count_balls()
{
  extern struct Balls Balls;
  int number_balls = 0;
  int i,j;

  for (i = 0; i < COL_NUM; i++)
    for (j = 0; j < ROW_NUM; j++)
      if (Balls.colour[i][j] != -99){
	number_balls = number_balls + 1;
      }

return number_balls;
}

// for debugging
int count_colours(int n_colours)
{
  int col[4];
  int i, j;

  for (i = 0; i < 4; i++)
    col[i] = 0;

  for (i = 0; i < COL_NUM; i++)
    for (j = 0; j < ROW_NUM; j++){
      if (Balls.colour[i][j] > -1)
	col[(Balls.colour[i][j])] = col[(Balls.colour[i][j])] + 1;
    }

  printf("col1 = %d, col2 = %d, col3 = %d, col4 = %d\n", col[0], col[1], col[2], col[3]);

  return 0;
}
