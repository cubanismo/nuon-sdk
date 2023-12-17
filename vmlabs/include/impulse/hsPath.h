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

#ifndef hsPath_DEFINED
#define hsPath_DEFINED

#include "hsMemory.h"
#include "hsMatrix33.h"

class hsInputStream;
class hsOutputStream;
class hsTransformer;

/** A sequence of line and curve segment specifying a complex geometry.

	Paths are opaque objects, used to store geometry more complex than
	just a rectangle. Paths can contain multiple contours, and each
	contour can be made up of any number of line and curve
	segments. The curve segments in a path are cubic beziers.

	Paths can be used as a drawing primitive, and they can also (along
	with instances of hsRect) be used as a clip.

	An hsPath is created by making method calls to add lines and curves:

	\code
	void   MoveTo(const hsPoint& pt);
	void   LineTo(const hsPoint& pt);
	void   CurveTo(const hsPoint& pt0, const hsPoint& p1,
				   const hsPoint& p2);
	void   Close();  // close the current contour
	\endcode

	\sa hsRect
	\sa hsPathIterator
*/
class hsPath {
	hsTArray<hsPoint>	fPts;
	hsTArray<char>		fFlags;
	hsPoint				fMoveTo;
	UInt32				fContourCount;
	UInt32				fPathFlags;
	
	friend class hsPathIterator;
public:
	enum Verb {
		kDone_PathVerb,
		kMoveTo_PathVerb,
		kLineTo_PathVerb,
		kQuadTo_PathVerb,
		kCurveTo_PathVerb,
		kClose_PathVerb
	};
			hsPath();
			hsPath(UInt32 pathFlags);
			hsPath(const hsPath& src);
			~hsPath();

			/** Clear the path.
				
				There are no methods for deleting segments within a
				path. However, you can clear the entire path using
				::Reset(). */
	void	Reset();
	hsBool	IsEmpty() const;
	
	/** @name Fill Rule

		Paths can be drawn using either the even-odd (EO) rule, or the
		winding rule. This is specified in the path with the
		kEOFill_PathFlag. Paths default to winding fill (flags \f$=
		0\f$). */
	//@{
	enum {
		kEOFill_PathFlag = 0x01
	};
	UInt32	GetFlags() const { return fPathFlags; }
	void	SetFlags(UInt32 flags);
	//@}

	void	MoveTo(const hsPoint& pt);
	void	MoveTo(hsScalar x, hsScalar y);
	void	LineTo(const hsPoint& pt);
	void	LineTo(hsScalar x, hsScalar y);
	void	PolyTo(int count, const hsPoint pts[]);
	void	QuadTo(const hsPoint& pt0, const hsPoint& p1);
	void	QuadTo(hsScalar x0, hsScalar y0, hsScalar x1, hsScalar y1);
	void	CurveTo(const hsPoint& pt0, const hsPoint& p1, const hsPoint& p2);
	void	CurveTo(hsScalar x0, hsScalar y0, hsScalar x1, hsScalar y1, hsScalar x2, hsScalar y2);
	void	Close();
	hsBool	GetFirstPt(hsPoint* firstPt) const;	//!< return false if empty path
	hsBool	GetLastPt(hsPoint* lastPt) const;	//!< return false if empty path

	void	PathTo(const hsPath* contour);
	void	ReversePathTo(const hsPath* contour);

	hsPath&	operator=(const hsPath& src);

	/** Paths can return their bounds (as a rectangle), and be transformed by
		a matrix. */
	void	GetBounds(hsRect* bounds, hsBool exact) const;
	hsBool	IsRect(hsRect* rect) const;
	void	Transform(const hsMatrix* matrix, const hsPath* src = nil);
	void	Transform(const hsTransformer& xf, const hsPath* src = nil);
	void	Translate(hsScalar dx, hsScalar dy, const hsPath* src = nil);
	/// Turns lines into cubics, and subdivides each cubic \a level times
	void	Subdivide(int level);
	/** Breaks lines and paths such that they're at most \a length
        long, but not subdividing more than 2^\a level times. */
	void	Subdivide(hsScalar length, int level);

	friend int	operator==(const hsPath& a, const hsPath& b);
	friend int	operator!=(const hsPath& a, const hsPath& b) { return !(a == b); }

	//	Utility methods

	void	Read(hsInputStream* stream);
	void	Write(hsOutputStream* stream) const;

	UInt32	CountSegments(hsBool forceClosed) const;
	hsBool	IsEOFill() const { return (fPathFlags & kEOFill_PathFlag) != 0; }
	hsBool	IsWindingFill() const { return (fPathFlags & kEOFill_PathFlag) == 0; }
	
	/** @name Adding common shapes
		
		Helper methods for adding common shapes as contours. */
	//@{
	void	RLineTo(hsScalar dx, hsScalar dy);
	void	AddRect(const hsRect* rect, hsBool reverse = false);
	void	AddOval(const hsRect* oval, hsBool reverse = false);
	void	AddPoly(int count, const hsPoint pts[], hsBool close);
	void	AddPath(const hsPath* src);
	void	AddCircle(hsScalar centerX, hsScalar centerY, hsScalar radius);
	void	AddRRect(const hsRect* rect, hsScalar ovalWidth, hsScalar ovalHeight);
	void	AddArc(const hsRect* rect, hsScalar startAngle, hsScalar sweepAngle, hsBool wedge);
	void	AddQuadratic(int count, const hsPoint points[], const UInt8 onCurve[], hsBool closed);
	//@}
};

/** Iterator over path elements.
	
	Since paths are opaque, Impulse provides an iterator for
    retrieving the data inside.

	The ::Next() method is called in a loop, until it returns
	\c kDone_PathVerb. The interpretation of the \a pts[] parameter
	depends on the return value.

	<TABLE>
	<TR><TD><B>Verb returned from Next()</B><TD><B>Pts[]</B> assigned
	<TR><TD>\c kDone_PathVerb		<TD>none
	<TR><TD>\c kMoveTo_PathVerb		<TD>pts[0]
	<TR><TD>\c kLineTo_PathVerb		<TD>pts[0..1]
	<TR><TD>\c kCurveTo_PathVerb	<TD>pts[0..3]
	<TR><TD>\c kClose_PathVerb		<TD>none
	</TABLE>
	
	Example:

	\code
	hsPathIterator iter(&path);
	hsPath::Verb   verb;
	hsPoint        pts[4];
	
	while ((verb = iter.Next(pts)) != hsPath::kDone_PathVerb)
	{
	    switch (verb) {
	    case hsPath::kMoveTo_PathVerb:
    	    // pts[0] begins a new contour
        	break;
	    case hsPath::kLineTo_PathVerb:
    	    // pts[0..1] are a line segment
        	break;
	    case hsPath::kCurveTo_PathVerb:
    	    // pts[0..3] are a bezier segment
        	break;
		case hsPath::kClose_PathVerb:
	        // marks the current contour closed
    	    break;
    	}
	}
	\endcode
	*/
class hsPathIterator {
public:
			hsPathIterator();
			hsPathIterator(const hsPath* path, hsBool forceClosed = false);

	void	operator=(const hsPathIterator& src);

	void			Reset(const hsPath* path, hsBool forceClosed = false);
	hsPath::Verb	Next(hsPoint pts[4] = nil);
	hsBool			NextContour(hsPath* contour);
	hsBool			IsClosed();
	hsBool			IsDone();

private:
	const hsPath*	fPath;
	const hsPoint*	fPIter;
	const char*		fFIter, *fFIterStop;
	hsPoint			fFirstPt, fLastPt;
	hsBool			fForceClosed;
	hsPath::Verb	fLastVerb;
	
	hsBool	CloseContour(hsPoint pts[4], hsBool closeVerb);
};

class hsTransformer {
 public:
	virtual void	MapPoints(UInt32 count, const hsPoint src[], hsPoint dst[]) const = 0;
};

#endif
