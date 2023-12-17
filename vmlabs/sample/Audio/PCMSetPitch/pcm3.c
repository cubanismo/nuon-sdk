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
#include <nuon/mutil.h>

extern short Sine[];
extern short SineEnd[];

void delay(void)
{
long time,sec,usec;
	
	time=GetTimer(&sec,&usec);

	while( GetTimer(&sec,&usec) < (time+100) );	
}

int main()
{
long voice,pitch;
PCMPOS Pan;
PCMHEAD WaveDefine;

	InitTimer();

    AUDIOInit();

    WaveDefine.PCMWaveBegin = (unsigned long)Sine;
    WaveDefine.PCMLength    = SineEnd - Sine;
    WaveDefine.PCMLoopBegin = 0;
    WaveDefine.PCMLoopEnd   = SineEnd - Sine;
    WaveDefine.PCMBaseFreq  = 0x2000;
    WaveDefine.PCMControl   = 1;

    Pan.PCMPanLR = 0;
    Pan.PCMPanFB = 0;
    Pan.PCMPanUD = 0;

    voice = PCMPlaySample(-1, &WaveDefine, &Pan, 0x40000000, 0x40000000);

    for (;;)
    {
		for (pitch = 0x400; pitch < 0x4000; pitch += 0x80)
		{
				PCMSetPitch(voice, pitch);
				delay();
		}
    }
}
