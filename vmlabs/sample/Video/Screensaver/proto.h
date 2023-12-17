/*
 * 
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#ifndef _PROTO_H_
#define _PROTO_H_

#ifdef __cplusplus
extern "C" {
#endif

int main(void);

void draw_picture(long *picture,int xoff, int yoff, int imgwid, int imght, int wclip, int hclip );
void swap_screenbuffers(void);
void init_screenbuffers(void);
void clearscreen(mmlDisplayPixmap *scrn);

int screensaver( int dmaFlags, void *mem, int w, int h, int maxidle );

#ifdef __cplusplus
}
#endif

#endif
