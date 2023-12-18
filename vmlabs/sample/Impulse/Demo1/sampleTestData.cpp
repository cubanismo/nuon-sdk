/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
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

#else 
// Pointers to preloaded fonts in Nuon memory
extern uint8 SysFont[];
extern uint8 SysFontEnd[];
extern uint8 SysFontBold[];
extern uint8 SysFontBoldEnd[];

#endif
/***********************************************************/
void InitTest (TestSetup *pts, unsigned whichTest)
{
		
	sprintf (pts->testName, "sample_T%d", whichTest);

	// for convenience, allocate and initialize the arrays of 
	// pointers to filenames; plug in non-null values (above) on
	// a test-by-test basis 
	#define NUM_FONT_FILES  3

	// prevent memory leaks			
	pts->osdInitFlags = pts->mainInitFlags = kOwnDisplayPixmap | kOwnAppPixmap;

	// write the caption on the main plane, unless otherwise indicated below
	pts->captionChannel = kChMain;

#if defined(WIN32)

	pts->defaultFontFiles = new char*[NUM_FONT_FILES];
	pts->moreFontFiles = new char*[NUM_FONT_FILES];
	pts->defaultFontRamBlks = NULL;
	pts->moreFontRamBlks = NULL;

	for (int i=0; i < NUM_FONT_FILES; i++) {
		pts->defaultFontFiles[i] = NULL;
		pts->moreFontFiles[i] = NULL;
	}

	// use default font (overwrite in specific test if desired)
	strcpy (pts->captionTextFontName, "\0");
	pts->captionTextFontIndex = -1;
	if (pts->defaultFontFiles[0]) delete pts->defaultFontFiles[0];
	pts->defaultFontFiles[0] = new char [ strlen(sysFontFile) + 1];
	strcpy (pts->defaultFontFiles[0], sysFontFile);

#else  //Nuon

	pts->defaultFontFiles = NULL;
	pts->moreFontFiles = NULL;
	pts->defaultFontRamBlks = new FontRamBlock*[NUM_FONT_FILES];
	pts->moreFontRamBlks = new FontRamBlock*[NUM_FONT_FILES];

	for (int i=0; i < NUM_FONT_FILES; i++) {
		pts->defaultFontRamBlks[i] = NULL;
		pts->moreFontRamBlks[i] = NULL;
	}

	// use default font (overwrite in specific test if desired)
	strcpy (pts->captionTextFontName, "\0");
	pts->captionTextFontIndex = -1;
	if (pts->defaultFontRamBlks[0]) delete pts->defaultFontRamBlks[0];
	pts->defaultFontRamBlks[0] = new FontRamBlock;
	pts->defaultFontRamBlks[0]->fontMemStart = SysFont;
	pts->defaultFontRamBlks[0]->length = (UInt32) (SysFontEnd - SysFont);


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
		pts->captionTextSize = 18; 
		
		// find by index
		pts->captionTextFontIndex = 0;
#if defined (WIN32)
		if (pts->defaultFontFiles[0]) delete pts->defaultFontFiles[0];
		pts->defaultFontFiles[0] = new char [ strlen(sysFontBoldFile) + 1];
		strcpy (pts->defaultFontFiles[0], sysFontBoldFile);
#else
		if (pts->defaultFontRamBlks[0]) delete pts->defaultFontRamBlks[0];
		pts->defaultFontRamBlks[0] = new FontRamBlock;
		pts->defaultFontRamBlks[0]->fontMemStart = SysFontBold;
		pts->defaultFontRamBlks[0]->length = (UInt32) (SysFontBoldEnd - SysFontBold);
#endif


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
		pts->captionTextSize = 18; 
		
		// find by index
		pts->captionTextFontIndex = 1;
#if defined (WIN32)
		pts->defaultFontFiles[1] = new char [ strlen(sysFontBoldFile) + 1];
		strcpy (pts->defaultFontFiles[1], sysFontBoldFile);
#else
		pts->defaultFontRamBlks[1] = new FontRamBlock;
		pts->defaultFontRamBlks[1]->fontMemStart = SysFontBold;
		pts->defaultFontRamBlks[1]->length = (UInt32) (SysFontBoldEnd - SysFontBold);
#endif

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
		pts->captionTextSize = 18; 

		// find by name (in default list)
		strcpy (pts->captionTextFontName, "Bold");
#if defined (WIN32)
		pts->defaultFontFiles[1] = new char [ strlen(sysFontBoldFile) + 1];
		strcpy (pts->defaultFontFiles[1], sysFontBoldFile);
#else
		pts->defaultFontRamBlks[1] = new FontRamBlock;
		pts->defaultFontRamBlks[1]->fontMemStart = SysFontBold;
		pts->defaultFontRamBlks[1]->length = (UInt32) (SysFontBoldEnd - SysFontBold);
#endif

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
		pts->captionTextSize = 18; 

		// find by name (in add-on list)
		strcpy (pts->captionTextFontName, "Bold");
#if defined (WIN32)
		pts->moreFontFiles[0] = new char [ strlen(sysFontBoldFile) + 1];
		strcpy (pts->moreFontFiles[0], sysFontBoldFile);
#else
		pts->moreFontRamBlks[0] = new FontRamBlock;
		pts->moreFontRamBlks[0]->fontMemStart = SysFontBold;
		pts->moreFontRamBlks[0]->length = (UInt32) (SysFontBoldEnd - SysFontBold);
#endif

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
		pts->DrawOsd = OriginalDemoDraw1;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionChannel = kChOsd;
		pts->captionTextColor.SetARGB (0xFFFF, 0xF000, 0xF000, 0xF000);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"16-bit OSD + 16-bit Main",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"opaque OSD completely covers main plane",
				CHARS_PER_LINE);
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
		pts->osdHeight = DEFAULT_HEIGHT;
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
		pts->mainEraseColor.SetARGB (0xFFFF, 0xF000, 0xF000, 0xF000);
		pts->osdEraseColor.SetARGB (0xFFFF, 0x0, 0x0, 0x8000);

		// draw functions
		pts->DrawMain = DrawTextEffects;
		pts->DrawOsd = DrawRotate;
		pts->DrawBoth = DoNothingGracefullyNrNrTs;

		// caption text
		pts->captionTextColor.SetARGB (0xFFFF, 0xF800, 0x0000, 0x0000);
		pts->captionTextColorIndex = 0;   
		strncpy (pts->captionLine1, 
				"8-bit OSD + 16-bit Main",
				CHARS_PER_LINE);
		strncpy (pts->captionLine2, 
				"NUON version uses directDraw to OSD",
				CHARS_PER_LINE);
		pts->captionTextSize = 18; 




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
		pts->captionTextSize = 18; 
		
		// find by index
		pts->captionTextFontIndex = 1;
#if defined (WIN32)
		pts->defaultFontFiles[1] = new char [ strlen(sysFontBoldFile) + 1];
		strcpy (pts->defaultFontFiles[1], sysFontBoldFile);
#else
		pts->defaultFontRamBlks[1] = new FontRamBlock;
		pts->defaultFontRamBlks[1]->fontMemStart = SysFontBold;
		pts->defaultFontRamBlks[1]->length = (UInt32) (SysFontBoldEnd - SysFontBold);
#endif


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
	char **ptr;
	FontRamBlock **frbP;

	hsGFontList::KillFontList ();  

	if (pts->defaultFontFiles) {
		ptr = pts->defaultFontFiles;
		while (*ptr) {
			delete (*ptr);
			ptr++;
		}
		delete pts->defaultFontFiles;
	}

	if (pts->moreFontFiles) {
		ptr = pts->moreFontFiles;
		while (*ptr) {
			delete (*ptr);
			ptr++;
		}
		delete pts->moreFontFiles;
	}

	if (pts->defaultFontRamBlks) {
		frbP = pts->defaultFontRamBlks;
		while (*frbP) {
			delete (*frbP);
			frbP++;
		}
		delete pts->defaultFontRamBlks;
	}

	if (pts->moreFontRamBlks) {
		frbP = pts->moreFontRamBlks;
		while (*frbP) {
			delete (*frbP);
			frbP++;
		}
		delete pts->moreFontRamBlks;
	}
}
