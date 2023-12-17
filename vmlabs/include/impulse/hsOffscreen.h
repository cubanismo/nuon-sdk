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

#ifndef hsOffscreen_DEFINED
#define hsOffscreen_DEFINED

#include "hsRect.h"

#if !(HS_BUILD_FOR_PALM)

class hsGBitmap;

#if HS_BUILD_FOR_WIN32
	#define WIN32_EXTRA_LEAN
	#define WIN32_LEAN_AND_MEAN
	#include <windows.h>
#elif HS_BUILD_FOR_MAC
	#include <Quickdraw.h>
#elif HS_BUILD_FOR_UNIX
	#include <X11/Xlib.h>
#endif

#if HS_BUILD_FOR_WIN32
	// This is a mirror of the GDI struct
	typedef struct hstagBITMAPINFO {
	    BITMAPINFOHEADER    bmiHeader;
	    RGBQUAD             bmiColors[256];
	} HSBITMAPINFO;
#endif

class hsOffscreen {
protected:
	void*		fPixels;
	int			fPixelsLockCount;
	UInt32		fRowBytes;
	unsigned	fPixelSize;
	hsBool		fDoGray;

#if HS_BUILD_FOR_MAC
	CGrafPtr	fWorld;		// GWorldPtr
	PixMap**	fPixMap;		// PixMapHandle
	UInt32		fFlags;		// GWorldFlags
#elif HS_BUILD_FOR_WIN32
	HSBITMAPINFO fHeader;
	HDC			fMemDC;
	HBITMAP		fBitmap;
	HGLRC		fRC;
#elif HS_BUILD_FOR_BE
	class BBitmap*	fBBitmap;
#elif HS_BUILD_FOR_UNIX
	XImage*		fXImage;
#elif HS_BUILD_FOR_REFERENCE
	hsIntRect	fBounds;
 #endif

public:
				hsOffscreen();
	virtual		~hsOffscreen();

	void		Reset(void);
	void		UseRect(const hsIntRect* bounds, unsigned pixelSize, hsBool doGray);
	void*		LockPixels(void);
	void		UnlockPixels(void);	
	void		GetBitmap(hsGBitmap* bitmap);
	unsigned 	GetDimensions(Int32* width, Int32* height, Int32* rowBytes);
	void		CompactRowBytes();
	void		SetAlphaByte(Byte alpha);

#if HS_BUILD_FOR_MAC
	void		CopyBits(const hsIntRect* src, const hsIntRect* dst, GrafPtr port = nil, hsBool doDither = true);

	UInt32		GetGWorldFlags() { return fFlags; }
	void		SetGWorldFlags(UInt32 flags);	// GWorldFlags
	void		UsePICT(Picture** pic, int depth, hsBool doGray);		// PicHandle
	void		UsePICT(short rsrcID, int depth, hsBool doGray);
	void		SetOffscreenPort(void);
	PixMap**	GetPixMap(void);
	CGrafPtr	GetPort() const { return fWorld; } 
#endif

#if HS_BUILD_FOR_WIN32
	HDC			GetHDC() const { return fMemDC; }
	void		CopyBits(const hsIntRect* src, const hsIntRect* dst, HDC hdc=NULL, hsBool doDither = true);
#endif

#if HS_BUILD_FOR_BE
	void		CopyBits(const hsIntRect* src, const hsIntRect* dst, class BView* view, hsBool doDither = true);
#endif

#if HS_BUILD_FOR_UNIX_AND_X
	void		CopyBits(const hsIntRect* src, const hsIntRect* dst, Window wind, hsBool doDither = false);
#endif
};

#endif
#endif
