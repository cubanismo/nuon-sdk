/*
 * Copyright (C) 1999 all rights reserved by AlphaMask, Inc. Cambridge, MA USA
 *
 * This software is the property of AlphaMask, Inc. and it is furnished
 * under a license and may be used and copied only in accordance with the
 * terms of such license and with the inclusion of the above copyright notice.
 * This software or any other copies thereof may not be provided or otherwise
 * made available to any other person or entity except as allowed under license.
 * No title to and ownership of the software or intellectual property
 * therewithin is hereby transferred.
 *
 * ALPHAMASK MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY
 * OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. ALPHAMASK SHALL NOT BE LIABLE FOR
 * ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
 * DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 *
 * This information in this software is subject to change without notice
*/

#ifndef hsSfntDefined
#define hsSfntDefined

#include "hsTypes.h"
 
typedef UInt32 hsSfntTableTag;

struct hsSfntDirectoryEntry {
	hsSfntTableTag	tableTag;
	UInt32			checkSum;
	UInt32			offset;
	UInt32			length;
};
typedef struct hsSfntDirectory hsSfntDirectory;

/* The search fields limits numOffsets to 4096. */
struct hsSfntDirectory {
	hsSfntTableTag	format;
	UInt16			numOffsets;				/* number of tables */
	UInt16			searchRange;			/* (max2 <= numOffsets)*16 */
	UInt16			entrySelector;			/* log2(max2 <= numOffsets) */
	UInt16			rangeShift;				/* numOffsets*16-searchRange*/
	struct hsSfntDirectoryEntry table[1];	/* table[numOffsets] */
};
typedef struct hsSfntDirectoryEntry hsSfntDirectoryEntry;

enum {
	sizeof_hsSfntDirectory		= 12
};

/* Cmap - character id to glyph id gxMapping */
#define kCmapFontTableTag			hsFourByteTag('c', 'm', 'a', 'p')

struct hsSfntCMapSubHeader {
	UInt16		format;
	UInt16		length;
	UInt16		languageID;		/* base-1 */
};
typedef struct hsSfntCMapSubHeader hsSfntCMapSubHeader;

enum {
	sizeof_hsSfntCMapSubHeader = 6
};

struct hsSfntCMapEncoding {
	UInt16		platformID;		/* base-0 */
	UInt16		scriptID;		/* base-0 */
	UInt32		offset;
};
typedef struct hsSfntCMapEncoding hsSfntCMapEncoding;

enum {
	sizeof_hsSfntCMapEncoding = 8
};

struct hsSfntCMapHeader {
	UInt16				version;
	UInt16				numTables;
	struct hsSfntCMapEncoding	encoding[1];
};
typedef struct hsSfntCMapHeader hsSfntCMapHeader;

enum {
	sizeof_hsSfntCMapHeader = 4
};

/* Name table */
#define kNameFontTableTag			hsFourByteTag('n', 'a', 'm', 'e')

struct hsSfntNameRecord {
	UInt16	platformID;		/* base-0 */
	UInt16	scriptID;			/* base-0 */
	UInt16	languageID;		/* base-0 */
	UInt16	nameID;			/* base-0 */
	UInt16	length;
	UInt16	offset;
};
typedef struct hsSfntNameRecord hsSfntNameRecord;

enum {
	sizeof_hsSfntNameRecord = 12
};

struct hsSfntNameHeader {
	UInt16				format;
	UInt16				count;
	UInt16				stringOffset;
	hsSfntNameRecord	rec[1];
};
typedef struct hsSfntNameHeader hsSfntNameHeader;

enum {
	sizeof_hsSfntNameHeader	= 6
};

#define kSfnt_WildCard	(0xFFFF)		// 16-bits explicitly, so that if we swap it, we get the same thing

enum {
	kNoFontName = kSfnt_WildCard,
	kCopyrightFontName = 0,
	kFamilyFontName,
	kStyleFontName,
	kUniqueFontName,
	kFullFontName,
	kVersionFontName,
	kPostscriptFontName,
	kTrademarkFontName,
	kManufacturerFontName,

	kNoPlatform = kSfnt_WildCard,
	kUnicodePlatform = 0,
	kMacintoshPlatform,
	kISOPlatform_DEAD,
	kMicrosftPlatform,

	kNoScript = kSfnt_WildCard,
	kRomanScript = 0,
	kMicrosoftEncoding = 1,

	kNoLanguage = kSfnt_WildCard,
	kEnglishLanguage = 0
};

//////////////////////////////////////////////////////////////////////////////////////
//	Head table
//

#define kHeadFontTableTag			hsFourByteTag('h', 'e', 'a', 'd')
#define kBhedFontTableTag			hsFourByteTag('b', 'h', 'e', 'd')

struct hsSfntHeadTable {
	hsFixed	version;
	hsFixed	revision;
	UInt32	checkSumAdjustment;
	UInt32	magicNumber;			// 0x5F0F3CF5
	UInt16	flags;
	UInt16	upem;
	UInt32	created[2];
	UInt32	modified[2];
	Int16	xMin;
	Int16	yMin;
	Int16	xMax;
	Int16	yMax;
	UInt16	macStyle;
	UInt16	lowestPPEM;
	Int16	directionHint;
	Int16	indexToLocFormat;
	Int16	glyphDataformat;
};

//////////////////////////////////////////////////////////////////////////////////////
//	Horizontal Header and Metrics tables
//

#define kMaxpFontTableTag			hsFourByteTag('m', 'a', 'x', 'p')

struct hsSfntMaxpTable {
	hsFixed	version;
	UInt16	glyphCount;
	UInt16	maxPoints;
	UInt16	maxContours;
	UInt16	maxComponentPoints;
	UInt16	maxComponentContours;
	UInt16	maxZones;
	UInt16	maxTwilightPoints;
	UInt16	maxStorage;
	UInt16	maxFDefs;
	UInt16	maxIDefs;
	UInt16	maxStack;
	UInt16	maxInstructionSize;
	UInt16	maxComponentElements;
	UInt16	maxComponentDepth;
};

//////////////////////////////////////////////////////////////////////////////////////
//	Horizontal Header and Metrics tables
//

#define kHheaFontTableTag			hsFourByteTag('h', 'h', 'e', 'a')

struct hsSfntHheaTable {
	hsFixed	version;
	Int16	ascent;
	Int16	descent;
	Int16	lineGap;
	UInt16	advanceMax;
	Int16	minLSB;
	Int16	minRSB;
	Int16	maxExtent;
	Int16	caretSlopeRise;
	Int16	caretSlopeRun;
	Int16	caretOffset;
	Int16	reserved[4];
	Int16	hmtxFormat;	// 0
	UInt16	numLongMetrics;
};

#define kHmtxFontTableTag			hsFourByteTag('h', 'm', 't', 'x')

struct hsSfntLongMetrics {
	UInt16	advance;
	Int16	sideBearing;
};

//	short metrics == Int16 sideBearing

//////////////////////////////////////////////////////////////////////////////////////
//	SBit tables
//

#define kBLocFontTableTag			hsFourByteTag('b', 'l', 'o', 'c')
#define kEBLCFontTableTag			hsFourByteTag('E', 'B', 'L', 'C')

#define kBDatFontTableTag			hsFourByteTag('b', 'd', 'a', 't')
#define kBDATFontTableTag			hsFourByteTag('E', 'B', 'D', 'T')

struct hsSfntBigMetric {
	UInt8	height;
	UInt8	width;
	char	horiSBx;
	char	horiSBy;
	UInt8	horiAdvance;
	char	vertSBx;
	char	vertSBy;
	UInt8	vertAdvance;
};

struct hsSfntSmallMetric {
	enum {
		kSizeOf = 5
	};
	UInt8	height;
	UInt8	width;
	char	sbX;
	char	sbY;
	UInt8	advance;
};

struct hsSfntSBitLineMetric {
	char	ascent;
	char	descent;
	UInt8	widMax;
	char	caretSlopeN;
	char	caretSlopeD;
	char	caretOffset;
	char	minLSB;
	char	minRSB;
	char	maxBefore;
	char	maxAfter;
	char	pad[2];		// not in Apple's spec???
};

//	BLOC Index Array Formats
//	1	variable metrics, 4-byte offsets
//	2	shared metric
//	3	variable metrics, 2-byte offsets
//	4	variable metrics, 2-byte offsets, sparse
//	5	shared metric, sparse

struct hsSfntBLOCIndex {
	struct GlyphOffsetPair {
		UInt16	glyphID;
		UInt16	offset;
	};

	UInt16	arrayFormat;
	UInt16	imageFormat;
	UInt32	bdatOffset;
	
	const UInt32*	format1() const { return (const UInt32*)(this + 1); }
	const UInt16*	format3() const { return (const UInt16*)(this + 1); }

	UInt32	format2ImageSize() const
	{
		return hsSWAP32(*(const UInt32*)(this + 1));
	}
	const hsSfntBigMetric& format2Metric() const
	{
		return *(const hsSfntBigMetric*)((const UInt32*)(this + 1) + 1);
	}
	
	UInt32	format4Count() const
	{
		return hsSWAP32(*(const UInt32*)(this + 1));
	}
	const GlyphOffsetPair* format4Pairs() const
	{
		return (const GlyphOffsetPair*)((const UInt32*)(this + 1) + 1);
	}

	UInt32	format5ImageSize() const
	{
		return hsSWAP32(*(const UInt32*)(this + 1));
	}
	const hsSfntBigMetric& format5Metric() const
	{
		return *(const hsSfntBigMetric*)((const UInt32*)(this + 1) + 1);
	}
	UInt32	format5Count() const
	{
		const char* ptr;
		
		ptr = (const char*)this	+ sizeof(*this)
								+ sizeof(UInt32)
								+ sizeof(hsSfntBigMetric);
		return hsSWAP32(*(UInt32*)ptr);
	}
	const GlyphOffsetPair* format5Pairs() const
	{
		const char* ptr;
		
		ptr = (const char*)this + sizeof(*this)
								+ sizeof(UInt32)
								+ sizeof(hsSfntBigMetric)
								+ sizeof(UInt32);
		return (const GlyphOffsetPair*)ptr;
	}
};

//	There are [countSubTables] of these
//	pointed to by offsetSubTable
//
struct hsSfntBLOCSubTable {
	UInt16	firstGlyph;
	UInt16	lastGlyph;
	UInt32	offsetToIndex;	// add to BLOCEntry.offsetSubTable
};

struct hsSfntBLOCEntry {
	enum {
		kHori_SmallMetrics	= 0x01,
		kVert_SmallMetrics	= 0x02
	};	// flags

	UInt32	offsetSubTable;
	UInt32	lengthSubTable;
	UInt32	countSubTables;
	UInt32	colorRef;
	
	hsSfntSBitLineMetric	horiMetric;
	hsSfntSBitLineMetric	vertMetric;
	
	UInt16	startGlyph;
	UInt16	endGlyph;
	UInt8	ppemX;
	UInt8	ppemY;
	UInt8	bitDepth;
	UInt8	flags;
};

#define kSFNT_BLOC_VERSION		((2L) << 16)

struct hsSfntBLOCHead {
	hsFixed		version;
	UInt32		numSizes;
	
	hsSfntBLOCEntry*	entry() { return (hsSfntBLOCEntry*)(this + 1); }
};

//	BDAT image formats
//
//	1	smallMetrics	byteAligned image
//	2	smallMetrics	bitAligned image
//	3	obsolete
//	4	compressed, not supported
//	5	shared (big)	bitAligned image
//	6	bigMetrics		byteAligned image
//	7	bigMetrics		bitAligned image
//	8	smallMetrics	composit, not support (yet)
//	9	bigMetrics		composit, not support (yet)
//


//////////////////////////////////////////////////////////////////////////////////////
//	Global functions
//

class hsSfnt {
public:
	// These take a pointer to the font data

	static UInt32	ComputeSize(const hsSfntDirectory* dir);
	static UInt32	FindTableOffset(const hsSfntDirectory* sfnt, hsSfntTableTag tableTag, UInt32* tableSize = nil);

	static UInt32	FindName(const hsSfntNameHeader* table, UInt16 nameID, UInt16 plat, UInt16 script, UInt16 lang, UInt32* index);	// return length
	static UInt32	GetName(const hsSfntNameHeader* table, UInt32 index, Byte name[]);	// return length
	static hsBool	MatchName(const hsSfntNameHeader* table, UInt16 nameID, UInt16 plat,
								UInt16 script, UInt16 lang, int length, const Byte name[]);

	static const hsSfntCMapSubHeader*	FindCmapSubTable(const hsSfntCMapHeader* cmap, int platformID, int encodingID);
	static int						ApplyCmapSubTable(const hsSfntCMapSubHeader* subHead,
												int length, const void* text,
												hsBool unicodeText, UInt16 glyphArray[]);
};

//////////////////////////////////// Future? ////////////////////////////////

#if 0		// do these later

/* Fvar table - gxFont variations */
enum {
	kVariationFontTableTag		= 'fvar'
};

/* These define each gxFont variation */
struct hsSfntVariationAxis {
	gxFontVariationTag	axisTag;
	Fixed				minValue;
	Fixed				defaultValue;
	Fixed				maxValue;
	short				flags;
	short				nameID;
};
typedef struct hsSfntVariationAxis hsSfntVariationAxis;


enum {
	sizeof_hsSfntVariationAxis	= 20
};

/* These are named locations in gxStyle-space for the user */
struct hsSfntInstance {
	short							nameID;
	short							flags;
	Fixed							coord[1];					/* [axisCount] */
/* room to grow since the header carries a tupleSize field */
};
typedef struct hsSfntInstance hsSfntInstance;


enum {
	sizeof_hsSfntInstance			= 4
};

struct hsSfntVariationHeader {
	Fixed					version;					/* 1.0 Fixed */
	unsigned short				offsetToData;				/* to first axis = 16*/
	unsigned short				countSizePairs;				/* axis+inst = 2 */
	unsigned short				axisCount;
	unsigned short				axisSize;
	unsigned short				instanceCount;
	unsigned short				instanceSize;
/* ƒother <count,size> pairs */
	struct hsSfntVariationAxis	axis[1];					/* [axisCount] */
	struct hsSfntInstance		instance[1];				/* [instanceCount]  ƒother arrays of data */
};
typedef struct hsSfntVariationHeader hsSfntVariationHeader;


enum {
	sizeof_hsSfntVariationHeader	= 16
};

/* Fdsc table - gxFont descriptor */
enum {
	kDescriptorFontTableTag		= 'fdsc'
};

struct hsSfntDescriptorHeader {
	Fixed			version;					/* 1.0 in Fixed */
	long				descriptorCount;
	gxFontDescriptor	descriptor[1];
};
typedef struct hsSfntDescriptorHeader hsSfntDescriptorHeader;


enum {
	sizeof_hsSfntDescriptorHeader	= 8
};

/* Feat Table - layout feature table */
enum {
	kFeatureFontTableTag			= 'feat'
};

struct hsSfntFeatureName {
	unsigned short					featureType;
	unsigned short					settingCount;
	long							offsetToSettings;
	unsigned short					featureFlags;
	unsigned short					nameID;
};
typedef struct hsSfntFeatureName hsSfntFeatureName;

struct hsSfntFontRunFeature {
	unsigned short					featureType;
	unsigned short					setting;
};
struct hsSfntFeatureHeader {
	long							version;					/* 1.0 */
	unsigned short					featureNameCount;
	unsigned short					featureSetCount;
	long							reserved;					/* set to 0 */
	struct hsSfntFeatureName			names[1];
	struct gxFontFeatureSetting		settings[1];
	struct hsSfntFontRunFeature		runs[1];
};
typedef struct hsSfntFeatureHeader hsSfntFeatureHeader;

/* OS/2 Table */

enum {
	kOs2FontTableTag				= 'OS/2'
};

/*  Special invalid glyph ID value, useful as a sentinel value, for example */
enum {
	nonGlyphID					= 65535
};



class hsSfnt {
public:
	// These take a pointer to the font data

	static UInt32	ComputeSize(const hsSfntDirectory* dir);
	static UInt32	FindTableOffset(const hsSfntDirectory* sfnt, hsSfntTableTag tableTag, UInt32* tableSize = nil);

	static UInt32	FindName(const hsSfntNameHeader* table, UInt16 nameID, UInt16 plat, UInt16 script, UInt16 lang, UInt32* index);	// return length
	static UInt32	GetName(const hsSfntNameHeader* table, UInt32 index, Byte name[]);	// return length
	static hsBool	MatchName(const hsSfntNameHeader* table, UInt16 nameID, UInt16 plat,
								UInt16 script, UInt16 lang, int length, const Byte name[]);

	static const hsSfntCMapSubHeader*	FindCmapSubTable(const hsSfntCMapHeader* cmap, int platformID, int encodingID);
	static int						ApplyCmapSubTable(const hsSfntCMapSubHeader* subHead,
												int length, const void* text,
												hsBool unicodeText, UInt16 glyphArray[]);
};
#endif	// do these later
#endif
