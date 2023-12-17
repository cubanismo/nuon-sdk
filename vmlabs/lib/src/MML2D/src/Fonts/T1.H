/*
 * T1.H
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
#ifndef __T2K_T1__
#define __T2K_T1__
#ifdef ENABLE_T1


#define ENABLE_DECRYPT
/* #define ENABLE_ENCRYPT */

#ifdef ENABLE_DECRYPT
#define	ENABLE_EITHER_CRYPT
#endif

#ifdef ENABLE_ENCRYPT
#undef	ENABLE_EITHER_CRYPT
#define	ENABLE_EITHER_CRYPT
#endif

#define		kMaxStackValues		32
#define 	T1_MAX_MASTERS 16

typedef struct {
	/* private */
	tsiMemObject *mem;
	uint8 *dataInPtr;
	uint8 *decryptedData;
	long dataLen;
	long eexecGO;
	long charstringsGO;
	
	long x, y;
	long flexOn;
	long flexCount;
	
	
	short	lenIV;
	
	uint8 *encoding;
	short NumCharStrings;
	uint16 *charCode; /* CharStrings big array of character codes */
	uint16 *adobeCode; /* CharStrings big array of character codes */
	uint8  **charData; /* CharStrings big array of pointers to character data */
	short  numSubrs;
	uint8  **subrsData; /* Array of pointers to subroutines */

	short		gNumStackValues;
	long		gStackValues[kMaxStackValues]; /* kMaxStackValues is the max allowed */
	
	
	int numMasters;
	int numAxes;
	F16Dot16 WeightVector[T1_MAX_MASTERS]; /* 0..(numMasters-1) */
	
	/* public */
	GlyphClass *glyph;
	hmtxClass *hmtx;

	long lsbx;
	long lsby;
	long awx;
	long awy;
	
	long upem;
	long maxPointCount;
	long ascent;
	long descent;
	long lineGap;
	long advanceWidthMax;
	F16Dot16 italicAngle;
	
	F16Dot16 m00, m01, m10, m11;
} T1Class;

#ifdef ENABLE_MAC_T1
char * ExtractPureT1FromMacPOSTResources( tsiMemObject *mem, short refNum, unsigned long *length );
#endif
unsigned char *ExtractPureT1FromPCType1( unsigned char *src, unsigned long *length );


T1Class *tsi_NewT1Class( tsiMemObject *mem, uint8 *data, long dataLen );

void ParseCharString( T1Class *t, uint16 charCode );

uint16 tsi_T1GetGlyphIndex( T1Class *t, uint16 charCode );
GlyphClass *tsi_T1GetGlyphByIndex( T1Class *t, uint16 index, uint16 *aw );
GlyphClass *tsi_T1GetGlyphByCharCode( T1Class *t, uint16 charCode, uint16 *aw );

long tsi_T1GetParam( T1Class *t, const uint8 *param, long defaultValue );
F16Dot16 tsi_T1GetFixedParam( T1Class *t, const uint8 *param, F16Dot16 defaultValue );

void tsi_DeleteT1Class( T1Class *t );

#endif /* ENABLE_T1 */


#ifdef ENABLE_CFF

#define Card8	uint8	/* 0..255 		1 byte unsigned number */
#define Card16	uint16	/* 0..65535		2 byte unsigned number */
#define OffSize uint8	/* 1..4 		1 byte unsigned number, specifies the size of an Offset field(s) */
#define SID		uint16	/* 0 - 64999	2 byte string identifier */

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	uint32 baseDataOffset;
	
	OffSize	offSize;
	
	uint32 *offsetArray; /* uint32 offsetArray[ count + 1 ] */ 

	/* public */
	Card16	count;
} CFFIndexClass;

#define CFF_MAX_STACK 64
#define CFF_MAX_MASTERS 16



typedef struct {
	Card16 version;
	Card16 Notice;
	Card16 FullName;
	Card16 FamilyName;
	Card16 Weight;
	
	int32 UniqueId;
	int32 bbox_xmin, bbox_ymin, bbox_xmax, bbox_ymax;
	F16Dot16 italicAngle;
	
	int32 charset;
	int32 Encoding;
	int32 Charstrings;
	int32 PrivateDictSize, PrivateDictOffset;
	
	int numAxes;
	int numMasters;
	int lenBuildCharArray;
	F16Dot16 *buildCharArray; /* the transient array */
	F16Dot16 defaultWeight[CFF_MAX_MASTERS];
	SID NDV; /* SID of the Normalize Design vector subroutine */
	SID CDV; /* SID of the Convert Design vector subroutine */
	/* The registry */
	F16Dot16 reg_WeightVector[CFF_MAX_MASTERS]; 			/* item 0 */
	F16Dot16 reg_NormalizedDesignVector[CFF_MAX_MASTERS];	/* item 1 */
	F16Dot16 reg_UserDesignVector[CFF_MAX_MASTERS];			/* item 2 */
	
	
	/* Font Matrix */
	F16Dot16 m00, m01, m10, m11;
} TopDictInfo;

typedef struct {
	int32 Subr, SubrOffset;
	int32 defaultWidthX;
	int32 nominalWidthX;
} PrivateDictInfo;

#define sidLimit 512

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	InputStream *in;
	
	/* Global font data */
	long NumCharStrings;
	
	/* Encoding */
	SID charCodeToSID[256];
	/* charset */
	SID *gIndexToSID; /* [ NumCharStrings ] */
	/* our T2K built lookup to find chars. */
	uint16 SIDToGIndex[sidLimit];
	
	hmtxClass *hmtx;  /* [ NumCharStrings ] */
	long upem;
	long maxPointCount;
	long ascent;
	long descent;
	long lineGap;
	long advanceWidthMax;
	F16Dot16 italicAngle;
	

	
	/* Begin Type2BuildChar state */
	F16Dot16 gStackValues[ CFF_MAX_STACK ];
	long gNumStackValues;
	GlyphClass *glyph;
	long x, y, awy, awx;
	long lsbx, lsby;
	int numStemHints;
	int pointAdded;
	int widthDone;
	uint16 seed;
	/* End Type2BuildChar state */
	
	/* Begin Header */
	Card8	major;
	Card8	minor;
	Card8	hdrSize;
	OffSize	offSize;
	/* End Header */
	
	/* Name Index */
	CFFIndexClass *name; /* NumFonts in this set == name->count !!! */

	/* Top DICT Index */
	CFFIndexClass *topDict; /* per-font */
	TopDictInfo   topDictData;

	/* String Index */
	CFFIndexClass *string; /* shared by all fonts */

	/* Global Subr Index */
	CFFIndexClass *gSubr;
	int32 gSubrBias;
	
	/* Encoding */
	
	/* Charsets */
	
	/* FDSelect (CIDFonts only) */
	
	/* CharStrings, per font, found through the topDict */
	CFFIndexClass *CharStrings;
	
	/* Font DICT Index per-font (CIDFonts only) */
	
	/* Private DICT, per-font */
	PrivateDictInfo privateDictData;

	/* Private Subr INDEX, per-font or per-PRivate DICT for CIDFonts */
	/* Local Subr Index */
	CFFIndexClass *lSubr;
	int32 lSubrBias;
	
	/* Copyright and trandemark notices */


	/* public */
} CFFClass;

CFFClass *tsi_NewCFFClass( tsiMemObject *mem, InputStream *in, int32 fontNum );
void tsi_DeleteCFFClass( CFFClass *t );

uint16 tsi_T2GetGlyphIndex( CFFClass *t, uint16 charCode );
GlyphClass *tsi_T2GetGlyphByIndex( CFFClass *t, uint16 index, uint16 *aw );
GlyphClass *tsi_T2GetGlyphByCharCode( CFFClass *t, uint16 charCode, uint16 *aw );

#endif /* ENABLE_CFF */
#endif /* __T2K_T1__ */

