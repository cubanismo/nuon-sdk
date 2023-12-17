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

#ifndef hsScalarMacrosDefined
#define hsScalarMacrosDefined

#include "hsFixedTypes.h"

#ifndef HS_SCALAR_IS_FLOAT
	#define HS_SCALAR_IS_FIXED		0
	#define HS_SCALAR_IS_FLOAT		1
	#define HS_NEVER_USE_FLOAT		0
#endif

#if HS_SCALAR_IS_FLOAT && HS_NEVER_USE_FLOAT
	#error "can't define HS_SCALAR_IS_FLOAT and HS_NEVER_USE_FLOAT"
#endif

#if HS_SCALAR_IS_FLOAT
	#include <math.h>
#endif

#define hsScalarDegToRad(deg)			hsScalarMul(deg, hsScalarPI / 180)
#define hsScalarRadToDeg(rad)			hsScalarMul(rad, 180 / hsScalarPI)

#if HS_SCALAR_IS_FIXED
	typedef hsFixed						hsScalar;

	#define hsScalar1					hsFixed1
	#define hsScalarHalf				(hsFixed1 >> 1)
	#define hsScalarPI					(hsFixedPI)
	#define hsScalarMax					(0x7fffffff)

	#if HS_CAN_USE_FLOAT || HS_FLOAT_TO_SCALAR
		#define hsFloatToScalar(x)		hsFixed((x) * float(hsFixed1))
		#define hsScalarToFloat(x)		((x) / float(hsFixed1))
	#endif

	#define hsIntToScalar(x)			hsIntToFixed(x)
	#define hsScalarToInt(x)			hsFixedToInt(x)
	#define hsScalarRound(x)			hsFixedRound(x)

	#define hsFixedToScalar(x)			(x)
	#define hsScalarToFixed(x)			(x)

	#define hsFractToScalar(x)			hsFractToFixed(x)
	#define hsScalarToFract(x)			hsFixedToFract(x)

	#define hsScalarMul(a, b)			hsFixMul(a, b)
	#define hsScalarMul2(a)				((a) << 1)
	#define hsScalarDiv(a, b)			hsFixDiv(a, b)
	#define hsScalarDiv2(a)				((a) >> 1)
	#define hsScalarInvert(a)			hsFixDiv(hsFixed1, a)
	#define hsScalarMod(a,b)			((a) % (b))
	#define hsScalarMulDiv(n1, n2, d)	hsMulDiv32(n1, n2, d)
	#define hsScalarMulAdd(a, b, c)		(hsFixMul(a, b) + (c))

	#define hsSquareRoot(scalar)		hsFixSqrt(scalar)
	#define hsSine(angle)				hsFixedSin(angle)
	#define hsCosine(angle)				hsFixedCos(angle)
	#define hsASine(value)				hsFixedASin(value)
	#define hsACosine(value)			hsFixedACos(value)

#ifdef __cplusplus
	inline hsScalar hsScalarAverage(hsScalar a, hsScalar b) { return (a + b) >> 1; }
	inline hsScalar hsScalarAverage(hsScalar a, hsScalar b, hsScalar t)
	{
		return a + hsFixMul(t, b - a);
	}

	#if HS_CAN_USE_FLOAT
		inline hsScalar hsPow(hsScalar base, hsScalar exponent)
		{
			return hsFloatToScalar(powf(hsScalarToFloat(base), hsScalarToFloat(exponent)));
		}
		inline hsScalar hsATan2(hsScalar y, hsScalar x)
		{
			return hsFloatToScalar(atan2f(hsScalarToFloat(y), hsScalarToFloat(x)));
		}
	#endif
	inline hsScalar hsCeil(hsScalar x) { return hsScalar((x + 0xFFFF) & 0xFFFF0000); }
	inline hsScalar hsFloor(hsScalar x) { return hsScalar(x & 0xFFFF0000); }
#endif 
#endif
#if HS_SCALAR_IS_FLOAT
/** The type of a scalar number

	Impulse can be conditionally compiled to use or not use floating
	point numbers. To facilitate this, all Impulse coordinates use the
	type \textbf{hsScalar}, denoting a 32-bit fractional value that may
	be a float or a 16.16 fixed.

	For concreteness, the floating-point scalar is shown here. */
	typedef float					hsScalar;

	#define hsScalar1				float(1)
	#define hsScalarHalf			float(0.5)
	#define hsScalarPI				float(HS_PI)
	#define hsScalarMax				float(3.402823466e+38F)

	#define hsFloatToScalar(x)		float(x)
	#define hsScalarToFloat(x)		float(x)

	#define hsIntToScalar(x)		float(x)
	#define hsScalarToInt(x)		Int32(x)


	#define hsFixedToScalar(x)		((hsScalar)(x) / float(hsFixed1))
	#define hsScalarToFixed(x)		hsFixed((x) * float(hsFixed1))

	#define hsFractToScalar(x)		((x) / float(hsFract1))
	#define hsScalarToFract(x)		hsFract((x) * float(hsFract1))
#ifdef __cplusplus

	#define hsScalarMod(a,b)		fmodf(a, b)
	#define hsScalarMulAdd(a, b, c)	(float(a) * float(b) + float(c))
	#define hsScalarMul(a,b)		(float(a) * float(b))
	#define hsScalarMul2(a)			((a) * float(2))
	#define hsScalarDiv(a,b)		(float(a) / float(b))
	#define hsScalarDiv2(a)			((a) * float(0.5))
	#define hsScalarInvert(a)		(float(1) / (a))
	#define hsScalarMulDiv(n1,n2,d)	(float(n1) * float(n2) / float(d))

#ifndef HS_DEBUGGING 	/* mf horse testing defines vs inlines for VC++5.0 performance */

	#define hsScalarRound(x)			Int32((x) + ((x) < 0 ? -hsScalarHalf : hsScalarHalf))

#else /* HS_DEBUGGING - use inlines for type-checking etc...and all */
	inline Int32 hsScalarRound(float x)
	{
		float half = hsScalarHalf;
		if (x < 0)
			half = -half;
		return Int32(x + half);
	}
#endif /* HS_DEBUGGING - use inlines for type-checking etc...and all */

	inline float hsScalarAverage(float a, float b) { return (a + b) * float(0.5); }
	inline float hsScalarAverage(float a, float b, float t) { return a + t * (b - a); }

#if (HS_BUILD_FOR_BE || HS_BUILD_FOR_UNIX)
	#define acosf(x)		(float)acos(x)
	#define asinf(x)		(float)asin(x)
	#define atanf(x)		(float)atan(x)
	#define atan2f(x, y)	(float)atan2(x, y)
	#define ceilf(x)		(float)ceil(x)
	#define cosf(x)			(float)cos(x)
	#define coshf(x)		(float)cosh(x)
	#define expf(x)			(float)exp(x)
	#define fabsf(x)		(float)fabs(x)
	#define floorf(x)		(float)floor(x)
	#define fmodf(x, y)		(float)fmod(x, y)
	#define logf(x)			(float)log(x)
	#define log10f(x)		(float)log10(x)
	#define powf(x, y)		(float)pow(x, y)
	#define sinf(x)			(float)sin(x)
	#define sinhf(x)		(float)sinh(x)
	#define sqrtf(x)		(float)sqrt(x)
	#define tanf(x)			(float)tan(x)
	#define tanhf(x)		(float)tanh(x)

	inline float modff(float x, float* y)
	{
		double _Di, _Df = modf(x, &_Di);
		*y = (float)_Di;
		return ((float)_Df);
	}
#endif

	inline hsScalar hsSquareRoot(hsScalar scalar) { return sqrtf(scalar); }
	inline hsScalar hsSine(hsScalar angle) { return sinf(angle); }
	inline hsScalar hsCosine(hsScalar angle) { return cosf(angle); }
	inline hsScalar hsASine(hsScalar value) { return asinf(value); }
	inline hsScalar hsACosine(hsScalar value) { return acosf(value); }
	inline hsScalar hsPow(hsScalar base, hsScalar exponent) { return powf(base, exponent); }
	inline hsScalar hsATan2(hsScalar y, hsScalar x) { return atan2f(y, x); }
	inline hsScalar hsCeil(hsScalar x) { return ceilf(x); }
	inline hsScalar hsFloor(hsScalar x) { return floorf(x); }
#endif	/* __CPLUSPLUS */
#endif	/* HS_SCALAR_IS_FLOAT */

inline hsScalar hsScalarSquare(hsScalar x) { return hsScalarMul(x, x); }

#endif
