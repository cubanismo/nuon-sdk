/* Copyright (c) 1995-2000, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc



1/10/01 adapted from NuonRaster.h in dvdsdk; replaces previous 
version --kml

###############################################################################

NuonRaster inheritance from hsGRasterDevice
-------------------------------------------
The Impulse raster device defined in hsGRasterDevice uses an hsGBitmap data
member to keep track of all the information about the size of the bitmap, where
it is (pointer to the frame buffer), etc.

We inherit that bitmap and all that associated information (although we had to
make a small change to the hsGBitmap class to inherit).  However, there are 
actually two bitmaps: one is the hsGBitmap data member, and the other is our Nuon
display frame buffer.

Eventually, the intent is to make the Impulse bitmap essentially optional, and
to support a mode where we render directly into the display frame.  At the same time,
it is important to not only maintain support for separate Impulse (application)
and display bitmaps, but to permit them to be different color depths and color
spaces.

Color Table
-----------
NuonRaster has a NuonYccColorTable associated with it.  This color table keeps
both Nuon (mmlcolor) and Impulse color tables, and keeps them matched to each
other.  Impulse functions render using the Impulse color table, but the actual
displayed color comes from the Nuon color table loaded into the hardware.

In the Impulse scheme of things, the color table is attached to the bitmap.  So
to keep all the attachments between different objects requires some coordination
within this class.  For example, attaching a new color table to the device requires
changing the bitmap.  On the other hand, changing the bitmap may either cause
the bitmap's color table to be pushed into the Nuon color table, or vice-versa,
depending on state flags.

                 --------------
                 | NuonRaster |
                 --------------
                   |       |
                   |       |
                   V       V
----------------------   -------------
| NuonYccColorTable  |   | hsGBitmap |
----------------------   -------------
                   |       |
                   |       |
                   V       V
             ---------------------
             | hsGColorTable or  |
             | NuonAGlColorTable |
             ---------------------

NuonAglColorTable is a derived class of hsGColorTable.  In the initial design, it
_is_ hsGColorTable.  It will present all the same public members as hsGBitmap, and
it should be possible and safe to pass a NuonAglColorTable in place of a hsGColorTable
wherever the latter is used.

The definition of the NuonAglColorTable gives us the hook to build a color table
that copes more gracefully with YCC color space and/or skewed palettes.


Image Parameters
----------------
hsGBitmap objects have image width, height, and pixel depth information in addition
to a pointer to the bitmap.  In many cases, the display buffer has the same width,
height, and depth; but this is not always required.  For example, there are methods
in the underlying mml2d which support scaled copying (though not for 8-bit color
depth), that could be called when the hsGBitmap and the display pixmap are different
sizes.  So NuonRaster methods must address this relationship between application and
display pixmaps.

In the initial writing, we may deliberately avoid doing some of this checking; but
the hooks should be in there to support it.  By the same reasoning, although the
current uses for NuonRaster will not involve 32-bit color, we need to support the 
hooks for it.

App Bitmaps
-----------
There are different controls for setting up a bitmap.  If the kInitDefaultBitmap 
setup flag is passed in the contstructor call and source depth is a supported 
depth (8,16,32, depending on channel) an application bitmap will be 
created, along with a frame buffer.  

If the kInitDefaultBitmap flag is set but source depth is 0, the bitmap is set up
to support direct writes to the display pixmap, and no application frame buffer is
created.

If the flag is not set, no bitmap initialization is done.  A followup call of 
SetPixels() or SetSourceDepth() is required to set up the bitmap.


Freeing Dynamically Allocated Memory
------------------------------------
A problem shows up that is fundamentally a difference in programming methodologies 
between the AGL libraries and the MML2D.  In the former, objects tend to unreference 
any allocated memory they've acquired in the course of execution.  The last 
unreferencer deletes the object.  MML2D methodology is that whatever allocates the 
memory is responsible for freeing it.

The kOwnDisplayPixmap and kOwnAppPixmap flags keep track of pixmaps that might have
been externally allocated.  NuonRaster will free any memory that it allocated.


 2/8/01, 3/28/01  kml  
###############################################################################

*/


/*---------------------------------------------------------------------------*/

#if !defined(NUONRASTER_H)
#define NUONRASTER_H

#ifdef WIN32
#include <windows.h>
#else
#include <nuon/mml2d.h>
#include <nuon/video.h>
#endif

/* this define turns off impulse debugging */
//#define __profile__ 1

#include "NuonRasterBase.h"
#include "hsGRasterDevice.h"
#include "HSScan.h"
#include "hsGBitmap.h"
#include "NuonYccColorTable.h"
#include "NuonChannelManager.h"

#define DEFAULT_WIDTH  720
#define DEFAULT_HEIGHT 480
#define CLUT_DEPTH 8
#define VIDEO_DEPTH 16

/*---------------------------------------------------------------------------*/

class NuonBounder : public HSScanHandler {
protected:
	hsIntRect fBounds;
	hsBool fIsEmpty;
	virtual hsBool HandleIntRect(const hsIntRect *,const hsScanRegion *);
public:
	NuonBounder() { Reset(); }
	void Reset(void) { fIsEmpty = true; }
	hsBool GetBounds(hsIntRect *bounds) { *bounds = fBounds; return !fIsEmpty; }
};


// control Flags
enum {  kInitDefaultColor = 0x1, 
		  kInitDefaultBitmap = 0x2,
		  kUseDoubleBuffer = 0x4,
		  kUseBmpColorTable = 0x8,
		  kUseBmpSizeInfo = 0x10
};

// state (mFlags)
enum {  kIsDefaultColor = 0x1,               // using default color table
		  kIsDoubleBuffered = 0x2,           // not set == single buffered (default)
		  kIsDisplayBuffer1 = 0x4,           // identifies current display buf; nonzero
					                         // value only valid when double-buffered
		  kBitmapInitialized = 0x8, 
		  kOwnDisplayPixmap = 0x10,			// we allocated the app pixmap
		  kOwnAppPixmap = 0x20				// we allocated the display pixmap
};   


class NuonRaster : public NuonRasterBase
{  
public:
	// why are these public? -- Karen  (2/16/01: they turn out to be handy for debug)
	int								mWidth;       // width & height of raster device
	int								mHeight;      // may be different than for app bitmap
protected:
	unsigned						mFlags;        // current state
	unsigned						mCtrlFlags;   // how state should change
	unsigned						mWhichChannel;  // need to know what channel we're
															// feeding in order to do Flip()
	unsigned						mUserID;     // user ID from channel manager; used to
	                                             // avoid unnecessary channel configuring

	// pointer to the channel manager being used; what actually gets assigned
	// (in the constructor) is a pointer to a derived class of NuonChannelManager,
	// either a PE, a BIOS, or a Windows emulation manager
	// Assigning this way also enforces the requirement that a manager exist, and
	// so the system is initalized, before trying to init a NuonRaster object
	static NuonChannelManager  *mChannelMgr;
	static int					mChannelManagerUsers;

	static NuonYccColorTable	*mDitherColorTable;
	int							mDepth;
	int							mSourceDepth;
	//hsGNuonBitmap					mBitmap;   use fPixels
	NuonYccColorTable			*mClut;      //maybe this should be static, too
	NuonBounder					*mBounder;

	//haven't thought through the windows stuff yet, but believe we should be
	 //using mmlAppPixmap and mmlDisplayPixmap for it, too; just carry around
	 //some unused fields
	mmlAppPixmap				mAppPixmap;

	// when we do have a bitmap, this pointer duplicates the value in the bitmap
	//REMOVE void						*mpAppFrame;

	// not sure if we should use an array of mmlDisplayPixmaps or just allocate
	// two buffers in one call to InitPixmap().  I'm assuming 2 bufs in one
	// mmlDisplayPixmap will work for the time being
	mmlDisplayPixmap			mDisplayPixmap;
	void						*mpDispFrame[2];

	
	// method for getting bitmap color table and local color table to match
	void SynchBitmapToColorTable (hsGBitmap* pixels);


public:
	NuonRaster(NuonChannelManager *mgr, unsigned ctrlFlags, unsigned whichChannel, 
						int width,int height,int depth, int sourceDepth,
						void *frameBuf = NULL, void *appBuf = NULL );
	~NuonRaster();

	int SetDepth(int depth, void* memP = NULL);
	int SetSourcePixmap( int depth, int width, int height, void* bitmapP = NULL, 
							NuonAglColorTable *colorsP = NULL);
	int GetDepth(void) { return mDepth; }
	int GetSourceDepth (void) { return mSourceDepth; }
	mmlDisplayPixmap* GetDisplayPixmapP(void){ return &mDisplayPixmap; }

	void* GetLocalRamAdr(void) { return mChannelMgr->GetLocalRamAdr(); }

	// redefine SetPixels from hsGRasterDevice in order to make sure the
	// color table gets updated; call hsGRasterDevice::SetPixels() to
	// actually do the work
	// this is actually tricky, because bitmaps can have color tables
	// attached to them.  NuonRaster, because it keeps its own color table,
	// MUST decide what to do with this new bitmap's table
	
	// set/clear setup flags to indicate what to do about:
	//  * changing the color table with a new bitmap
	//  * differing app and display pixmap sizes/depths when a new bitmap
	//    is attached
	//  * double-buffering
	//  * who does cleanup
	//  caller's responsibility not to perturb other flags
	void SetFlags (unsigned ctrlFlags) { mCtrlFlags = ctrlFlags; }
	const unsigned GetFlags () { return mCtrlFlags; }

	// override the hsGBitmap method; use the above flag setting to
	// control the color table
	virtual void SetPixels(const hsGBitmap* pixels);

	// offer an alternative that explicitly says what to do with the color
	// table
    int SetClut(NuonYccColorTable* colorTable);
	NuonYccColorTable* GetClut() { return mClut; } 
	void SetDefaultClut ();
	void SetCaptureColorTable(NuonYccColorTable* colorTable);
	void UseCaptureColorTable(void);

	// redefinition of Erase functions necessary to make sure an AGL color table
	// exists, or convert to use Nuon color table
	// indexed erase -- does nothing gracefully if no color table
	void			Erase (UInt8 colorIndex);
	//
	void			Erase();
 	virtual void	Erase(const hsGColor* color);
	/// agl alpha = 0xFFFF
	void			Erase(hsGColorValue red, hsGColorValue green, hsGColorValue blue);
	///
	void			Erase(hsGColorValue alpha, hsGColorValue red, hsGColorValue green, hsGColorValue blue);

	void			DrawTransparentRect (hsIntRect *rect);

	// the following move to NuonChannelManager
		// void Show(int alpha);
		// void Hide(void);
		// void SetDispFrame (void* memP);

	void CopyDisplay(hsIntRect *rect,int x,int y);

	// capture video for dithering to osd
	void CaptureVideo(int x,int y,int width,int height,int letterboxP, bool useYUV) 
	{ 
		if (!mDitherColorTable)
				mDitherColorTable = NuonYccColorTable::MakeCaptureColorTable(COLOR_TABLE_DEPTH, useYUV);				
		mChannelMgr->CaptureVideo(x, y, width, height, letterboxP, 
									&fPixels, mDitherColorTable->GetAglColorTable(), useYUV);
	}
	
	// for all of these, when we're not double-buffered, flipping does nothing
	// gracefully and the backbuffer is the display buffer
	void Flip(void);						 // swap back & front buffers
    void Update(void);                // this will write backbuffer and flip
	void rasterize(hsIntRect *rect = NULL);  // write backbuffer

	void Show (const int alpha = 0);

#if defined (NO_PRINT)
#else
	void PrintState (char *objectName, unsigned nuonColors = 0, unsigned aglColors = 0);
#endif
};

#endif /* NUONRASTER_H */
