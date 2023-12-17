/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#ifndef MIDIPLAY_H
#define MIDIPLAY_H

#include <nuon/synth.h>

#define MIDI_MPE 2       // 2 works on N501 while 1 does not!

extern int RandomSongPlay;
extern int SongDelay;
extern volatile int SongCompleted;

extern long PlayList[];
extern int ListSize;

void InitMidiPlay(void);
void SignalEndOfSong(long p0, long p1, long p2, long p3);
void StartSong(int index);

#endif
