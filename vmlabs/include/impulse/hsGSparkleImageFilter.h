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

#ifndef hsGSparkleImageFilter_DEFINED
#define hsGSparkleImageFilter_DEFINED

#include "hsGImageFilter.h"
#include "hsRandom.h"

///
class hsGSparkleImageFilter : public hsGImageFilter {
	hsRandom		fRand;
	UInt8			fMod;
	
	inline UInt8	SparkleByte(UInt8 value, UInt8 max);
public:
	///
					hsGSparkleImageFilter(UInt8 range = 64);

	virtual hsBool	FilterImage(const hsGBitmap* src, hsGBitmap* dst);

	virtual const char* GetName();
};

#endif
