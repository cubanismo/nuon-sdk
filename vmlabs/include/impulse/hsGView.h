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

#ifndef hsGView_DEFINED
#define hsGView_DEFINED

#include "hsGDevice.h"

class hsGView : public hsRefCnt {
	hsGView*	fParent;
	hsMatrix	fMatrix;
	hsRect		fClipRect;
	hsBool		fClipIsFull;
public:
				hsGView(hsGView* parent = nil);
	virtual		~hsGView();
	
	hsGView*	GetParent() const { return fParent; }
	void		SetParent(hsGView* parent);

	void		Reset() { this->ResetClip(); this->ResetMatrix(); }

	void		ResetClip() { fClipIsFull = true; }
	void		ClipRect(hsScalar left, hsScalar top, hsScalar right, hsScalar bottom);
	void		ClipRect(const hsRect* rect);

	void		ResetMatrix() { fMatrix.Reset(); }
	void		Translate(hsScalar dx, hsScalar dy);
	void		Scale(hsScalar sx, hsScalar sy, hsScalar px, hsScalar py);
	void		Rotate(hsScalar degrees, hsScalar px, hsScalar py);
	void		Skew(hsScalar sx, hsScalar sy, hsScalar px, hsScalar py);
	void		Concat(const hsMatrix* matrix);

	hsMatrix*	GetMatrix(hsMatrix* matrix);
	void		SetMatrix(const hsMatrix* matrix);

	void		Apply(hsGDevice* device);
	void		Push(hsGDevice* device);
};

#endif
