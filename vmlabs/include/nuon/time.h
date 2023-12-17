/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


/*
 * BIOS time-releated functions
 *
 */

#ifndef _BIOS_TIME_H
#define _BIOS_TIME_H

#ifdef __cplusplus
extern "C" {
#endif

/* structure for time of day */
struct _currenttime {
    int sec;
    int min;
    int hour;
    int wday;
    int mday;
    int month;
    int year;
    int isdst;     /* flag: for definitions, see below */
    int timezone;  /* minutes west of Greenwich */
    int reserved[3]; /* reserved for future expansion */
};

/* values for isdst */
#define _DST_UNKNOWN -1  /* whether DST is in effect is unknown */
#define _DST_NO      0   /* DST is not in effect */
#define _DST_YES     1   /* DST is in effect */

int _TimeOfDay(struct _currenttime *tm, int getset);
unsigned long _TimeElapsed(long *secs, long *usecs);

void _TimeToSleep(unsigned long msecs);
int _TimerInit(int which, int rate);


#ifdef __cplusplus
}
#endif

#endif
