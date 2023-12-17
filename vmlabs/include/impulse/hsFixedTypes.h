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

#ifndef hsFixedTypes_DEFINED
#define hsFixedTypes_DEFINED

#include "hsTypes.h"

#ifdef __cplusplus
extern "C" {
#endif

#define hsIntToFixed(x)		((hsFixed)(x) << 16)
#define hsFixedToInt(x)		((x) >> 16)
#define hsFixedRound(x)		(((x) + 0x8000) >> 16)
#define hsFixed1			hsIntToFixed(1)
#define hsFixedPI			(0x3243F)
#define hsFixedPiOver2		(0x1921F)

#define hsFixedToFract(x)	((hsFract)(x) << 14)
#define hsFractToFixed(x)	((hsFixed)(x) >> 14)
#define hsFract1			hsFixedToFract(hsFixed1)
#define hsFractPiOver2		(0x6487ED34)	/* needs some work */

#define hsFixFloor(x)	\
	(hsFixed)((x) < 0 ? -(hsFixed)((-(x) + 0xFFFF) & 0xFFFF0000) : (x) & 0xFFFF0000)

#define hsFixedToFloorInt(x)	\
	(int)((x) < 0 ? -(int)((-(x) + 0xFFFF) >> 16) : ((x) >> 16))

#define hsFixCeiling(x)	\
	(hsFixed)((x) < 0 ? -(hsFixed)(-(x) & 0xFFFF0000) : ((x) + 0xFFFF) & 0xFFFF0000)

#define hsFixedToCeilingInt(x)	\
	(int)((x) < 0 ? -(int)(-(x) >> 16) : (((x) + 0xFFFF) >> 16))


#if HS_CAN_USE_FLOAT
	#define hsFixedToFloat(x)		((x) / float(hsFixed1))
	#define hsFloatToFixed(x)		hsFixed((x) * hsFixed1)
	
	#define hsFractToFloat(x)		((x) / float(hsFract1))
	#define hsFloatToFract(x)		hsFract((x) * hsFract1)
#endif

#if (HS_BUILD_FOR_MAC68K || HS_BUILD_FOR_PALM) && !(HS_PIN_MATH_OVERFLOW)
	asm hsFixed hsFixMul68K(hsFixed a:__D0, hsFixed b:__D1);
	asm hsFixed hsFixDiv68K(hsFixed numer:__D0, hsFixed denom:__D1);

	#define hsFixMul(a, b)	hsFixMul68K(a, b)
	#define hsFixDiv(a, b)	hsFixDiv68K(a, b)
#else
	hsFixed hsFixMul(hsFixed a, hsFixed b);
	hsFixed hsFixDiv(hsFixed a, hsFixed b);
#endif

hsFract hsFracMul(hsFract a, hsFract b);
hsFract hsFracDiv(hsFract a, hsFract b);

hsFract	hsFracSqrt(hsFract value);
#define	hsFixSqrt(value)	(hsFracSqrt(value) >> 7)
hsFract	hsFracCubeRoot(hsFract value);
hsFixed	hsFixedSin(hsFixed s);
hsFixed	hsFixedCos(hsFixed s);
hsFixed	hsFixedASin(hsFixed s);
hsFixed	hsFixedACos(hsFixed s);

UInt16	hsSqrt32(UInt32 value);
UInt16	hsCubeRoot32(UInt32 value);
Int32	hsMulDiv32(Int32 numer1, Int32 numer2, Int32 denom);
Int32	hsMagnitude32(Int32 x, Int32 y);

#ifdef __cplusplus
}
#endif

#ifdef __cplusplus
	struct hsFixedPlane {
		hsFixed	fA, fB, fC;

		void		Set(hsFixed a, hsFixed b, hsFixed c) { fA = a; fB = b; fC = c; }

		hsFixed	FixEval(hsFixed x, hsFixed y) const { return hsFixMul(fA, x) + hsFixMul(fB, y) + fC; }
		Int32	IntEval(Int32 x, Int32 y) const { return fA * x + fB * y + fC; }
		void 		ShiftDown(UInt32 i) { fA >>= i; fB >>= i; fC >>= i;}
	};
#endif

#endif