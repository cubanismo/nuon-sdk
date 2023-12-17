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

#ifndef hsGRasterizer_DEFINED
#define hsGRasterizer_DEFINED

#include "hsGStdSizeable.h"
#include "hsMatrix33.h"

class hsPath;
struct hsGMask;
class hsScanRegion;

/** Clients may also override the scan conversion process by providing
	a subclass of hsGRasterizer. This object is passed a path, and
	returns an alpha mask.

	A hsGRasterizer is attached to an hsGAttribute via
	hsGAttribute::SetRasterizer.

	This class is reference counted. */
class hsGRasterizer : public hsGStdSizeable {
public:
					hsGRasterizer(hsScalar stdSize) : hsGStdSizeable(stdSize) {}
					hsGRasterizer(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0)
							: hsGStdSizeable(reg, stream, textSize) {}

	virtual void	GetBounds(const hsPath* path, const hsMatrix* matrix, hsIntRect* bounds) = 0;
	virtual void	Rasterize(const hsPath* path, const hsMatrix* matrix, const hsScanRegion* clip,
								hsGMask* mask) = 0;
};

#endif
