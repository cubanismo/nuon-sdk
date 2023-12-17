/*
   Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
*/

#ifndef NUON_ERROR_H
#define NUON_ERROR_H

#include <assert.h>

#define NUON_OK 0
#define NUON_WARNING 1
#define NUON_ERROR -1

// use DEBUG flag with & without underscores
#ifdef DEBUG
#define _DEBUG
#endif

#ifdef _DEBUG
#define NUON_ASSERT(x) assert(x)
#else
#define NUON_ASSERT(x)
#endif



#endif // NUON_ERROR_H
