/*
 * simple sprintf
 * Copyright (c) 1990-1992 Eric R. Smith
 * Copyright (c) 1997-1998 VM Labs, Inc.
 *
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

#ifndef MSPRINTF_H
#define MSPRINTF_H

#include <stdarg.h>

#define SPRINTF_MAX 128

#ifdef __cplusplus
extern "C" {
#endif

int mvsprintf(char *buf, const char *fmt, va_list args)
#ifdef __GNUC__
    __attribute__ (( format(printf, 2, 0) ))
#endif
;

int msprintf(char *buf, const char *fmt, ...)
#ifdef __GNUC__
    __attribute__ (( format(printf, 2, 3) ))
#endif
;

#ifdef __cplusplus
	   }
#endif

#define sprintf msprintf

#endif /* MSPRINTF_H */
