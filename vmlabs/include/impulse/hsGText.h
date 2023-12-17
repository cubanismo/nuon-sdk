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

#ifndef hsGText_DEFINED
#define hsGText_DEFINED

#include "hsRefCnt.h"
#include "hsFixedTypes.h"
#include "hsPath.h"
#include "hsDescriptor.h"
#include "hsGMask.h"

struct hsGUnderline {
	hsScalar	fOffset;
	hsScalar	fThickness;		// set to 0 for "no underline"
};

class hsGGlyphStrike;
class hsGBitmap;
struct hsGColor;
class hsGAttribute;
struct hsGTextSpacing;

namespace AlphaMask {
	class RawDraw;
}

struct hsGGlyph {
	UInt16			fCharCode;
	UInt16			fGlyphID;		// or same as fCharCode if we're letting the scaler do it
	UInt16			fWidth;
	UInt16			fHeight;
	UInt32			fRowBytes;
	hsFixedPoint	fTopLeft;
	const void*		fImage;
	hsFixedPoint	fAdvance;
};

class hsGTextContext : public hsRefCnt {
	UInt8			fMaskType;
	UInt8			fTextEncoding;
	hsBool16		fDoPostDraw;
	UInt32			fGlyphCount;
	hsGGlyph*		fGlyphArray;
	hsFixedPoint*	fPosArray;
	UInt16*			fCodeArray;

	hsGGlyphStrike*	fStrike;
	hsScalar		fTextSize;
	
	hsGUnderline	fUnderline;
	UInt32			fFlags;
	hsFixedPoint	fAdvanceOffset;
	
	inline void		AllocGlyphArrays();
public:
					hsGTextContext(const hsGAttribute& attr,
								   hsConstDescriptor desc,
								   const hsFixedPoint& advOffset,
								   const hsGUnderline* underline=nil);
					~hsGTextContext();

	hsGMask::Type	GetMaskType() const { return (hsGMask::Type)fMaskType; }
	hsBool			DoPostDraw() const { return hsIntToBool(fDoPostDraw); }

	UInt32			GetWidths(UInt32 length, const void* text,
							  const hsGTextSpacing* spacing,
							  hsFixed width[], unsigned offsetToNextWidth);

	void			GetGlyph(UInt16 code, hsGGlyph* glyph);
	UInt32			SetText(UInt32 length, const void* text);
	hsGGlyph*		GetGlyphs();
	hsFixedPoint*	GetPositions(hsGGlyph** glyphPtr, const hsGTextSpacing* spacing);
	const void*		GetGlyphImage(hsGGlyph* glyph);
	const hsPath*	GetGlyphPath(const hsGGlyph& glyph);
	void			GetLineHeight(hsFixedPoint* ascent, hsFixedPoint* descent, hsFixedPoint* baseline);

//	void			GetSubPixelGlyph(hsGGlyph* glyph, hsFixed originX, hsFixed originY);
//	const void*		GetSubPixelGlyphImage(hsGGlyph* glyph, hsFixed originX, hsFixed originY);
	void			PurgeImageData();

	void			PostDraw(const AlphaMask::RawDraw& rd, hsFixed originX, hsFixed originY, hsFixed stopX, hsFixed stopY);
};

#endif
