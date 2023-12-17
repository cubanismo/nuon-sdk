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

#ifndef hsFileStream_DEFINED
#define hsFileStream_DEFINED

#include "hsStream.h"

class hsFileStream: public hsIOStream {	
	UInt32			fRef;
public:
					hsFileStream();
	virtual			~hsFileStream();

	virtual hsBool	AtEnd();
	virtual void	Read(UInt32 byteCount, void* buffer);
	virtual void	Write(UInt32 byteCount, const void* buffer);
	virtual void	Skip(UInt32 deltaByteCount);
	virtual void	Rewind();

	virtual UInt32	GetFileRef();
	virtual void	SetFileRef(UInt32 refNum);
};

#if HS_HAS_STDFILE
	class hsUNIXStream: public hsIOStream {	
		FILE*			fRef;
	public:
		virtual hsBool	AtEnd();
		virtual void	Read(UInt32 byteCount, void* buffer);
		virtual void	Write(UInt32 byteCount, const void* buffer);
		virtual void	Skip(UInt32 deltaByteCount);
		virtual void	Rewind();

		FILE*			GetFILE() { return fRef; }
		void			SetFILE(FILE* file) { fRef = file; }
	};
#endif

#endif
