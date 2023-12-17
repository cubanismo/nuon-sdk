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

#ifndef hsGSVGDevice_DEFINED
#define hsGSVGDevice_DEFINED

#include "hsGDevice.h"
#include "hsPrintf.h"

class hsGSVGDevice : public hsGDevice {
	hsGAttribute	fAttr;
	class hsXMLWriter*	fXML;
	class hsSVGXformStack*	fXformStack;
	int				fShaderCount;
	int				fOpenStyleGroup;

	void			CloseOpenStyleGroup();
	void			UpdateAttr(const hsGAttribute* attr, hsBool doText, hsBool forceFrame = false);

public:
					hsGSVGDevice();
	virtual			~hsGSVGDevice();

	void			StartPage(hsPrintf* pf);
	void			EndPage();

//	Overrides

	virtual void	Save();
	virtual void	SaveLayer(const hsRect* bounds, UInt32 flags, const hsGAttribute* attr = nil);
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
