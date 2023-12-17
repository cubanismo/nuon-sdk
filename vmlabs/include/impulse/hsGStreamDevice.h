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

#ifndef hsGStreamDevice_DEFINED
#define hsGStreamDevice_DEFINED

#include "hsGDevice.h"
#include "hsGAttribute.h"
#include "hsRegistry.h"
#include "hsMemory.h"

/** This device does not render anything, but instead records all of
    the drawing, matrix and clip calls into the stream object the
    caller provides (see hsStream). The resulting stream is completely
    self-contained, and can be copied or written to disk. To replay
    the drawing, simply pass the stream to a hsGStreamPlayback object.

	\sa hsGStreamPlayback */
class hsGStreamDevice : public hsGDevice {
	hsGAttribute		fAttr;
	class hsGStdSizeableMem*	fStdMem;
protected:
	class hsOutputStream*	fStream;
	class hsGFontDict*	fFontDict;
	hsStringStorage		fNames;

	void			FlushFrameState(const hsGAttribute* attr);
	void			FlushTextState(const hsGAttribute* attr);
	void			Flush(Byte opCode, const hsGAttribute* attr);
public:
					hsGStreamDevice(hsBool useFontDict);
	virtual			~hsGStreamDevice();

	virtual void	StartRecording(hsOutputStream* stream);
	virtual void	StopRecording();

//	OVERRIDES

	virtual void	Save();
	virtual void	SaveLayer(const hsRect* bounds, UInt32 flags, const hsGAttribute* attr = nil);
	virtual void	Restore();

	virtual void	Concat(const hsMatrix* matrix);
	virtual void	ClipPath(const hsPath* path, hsBool applyCTM = true);

	virtual void	DrawFull(const hsGAttribute* attr);
	virtual void	DrawLine(const hsPoint* start, const hsPoint* stop,
								const hsGAttribute* attr);
	virtual void	DrawRect(const hsRect* rect, const hsGAttribute* attr);
	virtual void	DrawPath(const hsPath* path, const hsGAttribute* attr);
	virtual void	DrawBitmap(const hsGBitmap* bitmap,
								hsScalar x, hsScalar y, const hsGAttribute* attr);
	virtual void	DrawParamText(UInt32 length, const void* text,
								hsScalar x, hsScalar y, const hsGAttribute* attr);
	virtual void	DrawPosText(UInt32 length, const void* text, const hsPoint pos[],
								const hsVector tan[], const hsGAttribute* attr);
};

#endif
