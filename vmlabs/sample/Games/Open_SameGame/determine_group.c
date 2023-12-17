
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


// This function determines all the possible groups in the ball
// table and assigns a number to each group.  Singleton groups 
// are always assigned a "-1"; thus we don't differentiate between
// them.  This function also returns the total number of (non-trivial)
// groups.
int det_group()
{
  extern struct Balls Balls;
  int i,j, group_num;

  // we start by giving all balls group number 0
  for (i = 0; i < COL_NUM; i++)
    for (j = 0; j < ROW_NUM; j++){
      if (Balls.group[i][j] != -99){
	Balls.group[i][j] = 0;  // -1 = singleton, 0 = not yet determined, 
                                // 1 to n = group number
      }
    }

  group_num = 1;

  for (i = 0; i < COL_NUM; i++)
    for (j = 0; j < ROW_NUM; j++){
      // -1 singleton, 0 not found, 1-n group number
      //check here if it's a singleton or not
      if (!singleton(i,j)){
	if (Balls.group[i][j] == 0){
	  Balls.group[i][j] = group_num;
	  det_neigh_group(i, j, group_num);
	  group_num = group_num + 1;
	} 
      }else{ 
	// the ftn singleton() says it's a singleton but let's make
	// sure we aren't tagging an empty tile.  It is possible, at
	// this time, for singleton() to decide that a -99 tile is a
	// singleton.
	if (Balls.colour[i][j] != -99){
	  Balls.group[i][j] = -1;
	}
      }
    }
  return group_num-1;
}

// ftn returns 1 if the this ball has a group size of 1 (i.e. it's a
// singleton) and returns 0 otherwise
int singleton(int i, int j)
{
  extern struct Balls Balls;

  int left = (i == 0) ? 0 : i-1;
  int top = (j == 0) ? 0 : j-1;
  int right = (i == COL_NUM-1) ? i : i+1;
  int bott = (j == ROW_NUM-1) ? j : j+1;

  if (((left != i) && (Balls.colour[left][j] == Balls.colour[i][j]))
      || ((top != j) && (Balls.colour[i][top] == Balls.colour[i][j]))
      || ((right != i) && (Balls.colour[right][j] == Balls.colour[i][j]))
      || ((bott != j) && (Balls.colour[i][bott] == Balls.colour[i][j]))){
    return 0;
  }else{
    return 1;
  }
}

// This recursive ftn starts with a (nonsingleton always?) ball and
// searches for all the other balls which are in the same group as the
// initial ball.  All found balls are then given the same group
// number.
int det_neigh_group(int i, int j, int group_num)
{
  extern struct Balls Balls;

  int left = (i == 0) ? 0 : i-1;
  int top = (j == 0) ? 0 : j-1;
  int right = (i == COL_NUM-1) ? i : i+1;
  int bott = (j == ROW_NUM-1) ? j : j+1;

  if ((left != i) && (Balls.group[left][j] == 0) 
      && (Balls.colour[left][j] == Balls.colour[i][j])){
    Balls.group[left][j] = group_num;  // found a member of group
    det_neigh_group(left, j, group_num); // look at it's neighbours
  }

  if ((top != j) && (Balls.group[i][top] == 0) 
      && (Balls.colour[i][top] == Balls.colour[i][j])){
    Balls.group[i][top] = group_num;  // found a member of group
    det_neigh_group(i, top, group_num); // look at it's neighbours
  }

  if ((right != i) && (Balls.group[right][j] == 0) 
      && (Balls.colour[right][j] == Balls.colour[i][j])){
    Balls.group[right][j] = group_num;  // found a member of group
    det_neigh_group(right, j, group_num); // look at it's neighbours
  }

  if ((bott != j) && (Balls.group[i][bott] == 0) 
      && (Balls.colour[i][bott] == Balls.colour[i][j])){
    Balls.group[i][bott] = group_num;  // found a member of group
    det_neigh_group(i, bott, group_num); // look at it's neighbours
  }

  return 0;
}


// Debugging tool
void print_ball_table()
{
  int i, j;

  extern struct Balls Balls;

  if (ON_DVD == 0){

    printf("Colours:\n");
    for (i = 0; i < ROW_NUM; i++){
      for (j = 0; j < COL_NUM; j++){
	printf("%4d", Balls.colour[j][i]);
      }
      printf("\n");
    }
    
    printf("Group Numbers:\n");
    for (i = 0; i < ROW_NUM; i++){
      for (j = 0; j < COL_NUM; j++){
	printf("%4d", Balls.group[j][i]);
      }
      printf("\n");
    }
    printf("\n");
    printf("\n");
    
  }

}


