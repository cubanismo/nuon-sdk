/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 *
 * This program is a sample for testing the new versions of 
 * NuonRaster, NuonYCCColorTable, and NuonChannelManager
*/
#ifndef SAMPLE_H
#define SAMPLE_H

#ifdef WIN32
#pragma include_alias( <impulse/NuonFontlist.h>, <NuonFontlist.h> )
#pragma include_alias( <impulse/NuonRaster.h>, <NuonRaster.h> )
#pragma include_alias( <impulse/NuonYccColorTable.h>, <NuonYccColorTable.h> )
#endif

#include <impulse/NuonFontlist.h>
#include <impulse/NuonRaster.h>
#include <impulse/NuonYccColorTable.h>
#include "palettes.h"


#define ON 1 
#define OFF 0

#define STRING_MAXLEN 256 
#define CHARS_PER_LINE 60



struct tagTestSetup;
typedef struct tagTestSetup TestSetup;
struct tagTestSetup {
	char testName[STRING_MAXLEN];

	// main channel setup
	int mainInitFlags;
	int mainWidth;
	int mainHeight;
	int mainDepth;
	int mainSourceDepth;

	// osd channel setup
	int osdInitFlags;
	int osdWidth;
	int osdHeight;
	int osdDepth;
	int osdSourceDepth;
	NuonYccColorTable *(*MakeOsdPalette) (void);

	// bitmap functions
	void (*AddMainBitmap)(NuonRaster*);
	void (*AddOsdBitmap)(NuonRaster*);

	// initial erase colors
	hsGColor mainEraseColor;
	hsGColor osdEraseColor;

	// draw functions
	void (*DrawMain) (NuonRaster*, TestSetup *pts);
	void (*DrawOsd) (NuonRaster*, TestSetup *pts);
	void (*DrawBoth) (NuonRaster*, NuonRaster*, TestSetup *pts);

	// caption text
	unsigned captionChannel;
	hsGColor captionTextColor;
	int captionTextColorIndex;   // only one of these (color or index) is used
	char captionLine1[CHARS_PER_LINE];
	char captionLine2[CHARS_PER_LINE];
	int captionTextSize;
	char captionTextFontName[STRING_MAXLEN];  //partial name
	int captionTextFontIndex;

	// fonts
	// used for WIN32 -- load fonts from files
	char **defaultFontFiles;
	char **moreFontFiles;

	// used for Nuon -- load fonts already allocated in memory
	FontRamBlock **defaultFontRamBlks;
	FontRamBlock **moreFontRamBlks;
};



//real functions
void DrawColors (NuonRaster *nr, TestSetup *pts);
void AddABitmap1 (NuonRaster *nr);
void AddABitmap2 (NuonRaster *nr);
void InitTest (TestSetup *pts, unsigned whichTest);
void DeInitTest (TestSetup *pts);
hsGBitmap *MakeNewBitmap (int width, int height, int sourceDepth);
void DrawCaption (NuonRaster *nr, TestSetup *pts);
void OriginalDemoDraw1( NuonRaster *nr, TestSetup *pts);
void DrawTextEffects( NuonRaster *nr, TestSetup *pts );
void DrawRotate( NuonRaster *nr, TestSetup *pts );
void BlankBackground (NuonRaster *nr);
void BlankBackground ( NuonRaster *nr, TestSetup *pts );
void ComplexClipAndGradientFill( NuonRaster *nr, TestSetup *pts );
void DrawAGLDemo (NuonRaster *nr, TestSetup *pts);
void Impulsive( NuonRaster *nr, TestSetup *pts );


//dummy functions
NuonYccColorTable *DoNothingGracefullyCol ();
void DoNothingGracefullyNr (NuonRaster*);
void DoNothingGracefullyNrTs (NuonRaster*, TestSetup*);
void DoNothingGracefullyNrNrTs (NuonRaster*, NuonRaster*, TestSetup*);


#endif SAMPLE_H

