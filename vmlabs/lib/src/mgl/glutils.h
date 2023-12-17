/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

#ifndef GLUTILS_H
#define GLUTILS_H

#define IS_SDRAM(p)	((0x40000000 <= (unsigned long)(p)) && ((unsigned long)(p) <= 0x7fffffff))

// r, g, b, y, cr, cb, a on [0, 255]

#define COLOR_655(y, cr, cb)			((((y) & 0xfc) << 8) | (((cr) & 0xf8) << 2) | (((cb) & 0xf8) >> 3))

#define COLOR_GRB655(r, g, b)			((((g) & 0xf8) << 8) | (((r) & 0xf8) << 2) | (((b) & 0xf8) >> 3))

#define COLOR_8888Alpha(y, cr, cb, a)	(((y) << 24) | ((cr) << 16) | ((cb) << 8) | (a))
#define COLOR_GRB888Alpha(r, g, b, a)	COLOR_8888Alpha(g, r, b, a)

#define COLOR_I16(r, g, b)				((4899 * (r) + 9617 * (g) + 1868 * (b)) >> GLCOLORSHIFT)	// 2.14

// glutils.c

#if defined(DEBUG) || defined(GL_TRACE_API)
extern unsigned char *GLConstantString(int cons);
#endif

extern void DMAToMPE(int mpeIndex, void *dstAddr, const void *srcAddr, long size);

extern void WaitForMPE(int mpeIndex);
extern int WaitForAnyMPE(void);
extern void WaitForAllMPEs(void);

// glmutils.s

extern int GetCommBusId(void);
extern void CommRecvInterrupt(void);

extern unsigned long tile(unsigned long);
extern unsigned long textureShift(unsigned long);

#endif // GLUTILS_H