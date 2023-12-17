/*
 * Copyright (C) 1996-2000 all rights reserved by AlphaMask, Inc. in Boston MA 02114
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

#ifndef hsGFontT2K_DEFINED
#define hsGFontT2K_DEFINED

#include "hsGFont_Internal.h"

#if HS_BUILD_FOR_MAC
	#include <Files.h>
#endif

class hsGSfntFont : public hsGFont {
	struct hsSfntDirectory*	fDirectory;
protected:
	virtual void	ReleaseSelf();

	virtual struct hsSfntDirectory* LoadDirectory();
	virtual void	ReleaseDirectory(hsSfntDirectory* dir);
public:
					hsGSfntFont(hsGFontID fontID, UInt32 format)
						: hsGFont(fontID, format), fDirectory(nil) {}
					hsGSfntFont(UInt32 format)
						: hsGFont(format), fDirectory(nil) {}
	virtual			~hsGSfntFont();

	virtual UInt32	GetDataLength();
	virtual UInt32	GetName(hsGFontList::NameID nameID, char name[]);
	virtual hsBool	MatchName(hsGFontList::NameID nameID, const char name[]);
	
	//	These assume that AcquireAccess() has already been called
	const struct hsSfntDirectory* GetDirectory();
	UInt32			FindTableSize(UInt32 tableTag);
	UInt32			FindTableOffset(UInt32 tableTag);
	const void*		FindTable(UInt32 tableTag, void* data = nil);
	UInt16			Char2Glyph(UInt16 charCode, hsBool isUnicode);
};

class hsGRAMSfntFont : public hsGSfntFont {
private:
	UInt32		fLength;
	void*		fData;
	hsBool32	fDoDelete;	// using HSMemory::Delete()
public:
				hsGRAMSfntFont(UInt32 length, void* sfnt, hsBool doDelete, UInt32 format);
	virtual		~hsGRAMSfntFont();

	virtual UInt32		GetDataLength();
	virtual const void*	GetChunk(UInt32 offset, UInt32 length, void* dstOrNil = nil);

	static hsGRAMSfntFont* FileToRAM(FILE* f, UInt32 format);	// returns nil if failure
};

class hsGChunkStorageSfntFont : public hsGSfntFont {
protected:
	hsChunkAllocator	fStorage;
	virtual void		ReleaseSelf();
public:
	hsGChunkStorageSfntFont(hsGFontID fontID, UInt32 format) : hsGSfntFont(fontID, format) {}
	hsGChunkStorageSfntFont(UInt32 format) : hsGSfntFont(format) {}
};

class hsGFileSfntFont : public hsGChunkStorageSfntFont {
private:
	char*	fName;
	FILE*	fFILE;

	virtual void	AcquireSelf();
	virtual void	ReleaseSelf();
public:
					hsGFileSfntFont(const char name[], UInt32 format);
	virtual			~hsGFileSfntFont();
	
	const char*		GetFileName() const { return fName; }

	virtual UInt32		GetDataLength();
	virtual const void*	GetChunk(UInt32 offset, UInt32 length, void* dstOrNil = nil);
};

#if HS_BUILD_FOR_MAC
class hsGMacType1Font : public hsGFont {
	FSSpec				fSpec;
	hsChunkAllocator	fStorage;
	virtual void		ReleaseSelf();
public:
	hsGMacType1Font(const FSSpec& spec)
		: hsGFont(kType1_hsGFontFormat), fSpec(spec) {}
	hsGMacType1Font(hsGFontID fontID, const FSSpec& spec)
		: hsGFont(fontID, kType1_hsGFontFormat), fSpec(spec) {}

	virtual UInt32		GetName(hsGFontList::NameID nameID, char name[]);
	virtual hsBool		MatchName(hsGFontList::NameID nameID, const char name[]);

	virtual UInt32		GetDataLength();
	virtual const void*	GetChunk(UInt32 offset, UInt32 length, void* dstOrNil = nil);

	virtual const struct FSSpec* GetFSSpec() const;

	static hsBool		supportedFormat(const FSSpec& spec);
};
#endif

#if HS_BUILD_FOR_WIN32
class hsGPFMFont : public hsGFont {
private:
	char*				fName;
	FILE*				fFILE;
	hsChunkAllocator	fStorage;

	virtual void	AcquireSelf();
	virtual void	ReleaseSelf();
public:
					hsGPFMFont(const char filename[]);
	virtual			~hsGPFMFont();

	virtual UInt32	GetName(hsGFontList::NameID nameID, char name[]);
	virtual hsBool	MatchName(hsGFontList::NameID nameID, const char name[]);

	virtual UInt32		GetDataLength();
	virtual const void*	GetChunk(UInt32 offset, UInt32 length, void* dstOrNil = nil);
};
#endif

#endif
