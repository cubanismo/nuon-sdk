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

#ifndef hsGStdSizeable_DEFINED
#define hsGStdSizeable_DEFINED

#include "hsRefCnt.h"
#include "hsScalar.h"

class hsInputStream;
class hsOutputStream;
class hsRegistry;

/** Class of streamable objects. Instances of classes that subclass
    hsGStdSizeable can be streamed to an hsOutputStream by a
    hsGStreamDevice, and unstreamed by a
    hsGStreamPlayback. */
class hsGStdSizeable : public hsRefCnt {
	hsScalar		fStdSize, fParamScale;
protected:
	hsScalar		GetParamScale() const { return fParamScale; }
	hsScalar		ScaleParam(hsScalar p) const { return hsScalarMul(p, fParamScale); }
public:
	enum {
		kNonPersistent	= 0x0001
	};

	///
					hsGStdSizeable(hsScalar stdSize);
					hsGStdSizeable(hsRegistry* reg, hsInputStream* stream, hsScalar textSize = 0);

	/** @name Unflattening
		For unflattening within the text system. */
	//@{
	typedef void* (*CreateProc)(hsInputStream* stream, hsScalar textSize);
	virtual CreateProc	GetCreateProc() = 0;
	//@}

	/** @name Flattening */
	//@{
	virtual const char* GetName() = 0;
	virtual void	Write(hsOutputStream* stream, UInt32 flags = 0);
	virtual UInt32	GetStreamSize(UInt32 flags = 0);
	//@}
	
	/** @name Helper utilities */
	//@{
	void			WriteStreamSize(hsOutputStream* stream, UInt32 flags = 0);
	void*			WriteToMem(void* mem, UInt32* sizePtr, hsBool doAllocate);
	//@}
};

#endif
