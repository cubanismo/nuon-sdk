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

#ifndef hsRect_DEFINED
#define hsRect_DEFINED

#include "hsPoint2.h"

#if HS_BUILD_FOR_MAC
	//	This guy disables MetroWerks' desire to only include a file once, which obviously gets
	//	in the way of our little HS_RECT.inc trick
	#pragma once off
#endif

#define HS_RECT_NAME		hsIntRect
#define HS_RECT_POINT		hsIntPoint
#define HS_RECT_TYPE		Int32
#define HS_RECT_EXTEND		1
#include "HS_RECT.inc"

#if HS_BUILD_FOR_MAC
	Rect*		ToRect(Rect* r) const
				{
					r->left = (Int16)this->fLeft;
					r->top = (Int16)this->fTop;
					r->right = (Int16)this->fRight;
					r->bottom = (Int16)this->fBottom;
					return r;
				}
	hsIntRect*	Set(const Rect* r)
				{
					return this->Set(r->left, r->top, r->right, r->bottom);
				}
#endif
#ifdef _WINDOWS_
	RECT*		ToRECT(RECT* r) const
				{
					r->left = this->fLeft;
					r->top = this->fTop;
					r->right = this->fRight;
					r->bottom = this->fBottom;
					return r;
				}
	hsIntRect*	Set(const RECT* r)
				{
					return this->Set(r->left, r->top, r->right, r->bottom);
				}
#endif
};

#define HS_RECT_NAME		hsFixedRect
#define HS_RECT_POINT		hsFixedPoint
#define HS_RECT_TYPE		hsFixed
#define HS_RECT_EXTEND		1
#include "HS_RECT.inc"

	hsFixedRect* Set(const hsIntRect* src)
				{
					this->fLeft	= hsIntToFixed(src->fLeft);
					this->fTop		= hsIntToFixed(src->fTop);
					this->fRight	= hsIntToFixed(src->fRight);
					this->fBottom	= hsIntToFixed(src->fBottom);
					return this;
				}

	hsFixed		CenterX(void) const { return (fLeft + fRight) >> 1; }
	hsFixed		CenterY(void) const { return (fTop + fBottom) >> 1; }
	hsFixedPoint*	Center(hsFixedPoint* center) const
				{
					(void)center->Set(this->CenterX(), this->CenterY());
					return center;
				}
	hsIntRect*	Truncate(hsIntRect* dst) const
				{
					return (hsIntRect*)dst->Set(	hsFixedToInt(fLeft), hsFixedToInt(fTop),
											hsFixedToInt(fRight), hsFixedToInt(fBottom));
				}
	hsIntRect*	Round(hsIntRect* dst) const
				{
					return (hsIntRect*)dst->Set(	hsFixedRound(fLeft), hsFixedRound(fTop),
											hsFixedRound(fRight), hsFixedRound(fBottom));
				}
	hsIntRect*	RoundOut(hsIntRect* dst) const
				{
					return (hsIntRect*)dst->Set(	hsFixedToFloorInt(fLeft),
											hsFixedToFloorInt(fTop),
											hsFixedToCeilingInt(fRight),
											hsFixedToCeilingInt(fBottom));
				}
};

#if HS_SCALAR_IS_FLOAT
	#define HS_RECT_NAME		hsFloatRect
	#define HS_RECT_POINT		hsFloatPoint
	#define HS_RECT_TYPE		float
	#define HS_RECT_EXTEND		1
	#include "HS_RECT.inc"

	hsFloatRect* Set(const hsIntRect* src)
				{
					this->fLeft	= float(src->fLeft);
					this->fTop		= float(src->fTop);
					this->fRight	= float(src->fRight);
					this->fBottom	= float(src->fBottom);
					return this;
				}

		float			CenterX(void) const { return (fLeft + fRight) / float(2); }
		float			CenterY(void) const { return (fTop + fBottom) / float(2); }
		hsFloatPoint*	Center(hsFloatPoint* center) const
					{
						(void)center->Set(this->CenterX(), this->CenterY());
						return center;
					}
		float			Area() const { return this->Width() * this->Height(); }

		hsIntRect*	Round(hsIntRect* r) const;
		hsIntRect* 	RoundOut(hsIntRect* r) const;
		hsIntRect*	Truncate(hsIntRect* r) const;
	};
#endif

#if HS_SCALAR_IS_FIXED
	typedef hsFixedRect		hsRect;
#else
	typedef hsFloatRect		hsRect;
#endif

#endif
