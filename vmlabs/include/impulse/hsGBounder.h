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

#ifndef hsGBounder_DEFINED
#define hsGBounder_DEFINED

#include "hsGRasterDevice.h"
#include "HSScan.h"

/**
   The hsGBounder class provides a mechanism for calculating the
   bounds of one or drawing primitive. Note that this bounds can vary
   greatly from just the bounds of the primitive's geometry, for there
   are many factors that affect the bounds:
   
   <UL>
   
   <LI> Framing (stroking) adds to the bounds. In the simplest case,
   \f$1/2\f$ of the frame size is added to each side of the bounds,
   but miter joins (if they are selected in the attribute) can extend
   the bounds even further.

   <LI> The device's matrix can transform the geometry, affecting its bounds.
   
   <LI> The optional objects hsGPathEffect, hsGRasterizer,
   hsGMaskFilter can all modify the drawing of a primitive such that
   its bounds differ from the geometry. Note that hsGShader and
   hsGXferMode objects cannot affect the size of the drawn primitive,
   only what color(s) it is drawn in.
   
   </UL>

   Example usage:

\code
class Shape {
public:
    virtual void Draw(hsGDevice* device) = 0;
    hsBool       Bounds(hsIntRect* bounds);
};

hsBool Shape::Bounds(hsIntRect* bounds)
{
    hsGBounder bounder;

    this->Draw(bounder.GetDevice());

	 return bounder.GetBounds(bounds);
}
\endcode

	This example assumes that the Shape class has subclasses that define
	the Draw() method for various types of shapes. Each shape subclass
	knows how to draw itself into a device. The Bounds() method is not
	virtual, and need only be implemented by the base class, since it can
	create a bounder device and pass that to the Shape's virtual Draw()
	method. Whatever the subclass draws will get accumulated by the
	bounder's device, and returned when :etBounds() is called.

	\sa hsGHitTestDevice */
class hsGBounder : HSScanHandler {
protected:
	hsGRasterDevice	fDevice;
	hsIntRect		fBounds;
	hsBool			fIsEmpty;
	hsBool			fRespectClip;

	//	Override from HSScanHandler
	//
	virtual hsBool 	HandleIntRect(const hsIntRect*, const hsScanRegion* clip);
public:
	///
				hsGBounder(hsBool respectClip = false);
	
				/** resets the bounds to empty

				Calling ::Reset() reinitializes the bounder's
				accumulater rectangle, so the same bounder object can
				be used to compute the bounds of different
				primitives. */
	void		Reset(hsBool respectClip = false);

	/** draw into this device to accumulate bounds
		
		::GetDevice() returns a private device object. Any drawing directed to
		this device will not appear anywhere, but will its bounds will be
		accumulated by the bounder object. */
	hsGDevice*	GetDevice() { return &fDevice; }
	/** returns the accumulated bounds, or \c false if none
		
		Notice that ::GetBounds() returns a \c bool, and returns the
		resulting bounds (if bounds \f$\neq$ \c nil) as an integer
		rectangle. This is the device coordinate bounds of the
		primitive(s) that were drawn into the device returned by
		::GetDevice(). If ::GetBounds() returns false, then no primitive
		was drawn into the device (or if one was, it was clipped
		out). */
	hsBool		GetBounds(hsIntRect* bounds);
};

#endif
