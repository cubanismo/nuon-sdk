/*
 * GLYPH.H
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
#ifndef __T2K_GLYPH__
#define __T2K_GLYPH__

/* private constants */
#define BASE0 0
#define BASE1 2200
#define BASE2 12604
#define BASE3 14652
#define BASEMAX 16384


/*
 * Composite glyph constants
 */
#define COMPONENTCTRCOUNT 			-1		/* ctrCount == -1 for composite */
#define ARG_1_AND_2_ARE_WORDS		0x0001	/* if set args are words otherwise they are bytes */
#define ARGS_ARE_XY_VALUES			0x0002	/* if set args are xy values, otherwise they are points */
#define ROUND_XY_TO_GRID			0x0004	/* for the xy values if above is true */
#define WE_HAVE_A_SCALE				0x0008	/* Sx = Sy, otherwise scale == 1.0 */
#define NON_OVERLAPPING				0x0010	/* set to same value for all components */
#define MORE_COMPONENTS				0x0020	/* indicates at least one more glyph after this one */
#define WE_HAVE_AN_X_AND_Y_SCALE	0x0040	/* Sx, Sy */
#define WE_HAVE_A_TWO_BY_TWO		0x0080	/* t00, t01, t10, t11 */
#define WE_HAVE_INSTRUCTIONS		0x0100	/* instructions follow */
#define USE_MY_METRICS				0x0200	/* */

typedef struct {
	/* private */
	tsiMemObject *mem;
	
	short curveType;			/* 2 or 3 */
	short contourCountMax;
	long pointCountMax;
	
	/* public */
	short	contourCount;	/* number of contours in the character */
	short 	pointCount;		/* number of points in the characters + 0 for the sidebearing points */
	short	*sp;			/* sp[contourCount] Start points */
	short	*ep;  			/* ep[contourCount] End points */
	short	*oox;			/* oox[pointCount] Unscaled Unhinted Points, add two extra points for lsb, and rsb */
	short	*ooy;			/* ooy[pointCount] Unscaled Unhinted Points, set y to zero for the two extra points */
							/* Do NOT include the two extra points in sp[], ep[], contourCount */
							/* Do NOT include the two extra points in pointCount */
	uint8 *onCurve;			/* onCurve[pointCount] indicates if a point is on or off the curve, it should be true or false */

	F26Dot6 *x, *y;
	
	short *componentData;
	long  componentSize;
	long  componentSizeMax;
	
	uint8 *hintFragment;
	long hintLength;
	
	short	xmin, ymin, xmax, ymax;

} GlyphClass;

GlyphClass *New_EmptyGlyph( tsiMemObject *mem, int16 lsb, uint16 aw );

long Write_GlyphClassT2K( GlyphClass *glyph, OutputStream *out, void *model );
GlyphClass *New_GlyphClassT2K( tsiMemObject *mem, InputStream *in, char readHints, int16 lsb, uint16 aw, void *model );
void TEST_T2K_GLYPH( tsiMemObject *mem );

#ifdef T1_OR_T2_IS_ENABLED
void glyph_CloseContour( GlyphClass *t );
void glyph_AddPoint( GlyphClass *t, long x, long y, char onCurveBit );
void glyph_StartLine( GlyphClass *t, long x, long y );
#endif /* T1_OR_T2_IS_ENABLED */

#ifdef ENABLE_PRINTF
void glyph_PrintPoints( GlyphClass *t );
#endif

#ifdef ENABLE_WRITE
void WriteDeltaXYValue( OutputStream *out, int dx, int dy, char onCurve );
#endif
int ReadDeltaXYValue( InputStream *in, short *dxPtr, short *dyPtr );
#ifdef ENABLE_ORION
int ReadOrionDeltaXYValue( InputStream *in, void *model, short *dxPtr, short *dyPtr );
#endif

#endif /* __T2K_GLYPH__ */

