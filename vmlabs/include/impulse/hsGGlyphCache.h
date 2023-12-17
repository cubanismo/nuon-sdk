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

#ifndef hsGGlyphCache_DEFINED
#define hsGGlyphCache_DEFINED

#include "hsGText.h"
#include "hsDescriptor.h"
#include "hsGScalerContext.h"
#include "hsMemory.h"

class hsGGlyphStrike : public hsRefCnt {
	hsGGlyphStrike		*fNext, *fPrev;
	friend class hsGGlyphCache;

	enum {
		kSentinelCharCode	= 0xFFFF	// marks the fCharCode field to indicate empty record
	};
private:
	hsBool16			fNeedToPurge;
	hsBool16			fCacheIs16Bit;
	//	This holds all of the image data pointed to by fEntries
	hsChunkAllocator	fImageData;
	//	This holds the hsGGlyph data
	union {
		hsGGlyph*		f8Bit;	//	fCacheIs16Bit == 0, f8Bit[256]
		class hsG16BitLookup*	f16Bit;	//	fCacheIs16Bit == 1
	} fCache;
	class hsGPathCache* fPathCache;

private:
	hsGScalerContext*	fScalerContext;	// created by the scaler
	void				LoadScaler();

	// cached from the scaler context
	hsFixedPoint		fAscent, fDescent, fBaseline;
protected:
	hsDescriptor		fDesc;
	hsBool8				fDoesKerning;
	UInt8				fMaskType;
	UInt8				fTextEncoding;
	UInt8				fPad;
public:
						hsGGlyphStrike(hsConstDescriptor desc);
	virtual				~hsGGlyphStrike();

	hsConstDescriptor	GetDesc() const { return fDesc; }
	hsBool				DoesKerning() const { return hsIntToBool(fDoesKerning); }
	hsGMask::Type		GetMaskType() const { return (hsGMask::Type)fMaskType; }
	UInt8				GetTextEncoding() const { return fTextEncoding; }	// hsGStyle::TextEncoding
	UInt32				GlyphImageSize(const hsGGlyph* glyph) const;
	const void*			GetImage(hsGGlyph* glyph);
	const hsPath*		GetPath(const hsGGlyph* glyph);
	void				GetLineHeight(hsFixedPoint* ascent, hsFixedPoint* descent, hsFixedPoint* baseline);
	void				KernGlyphs(UInt32 count, const UInt16 charCodes[], hsGGlyph glyphs[], hsFixedPoint positions[]);
	hsGScalerContext*	GetScalerContext() const { return fScalerContext; }

	hsGGlyph* Get8BitMetrics(UInt8 charCode)
	{
		hsAssert(fCacheIs16Bit == 0, "Cache is not 8bit");

		hsGGlyph* entry = &fCache.f8Bit[charCode];
		this->Assure8BitEntry(entry, charCode);
		return entry;
	}
	hsGGlyph* Get16BitMetrics(UInt16 charCode);

	hsGGlyph* GetMetrics(UInt16 charCode)
	{
		if (fCacheIs16Bit == 0)
			return this->Get8BitMetrics(UInt8(charCode));
		else
			return this->Get16BitMetrics(charCode);
	}
	void	GetMetrics(UInt32 count, const UInt16 charCodes[], hsGGlyph glyphs[]);

	hsGGlyph* Get256Metrics()
	{
		hsAssert(fCacheIs16Bit == 0, "Cache is not 8bit");
		return &fCache.f8Bit[0];
	}
	void Assure8BitEntry(hsGGlyph* entry, UInt16 charCode)
	{
		if (entry->fCharCode != charCode)
		{	entry->fCharCode = charCode;
			hsDebugCode(entry->fGlyphID = 0xFEED;)
			entry->fImage = nil;
			fScalerContext->GetMetrics(entry);
		}
	}
	
	void			PurgeImageData();

	//	Override from hsRefCnt to check fNeedToPurge

	virtual void	UnRef();


	// Call this to find a strike. Call strike->UnRef() when you are through with it
	//
	static hsGGlyphStrike*	RefStrike(hsConstDescriptor desc);

	// Call this to clean-up
	static void		KillGlyphCache();
};
#define NUON 1
#ifdef NUON
//rwb
void SetMaxGlyphCacheSize( int size );
int GetMaxGlyphCacheSize( );
#endif
#endif
