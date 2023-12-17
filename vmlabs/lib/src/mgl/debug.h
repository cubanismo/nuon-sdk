/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/


#ifndef DEBUG_H
#define DEBUG_H

// defines assert macro if NDEBUG is undefined
#include <assert.h>

#ifdef DEBUG
#define DEBUG_ASSERT(p) assert(p)
#else
#define DEBUG_ASSERT(p)
#endif

#endif // DEBUG_H