/*
 * TT_PRVT.H
 * Copyright (C) 1989-1998 all rights reserved by Type Solutions, Inc. Plaistow, NH, USA.
 * Author: Sampo Kaasila
 *
 * This software is the property of Type Solutions, Inc. and it is furnished
 * under a license and may be used and copied only in accordance with the
 * terms of such license and with the inclusion of the above copyright notice.
 * This software or any other copies thereof may not be provided or otherwise
 * made available to any other person or entity except as allowed under license.
 * No title to and ownership of the software or intellectual property
 * therewithin is hereby transferred.
 *
 * This information in this software is subject to change without notice
 */
 /* Private TrueType structures */
#ifndef __T2K_TT_PRVT__
#define __T2K_TT_PRVT__

typedef struct {
	uint32	leftRightIndex; /* leftIndex << 16 || rightIndex */
	int16	value; 
} kernPair0Struct;

typedef struct {
	/* private */
	tsiMemObject *mem;
	/* public */
	uint16 nPairs;
	uint16 searchRange;
	uint16 entrySelector;
	uint16 rangeShift;
	kernPair0Struct *pairs;
} kernSubTable0Data;

typedef struct {
	/* private */
	tsiMemObject *mem;
	/* public */
	uint16	version;
	/* uint16	length; OLD */
	int32 	length;
	uint16	coverage;
	/* kernSubTable0Data *data; */
	void *data;
} kernSubTable;

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	/* public */
	uint16	version;
	long	nTables;
	
	kernSubTable **table; /* kernSubTable *table[] */
} kernClass;

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	/* public */
	long	tag;
	long	checkSum;
    long	offset;
	long	length;
} sfnt_DirectoryEntry;

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	
	/* public */
	int		version;			/* int32  : 0x10000 (1.0)					*/
	short	numOffsets;			/* uint16 : number of tables				*/
	short	searchRange;		/* uint16 : (max2 <= numOffsets)*16			*/
	short	entrySelector;		/* uint16 : log2(max2 <= numOffsets)		*/
	short	rangeShift;			/* uint16 : numOffsets*16-searchRange		*/
	sfnt_DirectoryEntry **table;	/* sfnt_DirectoryEntry : *table[numOffsets] 	*/
} sfnt_OffsetTable;


/* --- */
typedef struct {
	uint16	platformID;
	uint16	specificID;
	uint32	offset;
} sfnt_platformEntry;

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	int16 version;
	int16 numEncodingTables;
	
	sfnt_platformEntry **platform; /* *entries[numEncodingTables] */
	uint8 *cmapData;
	long length;
	
	int16 preferedEncodingTable;
	uint16 preferedFormat;

#define NUM_FIGURES 10	
	uint16 figIndex[NUM_FIGURES];
	
	/* public */
} cmapClass;
/* --- */

typedef struct {
	/* private */
	tsiMemObject *mem;
	uint32 version;
	/* public */
	uint32 directoryCount;
	uint32 *tableOffsets;
} ttcfClass;
/* --- */

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	
	/* public */
    int32		version;			/* for this table, set to 1.0 */
    int32		fontRevision;		/* For Font Manufacturer */
	int32		checkSumAdjustment;
	int32		magicNumber; 		/* signature, should always be 0x5F0F3CF5  == MAGIC */
	int16		flags;
	int16		unitsPerEm;			/* Specifies how many in Font Units we have per EM */

	int32		created_bc;
	int32		created_ad;
	int32		modified_bc;
	int32		modified_ad;

	/** This is the font wide bounding box in ideal space
	(baselines and metrics are NOT worked into these numbers) **/
	int16		xMin;
	int16		yMin;
	int16		xMax;
	int16		yMax;

	int16		macStyle;				/* Macintosh style word */
	int16		lowestRecPPEM; 			/* lowest recommended pixels per Em */

	/* 0: fully mixed directional glyphs, */
	/* 1: only strongly L->R or T->B glyphs, -1: only strongly R->L or B->T glyphs, */
	/* 2: like 1 but also contains neutrals, -2: like -1 but also contains neutrals */
	int16		fontDirectionHint;

	int16		indexToLocFormat;		/* 0 for short, 1 for long */
	int16		glyphDataFormat;		/* 0 for current format */
} headClass;

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	
	/* public */
    int32		version;			/* for this table, set to 1.0 */
	int16		Ascender;
	int16		Descender;
	int16		LineGap;
	
	uint16		advanceWidthMax;
	int16 		minLeftSideBearing;
	int16 		minRightSideBearing;
	int16		xMaxExtent;
	
	int16		caretSlopeRise;
	int16		caretSlopeRun;
	
	int16 		reserved1;
	int16 		reserved2;
	int16 		reserved3;
	int16 		reserved4;
	int16 		reserved5;
	
	int16		metricDataFormat;
	uint16		numberOfHMetrics;
} hheaClass;


typedef struct {
	/* private */
	tsiMemObject *mem;
	
	/* public */
	int32 numGlyphs;
	int32 numberOfHMetrics;
	int16 *lsb;
	uint16 *aw;
} hmtxClass;

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	
	/* public */
	int32	version;				/* for this table, set to 1.0 */
	int16	numGlyphs;
	int16	maxPoints;				/* in an individual glyph */
	int16	maxContours;			/* in an individual glyph */
	int16	maxCompositePoints;		/* in an composite glyph */
	int16	maxCompositeContours;	/* in an composite glyph */
	int16	maxElements;			/* set to 2, or 1 if no twilightzone points */
	int16	maxTwilightPoints;		/* max points in element zero */
	int16	maxStorage;				/* max number of storage locations */
	int16	maxFunctionDefs;		/* max number of FDEFs in any preprogram */
	int16	maxInstructionDefs;		/* max number of IDEFs in any preprogram */
	int16	maxStackElements;		/* max number of stack elements for any individual glyph */
	int16	maxSizeOfInstructions;	/* max size in bytes for any individual glyph */
	int16	maxComponentElements;	/* number of glyphs referenced at top level */
	int16	maxComponentDepth;		/* levels of recursion, 1 for simple components */
} maxpClass;


typedef struct {
	/* private */
	tsiMemObject *mem;
	
	/* public */
	
	int32 *offsets;
	int n;
	short indexToLocFormat;

} locaClass;


#endif /* __T2K_TT_PRVT__ */

