
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Internal Text Library Function Prototypes, typedefs, etc.
 * rwb 12/23/98
 */

#ifndef mltxtpriv_h
#define mltxtpriv_h

//#include <nuon/m2types.h>
//#include <nuon/mlcolor.h>
#include "../Fonts/t2k.h"
#include "../../nuon/mml2d.h"

#define eT2Kerr 0
#define kCodeStart 0x20
//#define kMaxCharCode 0x7F
//#define kNumChar 96;
#define kMaxCharCode 0xFF
#define kNumChar 224;
typedef short f12Dot4;

typedef struct mmlFontStruct mmlFontStruct;
struct mmlFontStruct{
	mmlFontStruct*	nextFont;
	textCode*	fontName;
	InputStream*	fontStream;
	sfntClass*	fontSfnt;
	T2K*		scalerP;
	int		tech;		/* typeTechnology */
};

typedef struct glyphProp glyphProp;
struct glyphProp{
	uint32*		pixData;
	f12Dot4		left;
	f12Dot4		right;
	uint16		bodyWidthPix;
	uint16		entrySizeLongs;
};

typedef struct glyphCache glyphCache;
struct glyphCache{
	glyphCache*		nextCache;
	mmlFontStruct*	fontP;
	int				fontSize;
	f16Dot16			unused;	/* remove but make sure bitmap fonts track this change */
	f16Dot16			xScale;
	T2K*			scalerP;
	ml2by2Matrix 		matrix;	/* matrix as used b t2k scaler */
	mmlLayoutMetrics	metrics;
	glyphProp			entry[kMaxCharCode-kCodeStart+1];
	};


/* cacheBlock consists of pointer to next block followed by compressed
pixmap data for a bunch of glyphs in order generated.  Cacheblocks share
data from many different strikes.
*/

typedef struct mmlFontStuff mmlFontStuff;
struct mmlFontStuff{
	mmlGC*		gcP;
	tsiMemObject*	memHandler;
	int			maxCacheSizeLongs;
	int			currentSizeLongs;
	int			blockSizeLongs;
	uint32*		firstCacheBlockP;
	uint32*		nextGlyphAdr;
	uint32*		lastGlyphAdr;
	mmlTextStyle 	currentStyle;	
	mmlFontStruct	firstFont;
	int			numFonts;
	glyphCache*		currentCacheP;
	glyphCache*		firstCacheP;
	int			textModel;
};

/* Internal function prototypes */
void texSimpleDraw( mmlFontContext fcP, textCode t[], int num, mmlTextStyle* sP,
	 m2dRect* rP, mmlDisplayPixmap* frameP );
mmlStatus GetCacheEntry(mmlFontContext fcP, glyphCache* gP, textCode k,
	glyphProp** propPP, int* sizeSetP );
glyphCache* getGlyphCache( mmlFontContext fcP, mmlTextStyle* tS );
mmlStatus texPackGlyph( uint32* srcStartP, uint32* destP, int high, int wide, int rowLongsWide,
	int colHigh, int nTopWhite, uint32** nextP, uint32* endP );

#endif
