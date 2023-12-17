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

#ifndef hsGColorTable_DEFINED
#define hsGColorTable_DEFINED

#include "hsGColor.h"
#include "hsRefCnt.h"

/** Instances map pixel indices to color values.

	The color-table class is a descendent of hsRefCnt, and is used with
	kIndex8Config to map 8-bit indices (the pixel values) to colors.

	NOTE: Impulse treats 32-bit pixels with alpha as \emph{premultiplied}
	colors. This means that within each pixel, the RGB components are
	stored already scaled by their alpha component. This applies to
	bitmaps that are drawn as primitives, as well as the result of Impulse
	drawing into a bitmap.

	\begin{tabular}{|l|l|}\hline
	\textbf{Color}	&\textbf{32-bit format [ARGB]}\\\hline
	Black			&[0xFF 0 0 0]\\
	White			&[0xFF 0xFF 0xFF 0xFF]\\
	Red				&[0xFF 0xFF 0 0]\\
	50% Translucent Red	&[0x80 0x80 0 0]\\
	Transparent	&[0 0 0 0]\\
	\hline
	\end{tabular}
	
	A rule of thumb for premultiplied colors: all color components must be
	$\leq$ the alpha component.  */
class hsGColorTableCache {
	UInt8	fCIndex[4096];		// 4 4 4
	
	friend class hsGColorTable;
	hsGColorTableCache(int count, const hsColor32 colors[]);
	hsGColorTableCache(const UInt8 cindex[]);
	hsGColorTableCache() {}
public:

	UInt8 ColorToIndex(int r, int g, int b) const
	{
#if !HS_BUILD_FOR_NUON
		hsAssert(unsigned(r) <= 255 && unsigned(g) <= 255 && unsigned(b) <= 255, "oops");
#endif
		return fCIndex[ ((r & 0xF0) << 4) | (g & 0xF0) | (b >> 4) ];
	}

	UInt8 ColorToIndex(UInt32 c) const
	{
		return fCIndex[ ((c >> 12) & 0xF00) | ((c >> 8) & 0xF0) | ((c >> 4) & 0xF) ];
	}
	
	//	For hashing into the cache directly
	//	The hash is rrrrggggbbbb (444)
	
	static unsigned RGB2Hash(int r, int g, int b)
	{
		return ((r & 0xF0) << 4) | (g & 0xF0) | (b >> 4);
	}

	static unsigned Color2Hash(UInt32 c)
	{
		return ((c >> 12) & 0xF00) | ((c >> 8) & 0xF0) | ((c >> 4) & 0xF);
	}

	UInt8 HashToIndex(unsigned hash) const
	{
		hsAssert(hash < 4096, "bad hash");
		return fCIndex[hash];
	}
};

#if 0
class hsGColorTableBlend {
	UInt16	fBColor[4096];
public:
			hsGColorTableBlend(int count, const hsColor32 colors[]);

	UInt16	AlphaIndexTo444(unsigned alpha, unsigned index) const
	{
		hsAssert(index <= 255, "bad index");

		return fBColor[PrepareAlpha(alpha) | index];
	}

	const UInt16* PeekBTable() const { return fBColor; }

	static unsigned PrepareAlpha(unsigned alpha)
	{
		hsAssert(alpha <= 255, "bad alpha");
		
		return alpha >> 4 << 8;
	}
};
#endif

class hsGColorTable : public hsRefCnt {
	unsigned	fFlags;
	unsigned	fCount;
	hsColor32*	fColors;

	hsGColorTableCache*	fCache;
//	hsGColorTableBlend*	fBlend;

	void			operator=(const hsGColorTable&);	// leave unimplemented

	inline void		DirtyCache();
	void			UpdateCache();
public:
					hsGColorTable();
					hsGColorTable(const UInt8 cindex[]);	// the inverse-table
	virtual			~hsGColorTable();

	const hsColor32* PeekColors() const { return fColors; }
	const UInt32*	 Peek32() const { return (const UInt32*)fColors; }

	const hsColor32& IndexToColor(unsigned i) const
					{
						hsAssert(i < fCount, "bad IndexToColor param");
						return fColors[i];
					}
	
	const hsColor32& operator[](unsigned i) const
					{
						hsAssert(i < fCount, "bad IndexToColor param");
						return fColors[i];
					}

	UInt8			ColorToIndex(int red, int green, int blue)
					{
						if (fCache == nil) this->UpdateCache();
						return fCache->ColorToIndex(red, green, blue);
					}
	UInt8			ColorToIndex(UInt32 color32)
					{
						if (fCache == nil) this->UpdateCache();
						return fCache->ColorToIndex(color32);
					}
	UInt8			ColorToIndex(const struct hsGColor* color)
					{
						if (fCache == nil) this->UpdateCache();
						return fCache->ColorToIndex(color->fR >> 8,
													color->fG >> 8,
													color->fB >> 8);
					}
	UInt8			ColorToIndex(const hsColor32* color)
					{
						if (fCache == nil) this->UpdateCache();
						return fCache->ColorToIndex(color->r, color->g, color->b);
					}

	hsGColorTableCache* GetCache();	// never returns nil
//	hsGColorTableBlend* GetBlend();	// may return nil

	unsigned			GetCount() const { return fCount; }
	//	All of the Set___ routines may invalidate the lookup cache
	void				SetCount(unsigned count);
	void				SetColors(unsigned index, unsigned count, const hsColor32 colors[]);
	void				SetDefaultColorTable();
	void				Set332ColorTable();
#if HS_BUILD_FOR_MAC
	void				SetMacColors(const struct ColorTable** ctHandle);
#elif HS_BUILD_FOR_UNIX
	void				SetXColors();
#endif

	friend int operator==(const hsGColorTable& a, const hsGColorTable& b);
};

class hsGDither {
	hsGColorTable*		fCTable;
	hsGColorTableCache*	fCache;
	int					fRGB[3];
public:
			hsGDither();
			~hsGDither();

	void	SetColorTable(hsGColorTable* ctable);
	int		ColorToIndex(int r, int g, int b);
};

#endif
