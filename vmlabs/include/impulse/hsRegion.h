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

#ifndef AlphaMask_Rgn_DEFINED
#define AlphaMask_Rgn_DEFINED

#include "hsRect.h"

#ifdef HS_DEBUGGING
	#define MEMBER_INLINE
#else
	#define MEMBER_INLINE	inline
#endif

class hsPath;
class hsGBlitter;

namespace AlphaMask {

class Rgn {
public:
	enum Mode {
		kReplace_Mode,
		kIntersect_Mode
	};
	typedef Int16 RunType;

				Rgn();
				Rgn(const hsIntRect& bounds);
				Rgn(const Rgn& src);
				~Rgn() throw();

	bool		equal(const Rgn& rgn) const;
	Rgn&		operator=(const Rgn& src);
	friend bool operator==(const Rgn& a, const Rgn& b) { return a.equal(b); }
	friend bool	operator!=(const Rgn& a, const Rgn& b) { return !(a == b); }
	operator	bool() const { return !this->isEmpty(); }

	bool		isEmpty() const { return count_ == kEmptyRegionCount; }
	bool		isRect() const { return count_ <= kRectRegionCount; }
	bool		getRect(hsIntRect& rect) const
				{
					rect = bounds_;
					return count_ <= kRectRegionCount;
				}
	bool		getRect(Int32& left, Int32& top, Int32& right, Int32& bottom) const
				{
					left	= bounds_.fLeft;
					top		= bounds_.fTop;
					right	= bounds_.fRight;
					bottom	= bounds_.fBottom;
					return count_ <= kRectRegionCount;
				}
	const hsIntRect& getBounds() const { return bounds_; }

	Rgn&		setEmpty() throw();
	Rgn&		setRect(const hsIntRect& rect) throw();
	Rgn&		setRect(Int32 left, Int32 top, Int32 right, Int32 bottom) throw();
	Rgn&		setRect(const hsRect& rect) throw();
	Rgn&		setPath(const hsPath& path, Rgn::Mode mode = Rgn::kReplace_Mode);

	Rgn&		sect(const hsIntRect& rect) { return this->sect(*this, rect); }
	Rgn&		sect(const Rgn& rgn) { return this->sect(*this, rgn); }
	Rgn&		sect(const hsIntRect& rectA, const hsIntRect& rectB);
	Rgn&		sect(const Rgn& rgn, const hsIntRect& rect);
	Rgn&		sect(const Rgn& rgnA, const Rgn& rgnB);
	
	Rgn&		join(const hsIntRect& rect) { return this->join(*this, rect); }
	Rgn&		join(const Rgn& rgn) { return this->join(*this, rgn); }
	Rgn&		join(const hsIntRect& rectA, const hsIntRect& rectB);
	Rgn&		join(const Rgn& rgn, const hsIntRect& rect);
	Rgn&		join(const Rgn& rgnA, const Rgn& rgnB);

	Rgn&		diff(const hsIntRect& rect) { return this->diff(*this, rect); }
	Rgn&		diff(const Rgn& rgn) { return this->diff(*this, rgn); }
				// rgnA - rgnB
	Rgn&		diff(const hsIntRect& rectA, const hsIntRect& rectB);
	Rgn&		diff(const Rgn& rgn, const hsIntRect& rect);
	Rgn&		diff(const hsIntRect& rect, const Rgn& rgn);
	Rgn&		diff(const Rgn& rgnA, const Rgn& rgnB);

	Rgn&		exor(const hsIntRect& rect) { return this->exor(*this, rect); }
	Rgn&		exor(const Rgn& rgn) { return this->exor(*this, rgn); }
	Rgn&		exor(const hsIntRect& rectA, const hsIntRect& rectB);
	Rgn&		exor(const Rgn& rgn, const hsIntRect& rect);
	Rgn&		exor(const Rgn& rgnA, const Rgn& rgnB);

	Rgn&		offset(Int32 dx, Int32 dy, Rgn* result = nil);

	bool		contains(Int32 x, Int32 y) const;
	bool		contains(const hsIntRect& rect) const;
	bool		fastContains(const hsIntRect& rect) const
				{
					return count_ == kRectRegionCount && bounds_.Contains(&rect);
				}

	bool		clipSpan(Int32 y, Int32& left, Int32& right) const;
	void		rectBlit(const hsIntRect& rect, hsGBlitter& blitter) const;

	class Iterator {
		bool			done_;
		const RunType*	runs_;
		hsIntRect		rect_;
	public:
		Iterator(const Rgn& rgn);
		
		bool				done() const { return done_; }
		const hsIntRect&	rect() const { return rect_; }
		void				next();
	};

	class Recterator {
		Iterator	iter_;
		hsIntRect	clip_;

		hsIntRect	rect_;
		bool		done_;
	public:
		Recterator(const Rgn& rgn, const hsIntRect& clip);
		
		bool				done() const { return done_; }
		const hsIntRect&	rect() const { return rect_; }
		void				next();
	};

	class Spanerator {
		const Rgn*		fRgn;
		const RunType*	fHead, *fTail;

		MEMBER_INLINE bool	findSpan(Int32 y);
	public:
					Spanerator(const Rgn* rgn = nil) { this->reset(rgn); }

		void		reset(const Rgn* rgn);
		bool		clipSpan(Int32 y, Int32& left, Int32& right);
		inline void	blitSpan(int y, int x, int count, hsGBlitter* blitter);
#ifdef HS_DEBUGGING
		void		validate(const Rgn& rgn);
#endif
	};

	class Walker {
		const Rgn&	fRgn;
		const RunType*	fHead, *fTail, *fCurr;
		RunType		fCurrBot;
		bool		fDone;
	public:
				Walker(const Rgn& rgn);

		void	resetToStart();
		bool	nextSpan(Int32& y, Int32& left, Int32& right);
		void	resetToEnd();
		bool	prevSpan(Int32& y, Int32& left, Int32& right);
	};

private:
	enum {
		kEmptyRegionCount	= -1,
		kRectRegionCount	= 0
	};
	hsIntRect	bounds_;
	Int32		count_;
	RunType*	runs_;
	mutable Spanerator*	spanerator_;

				Rgn(Int32 count, const RunType runs[], const hsIntRect* bounds = nil);
	Rgn&		setRuns(Int32 count, const RunType runs[], const hsIntRect* bounds = nil);
	void		swap(Rgn& other) throw();
	
#ifdef HS_DEBUGGING
	void validate() const;
#else
	inline void validate() const {}
#endif

	class Operator {
		RunType*	result_;
		int			min_, max_;
	public:
		 Operator(int min, int max) : result_(nil), min_(min), max_(max) {}
		 ~Operator();

		RunType* operator()(const Rgn& rgnA, const Rgn& rgnB, Int32& outCount);
	};

	friend class Operator;
	friend class Iterator;
	friend class Spanerator;
	friend class Walker;
};

}	// namespace

#endif
