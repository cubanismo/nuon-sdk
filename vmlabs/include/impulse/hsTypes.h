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

#ifndef hsTypes_DEFINED
#define hsTypes_DEFINED

#ifndef hsConfig_DEFINED
	#include "hsConfig.h"
#endif

/************ These are the computed defines based on hsConfig.h ************/

#ifndef HS_DEBUGGING
	#define HS_RELEASE
#endif

#if defined(HS_BUILD_FOR_NUON) && defined(WIN32)
	#define HS_BUILD_FOR_NUON_ON_WIN32
#endif

#if defined(HS_BUILD_FOR_NUON_ON_WIN32)
		#define HS_CPU_BENDIAN		0
		#define HS_CPU_LENDIAN		1
#endif

#ifndef HS_CPU_BENDIAN
	#if HS_BUILD_FOR_WIN32
		#define HS_CPU_BENDIAN		0
		#define HS_CPU_LENDIAN		1
	#else
		#define HS_CPU_BENDIAN		1
		#define HS_CPU_LENDIAN		0
	#endif
#endif

#ifdef HS_DEBUGGING
	#define DEBUG_INLINE	static
#else
	#define DEBUG_INLINE	inline
#endif

#if defined(HS_BUILD_FOR_MAC68K) || defined(HS_BUILD_FOR_MACPPC) 
	#define HS_BUILD_FOR_MAC		1
#endif

#if defined(__INTEL__) && defined(HS_BUILD_FOR_MAC)
	#error "Can't have HS_BUILD_FOR_MAC defined"
#endif
#if (defined(GENERATING68K) || defined(GENERATINGPOWERPC)) && defined(HS_BUILD_FOR_WIN32)
	#define "Can't define HS_BUILD_FOR_WIN32"
#endif

#define HS_SCALAR_IS_FIXED			!(HS_SCALAR_IS_FLOAT)
#define HS_NEVER_USE_FLOAT			!(HS_CAN_USE_FLOAT)

#if HS_DEBUG_MATH_OVERFLOW && !(HS_PIN_MATH_OVERFLOW)
	#error "Can't debug overflow unless HS_PIN_MATH_OVERFLOW is ON"
#endif

#if HS_SCALAR_IS_FIXED && defined(HS_DEBUGGING)
	#define HS_PIN_MATH_OVERFLOW	1	/* This forces hsWide versions of FixMath routines */
	#define HS_DEBUG_MATH_OVERFLOW	1	/* This calls hsDebugMessage on k[Pos,Neg]Infinity */
#endif

#if !(HS_BUILD_FOR_PALM)
	#define HS_HAS_STDFILE			1
	#define HS_HAS_STDIO			1
#endif

#if !defined(HS_PIXEL_FORMAT_BGRA) && \
	!defined(HS_PIXEL_FORMAT_ABGR) && \
	!defined(HS_PIXEL_FORMAT_RGBA) && \
	!defined(HS_PIXEL_FORMAT_ARGB)
	#if HS_BUILD_FOR_BE
		#define HS_PIXEL_FORMAT_BGRA
	#elif HS_BUILD_FOR_UNIX
		#define HS_PIXEL_FORMAT_ABGR
	#else
		#define HS_PIXEL_FORMAT_ARGB
	#endif
#endif

#if HS_IMPULSE_SUPPORT_NOCURSOR
	#define HS_IMPULSE_SUPPORT_CURSOR		0
#else
	#define HS_IMPULSE_SUPPORT_CURSOR		1
#endif

#if HS_BUILD_FOR_UNIX
	#define INIT_TO_ZERO_FOR_GCC_WARNING	= 0
#elif HS_BUILD_FOR_NUON
	#define INIT_TO_ZERO_FOR_GCC_WARNING	= 0
#else
	#define INIT_TO_ZERO_FOR_GCC_WARNING
#endif

/************************** Other Includes *****************************/

#include "hsString.h"

#if HS_BUILD_FOR_PALM
	#include <SystemMgr.h>
#elif !(HS_BUILD_FOR_REFERENCE)
	#if HS_BUILD_FOR_MAC
		#include <Types.h>
		#include <ctype.h>
		#include <memory.h>
	#endif
		#include <stdlib.h>
		#include <stdio.h>
		
#endif
#if HS_CAN_USE_FLOAT
	#include <math.h>
#endif

#ifdef HS_DEBUGGING
	#if HS_BUILD_FOR_WIN32
		#ifdef HS_FIND_MEM_LEAKS
			#define VC_EXTRALEAN	/* Exclude rarely-used stuff from Windows headers */
			#ifdef __cplusplus
				#include <afx.h>
			#endif
			#define new DEBUG_NEW
		#else
			#include <crtdbg.h>		/* for hsAssert _RPT */
		#endif
	#endif
#endif

/************************** Basic Macros *****************************/

#ifdef __cplusplus
	#define hsCTypeDefStruct(foo)
#else
	#define hsCTypeDefStruct(foo)		typedef struct foo foo;
#endif

/************************** Basic Types *****************************/

/// 16-bit signed positive infinity
#define kPosInfinity16		(32767)
/// 16-bit signed negative infinity
#define kNegInfinity16		(-32768)

/// 32-bit signed positive infinity
#define kPosInfinity32		(0x7fffffff)
/// 32-bit signed negative infinity
#define kNegInfinity32		(0x80000000)

/// Signed 32-bit integer
typedef long				Int32;
/// Signed 16-bit integer
typedef short				Int16;

#if !(HS_BUILD_FOR_MAC)
	/// Unsigned 8-bit integer
	typedef unsigned char	UInt8;
	/// Unsigned 16-bit integer
	typedef unsigned short	UInt16;
	/// Unsigned 32-bit integer
	typedef unsigned long	UInt32;
	#ifndef Byte
		///
		typedef UInt8		Byte;
	#endif

	#ifndef false
		#define false		0
	#endif
	#ifndef true
		#define true		1
	#endif
#endif

/// 16.16 signed fixed-point integer
typedef Int32 			hsFixed;
/// 8.24 signed fixed-point integer
typedef Int32 			hsFract;

/// Unsigned 8-bit integer
typedef UInt8			hsBool8;
/// Unsigned 16-bit integer
typedef UInt16			hsBool16;
/// Unsigned 32-bit integer
typedef UInt32			hsBool32;

#ifdef __cplusplus
	typedef bool			hsBool;
	#define hsIntToBool(v)	((v) != 0)
#else
	typedef int				hsBool;
	#define hsIntToBool(v)	(v)
#endif

#if HS_CAN_USE_FLOAT
	#define HS_PI		3.1415927
#endif

#ifndef nil
#define nil (0)
#endif

#define hsLongAlign(n)		(((n) + 3) & ~3L)
#define hsMaximum(a, b)		((a) > (b) ? (a) : (b))
#define hsMinimum(a, b)		((a) < (b) ? (a) : (b))
#define hsABS(x)			((x) < 0 ? -(x) : (x))
#define hsSGN(x) 			(((x) < 0) ? -1 : ( ((x) > 0) ? 1 : 0 ))

#define hsBitTst2Bool(value, mask)		(((value) & (mask)) != 0)

#define hsFourByteTag(a, b, c, d)		(((UInt32)(a) << 24) | ((UInt32)(b) << 16) | ((UInt32)(c) << 8) | (d))

/************************** Swap Macros *****************************/

#ifdef __cplusplus
	inline UInt16 hsSwapEndian16(UInt16 value)
	{
		return UInt16((value >> 8) | (value << 8));
	}
	inline UInt32 hsSwapEndian32(UInt32 value)
	{
		return	(value << 24) |
				((value & 0xFF00) << 8) |
				((value >> 8) & 0xFF00) |
				(value >> 24);
	}
	#if HS_CAN_USE_FLOAT
		inline float hsSwapEndianFloat(float fvalue)
		{
			UInt32 value = *(UInt32*)&fvalue;
			value = hsSwapEndian32(value);
			return *(float*)&value;
		}
	#endif

	#if HS_CPU_LENDIAN
		#define hsSWAP16(n)	hsSwapEndian16(n)
		#define hsSWAP32(n)	hsSwapEndian32(n)
	#else
		#define hsSWAP16(n)	(n)
		#define hsSWAP32(n)	(n)
	#endif

	inline void hsSwap(Int32& a, Int32& b)
	{
		Int32	c = a;
		a = b;
		b = c;
	}

	inline void hsSwap(UInt32& a, UInt32& b)
	{
		UInt32	c = a;
		a = b;
		b = c;
	}

	#if HS_CAN_USE_FLOAT
		inline void hsSwap(float& a, float& b)
		{
			float	c = a;
			a = b;
			b = c;
		}
	#endif
#endif

/************************** Debug Macros *****************************/

struct hsColor32 {
//#if (HS_BUILD_FOR_WIN32 || HS_BUILD_FOR_BE)
#if ((defined(HS_PIXEL_FORMAT_BGRA) && HS_CPU_BENDIAN) || \
	 (defined(HS_PIXEL_FORMAT_ARGB) && HS_CPU_LENDIAN))
	UInt8	b, g, r, a;
#elif ((defined(HS_PIXEL_FORMAT_ABGR) && HS_CPU_BENDIAN) ||	\
	   (defined(HS_PIXEL_FORMAT_RGBA) && HS_CPU_LENDIAN))
	UInt8	a, b, g, r;
#elif ((defined(HS_PIXEL_FORMAT_RGBA) && HS_CPU_BENDIAN) ||	\
	   (defined(HS_PIXEL_FORMAT_ABGR) && HS_CPU_LENDIAN))
	UInt8	r, g, b, a;
#else
	UInt8	a, r, g, b;
#endif

#ifdef __cplusplus
	void		SetARGB(UInt8 aa, UInt8 rr, UInt8 gg, UInt8 bb)
			{
				this->a = aa; this->r = rr; this->g = gg; this->b = bb;
			}

	//	Compatibility inlines, should be depricated
	void		Set(UInt8 rr, UInt8 gg, UInt8 bb)
			{
				this->r = rr; this->g = gg; this->b = bb;
			}
	void		Set(UInt8 aa, UInt8 rr, UInt8 gg, UInt8 bb)
			{
				this->SetARGB(aa, rr, gg, bb);
			}

	friend int	operator==(const hsColor32& a, const hsColor32& b)
			{
				return *(UInt32*)&a == *(UInt32*)&b;
			}
	friend int	operator!=(const hsColor32& a, const hsColor32& b) { return !(a == b); }
#endif
};
hsCTypeDefStruct(hsColor32)

/************************** Debug Macros *****************************/

#ifdef __cplusplus
extern "C" {
#endif

#ifdef HS_DEBUGGING
	
	void	hsDebugMessage(const char message[], long refcon);
	void	hsAssertFunc(int line, const char *file, const char *message);
	#define hsDebugCode(code)		code
#if HS_BUILD_FOR_WIN32
	#define hsAssert(cond, m) do { if(!(cond)) { hsDebugMessage(m, 0); _RPTF0(_CRT_ERROR, m); } } while (0)
#else
	#define hsAssert(cond, message) do { if(!(cond)) hsAssertFunc(__LINE__,__FILE__, message); } while (0)
#endif
	#define hsIfDebugMessage(clause, message, refcon)	do { if (clause) hsDebugMessage(message, refcon); } while (0)
#else	/* Not debugging */
	#define hsDebugMessage(message, refcon)
	#define hsAssertFunc(line, file, message)

	#define hsDebugCode(code)		
	#define hsIfDebugMessage(clause, message, refcon)
	#define hsAssert(cond, message)
#endif

#ifdef __cplusplus
}
#endif

#endif

