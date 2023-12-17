/*
 * Copyright (C) 1999 all rights reserved by AlphaMask, Inc. Cambridge, MA USA
 *
 * This software is the property of AlphaMask, Inc. and it is furnished
 * under a license and may be used and copied only in accordance with the
 * terms of such license and with the inclusion of the above copyright notice.
 * This software or any other copies thereof may not be provided or otherwise
 * made available to any other person or entity except as allowed under license.
 * No title to and ownership of the software or intellectual property
 * therewithin is hereby transferred.
 *
 * ALPHAMASK MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY
 * OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. ALPHAMASK SHALL NOT BE LIABLE FOR
 * ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
 * DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 *
 * This information in this software is subject to change without notice
*/

#ifndef hsException_DEFINED
#define hsException_DEFINED

#include "hsTypes.h"
#ifdef IMPULSE_NO_EXCEPTIONS
#include <stdio.h>
#warning TODO: Need to deal with Impulse exceptions
#endif

class hsError {
public:
	enum ID {
		kNone,
		kInternal,
		kBadAlloc,
		kNilParam,
		kBadParam,
		kStreamRead,
		kStreamWrite,
		kStreamSkip,
		kOSError
	};
};

class hsException {
public:
	hsError::ID	fError;
	long		fParam;
	
	hsException(hsError::ID error, long param = 0) : fError(error), fParam(param) {}
};



inline void hsThrowError(hsError::ID err, long param = 0)
{
#ifndef IMPULSE_NO_EXCEPTIONS
	throw hsException(err, param);
#endif
}

inline void hsThrowString(const char message[])
{
#ifndef IMPULSE_NO_EXCEPTIONS
	throw message;
#else
	fprintf(stderr, "IMPULSE: %s\n", message);
#endif
}

inline void hsThrowIfNilParam(const void* p)
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (p == nil)
		throw hsException(hsError::kNilParam);
#endif
}

inline void hsThrowIfBadParam(hsBool trueIfBadParam)
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (trueIfBadParam)
		throw hsException(hsError::kBadParam);
#endif
}

inline void hsThrowIfOSErr(long osErr)
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (osErr != 0)
		throw hsException(hsError::kOSError, osErr);
#endif
}

inline void hsThrowIfTrue(hsBool condition)
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (condition)
		throw hsException(hsError::kInternal);
#endif
}

inline void hsThrowIfTrue(hsBool condition, hsError::ID err)
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (condition)
		throw hsException(err);
#endif
}

inline void hsThrowIfTrue(hsBool condition, const char message[])
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (condition)
		throw message;
#else
	if (condition)
		fprintf(stderr, "IMPULSE: %s\n", message);
#endif
}

inline void hsThrowIfFalse(hsBool condition)
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (condition == false)
		throw hsException(hsError::kInternal);
#endif
}

inline void hsThrowIfFalse(hsBool condition, hsError::ID err)
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (condition == false)
		throw hsException(err);
#endif
}

inline void hsThrowIfFalse(hsBool condition, const char message[])
{
#ifndef IMPULSE_NO_EXCEPTIONS
	if (condition == false)
		throw message;
#else
	if (condition == false)
		fprintf(stderr, "IMPULSE: %s\n", message);
#endif
}

#endif
