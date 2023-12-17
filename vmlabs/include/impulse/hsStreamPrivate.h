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

#ifndef hsStreamPrivate_INCLUDE
#define hsStreamPrivate_INCLUDE

#if HS_BUILD_FOR_WIN32
	static void swapIt(Int32 *swap)
	{
		Byte*	c = (Byte*)swap;
		Byte		t = c[0];

		c[0] = c[3];
		c[3] = t;
		t = c[1];
		c[1] = c[2];
		c[2] = t;
	}

	static void swapIt(int *swap)
	{
		swapIt((Int32*)swap);
	}

	static void swapIt(float *swap)
	{
		swapIt((Int32*)swap);
	}

	static void swapIt(Int16 *swap)
	{
		Byte *c = (Byte*)swap;
		Byte t;
		t = c[0];
		c[0] = c[1];
		c[1] = t;
	}
#else
	#define swapIt(value)
#endif

#if HS_SCALAR_IS_FLOAT
	#define kFloatToFixedCount	16
#endif

#endif
