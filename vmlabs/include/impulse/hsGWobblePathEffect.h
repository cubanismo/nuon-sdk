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

#ifndef hsGWobblePathEffect_DEFINED
#define hsGWobblePathEffect_DEFINED

#include "hsGPathEffect.h"
#include "hsRandom.h"

struct hsGWobbleEffectRecord {
	hsScalar	fPeriod;
	hsScalar	fDeviation;
	hsScalar	fRandom;
	hsScalar	fSmooth;
	
	void Reset()
	{
		fPeriod		= 0;
		fDeviation		= 0;
		fRandom		= 0;
		fSmooth		= 0;
	}
	friend int operator==(const hsGWobbleEffectRecord& a, const hsGWobbleEffectRecord& b)
	{
		return	a.fPeriod		== b.fPeriod &&
				a.fDeviation	== b.fDeviation &&
				a.fRandom		== b.fRandom &&
				a.fSmooth		== b.fSmooth;
	}
	friend int operator!=(const hsGWobbleEffectRecord& a, const hsGWobbleEffectRecord& b)
	{
		return !(a == b);
	}
};

class hsGWobblePathEffect : public hsGPathEffect {
	mutable hsRandom		fRAND;
	hsGWobbleEffectRecord	fRecord;

	void				WobbleContour(class hsPathMeasure* src, hsPath* dst, hsBool isClosed,
										hsScalar period, hsScalar deviation) const;
public:
						hsGWobblePathEffect(const hsGWobbleEffectRecord* record,
											hsScalar stdSize);
						hsGWobblePathEffect(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);

	void				SetWobble(const hsGWobbleEffectRecord* record);

	virtual hsBool		Filter(const hsGPathEffect::Record* input, hsGPathEffect::Record* output) const;

	virtual CreateProc	GetCreateProc();
	virtual const char*	GetName();
	virtual void		Write(hsOutputStream* stream, UInt32 flags = 0);

	static const char*	ClassName();
};

#endif
