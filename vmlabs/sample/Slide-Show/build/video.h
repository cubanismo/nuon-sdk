/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#ifndef VIDEO_H
#define VIDEO_H

#include <nuon/mml2d.h>
#include "jpeg.h"
#include "config.h"

#if (HI_RES)
#define SCREENWIDTH     720
#define SCREENHEIGHT    480
#else
#define SCREENWIDTH     360
#define SCREENHEIGHT    240
#endif

#define clr_white           (0xeb808000)    // RGB(255,255,255)
#define clr_black           (0x10808000)    // RGB(0,0,0)

extern long *ImageArr[];
extern int ImageSize[], NumImages;

void InitVideo(void);
void SwitchToNewImage(int i);
void PaintOverWithNewImage(int i);
void swap_screenbuffers(void);
void init_screenbuffers(void);
void clearscreen(mmlDisplayPixmap *scrn);
   
#endif
