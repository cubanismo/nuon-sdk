/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */


#include "sg.h"

// Deletes all the balls in group numbered group_num, returns the
// number of balls in said group, and also squeezes all columns left
// if necessary.
int delete_group(int group_num)
{
  extern struct Balls Balls;
  int i, j, k;
  int n_deleted_balls = 0;

  // Note that the set formed by intersecting the specified group with
  // a particular column does *not* have to be connected.  (Think of a
  // horseshoe on its side.)

  for (i = 0; i < COL_NUM; i++){

    // tag those balls from the specified group with "-2" 
    for (j = 0; j < ROW_NUM; j++){
      if (Balls.group[i][j] == group_num){
	Balls.group[i][j] = -99;  // probably not necessary given below
	Balls.colour[i][j] = -2;
	n_deleted_balls = n_deleted_balls + 1;
      }
    }

    // Now that we've deleted some balls, let's make the remaining
    // balls "fall" properly.  We start at the bottom of the column 
    // and shift down each time we find a tagged ball.
    for (j = ROW_NUM-1; j > -1; --j){
      
      while (Balls.colour[i][j] == -2){
	// shift down 1 position 
	for (k = j; k > 0 ; --k){
	  Balls.colour[i][k] = Balls.colour[i][k-1];
	  Balls.group[i][k] = Balls.group[i][k-1];
	  Balls.special[i][k] = Balls.special[i][k-1];
	}
	// place an empty ball on top
	Balls.colour[i][0] = -99;
	Balls.group[i][0] = -99;
	Balls.special[i][0] = 0;
      }

    }
    
  }  // for (i = 0.... ) loop


  // Since the deletion process may have resulted in an entire column
  // of deleted balls, we may need to squeeze the remaining columns to
  // the left.
  squeeze_left(0);

  // return the size of the deleted group
  return n_deleted_balls;
}


// This ftn recursively shifts the columns of the Balls table
// left in the case that there are empty columns.  The value "k"
// denotes the column from which we start looking (to the right) 
// to shift.
int squeeze_left(int k)
{
  int i, j, col, flag1, flag2;


  // give col an initial value; though it should be assigned one
  // further on when it is needed
  col = 0;

  // first check if we need to squeeze (ie. if there are empty columns)
  flag1 = 0;
  flag2 = 0;
  i = k;

  while ( ((!flag1) || (!flag2)) && (i < COL_NUM)){
    if (Balls.colour[i][ROW_NUM-1] == -99)
      flag1 = 1;  // we found a trivial column
    
    if ((flag1) && (Balls.colour[i][ROW_NUM-1] != -99))
      flag2 = 1; //we've found a non-trivial col occurring *after* a trivial one
    
    i = i+1;
  }


  // we have discovered a trivial column (meaning there are no balls in
  // that column) followed by a non-trivial column (to the right of it)
  if ((flag1) && (flag2)){  
    i = k;
    while ((Balls.colour[i][ROW_NUM-1] != -99) && (i < COL_NUM-1))
      i = i+1;  //search for first triv, there must be at least one col after it
    col = i;  // note where it is
    
    // if we can't find a trivial column then something has gone wrong
    if (i == COL_NUM-1){
      if (ON_DVD == 0)
	printf("error in squeez2");
    }

    // now shift each column past the i^th column one column to 
    // the left and make the final column empty
    while (i < COL_NUM-1){
      for (j = 0; j < ROW_NUM; j++){  // do the copy/shift
	Balls.colour[i][j] = Balls.colour[i+1][j];
	Balls.group[i][j] = Balls.group[i+1][j];
	Balls.special[i][j] = Balls.special[i+1][j];
      }
      i = i+1;
    }
    // make the last column trivial
    for (j = 0; j < ROW_NUM; j++){ 
      Balls.colour[COL_NUM-1][j] = -99;
      Balls.group[COL_NUM-1][j] = -99;
      Balls.special[COL_NUM-1][j] = 0;
    }
  }

  // ok, if we have found one empty column and removed it, then search
  // further (to the right) for more empty columns
  if (flag1 && flag2)
    squeeze_left(col);
  
  return 0;
}

