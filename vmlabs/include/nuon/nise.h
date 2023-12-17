/*Copyright (C) 1995-2001 VM Labs, Inc.

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

#ifndef _nise_h
#define _nise_h

#define PCM_API         1
#define SYNTH_HIGH_API  2
#define SYNTH_MIDI_API  4
#define SYNTH_LOW_API   8
#define STREAM_AUDIO    16
 
enum {
kNISEVoiceBitField	= 0,
kNISEFeatures		= 1,
  kNISEMixerType 	 = 0,
  kNISEEcho	 = 4,
  kNISEPrologic	 = 5,
  kNISEStreamingAudio = 7,
  kNISEScale = 24,  /* 8 bit value !*/
kNISEStreamBufferStart	= 2,
kNISEStreamBufferLength	= 3,

kNISEMasterVolume	= 4,
  kNISEPCMVolumeBit    = 0,
  kNISEStreamVolumeBit = 16,
kNISEStreamBufferPointer= 5,
kNISESurroundDelayAddr  = 6,
kNISESurroundDelayPos   = 7,

kNISEEchoDelayAddr      = 8,
kNISEEchoDelayLen       = 9,
kNISEEchoDelayPos       = 10,
kNISEEchoDelayFeedback  = 11,

/* ------------------------ */

kNISESampleStart	= 0,
kNISECurrentPoi		= 1,
kNISESampleEnd		= 2,
kNISELoopStart		= 3,

kNISEPhaseCounter	= 4,
kNISEPhaseIncrement	= 5,
kNISEVoiceFeatures	= 6,
  kNISESampleFormatBit = 0,
    kNISE8bitNSCMono = 0,
    kNISE16bitPCMMono = 1,
	
  kNISELFO       = 4,
  kNISEDistortion = 5,
  kNISEFilter     = 6,
  kNISEInterpolation = 7,

  kNISELFOModFilterF = 8,
  kNISELFOModFilterQ = 9,
  kNISELFOModGain    = 10,
  kNISELFOModPan     = 11,
  kNISELFOModDist    = 12,
kNISEDistortionAmount   = 7,
  
kNISEFilterStateLP	= 8,
kNISEFilterStateBP	= 9,
kNISEFilterStateHP	= 10,
kNISEFilterInputTrim	= 11,

kNISEFilterFrequency	= 12,
kNISEFilterResonance	= 13,
kNISEFilterType		= 14,
kNISEReserved1	        = 15,

kNISELFOPhase	        = 16,
kNISELFOPhaseIncr       = 17,
kNISELFORange	        = 18,
kNISEReserved2	        = 19,

kNISEPanLR		= 20,
kNISEPanFB		= 21,
kNISEFX			= 22,
kNISEGain		= 23
};


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
	kStreamingInfoReadErrors = 2,
	kStreamingInfoRetryCount = 3
};


typedef struct {
	unsigned long VoiceBitfield;
	unsigned long Features;
	unsigned long StreamBufferStart;
	unsigned long StreamBufferLength;

	unsigned short StreamVolume;
	unsigned short PCMVolume;
	unsigned long StreamBufferPointer;
	unsigned long SurroundDelayBuffer;
	unsigned long SurroundDelayPointer;
	
	unsigned long EchoDelayBuffer;
	unsigned long EchoDelayLength;
	unsigned long EchoDelayPointer;
	unsigned long EchoDelayFeedback;
} NISEControlStruct;


typedef struct {
	unsigned long SampleStart;
	unsigned long CurrentPointer;
	unsigned long SampleEnd;
	unsigned long LoopStart;

	unsigned long PhaseCounter;
	unsigned long PhaseIncrement;
	unsigned long Features;
	unsigned long DistortionAmount;

	unsigned long FilterStateLP;
	unsigned long FilterStateBP;
	unsigned long FilterStateHP;
	unsigned long FilterInputTrim;

	unsigned long FilterFrequency;
	unsigned long FilterResonance;
	unsigned long FilterType;
	unsigned long LFOValue;

	unsigned long LFOPhase;
	unsigned long LFOPhaseIncrement;
	unsigned long LFOStartPoint;
	unsigned long LFOEndPoint;
	
	unsigned long PanLeftRight;
	unsigned long PanFrontBack;
	unsigned long EchoAmount;
	unsigned long Gain;
} NISEVoiceStruct;

typedef struct
{
	NISEControlStruct NISEGlobal;
	NISEVoiceStruct NISEVoice[31];
} NISEParaBlock;

typedef struct
{
	unsigned long  PCMWaveBegin;
	unsigned long  PCMLength;
	unsigned long  PCMLoopBegin;
	unsigned long  PCMLoopEnd;
	unsigned long  PCMBaseFreq;
	unsigned long  PCMControl;
	unsigned long  PCMDistortionAmount;
	unsigned long  PCMFilterInputTrim;
	unsigned long  PCMFilterFrequency;
	unsigned long  PCMFilterResonance;
	unsigned long  PCMFilterType;
} PCMHEAD;


typedef struct
{
	long  PCMPanLR;
	long  PCMPanFB;
	long  PCMPanUD;
	long  Reserved1;
} PCMPOS;

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
void AUDIOScale(long scale);

void PCMEnableGlobalFeature(long control);
void PCMDisableGlobalFeature(long control);
void PCMEchoFeedback(long feedback);
long PCMGetUsedVoices(void);

long PCMPlaySample (long voice, PCMHEAD *sample, PCMPOS *pos,
                    long vol, long echoAmount);
long PCMVoiceOn (void *startAddr, long frequency, long len, long vol,
                 long panLR, long panFR);
void PCMVoiceOff (long voiceHandle);
void PCMPause(long voice, long mode);
void PCMSetEchoAmount (long voice, long v);
void PCMSetVolume (long voiceHandle, long vol);
void PCMSetPanLR (long voiceHandle, long panLR);
void PCMSetPanFB (long voiceHandle, long panFR);
void PCMSetPitch (long voiceHandle, long resample);
void PCMEnableFeature (long voice, long v);
void PCMDisableFeature (long voice, long v);
void PCMSetLFO (long voice, long range, long freq);
void PCMSetDistortionAmount (long voice, long v);
void PCMSetFilter (long voice, long f, long q, long t);

#endif
