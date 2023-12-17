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

#ifndef hsGXferModeDefined
#define hsGXferModeDefined

#include "hsGColor.h"
#include "hsGBlitter.h"

class hsGShader;

/** hsGXferMode also is called per scanline, and is
responsible for compositing the source colors onto the device. */
class hsGXferMode : public hsRefCnt {
public:
	enum {
		kSrcIsOpaque		= 0x01,
		kSrcAlphaIsConst	= 0x02
	};

	virtual void	SetFlags(UInt32 flags);

	// The default implementation is to call the protected method
	// Override these for speed
	virtual void	ResolveColors8888(int count, const hsColor32 src[], hsColor32 dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors888(int count, const hsColor32 src[], hsRGBTriple dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors555(int count, const hsColor32 src[], UInt16 dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors8(int count, const hsColor32 src[], UInt8 dst[], hsGColorTable* ctable, const hsGAlphaByte antialias[]);
	virtual void	ResolveAlpha(int count, const UInt8 src[], UInt8 dst[], const hsGAlphaByte antialias[]);
	
	virtual hsGRasterBlitter* ChooseBlitter(const hsGBitmap*	device,
											hsGShader*			shader,
											const hsGColor*		color,
											hsGMask::Type		maskType);
};

//

/*
	dst = src
*/
class hsGOpaqueMode : public hsGXferMode {
public:
	virtual void	ResolveColors8888(int count, const hsColor32 src[], hsColor32 dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors888(int count, const hsColor32 src[], hsRGBTriple dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors555(int count, const hsColor32 src[], UInt16 dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors8(int count, const hsColor32 src[], UInt8 dst[], hsGColorTable* ctable, const hsGAlphaByte antialias[]);
	virtual void	ResolveAlpha(int count, const UInt8 src[], UInt8 dst[], const hsGAlphaByte antialias[]);
};

/*
	dst = src.alpha * src.color + (1 - src.alpha) * dst.color
*/
class hsGAlphaMode : public hsGXferMode {
public:
	virtual void	ResolveColors8888(int count, const hsColor32 src[], hsColor32 dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors888(int count, const hsColor32 src[], hsRGBTriple dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors555(int count, const hsColor32 src[], UInt16 dst[], const hsGAlphaByte antialias[]);
	virtual void	ResolveColors8(int count, const hsColor32 src[], UInt8 dst[], hsGColorTable* ctable, const hsGAlphaByte antialias[]);
	virtual void	ResolveAlpha(int count, const UInt8 src[], UInt8 dst[], const hsGAlphaByte antialias[]);
};

#endif
