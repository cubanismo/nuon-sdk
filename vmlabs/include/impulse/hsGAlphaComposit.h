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

#ifndef hsGAlphaComposit_DEFINED
#define hsGAlphaComposit_DEFINED

#include "hsTypes.h"

/*
	The AlphaComposit routines assume that src and dst are pre-multiplied:
		i.e.  the color components are already scaled by the alpha value
*/

class hsGBitmap;
class hsGXferMode;

class hsGAlphaComposit {
public:
	enum Mode {
		kClear,		// Fs= 0		Fd= 0
		kSrc,		// Fs= 1		Fd= 0
		kSrcOver,	// Fs= 1		Fd= 1-As
		kDstOver,	// Fs= 1-Ad		Fd= 1
		kSrcIn,		// Fs= Ad		Fd= 0
		kDstIn,		// Fs= 0		Fd= As
		kSrcOut,	// Fs= 1-Ad		Fd= 0
		kDstOut		// Fs= 0		Fd= 1-As
	};

	static hsGXferMode*	ChooseXferMode(const hsGBitmap* device, Mode mode);
};

#endif
