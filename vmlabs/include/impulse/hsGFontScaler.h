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

#ifndef hsGFontScalerDefined
#define hsGFontScalerDefined

#include "hsDescriptor.h"
#include "hsMatrix33.h"
#include "hsGFont.h"

#define kScalerProc_FontScalerDesc		hsFourByteTag('S', 'c', 'l', 'r')		// void* proc
#define kRecord_FontScalerDesc			hsFourByteTag('T', 'R', 'e', 'c')		// hsGScalerRecord
#define kPathEffect_FontScalerDesc		hsFourByteTag('P', 'E', 'f', 'f')		// void* proc + data[]
#define kRasterizer_FontScalerDesc		hsFourByteTag('R', 'a', 's', 't')		// void* proc + data[]
#define kMaskFilter_FontScalerDesc		hsFourByteTag('M', 's', 'k', 'F')		// void* proc + data[]

struct hsGScalerRecord {
	hsGFontID	fFontID;
	hsScalar	fTextSize;
	hsMatrix	fMatrix;
	UInt16		fAttrFlags;
	UInt16		fTextEncoding;
	hsScalar	fBoldness;

	//	if (fFlags & hsGAttribute::kFrame)
	UInt32		fOutlineStrokeFlags;
	hsScalar	fOutlineMiterLimit;
	hsScalar	fOutlineThickness;
};

class hsGScalerContext;

class hsGFontScaler {
	//	This guy is OS-specific
	//
	static hsGScalerContext* CreateContext(hsConstDescriptor desc);
public:
	typedef hsGScalerContext* (*CreateContextProc)(hsConstDescriptor desc);
	
	static CreateContextProc FindContextProc(hsGFontID fontID);
};


#endif
