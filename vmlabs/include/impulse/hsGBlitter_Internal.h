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

#ifndef hsGBlitterInternalDefined
#define hsGBlitterInternalDefined

#include "hsFixedTypes.h"

#define FixedToPlane(value)		((value) >> 4)
#define PlaneToInt_8(value)		((value) >> 12)
#define PlaneToInt_5(value)		((value) >> 15)

#define ALPHA_MASK_16		0x8000
//#define ALPHA_MASK_16		0
#define Get_Red_16(pixel)	(((pixel) >> 10) & 0x1F)
#define Get_Green_16(pixel)	(((pixel) >> 5) & 0x1F)
#define Get_Blue_16(pixel)	((pixel) & 0x1F)
#define Set_Red_16(r)		((UInt16)(r) << 10)
#if HS_IMPULSE_SUPPORT_NUON655
#define Get_Y_16(pixel)		(((pixel) >> 10) & 0x3F)
#endif
#define Set_Green_16(g)		((UInt16)(g) << 5)
#define Set_Blue_16(b)		((UInt16)(b))

#if defined(HS_PIXEL_FORMAT_BGRA)
	#define ALPHA_MASK_32		UInt32(0xFF)
	#define Get_Blue_32(pixel)	(UInt8)((UInt32)(pixel) >> 24)
	#define Get_Green_32(pixel)	(UInt8)((UInt32)(pixel) >> 16)
	#define Get_Red_32(pixel)	(UInt8)((UInt32)(pixel) >> 8)
	#define Get_Alpha_32(pixel)	(UInt8)((UInt32)(pixel))
	#define Set_Blue_32(a)		((UInt32)(a) << 24)
	#define Set_Green_32(r)		((UInt32)(r) << 16)
	#define Set_Red_32(g)		((UInt32)(g) << 8)
	#define Set_Alpha_32(b)		UInt32(b)
	
	#define Get_Blue_32_5(pixel)		(UInt32(pixel) >> 27)
	#define Get_Green_32_5(pixel)	((UInt32(pixel) >> 19) & 0x1F)
#if HS_IMPULSE_SUPPORT_NUON655
	#define Get_Red_32_5(pixel)		((UInt32(pixel) >> 10) & 0x3F)
#else
	#define Get_Red_32_5(pixel)		((UInt32(pixel) >> 11) & 0x1F)
#endif
#elif defined(HS_PIXEL_FORMAT_ABGR)
	#define ALPHA_MASK_32		UInt32(0xFFL << 24)
	#define Get_Alpha_32(pixel)	(UInt8)((UInt32)(pixel) >> 24)
	#define Get_Blue_32(pixel)	(UInt8)((UInt32)(pixel) >> 16)
	#define Get_Green_32(pixel)	(UInt8)((UInt32)(pixel) >> 8)
	#define Get_Red_32(pixel)	(UInt8)(pixel)
	#define Set_Alpha_32(a)		((UInt32)(a) << 24)
	#define Set_Blue_32(b)		((UInt32)(b) << 16)
	#define Set_Green_32(g)		((UInt32)(g) << 8)
	#define Set_Red_32(r)		UInt32(r)
	
	#define Get_Blue_32_5(pixel)	((UInt32(pixel) >> 19) & 0x1F)
	#define Get_Green_32_5(pixel)	((UInt32(pixel) >> 11) & 0x1F)
#if HS_IMPULSE_SUPPORT_NUON655
	#define Get_Red_32_5(pixel)	((UInt32(pixel) >> 2) & 0x3F)
#else
	#define Get_Red_32_5(pixel)	((UInt32(pixel) >> 3) & 0x1F)
#endif
#elif defined(HS_PIXEL_FORMAT_RGBA)
	#define ALPHA_MASK_32		UInt32(0xFF)
	#define Get_Red_32(pixel)	(UInt8)((UInt32)(pixel) >> 24)
	#define Get_Green_32(pixel)	(UInt8)((UInt32)(pixel) >> 16)
	#define Get_Blue_32(pixel)	(UInt8)((UInt32)(pixel) >> 8)
	#define Get_Alpha_32(pixel)	(UInt8)(pixel)
	#define Set_Red_32(r)		((UInt32)(r) << 24)
	#define Set_Green_32(g)		((UInt32)(g) << 16)
	#define Set_Blue_32(b)		((UInt32)(b) << 8)
	#define Set_Alpha_32(a)		UInt32(a)
	
#if HS_IMPULSE_SUPPORT_NUON655
	#define Get_Red_32_5(pixel)		((UInt32(pixel) >> 26))
#else
	#define Get_Red_32_5(pixel)		((UInt32(pixel) >> 27))
#endif
	#define Get_Green_32_5(pixel)	((UInt32(pixel) >> 19) & 0x1F)
	#define Get_Blue_32_5(pixel)	((UInt32(pixel) >> 11) & 0x1F)
#else
	#if !defined(HS_PIXEL_FORMAT_ARGB)
	#warning No pixel format defined assuming HS_PIXEL_FORMAT_ARGB
	#endif
	#define ALPHA_MASK_32		UInt32(0xFFL << 24)
	#define Get_Alpha_32(pixel)	(UInt8)((UInt32)(pixel) >> 24)
	#define Get_Red_32(pixel)	(UInt8)((UInt32)(pixel) >> 16)
	#define Get_Green_32(pixel)	(UInt8)((UInt32)(pixel) >> 8)
	#define Get_Blue_32(pixel)	(UInt8)((UInt32)(pixel))
	#define Set_Alpha_32(a)		((UInt32)(a) << 24)
	#define Set_Red_32(r)		((UInt32)(r) << 16)
	#define Set_Green_32(g)		((UInt32)(g) << 8)
	#define Set_Blue_32(b)		UInt32(b)

#if HS_IMPULSE_SUPPORT_NUON655
	#define Get_Red_32_5(pixel)		((UInt32(pixel) >> 18) & 0x3F)
#else
	#define Get_Red_32_5(pixel)		((UInt32(pixel) >> 19) & 0x1F)
#endif
	#define Get_Green_32_5(pixel)	((UInt32(pixel) >> 11) & 0x1F)
	#define Get_Blue_32_5(pixel)		((UInt32(pixel) >> 3) & 0x1F)
#endif

#define SET_ARGB_32(a, r, g, b)	UInt32(Set_Alpha_32(a) | Set_Red_32(r) | Set_Green_32(g) | Set_Blue_32(b))
#define SET_RGB_32(r, g, b)		UInt32(ALPHA_MASK_32 | Set_Red_32(r) | Set_Green_32(g) | Set_Blue_32(b))

inline unsigned Promote_ColorComponent_5To8(unsigned value)
{
	return (value << 3) | (value >> 2);
}
#if HS_IMPULSE_SUPPORT_NUON655
inline unsigned Promote_ColorComponent_6To8(unsigned value)
{
	return (value << 2) | (value >> 4);
}
#endif

/* rwb 7/10/01 - this seems wrong wrt alpha 
inline UInt16 Pixel32_To_Pixel16(UInt32 pixel)
{
	return	UInt16(	ALPHA_MASK_16 |
					((pixel >> 9) & (0x1F << 10)) |
					((pixel >> 6) & (0x1F << 5)) |
					((pixel >> 3) & (0x1F << 0)));
}
*/
inline UInt16 Pixel32_To_Pixel16(UInt32 pixel)
{
#if HS_IMPULSE_SUPPORT_NUON655
	return	UInt16(	
					((pixel >> 9) & (0x3F << 10)) |
#else
	unsigned	a = pixel & 0xFF000000;
	return	UInt16(	((a==0xFF000000) ? ALPHA_MASK_16 : 0) |
					((pixel >> 9) & (0x1F << 10)) |
#endif
					((pixel >> 6) & (0x1F << 5)) |
					((pixel >> 3) & (0x1F << 0)));
}

inline UInt32 Pixel16_To_Pixel32(UInt16 pixel)
{
	unsigned	a = (pixel & ALPHA_MASK_16) ? 0xFF : 0;
#if HS_IMPULSE_SUPPORT_NUON655
	unsigned	r = Promote_ColorComponent_6To8(Get_Y_16(pixel));
#else
	unsigned	r = Promote_ColorComponent_5To8(Get_Red_16(pixel));
#endif
	unsigned	g = Promote_ColorComponent_5To8(Get_Green_16(pixel));
	unsigned	b = Promote_ColorComponent_5To8(Get_Blue_16(pixel));
	
	return SET_ARGB_32(a, r, g, b);
}

inline UInt16 SET_RGB_16(int r, int g, int b)
{
#if HS_IMPULSE_SUPPORT_NUON655
	return Set_Red_16(r) | Set_Green_16(g) | Set_Blue_16(b);
#else
	return ALPHA_MASK_16 | Set_Red_16(r) | Set_Green_16(g) | Set_Blue_16(b);
#endif
}

inline const hsColor32* READPIXEL32(UInt32 x, UInt32 y, UInt32 rowBytes, const void* image)
{
	return (hsColor32*)((char*)image + y * rowBytes + (x << 2));
}

//
//	These are for the alpha value stored in a color. It must be converted from 0..255 to 0..256 before
//	using the multiply and blend functions:
//
//	unsigned alpha256 = Alpha255To256(color.a);

#define Alpha255To256(a)			(unsigned(a) + 1)

#if HS_BUILD_FOR_PALM
	inline asm Int16 Alpha256_Multiply(Int16 value:__D0, Int16 alpha:__D1)
	{
		MULS	D1,D0
		ASR.L	#8,D0
	}

	inline asm Int32 Alpha256_Blend(Int32 src:__D1, Int32 dst:__D0, Int16 alpha:__D2)
	{
		MOVE.L	D3,A0			// save D3

		MOVE.L	D1,D3			// D3 = src
		SUB.L	D0,D3			// D3 = src - dst
		MULS	D2,D3			// D3 *= alpha
		ASR.L	#8,D3			// D3 >>= 8
		ADD.L	D3,D0			// D0 is the answer

		MOVE.L	A0,D3			// restore D3
	}
#else
	#define Alpha256_Multiply(v, a)		(Int32(v) * Int32(a) >> 8)

	inline Int32 Alpha256_Blend(Int32 src, Int32 dst, unsigned alpha256)
	{
		return dst + Int32((src - dst) * alpha256 >> 8);
	}
#endif


inline unsigned Alpha255Merge(unsigned a, unsigned b)
{
	return a + b - Alpha256_Multiply(a, Alpha255To256(b));
}

//

inline UInt32 BlendARGB(UInt32 src, UInt32 dst, unsigned alpha)
{
	unsigned	blend = Alpha255To256(alpha);

	return SET_ARGB_32(	(UInt8)Alpha255Merge(alpha, Get_Alpha_32(dst)),
						(UInt8)Alpha256_Blend( Get_Red_32(src), Get_Red_32(dst), blend),
						(UInt8)Alpha256_Blend( Get_Green_32(src), Get_Green_32(dst), blend),
						(UInt8)Alpha256_Blend( Get_Blue_32(src), Get_Blue_32(dst), blend));
}

inline UInt16 Blend555RGB(UInt16 src, UInt16 dst, unsigned alpha256)
{
#if HS_IMPULSE_SUPPORT_NUON655
	return SET_RGB_16(Alpha256_Blend( Get_Y_16(src), Get_Y_16(dst), alpha256 ),
#else
	return SET_RGB_16(Alpha256_Blend( Get_Red_16(src), Get_Red_16(dst), alpha256 ),
#endif
					Alpha256_Blend( Get_Green_16(src), Get_Green_16(dst), alpha256 ),
					Alpha256_Blend( Get_Blue_16(src), Get_Blue_16(dst), alpha256 ));
}

DEBUG_INLINE UInt32 Blend32(UInt32 s, UInt32 d, int oneMinusA, UInt32 FF00FF, UInt32 FF00FF00)
{
	UInt32	t1 = (((d & FF00FF) * oneMinusA) & FF00FF00) >> 8;
	UInt32	t2 = (((d >> 8) & FF00FF) * oneMinusA) & FF00FF00;
	
	return s + (t1 | t2);
}

DEBUG_INLINE UInt32 Blend32(UInt32 s, UInt32 d, int oneMinusA)
{
	UInt32	t1 = (((d & 0xFF00FF) * oneMinusA) & 0xFF00FF00) >> 8;
	UInt32	t2 = (((d >> 8) & 0xFF00FF) * oneMinusA) & 0xFF00FF00;
	
	return s + (t1 | t2);
}

extern const UInt32 gFF00FF;	// 0xFF00FF

//

//	0 <= blend <= hsFixed1
//	-32768 <= src, dst <= 32767
inline int Fixed_Blend(int src, int dst, hsFixed blend)
{
	return dst + hsFixedToInt((src - dst) * blend);
}

#endif
