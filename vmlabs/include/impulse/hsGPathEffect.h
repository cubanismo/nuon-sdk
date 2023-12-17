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

#ifndef hsGPathEffect_DEFINED
#define hsGPathEffect_DEFINED

#include "hsGStdSizeable.h"
#include "hsPath.h"
#include "hsStream.h"

class hsGAttribute;

/** Clients may modify the geometry at draw time by providing a
	subclass of hsGPathEffect. This object is passed the original
	geometry, and may return a new one.

	This class is reference counted. */
class hsGPathEffect : public hsGStdSizeable {
public:
	class Record {
		void		operator=(const Record& src);	// undefined
	public:
		UInt32		fFlags;
		hsScalar	fWidth;
		hsPath*		fPath;

		void		Dummy() {}	// so gcc won't give a warning
	};

					hsGPathEffect(hsScalar stdSize) : hsGStdSizeable(stdSize) {}
					hsGPathEffect(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0)
								: hsGStdSizeable(reg, stream, textSize) {}

	virtual hsBool	Filter(const hsGPathEffect::Record* input, hsGPathEffect::Record* output) const = 0;
};

class hsGPathEffectHandler {
	UInt32			fSaveFlags;
	hsScalar		fSaveWidth;
	hsGPathEffect*	fEffect;
	hsGAttribute*	fAttr;
	hsPath			fOutputPath;

	hsBool		InvokeEffect(const hsPath* inputPath);
public:
				hsGPathEffectHandler(const hsGAttribute* attr);
				~hsGPathEffectHandler();

	void		Restore();

	hsBool		HandleLine(const hsPoint* start, const hsPoint* stop);
	hsBool		HandleRect(const hsRect* src);
	hsBool		HandlePath(const hsPath* src);

	hsPath*		GetOutputPath() { return &fOutputPath; }
};

#endif

