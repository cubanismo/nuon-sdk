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

#ifndef hsGCurveTextEdit_Defined
#define hsGCurveTextEdit_Defined

#include "hsGTextEdit.h"
#include "hsTemplates.h"

struct hsGCharLoc {
	enum {
		kVisible	= 0x01
	};
	UInt8			fFlags;
	UInt8			fLength;	// either 1 (ascii) or 2 (unicode)
	UInt8			fText[2];	// treat as UInt16[1] if unicode
	hsGTEStyleRun*	fStyleRun;
	hsScalar			fAdvance;
	hsPoint2			fPosition;
	hsPoint2			fTangent;

	friend int	operator==(const hsGCharLoc& a, const hsGCharLoc& b)
	{
		return (a.fLength == b.fLength &&
				a.fText[0] == b.fText[0] &&
				a.fText[a.fLength - 1] == b.fText[a.fLength - 1] &&
				a.fStyleRun == b.fStyleRun &&
				a.fAdvance == b.fAdvance &&
				a.fPosition == b.fPosition &&
				a.fTangent == b.fTangent);
	}
};

class hsGCurveTextEdit : public hsGTextEdit {
	hsBool				fDirtyCharLocs;
	hsTArray<hsGCharLoc>	fCharLocs;

	void					BuildCharLocs();
protected:
	hsPath	fPath;
	hsScalar	fPathLengthOffset;

	virtual void	Dirty();	// override from baseclass

	const hsGCharLoc*	GetCharLocs(UInt32* recCount);
	hsBool			LocToOffset(hsScalar clickX, hsScalar clickY, UInt32* offset);
	hsBool			OffsetToLoc(UInt32 offset, UInt32 length, hsPoint2* loc, hsPoint2* advance,
								hsPoint2* ascent, hsPoint2* descent);

	friend class hsGCurveTEMouseTracker;
public:
				hsGCurveTextEdit(hsBool isUnicode = false);
	virtual		~hsGCurveTextEdit();

	void			GetPath(hsPath* path) const;
	virtual void	SetPath(const hsPath* path);

	hsScalar		GetPathLengthOffset() const { return fPathLengthOffset; }
	virtual void	SetPathLengthOffset(hsScalar offset);

	// High-level Methods

	virtual void	Draw(hsGDevice* device);
	virtual hsMouseTracker*	Mouse(Int32 x, Int32 y, hsModifierKeys modi, hsGDevice* device);
	virtual void	Action(UInt32 action, hsModifierKeys modi);

	// Selection Management

	virtual void	HiliteSelection(hsGDevice* device);

	// Stream Management

	virtual hsGTextEdit*	Copy();
	hsGCurveTextEdit*	CopyInto(hsGCurveTextEdit* dst);
	virtual void	Read(hsInputStream* stream);
	virtual void	Write(hsOutputStream* stream);
};

#endif
