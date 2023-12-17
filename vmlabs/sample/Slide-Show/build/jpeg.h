/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#ifndef JPEG_H
#define JPEG_H

#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>
#include <stdio.h>
#include <jpeg/jpeglib.h>

void show_jpeg(mmlDisplayPixmap *scrn, void *jpegdata, int jpeg_size);
void decompress_jpeg(void *jpegdata, int jpeg_size, long *outputbuffer);

#endif

