/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#include "SlideShow.h"

volatile int AutoPlay = 1;

int main(void)
{
    int iPix, iSong, n;
    JustOnButtons JOB;
    int count = 0;
    int ViewTime = 1000*VIEWTIME_SECONDS;
    long RefTime, Time;

    // perform initializations
    InitRemote();
#if (MIDI_PLAYBACK)
    InitMidiPlay();
#endif    
    InitVideo();

    iPix = iSong = 0;
    SwitchToNewImage(iPix);
#if (MIDI_PLAYBACK)
    StartSong(iSong);
#endif    

    RefTime = _TimeElapsed(0,0);
    while (1) {
#if (MIDI_PLAYBACK)
        if (SongCompleted) {
            SongCompleted = 0;
            iSong++;
            if (iSong == ListSize)
                iSong = 0;
            _TimeToSleep(SongDelay);
            StartSong(iSong);
        }
#endif        
        if (AutoPlay) {
            Time = _TimeElapsed(0,0);
            if (Time - RefTime >= ViewTime) {
                RefTime = Time;
                iPix++;
                if (iPix == NumImages) iPix = 0;
                SwitchToNewImage(iPix);
            }
        }
        JOB = GetButtons();
        if (NumeralKey(JOB, &n)) {
            count = 10*count + n;
        }
        else if (NextKey(JOB)) {
            if (count > 0) {
                ViewTime = 1000*count;
                count = 0;
            }
            iPix++;
            if (iPix == NumImages) iPix = 0;
            SwitchToNewImage(iPix);
        }
        else if (StopKey(JOB)) {
            AutoPlay = 0;
        }
        else if (PlayKey(JOB)) {
            AutoPlay = 1;
            RefTime = _TimeElapsed(0,0);
            if (count > 0) {
                ViewTime = 1000*count;
                count = 0;
            }
            iPix++;
            if (iPix == NumImages) iPix = 0;
            PaintOverWithNewImage(iPix);
        }
        else if (EnterKey(JOB) || RightKey(JOB)) {
            if (count > 0 && count <= NumImages) {
                iPix = count - 1;
                count = 0;
            }
            else {
                count = 0;
                iPix++;
                if (iPix == NumImages) iPix = 0;
            }
            PaintOverWithNewImage(iPix);
        }
        else if (LeftKey(JOB)) {
            iPix--;
            if (iPix < 0) iPix = NumImages-1;
            PaintOverWithNewImage(iPix);
        }
#if (MIDI_PLAYBACK)
        else if (UpKey(JOB)) {      // skip to next or indexed song
            if (count > 0 && count <= ListSize) {
                iSong = count - 1;
                count = 0;
            }
            else {
                count = 0;
                iSong++;
                if (iSong == ListSize)
                    iSong = 0;
            }
            StartSong(iSong);
        }
        else if (DownKey(JOB)) {       // skip to previous song
            iSong--;
            if (iSong < 0)
                iSong = ListSize - 1;
            StartSong(iSong);
        }
#endif
    }
    // can't actually get here...
    return 0;
}

