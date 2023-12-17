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

#ifndef hsGRasterDevice_DEFINED
#define hsGRasterDevice_DEFINED

#include "hsConfig.h"
#include "hsGDevice.h"
#include "hsGBitmap.h"
#include "RawDraw.h"
#include "HSScan.h"

class hsGCursorHandler;

/** To draw into a bitmap, use hsGRasterDevice (or its descendant
    hsGOffscreenDevice). */
class hsGRasterDevice : public hsGDevice {
	AlphaMask::RawDraw	fRD;

	hsIntPoint		fOrigin;

#ifdef HS_BUILD_FOR_NUON
protected:
	hsGBitmap		fPixels;
	hsBool			fTotalClipDirty;
#else
private:
	hsGBitmap		fPixels;
	hsBool			fTotalClipDirty;
#endif

	hsBool32		fWeOwnTheImage;
	
	hsMatrix		fTotalMatrix;
	hsScanRegion	fTotalClip;
	hsBool			fTotalMatrixDirty;
	
	const hsScanRegion*	fClipRgn;

	void			CheckDirtyMatrixClip();

	class hsGRasterLayer* fCurrLayer;
	hsIntPoint		fLayerOrigin;
	
	hsGCursorHandler*	fCursorHandler;
public:
					hsGRasterDevice();
	virtual			~hsGRasterDevice();

	HSScanHandler*	GetHandler() const { return fRD.fHandler; }
	virtual void	SetHandler(HSScanHandler* handler);

	void			GetOrigin(hsIntPoint* origin) const;
	/** ::SetOrigin() affects the device's total matrix by apply a
        translate after all other transforms have been applied. */
	virtual void	SetOrigin(int x, int y);

	hsGBitmap*		GetPixels(hsGBitmap* pixels) const;
	/** Call ::SetPixels() to give the device the bitmap it should draw
        into. If the fImage field of the bitmap is set to nil, then
        the device will allocate the memory for the bitmap (based on
        its width, height, pixel-size). If this is done, then the
        device will manage deleting that memory when either the device
        is destroyed, or another to call to ::SetPixels() is
        made. Calling ::GetPixels() returns a bitmap whose \a fImage#field
        reflects either the memory specified at the ::SetPixels() call,
        or the memory allocated by the device. It also calls
        ::SetOrigin() with the top-left of the bounds. */
	virtual void	SetPixels(const hsGBitmap* pixels);

	///
	hsGBitmap::Config GetBounds(hsIntRect* bounds) const;
	/** ::SetBounds() is a helper method. It takes a bounding rectangle
        and constructs a bitmap based on it and the specified
        bitDepth. In turn, it calls ::SetPixels() with a bitmap whose
        fImage field is \c nil, forcing the device to allocate the
        memory. */
	void			SetBounds(const hsIntRect* bounds, hsGBitmap::Config config);

	/**	The \a clipRgn is not copied, but you must call ::SetClipRgn()
		each time you change the clip to inform the device to
		look at it again. */
	const hsScanRegion*	GetClipRgn() const { return fClipRgn; }
	void			SetClipRgn(const hsScanRegion* clip);

	///
	void			Scroll(	const hsIntRect* srcRect, int dx, int dy,
							class hsScanRegion* dirty = nil);

	/** @name Erasure Methods
		
		These methods fill the device's bitmap with the specified
		color (including alpha). They does not call any of the virtual
		Draw methods, but write to the pixels directly, ignoring the
		matrix or clip. */
	//@{
	/// alpha = 0
	void			Erase();
	///
	virtual void	Erase(const hsGColor* color);
	/// alpha = 0xFFFF
	void			Erase(hsGColorValue red, hsGColorValue green, hsGColorValue blue);
	///
	void			Erase(hsGColorValue alpha, hsGColorValue red, hsGColorValue green, hsGColorValue blue);
	//@}

//	Cursor routines

	hsGCursorHandler* GetCursorHandler() const { return fCursorHandler; }
	void			SetCursorHandler(hsGCursorHandler* cursor);

//	Overrides from hsGDevice

	virtual void	SaveLayer(const hsRect* bounds, UInt32 flags, const hsGAttribute* attr = nil);
	virtual void	Restore();
	virtual void	Concat(const hsMatrix* matrix);
	virtual void	ClipPath(const hsPath* path, hsBool applyCTM = true);
	virtual hsMatrix* GetTotalMatrix(hsMatrix* matrix);

	/*! @name Raster Drawing

		The methods ::DrawLine(), ::DrawRect(), and ::DrawPath() operate in
		the following manner.

		- Prepare the geometry for scan conversion
			- Apply the hsGPathEffect (if any) from the attribute.
			- Stroke the geometry (if kFrame is specified by the attribute).
			- Apply the total-matrix to the geometry, transforming it into
			  device space.
		- Scan convert the geometry into an alpha mask, clipped to the bounds
		  of the stack of device clips.
			- Use the hsGRasterizer (if any) from the attribute, going from a
			  geometry to a mask.
			- Apply the hsGMaskFilter (if any) from the attribute, generating
			  another mask.
		- Blit the mask into the pixels using the color from the attribute,
		  clipped to the stack of device clips.
			- Use the hsGShader (if any) from the attribute to obtain the
			  colors (modified by the attribute's color's alpha).
			- Use the hsGXferMode (if any) from the attribute to blend the
			  colors with the device's pixels.
	*/
	//@{
	virtual void	DrawFull(const hsGAttribute* attr);
	virtual void	DrawLine(const hsPoint* start, const hsPoint* stop,
							 const hsGAttribute* attr);
	virtual void	DrawRect(const hsRect* r, const hsGAttribute* attr);
	virtual void	DrawPath(const hsPath* p, const hsGAttribute* attr);
	/** ::DrawBitmap() draws the bitmap primitive with its top-left
		corner specified by the \a x and \a y parameters. The bitmap
		respects the specified matrix and clip, and the attribute's
		color's alpha, and optional hsGXferMode. If the device's
		matrix causes the bitmap to be scaled, rotated, or otherwise
		transformed when it is drawn, then Impulse looks at the
		kFilterBitmap flag in the attribute. Filtering generally
		generates better results, but runs slower.  */
	virtual void	DrawBitmap(const hsGBitmap* b, hsScalar x, hsScalar y,
							   const hsGAttribute* attr);
	/** ::DrawParamText() and ::DrawPosText() offer two different ways
		to specify where to draw text. ::DrawParamText() just
		specifies the starting location, and relies on the spacing
		information in the font (and the optional hsGTextFace and
		hsGTextSpace fields of the attribute) to determine where to
		draw the characters. ::DrawPosText() specifies the position of
		each character (and optionally a tangent for each
		character). Both methods use the font and text size from the
		attribute.  */
	virtual void	DrawParamText(UInt32 length, const void* text, hsScalar x, hsScalar y,
								  const hsGAttribute* attr);
	virtual void	DrawPosText(UInt32 length, const void* text,
								const hsPoint pos[], const hsVector tan[],
								const hsGAttribute* attr);

	/**	For drawing horizontal-only (the total-matrix is ignored)
		ASCII text (ignores the attribute's text-encoding).

		\note The \a loc parameter is updated to reflect the end of the line.
        \note The \a underline parameter is optional. */
	void			DrawFastText(UInt32 length, const UInt8 text[], hsPoint* loc,
								const hsScalar underline[2], const hsGAttribute* attr);

	void			DrawSprite(const hsGBitmap* b, int x, int y,
							   const hsGAttribute* a);
	//@}

	const hsScanRegion*	GetTotalClip();
};

#endif

