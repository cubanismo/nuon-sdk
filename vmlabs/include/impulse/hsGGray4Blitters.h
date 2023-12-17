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

#ifndef hsGGray4Blitters_Defined
#define hsGGray4Blitters_Defined

#include "hsGBlitter.h"
#include "hsTemplates.h"
#include "hsGBitmap44Shader.h"

#if HS_IMPULSE_SUPPORT_GRAY4

class Solid_4_Opaque_Blitter : public hsGRasterBlitter {
	UInt32	fSrc32;
public:
	Solid_4_Opaque_Blitter(const hsGBitmap* device, const hsGColor* color);

	virtual hsGBitmap*	JustAnOpaqueColor(UInt32* colorPtr);
	virtual hsBool	SetContext(const hsGBitmap* device, const hsGAttribute* attr, hsBool doAntiAlias);
	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class Solid_4_Blend_Blitter : public hsGRasterBlitter {
	unsigned	fBlend256;
	unsigned	fSrc4;
public:
	Solid_4_Blend_Blitter(const hsGBitmap* device, const hsGColor* color);

	virtual hsBool	SetContext(const hsGBitmap* device, const hsGAttribute* attr, hsBool doAntiAlias);
	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

//

class Anti_4_Opaque_Blitter : public hsGRasterBlitter {
	unsigned	fSrc4;
public:
	Anti_4_Opaque_Blitter(const hsGBitmap* device, const hsGColor* color);
	
	virtual hsBool	SetContext(const hsGBitmap* device, const hsGAttribute* attr, hsBool doAntiAlias);
	virtual void	Blit(int y, int x, int count);
};

class Anti_4_Blend_Blitter : public hsGRasterBlitter {
	unsigned	fBlend256;
	unsigned	fSrc4;
public:
	Anti_4_Blend_Blitter(const hsGBitmap* device, const hsGColor* color);
	
	virtual hsBool	SetContext(const hsGBitmap* device, const hsGAttribute* attr, hsBool doAntiAlias);
	virtual void	Blit(int y, int x, int count);
};

//

class hsGGray4ShaderBlitter : public hsGRasterBlitter {
	enum {
		kMaxSrcColorCount	= 64
	};
	hsGCoreShader*	fShader;
	hsGXferMode*		fXferMode;
	hsGAlphaGray44	fSrc44[kMaxSrcColorCount];
public:
			hsGGray4ShaderBlitter(const hsGBitmap* device, hsBool doAntiAlias, const hsGColor* colorOrNil,
							hsGCoreShader* shaderOrNil, hsGXferMode* xferMode);
	virtual	~hsGGray4ShaderBlitter();
	
	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

//

class Ramp_D4_Blitter : public hsGRampBlitter {
	hsGXferMode*	fXferMode;
public:
				Ramp_D4_Blitter(const hsGBitmap* device, UInt32 triBlitFlags, hsGXferMode* xferMode);
	virtual		~Ramp_D4_Blitter();

	virtual void	Blit(int y, int x, int count);
};

//

#include "hsGShader.h"

class Bitmap_S4_D32_Blitter : public hsGRasterBlitter {
	hsGCoreShader*	fShader;
	hsGXferMode*		fXferMode;
public:
				Bitmap_S4_D32_Blitter(const hsGBitmap* device, const hsGBitmap* source,
									hsGAttribute* attr, const hsMatrix33* matrix);
	virtual		~Bitmap_S4_D32_Blitter();

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class Bitmap_D4_Blitter : public hsGRasterBlitter {
	hsGCoreShader*	fShader;
	hsGXferMode*		fXferMode;
public:
				Bitmap_D4_Blitter(const hsGBitmap* device, const hsGBitmap* source,
									hsGAttribute* attr, const hsMatrix33* matrix);
	virtual		~Bitmap_D4_Blitter();

	virtual void	Blit(int y, int x, int count);
};

class Sprite_S32_D4_Blitter : public hsGSpriteBlitter {
	hsGXferMode*	fXferMode;
	void			(*fShadeProc)(int count, const UInt32 src[], hsGAlphaGray44 dst[], unsigned blend256);
public:
				Sprite_S32_D4_Blitter(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
									unsigned blend256, hsGXferMode* xferMode);
	virtual		~Sprite_S32_D4_Blitter();

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class Sprite_S8_D4_Blitter : public hsGSpriteBlitter {
	hsGXferMode*			fXferMode;
	const hsGAlphaGray44*	(*fShadeProc)(int count, const UInt8 src[], hsGAlphaGray44 dst[],
									unsigned blend256, const hsGColorTable* ctable);
public:
				Sprite_S8_D4_Blitter(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
									unsigned blend256, hsGXferMode* xferMode);
	virtual		~Sprite_S8_D4_Blitter();

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class Sprite_S4_D32_Blitter : public hsGSpriteBlitter {
	hsColor32		fGray4ToColor32[16];
	void			(*fBlitProc)(int count, const hsGAlphaGray44 src[], UInt32 dst[], const hsColor32 gray2color[], unsigned blend256);
public:
				Sprite_S4_D32_Blitter(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
									unsigned blend256, const hsGColor* color);

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class Xor_D4_Opaque_Blitter : public hsGRasterBlitter {
protected:
	UInt32		fSrc32;
public:
				Xor_D4_Opaque_Blitter(const hsGBitmap* device, const hsGColor* color);

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

void hsGBitmap_Erase_PixelSize_4(const hsGBitmap* bm, const hsGColor* color);

#endif	// #if HS_IMPULSE_SUPPORT_GRAY4
#endif
