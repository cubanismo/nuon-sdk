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

#ifndef hsGSpriteBlittersDefined
#define hsGSpriteBlittersDefined

#include "hsGBlitter.h"

// Src = 8 common base class for XferModes

class SpriteBlit_Xfer_S8_Base : public hsGSpriteBlitter {
protected:
	enum {
		kBufferSize = 32
	};
	hsGXferMode*	fMode;
	hsColor32		fSrc32[kBufferSize];
public:
			SpriteBlit_Xfer_S8_Base(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
								unsigned blend256, hsGXferMode* mode);
	virtual	~SpriteBlit_Xfer_S8_Base();
};

//

#if HS_IMPULSE_SUPPORT_DEVICE32

class SpriteBlit_Blend_Alpha_D32 : public hsGSpriteBlitter {
public:
				SpriteBlit_Blend_Alpha_D32(const hsGBitmap* device, const hsGBitmap* source, int x, int y, unsigned blend256)
					: hsGSpriteBlitter(device, source, x, y, blend256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Blend_D32 : public hsGSpriteBlitter {
public:
				SpriteBlit_Blend_D32(const hsGBitmap* device, const hsGBitmap* source, int x, int y, unsigned blend256)
					: hsGSpriteBlitter(device, source, x, y, blend256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Alpha_D32 : public hsGSpriteBlitter {
public:
				SpriteBlit_Alpha_D32(const hsGBitmap* device, const hsGBitmap* source, int x, int y)
					: hsGSpriteBlitter(device, source, x, y, 256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_D32 : public hsGSpriteBlitter {
public:
				SpriteBlit_D32(const hsGBitmap* device, const hsGBitmap* source, int x, int y)
					: hsGSpriteBlitter(device, source, x, y, 256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Xfer_S8_D32 : public SpriteBlit_Xfer_S8_Base {
public:
				SpriteBlit_Xfer_S8_D32(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
									unsigned blend256, hsGXferMode* mode)
					: SpriteBlit_Xfer_S8_Base(device, source, x, y, blend256, mode) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Blend_S8_D32 : public hsGSpriteBlitter {
public:
				SpriteBlit_Blend_S8_D32(const hsGBitmap* device, const hsGBitmap* source, int x, int y, unsigned blend256)
					: hsGSpriteBlitter(device, source, x, y, blend256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_S8_D32 : public hsGSpriteBlitter {
public:
				SpriteBlit_S8_D32(const hsGBitmap* device, const hsGBitmap* source, int x, int y)
					: hsGSpriteBlitter(device, source, x, y, 256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};
#endif

#if HS_IMPULSE_SUPPORT_DEVICE24
	hsGRasterBlitter* hsGSpriteBlitter_ChooseBlitter24(	const hsGBitmap* device,
														const hsGBitmap* source,
														int x, int y,
														const hsGColor* color,
														hsGXferMode* xferMode);
#endif

#if HS_IMPULSE_SUPPORT_DEVICE16

class SpriteBlit_Blend_Alpha_D16 : public hsGSpriteBlitter {
public:
				SpriteBlit_Blend_Alpha_D16(const hsGBitmap* device, const hsGBitmap* source, int x, int y, unsigned blend256)
					: hsGSpriteBlitter(device, source, x, y, blend256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Blend_D16 : public hsGSpriteBlitter {
public:
				SpriteBlit_Blend_D16(const hsGBitmap* device, const hsGBitmap* source, int x, int y, unsigned blend256)
					: hsGSpriteBlitter(device, source, x, y, blend256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Alpha_D16 : public hsGSpriteBlitter {
public:
				SpriteBlit_Alpha_D16(const hsGBitmap* device, const hsGBitmap* source, int x, int y)
					: hsGSpriteBlitter(device, source, x, y, 256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_D16 : public hsGSpriteBlitter {
public:
				SpriteBlit_D16(const hsGBitmap* device, const hsGBitmap* source, int x, int y)
					: hsGSpriteBlitter(device, source, x, y, 256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Xfer_S8_D16 : public SpriteBlit_Xfer_S8_Base {
public:
				SpriteBlit_Xfer_S8_D16(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
									unsigned blend256, hsGXferMode* mode)
					: SpriteBlit_Xfer_S8_Base(device, source, x, y, blend256, mode) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Blend_S8_D16 : public hsGSpriteBlitter {
public:
				SpriteBlit_Blend_S8_D16(const hsGBitmap* device, const hsGBitmap* source, int x, int y, unsigned blend256)
					: hsGSpriteBlitter(device, source, x, y, blend256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_S8_D16 : public hsGSpriteBlitter {
public:
				SpriteBlit_S8_D16(const hsGBitmap* device, const hsGBitmap* source, int x, int y)
					: hsGSpriteBlitter(device, source, x, y, 256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};
#endif

class Sprite_S32_XferMode_Blitter : public hsGSpriteBlitter {
	hsGXferMode*		fXferMode;
	const hsColor32*	(*fShadeProc)(int count, const hsColor32 src[], hsColor32 dst[], unsigned blend256);
public:
			Sprite_S32_XferMode_Blitter(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
									unsigned blend256, hsGXferMode* xferMode);
	virtual	~Sprite_S32_XferMode_Blitter();
	
	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

#if HS_IMPULSE_SUPPORT_DEVICE8

class SpriteBlit_Xfer_S8_D8 : public SpriteBlit_Xfer_S8_Base {
public:
				SpriteBlit_Xfer_S8_D8(const hsGBitmap* device, const hsGBitmap* source, int x, int y,
									unsigned blend256, hsGXferMode* mode)
					: SpriteBlit_Xfer_S8_Base(device, source, x, y, blend256, mode) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_Blend_S8_D8 : public hsGSpriteBlitter {
public:
				SpriteBlit_Blend_S8_D8(const hsGBitmap* device, const hsGBitmap* source, int x, int y, unsigned blend256)
					: hsGSpriteBlitter(device, source, x, y, blend256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_S8_D8 : public hsGSpriteBlitter {
public:
				SpriteBlit_S8_D8(const hsGBitmap* device, const hsGBitmap* source, int x, int y)
					: hsGSpriteBlitter(device, source, x, y, 256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};

class SpriteBlit_S8_D8_EqCTable : public hsGSpriteBlitter {
public:
				SpriteBlit_S8_D8_EqCTable(const hsGBitmap* device, const hsGBitmap* source, int x, int y)
					: hsGSpriteBlitter(device, source, x, y, 256) {}

	virtual void	Blit(int y, int x, int count);
	virtual void	BlitTile(int y, int x, int width, int height);
};
#endif

#endif
