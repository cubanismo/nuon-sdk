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

#ifndef RawPostScript_DEFINED
#define RawPostScript_DEFINED

#include "hsPath.h"
#include "hsGBitmap.h"
#include "hsGAttribute.h"
#include "hsPrintf.h"

class RawPostScript {
public:
				RawPostScript();
				~RawPostScript();

	void		GetPaperSize(int* width, int* height);
	void		SetPaperSize(int width, int height);
	void		GetPageBounds(hsIntRect* page);
	void		SetPageBounds(const hsIntRect* page);

	void		StartPage(hsPrintf* pf, hsBool doFlip);
	void		EndPage(hsBool doShowPage);

	void		Draw_Line(const hsPoint* start, const hsPoint* stop);
	void		Draw_Rect(const hsRect* rect, hsBool doStroke);
	void		Draw_Path(const hsPath* path, hsBool doStroke);
	void		Draw_Bitmap(const hsGBitmap* bitmap, hsScalar x, hsScalar y);
	void		Draw_Text(UInt32 length, const void* text, hsScalar x, hsScalar y,
						  const hsGAttribute* attr);
	void		Draw_PosText(UInt32 length, const void* text, const hsPoint pos[],
							 const hsVector tan[], const hsGAttribute* attr);

	//	Low-level routines to write data to the postscript stream

	void		Dump_Raw(const char string[]);
	void		Dump_Color(const hsGColor* color);
	void		Dump_StrokeWidth(hsScalar width);
	void		Dump_MiterLimit(hsScalar miterLimit);
	void		Dump_CapType(hsGAttribute::CapType capType);
	void		Dump_JoinType(hsGAttribute::JoinType joinType);
	void		Dump_Font(hsGFontID fontID, hsScalar textSize, const hsGTextFace* face);
	void		Dump_Matrix(const hsMatrix* matrix);
	void		Dump_Clip(const hsPath* clip);
	void		Dump_Rect(const hsRect* r, const char cmd[]);
	void		Dump_Path(const hsPath* path, const char cmd[]);

	hsPrintf*	GetPrintf() const { return fPF; }
	void		SetPrintf(hsPrintf* pf) { fPF = pf; }

private:
	// Internal fields set by user
	hsPrintf*	fPF;
	hsIntPoint	fPaperSize;
	hsIntRect	fPageBounds;
	hsBool		fDoFlip;
};

#endif

