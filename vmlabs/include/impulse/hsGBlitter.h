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

#ifndef hsGBlitter_DEFINED
#define hsGBlitter_DEFINED

#include "hsGBitmap.h"
#include "hsFixedTypes.h"
#include "hsMatrix33.h"
#include "hsGMask.h"
#include "hsRegion.h"

class hsGAttribute;
class hsGXferMode;

typedef UInt8	hsGAlphaByte;		// values 0 (transparent) -> 255 (opaque)

class hsGBlitter : public hsRefCnt {
public:
	virtual void	Blit(int y, int x, int count) = 0;
	virtual void	BlitTile(int y, int x, int width, int height);

	virtual hsGBitmap*	JustAnOpaqueColor(UInt32* colorPtr);
};

class hsGRasterBlitter : public hsGBlitter {
	hsGAlphaByte*	fAA;
									//	Odd		Even	Both
	int				fFieldSkip;		//	0		1		-1
	hsBool			fDoFields;		//	true	true	false
protected:
	hsGBitmap		fDevice;

	void			SetDevice(const hsGBitmap* device);

	inline hsBool	FieldRendering() const { return fDoFields; }
	inline hsBool	SkipThisField(int y) const
					{
						return (y & 1) == fFieldSkip;
					}
public:
					hsGRasterBlitter(const hsGBitmap* device);

	hsGAlphaByte*	GetAlpha() const { return fAA; }
	void			SetAlpha(hsGAlphaByte aa[]) { fAA = aa; }
	const hsGBitmap* PeekDevice() const { return &fDevice; }

	virtual void	BlitMask(const hsGMask* mask, const hsScanRegion* clip);
	virtual void	BlitLCDMask(const hsGMask* mask, const hsScanRegion* clip, int lcd);

	virtual hsBool	SetContext(const hsGBitmap* device, const hsGAttribute* attr, hsGMask::Type maskType);

//
//	These are static functions that create various blitters
//
	static hsGRasterBlitter*	ChooseMaskBlitter(const hsGBitmap* device, const hsGAttribute* attr, hsGMask::Type maskType);
	static hsGRasterBlitter*	ChooseBitmapBlitter(const hsGBitmap* device, hsBool doAntiAlias,
													const hsGBitmap* source,
													const hsGAttribute* attr,
													const hsMatrix* matrix);
};

class hsGSpriteBlitter : public hsGRasterBlitter {
protected:
	hsGBitmap	fSource;
	int			fOffsetX, fOffsetY;
	unsigned	fBlend256;
public:
				hsGSpriteBlitter(const hsGBitmap* device, const hsGBitmap* source, int x, int y, unsigned blend256);

	virtual hsBool	SetBitmap(const hsGBitmap* source, int x, int y);

	static hsGSpriteBlitter* ChooseBlitter(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
											const hsGColor* color, hsGXferMode* xferMode);
	static void	BlitSprite(	const hsGBitmap* device, const hsGBitmap* source,
							int x, int y,
							const hsGColor* color, hsGXferMode* xferMode = nil,
							const hsScanRegion* clip = nil, hsGSpriteBlitter* blitter = nil);
};

class hsGNullBlitter : public hsGRasterBlitter {
public:
	hsGNullBlitter(const hsGBitmap* device);

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class hsGRectClipBlitter : public hsGBlitter {
	hsGBlitter*		fBlitter;
	hsIntRect		fRect;
public:	
	hsGBlitter*		set(hsGBlitter* b, const hsIntRect& rect);
	
	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class hsGRgnClipBlitter : public hsGBlitter {
	hsGBlitter*					fBlitter;
	AlphaMask::Rgn::Spanerator	fSpan;
public:	
	hsGBlitter*			set(hsGBlitter* b, const AlphaMask::Rgn& rgn);
	
	virtual void		Blit(int y, int x, int count);
	virtual void		BlitTile(int y, int x, int width, int height);
};

#endif
