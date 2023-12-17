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

#ifndef hsGPostScriptDevice_DEFINED
#define hsGPostScriptDevice_DEFINED

#include "hsGDevice.h"
#include "RawPostScript.h"

/** The hsGPostScriptDevice, like hsGStreamDevice, captures all
    drawing commands into (in this case) a file. However, this device
    converts these commands into their PostScript equivalents. It
    ignores those Impulse features that have no corresponding feature
    in PostScript: hsGRasterizer, hsGMaskFilter, hsGShader,
    hsGXferMode. In addition, it does not offer any font-downloading
    services. It is up to the client to insure that any fonts needed
    will be available on the printer. */
class hsGPostScriptDevice : public hsGDevice {
	hsGAttribute		fAttr;
	RawPostScript		fRP;
	hsTArray<hsGFontID>	fDownloadedFonts;
	UInt32				fForceUpdateFlags;

	void			UpdateAttr(const hsGAttribute* attr, hsBool doText);

protected:
	virtual void	PS_SetFont(	hsGFontID fontID, hsScalar textSize,
								const hsGTextFace* face, hsBool doDownload);

public:
					hsGPostScriptDevice();
	virtual			~hsGPostScriptDevice();

	///
	virtual void	SetPaperSize(int width, int height);
	///
	virtual void	SetPageBounds(const hsIntRect* page);

	///
	virtual void	StartPage(hsPrintf* pf, hsBool doFlip);
	///
	virtual void	EndPage(hsBool doShowPage);

	virtual void	ResetDownloadedFonts();
	
	hsPrintf*		GetPrintf() const;
	virtual void	SetPrintf(hsPrintf* pf);

//	Overrides

	virtual void	Save();
	virtual void	Restore();
	virtual void	Concat(const hsMatrix* matrix);
	virtual void	ClipPath(const hsPath* clip, hsBool applyCTM = true);

	virtual void	DrawFull(const hsGAttribute* a);
	virtual void	DrawLine(const hsPoint* start, const hsPoint* stop, const hsGAttribute* a);
	virtual void	DrawRect(const hsRect* r, const hsGAttribute* a);
	virtual void	DrawPath(const hsPath* p, const hsGAttribute* a);
	virtual void	DrawBitmap(const hsGBitmap* b, hsScalar x, hsScalar y, const hsGAttribute* a);
	virtual void	DrawParamText(UInt32 length, const void* text, hsScalar x, hsScalar y,
								  const hsGAttribute* a);
	virtual void	DrawPosText(UInt32 length, const void* text,
								const hsPoint pos[], const hsVector tan[],
								const hsGAttribute* a);
};

#endif
