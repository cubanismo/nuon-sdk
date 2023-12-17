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

#ifndef hsGExtruderizer_DEFINED
#define hsGExtruderizer_DEFINED

#include "hsGRasterizer.h"
#include "hsGColor.h"

class hsGExtruderizer : public hsGRasterizer {
	hsPoint2		fOffset;
	hsGColorValue	fFaceAlpha, fSideAlpha;
public:
					hsGExtruderizer(hsScalar dx, hsScalar dy,
									hsGColorValue faceAlpha,
									hsGColorValue sideAlpha,
									hsScalar stdSize);
					hsGExtruderizer(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);

	void			GetExtrude(hsPoint2* offset,
								hsGColorValue* faceA, hsGColorValue* sideA) const;
	void			SetExtrude(hsScalar dx, hsScalar dy,
								hsGColorValue faceA, hsGColorValue sideA);

	virtual void	GetBounds(const hsPath* path, const hsMatrix33* matrix,
								hsIntRect* bounds);
	virtual void	Rasterize(const hsPath* path, const hsMatrix33* matrix,
								const hsScanRegion* clip, hsGMask* mask);

	//	For font cache
	//
	virtual CreateProc	GetCreateProc();

	//	For writing to a stream
	//
	virtual const char* GetName();
	virtual void	Write(hsOutputStream* stream, UInt32 flags = 0);

	//	For reanimating
	//
	static const char*	ClassName();
};

#endif
