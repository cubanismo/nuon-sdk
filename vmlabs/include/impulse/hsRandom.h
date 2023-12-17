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

#ifndef hsRandom_DEFINED
#define hsRandom_DEFINED

#include "hsScalar.h"

//	"Numerical Recipes in C", 1992 page 284

class hsRandom {
	enum {
		kMul = 1664525,
		kAdd = 1013904223
	};
	UInt32	fSeed;
public:
	UInt32	GetSeed() const { return fSeed; }
	void		SetSeed(UInt32 seed) { fSeed = seed; }

	UInt32	NextU() { fSeed = kMul * fSeed + kAdd; return fSeed; }
	Int32	NextS() { fSeed = kMul * fSeed + kAdd; return (Int32)fSeed; }

	UInt32	NextUMod(UInt32 value) { return this->NextU() % value; }
	Int32	NextSMod(Int32 value) { return this->NextS() % value; }

	//	All of these [Fixed, Float, Scalar] return unit values...
	//		U returns 0..1
	//		S returns -1..1

	hsFixed	NextUFixed() { return this->NextU() >> 16; }
	hsFixed	NextUFixed(hsFixed scale) { return hsFixMul(this->NextUFixed(), scale); }
	hsFixed	NextSFixed() { return this->NextS() >> 16; }
	hsFixed	NextSFixed(hsFixed scale) { return hsFixMul(this->NextSFixed(), scale); }

#if HS_CAN_USE_FLOAT
	float	NextUFloat();
	float	NextUFloat(float scale);
	float	NextSFloat();
	float	NextSFloat(float scale);
#endif

#if HS_SCALAR_IS_FIXED
	hsFixed	NextUScalar() { return this->NextUFixed(); }
	hsFixed	NextUScalar(hsFixed scale) { return this->NextUFixed(scale); }
	hsFixed	NextSScalar() { return this->NextSFixed(); }
	hsFixed	NextSScalar(hsFixed scale) { return this->NextSFixed(scale); }
#else
	float	NextUScalar() { return this->NextUFloat(); }
	float	NextUScalar(float scale) { return this->NextUFloat(scale); }
	float	NextSScalar() { return this->NextSFloat(); }
	float	NextSScalar(float scale) { return this->NextSFloat(scale); }
#endif	

	//	This guy is defined in hsRandom.cpp
	static hsRandom gRAND;
};

#endif
