/*Copyright (C) 2001 VM Labs, Inc.

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

#include <nuon/mml2d.h>

#define DMA_PIXEL_PXFER   4   // pixel types [4 bits]                           
#define DMA_PXFER2_16BPP         2    // 16-bit pixels of single buffer
#define DMA_PXFER3_8BPP          3    // 8-bit pixels through CLUT
#define DMA_PXFER4_32BPP         4    // 32-bit pixels of single buffer

void InitTerminalX(int p,int scr,int width, int height, int dmafl,int bg);
void InitTerminal(int pr,int res);
void Print(char *str,int fg, int bg);
void ClearScreen(void);
void DrawText(char *str,int XOrigin,int YOrigin,int fg, int bg);
void FillRect(int initx, int inity, int wide, int high, int color);
void PrintStatus(char *str,int fg, int bg);
void SetScreenBase(int scr);
