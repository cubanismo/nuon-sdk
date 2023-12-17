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

#ifndef hsGMaskFilter_DEFINED
#define hsGMaskFilter_DEFINED

#include "hsGStdSizeable.h"
#include "hsMatrix33.h"
#include "hsPath.h"
#include "hsGMask.h"

class hsGAttribute;

namespace AlphaMask {
	class RawDraw;
}

/** For special effects such as blurring or embossing, the client may
	provide a subclass of hsGMaskFilter. This object, when present, is
	called to modify the alpha mask of a drawing primitive.

	A hsGMaskFilter is attached to an hsGAttribute via
	hsGAttribute::SetMaskFilter. */
class hsGMaskFilter : public hsGStdSizeable {
protected:
	hsGMask::Type	fMaskType;
public:
					hsGMaskFilter(hsGMask::Type maskType, hsScalar stdSize);
					hsGMaskFilter(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);

	hsGMask::Type	GetMaskType() const { return fMaskType; }

	virtual void	Filter(const hsMatrix* matrix, const hsGMask* src, hsGMask* dst) const = 0;
	virtual void	FilterBounds(const hsMatrix* matrix, hsIntRect* bounds) const;

	///	For streaming
	virtual void	Write(hsOutputStream* stream, UInt32 flags = 0);

	///	This performs the filter and call the blitter with the new mask
	void			FilterPath(const AlphaMask::RawDraw* rd, const hsPath* path,
							   const hsMatrix* matrix,
							   const hsGAttribute* attr) const;
};

#endif
