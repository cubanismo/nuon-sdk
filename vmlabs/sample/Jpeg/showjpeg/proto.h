/*
 * Copyright (c) 2000-2001, VM Labs, Inc., All rights reserved.
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

/* main.c */
void decompress_pictures(void);
int main(void);

/* jpeg.c */
void show_jpeg(mmlDisplayPixmap *scrn, void *jpegdata, int jpeg_size );
void decompress_jpeg(void *jpegdata, int jpeg_size, long *outputbuffer );

/* graphics.c */
void draw_picture(long *picture,int xoff, int yoff, int imgwid, int imght, int wclip, int hclip );
void clearscreen(mmlDisplayPixmap *scrn);

/* screenbuffers.c */
void swap_screenbuffers();
void init_screenbuffers();

#ifdef __cplusplus
}
#endif

#endif
