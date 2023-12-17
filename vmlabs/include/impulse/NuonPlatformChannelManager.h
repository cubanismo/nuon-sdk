/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 * 1/25/01 kml
 *
 * NuonPlatformChannelManager is a derived class of NuonChannelManager
 * which uses BIOS calls for hardware-dependent operations
 */

#ifndef NuonPlatformChannelManager_DEFINED
#define NuonPlatformChannelManager_DEFINED

#include "NuonChannelManager.h"



// channel manager for games (bios-controlled)
class NuonPlatformChannelManager : public NuonChannelManager {

protected:
	// system resources
	static mmlSysResources mSysRes;
	mmlGC *mpGC;
	
// returns nonzero on failure, 0 on success
// receives both depth and pixel format
// private method
virtual int InitPixmaps (mmlAppPixmap *sP, void *appMem, 
		 int wide, int high, int depth, mmlPixFormat pix, int numBuffers);

public:
	NuonPlatformChannelManager();
	virtual ~NuonPlatformChannelManager();

	// accessor for system resources: actual data type returned is a function of the
	// platform
	virtual const void *GetSystemResources (void) { return (void*) &mSysRes;  }

	virtual void* GetLocalRamAdr (void) { return mSysRes.intDataAdr; }

	// Loads the OSD hardware Clut
	virtual void SetClut (const NuonYccColorTable *clut) = 0;
	
	// Call with a new whichBuf to do a buffer flip (buffers all attached to the mmlDisplayPixmap
	// whichBuf must be less than the number of buffers allocated in the call to InitPixmaps
	virtual void SetDisplayFrame (mmlDisplayPixmap *sP, 
						 const unsigned channel = kChOsd, const unsigned whichBuf = 0);
	// Allocate pixmap(s)
	// returns mml status or Windows equiv (check return type)
	// uses the address specified in appMem or dispMem if not null
	
	// returns nonzero on failure, 0 on success
	// specifying depth defaults pixel format to RGBA
	virtual int InitPixmaps (mmlAppPixmap *sP, void *appMem, int wide, int high, 
						 int depth, int numBuffers = 1);

	virtual int InitPixmaps (mmlAppPixmap *sP, void *appMem, int wide, int high,
						 mmlPixFormat pix, int numBuffers = 1);

	// returns nonzero on failure, 0 on success
	// specifying depth defaults pixel format to YCCA
	virtual int InitPixmaps( mmlDisplayPixmap* sP, void *dispMem, int wide, int high, 
						 int depth, int numBuffers = 1);

	virtual int InitPixmaps( mmlDisplayPixmap* sP, void *dispMem, int wide, int high,
						 mmlPixFormat pix, int numBuffers = 1);

	// these do the same thing, but free the caller from needing to cast the Pixmap type
	virtual void ReleasePixmaps (mmlAppPixmap *sp, int numBuffers = 1);
	virtual void ReleasePixmaps (mmlDisplayPixmap *sp, int numBuffers = 1);

	// raster buffer (copy) operations
	virtual void CopyDisplay(mmlDisplayPixmap *sp, hsIntRect *rect, int x, int y, 
							const unsigned channel = kChOsd);
	virtual void CopyRect8 (mmlAppPixmap *appP, mmlDisplayPixmap *sP,
							const hsIntRect *rect, const unsigned channel = kChOsd);
	virtual void CopyRect16 (mmlAppPixmap *appP, mmlDisplayPixmap *sP,
							const hsIntRect *rect, const unsigned channel = kChOsd);
	virtual void CopyRect32 (mmlAppPixmap *appP, mmlDisplayPixmap *sP,
							const hsIntRect *rect, const unsigned channel = kChOsd);
	virtual void CopyTile (mmlDisplayPixmap *sP, hsGBitmap *bpImage, 
							NuonYccColor *colorbufAligned1024, const unsigned channel);
	virtual void DisplayPixmapDirectColorFill (mmlDisplayPixmap *sP,
								hsIntRect *r, NuonYccColor color, const unsigned channel);


#if defined (NO_PRINT)
#else
	virtual void PrintState (char *objectName);
#endif
};

#endif  //NuonPlatformChannelManager_DEFINED



