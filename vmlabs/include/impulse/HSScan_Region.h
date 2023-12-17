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

#ifndef hsScanRegion_DEFINED
#define hsScanRegion_DEFINED

#include "hsRegion.h"

/////////////////////////// Adaptor for hsScanRegion interface ////////////////////////

#include "hsGBlitter.h"
#include "hsTemplates.h"

class hsScanRegion {
	AlphaMask::Rgn	fRgn;
public:
	const AlphaMask::Rgn&	rgn() const { return fRgn; }

	enum Mode {
		kReplace_Mode,
		kIntersect_Mode
	};

				hsScanRegion() {}
				hsScanRegion(const hsScanRegion& src) : fRgn(src.fRgn) {}

	friend int		operator==(const hsScanRegion& a, const hsScanRegion& b) { return a.fRgn == b.fRgn; }
	friend int		operator!=(const hsScanRegion& a, const hsScanRegion& b) { return !(a == b); }
	hsScanRegion&	operator=(const hsScanRegion& src) { fRgn = src.fRgn; return *this; }

	hsBool		IsEmpty() const { return fRgn.isEmpty(); }
	hsBool		IsRect() const { return fRgn.isRect(); }
	hsBool		GetRect(hsIntRect* rect) const { return fRgn.getRect(*rect); }
	hsBool		GetRect(Int32* left, Int32* top, Int32* right, Int32* bottom) const
				{
					return fRgn.getRect(*left, *top, *right, *bottom);
				}

	void		SetEmpty() { fRgn.setEmpty(); }
//	void		SetFull();
	void		SetRect(Int32 left, Int32 top, Int32 right, Int32 bottom) { fRgn.setRect(left, top, right, bottom); }
	void		SetRect(const hsIntRect* rect) { fRgn.setRect(*rect); }

	void		SetRect(const hsRect* rect) { fRgn.setRect(*rect); }
	void		SetPath(const hsPath* path, hsScanRegion::Mode mode = hsScanRegion::kReplace_Mode)
				{
					fRgn.setPath(*path, mode == hsScanRegion::kReplace_Mode ? AlphaMask::Rgn::kReplace_Mode : AlphaMask::Rgn::kIntersect_Mode);
				}

//	void			SetRunTriples(UInt32 count, const Int16 runTriples[]);

	hsBool		Contains(int x, int y) const { return fRgn.contains(x, y); }
	hsBool		Contains(const hsIntRect* rect) const { return false; }
	hsBool		FastContains(const hsIntRect* rect) const
				{
					return fRgn.fastContains(*rect);
				}
	hsBool		ClipSpan(Int32 y, Int32* left, Int32* right) const { return fRgn.clipSpan(y, *left, *right); }

	hsBool		Intersect(const hsIntRect* rect) { return fRgn.sect(*rect) == true; }
	hsBool		Intersect(const hsScanRegion* rgn) { return fRgn.sect(rgn->fRgn) == true; }
	hsBool		Intersect(const hsScanRegion* rgn, const hsIntRect* rect) { return fRgn.sect(rgn->fRgn, *rect) == true; }
	hsBool		Intersect(const hsScanRegion* rgnA, const hsScanRegion* rgnB) { return fRgn.sect(rgnA->fRgn, rgnB->fRgn) == true; }
	
	hsScanRegion*	Union(const hsIntRect* rect) { fRgn.join(*rect); return this; }
	hsScanRegion*	Union(const hsScanRegion* rgn) { fRgn.join(rgn->fRgn); return this; }

	hsScanRegion*	Difference(const hsIntRect* rect) { fRgn.diff(*rect); return this; }
	hsScanRegion*	Difference(const hsScanRegion* rgn) { fRgn.diff(rgn->fRgn); return this; }
	hsScanRegion*	Difference(const hsScanRegion* rgnA, const hsScanRegion* rgnB) { fRgn.diff(rgnA->fRgn, rgnB->fRgn); return this; }

	hsScanRegion*	Offset(int dx, int dy, hsScanRegion* result = nil)
				{
					fRgn.offset(dx, dy, result ? &result->fRgn : nil);
					return this;
				}
};

class hsScanRegionIterator {
protected:
	const hsScanRegion*	fRgn;
public:
	hsScanRegionIterator(const hsScanRegion* rgn) : fRgn(rgn) {}

	void	Reset(const hsScanRegion* rgn) { fRgn = rgn; }
	hsBool	ClipSpan(Int32 y, Int32* left, Int32* right) { return fRgn->ClipSpan(y, left, right); }
};

class hsScanRegionWalker {
	AlphaMask::Rgn::Walker	fWalker;
public:
			hsScanRegionWalker(const hsScanRegion* rgn) : fWalker(rgn->rgn()) {}

	void	ResetToStart()	{ fWalker.resetToStart(); }
	hsBool	NextSpan()		{ return fWalker.nextSpan(fY, fLeft, fRight); }
	void	ResetToEnd()	{ fWalker.resetToEnd(); }
	hsBool	PrevSpan()		{ return fWalker.prevSpan(fY, fLeft, fRight); }
	
	Int32	fY, fLeft, fRight;
};

inline void hsScanRegion_RectBlit(const hsScanRegion* clip, const hsIntRect* rect, hsGBlitter* blitter)
{
	clip->rgn().rectBlit(*rect, *blitter);
}

inline void hsScanRegion_RectBlit(const hsScanRegion* clip, Int32 left, Int32 top, Int32 right, Int32 bottom, hsGBlitter* blitter)
{
	hsIntRect	rect = { left, top, right, bottom };
	
	hsScanRegion_RectBlit(clip, &rect, blitter);
}

#endif
