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

#ifndef hsGTextEditUtilsDefined
#define hsGTextEditUtilsDefined

#include "hsGTextEdit.h"
#include "hsGXferMode.h"

class hsGTEStyleRunIterator {
	const hsGTextEdit*	fTE;
	UInt32		fSelectionOffset, fSelectionLength;
	hsBool		fDone;
public:
				hsGTEStyleRunIterator(const hsGTextEdit* te)
				{
					this->Reset(te);
				}
				hsGTEStyleRunIterator(const hsGTextEdit* te, UInt32 offset, UInt32 length)
				{
					this->Reset(te, offset, length);
				}

	void			Reset(const hsGTextEdit* te);	// uses selection for offset/length
	void			Reset(const hsGTextEdit* te, UInt32 offset, UInt32 length);

	hsGTEStyleRun* NextRun(UInt32* runOffset, UInt32* runLength);
};

////////////////////////////////////////////////////////////////////////////////

class hsGTEXorHighlighter : public hsGTEHighlighter {
protected:
	class hsGXorAttribute*	fAttr;
public:
				hsGTEXorHighlighter();
	virtual		~hsGTEXorHighlighter();

	virtual void	HighlightLine(hsGDevice* device, const hsPoint2 points[2]);
	virtual void	HighlightRect(hsGDevice* device, const hsRect* rect);
	virtual void	HighlightPath(hsGDevice* device, const hsPath* path);
};

class hsGTESolidHighlighter : public hsGTEHighlighter {
protected:
	hsGAttribute	fFillAttr, fFrameAttr;
public:
				hsGTESolidHighlighter();

	virtual void	HighlightLine(hsGDevice* device, const hsPoint2 points[2]);
	virtual void	HighlightRect(hsGDevice* device, const hsRect* rect);
	virtual void	HighlightPath(hsGDevice* device, const hsPath* path);
};

////////////////////////////////////////////////////////////////////////////////

class hsGTEStyleAttrRun : public hsGTEStyleRun {
public:
	hsGAttribute			fAttribute;

	hsGTEStyleAttrRun&		operator=(const hsGTEStyleAttrRun& src);

	virtual hsGAttribute*	RefAttribute();
	virtual hsGTEStyleRun*	Copy() const;
	virtual hsBool			EqualTo(const hsGTEStyleRun* run) const;

	virtual void			Read(hsInputStream* stream);
	virtual void			Write(hsOutputStream* stream);

	// Static sample functions for editing the selection

	static void	SetFontID(hsGTextEdit* te, hsGFontID fontID);
	static void	SetTextSize(hsGTextEdit* te, hsScalar textSize);
	static void	SetColor(hsGTextEdit* te, const hsGColor* color);
	static void	SetShader(hsGTextEdit* te, hsGShader* shader);
	static void	SetXferMode(hsGTextEdit* te, hsGXferMode* mode);
};

#endif
