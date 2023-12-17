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

#ifndef HS_ScanDefined
#define HS_ScanDefined

#include "hsTypes.h"
#include "HSScan_Region.h"
#include "hsGBlitter.h"
#include "hsMemory.h"
#include "hsPath.h"

class HSScan {
public:
	static void	FillRect(const hsIntRect* rect, const hsScanRegion* clip, hsGBlitter* blitter);
	static void	FillRect(const hsRect* rect, const hsScanRegion* clip, hsGBlitter* blitter, hsBool dropoutControl);
	static void	FillPath(const hsPath* path, const hsScanRegion* clip, hsGBlitter* blitter);
	static void	FillTriangle(const hsPoint vertex[], const hsScanRegion* clip, hsGBlitter* blitter);
	static void	FillQuad(const hsPoint quad[], const hsScanRegion* clip, hsGBlitter* blitter);

	static void	AntiFillPath(const hsPath* path, const hsScanRegion* clip, hsGRasterBlitter* blitter, hsGRasterBlitter* solidBlitter);
	static void	AntiFillQuad(const hsPoint quad[], const hsScanRegion* clip, hsGRasterBlitter* blitter);

	static void	HairLine(const hsPoint* start, const hsPoint* stop, const hsScanRegion* clip, hsGBlitter* blitter);
	static void	HairRect(const hsRect* rect, const hsScanRegion* clip, hsGBlitter* blitter);
	static void	HairPath(const hsPath* path, const hsScanRegion* clip, hsGBlitter* blitter);

	static void	FrameRect(const hsRect* rect, hsScalar thickX, hsScalar thickY, const hsScanRegion* clip, hsGBlitter* blitter);

	static void	PenLine(const hsPoint* start, const hsPoint* stop, const hsPoint* penSize,
							const hsScanRegion* clip, hsGBlitter* blitter);

	enum {
		kMiterJoin	= 0x00,	// default
		kRoundJoin	= 0x01,
		kBluntJoin	= 0x02,
		
		kBluntCap	= 0x00,	// default
		kRoundCap	= 0x04,
		kSquareCap	= 0x08
	};
	static void	Stroke(const hsPath* src, hsScalar radius, hsScalar miterScale, UInt32 strokeFlags, hsPath* dst);
};

class hsGMaskFilter;

/** HSScanHandler is an optional object that the raster device can
    reference. If the device references one, it is called with the
    device-space (transformed into device coordinates) primitive
    before it is drawn. If the handler returns {\tt true}, then
    drawing continues. If the handler returns {\tt false}, then
    nothing is drawn. This can be used to accumulate the bounds of
    objects being drawn, or to hide a cursor. */
class HSScanHandler : public hsRefCnt {
public:
	virtual hsBool 	HandleIntRect(const hsIntRect*, const hsScanRegion* clip);
	virtual hsBool 	HandleRect(const hsRect*, const hsMatrix* matrix, const hsScanRegion* clip, hsGMaskFilter* filter, hsBool hairline);
	virtual hsBool 	HandlePath(const hsPath*, const hsMatrix* matrix, const hsScanRegion* clip, hsGMaskFilter* filter, hsBool hairline);
};

#endif
