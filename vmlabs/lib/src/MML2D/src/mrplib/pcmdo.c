/* Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
 *Confidential and Proprietary Information of VM Labs, Inc
 */
 /* rwb 4/8/98
  * MPE3 code to consume Host PCM Audio events and cause
MPE0 audio code to do the write thing.
  */
  

#include "../mrplib/parblock.h"
#include "../mrplib/mrpproto.h"
#include "../mrplib/pixmacro.h"
#include <math.h>

#define kAudMauiCmd 0x24       /* Comminfo code for MAUI command */


/* kAudMauiCmd stuff */
    
/* common to all MAUI commands */
#define kMauiCmd_SubCodeBit     24
#define kMauiCmd_SubCodeSize    8
#define kMauiCmd_SubCode_Null       0       /* not a real command - stored in MauiCmd to indicate
                                            ** that no new command is pending (@@@ assumed to be 0)
                                            */
#define kMauiCmd_SubCode_Play       1
#define kMauiCmd_SubCode_Abort      2
#define kMauiCmd_SubCode_Gain       3
#define kMauiCmd_SubCode_Pause      4
#define kMauiCmd_SubCode_Continue   5
#define kAudUICmd 					0x38
    
#define CM_PCM_ULINEAR 1
#define PCM_Line_Volume (1 << 0)
#define PCM_Line_PCM (1 << 4)

    /* kMauiCmd_SubCode_Play */
#define kMauiCmd_Play_StereoBit     18
#define kMauiCmd_Play_UnsignedBit   17
#define kMauiCmd_Play_16BitBit      16
#define kAudioMpe 0

	/* AudioUI enums */
enum {
kAisDynRangeCutBoostSize	= 8,		// 2 scalars for cut and boost
kAisMasterVolumeOffset		= kAisDynRangeCutBoostSize,
kAisMasterVolumeSize		= 4,		// 1 word for master volume [1.15, unsigned, must be in the range of 0.0 .. 1.0], 1 word for ramp phase increment [1.15, unsigned. must be in the range of 0.0 .. 1.0]
kAisUserSpeakerOffset		= (kAisMasterVolumeOffset + kAisMasterVolumeSize),
kAisUserSpeakerSize			= 4,		// 1 word for level, 4 bits for control, 1 byte for config
kAisTrimOffset				= (kAisUserSpeakerOffset + kAisUserSpeakerSize),
kAisTrimUpdateSize			= 2,		// 1 word for updating channel trim [1.15, unsigned, in the range of 0.0 .. 1.999999]
kAudUiIdBit					= 16
};

/* -------------------- Translation functions */
/*    Translate gain code into floating-point gain factor. */

float CalcMAUIGain (uint8 gainCode)
{
    if (gainCode & 0x80) {
        return 0;
    }
    else {
    return pow (10.0, (gainCode-127) * 0.5 / 20.0);
    }
}

int32 Fix30( float x )
{
	return (int32)( x * (float)(0x40000000));
}

uint16 Fix16( float x )
{
	return (uint16)( x * (float)(0x8000));
}

void cvrtPlayBlockToVector( const PcmPlayParamBlock* p, long* vector )
{
    vector[0] = kMauiCmd_SubCode_Play << kMauiCmd_SubCodeBit;
    if (p->sample_size   == 16)             vector[0] |= 1 << kMauiCmd_Play_16BitBit;
    if (p->coding_method == CM_PCM_ULINEAR) vector[0] |= 1 << kMauiCmd_Play_UnsignedBit;
    if (p->num_channels  == 2)              vector[0] |= 1 << kMauiCmd_Play_StereoBit;
    
    vector[1] = p->buf;
    vector[2] = p->buf_size;
    vector[3] = p->sample_rate;
}

extern void	CommSend(int targetID, long vec[4], int comminfo);

mrpStatus PcmPlay(int environs, PcmPlayParamBlock *parBlockP, int arg2, int arg3 )  
{
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	PcmPlayParamBlock* parP;
 	uint8* tileBase;
 	int* endP;
 	long vector[4];

 	/* Set up local dtram & read in parameter block */
 	int parSizeLongs = (sizeof(PcmPlayParamBlock)+3)>>2;
 	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, &endP ) )
  		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
  	else
  		parP = parBlockP;
	cvrtPlayBlockToVector( parP, vector );
	CommSend( kAudioMpe, vector, kAudMauiCmd ); 		
    	return eFinished; 
}

mrpStatus PcmAbort(int environs, void *parBlockP, int arg2, int arg3 )  
{
	long vector[4];
      vector[0] = kMauiCmd_SubCode_Abort << kMauiCmd_SubCodeBit;
      vector[1] = vector[2] = vector[3] = 0;
	CommSend( kAudioMpe, vector, kAudMauiCmd ); 		
    	return eFinished; 
}
mrpStatus PcmPause(int environs, void *parBlockP, int arg2, int arg3 )  
{
	long vector[4];
      vector[0] = kMauiCmd_SubCode_Pause << kMauiCmd_SubCodeBit;
      vector[1] = vector[2] = vector[3] = 0;
	CommSend( kAudioMpe, vector, kAudMauiCmd ); 		
    	return eFinished; 
}
mrpStatus PcmContinue(int environs, void *parBlockP, int arg2, int arg3 )  
{
	long vector[4];
      vector[0] = kMauiCmd_SubCode_Continue << kMauiCmd_SubCodeBit;
      vector[1] = vector[2] = vector[3] = 0;
	CommSend( kAudioMpe, vector, kAudMauiCmd ); 		
    	return eFinished; 
}

mrpStatus PcmGain(int environs, PcmGainParamBlock *parBlockP, int arg2, int arg3 )  
{
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	PcmGainParamBlock* parP;
 	uint8* tileBase;
 	int* endP;
	long vector[4];
 	// Set up local dtram & read in parameter block 
 	int parSizeLongs = (sizeof(PcmGainParamBlock)+3)>>2;
 	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, &endP ) )
  		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
  	else
  		parP = parBlockP;
  		
  	if( parP->lines & PCM_Line_PCM)
  	{
        vector[0] = kMauiCmd_SubCode_Gain << kMauiCmd_SubCodeBit;
            /* compute average gain of left and right channels */
        vector[1] = Fix30 ((CalcMAUIGain (parP->front_left) + CalcMAUIGain (parP->front_right)) / 2 );
        vector[2] = vector[3] = 0;
		CommSend( kAudioMpe, vector, kAudMauiCmd ); 		
    }
  	if( parP->lines & PCM_Line_Volume)
  	{
  		/* first send master gain == 1.0 using fastest possible ramp */
        vector[0] = (kAisMasterVolumeOffset << kAudUiIdBit) | kAisMasterVolumeSize;
        vector[1] = 0x80008000; 
        vector[2] = vector[3] = 0;
		CommSend( kAudioMpe, vector, kAudUICmd );
		/* now send message with both left and right trim values */
        vector[0] = (kAisTrimOffset << kAudUiIdBit) | (2*kAisTrimUpdateSize);
        vector[1] = ((Fix16 (CalcMAUIGain (parP->front_left)))<<16) | (Fix16 (CalcMAUIGain (parP->front_right)));
		CommSend( kAudioMpe, vector, kAudUICmd );
    }
   	return eFinished; 
} 




