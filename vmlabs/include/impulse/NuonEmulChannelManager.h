/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 * 1/25/01 kml
 *
 * NuonEmulChannelManager is a derived class of NuonChannelManager
 * which uses runtime library calls to emulate Nuon hardware-dependent 
 * operations
 */

#ifndef NuonEmulChannelManager_DEFINED
#define NuonEmulChannelManager_DEFINED

#include "NuonChannelManager.h"


#ifndef BYTE
typedef unsigned char BYTE;
#endif 

//#pragma pack( push, before_NuonRgbquad )
//#pragma pack(8)

// Microsoft's standard definition for a 32-bit color pixel, from wingdi.h
typedef struct tagNUON_RGBQUAD {
        BYTE    rgbBlue;
        BYTE    rgbGreen;
        BYTE    rgbRed;
        BYTE    rgbReserved;
} NUON_RGBQUAD;
//#pragma pack( pop, before_NuonRgbquad )



// manager for a PC-based emulation of Impulse on Nuon
class NuonEmulChannelManager : public NuonChannelManager {

	NUON_RGBQUAD *mDisplayBufP;
	unsigned mSelfCreateDisplayBuf;
	int		 mWidth;     
	int		 mHeight;    
	NuonYccColor   mOsdClut[COLOR_TABLE_DEPTH];
	int		 mImageAlpha;

// private method for copying rectangles between source and dest pixmaps
void CopyRect (mmlAppPixmap *appP, mmlDisplayPixmap *sP,
				const hsIntRect *rect, const int bytesPerPixel);

// returns nonzero on failure, 0 on success
// receives both depth and pixel format
// private method
virtual int InitPixmaps (mmlAppPixmap *sP, void *appMem, 
		 int wide, int high, int depth, mmlPixFormat pix, int numBuffers);

// creates or recreates the display buffer
int MakeBuf (int width, int height);

// renders the pixmaps(s) into the composite display buffer
void RenderToDisplay (const hsIntRect *rect,
				mmlDisplayPixmap *sP, const unsigned channel);


public:
	// if no input bitmap info, object will build its own
	NuonEmulChannelManager( NUON_RGBQUAD *displayBufP = NULL );

	~NuonEmulChannelManager( );

	NUON_RGBQUAD *GetDisplayBuf () { return mDisplayBufP; }

	// Show and Hide take an (optional) argument of channels
	// For Show and Hide, setting a channels flag for an inactive (uninitialized) channel 
	// is acknowledged in the return status but otherwise ignored as follows:
	// returns 0 on success, <0 on failure, >0 on one or both requested channels ignored
	// Config checks mmlDisplayPixmap::dmaFlags to verify pixmap can be displayed on
	// the selected channel
	
	// configure a channel before a call to Show()
	// this is where the check for allowed pixel format(s) is done
	virtual int ConfigChannel (const unsigned user, mmlDisplayPixmap *sP, const unsigned channel = kChOsd);

	// show channels that have been configured with a call to ConfigChannel
	virtual int Show (const unsigned channels = (kChOsd | kChMain), 
						 const int alpha = 0);

	// Loads the OSD hardware Clut
	virtual void SetClut (const NuonYccColorTable *clut);
	
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


#if defined (NO_PRINT)
#else
	virtual void PrintState (char *objectName);
#endif

	void GenerateBmpFile (FILE *fBmp);
};

#endif  //NuonEmulChannelManager_DEFINED



#if 0
#ifdef WIN32
	 HDC                   mDC;
    void SetDC(HDC hDC) { mDC = hDC; }
#endif
#endif

