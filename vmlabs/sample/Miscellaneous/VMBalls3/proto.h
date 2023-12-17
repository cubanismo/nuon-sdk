/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 */

#ifndef _PROTO_H_
#define _PROTO_H_

#ifdef __cplusplus
extern "C" {
#endif

/* vmballs.c */
int main(void);
int Vblanksync(int count);

/* graphics.c */
void load_sprite();
void plot_object( Ball_Position *ball );
void draw_picture(long *picture,int xoff, int yoff, int imgwid, int imght, int wclip, int hclip );
void clearscreen(mmlDisplayPixmap *scrn);
void swap_screenbuffers();
void init_screenbuffers();


#ifdef __cplusplus
}
#endif

#endif

