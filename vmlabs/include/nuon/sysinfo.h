/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

/*
 * System Info
 *
 */


#ifndef __SYSINFO_H__
#define __SYSINFO_H__

#ifdef __cplusplus
extern "C" {
#endif     

/* selectors */
typedef enum {
    kVersion					= 0,
	kFlags						= 1,
	kDigitalOutput				= 2,
	kFrontDisplayLevel			= 3,
	kAudioOutChannels			= 4,
	kAudioSpeakerSetting		= 5,
	kPlayerLanguage				= 6,
	kResumeInfoType				= 7,
	kAudioSpeakerDelay			= 8,
	kAudioLevelTrim				= 9,
	kMenuLanguage				= 10,
	kAudioMixingMode			= 11,
	kParentalCountryCode		= 12,
	kParentalLevel				= 13,
	kDisplayAspectRatio			= 14,
	kDisplayMode				= 15,
	kAudioConfiguration			= 16,
	kAudioLanguage				= 17,
	kAudioLanguageExt			= 18,
	kSubpictureLanguage			= 19,
	kSubpictureLanguageExt		= 20,
	kPassword					= 21,
	kVlmEffect					= 22,
	kResumeInfo					= 23,
    kRegionCode					= 24,
    kGameRegionCode				= 25,
	kAudioHDCDState				= 26,
	kBackgroundPicture			= 27,
    kTvSystem                   = 28,
    kUnderflowInitTimeout       = 29,
    kSupportedVideoMaterial     = 30,
    kSupportedVideoSystem       = 31,
    kVlmCategory                = 32,
	kTvOutput					= 33,
	kNumberOfSelectors			= 34,
	kUnlockSysInfo				= -1,
	kLockSysInfo				= -2,
    kCustomUIdata               = 3000		// custom UI data
} sysInfoSelect;

/* flags */
#define nvfDTS						0x00000001
#define nvfDynamicCompression		0x00000002
#define nvf2xScanAudio				0x00000004
#define nvfBlackLevel				0x00000008
#define nvfDealerLock				0x00000010
#define nvfChallengeOnResume        0x00000020
#define nvfDownSample96kHz			0x00000040
#define nvfPromptForHybrid			0x00000080
#define nvfLockFrontPanel			0x00000100
#define nvfChannelMatchMode         0x00000200
#define nvf3DSound                  0x00000400

/* player languages */
#define nvlNone                     0
#define nvlPlayerEnglishLanguage	1
#define nvlPlayerFrenchLanguage		2
#define nvlPlayerSpanishLanguage	3

/* resume information types */
#define nvrNone                     0
#define nvrDVD                      1
#define nvrVCD                      2
#define nvrCDA                      3
#define nvrMP3                      4

/* TV system types */
#define nvTvTypeNTSC                0
#define nvTvTypePAL                 1
#define nvTvTypeQuasiPAL            2
#define nvTvTypeSECAM               3
/* indicate that the TV system should automatically switch to match with the video source */
#define nvTvTypeAuto                0x80    

/* TV output types*/
#define nvTvTypeComposite           1
#define nvTvTypeSVideo              2
#define nvTvTypeRGB                 4
#define nvTvTypeYPrPb               8

/* Video source material types */
#define nvVideoSrcNTSC              1
#define nvVideoSrcPAL               2

/* Video system types */
#define nvVideoStdNTSC              1
#define nvVideoStdPAL               2
#define nvVideoStdQuasiPAL          4


int _LoadSystemSettings(void);
int _LoadDefaultSystemSettings(void);
int _StoreSystemSettings(void);
int _GetSystemSettingLength(sysInfoSelect sis, int *len);
int _GetSystemSetting(sysInfoSelect sis, void* data, int len, int flags);
int _SetSystemSetting(sysInfoSelect sis, void* data, int  len, int flags);

#ifdef __cplusplus
}
#endif
       
#endif
