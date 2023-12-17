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

#ifndef hsGBitmap_DEFINED
#define hsGBitmap_DEFINED

#include "hsConfig.h"
#include "hsGColorTable.h"
#include "hsRect.h"

#ifdef HS_DEBUGGING
	#define ASSERT_PIXELSIZE(bitmap, pixelsize)		hsAssert((bitmap)->fPixelSize == (pixelsize), "pixelSize mismatch")
	#define ASSERT_XY(bitmap, x, y)					hsAssert(x < (bitmap)->fWidth && y < (bitmap)->fHeight, "bad XY")
#else
	#define ASSERT_PIXELSIZE(bitmap, pixelsize)
	#define ASSERT_XY(bitmap, x, y)
#endif

///	for UInt8 r, g, b in 24 bit bitmaps
typedef UInt8 hsRGBTriple;


class hsGColorTable;

/** A bitmap represents the structure and dimensions of a drawing
    primitive.

	A hsGBitmap does not own the memory for the pixels, but merely
	points to it.  It is the responsibility of the client to manage
	the pixel memory.

	Bitmaps are oriented top-to-bottom. Thus the first pixel pointed
	to by fImage corresponds to the top-left corner of the bitmap.  */
class hsGBitmap {
public:
	enum Config {
		kNoConfig,
		kRGB32Config,
		kARGB32Config,
		kRGB24Config,
		k555Config,
		kIndex8Config,
		kAlpha8Config,
		/// ignores fImage and fRowBytes
		kCustomConfig
	};
	enum {
		kOddFieldFlag		= 0x01,
		kEvenFieldFlag		= 0x02,
		kTranspIndexFlag	= 0x04
	};
	
#ifdef HS_BUILD_FOR_NUON
	void* fNuonRasterP;
#endif

	/// Points to the memory for the pixels.
	void*			fImage;
	/// Dimensions of the bitmap.
	UInt32			fWidth, fHeight;
	/// The number of bytes between subsequent rows of pixels.
	UInt32			fRowBytes;

					hsGBitmap(Config config = kNoConfig);
					hsGBitmap(const hsGBitmap& src);
					~hsGBitmap();

	void			operator=(const hsGBitmap& src);

	Config			GetConfig() const { return Config(fConfig); }
	void			SetConfig(Config config);

	UInt32			GetFlags() const { return fFlags; }
	void			SetFlags(UInt32 flags);
	
	hsGColorTable*	GetColorTable() const { return fCTable; }
	void			SetColorTable(hsGColorTable* ctable);

	UInt8			GetTranspIndex() const { return fTranspIndex; }
	void			SetTranspIndex(UInt8 index) { fTranspIndex = index; }

	int				GetPixelSize() const { return (int)fPixelSize; }

	//	Utility methods

	void			Erase(const hsGColor* color) const;
	void			Read(hsInputStream* stream);
	void			Write(hsOutputStream* stream) const;
	void			Scroll(	const hsIntRect* srcRect, int dx, int dy,
							const class hsScanRegion* clip,
							class hsScanRegion* dirty = nil) const;

	friend hsBool operator==(const hsGBitmap& a, const hsGBitmap& b);

	UInt32	ImageSize() const
			{
				return (UInt32)fHeight * (UInt32)fRowBytes;
			}

	//	These methods return the address of the pixel specified by x and y
	//	They are meant to be fast, therefore they are inlined and do not check
	//	the fPixelSize field at runtime (except when debugging)

	UInt8*	GetAddr8(unsigned x, unsigned y) const
			{
				ASSERT_PIXELSIZE(this, 8);
				ASSERT_XY(this, x, y);
				return (UInt8*)((char*)fImage + y * fRowBytes + x);
			}
	UInt16*	GetAddr16(unsigned x, unsigned y) const
			{
				ASSERT_PIXELSIZE(this, 16);
				ASSERT_XY(this, x, y);
				return (UInt16*)((char*)fImage + y * fRowBytes + (x << 1));
			}
	hsRGBTriple* GetAddr24(unsigned x, unsigned y) const
			{
				ASSERT_PIXELSIZE(this, 24);
				ASSERT_XY(this, x, y);
				return (hsRGBTriple*)((char*)fImage + y * fRowBytes + (x << 1) + x);
			}
	UInt32*	GetAddr32(unsigned x, unsigned y) const
			{
				ASSERT_PIXELSIZE(this, 32);
				ASSERT_XY(this, x, y);
				return (UInt32*)((char*)fImage + y * fRowBytes + (x << 2));
			}
	hsColor32* GetCddr32(unsigned x, unsigned y) const
			{
				return (hsColor32*)this->GetAddr32(x, y);
			}

#ifdef HS_BUILD_FOR_MAC
	hsBool	UsePixMap(struct PixMap** pm);	// returns true if the pixels were successfully locked
#endif

private:
	UInt8			fFlags;
	UInt8			fConfig;
	UInt8			fPixelSize;
	UInt8			fTranspIndex;	// only in (kIndex8Config && kTranspIndexFlag)
	hsGColorTable*	fCTable;
};


// Defines for hsRGBTriple in 24-bit

#if HS_CPU_BENDIAN
	#define kRTriple	0
	#define kGTriple	1
	#define kBTriple	2
#else
	#define kRTriple	2
	#define kGTriple	1
	#define kBTriple	0
#endif

inline void SetRGBTriple(hsRGBTriple rgb[], UInt8 r, UInt8 g, UInt8 b)
{
	rgb[kRTriple] = r;
	rgb[kGTriple] = g;
	rgb[kBTriple] = b;
}

#define kMinCountFor24QuadCopy	32

inline void hsRGBTripleFill(hsRGBTriple image[], int r, int g, int b, int count)
{
	if (count > kMinCountFor24QuadCopy)
	{
		//	slow copy until we're long aligned
		//
		while (UInt32(image) & 3)
		{	SetRGBTriple(image, r, g, b);
			image += 3;
			count -= 1;
		}

		UInt32	quadR = (r << 24) | (g << 16) | (b << 8) | r;
		UInt32	quadG = (quadR << 8) | g;
		UInt32	quadB = (quadG << 8) | b;

		int	quadCount = count >> 2;
		for (int i = 0; i < quadCount; i++)
		{	((UInt32*)image)[kRTriple] = quadR;
			((UInt32*)image)[kGTriple] = quadG;
			((UInt32*)image)[kBTriple] = quadB;
			image += 12;
		}
		count &= 3;
	}
	for (int i = 0; i < count; i++)
	{	SetRGBTriple(image, r, g, b);
		image += 3;
	}
}

#endif
