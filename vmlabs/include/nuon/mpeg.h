/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

//****************************************************************
// TITLE :  Nuon MPEG (FMV: Full-Motion Video) definitions 
//
// FILE  :	mpeg.h
//
// DATE  :	
//
//	     
//**************************************************************** 

//--------------------------------
typedef struct {

    // MPEG Sequence Info (may change with each new sequence)
    long width;	    // horizontal size in pixels
    long height;	// vertical size in pixels
    long progseq;	// progressive or interlaced sequence
    long aspect;	// aspect ratio
    long is_mpeg2;  // is mpeg2 or mpeg1 flag

    // MPEG Picture Info (may change with each new picture)
    long fb;        // MPEG frame buffer
    long pType;     // picture coding type
    long pStruct;	// picture structure frame/field
    long tff;	    // top field first bit
    long rff;	    // repeat first field bit
    long pf;		// progressive frame 
    long tRef;		// temporal reference value

} MpegInfo;

//--------------------------------

void StartMPEG(void);
MpegInfo *GetNextMpegFrame(void);


