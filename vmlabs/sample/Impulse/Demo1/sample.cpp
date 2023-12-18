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
#include <nuon/joystick.h>

#include <impulse/NuonGamesChannelManager.h>
#include "sample.h"

// test list  -- sequence of test numbers in the slide show
struct TestList {
	unsigned *list;
	int listLength;
};

/***********************************************************/
/*******************%%%%%%%%%%%%%%%%%%%%%%******************/

// list of sample tests (edit to reduce for debugging)

unsigned activeTests[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
//unsigned activeTests[] = {4};
const int numTests = 9;
//const int numTests = 1;


#if defined (T2)
	const unsigned startTestNum = 2;
#elif defined (T3)
	const unsigned startTestNum = 3;
#elif defined (T4)
	const unsigned startTestNum = 4;
#elif defined (T5)
	const unsigned startTestNum = 5;
#elif defined (T6)
	const unsigned startTestNum = 6;
#elif defined (T7)
	const unsigned startTestNum = 7;
#elif defined (T8)
	const unsigned startTestNum = 8;
#elif defined (T9)
	const unsigned startTestNum = 9;
#else
	const unsigned startTestNum = 1;
#endif

/*******************%%%%%%%%%%%%%%%%%%%%%%******************/
/***********************************************************/



// joystick functions & constants; use large numbers (sure to
// be outside the legitimate range of tests) for controls
#define TOGGLE_SHOWMODE		CTRLR_BUTTON_A
#define QUIT				CTRLR_BUTTON_B
#define NEXT_SLIDE			CTRLR_BUTTON_C_RIGHT
#define PREV_SLIDE			CTRLR_BUTTON_C_LEFT
#define FIRST_SLIDE			CTRLR_BUTTON_C_UP
#define LAST_SLIDE			CTRLR_BUTTON_C_DOWN
#define LINEAR_SEQUENCE		CTRLR_BUTTON_R
#define RANDOM_SEQUENCE		CTRLR_BUTTON_L


#define AUTO_SHOW 1
#define NO_AUTO_SHOW 0
#define RANDOM 1
#define LINEAR 0

long getkey();
long forcekey();
unsigned nextTestNum (long joyEdge, TestList tl, unsigned currentNum = 0);

/*--------------------------------------------------------------------------*/
// poll the joystick using an edge-detection technique (i.e. don't react to the
// same button twice unless it's been pressed, released, pressed again)
long getkey()
{
  long new_joy;
  long joy_edge;
  static long last_joy;

  // get joystick button(s) pressed
  new_joy = Buttons(_Controller[1]);
  // isolate the (pressed) buttons which were not pressed last time
  joy_edge = (new_joy ^ last_joy) & new_joy;
  // update old joystick value
  last_joy = new_joy;

return joy_edge;
}

#if defined (DEBUG)
#define TIMEWASTED 3000000
#else
#define TIMEWASTED 10000000
#endif

// set the joystick key to forward
long forcekey()
{
	long joyEdge;

	for (int timewaster= TIMEWASTED; timewaster > 0; timewaster--) {
		joyEdge = getkey();

		// respond only to quit or showmode control keys
		if (joyEdge & 
			(QUIT | LINEAR_SEQUENCE | RANDOM_SEQUENCE | TOGGLE_SHOWMODE))
				return joyEdge;
	}
	// next slide
	return (long) NEXT_SLIDE;
}


/*---------------------------------------------------------------------------*/
// process the joystick button-push for a slide show through a circular list
// remember the number, but allow the user to reset our memory
// test numbers start with 1, not 0

unsigned nextTestNum (long joyEdge, TestList tl, unsigned currentNum) 
{
	static int index = 0;

// get a new current index if a new reference current test number is given	
	if (currentNum) {
		for (int i = 0; i < tl.listLength; i++) {
			if (currentNum == tl.list[i]) {
				index = i;
				break;
			}
		}
	}

	if (joyEdge & FIRST_SLIDE) 	index = 0; 

	else if (joyEdge & LAST_SLIDE)	index = tl.listLength - 1; 

	else if ((joyEdge & PREV_SLIDE) && (joyEdge & NEXT_SLIDE)) {
		index = rand() % numTests;
	}

	else if (joyEdge & PREV_SLIDE) {
		index--;
		if (index < 0) index = tl.listLength - 1;
	}
 
	else if (joyEdge & NEXT_SLIDE) {
		index++;
		if (index > (tl.listLength - 1)) index = 0;
	}

	return ( tl.list[index] );
}


/***********************************************************/
/***********************************************************/


int main (void)
{

	#if defined (PRINT_DEBUG)
	  int passcount=0;
	#endif

	// test setup
	TestSetup ts;
	bool directDraw;
	int showmode = NO_AUTO_SHOW;
	int seqmode = LINEAR;

	// loop control
	TestList tests = { {activeTests}, {numTests} };  // list array, array size
	long joystickEdge = 0;

	printf ("\n");
	printf ("joystick navigation:          first slide \n");
	printf ("                                    ^  \n");
	printf ("                 previous slide < C-PAD > next slide\n");
	printf ("                                    v  \n");
	printf ("                               last slide\n");
	printf ("\n");
	printf ("   A - toggle automatic slideshow on/off\n");
	printf ("   B - quit ungracefully\n");
	printf ("\n");
	printf ("  Left Button -            Right Button -\n");
	printf ("Random Slideshow         Linear Slideshow\n");
	printf ("\n");
	fflush (stdout);


	// this call to nextTestNum just synchs the static test number
	// remembered in nextTestNum to the first test run
	unsigned whichTest = nextTestNum (joystickEdge, tests, startTestNum);

	// create a hardware manager and initialize the system
	NuonGamesChannelManager* hwMgr = new NuonGamesChannelManager;
	assert (hwMgr != NULL);

	// loop forever, cycling through tests on demand
	while (!(joystickEdge & QUIT)) {

		InitTest (&ts, whichTest);
		directDraw = (ts.osdSourceDepth == 0);
				
		NuonFontList::SetInitRamBlks (ts.defaultFontRamBlks); 

		// set up default frame buffer addresses in the channel manager
		// here, if they're needed (say, for the PE)

		// setup main channel & raster object
		// initalize the channel, create raster object, configure the channel
		NuonRaster* nrMain = new NuonRaster(hwMgr,
											ts.mainInitFlags,
											kChMain,
						 					ts.mainWidth, 
						 					ts.mainHeight, 
						 					ts.mainDepth,
											ts.mainSourceDepth);


		// setup osd channel & raster object
		// initalize the channel, create raster object, configure the channel
		NuonRaster* nrOsd  = new NuonRaster(hwMgr, 
											ts.osdInitFlags,
											kChOsd,
						 					ts.osdWidth, 
						 					ts.osdHeight, 
						 					ts.osdDepth,
											ts.osdSourceDepth);


		// set up any palette
		NuonYccColorTable *palette = (*ts.MakeOsdPalette)();
		if (palette) nrOsd->SetClut (palette);

		// set up any bitmaps
		(*ts.AddMainBitmap)(nrMain);
		(*ts.AddOsdBitmap)(nrOsd);


		// set background color on both channels
		nrMain->Erase (&ts.mainEraseColor);
		nrOsd->Erase (&ts.osdEraseColor);
		nrMain->rasterize();
		nrOsd->rasterize();

		// Show channels
		hwMgr->Show();

		// draw   (each of these functions does matrix cleanup and calls rasterize()
		(*ts.DrawMain)(nrMain, &ts);
		(*ts.DrawOsd)(nrOsd, &ts);
		(*ts.DrawBoth)(nrMain, nrOsd, &ts);

		DrawCaption (((ts.captionChannel == kChMain) ? nrMain : nrOsd), &ts);


		//hwMgr->PrintState("hwMgr");
		//nrMain->PrintState("nrMain");
		//nrOsd->PrintState("nrOsd",1,0);

		// figure out what to display next
		if (showmode == AUTO_SHOW) {
			joystickEdge = forcekey();

			if (joystickEdge & TOGGLE_SHOWMODE) {
				showmode = NO_AUTO_SHOW;
			}
			else if (joystickEdge & LINEAR_SEQUENCE) {
				seqmode = LINEAR;
			}
			else if (joystickEdge & RANDOM_SEQUENCE) {
				seqmode = RANDOM;
			}
			else if (seqmode == RANDOM) {
				joystickEdge = (PREV_SLIDE | NEXT_SLIDE);
			}
		}

		// if the previous if statement executed and changed the value of showmode,
		// then this one should also execute in the same pass through the loop
		if (showmode == NO_AUTO_SHOW) {
			while (!(joystickEdge = getkey()));
			
			if (joystickEdge & TOGGLE_SHOWMODE) {
				showmode = AUTO_SHOW;
				joystickEdge = NEXT_SLIDE;
				if (seqmode == RANDOM) {
					joystickEdge |= PREV_SLIDE;
				}
			}
		}
		whichTest = nextTestNum (joystickEdge, tests);

		hwMgr->Hide ();

		if (nrMain) delete nrMain;
		if (nrOsd) delete nrOsd;
		DeInitTest (&ts);
		#if defined (PRINT_DEBUG)
		  printf ("slide %d\n", passcount); fflush (stdout); passcount++;
		#endif
	}

	if (hwMgr) delete hwMgr;
	printf ("finished\n"); fflush(stdout);
	return 0;
}


