/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#include "midiplay.h"
#include <nuon/bios.h>
#include <stdlib.h>

static AUDIO_RESOURCES audiorsc = { MIDI_MPE, 0, 0, 0 };

int RandomSongPlay = 0;  // set to 1 for random order
int SongDelay = 2000;    // pause between songs in milliseconds

volatile int SongCompleted = 0;

void InitMidiPlay(void)
{
    AUDIOInitX(&audiorsc);
}

void StartSong(int index)
{
    if (index >= 0 && index < ListSize) {
        SYNTHStopMidiParser();  // stop current performance
        _TimeToSleep(1000);     // pause before starting new song
        // restart SYNTH on new song, and reinstall callback
        SYNTHStartMidiParserFeedback(PlayList[index],3,0xffff,0);
        _TimeToSleep(2000); // delay before installing callback
        SYNTHInstallCB(SignalEndOfSong);
    }
}

//callback
void SignalEndOfSong(long p0, long p1, long p2, long p3)
{
    if (p3 == 0) {      // end-of-track event
        SongCompleted = 1;
    }
}

