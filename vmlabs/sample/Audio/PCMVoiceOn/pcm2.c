/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <nuon/nise.h>

extern short Sine[];
extern short SineEnd[];

int main()
{
    AUDIOInit();
    PCMVoiceOn((long *)Sine,0x2000,SineEnd-Sine,0x40000000,0,0);

    for (;;) ;

}
