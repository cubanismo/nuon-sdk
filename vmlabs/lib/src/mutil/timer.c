/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

/* the interfaces implemented in this file are long since obsolete... */

#include <nuon/time.h>
#include "mutil.h"

void
InitTimer(void)
{
    /* nothing to do -- the BIOS always initializes
       the timer for us */
}

/* get count of seconds and milliseconds elapsed */

long
GetTimer(long *secs, long *usecs)
{
    /* ask the BIOS for time elapsed since boot */
    return _TimeElapsed(secs, usecs);
}

