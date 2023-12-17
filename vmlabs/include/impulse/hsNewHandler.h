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

#ifndef hsNewHandler_Defined
#define hsNewHandler_Defined

#include "hsExceptions.h"

#if !(HS_BUILD_FOR_WIN32) || !defined(HS_FIND_MEM_LEAKS)
	#include <new.h>
#endif

#if HS_BUILD_FOR_WIN32 && !defined(__MWERKS__)
	typedef int				hsNewHandler_ReturnType;
	typedef size_t			hsNewHandler_ParamType;
	typedef _PNH			hsNewHandler;

	#define hsNewHandler_Param	size

#ifdef HS_FIND_MEM_LEAKS
	#define hsSetNewHandler(h)	AfxSetNewHandler(h)
#else
	#define hsSetNewHandler(h)	_set_new_handler(h)
#endif

	#define hsNewHandler_Success()		return true
	#define hsNewHandler_CallHandler(h)	return h
	#define hsNewHandler_Failure()		hsThrowError(hsError::kBadAlloc); return false
#else
	typedef void			hsNewHandler_ReturnType;
	typedef void			hsNewHandler_ParamType;
	typedef new_handler		hsNewHandler;

	#define hsNewHandler_Param
	#define hsSetNewHandler(h)	set_new_handler(h)

	#define hsNewHandler_Success()		return
	#define hsNewHandler_CallHandler(h)	h
	#define hsNewHandler_Failure()		hsThrowError(hsError::kBadAlloc)
#endif

#endif
