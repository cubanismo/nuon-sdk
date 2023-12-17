/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdio.h>
#include <nuon/nise.h>

extern short Sine[];
extern short SineEnd[];

#define DUMP_INFO (0)

int main() 
{
PCMPOS Pan;
PCMHEAD WaveDefine;

    AUDIOInit();

    WaveDefine.PCMWaveBegin = (unsigned long)Sine;
    WaveDefine.PCMLength    = SineEnd - Sine;
    WaveDefine.PCMLoopBegin = 0;
    WaveDefine.PCMLoopEnd   = SineEnd - Sine;
    WaveDefine.PCMBaseFreq  = 0x2000;
    WaveDefine.PCMControl   = 0;

    Pan.PCMPanLR = 0;
    Pan.PCMPanFB = 0;
    Pan.PCMPanUD = 0;

	PCMPlaySample(-1, &WaveDefine, &Pan, 0x40000000, 0x40000000);

    for (;;) ;

}
