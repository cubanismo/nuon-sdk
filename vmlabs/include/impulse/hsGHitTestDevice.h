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

#ifndef hsGHitTestDevice_DEFINED
#define hsGHitTestDevice_DEFINED

#include "hsGDevice.h"

/** The hsGHitTestDevice class provides for pixel-accurate hit
    testing. It does this by storing a target rectangle in device
    (pixel) coordinates. Any drawing performed on the device will not
    render, but will set a flag as to whether its pixels intersected
    the target rectangle.
	
	\code
	class Shape {
	public:
        ...
        hsBool       HitTest(int x, int y);
	};
	
	hsBool Shape::HitTest(int x, int y)
	{
    	hsIntRect    target;
    	target.Set(x, y, x + 1, y + 1);
    	hsGHitTestDevice tester(&target, true);
    	this->Draw(&tester);
    	return tester.IsHit();
	}
	\endcode
*/
class hsGHitTestDevice : public hsGDevice {
	class hsGHTDevice*	fHTDevice;
public:
	/** The target rectangle (specified by the client) is expressed in
        device coordinates. To specify a single point at \f$(x,y)\f$, pass
        the rectangle \f$(x, y, x+1, y+1)\f$. Any drawing directed to this
        device will not render, but will be tested against the target
        rectangle. Once one primitive intersects the target rectangle,
        the ::IsHit() method will return true. Calling ::Reset() sets the
        ::IsHit() flag back to \c false. */
					hsGHitTestDevice(const hsIntRect* target, hsBool respectAlpha);
	virtual			~hsGHitTestDevice();

	/// resets ::IsHit() to \c false
	void			Reset();
	/// returns \c true if anything has been drawn since the last ::Reset()
	hsBool			IsHit();

//	Overrides

	virtual void	Save();
	virtual void	SaveLayer(const hsRect* bounds, UInt32 flags, const hsGAttribute* attr = nil);
	virtual void	Restore();
	virtual void	Concat(const hsMatrix* matrix);
	virtual void	ClipPath(const hsPath* path, hsBool applyCTM = true);
	virtual hsMatrix* GetTotalMatrix(hsMatrix* matrix);
	virtual void	PushInto(hsGDevice* target) const;

	virtual void	DrawFull(const hsGAttribute* attr);
	virtual void	DrawLine(const hsPoint* start, const hsPoint* stop, const hsGAttribute* attr);
	virtual void	DrawRect(const hsRect* r, const hsGAttribute* attr);
	virtual void	DrawPath(const hsPath* p, const hsGAttribute* attr);
	virtual void	DrawBitmap(const hsGBitmap* b, hsScalar x, hsScalar y,
							   const hsGAttribute* attr);
	virtual void	DrawParamText(UInt32 length, const void* text, hsScalar x, hsScalar y,
								  const hsGAttribute* attr);
	virtual void	DrawPosText(UInt32 length, const void* text,
								const hsPoint pos[], const hsVector tan[],
								const hsGAttribute* attr);
};

#endif
