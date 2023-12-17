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

#ifndef hsPrintf_DEFINED
#define hsPrintf_DEFINED

#include "hsStream.h"
#include "hsMemory.h"
#include "hsGColor.h"

class hsPrintf {
public:
	virtual hsPrintf& put(Int32 n, const char s[]) = 0;
	
	hsPrintf&	puts(const char str[]);
	hsPrintf&	put_space();
	hsPrintf&	put_newline();
	hsPrintf&	put_char(char value);
	hsPrintf&	put_dec(Int32 value);
	hsPrintf&	put_udec(UInt32 value);
	hsPrintf&	put_hex(UInt32 value);
	hsPrintf&	put_hexbyte(UInt8 value);
	hsPrintf&	put_hexnib(unsigned value);	// just the low 4-bits
	hsPrintf&	put_scalar(hsScalar value);
	
	hsPrintf&	put_color_svg(const hsGColor* color);
};

class hsStreamPrintf : public hsPrintf {
	hsOutputStream*		fStream;
public:
						hsStreamPrintf(hsOutputStream* stream);
	virtual				~hsStreamPrintf();

	hsOutputStream*		GetStream() const { return fStream; }

	//	Overrides

	virtual hsPrintf&	put(Int32 n, const char s[]);
};


class hsRAMPrintf : public hsPrintf {
	enum { kDefaultChunkSize = 1024 };
	hsAppender			fAppender;
public:
						hsRAMPrintf(UInt32 chunkSize = kDefaultChunkSize);
	virtual 			~hsRAMPrintf();

	void				Reset();
	UInt32				CopyToMem(void* buffer);

	//	Overrides

	virtual hsPrintf&	put(Int32 n, const char s[]);
};

/*
 *	This guy always appends a 0 at the end, making it a valid C string
 */
class hsStringPrintf : public hsPrintf {
	char*	fStart;
	char*	fCurr;
	char*	fStop;
public:
	hsStringPrintf();
	hsStringPrintf(char buffer[], int maxLen);
	
	void	Reset(char buffer[], int maxLen);
	void	Rewind();

	//	Overrides

	virtual hsPrintf&	put(Int32 n, const char s[]);
};

#endif
