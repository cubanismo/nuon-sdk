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

#ifndef hsGDevice_DEFINED
#define hsGDevice_DEFINED

#include "hsPath.h"
#include "hsGAttribute.h"

/** The base class for all drawing devices.

Impulse provides several basic subclass of hsGDevice, overriding the
Draw methods:

- hsGRasterDevice. This subclass renders into a bitmap. The client
  can provide the memory for the bitmap, or the class can allocate it.

- hsGOffscreenDevice. This subclass of hsGRasterDevice manages
  creating a platform-specific offscreen bitmap, and offers easy methods
  for copying it onto the screen.

- hsGStreamDevice. This subclass captures the drawing commands and
  writes them into a stream for later playback.

- hsGPostScriptDevice. This subclass captures the drawing commands and
  translates them into PostScript commands, ignoring those features of
  Impulse that are not supported in PostScript.

- hsGHitTestDevice. This subclass provides a device that tests whether
  a given point or rectangle intersects any of the primitives drawn
  into it.

Impulse also provides helper classes based around hsGDevice:

- hsGBounder. This class provides a device that returns the bounds of
  any primitives drawn into it.

- hsGStreamPlayback.  This class takes the drawing commands previously
  recorded by hsGStreamDevice into a stream, and replays them into
  another device.
*/
class hsGDevice : public hsRefCnt {
	// assignment is not allowed
	void			operator=(const hsGDevice&);
protected:
	friend class hsGDevice_Data;
	hsGDevice_Data*	fData;
public:
					hsGDevice();
	virtual			~hsGDevice();

	enum {
		kTranspLayer		= 0x0001,
		kDeviceConfigLayer	= 0x0000,		//!< default is to match the device's config
		k32BitConfigLayer	= 0x0100,
		kAlphaConfigLayer	= 0x0200,

		kLayerConfigMask	= 0x0300
	};

	/** @name Device Stack
		
		The device maintains an internal stack of matrices and clips
		(views). These affect all primitives drawn into the device. A
		new "view" is pushed onto the stack when Save() is called. It
		is initialized to an identity matrix and an unrestricted
		clip. This new view can be modified: the matrix is changed
		using Concat(), and the clip is augmented by using
		ClipPath(). To pop the current view off the stack, call
		Restore().

		Example:

		\code
		device->DrawRect(&rect, &attr);
		device->Save();
		// now there is another view on the stack
		device->Rotate(hsIntToScalar(30), 0, 0);
		device->DrawRect(&rect, &attr);
		// now the rect is rotated 30 degress about (0,0)
		path.AddOval(&rect);
		device->ClipPath(&path);
		device->DrawRect(&rect, &attr);
		// now the rect draws through an oval clip
		device->Restore();
		// now the device is back to its original view state
		\endcode
	*/
	//@{
	virtual void	Save();
	virtual void	SaveLayer(const hsRect* bounds, UInt32 flags, const hsGAttribute* attr = nil);
	virtual void	Restore();
	//@}
	
	/** @name Matrix and Clip manipulation
		
		There are helper methods for manipulating the matrix and clip.

		Balance with one call to Restore() */
	//@{
	/** ClipRect() is a utility method for creating a rectangular
		path, and clipping with it. Internally, the code looks
		something like the following:

		\code
		void hsGDevice::ClipRect(const hsRect* rect)
		{
			if (rect != nil)
			{
        		hsPath path;
				
				path.AddRect(rect);
				this->ClipPath(&path);
			}
		}
		\endcode
		
		Internally, Impulse detects paths that are rectangular, and uses them
		as such for efficiency.  */
	void			ClipRect(const hsRect* rect);
	virtual void	ClipPath(const hsPath* path, hsBool applyCTM = true);
	/** ::Translate(), ::Scale(), ::Rotate(), ::Skew() and ::Concat()
		methods should look familiar. They are similar to the methods
		on hsMatrix, except that on a hsGDevice, they premultiply
		the device matrix (are applied before the rest of the Device
		matrix), where as the hsMatrix methods postmultiply,
		applying their change after the original matrix.  */
	void			Translate(hsScalar dx, hsScalar dy);
	void			Scale(hsScalar sx, hsScalar sy, hsScalar px, hsScalar py);
	void			Rotate(hsScalar degrees, hsScalar px, hsScalar py);
	void			Skew(hsScalar sx, hsScalar sy, hsScalar px, hsScalar py);
	virtual void	Concat(const hsMatrix* matrix);
	//@}


	/** The device method GetMatrix() returns only the current matrix
		for the view on the top of the stack. This is the matrix you
		are allow to modify. However, when a primitive is drawn, it is
		transformed by the concatenation of all of the matrices in the
		stack. This concatenated matrix is called the TotalMatrix. The
		TotalMatrix cannot be modified, but may be retrieved. It is
		useful for mapping (transforming) points into device space
		(pixel space in the case of a hsGRasterDevice).
		
		\code
		hsMatrix*	GetTotalMatrix(hsMatrix* matrix);
		void        MapPoints(int count, const hsPoint src[],
					hsPoint dst[]);
		void        MapRect(const hsRect* src, hsRect* dst);
		\endcode
		
		::GetTotalMatrix() returns the parameter it is passed, not the
		actual total matrix. This allows the following usage:
		
		\code
		hsMatrix matrix;
		device->GetTotalMatrix(&matrix)->MapPoints(4, src, dst);
		\endcode
	 */
	virtual hsMatrix* GetTotalMatrix(hsMatrix* matrix);
	/** ::PushInto() is used to transfer the entire view stack from
        the source device. This is useful when you want to replicate
        the drawing from one device into another. Internally, this is
        done by first calling ::Save(), and then concatenating all of
        the matrices and clips from source. To restore the device to
        its state before the ::PushInto() call, only one call to
        ::Restore() is needed. */
	virtual void	PushInto(hsGDevice* target) const;

	virtual void	DrawFull(const hsGAttribute* attr);
	virtual void	DrawLine(const hsPoint* start, const hsPoint* stop, const hsGAttribute* attr);
	virtual void	DrawRect(const hsRect* r, const hsGAttribute* attr);
	virtual void	DrawPath(const hsPath* p, const hsGAttribute* attr);
	virtual void	DrawBitmap(const hsGBitmap* b, hsScalar x, hsScalar y, const hsGAttribute* attr);
	virtual void	DrawParamText(UInt32 length, const void* text, hsScalar x, hsScalar y,
								  const hsGAttribute* attr);
	virtual void	DrawPosText(UInt32 length, const void* text,
								const hsPoint pos[], const hsPoint tan[],
								const hsGAttribute* attr);

	//	Helper methods
	//
	void			DrawColor(const hsGColor* color);
	void			DrawARGB(	hsGColorValue alpha, hsGColorValue red,
								hsGColorValue green, hsGColorValue blue);
	
	/** MapPoints() can accept \a src[] and \a dst[] being the same
		array.  */
	void			MapPoints(int count, const hsPoint src[], hsPoint dst[]);
	/** MapRect returns in \a dst the bounds of the transformed \a src
		rectangle in the case the TotalMatrix involves more than just
		translation and scaling. */
	void			MapRect(const hsRect* src, hsRect* dst);

	/** @name Matrix Inversion Helper Methods
		
		Sometimes it is helpful to perform the inverse operation:
		mapping points (and vectors) from device coordinates back
		through the TotalMatrix. This can be done by calling
		::GetTotalMatrix() and then inverting the matrix, or using the
		following helper methods.
		
		These inverse methods return a boolean value, indicating
		their success or failure. If the device's total matrix is
		non-invertible, these methods return \c false and do not modify
		their parameters. */
	//@{
	hsBool			GetTotalInverse(hsMatrix* inverse);
	hsBool			InvertPoints(int count, const hsPoint src[], hsPoint dst[]);
	hsBool			InvertRect(const hsRect* src, hsRect* dst);
	//@}
};

class hsGSaveRestore {
	hsGDevice*	fDevice;
public:
	hsGSaveRestore(hsGDevice* device) : fDevice(device)
	{
		if (device) device->Save();
	}
	~hsGSaveRestore()
	{
		if (fDevice) fDevice->Restore();
	}
};

#endif
