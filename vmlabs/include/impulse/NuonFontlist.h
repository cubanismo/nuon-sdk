/*-------------------------------------------------------------------------------------------------
 * Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
-------------------------------------------------------------------------------------------------*/
// derived class to add a couple of Nuon-specific methods to hsGFontList
// removes the knowledge of sysfont, etc from this library (even if linked in
// at compile time, this allows fonts to be outside the Impulse library

#ifndef NUON_FONTLIST_H
#define NUON_FONTLIST_H

#include "hsGFont.h"

typedef struct FontRamBlock FontRamBlock;
struct FontRamBlock {
	void *fontMemStart;
	UInt32 length;
	UInt32 fontFormat;
};

typedef struct FontFileBlock FontFileBlock;
struct FontFileBlock {
	char *fontFileName;
	UInt32 fontFormat;
};

#define LOAD_ALL -1

class NuonFontList : public hsGFontList {
public:
	static const UInt32 kNuon_TrueType_hsGFontFormat;
	static const UInt32 kNuon_kSbits_hsGFontFormat;

	static FontFileBlock **mInitFontFiles;
	static FontRamBlock **mInitFontRamBlks;

	static void KillFontList ();  

	static void SetInitFileList (FontFileBlock **initFontFiles, int numFonts = LOAD_ALL); 
	static void SetInitRamBlks (FontRamBlock **initFontRamBlks, int numFonts = LOAD_ALL);

	static hsGFontID	AddAllocatedFont(UInt32 length, void* sfnt, hsBool doDelete, UInt32 format=0);
	static hsGFontID	AddAllocatedFont(FontRamBlock *blk, hsBool doDelete);
};



#endif  //NUON_FONTLIST_H