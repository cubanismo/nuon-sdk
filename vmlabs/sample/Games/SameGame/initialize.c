/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "sg.h"

// ftn to create a new table
//
// if seed is non-zero (ie the very first table, then use it)

int set_new_table(int n_colours, int seed, int special)
{
  int i, j, m, n;
  extern struct Balls Balls;

  // get a random seed to set up the first game
  if (seed != 0){
    srand(seed);
  }

  // randomly set up table
  for (i = 0; i < COL_NUM; i++)
    for (j = 0; j < ROW_NUM; j++){
      // use "rand()-1" so that "1" never comes up (which 
      // would give an extra colour or an error)
      n = n_colours * (double)(rand()-1)/(double)RAND_MAX;
      Balls.colour[i][j] = n;
      // probably don't need this as it's in det_group, but better
      // safe than sorry.
      Balls.group[i][j] = 0;  // -1 singleton, 0 not found, 1-n group number
      Balls.special[i][j] = 0;
    }

  // select the special balls
  if (special == 1){

    // place two changeable balls in the table.  The first occurs
    // randomly in the first 2/3 columns, and the second appears in
    // the last 2/3 of the table.

      m = ROW_NUM * (double)(rand()-1)/(double)RAND_MAX;
      n = COL_NUM * (double)(rand()-1)/(double)RAND_MAX * 2.0 / 3.0;
      Balls.special[n][m] = 1;

      m = ROW_NUM * (double)(rand()-1)/(double)RAND_MAX;
      n = COL_NUM * (double)(rand()-1)/(double)RAND_MAX * 2.0 / 3.0;
      n = (int)(n + ((double)COL_NUM / 3.0));
      Balls.special[n][m] = 1;

  }

  return 0;
}






