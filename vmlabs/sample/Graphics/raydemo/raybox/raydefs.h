
/* Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.

 * basic definitions for the raytrace program
 * this file may be used either in assembly or
 * C, so keep it simple -- just #defines, please,
 * and no special C syntax (like casts)
 */

#define VERTICAL_SCALE 0
#define HORIZ_SCALE 0

/* screen setup */
#define SCRNWIDTH 224
#define SCRNHEIGHT 240

// ASPECT_RATIO is pixel height/pixel width
// normally 320/240 -> 1
#define ASPECT_RATIO (SCRNHEIGHT/SCRNWIDTH)*(320/240)

/* speed of balls:
 * should be independent of rendering speed, but alas it isn't
 * lower means faster
 */

#define SPEED 2


