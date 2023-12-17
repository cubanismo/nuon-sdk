/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 * This program is a sample for testing the new versions of 
 * NuonRaster, NuonYCCColorTable, and NuonChannelManager
*/


#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "sample.h"

#if defined (WIN32)
// available Nuon font list in Impulse libraries 3/25/01
const char *sysFontFile = "..\\..\\source\\t2k\\fonts\\arr_____.ttf";
const char *sysFontBoldFile = "..\\..\\source\\t2k\\fonts\\arrb____.ttf";
const char *sysSbitsFontFile = "..\\..\\source\\t2k\\fonts\\trebs-sbits.ttf";

#else 
// Pointers to preloaded fonts in Nuon memory
extern uint8 SysFont[];
extern uint8 SysFontEnd[];
extern uint8 SysFontBold[];
extern uint8 SysFontBoldEnd[];
extern uint8 SysSbitsFont[];
extern uint8 SysSbitsFontEnd[];

#endif

/***********************************************************/
void InitTest (TestSetup *pts, unsigned whichTest)
{
		
	sprintf (pts->testName, "sample_T%d", whichTest);

	// for convenience, allocate and initialize the arrays of 
	// pointers to filenames; plug in non-null values (above) on
	// a test-by-test basis 
	#define NUM_FONT_FILES  4

	// prevent memory leaks			
	pts->osdInitFlags = pts->mainInitFlags = kOwnDisplayPixmap | kOwnAppPixmap;

	// write the caption on the main plane, unless otherwise indicated below
	pts->captionChannel = kChMain;

	// these are indices for _matching_ outline & sbits fonts
	pts->outlineFontIndex = 0;
	pts->sbitsFontIndex = 2;

	// these values force use of default font (overwrite in specific test if desired)
	// because of the way Impulse gracefully defaults when it can't find a font
	strcpy (pts->captionTextFontName, "\0");
	pts->captionTextFontIndex = -1;

	//default number of preloaded fonts
	pts->numDefaultFonts = 1;

#if defined(WIN32)

	pts->fontFiles = new FontFileBlock*[NUM_FONT_FILES];
	pts->fontRamBlks = NULL;

	for (int i=0; i < NUM_FONT_FILES; i++) {
		pts->fontFiles[i] = NULL;
	}

	// use default font (overwrite in specific test if desired)
	strcpy (pts->captionTextFontName, "\0");
	pts->captionTextFontIndex = -1;

	// set up the list of fonts
	if (pts->fontFiles[0]) delete pts->fontFiles[0];
	pts->fontFiles[0] = new FontFileBlock;
	pts->fontFiles[0]->fontFileName = new char [ strlen(sysFontFile) + 1];
	strcpy (pts->fontFiles[0]->fontFileName, sysFontFile);
	pts->fontFiles[0]->fontFormat = NuonFontList::kNuon_TrueType_hsGFontFormat;

	if (pts->fontFiles[1]) delete pts->fontFiles[1];
	pts->fontFiles[1] = new FontFileBlock;
	pts->fontFiles[1]->fontFileName = new char [ strlen(sysFontBoldFile) + 1];
	strcpy (pts->fontFiles[1]->fontFileName, sysFontBoldFile);
	pts->fontFiles[1]->fontFormat = NuonFontList::kNuon_TrueType_hsGFontFormat;

	if (pts->fontFiles[2]) delete pts->fontFiles[2];
	pts->fontFiles[2] = new FontFileBlock;
	pts->fontFiles[2]->fontFileName = new char [ strlen(sysSbitsFontFile) + 2];
	strcpy (pts->fontFiles[2]->fontFileName, sysSbitsFontFile);
	pts->fontFiles[2]->fontFormat = NuonFontList::kNuon_kSbits_hsGFontFormat;

#else  //Nuon

	pts->fontFiles = NULL;
	pts->fontRamBlks = new FontRamBlock*[NUM_FONT_FILES];

	for (int i=0; i < NUM_FONT_FILES; i++) {
		pts->fontRamBlks[i] = NULL;
	}


	if (pts->fontRamBlks[0]) delete pts->fontRamBlks[0];
	pts->fontRamBlks[0] = new FontRamBlock;
	pts->fontRamBlks[0]->fontMemStart = SysFont;
	pts->fontRamBlks[0]->length = (UInt32) (SysFontEnd - SysFont);
	pts->fontRamBlks[0]->fontFormat = NuonFontList::kNuon_TrueType_hsGFontFormat;

	if (pts->fontRamBlks[1]) delete pts->fontRamBlks[1];
	pts->fontRamBlks[1] = new FontRamBlock;
	pts->fontRamBlks[1]->fontMemStart = SysFontBold;
	pts->fontRamBlks[1]->length = (UInt32) (SysFontBoldEnd - SysFontBold);
	pts->fontRamBlks[1]->fontFormat = NuonFontList::kNuon_TrueType_hsGFontFormat;

	if (pts->fontRamBlks[2]) delete pts->fontRamBlks[2];
	pts->fontRamBlks[2] = new FontRamBlock;
	pts->fontRamBlks[2]->fontMemStart = SysSbitsFont;
	pts->fontRamBlks[2]->length = (UInt32) (SysSbitsFontEnd - SysSbitsFont);
	pts->fontRamBlks[2]->fontFormat = NuonFontList::kNuon_kSbits_hsGFontFormat;


#endif

/*---------------------------------------*/
// Test Setup 1
	if (whichTest == 1) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default color (test to see that kInitDefaultColor ignored for 16-bit color)
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: default bitmap, 
			single frame buffer
			app buffer
			default color 
			default width, 3/4 default height
			8-bit color
		*/
		pts->osdInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = (DEFAULT_HEIGHT >> 1) + (DEFAULT_HEIGHT >> 2);  // 3/4 full height
		pts->osdDepth = CLUT_DEPTH;
		pts->osdSourceDepth = CLUT_DEPTH;


		// use default OSD palette
		pts->MakeOsdPalette = MakeSmallerPalette;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = DoNothingGracefullyNr;

		// initial erase colors
		pts->mainEraseColor.SetARGB (0xFFFF, 0x8000, 0x0, 0x0);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = DoNothingGracefullyNrTs;
		pts->DrawOsd = DrawColors;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionTextColor.SetARGB (0xFFFF, 0xF000, 0xF000, 0xF000);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"init with bitmap; change OSD palette",
				CHARS_PER_LINE);
		
		// find by index
		pts->captionTextFontIndex = 0;
		pts->captionTextSize = 18; 


/*---------------------------------------*/
// Test Setup 2

	} else if (whichTest == 2) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: no default bitmap, 
			single frame buffer
			app buffer
			no default color 
			default width, 3/4 default height
			8-bit color
		*/
		pts->osdInitFlags |= kUseBmpColorTable;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = (DEFAULT_HEIGHT >> 1) + (DEFAULT_HEIGHT >> 2);  // 3/4 full height
		pts->osdDepth = CLUT_DEPTH;
		pts->osdSourceDepth = CLUT_DEPTH;


		// use default OSD palette
		//pts->MakeOsdPalette = DoNothingGracefullyCol;
		pts->MakeOsdPalette = DoNothingGracefullyCol;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = AddABitmap1;

		// initial erase colors
		pts->mainEraseColor.SetARGB (0xFFFF, 0xF000, 0xF000, 0xF000);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = DoNothingGracefullyNrTs;
		pts->DrawOsd = DrawColors;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionTextColor.SetARGB (0xFFFF, 0x0, 0x0, 0x0);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main: add new bitmap with",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"AGL color table; clut NUON alpha values lost",
				CHARS_PER_LINE);
		
		// find by index
		pts->captionTextFontIndex = 1;
		pts->captionTextSize = 18; 
		pts->numDefaultFonts = -1;


/*---------------------------------------*/
// Test Setup 3

	} else if (whichTest == 3) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: no default bitmap, 
			single frame buffer
			app buffer
			no default color 
			default width, 3/4 default height
			8-bit color
		*/
		//pts->osdInitFlags |= 0;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = (DEFAULT_HEIGHT >> 1) + (DEFAULT_HEIGHT >> 2);  // 3/4 full height
		pts->osdDepth = CLUT_DEPTH;
		pts->osdSourceDepth = CLUT_DEPTH;


		// use default OSD palette
		//pts->MakeOsdPalette = DoNothingGracefullyCol;
		pts->MakeOsdPalette = DoNothingGracefullyCol;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = AddABitmap2;

		// initial erase colors
		pts->mainEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x0);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = DoNothingGracefullyNrTs;
		pts->DrawOsd = DrawColors;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionTextColor.SetARGB (0xFFFF, 0x8000, 0x8000, 0xF000);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main: add new bitmap THEN",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"add NUON color table (alphas preserved)",
				CHARS_PER_LINE);

		// find by name (in default list)
		strcpy (pts->captionTextFontName, "Bold");
		pts->captionTextSize = 18; 
		pts->numDefaultFonts = 3;

/*---------------------------------------*/
// Test Setup 4  same as T3 but direct draw into 8 bit SDRAM buffer

	} else if (whichTest == 4) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: no default bitmap, 
			single frame buffer
			app buffer
			no default color 
			default width, 3/4 default height
			8-bit color
		*/
		//pts->osdInitFlags |= 0;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = (DEFAULT_HEIGHT >> 1) + (DEFAULT_HEIGHT >> 2);  // 3/4 full height
		pts->osdDepth = CLUT_DEPTH;
#ifdef WIN32
		pts->osdSourceDepth = CLUT_DEPTH;
#else
		pts->osdSourceDepth = 0;
#endif


		// use default OSD palette
		//pts->MakeOsdPalette = DoNothingGracefullyCol;
		pts->MakeOsdPalette = DoNothingGracefullyCol;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = AddABitmap2;

		// initial erase colors
		pts->mainEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x0);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = DoNothingGracefullyNrTs;
		pts->DrawOsd = DrawColors;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionTextColor.SetARGB (0xFFFF, 0xF000, 0xF000, 0x8000);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"NUON version uses directDraw to OSD",
				CHARS_PER_LINE);

		
		// find by name (in add-on list)
		strcpy (pts->captionTextFontName, "Arial");
		pts->captionTextSize = 18; 
		pts->numDefaultFonts = 2;

/*---------------------------------------*/
// Test Setup 5

	} else if (whichTest == 5) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default color (test to see that kInitDefaultColor ignored for 16-bit color)
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: default bitmap, 
			single frame buffer
			app buffer
			default color 
			default width, 3/4 default height
			16-bit color
		*/
		pts->osdInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = (DEFAULT_HEIGHT >> 1) + (DEFAULT_HEIGHT >> 2);  // 3/4 full height
		pts->osdDepth = VIDEO_DEPTH;
		pts->osdSourceDepth = VIDEO_DEPTH;


		// use default OSD palette
		pts->MakeOsdPalette = DoNothingGracefullyCol;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = DoNothingGracefullyNr;

		// initial erase colors
		pts->mainEraseColor.SetARGB (0xFFFF, 0x8000, 0x0, 0x0);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = DoNothingGracefullyNrTs;
		pts->DrawOsd = DrawColors;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionTextColor.SetARGB (0xFFFF, 0xF000, 0xF000, 0xF000);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"16-bit OSD + 16-bit Main",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"make default AGL palette to display, but no CLUT used",
				CHARS_PER_LINE);

		pts->captionTextFontIndex = 1;
		pts->captionTextSize = 18; 

/*---------------------------------------*/
// Test Setup 6

	} else if (whichTest == 6) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default color (test to see that kInitDefaultColor ignored for 16-bit color)
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: default bitmap, 
			single frame buffer
			app buffer
			default color 
			default width, default height
			16-bit color
		*/
		pts->osdInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = DEFAULT_HEIGHT;
		pts->osdDepth = VIDEO_DEPTH;
		pts->osdDepth = CLUT_DEPTH;
#ifdef WIN32
		pts->osdSourceDepth = CLUT_DEPTH;
#else
		//pts->osdSourceDepth = CLUT_DEPTH;
		pts->osdSourceDepth = 0;
#endif


		// use default OSD palette
		pts->MakeOsdPalette = DoNothingGracefullyCol;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = DoNothingGracefullyNr;

		// initial erase colors
		pts->mainEraseColor.SetARGB (0xFFFF, 0x8000, 0x4000, 0x4000);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = OriginalDemoDraw1;
		pts->DrawOsd = DrawRotate;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionChannel = kChOsd;
		pts->captionTextColor.SetARGB (0xFFFF, 0xF000, 0xF000, 0xF000);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main, directDraw",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"wheel fonts top=bitmap/bottom=outline",
				CHARS_PER_LINE);

		pts->captionTextFontIndex = 1;
		pts->captionTextSize = 18; 


/*---------------------------------------*/
// Test Setup 7

	} else if (whichTest == 7) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default color (test to see that kInitDefaultColor ignored for 16-bit color)
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: default bitmap, 
			single frame buffer
			app buffer
			default color 
			default width, default height
			16-bit color
		*/
		pts->osdInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = (DEFAULT_HEIGHT >> 1) + (DEFAULT_HEIGHT >> 2) + 10; 
		pts->osdDepth = CLUT_DEPTH;
#ifdef WIN32
		pts->osdSourceDepth = CLUT_DEPTH;
#else
		//pts->osdSourceDepth = CLUT_DEPTH;
		pts->osdSourceDepth = 0;
#endif


		// use default OSD palette
		pts->MakeOsdPalette = DoNothingGracefullyCol;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = DoNothingGracefullyNr;

		// initial erase colors
		pts->osdEraseColor.SetARGB (0xFFFF, 0xF000, 0xF000, 0xF000);
		pts->mainEraseColor.SetARGB (0xFFFF, 0xA600, 0xCA00, 0xF000);

		// draw functions
		pts->DrawMain = DoNothingGracefullyNrTs;
		pts->DrawOsd = DrawTextEffects;
		//pts->DrawOsd = DoNothingGracefullyNrTs;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionTextColor.SetARGB (0xFFFF, 0xF800, 0x0000, 0x0000);

		pts->captionTextColorIndex = 0;   

		pts->captionTextFontIndex = 2;
		pts->captionTextSize = 24; 

		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main, directDraw",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"Bitmap/Outline Fonts: 48pt, 80pt, 60pt",
				CHARS_PER_LINE);




/*---------------------------------------*/
// Test Setup 8

	} else if (whichTest == 8) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default color (test to see that kInitDefaultColor ignored for 16-bit color)
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: default bitmap, 
			single frame buffer
			app buffer
			default color 
			default width, default height
			16-bit color
		*/
		pts->osdInitFlags |= kInitDefaultBitmap;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = DEFAULT_HEIGHT;
		pts->osdDepth = CLUT_DEPTH;
#ifdef WIN32
		pts->osdSourceDepth = CLUT_DEPTH;
#else
		pts->osdSourceDepth = 0;
#endif

		// use default OSD palette
		pts->MakeOsdPalette = UniformTranslucency;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = DoNothingGracefullyNr;

		// initial erase colors
		pts->mainEraseColor.SetARGB (0xFFFF, 0xf000, 0xf000, 0xf000);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = Impulsive;
		pts->DrawOsd = ComplexClipAndGradientFill;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionTextColor.SetARGB (0xFFFF, 0x0000, 0x0000, 0x0000);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main: 8-bit gradient, 50% alpha",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"NUON version uses directDraw to OSD",
				CHARS_PER_LINE);
		
		// find by index
		pts->captionTextFontIndex = 1;
		pts->captionTextSize = 18; 
		pts->numDefaultFonts = 2;


/*---------------------------------------*/
// Test Setup 9

	} else if (whichTest == 9) {

		/* main channel init: default bitmap, 
			single frame buffer
			app buffer
			default color (test to see that kInitDefaultColor ignored for 16-bit color)
			default width & height
			16-bit color
		*/
		pts->mainInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->mainWidth = DEFAULT_WIDTH;
		pts->mainHeight = DEFAULT_HEIGHT;
		pts->mainDepth = VIDEO_DEPTH;
		pts->mainSourceDepth = VIDEO_DEPTH;


		/* osd channel init: default bitmap, 
			single frame buffer
			app buffer
			default color 
			default width, default height
			8-bit color
		*/
		pts->osdInitFlags |= kInitDefaultColor | kInitDefaultBitmap;
		pts->osdWidth = DEFAULT_WIDTH;
		pts->osdHeight = DEFAULT_HEIGHT;
		pts->osdDepth = CLUT_DEPTH;
		pts->osdSourceDepth = CLUT_DEPTH;

		// use default OSD palette
		pts->MakeOsdPalette = DoNothingGracefullyCol;

		// bitmap functions
		pts->AddMainBitmap = DoNothingGracefullyNr;
		pts->AddOsdBitmap = DoNothingGracefullyNr;

		// initial erase colors
		pts->mainEraseColor.SetARGB (0xFFFF, 0xf000, 0xf000, 0x0000);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = DrawAGLDemo;
		pts->DrawOsd = BlankBackground;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionChannel = kChOsd;
		pts->captionTextColor.SetARGB (0xFFFF, 0x000, 0x000, 0xF000);
		pts->captionTextColorIndex = 5;   
		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main; OSD transparent bkgnd",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"note (bad) AGL antialiasing text against this bkgnd",
				CHARS_PER_LINE);

		pts->captionTextFontIndex = 1;
		pts->captionTextSize = 18; 

/*---------------------------------------*/

	} else  {

		printf ("Error -- no test setup!\n"); fflush (stdout);
		assert (0);

	} 
}  // end TestSetup
/***********************************************************/

/***********************************************************/
// Clean up allocated memory, fonts
void DeInitTest (TestSetup *pts)
{
	FontFileBlock **ffbP;
	FontRamBlock **frbP;

	hsGFontList::KillFontList ();  

	if (pts->fontFiles) {
		ffbP = pts->fontFiles;
		while (*ffbP) {
			delete (*ffbP);
			ffbP++;
		}
		delete pts->fontFiles;
	}

	if (pts->fontRamBlks) {
		frbP = pts->fontRamBlks;
		while (*frbP) {
			delete (*frbP);
			frbP++;
		}
		delete pts->fontRamBlks;
	}
}
