
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* MRP constants, enums, macros
 * rwb 9/20/98
 * Lives in mrplib folder
 * Referred to from outside folders.
 */
#ifndef mrptypes_h
#define mrptypes_h

#include <sys/types.h>
#include "version.h"

#ifndef uint32_h
#define uint32_h
typedef short int		int16;
typedef int			int32;
typedef unsigned long	mmlColor;
#endif

#ifndef mlPixType_h
#define mlPixType_h
typedef enum mmlPixFormat mmlPixFormat;
enum mmlPixFormat{
	eMinFormat,
	eClut4,
	e655,
	eClut8,
	e888Alpha,
	e655Z,
	e888AlphaZ,
	eGRB655,
	eRGBAlpha1555,
	eRGB0555,
	eGRB888Alpha,
	eClut4GRB888Alpha,
	eClut8GRB888Alpha,
	eClut8GRB655,
	eClut8655,
	eMPEG,
	eMaxFormat
};
#endif

/* This could probably be increased to 64 in most environments */
#define kMaxLongs 32

#define kSysReadFlag 0x2000
#define kWaitFlag 1
#define DmaActive 31
#define LoBusPriority (1<<5)
#define BitRead 0x2000
#define kPixWrite 0xC000
#define kPixRead 0xE000
#define kBitDirect (1<<27)
#define kBitDup (1<<26)
#define kCluster 0x800
#define kTransparent 0x100
#define kTransBB 0x200

#define kChNorm (1<<28)

#define MAX( x, y ) ((x) > (y) ? x : y)
#define MIN( x, y ) ((x) < (y) ? x : y)

/* bit definitions for loadcoff flags */
#define START_NEW_MPE 1
#define HALT_SELF     2

enum mrpStatus{
	eFinished,
	eNotFinished,
	eUnimplemented,
	eUnrecognized,
	eError,
	eActionComplete
};
typedef enum mrpStatus mrpStatus;
typedef mrpStatus (*mrpFunc)(uint32 a, void* b, int c, int d );

#endif

