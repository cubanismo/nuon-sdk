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

#ifndef hsGMask_DEFINED
#define hsGMask_DEFINED

#include "hsRect.h"

struct hsGMask {
	enum Type {
		kBW_MaskType,
		kAlpha_MaskType,
		kA3D_MaskType,
		kLCD_MaskType
	};
	hsIntRect	fBounds;
	UInt8*		fImage;
	UInt16		fRowBytes;
	UInt16		fMaskType;
	
	hsGMask::Type GetMaskType() const { return (hsGMask::Type)fMaskType; }
	UInt32		GetImageSize() const;
	void		GetBitmap(class hsGBitmap* bm) const;
};

class hsTempMask : public hsGMask {
public:
	hsTempMask() { fImage = nil; }
	~hsTempMask() { delete[] fImage; }
	
	void	Allocate()
	{
		hsAssert(fImage == nil, "allocating over existing image");
		fImage = new UInt8[this->GetImageSize()];
	}
};

#endif
