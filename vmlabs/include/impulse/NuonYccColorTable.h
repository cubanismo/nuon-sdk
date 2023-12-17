
/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 *
 * The NuonAglColorTable is not yet implemented.  It is intended as a
 * complete superset of hsGColorTable, with some expansion to handle
 * YCC color space and skewed palettes.
 *
 * The NuonYccColorTable class encapsulates a simple CLUT8 Nuon-format
 * YCCA color table with an optional associated AGL-format color table
 * (in either YCC or RGB format, depending on the needs of the user)
 * and a package of methods for setting a default table, setting a dithered
 * table, etc. 
 *
 * See comments in NuonRaster.h for an overview of how this class fits
 * into the raster device scheme.
 *
 * 2/8/01 kml
*/

#ifndef NuonYccColorTable_DEFINED
#define NuonYccColorTable_DEFINED

#include "NuonError.h"
#include "hsGColorTable.h"

#define COLOR_TABLE_DEPTH 256
#define USE_AGL_COUNT -1

// a modification of hsGColorTable that has better support for YCC and alpha
// (tbd 1/30/01 kml)
//class NuonAglColorTable : public hsGColorTable {
//};
typedef hsGColorTable NuonAglColorTable;


// aka nuicolor and mmlcolor
typedef unsigned long    NuonYccColor; 

// control flags
enum {	kInitDefaultTable = 0x1,     
		kMakeYccAglTable = 0x2,  
		kUseSafeColors = 0x4
};


// mFlags
enum {	kAglTableIsYcc = 0x1, 
		kColorIsSafe = 0x2,
		kAglTableExistence = 0x10000
};

class NuonYccColorTable: public hsRefCnt {

protected:
	unsigned mFlags;  // color safety, Agl table type at time of build
	unsigned mCtrlFlags;  // need to keep the instruction set as well as the state
	int mCount;  			//danger -- may be redundant info with mAglTable.fCount;
							// when the value is -1, use mAglTable.fCount

	NuonAglColorTable*	mAglTable;
	// if kYccAglTable flag is set, mAglTable is YCC format; else RGB format
	
	NuonYccColor   mNuonTable[COLOR_TABLE_DEPTH];
	// if the kUseSafeColors flag is set at the time either of these tables is
	// built, they will be modified if necessary to be NTSC-colorsafe
	

public:
	NuonYccColorTable (unsigned ctrlFlags = 0);  //  (kMakeYccAglTable | kUseSafeColors)

	~NuonYccColorTable();

	// alternate set/clear of control flags (only changes specified flag(s))
	void Set (unsigned ctrlFlags) { mCtrlFlags |= ctrlFlags; }
	void Clear (unsigned ctrlFlags) { mCtrlFlags &= ~ctrlFlags; }

	// status info 
	unsigned GetStatus () { return (mAglTable ? mFlags | kAglTableExistence : mFlags); }

	// get count of colors
	inline unsigned GetCount() const
		{ return  ((mAglTable) ? mAglTable->GetCount() : mCount); }

	int SetCount (const unsigned count);

	// specify the color table in AGL format
	// causes the NuonYccColor table to be created (default translucency is opaque)
	// returns nonzero on error
	int SetColors (const hsColor32 aglColors[], unsigned srcStatusFlags, const unsigned count,
						const unsigned startIndex = 0, UInt8 nAlphaVals[] = NULL);
	int SetColors (const hsColor32 aglColors[]) // must specify count first
						{ return SetColors (aglColors, 0, GetCount()); }


	// specify the color table directly  (color and translucency) 
	// does not cause the NuonAglColorTable to be built immediately (don't use the memory
	// until it's needed)
	// returns nonzero on error
	int SetColors (const NuonYccColor nColors[], unsigned srcStatusFlags, const unsigned count,
						 const unsigned startIndex = 0);
	int SetColors (const NuonYccColor nColors[])   // must specify count first
						{ return SetColors (nColors, 0, GetCount()); }

	// specify translucency; (count + startIndex) must be  <= current color count
	// returns nonzero on error
	int SetAlphaVals (UInt8 nAlphaVals[], const unsigned count,
						 								const unsigned startIndex = 0);
	int SetAlphaVals (UInt8 nAlphaVals[])
						{ return SetAlphaVals (nAlphaVals, GetCount()); }

	// get access to colors
	const NuonYccColor* PeekColors()  const { return mNuonTable;  }

	// get access to the color tables
	NuonAglColorTable* GetAglColorTable();   // bulds a NuonAglColorTable if one doesn't
												 // exist AND a NuonYccColor array does. 
	// used to force a rebuild of the AGL color table the next time it is accessed
	void ClearAglColorTable() 
		{ if (mAglTable)  { mCount = mAglTable->GetCount(); delete mAglTable; }   }

	// make a table available for writing externally	
	NuonYccColor* GetNuonColorTableForWriting() { ClearAglColorTable(); return mNuonTable; }
				

	const NuonYccColor& IndexToColor (unsigned i) const
						{ hsAssert ((i < ((mAglTable) ? mAglTable->GetCount() : (unsigned) mCount)), 
						"bad color table count"); 
						  return mNuonTable[i]; }

	const NuonYccColor& operator[] (unsigned i) const 
						{ hsAssert ((i < ((mAglTable) ? mAglTable->GetCount() : (unsigned) mCount)), 
						"bad color table count"); 
						  return mNuonTable[i]; }

	// access the color table(s) directly for other variants on ColorToIndex
	// not sure how to implement this yet, anyhow-- how to deal with transparency?
	UInt8	ColorToIndex(const NuonYccColor color32);
	UInt8	ColorToIndex(const hsGColor *acolor);

	void SetDefaultColorTable();
	void SetDefaultColorTable1();

	/*
	friend int operator==(const NuonYccColorTable& a, const NuonYccColorTable& b);
	*/


	// dither ycc16 stuff
	static NuonYccColorTable *MakeCaptureColorTable(unsigned numcolors, bool useYUV);

	// void CaptureVideo(int x,int y,int width,int height,int letterboxP);
		// void UseCaptureColorTable(void);

#if defined (NO_PRINT)
#else
	// state (for debug)
	void PrintState (char *objectName, unsigned nuonColors = 0, unsigned aglColors = 0);
#endif
};

//////////////////////////////////////////////////////////////////////////////////////////////////////
// some generally useful color conversion routines

// map a YCrCb color to RGB
hsColor32 MapYccToRgb(NuonYccColor color);

// map an RGB color to YCrCb
NuonYccColor MapRgbToYcc (hsColor32 color);

// clean hsColor32 copy
inline void CopyColor32 (hsColor32 &dest, const hsColor32 &src);



#endif // #defined  NuonYccColorTable
