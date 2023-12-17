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

#ifndef hsPoint2_Defined
#define hsPoint2_Defined

#include "hsScalar.h"

#if __MWERKS__
	//	This guy disables MetroWerks' desire to only include a file once, which obviously gets
	//	in the way of our little HS_POINT2.inc trick
	#pragma once off
#endif

#define HS_POINT2_NAME		hsIntPoint
#define HS_POINT2_TYPE		Int32
#include "HS_POINT2.inc"
};

#define HS_POINT2_NAME		hsFixedPoint
#define HS_POINT2_TYPE		hsFixed
#include "HS_POINT2.inc"

	hsFixedPoint&	operator=(const hsIntPoint& src)
	{
		this->fX	= hsIntToFixed(src.fX);
		this->fY	= hsIntToFixed(src.fY);
		return *this;
	}

	hsFixed Magnitude() const { return hsMagnitude32(fX, fY); }

	static hsFixed	Magnitude(hsFixed x, hsFixed y)
	{
		return hsMagnitude32(x, y);
	}
	static hsFixed	Distance(const hsFixedPoint& p1, const hsFixedPoint& p2)
	{
		return hsMagnitude32(p2.fX - p1.fX, p2.fY - p1.fY);
	}
	static hsFixedPoint Average(const hsFixedPoint& a, const hsFixedPoint& b)
	{
		hsFixedPoint	result;
		result.Set((a.fX + b.fX) >> 1, (a.fY + b.fY)  >> 1);
		return result;
	}
};

#if HS_CAN_USE_FLOAT
	#define HS_POINT2_NAME		hsFloatPoint
	#define HS_POINT2_TYPE		float
	#include "HS_POINT2.inc"

		hsFloatPoint& operator=(const hsIntPoint& src)
		{
			this->fX = float(src.fX);
			this->fY = float(src.fY);
			return *this;
		}

		friend hsFloatPoint operator*(const hsFloatPoint& s, float t)
		{
			hsFloatPoint	result;
			result.Set(s.fX * t, s.fY * t);
			return result;
		}
		friend hsFloatPoint operator*(float t, const hsFloatPoint& s)
		{
			hsFloatPoint	result;
			result.Set(s.fX * t, s.fY * t);
			return result;
		}

		float		Magnitude() const { return hsFloatPoint::Magnitude(fX, fY); }
		float		MagnitudeSquared() const { return fX * fX + fY * fY; }

		static float	Magnitude(float x, float y) { return (float)sqrt(x * x + y * y); }
		static hsScalar	Distance(const hsFloatPoint& p1, const hsFloatPoint& p2);
		static hsFloatPoint Average(const hsFloatPoint& a, const hsFloatPoint& b)
		{
			hsFloatPoint	result;
			result.Set((a.fX + b.fX) * float(0.5), (a.fY + b.fY) * float(0.5));
			return result;
		}
		static hsScalar	ComputeAngle(const hsFloatPoint& a, const hsFloatPoint& b, const hsFloatPoint& c);
	};

	//	For compatibility
	//
	typedef hsFloatPoint	hsFloatPoint2;
#endif

#if HS_SCALAR_IS_FIXED
	typedef hsFixedPoint	hsPoint;
#else
	typedef hsFloatPoint	hsPoint;
#endif

typedef hsPoint				hsVector;

//	For compatibility
//
typedef hsIntPoint		hsIntPoint2;
typedef hsFixedPoint	hsFixedPoint2;
typedef hsPoint 		hsPoint2;

#endif	// hsPoint2_Defined

