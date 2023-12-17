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

#ifndef hsGImageFilter_DEFINED
#define hsGImageFilter_DEFINED

#include "hsGStdSizeable.h"
#include "hsGBitmap.h"

/**
	A hsGImageFilter is attached to an hsGAttribute via
	hsGAttribute::SetImageFilter. */
class hsGImageFilter : public hsGStdSizeable {
public:
					hsGImageFilter() : hsGStdSizeable(0) {}
					hsGImageFilter(hsRegistry* reg, hsInputStream* stream)
								: hsGStdSizeable(reg, stream, 0) {}

	virtual hsBool	FilterBounds(const hsIntRect* src, hsIntRect* dst);
	virtual hsBool	FilterImage(const hsGBitmap* src, hsGBitmap* dst) = 0;

	//	Override this, throwing an exception, since we never record
	//	image-filters in the text-cache
	//
	virtual CreateProc	GetCreateProc();
};

#endif
