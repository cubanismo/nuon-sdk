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

#ifndef hsGBlurMaskFilter_DEFINED
#define hsGBlurMaskFilter_DEFINED

#include "hsGMaskFilter.h"

class hsGBlurMaskFilter : public hsGMaskFilter {
	hsScalar	fInnerRadius, fOuterRadius;
	mutable int	fDevInnerRadius, fDevOuterRadius;
	hsBool		fFillBlur;

	void			ScaleRadii(const hsMatrix33* matrix) const;
public:
					hsGBlurMaskFilter(hsScalar innerRadius, hsScalar outerRadius,
										hsBool doFill, hsScalar stdSize);
					hsGBlurMaskFilter(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);

	virtual void	FilterBounds(const hsMatrix33* matrix, hsIntRect* bounds) const;
	virtual void	Filter(const hsMatrix33* matrix, const hsGMask* src, hsGMask* dst) const;

	virtual CreateProc	GetCreateProc();

	virtual const char* GetName();
	virtual void	Write(hsOutputStream* stream, UInt32 flags = 0);

	static const char*	ClassName();
};

#endif
