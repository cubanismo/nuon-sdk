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

#ifndef hsGCursorHandler_DEFINED
#define hsGCursorHandler_DEFINED

#include "hsGBitmap.h"

class hsGCursorHandler : public hsRefCnt {
public:
					hsGCursorHandler(const hsGBitmap* pixels);
	virtual			~hsGCursorHandler();

	void			GetCursorLoc(hsIntPoint* loc) const;
	void			SetCursorLoc(const hsIntPoint* loc);
	void			SetCursorLoc(int x, int y);
	void			SetCursorImage(const hsGBitmap* image, int hotX, int hotY);
	hsBool			IsCursorVisible() const;
	hsIntRect*		GetCursorBounds(hsIntRect* bounds) const;

	void			ShowCursor();
	void			HideCursor();
	void			MoveCursor(int dx, int dy);

private:
	hsIntPoint		fCursorLoc, fCursorHotSpot;
	hsGBitmap		fCursorImage, fBackgroundImage, fPixels;
	hsGColor		fCursorColor;
	int				fCursorShowCount;

	class hsGSpriteBlitter*	fBG2DevBlitter;
	class hsGSpriteBlitter*	fDev2BGBlitter;
	class hsGSpriteBlitter*	fCurs2DevBlitter;
	
	void			RemoveCursor();
	void			RestoreCursor();
	void			ChooseNewBlitters();

	friend class hsGTmpCursorHandler;
};

#endif
