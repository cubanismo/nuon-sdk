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

#ifndef hsBilerpFactors_Defined
#define hsBilerpFactors_Defined

#include "hsScalar.h"

#define hsFixedToDot2(value)		(((value) >> 14) & 3)
#define hsScalarToDot2(value)		((hsScalarToFixed(value) >> 14) & 3)

#define HS_BILERP_INDEX(xDot2, yDot2)		(((yDot2) << 2) | (xDot2))

struct hsGBilerpFactors {
	int	m00, m01, m10, m11;
};
extern const hsGBilerpFactors gBilerpFactors[];

#define ASSERT_VALID_BILERPFACTORS(f)	\
	hsAssert(f->m00 + f->m01 + f->m10 + f->m11 == 16, "bad bilerp factors")

inline int hsBILERP(int p00, int p01, int p10, int p11, const hsGBilerpFactors* f)
{
	return (f->m00 * p00 + f->m01 * p01 + f->m10 * p10 + f->m11 * p11) >> 4;
}

inline const hsGBilerpFactors* hsGetDot2BilerpFactors(unsigned xDot2, unsigned yDot2)
{
	return &gBilerpFactors[HS_BILERP_INDEX(xDot2, yDot2)];
}

inline const hsGBilerpFactors* hsGetFixedBilerpFactors(hsFixed x, hsFixed y)
{
	return &gBilerpFactors[HS_BILERP_INDEX(hsFixedToDot2(x), hsFixedToDot2(y))];
}

inline const hsGBilerpFactors* hsGetScalarBilerpFactors(hsScalar x, hsScalar y)
{
	return &gBilerpFactors[HS_BILERP_INDEX(hsScalarToDot2(x), hsScalarToDot2(y))];
}

#endif
