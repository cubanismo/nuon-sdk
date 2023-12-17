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

#ifndef hsGScalerContextDefined
#define hsGScalerContextDefined

#include "hsGText.h"
#include "hsPath.h"
#include "hsGFontScaler.h"

class hsGPathEffect;
class hsGRasterizer;
class hsGMaskFilter;

class hsGScalerContext {
	class ScalerRawDraw*	fRD;
protected:
	hsGMask::Type	fMaskType;
	hsBool32		fDoesKerning;
	hsGScalerRecord	fScalerRecord;
	hsDescriptor	fStrokeDesc;
	hsGPathEffect*	fPathEffect;
	hsGRasterizer*	fRasterizer;
	hsGMaskFilter*	fMaskFilter;

	hsBool			RequestLCDMask() const;
	void			ConstructPath(const hsGGlyph* glyph, hsPath* resultPath);

	virtual void	GenerateMetrics(hsGGlyph* glyph) = 0;
	virtual void	GenerateImage(const hsGGlyph* glyph, void* buffer) = 0;
	virtual void	GeneratePath(const hsGGlyph* glyph, hsPath* path) = 0;
	virtual void	GenerateLineHeight(hsFixedPoint* ascent, hsFixedPoint* descent, hsFixedPoint* baseline) = 0;
	virtual void	GenerateKerning(UInt32 count, const UInt16 charCodes[], hsGGlyph glyphs[], hsFixedPoint positions[]);
public:
					hsGScalerContext(hsConstDescriptor desc);
	virtual			~hsGScalerContext();

	hsBool			DoesKerning() const { return hsIntToBool(fDoesKerning); }
	hsGMask::Type	GetMaskType() const;

	void			GetMetrics(hsGGlyph* glyph);
	void			GetImage(const hsGGlyph* glyph, void* buffer);
	void			GetPath(const hsGGlyph* glyph, hsPath* path);
	void			GetLineHeight(hsFixedPoint* ascent, hsFixedPoint* descent, hsFixedPoint* baseline);
	void			KernGlyphs(UInt32 count, const UInt16 charCodes[], hsGGlyph glyphs[], hsFixedPoint positions[]);
};

#endif
