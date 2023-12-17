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

#ifndef hsGGradientShader_DEFINED
#define hsGGradientShader_DEFINED

#include "hsGShader.h"
#include "hsTemplates.h"

class hsGGradientShader : public hsGShader {
protected:
	int						fColorCount;
	hsTArray<hsGColor>		fColor;
	hsTArray<hsScalar>		fInterval;
	TileMode				fTileMode;

	//	Should be set in SetContext(), used by IsOpaque()
	hsTArray<hsColor32>	fARGB;
public:
					hsGGradientShader(hsScalar stdSize = 0);
					hsGGradientShader(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);

	int				GetGradient(hsGColor colors[], hsScalar intervals[], TileMode* repeat);
	virtual void	SetGradient(int count, const hsGColor colors[],
							const hsScalar intervals[], TileMode repeat);

	//	Overridden from hsGShader
	virtual hsBool		IsOpaque();
	virtual void		Write(hsOutputStream* stream, UInt32 flags = 0);	
};

class hsGLinearGradientShader : public hsGGradientShader {  
protected:
	//	User Data
	hsPoint2				fPoint[2];

	//	Cache built in SetContext()
	hsMatrix33			fInverse;
	hsMatrixType			fInverseType;
	hsTArray<hsFixed>		fPos;
	hsTArray<hsFixed>		fPosDx;
	hsTArray<hsFixed>		fPosScale;
public:
 					hsGLinearGradientShader(hsScalar stdSize = 0);
 					hsGLinearGradientShader(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);

	void			GetPoints(hsPoint2* start, hsPoint2* stop) const;
	void			SetPoints(const hsPoint2* start, const hsPoint2* stop);

	//	Overrides
	virtual void	SetContext(const hsGBitmap* device, const hsGAttribute* attr, const hsMatrix33* matrix);
	virtual void	ShadeSpan(int y, int x, int count, hsColor32 src[]);

	virtual CreateProc	GetCreateProc();
	virtual const char*	GetName();
	virtual void	Write(hsOutputStream* stream, UInt32 flags = 0);
	virtual hsBool	WriteSVG(hsXMLWriter* xml, const char id[]);

	static const char*	ClassName();
};

///
class hsGRadialGradientShader : public hsGGradientShader {
protected:
	//	User Data
	hsPoint2			fCenter;
	hsScalar			fRadius;

	//	Cache built in SetContext()
	hsMatrix33			fInverse;
	hsMatrixType			fInverseType;
	hsTArray<hsGColor>		fContextColor;
	hsTArray<hsFixed>		fPos;
	hsTArray<hsFixed>		fPosScale;
	friend class hsGRadialGradientShaderHelper;
public:
 					hsGRadialGradientShader(hsScalar stdSize = 0);
 					hsGRadialGradientShader(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);
 
	hsScalar		GetRadial(hsPoint2* center) const;
	void			SetRadial(const hsPoint2* center, hsScalar radius);
	
	//	Overrides
	virtual void	SetContext(const hsGBitmap* device, const hsGAttribute* attr, const hsMatrix33* matrix);
	virtual void	ShadeSpan(int y, int x, int count, hsColor32 src[]);
	
	virtual CreateProc	GetCreateProc();
	virtual const char*	GetName();
	virtual void	Write(hsOutputStream* stream, UInt32 flags = 0);	
	virtual hsBool	WriteSVG(hsXMLWriter* xml, const char id[]);
	
	static const char*	ClassName();
};

#endif
