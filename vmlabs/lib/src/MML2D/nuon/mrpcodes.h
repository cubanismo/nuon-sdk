/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
 *
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
*/
/* Nuon Multimedia Function Codes.
 */
#ifndef mrpCodes_h
#define mrpCodes_h

enum mrpCode{
	eExecSequence = 0xE,
	eFlushCache = 0xF,
	eSdramFill = 0x10,
	eFillColr = 0x11,
	eDCopy = 0x12,
	eBiCopy = 0x13,
	eCopyRect = 0x14,
	eFillMpeg = 0x15,
	eCopyRectFast = 0x16,
	eCopyToClut = 0x17,
	eFillClut = 0x18,
	eCopySDClut = 0x19,
	eCopyTile8 = 0x1A,
	eCopyTileAll = 0x1B,
	eCopyRGBFast = 0x1C,
	eCopyRect16 = 0x1D,
	eVidOsd = 0x20,
	eVidMain = 0x21,
	eDrawLinePlus = 0x30,
	eDrawEllipsePlus = 0x40,
	eTxBlt = 0x50,
	eTxBlend = 0x51,
	eTxAlpha = 0x52,
	eNoParBlockStart = 0x80,
	eDrawPoint = 0x80,
	eSmallFill = 0x81,
	eMovePix = 0x82,
	eNoParBlockEnd = 0x90,
   	eVideoStart = 0x100,
	eAudioStart = 0x101,
	eVideoStop = 0x102,
	eAudioStop = 0x103,
	eAudioMute = 0x104,
	eVideoBlank = 0x105,
	ePlayIFrame = 0x106,
	ePlayBlank = 0x107,
	eTrickFlag = 0x108,
	eLoadCOFF = 0x200,
	ePcmPlay = 0x300,
	ePcmAbort = 0x301,
	ePcmGain = 0x302,
	ePcmPause = 0x303,
	ePcmContinue = 0x304,
	eKaraoke = 0x305,
	eScrollUp = 0x900,
	eCopy32 = 0x901, 
	eUnimp = 0xFFFF
	};
typedef enum mrpCode mrpCode;

#endif
