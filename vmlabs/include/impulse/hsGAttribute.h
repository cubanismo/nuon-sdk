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

#ifndef hsGAttribute_DEFINED
#define hsGAttribute_DEFINED

#include "hsRefCnt.h"
#include "hsGColor.h"
#include "hsGFont.h"
#include "hsGMask.h"

//	This is needed for the internal fields of the attribute

#include "hsGFontScaler.h"

class hsGShader;
class hsGXferMode;
class hsGMaskFilter;
class hsGPathEffect;
class hsGRasterizer;
class hsGImageFilter;
class hsGRasterBlitter;

namespace AlphaMask {
	class RawDraw;
}

#define kDropOutControl_hsGAttribute	0x80000000

/** Encapsulates rendering properties:
	color, text attributes, and path and paint effects.

	The hsGAttribute object is derived from hsRefCnt. This allows the
	attribute object to be safely referenced by multiple objects.

	All of the \c Set... methods return a boolean value indicating
	whether the method actually changed the setting. If the specified
	value is the same as the one already in the attribute, the method
	returns \c false, else the setting is changed and the method
	returns \c true.  */
class hsGAttribute : public hsRefCnt {
public:
					hsGAttribute(UInt32 flags = 0);
					hsGAttribute(const hsGAttribute&);
					~hsGAttribute();

	hsGAttribute&	operator=(const hsGAttribute& src);

	/** @name Attribute Flags */
	//@{
	/** Attribute flags specify various options for modifying a
        drawing. The default setting is a value of \c 0. */
	enum {
		kAntiAlias			= 0x0001, //!< Anti-alias edges if set, else hard edges
		/// Frame the geometry if set, else fill
		kFrame				= 0x0002,
		/// Filter bitmaps if set, else point-sample bitmaps
		kFilterBitmap		= 0x0004,
		/// Square pen if set, else centered pen
		kSquarePen			= 0x0008,
		/// Kern text if set, else ignore any kerning data in font
		kKernText			= 0x0010,
		/// Subpixel position text if set, else integral placement (faster)
		kSubPixelText		= 0x0020,
		/// Use linear metrics if set, else hinted metrics
		kLinearMetricsText	= 0x0040,
		/// else hinted outlines
		kLinearContourText	= 0x0080,
		kLCDText			= 0x1000
#if HS_BUILD_FOR_NUON
		,kNuonCacheGlyph	= 0x10000
#endif
	};
	UInt32			GetFlags() const { return fFlags; }
	hsBool			SetFlags(UInt32 flags);
	/** Changing the value of kFrame may be done quite often. To
        accommodate this, two helper methods are available. */
	/// Clear the ::kFrame bit
	hsBool			SetFillMode()
					{
						return this->SetFlags(fFlags & ~hsGAttribute::kFrame);
					}
	/// Set the ::kFrame bit
	hsBool			SetFrameMode()
					{
						return this->SetFlags(fFlags | hsGAttribute::kFrame);
					}
	//@}

	/** @name Image Filter */
	//@{
	hsGImageFilter*	GetImageFilter() const { return fImageFilter; }
	hsBool			SetImageFilter(hsGImageFilter* imageFilter);
	//@}

	/** @name Attribute color
		
		There is a single color in the attribute, and it applies to
		all primitives (line, rectangle, path, text) except for
		bitmaps, which only respect the color's alpha value. */
	//@{
	const hsGColor*	GetColor() const { return &fColor; }
	void			GetColor(hsGColor* color) const;
	hsBool			SetColor(const hsGColor* color);
	hsBool			SetARGB(hsGColorValue alpha, hsGColorValue red,
						hsGColorValue green, hsGColorValue blue);
	//@}

	void	SetColorIndex(int index);	// < 0 means use actual color
	int		GetColorIndex() const;		// < 0 means use actual color

	/** @name Other color-related objects
		
	   Along with the color, two other objects can affect the color of
	   the resulting image. hsGShader is a client-specified object
	   that supplies per-pixel colors. It is called for each scanline
	   of the primitive being drawn. hsGXferMode also is called per
	   scanline, and is responsible for compositing the source colors
	   onto the device. Each of these objects are optional, and may be
	   \c null.

	   Subclasses of hsGShader and hsGXferMode are derived from
	   hsRefCnt, and are therefore reference counted. ::SetShader()
	   and ::SetXferMode() automatically call hsRefCnt::Ref() on the
	   new object (if it is not \c null), and call hsRefCnt::UnRef()
	   on the previous object (if it is not \c nul). ::GetShader() and
	   ::GetXferMode() do not change the object's reference count.
	   
	   Example:
	   \include shader-refcount */
	//@{
	//
	hsGShader*		GetShader() const { return fShader; }
	//
	hsGXferMode*	GetXferMode() const { return fXferMode; }
	//
	hsBool			SetShader(hsGShader* shader);
	//
	hsBool			SetXferMode(hsGXferMode* xferMode);
	//@}

	/** @name Mask Filter
		
		For special effects such as blurring or embossing, the client
		may provide a subclass of hsGMaskFilter. This object, when
		present, is called to modify the alpha mask of a drawing
		primitive. Like hsGShader and hsGXferMode, the hsGMaskFilter
		is reference counted. */
	//@{
	hsGMaskFilter*	GetMaskFilter() const { return fMaskFilter; }
	hsBool			SetMaskFilter(hsGMaskFilter* filter);
	//@}

	/** @name Frame Attributes
		
		Geometric primitives can be draw filled or framed
		(stroked). If they are framed (::kFrame bit is set), then the
		following fields apply.

		The interpretation for \a frameSize, ::CapType, ::JoinType and
		\a miterLimit is the same as in PostScript. */
	//@{
	/// The interpretation for ::CapType is the same as in PostScript.
	enum CapType {
		kButtCap,
		kRoundCap,
		kSquareCap
	};
	/// The interpretation for ::JoinType is the same as in PostScript.
	enum JoinType {
		kMiterJoin,
		kRoundJoin,
		kBluntJoin
	};
	hsScalar		GetFrameSize() const { return fFrameSize; }
	hsScalar		GetFrameSize(const hsMatrix* matrix) const;
	CapType			GetCapType() const { return (CapType)fCapType; }
	JoinType		GetJoinType() const { return (JoinType)fJoinType; }
	hsScalar		GetMiterLimit() const { return fMiterLimit; }
	hsScalar		GetMinWidth() const { return fMinWidth; }

	hsBool			SetFrameSize(hsScalar frameSize);
	hsBool			SetCapType(CapType captype);
	hsBool			SetJoinType(JoinType jointype);
	hsBool			SetMiterLimit(hsScalar miterLimit);
	/** ::SetMinWidth allows the client to set the minimum size (in
		pixels) for a framed geometry. This is used to keep very thin
		lines from disappearing when they are scaled down. If \a
		minWidth is set to 0 (its default), no minimum thickness is
		enforced. */
	hsBool			SetMinWidth(hsScalar minWidth);
	//@}

	/** @name Path Effects
		
		Clients may modify the geometry at draw time by providing a
		subclass of hsGPathEffect. This object is passed the
		original geometry, and may return a new one. This class is
		reference counted. */
	//@{
	hsGPathEffect*	GetPathEffect() const { return fPathEffect; }
	hsBool			SetPathEffect(hsGPathEffect* pathEffect);
	//@}

	/** @name Rasterizer Override
		
		Clients may also override the scan conversion process by
		providing a subclass of hsGRasterizer. This object is
		passed a path, and returns an alpha mask. This object is
		reference counted. */
	//@{
	hsGRasterizer*	GetRasterizer()	const { return fRasterizer; }
	hsBool			SetRasterizer(hsGRasterizer* rasterizer);
	//@}

	/** @name Text attributes
		
		Attributes for text include font, size, encoding, algorithmic styles,
		and spacing.

		Fonts are identified by a 32-bit font ID. These IDs are
		obtained using the hsGFontList methods. A value of 0 specifies
		that the default font should be used.
		
		The text size specifies the size of the text (to be modified
		by the matrix and optional hsGTextFace). Note that the size is an
		::hsScalar, and may be a fractional value (e.g. 12.75).

		These next two attributes (hsGTextFace and hsGTextSpacing) are
		optional structs. The \c Get methods return a boolean
		indicating if the attribute has the value. To clear the value,
		pass \c null to the \c Set method.  */
	//@{
	hsGFontID		GetFontID() const { return fFontID; }
	hsBool			SetFontID(hsGFontID fontID);
	hsScalar		GetTextSize() const { return fTextSize; }
	hsBool			SetTextSize(hsScalar textSize);
	/** The text encoding identifies what kind of character codes are
		passed to drawing and measuring methods. */
	enum TextEncoding {
		/// ASCII specifies that all character codes are 1-byte.
		kAsciiEncoding,
		/// UTF8 specifies that the	characters require a variable number of bytes.
		kUTF8Encoding,
		/// Unicode	specifies that each character is 16-bits.
		kUnicodeEncoding
	};
	TextEncoding	GetTextEncoding() const { return (TextEncoding)fTextEncoding; }
	hsBool			SetTextEncoding(TextEncoding encoding);
	const hsGTextFace* GetTextFace() const { return fTextFace; }
	/** hsGTextFace allows the client to modify the size and shape of
		the text.

		The default setting for attribute is no hsGTextFace. In this
		case, ::GetTextFace() returns \c false, and does not modify the
		face parameter. To reset the attribute to its default state,
		pass \c null to ::SetTextFace().

	 */
	hsBool			SetTextFace(const hsGTextFace* face);
	hsBool			GetTextFace(hsGTextFace* face) const;
	/** ::hsGTextSpacing allows the client to override the character
		spacing and alignment when drawn using ::DrawGlyphs.

		The default setting for an attribute is no hsGTextSpacing. In
		this ::GetTextSpacing() returns \c null, and does not modify
		the face parameter. To reset the attribute to its default
		state, pass \c null to ::SetTextSpacing().

	*/
	const hsGTextSpacing* GetTextSpacing() const { return fTextSpacing; }
	hsBool			GetTextSpacing(hsGTextSpacing* spacing) const;
	hsBool			SetTextSpacing(const hsGTextSpacing* spacing);
	//@}

	/** @name Text Measurement Methods */
	//@{
	/** ::MeasureGlyphs returns the width of a string, and returns the
		line height in two optional parameters. The character codes in
		the text parameter are interpreted based on the current
		::TextEncoding.

		Ascent and descent are points, so that ::MeasureText can
		return information about the angle of the text as well. The
		\f$y\f$ component of ascent and descent indicates the line
		height (above and below the baseline), and the \f$x\f$
		component reflects the italic angle (if any). For normal
		upright text, the \f$x\f$ component is 0.  */
	hsScalar		MeasureText(UInt32 length, const void* text, hsVector* ascent, hsVector* descent) const;
	/** ::GetTextWidths returns an array of widths for each character
		in a string. The method returns the number of characters
		processed, base on the current TextEncoding. For
		::kAsciiEncoding, the return value is \var length. For
		::kUnicodeEncoding, the return value is
		\f$\textit{length}/2$. For ::kUTF8Encoding, the value depends
		on the actual characters in the text. */
	UInt32			GetTextWidths(UInt32 length, const void* text, hsScalar widths[]) const;
	hsBool			GetTextUnderline(UInt32 length, const void* text, hsRect* bounds) const;
	/** ::GetTextPath converts the text into a path containing the
		outlines of all the characters.

		::GetTextPath returns the path scaled by the text-size (and
		any ::TextFace scaling), and filters it through the
		attribute's hsGPathEffect (if any).  */
	void			GetTextPath(UInt32 length, const void* text, class hsPath* path, hsScalar maxAdv = -1) const;

	int				TextLengthToGlyphCount(UInt32 length, const void* text) const;
	UInt32			GlyphCountToTextLength(int count, UInt32 length, const void* text) const;
	//@}

	// Streaming
	/// \internal
					hsGAttribute(class hsRegistry* reg, hsInputStream* stream);
	/// \internal
	void			Write(hsOutputStream* stream, UInt32 flags = 0) const;

	//	Internal methods
	/// \internal
	virtual hsGRasterBlitter*	ChooseColorBlitter(const hsGBitmap* device, hsGMask::Type maskType,
												   const hsMatrix* matrix) const;
	/// \internal
	virtual hsGRasterBlitter*	ChooseBitmapBlitter(const hsGBitmap* device, hsBool doAntiAlias,
													const hsGBitmap* source, const hsMatrix* matrix) const;

	/// \internal
	UInt32			GetScanStrokerFlags() const;
	/// \internal
	void			SetScanStrokerFlags(UInt32 strokerFlags);
	/// \internal
	static UInt32	ComputeScanStrokerFlags(CapType ct, JoinType jt);

	/// \internal
	class hsGTextContext*	GetTextContext(const hsMatrix* matrix) const;

protected:
	UInt32			fFlags;
	hsGColor		fColor;
	hsScalar		fFrameSize, fMiterLimit, fMinWidth, fTextSize;
	UInt8			fCapType, fJoinType, fTextEncoding, fPad;
	hsGFontID		fFontID;
	hsGTextFace*	fTextFace;
	hsGTextSpacing* fTextSpacing;
	hsGShader*		fShader;
	hsGXferMode*	fXferMode;
	hsGMaskFilter*	fMaskFilter;
	hsGPathEffect*	fPathEffect;
	hsGRasterizer*	fRasterizer;
	hsGImageFilter*	fImageFilter;

private:
	enum {
		kUseIndexForColor	= 0x2000,
		kValidFlags			= 0x20FF
	};

	//	Cache the last blitter

	mutable hsGRasterBlitter*	fCachedColorBlitter;

	//	Cached fields for text
	//
	mutable hsGFontID					fRealFontID;
	mutable hsGFontScaler::CreateContextProc fScalerProc;
	mutable hsDescriptor				fStrikeDesc;
	mutable hsMatrix					fStrikeMatrix;
	mutable hsFixedPoint				fAdvanceOffset;

	hsDescriptor	MakeStrikeDesc(const hsMatrix* matrix, hsFixedPoint* advance) const;

	//	These are just for RawDraw::DrawAsciiText	

	mutable hsBool32		fSimpleDescDirty;
	mutable hsDescriptor	fSimpleDesc;

	void					BuildSimpleStrike() const;
#if !(HS_BUILD_FOR_UNIX || HS_BUILD_FOR_NUON)
	inline
#endif
	class hsGGlyphStrike*	RefSimpleStrike() const;

	friend class AlphaMask::RawDraw;
};

//

class TmpFrameAttr {
	hsGAttribute*	fAttr;
	UInt32			fOldFlags;
public:
	TmpFrameAttr(hsGAttribute* attr);
	~TmpFrameAttr();
};

class TmpFillAttr {
	hsGAttribute*	fAttr;
	UInt32			fOldFlags;
public:
	TmpFillAttr(hsGAttribute* attr);
	~TmpFillAttr();
};

#endif
