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

#ifndef hsGDistanceKernel_Defined
#define hsGDistanceKernel_Defined

#include "hsGBitmap.h"

class hsGDistanceKernel {
	int*	fKernel;
	UInt8*	fImage;
	hsFixed	fUnitScale;
	int		fDiameter, fMaxValue, fRowBytes;

	inline void	Apply(int x, int y, unsigned maskValue) const;
public:
			hsGDistanceKernel(int innerRadius, int outerRadius, UInt8 image[], int rowBytes, int maxValue);
			~hsGDistanceKernel();

	void 		Apply(const hsGBitmap* src, hsBool mergeWithSource);
};

#endif
