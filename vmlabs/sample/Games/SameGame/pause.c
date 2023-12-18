/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "sg.h"

// ftn waits until specificied number of seconds have passed before
// exiting
int pause_a_bit(double seconds)
{
  clock_t tBeg, tEnd;
  double sec;
  int exit = 0;

  tBeg = clock();
  while (!exit){
      tEnd = clock();
      sec = (tEnd>tBeg) ? (double)(tEnd-tBeg)/(CLOCKS_PER_SEC) : -99;
      if (sec > seconds)
	exit = 1;
  }
return 0;
}
