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

#ifndef hsGFontListDefined
#define hsGFontListDefined

#include "hsScalar.h"

#if HS_BUILD_FOR_WIN32
	#undef GetTextFace
#endif

class hsInputStream;
class hsOutputStream;

#define kLeft_hsGAlignment		0
#define kCenter_hsGAlignment		hsScalarHalf
#define kRight_hsGAlignment		hsScalar1

/** hsGTextSpacing allows the client to override the character spacing
	and alignment when drawn using hsGDevice::DrawGlyphs.

	\a fAlignment specifies a continuum between left (0), center (0.5)
	and right (1) alignment. If \a fAlignment \f$< 0\f$, then its
	absolute value is interpreted as a width, and the text spacing is
	automatically adjusted to fit the text within that width. If \a
	fAlignment \f$\geq 0\f$, then \a fSpaceExtra and \a fCharExtra are
	added to their respective characters. If the \a hsGTextSpacing
	field is \c nil (the default), text is drawn left-aligned.  */
struct hsGTextSpacing {
	enum {
		/// trim spaces when justified
		kTrimJustText	= 0x01	// ignore trailing spaces (only if fAlignment < 0)
	};
	UInt32	fFlags;
	/// if \a fAlignment \f$< 0\f$ then treat as width for full justified
	hsScalar	fAlignment;
	/// ignore if \a fAlignment \f$< 0\f$
	hsScalar	fSpaceExtra;
	/// ignore if \a fAlignment \f$< 0\f$
	hsScalar	fCharExtra;
	
	hsGTextSpacing() : fFlags(0), fAlignment(0), fSpaceExtra(0), fCharExtra(0)
	{
	}
	hsGTextSpacing(hsScalar alignment) : fFlags(0), fAlignment(alignment), fSpaceExtra(0), fCharExtra(0)
	{
	}

	void		Read(hsInputStream* stream);
	void		Write(hsOutputStream* stream) const;

	void		Reset()
	{
		fFlags		= 0;
		fAlignment	= 0;
		fSpaceExtra	= 0;
		fCharExtra	= 0;
	}
	
	hsBool		IsDefault() const
	{
		return fFlags == 0 && fAlignment == 0 && fSpaceExtra == 0 && fCharExtra == 0;
	}
	
	friend int	operator==(const hsGTextSpacing& a, const hsGTextSpacing& b)
	{
		return	a.fFlags == b.fFlags &&
				a.fAlignment == b.fAlignment &&
				a.fSpaceExtra == b.fSpaceExtra &&
				a.fCharExtra == b.fCharExtra;
	}
	friend int	operator!=(const hsGTextSpacing& a, const hsGTextSpacing& b)
	{
		return !(a == b);
	}
};

#define APPLY_hsGTextSpacing(spacing, advance, charCode)		\
	if ((charCode) == 32)									\
		(advance) += hsScalarToFixed((spacing)->fSpaceExtra);		\
	else													\
		(advance) += hsScalarToFixed((spacing)->fCharExtra)

#define IF_APPLY_hsGTextSpacing(spacing, advance, charCode)		\
	do { if (spacing) APPLY_hsGTextSpacing(spacing, advance, charCode); } while (false)

//

#define kNoBold_hsGTextFace				hsScalar1
#define kNoSkew_hsGTextFace				0
#define kNoXScale_hsGTextFace			hsScalar1
#define kNoXOffset_hsGTextFace			0
#define kNoOutlineWidth_hsGTextFace		0
#define kNoUnderlineThickness_hsGTextFace	0
#define kNoUnderlineOffset_hsGTextFace		0

/** hsGTextFace allows the client to modify the size and shape of the
	text. */
struct hsGTextFace {
	/** \a fBoldness specifies algorithmic emboldening. */
	hsScalar	fBoldness;
	/** \a fSkew and \a fXScale combine to create a matrix that modifies /
		the shape of the text. */
	hsScalar	fSkew;
	///
	hsScalar	fXScale;
	/** \a fXOffset adds itself to each character's advance
		width. */
	hsScalar	fXOffset;
	/** \a fOutlineWidth specifies the thickness of outline text (a value
		of 0 means normal text). */
	hsScalar	fOutlineWidth;
	/** Underline thickness and offset specify where
		to draw an underline. */
	hsScalar	fUnderlineThickness;
	///
	hsScalar	fUnderlineOffset;

				hsGTextFace() { this->Reset(); }

	void		Reset();
	void		Read(hsInputStream* stream);
	void		Write(hsOutputStream* stream) const;
	hsBool		IsDefault() const;
	
	friend int	operator==(const hsGTextFace& a, const hsGTextFace& b);
	friend int	operator!=(const hsGTextFace& a, const hsGTextFace& b)
			{
				return !(a == b);
			}
};

/** Fonts are identified by a 32-bit font ID. a font IDs is obtained
	using the hsGFontList methods, and are passed to an
	hsGAttribute. A value of 0 specifies that the default font should
	be used. */
typedef UInt32 hsGFontID;

/** hsGFontList is a class with only static methods. It manages a
	global list of fonts. Fonts are identified by a 32-bit value
	called a hsGFontID. The fontID is what you give to a style to
	select a font. The fontID uniquely identifies a font, meaning a
	particular style within a font family such as <TT>Times
	Italic</TT> or <TT>Courier Bold</TT>. Fonts are not created or
	deleted by applications, the global font list is responsible for
	managing them. To search for a font by name, use ::Find(),
	specifying the type of name you are providing. */
class hsGFontList {
public:
	/** These specify the type of name for a font. They are a required
		parameter to the ::Find() method for finding a font from
		within the global list, ::GetName() for retrieving a name from
		a font, and ::MatchName() for querying a font if it has a
		given name.  */
	enum NameID {
		/// \c Times, \c Helvetica, \c Courier, \c Symbol, etc.
		kFamilyName,
		/// \c Regular, \c Roman, \c Bold, \c Italic, \c Demi, \c Narrow, etc.
		kStyleName,
		/// <TT>Times Italic</TT>, <TT>Courier Bold</TT>, \c Helvetica, etc.
		kFullName,
		/// \c Times-Roman, \c Helvetica-Bold, etc.
		kPostScriptName,
		kNameCount,
		kAnyName = kNameCount
	};
	enum {
		kMaxNameLength = 64
	};

	/** Returns the number of available fonts. Use this to iterate
		throught the list with ::Get(index) */
	static UInt32 Count();
	/** Returns the fontID for a given index.
		Valid indices are \f$0\ldots\texttt{::Count()} - 1\f$.

		Returns the number of available fonts. Use this to iterate
		throught the list with ::Get(index) */
	static hsGFontID Get(UInt32 index);
	/** Returns the fontID for the font that matches the given name.
		Valid indices are \f$0\ldots\texttt{Count()} - 1\f$. */
	static hsGFontID Find(NameID nameID, const char name[]);
	
	static hsBool		FontExists(hsGFontID fontID);
	static hsGFontID	GetRealFontID(hsGFontID fontID);

	/** Given a fontID, it returns the length and the text (if not
		nil) for the requested name.  If the name is not found, it
		returns 0. */
	static UInt32		GetName(hsGFontID fontID, NameID nameID, char name[]);
	/// Returns true if the given fontID has the specified name.
	static hsBool		MatchName(hsGFontID fontID, NameID nameID, const char name[]);

	static hsGFontID	AddFontFile(const char name[], UInt32 format = 0);
	static hsBool		RemoveFont(hsGFontID fontID);
#if HS_BUILD_FOR_MAC
	static UInt32		AddFolderFonts(short vRefNum, long dirID);
	static hsGFontID	AddFontFSSpec(const struct FSSpec* spec);
#endif

	/** Optional method for deleting all references to fonts. Useful
		when checking for leaks.
		
		This need only be called when an app terminates, and then only
		if it wants to worry about delete all of its objects when
		looking for memory leaks. */
	static void		KillFontList();
};

#endif
