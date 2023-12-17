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

#ifndef hsGShader_DEFINED
#define hsGShader_DEFINED

#include "hsGStdSizeable.h"
#include "hsGBitmap.h"
#include "hsMatrix33.h"

class hsGAttribute;
class hsRegistry;

/** hsGShader is a client-specified object that supplies per-pixel
	colors. It is called for each scanline of the primitive being
	drawn.

	A hsGShader is attached to an hsGAttribute via
	hsGAttribute::SetShader().

	The shader object is given an uninitialized array that it must
	fill with values. The shader needs to pick-up the base color from
	the attribute, and then use its filter function to modulate
	it. The attribute is given to the shader before each primitive
	with the hsGShader::SetContext() method.

	Also in ::SetContext() is the CTM from source to device pixels. The
	shader might ignore this, but may shaders (like gradient and
	bitmap-tile) need to record the CTM so they can invert it, since
	the ::ShadeSpan() method is passed device coordinates (y, x, count),
	not source coordinates.

	\note It is always possible that the shader will be asked for
	colors at coordinates outside the boarder of the shape being drawn
	(especially if we're antialiasing), so the shader needs to handle
	this, either with real colors or by setting them to [0,0,0,0].

	\note The colors returned by ::ShadeSpan() must be pre-multiplied:
	a >= r, g, b, since all the subsequent blitters will assume this
	when blending onto the device.  */
class hsGShader : public hsGStdSizeable {
protected:
	hsMatrix		fLocalMatrix;
public:
					hsGShader(hsScalar stdSize = 0);
					hsGShader(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);

	//	Overridden from hsGStdSizeable
	//
	virtual void	Write(hsOutputStream* stream, UInt32 flags = 0);

	/**	This is called before each draw,
		giving the shader the current attribute and matrix. */
	virtual void	SetContext(const hsGBitmap* device,
							   const hsGAttribute* attr,
							   const hsMatrix* matrix);

	/**	This may be called by the blitter.
		Return \c true if all colors have alpha == \c 0xFF. */
	virtual hsBool	IsOpaque();

	/** Subclasses must implement this.

		This is called by the blitter,
		where \a x and \a y are in device coordinates. */
	virtual void	ShadeSpan(int y, int x, int count, hsColor32 src[]) = 0;
	/// If this isn't overridden, it calls ::ShadeSpan.
	virtual void	ShadeSpanAlpha(int y, int x, int count, UInt8 alpha[]);
#if HS_IMPULSE_SUPPORT_GRAY4
	/** If this isn't overridden, it calls ::ShadeSpan.
		
		This function is only present if the \c
		HS_IMPULSE_SUPPORT_GRAY4 compile-time option is set. */
	virtual void	ShadeGray4(int y, int x, int count, hsGAlphaGray44 src[]);
#endif

	virtual void	SetLocalMatrix(const hsMatrix* mat);
	void			GetLocalMatrix(hsMatrix *mat) const
					{
						if (mat)
							*mat = fLocalMatrix;
					}

	virtual hsBool	WriteSVG(class hsXMLWriter* xml, const char id[]);

	///	For subclasses that support tiling
	enum TileMode {
		kClampTile,
		kWrapTile,
		kMirrorTile,
		kDecalTile
	};
};

//	This is an internal class. Do not subclass it
//
class hsGInternalShader : public hsGShader {
public:
						hsGInternalShader();

	//	Define these two to do nothing
	//
	virtual CreateProc	GetCreateProc();
	virtual const char* GetName();
};

#endif
