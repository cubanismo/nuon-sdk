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

#ifndef hsTLoops_DEFINED
#define hsTLoops_DEFINED

#include "hsTypes.h"

#undef HS_DO_LOOP_UNROLL

#if !(HS_BUILD_FOR_MAC)
	#define HS_DO_LOOP_UNROLL
#endif

///////////////////////////////////////////////////////////////////////////

#if 0
	#define StarPlusPlus(dst, src, i)			(dst)[i] = (src)[i]
	#define StarPlusPlusAssign(dst, i, V)		(dst)[i] = (V)
	#define StarPlusPlusUpdate(ptr, N)			ptr += N

	#define StarMinusMinus(dst, src, i)			(dst)[i] = (src)[i]
	#define StarMinusMinusUpdate(ptr, N)		ptr -= N
#else
	#define StarPlusPlus(dst, src, i)			*dst++ = *src++
	#define StarPlusPlusAssign(dst, i, V)		*dst++ = V
	#define StarPlusPlusUpdate(ptr, N)

	#define StarMinusMinus(dst, src, i)			*--dst = *--src
	#define StarMinusMinusUpdate(ptr, N)
#endif


template <class T> inline void hsTFastForward(T dst[], const T src[], int count)
{
#ifdef HS_DO_LOOP_UNROLL
	int	octCount = count >> 3;

	while (--octCount >= 0)
	{
		StarPlusPlus(dst, src, 0);	StarPlusPlus(dst, src, 1);
		StarPlusPlus(dst, src, 2);	StarPlusPlus(dst, src, 3);
		StarPlusPlus(dst, src, 4);	StarPlusPlus(dst, src, 5);
		StarPlusPlus(dst, src, 6);	StarPlusPlus(dst, src, 7);

		StarPlusPlusUpdate(src, 8);
		StarPlusPlusUpdate(dst, 8);
	}

	count &= 7;
#endif
	for (int i = 0; i < count; i++)
		StarPlusPlus(dst, src, i);
}

template <class T> inline void hsTFastBackward(T dst[], const T src[], int count)
{
#ifdef HS_DO_LOOP_UNROLL
	src += count;
	dst += count;

	int	octCount = count >> 3;

	while (--octCount >= 0)
	{
		StarMinusMinus(dst, src, -1);	StarMinusMinus(dst, src, -2);
		StarMinusMinus(dst, src, -3);	StarMinusMinus(dst, src, -4);
		StarMinusMinus(dst, src, -5);	StarMinusMinus(dst, src, -6);
		StarMinusMinus(dst, src, -7);	StarMinusMinus(dst, src, -8);

		StarMinusMinusUpdate(src, 8);
		StarMinusMinusUpdate(dst, 8);
	}

	count &= 7;
	for (int i = 0; i < count; i++)
		*--dst = *--src;
#else
	for (int i = count - 1; i >= 0; --i)
		dst[i] = src[i];
#endif
}

template <class T> inline void hsTFastAssign(T dst[], int count, T value)
{
#ifdef HS_DO_LOOP_UNROLL
	int	octCount = count >> 3;

	while (--octCount >= 0)
	{
		StarPlusPlusAssign(dst, 0, value);	StarPlusPlusAssign(dst, 1, value);
		StarPlusPlusAssign(dst, 2, value);	StarPlusPlusAssign(dst, 3, value);
		StarPlusPlusAssign(dst, 4, value);	StarPlusPlusAssign(dst, 5, value);
		StarPlusPlusAssign(dst, 6, value);	StarPlusPlusAssign(dst, 7, value);

		StarPlusPlusUpdate(dst, 8);
	}
	count &= 7;
#endif
	for (int i = 0; i < count; i++)
		StarPlusPlusAssign(dst, i, value);
}

template <class T> inline void hsTFastClear(T dst[], int count)
{
	hsTFastAssign(dst, count, T(0));
}

#endif
