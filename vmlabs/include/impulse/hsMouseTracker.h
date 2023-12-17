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

#ifndef hsMouseTrackerDefined
#define hsMouseTrackerDefined

#include "hsMatrix33.h"
#include "hsInput.h"
#include "hsRefCnt.h"

class hsMouseTracker : public hsRefCnt {
protected:
	UInt32		fFlags;
	hsMatrix33	fInverse;

	// override these in your subclass
	virtual void	DownSelf(const hsPoint2* loc, hsModifierKeys modi);
	virtual void	MovedSelf(const hsPoint2* loc, hsModifierKeys modi);
	virtual void	UpSelf(const hsPoint2* loc, hsModifierKeys modi);
	
	// return true if we should proceed with calling the ...Self method
	virtual hsBool	FilterInput(Int32 x, Int32 y, hsPoint2* loc, hsModifierKeys* modi);
public:
	enum {
		kWaitForMove	= 0x0001		// don't call MouseMoved until it really does
	};
				hsMouseTracker(UInt32 flags = 0);
				hsMouseTracker(class hsGDevice* device, UInt32 flags = 0);

	UInt32		GetFlags() const { return fFlags; }
	virtual void	SetFlags(UInt32 flags);

	virtual void	MouseDown(Int32 x, Int32 y, hsModifierKeys modi);
	virtual void	MouseMoved(Int32 x, Int32 y, hsModifierKeys modi);
	virtual void	MouseUp(Int32 x, Int32 y, hsModifierKeys modi);

	static hsMouseTracker*	RefEmptyTracker();

	static void	SetTracker(hsMouseTracker* tracker);
	static void	DoMouseMoved(Int32 x, Int32 y, hsModifierKeys modi);
	static void	DoMouseUp(Int32 x, Int32 y, hsModifierKeys modi);
};

#endif
