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

#ifndef hsGBitmapShader_DEFINED
#define hsGBitmapShader_DEFINED

#include "hsGShader.h"

///
class hsGBitmapShader : public hsGShader {
protected:
	hsGBitmap		fBitmap;
	TileMode		fTileMode;
	hsBool16		fDeviceCoords;
	hsBool16		fWeOwnThePixels;
	class hsGBitmapCoreShader*	fShadeWorker;

	virtual void ChooseShaderWorker(const hsGAttribute* attr, const hsMatrix* matrix);
public:
					hsGBitmapShader();
					hsGBitmapShader(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);
	virtual			~hsGBitmapShader();

	//	Overridden from hsGCoreShader
	virtual void	SetContext(const hsGBitmap* device, const hsGAttribute* attr, const hsMatrix* matrix);
	virtual hsBool	IsOpaque();
	virtual void	ShadeSpan(int y, int x, int count, hsColor32 src[]);
#if HS_IMPULSE_SUPPORT_GRAY4
	virtual void	ShadeGray4(int y, int x, int count, hsGAlphaGray44 src[]);
#endif

	//	Overridden from hsGShader
	virtual CreateProc	GetCreateProc();
	virtual const char*	GetName();
	virtual void		Write(hsOutputStream* stream, UInt32 flags = 0);

	//	These are just for hsGBitmapShader, to be called by the Client
	///
	void			SetTileMode(TileMode repeat) { fTileMode = repeat; }
	///
	void			SetDeviceCoords(hsBool b) { fDeviceCoords = (hsBool16)b; }
	
	//	If shaderOwnsPixels == true, then they must be allocated with HSMemory::New()
//	virtual void	SetTexture(const char name[]);
	///
	virtual void	SetBitmap(const hsGBitmap* bitmap, hsBool shaderOwnsPixels = false);

	static void	RegisterTexture(const char name[], const hsGBitmap* bitmap, hsBool registryOwnsPixels = false);
	static hsBool	FindTexture(const char name[], hsGBitmap* bitmap, hsBool* registryOwnsPixels = nil);
	static hsBool	UnregisterTexture(const char name[]);
	static void	UnregisterAllTextures();
	
	static const char*	ClassName();
};

#endif
