/*
 * T2K.H
 * Copyright (C) 1989-1998 all rights reserved by Type Solutions, Inc. Plaistow, NH, USA.
 * http://www.typesolutions.com/
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
#ifndef __T2K_T2K__
#define __T2K_T2K__
#include "CONFIG.H"
#include "DTYPES.H"
#include "TSIMEM.H"
#include "T2KSTRM.H"
#include "TRUETYPE.H"
#include "GLYPH.H"

#ifdef CODING_EXAMPLE
	/* First configure T2K, please see "CONFIG.H" !!! */

	/* This shows pseudo code example for how to use the T2K scaler. */
	tsiMemObject *mem = NULL;
	InputStream *in = NULL;
	sfntClass *font = NULL;
	T2K *scaler = NULL;
	int errCode;
	T2K_TRANS_MATRIX trans;
	T2K_AlgStyleDescriptor style;			
			

	/* Create a Memhandler object. */
	mem	= tsi_NewMemhandler( &errCode );
	assert( errCode == 0 );
		/* Point data1 at the font data */
		If ( TYPE 1 ) {
			if ( PC Type 1 ) {
				data1 = ExtractPureT1FromPCType1( data1, &size1 );
				/* data1 is not allocated just munged by this call ! */
			} else if ( Mac Type 1 ) {
				short refNum = OpenResFile( pascalName ); /* Open the resource with some Mac call */
				data1 = (unsigned char *)ExtractPureT1FromMacPOSTResources( mem, refNum, &size1 );
				CloseResFile( refNum ); /* Close the resource file with some Mac call */
				/* data1 IS allocated by the T2kMemory layer! */
			}
		}
		/* Please make sure you use the right New_InputStream call depending on who allocated data1,
		  and depending on if the font is in ROM/RAM or on the disk/server etc. */
		/* Create an InputStream object for the font data */
		in 	= New_InputStream( mem, data1, size1, &errCode ); /* if data allocated by the T2kMemory layer */
		assert( errCode == 0 );
	  	**** OR ****
		in 	= New_InputStream3( mem, data1, size1, &errCode ); /* otherwise do this if you allocated the data  */
		**** OR *****
		/* Allows you to leave the font on the disk, or remote server for instance (!) */
		in = New_NonRamInputStream( mem, fpID, ReadFileDataFunc, length, &errCode  ); 
		
		assert( errCode == 0 );
			/* Create an sfntClass object. (No algorithmic styling) */
			short fontType = FONT_TYPE_TT_OR_T2K; /* Or, set equal to FONT_TYPE_1 for type 1, FONT_TYPE_2 for CFF fonts */
			font = New_sfntClass( mem, fontType, in, NULL, &errCode );
			**** OR ****
			/* alternatively do this for formats that support multiple logical fonts within one file */
			font = New_sfntClassLogical( mem, fontType, logicalFontNumber, in, NULL, &errCode );
			
			/* Or if you wish to use algorithmic styling do this instead
			 * T2K_AlgStyleDescriptor style;
			 *
			 * style.StyleFunc 			= 	tsi_SHAPET_BOLD_GLYPH;
			 * style.StyleMetricsFunc	=	tsi_SHAPET_BOLD_METRICS;
			 * style.params[0] = 5L << 14; (* 1.25 *)
			 * font = New_sfntClass( mem, fontType, in, &style, &errCode );
			 */
			assert( errCode == 0 );
				/* Create a T2K font scaler object.  */
				scaler = NewT2K( font->mem, font, &errCode );
				assert( errCode == 0 );
					/* 12 point */
					trans.t00 = ONE16Dot16 * 12;
					trans.t01 = 0;
					trans.t10 = 0;
					trans.t11 = ONE16Dot16 * 12;
					/* Set the transformation */
					T2K_NewTransformation( scaler, true, 72, 72, &trans, &errCode );
					assert( errCode == 0 );
					loop {
						/* Create a character */
						T2K_RenderGlyph( scaler, charCode, 0, 0, BLACK_AND_WHITE_BITMAP, T2K_GRID_FIT | T2K_RETURN_OUTLINES  | T2K_SCAN_CONVERT, &errCode );
						assert( errCode == 0 );
						/* Now draw the char */
						/* Free up memory */
						T2K_PurgeMemory( scaler, 1, &errCode );
						assert( errCode == 0 );
					}
				/* Destroy the T2K font scaler object. */
				DeleteT2K( scaler, &errCode );
				assert( errCode == 0 );
			/* Destroy the sfntClass object. */
			Delete_sfntClass( font, &errCode );
			assert( errCode == 0 );
		/* Destroy the InputStream object. */
		Delete_InputStream( in, &errCode  );
		assert( errCode == 0 );
	/* Destroy the Memhandler object. */
	tsi_DeleteMemhandler( mem );

#endif /* CODING_EXAMPLE */

typedef struct {
	F16Dot16 t00, t01;
	F16Dot16 t10, t11;
} T2K_TRANS_MATRIX;

/* public getter functions */
#define T2K_FontHasKerningData( t ) ((t)->font != NULL && (t)->font->kern != NULL)
#define T2K_GetNumGlyphsInFont( t ) GetNumGlyphs_sfntClass( (t)->font )

typedef struct {
	/* private */
	long stamp1;
	tsiMemObject *mem;
	F16Dot16 t00, t01;
	F16Dot16 t10, t11;
	int is_Identity;
	
	/* public */
	F16Dot16	xAscender,	yAscender;
	F16Dot16	xDescender,	yDescender;
	F16Dot16	xLineGap,	yLineGap;
	F16Dot16	xMaxLinearAdvanceWidth, yMaxLinearAdvanceWidth;
	long		numGlyphs;
	F16Dot16 	caretDx, caretDy; /* [0,K] for vertical */

	/* Begin outline data */
	GlyphClass *glyph;
	F16Dot16 xAdvanceWidth16Dot16, yAdvanceWidth16Dot16;
	F16Dot16 xLinearAdvanceWidth16Dot16, yLinearAdvanceWidth16Dot16;
	/* End outline data */
	
	/* Begin bitmap data */
	long width, height;
	F26Dot6 fTop26Dot6, fLeft26Dot6;
	long rowBytes;
	unsigned char *baseAddr; /* unsigned char baseAddr[N], 	N = t->rowBytes * t->height */
	/* End bitmap data */

	/* private */
	/* F16Dot16 xPointSize, yPointSize; */
	/* long xRes, yRes; */
	long xPixelsPerEm, yPixelsPerEm;
	F16Dot16 xPixelsPerEm16Dot16, yPixelsPerEm16Dot16;
	F16Dot16 xMul, yMul;
	long ag_xPixelsPerEm, ag_yPixelsPerEm;
	char xWeightIsOne;

	sfntClass *font;
	/* Hide the true data Types from our client */
	void *hintHandle; /* ag_HintHandleType hintHandle */
	/* void *globalHintsCache; Moved into sfntClass */
	
#ifdef LAYOUT_CACHE_SIZE
	uint32 tag[LAYOUT_CACHE_SIZE];
	int16 kernAndAdvanceWidth[ LAYOUT_CACHE_SIZE ];
	#ifdef ENABLE_KERNING
		int16 kern[ LAYOUT_CACHE_SIZE ];
	#endif /* ENABLE_KERNING */
#endif /* LAYOUT_CACHE_SIZE */
	
	long stamp2;
} T2K;


#ifdef ENABLE_AUTO_GRIDDING
/*
 * For all T2K functions *errCode will be set to zero if no error was encountered
 *
 * If you are not using any algorithmic styling then set styling = NULL
 */
T2K *NewT2K( tsiMemObject *mem, sfntClass *font, int *errCode );

/* Two optional functions to set prefered platform and/or prefered platform specific ID */
/* Invoke right after NewT2K() */
#define Set_PlatformID( t, ID ) 			((t)->font->preferedPlatformID = (ID))
#define Set_PlatformSpecificID( t, ID ) 	((t)->font->preferedPlatformSpecificID = (ID))

/* x & y point size is passed embedded in the T as trans = pointSize * oTrans */
void T2K_NewTransformation( T2K *t, int doSetUpNow, long xRes, long yRes, T2K_TRANS_MATRIX *trans, int *errCode );

/* Bits for the cmd field below */
#define T2K_GRID_FIT		0x01
#define T2K_SCAN_CONVERT	0x02
#define T2K_RETURN_OUTLINES	0x04
#define T2K_CODE_IS_GINDEX	0x08 /* Otherwise it is the charactercode */
#define T2K_USE_FRAC_PEN	0x10
#define T2K_SKIP_SCAN_BM	0x20 /* Everything works as normal, however we do _not_ generate the actual bitmap */

/* For the greyScaleLevel field below */
#define BLACK_AND_WHITE_BITMAP 				0
#define GREY_SCALE_BITMAP_LOW_QUALITY		1
#define GREY_SCALE_BITMAP_MEDIUM_QUALITY	2
#define GREY_SCALE_BITMAP_HIGH_QUALITY		3 /* Recommended for grey-scale */
#define GREY_SCALE_BITMAP_HIGHER_QUALITY	4
#define GREY_SCALE_BITMAP_EXTREME_QUALITY	5 /* Slooooowest */

/* When doing grey-scale the scan-converter returns values in the range T2K_WHITE_VALUE -- T2K_BLACK_VALUE */
#define T2K_BLACK_VALUE 120
#define T2K_WHITE_VALUE 0

/* The Caller HAS to deallocate outlines && t->baseAddr with T2K_PurgeMemory( t, 1 ) */
/* fracPenDelta should be between 0 and 63, 0 represents the normal pixel alignment,
   16 represents a quarter pixel offset to the right,
   32 represents a half pixel offset of the character to the right,
   and -16 represents a quarter/4 pixel shift to the left. */
/* For Normal integer character positioning set fracPenDelta == 0 */
/* IPenPos = Trunc( fracPenPos );  FracPenDelta = fPenPos - IPenPos */
/* The bitmap data is relative to  IPenPos, NOT fracPenPos */
void T2K_RenderGlyph( T2K *t, long code, int8 xFracPenDelta, int8 yFracPenDelta, uint8 greyScaleLevel, uint8 cmd, int *errCode );

#define MAX_PURGE_LEVEL 2
void T2K_PurgeMemory( T2K *t, int level, int *errCode );

void DeleteT2K( T2K *t, int *errCode );

#endif /* ENABLE_AUTO_GRIDDING */

/* Transforms xInFUnits into 16Dot16 x and y values */
void T2K_TransformXFunits( T2K *t, short xValueInFUnits, F16Dot16 *x, F16Dot16 *y);
/* Transforms yInFUnits into 16Dot16 x and y values */
void T2K_TransformYFunits( T2K *t, short yValueInFUnits, F16Dot16 *x, F16Dot16 *y);

#ifdef ENABLE_LINE_LAYOUT

#ifdef LINEAR_LAYOUT_EXAMPLE
	/* This is a pseudo-code example */
	totalWidth = T2K_MeasureTextInX( scaler, string16, kern, numChars);
	for ( i = 0;  (charCode = string16[i]) != 0; i++ ) {
		F16Dot16 xKern, yKern;
		
		/* Create a character */
		T2K_RenderGlyph( scaler, charCode, 0, 0, BLACK_AND_WHITE_BITMAP, T2K_GRID_FIT | T2K_RETURN_OUTLINES  | T2K_SCAN_CONVERT, &errCode );
		assert( errCode == 0 );
		T2K_TransformXFunits( scaler, kern[i], &xKern, &yKern );

		bm->baseAddr 		= (char *)scaler->baseAddr;
		bm->rowBytes 		= scaler->rowBytes;
		bm->bounds.left 	= 0;
		bm->bounds.top		= 0;
		bm->bounds.right	= scaler->width;
		bm->bounds.bottom	= scaler->height;
	
		MyDrawChar( graf, x + ( (scaler->fLeft26Dot6+(xKern>>10))>>6), y - (scaler->fTop26Dot6+(yKern>>10)>>6), bm );
		/* We keep x as 32.16 */
		x16Dot16 += scaler->xLinearAdvanceWidth16Dot16 + xKern; x += x16Dot16>>16; x16Dot16 &= 0x0000ffff;
		/* Free up memory */
		T2K_PurgeMemory( scaler, 1, &errCode );
		assert( errCode == 0 );
	}


#endif /* LINEAR_LAYOUT_EXAMPLE */

/* Returns the total pixel width fast, and computes the kern values */
uint32 T2K_MeasureTextInX(T2K *t, const uint16 *text, int16 *xKernValuesInFUnits, uint32 numChars );


#define T2K_X_INDEX		0
#define T2K_Y_INDEX		1
#define T2K_NUM_INDECES	2

typedef struct {
	/* input */
	uint16   	charCode;
	uint16   	glyphIndex;
	F16Dot16 	AdvanceWidth16Dot16[ T2K_NUM_INDECES ];
	F16Dot16 	LinearAdvanceWidth16Dot16[ T2K_NUM_INDECES ];
	F26Dot6	 	Corner[ T2K_NUM_INDECES ]; /* fLeft26Dot6, fTop26Dot6 */
	long		Dimension[ T2K_NUM_INDECES ]; /* width, height */
} T2KCharInfo;


typedef struct {
	/* output */
	F16Dot16	BestAdvanceWidth16Dot16[ T2K_NUM_INDECES ];
} T2KLayout;

uint16 T2K_GetGlyphIndex( T2K *t, uint16 charCode );
/*
 * Before calling create a T2KCharInfo for each character on the line and initialize
 * all the fields. You can use the above T2K_GetGlyphIndex() to get the glyphIndex.
 * Computes the ideal lineWidth. The computation takes kerning into account.
 * Initializes out
 */
void T2K_GetIdealLineWidth( T2K *t, const T2KCharInfo cArr[], long lineWidth[], T2KLayout out[] );
/*
 * You have to call T2K_GetIdealLineWidth() first to initalize out before calling this function.
 * Computes out so that the LineWidthGoal is satisfied while taking kerning into account.
 * Note: This is an early version of the function.
 */
void T2K_LayoutString( const T2KCharInfo cArr[], const long LineWidthGoal[], T2KLayout out[] );

#endif /* ENABLE_LINE_LAYOUT */

#endif /* __T2K_T2K__ */
