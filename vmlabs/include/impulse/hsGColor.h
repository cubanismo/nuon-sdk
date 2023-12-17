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

#ifndef hsGColorDefined
#define hsGColorDefined

#include "hsStream.h"

//	If this is defined to be 1 then
//		0x0 is black
//		0xF is white
//	else
//		0x0 is white
//		0xF is black
#define HS_IMPULSE_GRAY_ZERO_IS_BLACK		0

/// 0..FFFF
typedef UInt16	hsGColorValue;

/** Color is specified in 16-bit component ARGB, represented by
	hsGColor. For alpha, 0 specifies transparent, and \c 0xFFFF
	specifies opaque. */
struct hsGColor {
	///
	hsGColorValue	fA;
	hsGColorValue	fR;
	hsGColorValue	fG;
	hsGColorValue	fB;
	
	friend int operator==(const hsGColor& a, const hsGColor& b)
		{
			return	a.fA == b.fA &&
					a.fR == b.fR &&
					a.fG == b.fG &&
					a.fB == b.fB;
		}
	friend int operator!=(const hsGColor& a, const hsGColor& b)
		{
			return !(a == b);
		}

	hsGColor* SetARGB(hsGColorValue alpha, hsGColorValue red, hsGColorValue green, hsGColorValue blue)
		{
			fA = alpha;
			fR = red; fG = green; fB = blue;
			return this;
		}
	hsGColor* Set(const hsColor32* c)
	{
		fA = (c->a << 8) | c->a;
		fR = (c->r << 8) | c->r;
		fG = (c->g << 8) | c->g;
		fB = (c->b << 8) | c->b;

		return this;
	}
		
	hsColor32* ToColor32(hsColor32* c) const
	{
		c->Set(	UInt8(fA >> 8), UInt8(fR >> 8), UInt8(fG >> 8), UInt8(fB >> 8));
		return c;
	}

	void Read(hsInputStream* stream)
	{
		stream->ReadSwap16(4, (UInt16*)this);
	}
	void Write(hsOutputStream* stream) const
	{
		stream->WriteSwap16(4, (const UInt16*)this);
	}

	static UInt8 ColorValueToByte(hsGColorValue value)
		{
			return UInt8(value >> 8);
		}
	static hsGColorValue ByteToColorValue(UInt8 byte)
		{
			return hsGColorValue(((byte) << 8) | byte);
		}

	static unsigned ColorValueTo5(hsGColorValue value)
		{
			return unsigned(value >> 11);
		}
#if HS_IMPULSE_SUPPORT_NUON655
	static unsigned ColorValueTo6(hsGColorValue value)
		{
			return unsigned(value >> 10);
		}
#endif
	static unsigned FiveToColorValue(unsigned value)
		{
			return (value << 11) | (value << 6) | (value << 1) | (value >> 4);
		}
};

//

#if HS_IMPULSE_SUPPORT_GRAY4

typedef UInt8	hsGAlphaGray44;	// (Alpha << 4) | Gray

#define hsGAlphaGray44_AlphaMask		0xF0
#define hsGAlphaGray44_AlphaShift		4
#define hsGAlphaGray44_GrayMask		0x0F
#define hsGAlphaGray44_GrayShift		0

inline unsigned hsGAlphaGray44_GetAlpha4(hsGAlphaGray44 ag)
{
	return ag >> 4;
}

inline unsigned hsGAlphaGray44_GetGray4(hsGAlphaGray44 ag)
{
	return ag & 0xF;
}

inline unsigned hsGAlphaGray44_Set(unsigned alpha, unsigned gray)
{
	hsAssert(alpha < 16, "bad alpha");
	hsAssert(gray < 16, "bad gray");
	
	return (alpha << 4) | gray;
}

inline unsigned RGBToGray4(unsigned red8, unsigned green8, unsigned blue8)
{
	// 3*red + 3*green + 2*blue
	unsigned rg8 = red8 + green8;

#if HS_IMPULSE_GRAY_ZERO_IS_BLACK
	return (rg8 + blue8 << 1) + rg8 >> 7;
#else
	return 0xF - ((((rg8 + blue8) << 1) + rg8) >> 7);
#endif
}

inline hsGAlphaGray44 ARGBToAlphaGray44(unsigned alpha8, unsigned red8, unsigned green8, unsigned blue8)
{
	return hsGAlphaGray44_Set(alpha8 >> 4, RGBToGray4(red8, green8, blue8));
}

inline unsigned hsGColorToGray4(const hsGColor* color)
{
	return RGBToGray4(	hsGColor::ColorValueToByte(color->fR),
						hsGColor::ColorValueToByte(color->fG),
						hsGColor::ColorValueToByte(color->fB));
}

inline unsigned hsGColorToAlphaGray44(const hsGColor* color)
{
	return ARGBToAlphaGray44(	hsGColor::ColorValueToByte(color->fA),
								hsGColor::ColorValueToByte(color->fR),
								hsGColor::ColorValueToByte(color->fG),
								hsGColor::ColorValueToByte(color->fB));
}

class hsGGray4Globals {
	static const UInt32 gNibbleMask[];
	static const UInt32 gRepeat_4_32[];
	static const UInt32 gLeftNibbleMask[];
public:
	static UInt32 Repeat32(unsigned gray4)
	{
		hsAssert(gray4 < 16, "bad gray4");
		return gRepeat_4_32[gray4];
	}

	static UInt32 NibbleMask(unsigned x)
	{
		hsAssert(x < 8, "bad x");
		return gNibbleMask[x];
	}

	static UInt32 LeftMask4(unsigned x)
	{
		return gLeftNibbleMask[x & 7];
	}

	static UInt32 RightMask4(unsigned x)
	{
		return ~LeftMask4(x);
	}
};

#endif	// HS_IMPULSE_SUPPORT_GRAY4

/*@
@page hsgcolor.html

@typedef hsGColorValue	UInt16
hsGColorValue specifies a component of a color. It ranges from 0 to 65535 (0xFFFF). In RGB, color values (0,0,0) represent black,
and (0xFFFF,0xFFFF,0xFFFF) represent white.

@struct hsGColor
This struct is used to define colors. Currently only RGB colors are supported. Each color is 
a 16 bit unsigned integer value. The alpha component is the opacity for the color. When alpha 
is 1 (0xffff) the color is completely opaque.
@field hsGColorValue fA the alpha component
@field hsGColorValue fR the red component
@field hsGColorValue fB the blue component
@field hsGColorValue fG the green component
@method SetRGB sets the RGB components of the color. Alpha is untouched.
@method SetARGB sets the RGB and alpha components
@method EqualARGB returns true if two color are equal
@endclass

@endpage
*/
#endif

