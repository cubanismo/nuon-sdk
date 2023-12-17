/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <nuon/synth.h>

extern short MidiFile[];

static AUDIO_RESOURCES audiorsc = { 1, 0, 0, 0 };

int main()
{
	AUDIOInitX(&audiorsc);
	SYNTHStartMidiParser((long)MidiFile);

	while(1);
}
