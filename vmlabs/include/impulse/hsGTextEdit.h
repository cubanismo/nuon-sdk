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

#ifndef hsGTextEditDefined
#define hsGTextEditDefined

#include "hsGDevice.h"
#include "hsGAttribute.h"
#include "hsMouseTracker.h"

////////////////////////////////////////////////////////////////////////////////////////////

class hsGTEHighlighter : public hsRefCnt {
public:
	virtual void	HighlightLine(hsGDevice* device, const hsPoint2 endPoints[2]) = 0;
	virtual void	HighlightRect(hsGDevice* device, const hsRect* rect) = 0;
	virtual void	HighlightPath(hsGDevice* device, const hsPath* path) = 0;

	virtual void	Read(hsInputStream* stream);
	virtual void	Write(hsOutputStream* stream);
	virtual UInt32	GetStreamSize();
};

class hsGTEStyleRun {
public:
	virtual		~hsGTEStyleRun() {}

	virtual hsGAttribute*	RefAttribute() = 0;
	virtual hsGTEStyleRun*	Copy() const = 0;
	virtual hsBool			EqualTo(const hsGTEStyleRun* run) const = 0;

	virtual void	GetRunSpacing(hsFixedPoint2* ascent, hsFixedPoint2* descent);
	virtual void	Write(hsOutputStream* stream);
	virtual UInt32	GetStreamSize();
};

class hsGTextEdit {
public:
	struct LineSpace {		// spacing = MAX( fMin, fScale * height + fAdd )
		hsScalar	fMin;
		hsScalar	fScale;
		hsScalar	fAdd;
		
		void		Reset();	// fMin = 0, fScale = hsScalar1, fAdd = 0
	};
private:
	UInt32			fFlags;
	int				fBytesPerChar;
	hsScalar			fAlignment;
	LineSpace			fLineSpacing;
	hsRect			fFrame, fMargin;
	hsGTEStyleRun*	fDefaultStyleRun;
	hsGTEHighlighter*	fHighlighter;
	class hsGTEData*	fData;

	void			ReadVersion2(hsInputStream* stream);

	virtual hsGTEStyleRun* NewStyleRun(hsInputStream* stream);	// override for subclasses
	friend class hsGTERunList;
protected:
	virtual void	Dirty();	// call this whenever something changes that affects the line-breaks or display
	virtual void	AdjustLine(UInt32 index, hsScalar* ascent, hsScalar* descent);
	virtual void	DrawRun(int length, const void* text, const hsPoint2* loc,
							hsGTEStyleRun* styleRun, hsGDevice* device, hsBool lastLine);
	friend class hsGTELineMgr;
public:
	enum {
		kNo_Action,
		kLeftArrow_Action,
		kRightArrow_Action,
		kUpArrow_Action,
		kDownArrow_Action,
		kDelete_Action
	};
	enum {
		kReturn_CharCode	= 13
	};
	enum {
		kNoFrameClip_Flag	= 0x0001
	};
		
				hsGTextEdit(hsBool isUnicode = false);
	virtual		~hsGTextEdit();

	int			BytesPerChar() const { return fBytesPerChar; }

	UInt32		GetFlags() const { return fFlags; }
	virtual void	SetFlags(UInt32 flags);

	hsScalar		GetAlignment() const { return fAlignment; }
	virtual void	SetAlignment(hsScalar alignment);

	//	Line spacing routines
	LineSpace*	GetSpacing(LineSpace* spacing) const;
	virtual void	SetSpacing(const LineSpace* spacing);

	// Frame specifies the valid click-space for mouse events (and clipping?)
	hsRect*		GetFrame(hsRect* frame) const;
	virtual void	SetFrame(const hsRect* frame);

	// Margin specifies the rect the text will fit into. Usually frame > margin
	hsRect*		GetMargin(hsRect* margin) const;
	virtual void	SetMargin(const hsRect* margin);

	// Highlighter object is responsible for drawing the selection area
	hsGTEHighlighter*	GetHighlighter() const { return fHighlighter; }
	virtual void		SetHighlighter(hsGTEHighlighter* hiliter);

	// The default stylerun is used when there is no explicit stylerun specified by SetStyleRun()
	hsGTEStyleRun* GetDefaultStyleRun() const { return fDefaultStyleRun; }
	virtual void	SetDefaultStyleRun(const hsGTEStyleRun* run);

	// High-level Methods

	virtual void	Draw(hsGDevice* device);
	virtual hsMouseTracker*	Mouse(Int32 x, Int32 y, hsModifierKeys modi, hsGDevice* device);
	virtual void	Action(UInt32 action, hsModifierKeys modi);
	virtual void	CharCode(UInt16 charCode, hsModifierKeys modi);
#if HS_BUILD_FOR_MAC
	virtual void	Key(UInt16 charCode, hsModifierKeys modi);
#endif
#if HS_BUILD_FOR_WIN32
	virtual hsBool	WinKeyDown(UInt32 nChar, UInt32 nFlags);
#endif
	// Text Management

	virtual UInt32	TextLength() const;		// returns bytes, not necessarily characters
	virtual UInt32	CopyText(UInt32 offset, UInt32 length, void* text) const;	// return actual length
	virtual void	InsertText(UInt32 offset, UInt32 length, const void* text);
	virtual UInt32	DeleteText(UInt32 offset, UInt32 length);					// return actual length

	//	The CopyText_ methods treat both offset and length as byte-counts in the space of TextEdit
	UInt32		CopyText_ToAscii(UInt32 offset, UInt32 length, UInt8 text[]) const;
	UInt32		CopyText_ToUnicode(UInt32 offset, UInt32 length, UInt16 text[]) const;
	//	The InsertText_ methods treat offset as a byte-offset in the space of TextEdit
	//	but treat length as referring to the size of their respective text[] parameter
	void			InsertText_FromAscii(UInt32 offset, UInt32 length, const UInt8 text[]);
	void			InsertText_FromUnicode(UInt32 offset, UInt32 length, const UInt16 text[]);

	//	These routines respect both the limits of the current text size and the state of BytesPerChar()
	UInt32		PrevOffset(UInt32 offset) const;
	UInt32		NextOffset(UInt32 offset) const;

	// TextRun Management

	virtual hsGTEStyleRun* GetStyleRun(UInt32 offset, UInt32 length, UInt32* runOffset, UInt32* runLength) const;
	virtual UInt32	SetStyleRun(UInt32 offset, UInt32 length, const hsGTEStyleRun* run, hsBool compactRuns = true);	// return actual run length
	virtual void	StyleRunChanged(hsGTEStyleRun* run);							// call if you changed the data in the stylerun

	// Selection Management
	
	virtual UInt32	GetSelection(UInt32* offset) const;						// return length
	virtual UInt32	GetSelection(UInt32* startOffset, UInt32* stopOffset) const;	// return length
	void			SetSelection(UInt32 offset) { (void)this->SetSelection(offset, offset); }
	virtual UInt32	SetSelection(UInt32 startOffset, UInt32 stopOffset);			// return actual length
	virtual void	HiliteSelection(hsGDevice* device);

	// Stream Management

	virtual hsGTextEdit*	Copy();
	hsGTextEdit*	CopyInto(hsGTextEdit* dst);
	virtual void	Read(hsInputStream* stream);
	virtual void	Write(hsOutputStream* stream);

	// Query routines for lines

	virtual UInt32	CountLines();
	virtual UInt32	GetLine(UInt32 index, UInt32* offset, hsPoint2* origin, hsScalar* width);
	virtual UInt32	OffsetToLine(UInt32 offset, hsBool lineEndBias);
	virtual UInt32	SelectionToLine(UInt32* lineCount);
	
	hsBool		GetLineSpacing(UInt32 index, LineSpace* spacing, hsBool* concat) const;
	virtual void	SetLineSpacing(UInt32 index, const LineSpace* spacing, hsBool concat);
	virtual void	ClearLineSpacing();

	//	Override this to change the word-select behavior

	virtual void	GetWordBounds(UInt32 offset, UInt32* wordStart, UInt32* wordStop);
};

#endif

