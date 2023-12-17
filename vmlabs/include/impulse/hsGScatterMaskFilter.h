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

#ifndef hsGBlockMaskFilter_DEFINED
#define hsGBlockMaskFilter_DEFINED

#include "hsGMaskFilter.h"

class hsGScatterMaskFilter : public hsGMaskFilter {
	hsScalar	fRadius;
	UInt32		fFlags;

	Int32		ScaleRadius(const hsMatrix33* matrix) const;
public:
	enum {
		kNoGrow_Flag	= 0x0001
	};
	hsGScatterMaskFilter(hsScalar radius, UInt32 flags, hsScalar stdSize);
	hsGScatterMaskFilter(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);
	
	hsScalar		GetRadius() const { return fRadius; }
	virtual void	SetRadius(hsScalar radius);

	virtual void	Filter(const hsMatrix33* matrix, const hsGMask* src, hsGMask* dst) const;
	virtual void	FilterBounds(const hsMatrix33* matrix, hsIntRect* bounds) const;

	virtual const char* GetName();
	virtual void	Write(hsOutputStream* stream, UInt32 flags = 0);

	virtual CreateProc	GetCreateProc();

	static const char*	ClassName();
};

#endif
