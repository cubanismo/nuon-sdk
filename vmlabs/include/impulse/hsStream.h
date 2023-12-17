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

#ifndef hsStream_Defined
#define hsStream_Defined

#include "hsScalar.h"

class hsInputStream {
protected:
	UInt32			fBytesRead;
public:
					hsInputStream() : fBytesRead(0) {}
	virtual			~hsInputStream();

	UInt32			GetBytesRead() const { return fBytesRead; }

	virtual hsBool	AtEnd();
	virtual void	Read(UInt32 byteCount, void * buffer) = 0;
	virtual void	Skip(UInt32 deltaByteCount) = 0;
	virtual void	Rewind() = 0;
	
	virtual UInt32	GetEOF();
	virtual void	CopyToMem(void* mem);
	
	hsBool			ReadBool();
	void			ReadBool(int count, hsBool values[]);
	UInt8			ReadByte();
	
	/* The swap functions read a network byte-order integer (they only
	   swap if you're on a little-endian machine, such as an x86. */
	UInt16			ReadSwap16();
	void			ReadSwap16(int count, UInt16 values[]);
	UInt32			ReadSwap32();
	void 			ReadSwap32(int count, UInt32 values[]);
	
	void*			ReadAddr();
	UInt32			ReadSwapAtom(UInt32* size);
	UInt8			ReadString(char string[]);
#if HS_CAN_USE_FLOAT
	float			ReadSwapFloat();
	void			ReadSwapFloat(int count, float values[]);
#endif

#if HS_SCALAR_IS_FIXED
	hsFixed			ReadSwapScalar() { return (hsFixed)this->ReadSwap32(); }
	void			ReadSwapScalar(int count, hsFixed values[])
					{
						this->ReadSwap32(count, (UInt32*)values);
					}
#else
	float			ReadSwapScalar();
	void			ReadSwapScalar(int count, float values[]);
#endif
};

class hsOutputStream {
public:
					hsOutputStream() {}
	virtual			~hsOutputStream();

	virtual void	Write(UInt32 byteCount, const void* buffer) = 0;
	void			WriteBool(hsBool value);
	void			WriteBool(int count, const hsBool values[]);
	void			WriteByte(UInt8 value);
	
	/* The swap functions read a network byte-order integer (they only
	   swap if you're on a little-endian machine, such as an x86. */
	void			WriteSwap16(UInt16 value);
	void			WriteSwap16(int count, const UInt16 values[]);
	void			WriteSwap32(UInt32 value);
	void 			WriteSwap32(int count, const  UInt32 values[]);
	
	void			WriteAddr(void* addr);
	void			WriteSwapAtom(UInt32 tag, UInt32 size);
	void			WriteString(const char string[]);

#if HS_CAN_USE_FLOAT
	void			WriteSwapFloat(float value);
	void			WriteSwapFloat(int count, const float values[]);
#endif

#if HS_SCALAR_IS_FIXED
	void			WriteSwapScalar(hsFixed value) { this->WriteSwap32((UInt32)value); }
	void			WriteSwapScalar(int count, const hsFixed values[])
					{
						this->WriteSwap32(count, (UInt32*)values);
					}
#else
	void			WriteSwapScalar(float value);
	void			WriteSwapScalar(int count, const float values[]);
#endif
};

class hsIOStream : public hsInputStream, public hsOutputStream {
};

class hsNullStream : public hsOutputStream {
protected:
	UInt32			fBytesWritten;
public:
	hsNullStream() : fBytesWritten(0) {}
	virtual void	Write(UInt32 byteCount, const void* buffer);

	UInt32			GetBytesWritten() const { return fBytesWritten; }
};

#endif
