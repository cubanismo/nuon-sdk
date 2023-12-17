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

#ifndef hsGClipRegionDefined
#define hsGClipRegionDefined

#include "HSScan_Region.h"

class hsGDevice;
class hsGView;

class hsGClipRegion {
private:
	hsGView*		fLastView;	// the last view passed to GetTotalClip
	hsGSeedValue	fClipSeed;		// the clipseed at the time fTotalRgn was built
	hsGSeedValue	fMatrixSeed;	// the matrixseed at the time fTotalRgn was built
	hsGDevice*	fLastDevice;	// the last device passed to GetTotalClip
	hsGSeedValue	fDeviceSeed;	// the deviceseed at the time fTotalRgn was built
	hsMatrix33	fLastMatrix;	// the last matrix passed to GetTotalClip
	hsMatrixType	fLastMatrixType;

	hsScanRegion	fTotalRgn;		// this holds the cached answer
protected:
	virtual void	RegionizeSelf(const hsMatrix33* matrix, hsScanRegion* dst) = 0;
public:
				hsGClipRegion();
	virtual		~hsGClipRegion();

	const hsScanRegion*	GetTotalClip(hsGView* view, hsGDevice* device, const hsMatrix33* matrix = nil);
};

//

class hsGRectClipRegion : public hsGClipRegion {
	hsBool32		fFull;
	hsRect		fBounds;
protected:
	void			CopyInto(hsGRectClipRegion* dst) const;
	// hsGClipRegion::RegionizeSelf
	virtual void	RegionizeSelf(const hsMatrix33* matrix, hsScanRegion* dst);
public:
				hsGRectClipRegion();

	hsBool		IsFull() const { return (hsBool)fFull; }
	void			GetBounds(hsRect* bounds) const;
	hsBool		SetBounds(const hsRect* bounds);	// return true if changed
	hsBool		SetBounds(hsScalar left, hsScalar top, hsScalar right, hsScalar bottom);
};

//

class hsGGeoClipRegion : public hsGClipRegion {
	enum ClipType {
		kFull, kPath
	};
	hsPath	fPath;
	ClipType	fType;
protected:
	// hsGClipRegion::RegionizeSelf
	virtual void	RegionizeSelf(const hsMatrix33* matrix, hsScanRegion* dst);
public:
				hsGGeoClipRegion();
	virtual		~hsGGeoClipRegion();

	hsBool		GetClip(hsPath* path);

	void			SetFull();
	void			SetRect(const hsRect* rect);
	void			SetPath(const hsPath* path);

	void			CopyInto(hsGGeoClipRegion* dst) const;
};

/*@
@page hsgclipregion.html
@class hsGClipRegion
The clip region classes are typically used
by hsGView objects to manage the manipulation of hsScanRegions which determine the pixels which
will actuall be drawn.
@method GetTotalClip return the total scan region for this clip region
@endclass
@class hsGRectClipRegion
This class defines a recantagular clipping region
@parent hsGClipRegion
@method GetBounds return the bounds of the region
@method SetBounds set the bounds of the region
@endclass
@methoddef hsGRectClipRegion GetBounds
This function returns the boundary of the clip region.  The function returns nil if there is no
boundary. 
@return hsRect* a pointer to the given rectangle 
@param hsRect* bounds a pointer to struct to copy the information into. 
@endmethod
@methoddef hsGRectClipRegion SetBounds
This function sets the boundary of the clip region.  The boundary is set to be no boundary (includes all pixels)
if nil is passed in as the rectangle.
@param hsRect* a pointer to the new bounds rectangle (nil) if no boundard.
@nextparamlist
@param hsScalar left left edge of the new bounds
@param hsScalar right right edge of the new bounds
@param hsScalar top top edge of the new bounds
@param hsScalar bottom bottom edge of the new bounds
@endmethod
@endpage
*/
#endif

