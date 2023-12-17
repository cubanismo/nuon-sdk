
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <nuon/mutil.h>
#include <nuon/audio.h>
#include <nuon/synth.h>


#define TIMER (0)

extern short Bank1[];
static AUDIO_RESOURCES audiorsc = { 1, 0, 0, 0 };


#define REVERB 91
#define BANK 0

void delay(void)
{
long time,sec,usec;
	
	time=GetTimer(&sec,&usec);
	while (GetTimer(&sec,&usec)<time+10000);
}

int main()
{
int i;

	InitTimer();
	        	
	AUDIOInitX(&audiorsc);

	SYNTHInstallBank(1,(long *)Bank1);

	SYNTHMidiProgramChange(0,1);
	SYNTHMidiControlChange(0,REVERB,100);
	SYNTHMidiControlChange(0,BANK,0);


	SYNTHMidiProgramChange(1,1);
	SYNTHMidiControlChange(1,REVERB,100);
	SYNTHMidiControlChange(1,BANK,1);
	
	for( i = 0; i < 16; i++ )
		SYNTHMidiControlChange(i,7,127);

	for (;;)
	{
		SYNTHMidiNoteOn(0,40,127);
        delay();
		
		SYNTHMidiNoteOff(0,40,127);
        delay();
	
		SYNTHMidiNoteOn(1,52,127);
        delay();
		
		SYNTHMidiNoteOff(1,52,127);
        delay();
	}
}
