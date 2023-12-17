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

#ifndef AlphaMask_RawDraw_DEFINED
#define AlphaMask_RawDraw_DEFINED

#include "hsPath.h"

struct hsGColor;
struct hsGMask;
class hsGBitmap;
class hsGAttribute;
class hsScanRegion;
class HSScanHandler;

namespace AlphaMask {

class RawDraw {
	void	drawDevRect(const hsRect& rect, UInt32 styleFlags, hsScalar penSize) const;
	void	fillPath(const hsPath& path, UInt32 styleFlags) const;
	void	fillQuad(const hsPoint quad[4]) const;
public:
	const hsGBitmap*	fPixels;	// required
	const hsMatrix*		fMatrix;	// required
	const hsGAttribute*	fAttr;		// required
	const hsScanRegion*	fClip;		// may be nil
	HSScanHandler*		fHandler;	// may be nil

			RawDraw();

	void	drawFull() const;
	void	drawLine(const hsPoint& start, const hsPoint& stop) const;
	void	drawRect(const hsRect& rect) const;
	void	drawPath(const hsPath& path) const;
	void	drawMask(const hsGMask& mask) const;
	void	drawBitmap(const hsGBitmap& bitmap, hsScalar x, hsScalar y) const;
	void	drawText(UInt32 length, const void* text, hsScalar x, hsScalar y) const;
	void	drawPosText(UInt32 length, const void* text, const hsPoint pos[],
						 const hsVector tan[]) const;

	//	These ignore the matrix stack, but do respect the clip

	void	drawSprite(const hsGBitmap& bitmap, Int32 x, Int32 y) const;
	void	drawAsciiText( UInt32 length, const UInt8 text[], hsPoint* loc,
							const hsScalar underline[2]) const;

	//	Utilities

	void	erase(const hsGColor& color) const;
	void	scroll( const hsIntRect& srcRect, Int32 dx, Int32 dy,
					hsScanRegion* dirty = nil) const;
};

}

#endif
