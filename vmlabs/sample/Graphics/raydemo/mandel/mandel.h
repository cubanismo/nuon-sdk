/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.

 * parameters for mandelbrot code
 * used by both C and assembly, so keep
 * this file simple
 */

/* define this to get a "letterboxed" mandelbrot set */
/* #define MANDEL_LETTERBOX */

#ifdef MANDEL_LETTERBOX
#define MANDEL_WIDTH 320
#define MANDEL_HEIGHT 180
#else
#define MANDEL_WIDTH  320
#define MANDEL_HEIGHT 240
#endif
