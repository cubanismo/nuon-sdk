/*Copyright (C) 1995-2001 VM Labs, Inc.

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

#ifndef _synth_h
#define _synth_h


#define MNOTEOFF 0
#define MNOTEON 1
#define MCONTROLCHANGE 3
#define MPROGRAMCHANGE 4
#define MPITCHBEND 6

#define GETINFO		0x80
#define STARTPARSE	0x81
#define STOPPARSE	0x82
#define MIDIEVENT	0x83
#define RAWDATA 	0x84
#define SENDCONFIG	0x85
#define SCALAR		0x86
#define SENDBANK	0x87

#define LNOTEON		0x40
#define LNOTEOFF	0x41
#define LPITCHBEND	0x42
#define LMODWHEEL	0x43
#define LVOLUME		0x44
#define LPAN		0x45
#define LCHORUS		0x46
#define LREVERB		0x47

#define PARSER_CONFIG 0
#define SYNTH_CONFIG 1
#define BANK_CONFIG 2
#define SYNTH_VOLUME 3
#define PCM_VOLUME 4
#define NEXT_MIDI 5

#define END_OF_TRACK_ID 0
#define STOP_TRANSMIT_ID 1
#define START_TRANSMIT_ID 2
#define MIDI_EVENT_ID 0x10
#define LYRICS_ID 0x80
#define INFO_RESP_ID 0xAB
#define NOTE_ON_RESP_ID 0xAC

#define PCM_API         1
#define SYNTH_HIGH_API  2
#define SYNTH_MIDI_API  4
#define SYNTH_LOW_API   8
#define STREAM_AUDIO    16

typedef struct
{
	int audioMPE;
	long sysramBuffer;
	long sdramBuffer;
	long ramWavetableStart;
} AUDIO_RESOURCES;

enum
{
	kStreamingInfoCurrentSector = 0,
	kStreamingInfoLoopFlag = 1,
};

long AUDIOInit(void);
void AUDIOExit(void);
long AUDIOInitX(AUDIO_RESOURCES *res);

long AUDIOInitStreamingAudio(int device, long StreamBuffer,long StreamBufferSize);
long AUDIOSetupStreamingAudio(long startSector,long endSector);
int  AUDIOStreamingAudioStatus(void);
int  AUDIOStartStreamingAudio(void);
void AUDIOStopStreamingAudio(void);

long AUDIOGetStreamingAudioInfo(int selector);
void AUDIOSetStreamingAudioLooping(int state);

void AUDIOSetupExternalStreamFeeder(void (* feeder)(unsigned char *, long));

void AUDIOMixer(long musicVolume, long fxVolume);

void SYNTHSetAudioMPE(long mpe);

/* High Level API */

void SYNTHConfig(long maxVoices, long mpeUsage, long reverbOn, long chorusOn);
void SYNTHInstallCB(void (*SYNTHCallback) (long p0,long p1,long p2,long p3));
void SYNTHInfo(long extended,long answer[]);
void SYNTHMixer(long synthVolume, long fxVolume);
void SYNTHInstallBank(long bankNumber, long *databaseStart);
void SYNTHNextMidiFile(long addr);
void SYNTHStartMidiParserFeedback(long addr,long mpe,long channels,long commands);
void SYNTHStartMidiParser(long addr);
void SYNTHStopMidiParser(void);
void SYNTHMidiSendEvents(unsigned char *events,long len);

/* Midi Direct API */

void SYNTHMidiNoteOn(long channel, long note, long velocity);
void SYNTHMidiNoteOff(long channel, long note, long velocity);
void SYNTHMidiPitchBend(long channel, long value);
void SYNTHMidiControlChange(long channel, long no,long value);
void SYNTHMidiProgramChange(long channel,long patch);

/* Low Level API */

long SYNTHNoteOn(long patch, long note, long velocity);
void SYNTHChangePara(long voicelist,long no,long value);
void SYNTHNoteOff(long voicelist);
void SYNTHPitchBend(long voicelist,long value);
void SYNTHModWheel(long voicelist,long value);
void SYNTHVolume(long voicelist,long value);
void SYNTHPan(long voicelist,long value);
void SYNTHChorus(long voicelist,long value);
void SYNTHReverb(long voicelist,long value);

/* PCM API */


typedef struct
{
	unsigned long  PCMWaveBegin;
	unsigned long  PCMLength;
	unsigned long  PCMLoopBegin;
	unsigned long  PCMLoopEnd;
	unsigned long  PCMBaseFreq;
	unsigned long  PCMControl;
	unsigned long  Reserved1;
	unsigned long  Reserved2;
} PCMHEAD;


typedef struct
{
	unsigned long  PCMPanLR;
	unsigned long  PCMPanFB;
	unsigned long  PCMPanUD;
	unsigned long  Reserved1;
} PCMPOS;

void PCMConfig (long control);
long PCMPlaySample (long voice, PCMHEAD *sample, PCMPOS *pos,
                    long vol, long reverb);
long PCMVoiceOn (void *startAddr, long frequency, long len, long vol,
                 long panLR, long panFR);
void PCMVoiceOff (long voiceHandle);
void PCMSetVolume (long voiceHandle, long vol);
void PCMSetPanLR (long voiceHandle, long panLR);
void PCMSetPanFB (long voiceHandle, long panFR);
void PCMSetPanUD (long voiceHandle, long panUD);
void PCMSetPitch (long voiceHandle, long resample);

#endif
