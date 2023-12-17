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

#ifndef hsPathMeasure_Defined
#define hsPathMeasure_Defined

#include "hsPath.h"

class hsPathMeasure {
	hsPathIterator*			fIter;
	UInt32					fSegCount;
	class hsPathSegment*	fSegArray;
	hsScalar				fTotalLength;
	hsBool					fDirty;

	void		AssureCache();
public:
				hsPathMeasure();
				hsPathMeasure(hsPathIterator* iter);
	virtual		~hsPathMeasure();

	void		SetPath(hsPathIterator* iter);
	hsBool		NextContour();

	hsScalar	GetLength();
	hsBool		GetPosTan(hsScalar distance, hsPoint* position, hsVector* tangent);
	void		GetSegment(hsScalar startDistance, hsScalar stopDistance,
							hsPath* segment, hsBool newContour);
};

#endif
