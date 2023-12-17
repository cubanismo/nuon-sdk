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

#ifndef AlphaMask_Region_Inline_DEFINED
#define AlphaMask_Region_Inline_DEFINED

#include "hsGBlitter.h"

void AlphaMask::Rgn::Spanerator::blitSpan(int y, int x, int count, hsGBlitter* blitter)
{
	Int32	left = x;
	Int32	right = x + count;

	while (this->clipSpan(y, left, right))
	{	blitter->Blit(y, left, right - left);
		hsAssert(right <= x + count, "bad clipSpan");
		if (right + 1 >= x + count)
			break;
		left = right + 1;
		right = x + count;
	}
}

#if 1
	#define	AM_RGN_BLIT_SPAN(spanerator, y, x, count, blitter)		\
		spanerator.blitSpan(y, x, count, blitter)
#else
	#define	AM_RGN_BLIT_SPAN(spanerator, y, x, count, blitter)		\
		do {														\
			Int32	left = x;										\
			Int32	right = x + count;								\
																	\
			while (spanerator.clipSpan(y, left, right))				\
			{	blitter->Blit(y, left, right - left);				\
				hsAssert(right <= x + count, "bad clipSpan");		\
				if (right + 1 >= x + count)							\
					break;											\
				left = right + 1;									\
				right = x + count;									\
			}														\
		} while (0)
#endif

#endif
