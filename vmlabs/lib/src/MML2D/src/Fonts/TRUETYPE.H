/*
 * TRUETYPE.H
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
#ifndef __T2K_TRUETYPE__
#define __T2K_TRUETYPE__
#include "TT_PRVT.H"
#include "GLYPH.H"
#ifdef ALGORITHMIC_STYLES
#include "SHAPET.H"
#endif
#include "T1.H"

typedef void (*StyleFuncPtr)( GlyphClass *glyph, tsiMemObject *mem, short UPEM, F16Dot16 params[] );
typedef void (*StyleMetricsFuncPtr)( hmtxClass *hmtx, tsiMemObject *mem, short UPEM, F16Dot16 params[] );
#define MAX_STYLE_PARAMS 4

typedef struct {
	/* private */
	sfnt_OffsetTable *offsetTable0;

#ifdef ENABLE_T1
	T1Class *T1;
#endif
#ifdef ENABLE_CFF
	CFFClass *T2;
#endif
	ttcfClass *ttcf;
	
	headClass *head;
	maxpClass *maxp;
	locaClass *loca;
	hheaClass *hhea;
	hmtxClass *hmtx;
	cmapClass *cmap;
	kernClass *kern;
	uint16 preferedPlatformID, preferedPlatformSpecificID;
	
	void *globalHintsCache;
	StyleFuncPtr StyleFunc;
	StyleMetricsFuncPtr StyleMetricsFunc;
	F16Dot16 params[MAX_STYLE_PARAMS];
	
	
	InputStream *in;
	OutputStream *out;
	tsiMemObject *mem;
	
	/* OrionModelClass *model; */
	void *model;
	/* public */
	
} sfntClass;

hmtxClass *New_hmtxEmptyClass( tsiMemObject *mem, int32 numGlyphs, int32 numberOfHMetrics );
void Delete_hmtxClass( hmtxClass *t );

/* Some useful getter methods */
short GetUPEM( sfntClass *t);
short GetMaxPoints( sfntClass *t);
void GetLineSpacing( sfntClass *font, int16 *Ascender, int16 *Descender, int16 *LineGap, uint16 *maxAW, F16Dot16 *caretDx, F16Dot16 *caretDy );


typedef struct {
	StyleFuncPtr StyleFunc;
	StyleMetricsFuncPtr StyleMetricsFunc;
	F16Dot16 params[MAX_STYLE_PARAMS];
} T2K_AlgStyleDescriptor;

/* Caller does something like in = New_InputStream3( t->mem, data, length ); */
#define FONT_TYPE_1 1
#define FONT_TYPE_2 22
#define FONT_TYPE_TT_OR_T2K 2

#define New_sfntClass( mem, fontType, in, styling, errCode ) New_sfntClassLogical( mem, fontType, 0, in, styling, errCode )

sfntClass *New_sfntClassLogical( tsiMemObject *mem, short fontType, long fontNum, InputStream *in, T2K_AlgStyleDescriptor *styling, int *errCode );
#define CMD_GRID 2
#define CMD_TT_TO_T2K 3
#define CMD_T2K_TO_TT 4
#define CMD_HINT_ROMAN 5
#define CMD_HINT_OTHER 6
sfntClass *New_sfntClass2( sfntClass *sfnt0, int cmd, int param );

void WriteToFile_sfntClass( sfntClass *t, const char *fname );
void Purge_cmapMemory( sfntClass *t );

#define tag_T2KG        		0x54324B47        /* 'T2KG' */
#define tag_T2KC        		0x54324B43        /* 'T2KC' */
/* caller need to do Delete_InputStream on the stream */
InputStream *GetStreamForTable( sfntClass *t, long tag  );

void Delete_sfntClass( sfntClass *t, int *errCode );

/* 	mem									= tsi_NewMemhandler(); */
/* 	tsi_DeleteMemhandler( mem ); */

GlyphClass *GetGlyphByIndex( sfntClass *t, long index, char readHints, uint16 *aw );
GlyphClass *GetGlyphByCharCode( sfntClass *t, long charCode, char readHints, uint16 *aw );

int IsFigure( sfntClass *t, uint16 gIndex );

#ifdef ENABLE_KERNING
void GetSfntClassKernValue( sfntClass *t, uint16 leftGIndex, uint16 rightGIndex, int16 *xKern, int16 *yKern );
#endif /* ENABLE_KERNING */

uint16 GetSfntClassGlyphIndex( sfntClass *t, uint16 charCode );


long GetNumGlyphs_sfntClass( sfntClass *t );

void Add_GlyphClass( GlyphClass **tPtr, GlyphClass *addMe, uint16 flags, long arg1, long arg2 );

void Delete_GlyphClass( GlyphClass *t );


#endif /* __T2K_TRUETYPE__ */
