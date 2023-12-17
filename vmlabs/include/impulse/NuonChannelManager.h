/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 * 1/25/01 kml
 *
 * NuonChannelManager is a base class intended to provide a
 * target-independent set of methods for initializing the system
 * for graphics, initializing channels, allocating pixmaps, etc.
 * The derived classes actually used will be for BIOS (Games), PE,
 * Windows emulation, and perhaps other targets.
 */

#ifndef NuonChannelManager_DEFINED
#define NuonChannelManager_DEFINED

#ifndef WIN32
#include <nuon/mml2d.h>
#else 
#include "mml2d.h"
#endif
#include "NuonError.h"
#include "HSScan.h"
#include "NuonYccColorTable.h"

#ifndef WIN32
#include "auxvid.h"
#endif

enum {kChOsd = 0x1, kChMain = 0x2};
enum {kSysInitComplete = 0x01, 
	  	kOsdActive =       0x02, 
		kMainActive =   	 0x04,
		kOsdConfigured =   0x08,
		kMainConfigured =  0x10,
		kOsdVisible =      0x20,
		kMainVisible =     0x40
};


// note there are pure virtual functions in NuonChannelManager; it can only be used as
// a base class

class NuonChannelManager {

protected:
	unsigned mFlags;   // whether sys has been initialized, which channels are active, visible
	unsigned mCtrlFlags;   //instructions for treating unowned channels as visible
	unsigned mUsers;       // who has configured a channel and not released it
	unsigned mWhoOwnsMain;
	unsigned mWhoOwnsOsd;

	// local pointers of the OSD and MAIN channel buffers
	mmlDisplayPixmap   *mMainPixmapP;
	mmlDisplayPixmap   *mOsdPixmapP;

public:
	// the constructor is where (for Nuon) we call mmlPowerUpGraphics()
	// something equivalent for Windows emulation
	NuonChannelManager();

	// these only have an effect on channels which are not owned by the channel manager
	virtual unsigned TreatAsVisible (const unsigned channels);
	virtual unsigned TreatAsNotVisible (const unsigned channels);

	// accessor for system resources: actual data type returned is a function of the
	// platform, not always needed
	virtual const void *GetSystemResources (void) { return NULL; }

	// Log the user
	virtual unsigned InitChannel (const unsigned channel = kChOsd);
	virtual void* GetLocalRamAdr (void) { return NULL; }

	// Show and Hide take an (optional) argument of channels
	// For Show and Hide, setting a channels flag for an inactive (uninitialized) channel 
	// is acknowledged in the return status but otherwise ignored as follows:
	// returns 0 on success, <0 on failure, >0 on one or both requested channels ignored
	// Config should check mmlDisplayPixmap::dmaFlags to verify pixmap can be displayed on
	// the selected channel
	
	// configure a channel before a call to Show()
	// this is where the check for allowed pixel format(s) is done
	virtual int ConfigChannel (const unsigned user, mmlDisplayPixmap *sP, const unsigned channel = kChOsd);

	// combines configure and show with calls to those functions, useful if only one channel is used
	// setting sP to NULL causes the manager to show whatever the channel is configured for
	// setting user to 0 forces config, but also doesn't record the user -- better to call ConfigChannel separately
	// if you want to force it
	virtual int Show (const unsigned user, mmlDisplayPixmap *sP, const unsigned channel, const int alpha);

	// stupid Show -- assumes config is done and correct-- devices should not use this
	virtual int Show (const unsigned channels, const int alpha);

	// hide channels
	virtual int Hide (const unsigned channels = (kChOsd | kChMain));

	// surrender channels
	virtual int ReleaseChannel (const unsigned user, const unsigned channel = kChOsd);

	// Loads the OSD hardware Clut
	virtual void SetClut (const NuonYccColorTable *clut) = 0;
	
	// Call with a new whichBuf to do a buffer flip (buffers all attached to the mmlDisplayPixmap
	// whichBuf must be less than the number of buffers allocated in the call to InitPixmaps
	virtual void SetDisplayFrame (mmlDisplayPixmap *sP, 
						 const unsigned channel = kChOsd, const unsigned whichBuf = 0) = 0;

	// Allocate pixmap(s)
	// returns mml status or Windows equiv (check return type)
	// uses the address specified in appMem or dispMem if not null
	
	// returns nonzero on failure, 0 on success
	// specifying depth defaults pixel format to RGBA
	virtual int InitPixmaps (mmlAppPixmap *sP, void *appMem, int wide, int high, 
						 int depth, int numBuffers = 1) = 0;

	virtual int InitPixmaps (mmlAppPixmap *sP, void *appMem, int wide, int high,
						 mmlPixFormat pix, int numBuffers = 1) = 0;

	// returns nonzero on failure, 0 on success
	// specifying depth defaults pixel format to YCCA
	virtual int InitPixmaps( mmlDisplayPixmap* sP, void *dispMem, int wide, int high, 
						 int depth, int numBuffers = 1) = 0;

	virtual int InitPixmaps( mmlDisplayPixmap* sP, void *dispMem, int wide, int high,
						 mmlPixFormat pix, int numBuffers = 1) = 0;

	// these do the same thing, but free the caller from needing to cast the Pixmap type
	virtual void ReleasePixmaps (mmlAppPixmap *sp, int numBuffers = 1) = 0;
	virtual void ReleasePixmaps (mmlDisplayPixmap *sp, int numBuffers = 1) = 0;

	// raster buffer operations
	virtual void CopyDisplay(mmlDisplayPixmap *sp, hsIntRect *rect, int x, int y, 
							const unsigned channel = kChOsd) = 0;
	virtual void CopyRect8 (mmlAppPixmap *appP, mmlDisplayPixmap *sP,
							const hsIntRect *rect, const unsigned channel = kChOsd) = 0;
	virtual void CopyRect16 (mmlAppPixmap *appP, mmlDisplayPixmap *sP,
							const hsIntRect *rect, const unsigned channel = kChOsd) = 0;
	virtual void CopyRect32 (mmlAppPixmap *appP, mmlDisplayPixmap *sP,
							const hsIntRect *rect, const unsigned channel = kChOsd) = 0;
	virtual void CopyTile (mmlDisplayPixmap *sP, hsGBitmap *bpImage, 
							NuonYccColor *colorbufAligned1024, const unsigned channel) {}
	virtual void DisplayPixmapDirectColorFill (mmlDisplayPixmap *sP,
							hsIntRect *r, NuonYccColor color, const unsigned channel){}


	
	/* CaptureVideo - capture video to a 16bpp app pixmap (only useful for player; need stub for emul) */
	virtual void CaptureVideo(int x,int y,int width,int height,int letterboxP, 
							hsGBitmap *bitmap, hsGColorTable *ditherAglTable, bool useYUV) {}


#if defined (NO_PRINT)
#else
	virtual void PrintState (char *objectName);
#endif
};


// Nuon Channel Managers -- Move these to different header files as they get created
#if 0
// manager for the presentation engine
class NuonPeChannelManager: public NuonChannelManager {};

#endif

#endif  //NuonChannelManager_DEFINED



