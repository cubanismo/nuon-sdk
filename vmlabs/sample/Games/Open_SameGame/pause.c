/*
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
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
