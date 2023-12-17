
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* Basic Text Library Functions
 * rwb 8/5/98
 * rwb 8/14/99 - hack. rotation wasn't being used. use it to indicate that 
 * the video is stretching horizontal by 2, so text should be halved horizontally.
 * pass 0 for scale by 1, 1 for scale by 1/2.
 * rwb 8/27/99 replace hack by adding an xScale field to textStyle
 * structure.  This will need to be set separately.
 */

#ifndef NO_DRAWTEXT
#include "../mrplib/parblock.h"
#endif
#include "mltxtpriv.h"
#include "ufnt.h"
#include "../../nuon/mml2d.h"
#ifndef NO_DRAWTEXT
#include "../../nuon/mrpcodes.h"
#endif
#include <stdlib.h>
#include <assert.h>
#include <stdio.h>

extern void _DCacheSync();

/* return the kind of character represented by a specific charcode.
Only implemented for ascii.
*/  
charKind CharKindQ( textCode k, textEncoding standard )
{
	assert( standard == eAscii );
	if( k >= 0x61 && k <= 0x7A ) return eLetter;
	else if( k >= 0x41 && k <= 0x5A ) return eLetter;
	else if( k == 0x20 ) return eWhiteSpace;
	else if( k >= 0x30 && k <= 0x39 ) return eNumber;
	else if( k >= 0x21 && k <= 0x2F ) return ePunctuation;
	else if( k >= 0x3A && k <= 0x40 ) return ePunctuation;
	else if( k >= 0x5B && k <= 0x60 ) return ePunctuation;
	else if( k >= 0x7B && k <= 0x7E ) return ePunctuation;
	else if( k >= 0x09 && k <= 0x0D ) return eWhiteSpace;
	else return eExtra;
}

/* Recursive release function
*/
static void release( uint32* p )
{
	if( (uint32*)(*p) != NULL ) release( (uint32*)*p );
	free( p );
}

/* Reset the glyph cache.  Need to release all the memory and reset font context.
*/
static mmlStatus initializeCache( mmlFontContext fcP )
{
	int sizeLongs = fcP->maxCacheSizeLongs < fcP->blockSizeLongs ? fcP->maxCacheSizeLongs : fcP->blockSizeLongs;
	if( fcP->firstCacheBlockP != NULL )
		release( (uint32*)fcP->firstCacheBlockP ); 	/* release all cache blocks */
	fcP->firstCacheBlockP = calloc( sizeLongs, 4 );
	if( fcP->firstCacheBlockP == NULL ) return eSysMemAllocFail;
	*fcP->firstCacheBlockP = 0; /* NULL */
	fcP->nextGlyphAdr = fcP->firstCacheBlockP+1;
	fcP->lastGlyphAdr = fcP->firstCacheBlockP + sizeLongs - 1;
	fcP->currentSizeLongs = sizeLongs;
	if( fcP->firstCacheP != NULL )
	{
		release( (uint32*)fcP->firstCacheP );
		fcP->firstCacheP = NULL;
	}
	return eOK;
}

/* Return a pointer to an existing matching cache or create one and 
return the pointer to it.
*/
glyphCache* getGlyphCache( mmlFontContext fcP, mmlTextStyle* tS )
{
	glyphCache* cP = fcP->firstCacheP;
	if( cP  == NULL )
	{
		cP = calloc( sizeof( glyphCache ), 1 );
		assert( cP != NULL );
		fcP->firstCacheP = cP;
		goto setT2K;
	}
	while( 1 )
	{
		if(( tS->fontP == cP->fontP ) &&
		( tS->fontSize == cP->fontSize ) &&
		( tS->xScale == cP->xScale )
		 ) return cP;
		if( cP->nextCache == NULL ) break;
		cP = cP->nextCache;
	}
	cP->nextCache = calloc( sizeof( glyphCache ), 1 );
	if( cP->nextCache == NULL )
	{
		initializeCache( fcP );
		cP = calloc( sizeof( glyphCache ), 1 );
		assert( cP != NULL );
		fcP->firstCacheP = cP;
		goto setT2K;
	}
	cP = cP->nextCache;
setT2K:
	assert( tS->fontP->tech != eNonScalable );
	cP->fontP = tS->fontP;
	cP->fontSize = tS->fontSize;
	cP->xScale = tS->xScale;
	{
		int errCode;
		int vsize = tS->fontSize + 2;
		int lineHeight;
		T2K_TRANS_MATRIX temp;
		cP->nextCache = NULL;
		if( tS->fontP->scalerP == NULL )
		{
			tS->fontP->scalerP = NewT2K((tsiMemObject*)fcP->memHandler,(sfntClass*)tS->fontP->fontSfnt, &errCode );
			assert( errCode == 0 );
		}
		cP->scalerP = tS->fontP->scalerP;
		if( fcP->textModel == eNewModel ) --vsize;
		do
		{
		/* rwb - TOFIX - add in rotation to matrix */
			--vsize;
			temp.t00 = ONE16Dot16 * vsize;
			temp.t01 = 0;
			temp.t10 = 0;
			temp.t11 = ONE16Dot16 * vsize;

/*			temp.t00 = 0;
			temp.t01 = ONE16Dot16 * vsize;
			temp.t10 = ONE16Dot16 * vsize;
			temp.t11 = 0;
*/

//			T2K_NewTransformation( cP->scalerP, true, (64*tS->xScale)>>16, 72, &temp, &errCode ); 
			T2K_NewTransformation( cP->scalerP, 0, (64*tS->xScale)>>16, 72, &temp, &errCode ); 
			assert( errCode == 0 );
			lineHeight = ((cP->scalerP->yAscender - cP->scalerP->yDescender)>>16) + vsize/8;
		}while( (fcP->textModel == eOldModel) && lineHeight > tS->fontSize );
		cP->matrix.t00 = ONE16Dot16 * vsize;
		cP->matrix.t01 = 0;
		cP->matrix.t10 = 0;
		cP->matrix.t11 = ONE16Dot16 * vsize;
		cP->metrics.columnHeight	= lineHeight;
		cP->metrics.ascent 			= cP->scalerP->yAscender;	
		cP->metrics.descent 		= cP->scalerP->yDescender;	
//		cP->metrics.base 			= lineHeight - (((-cP->scalerP->yDescender) + 0x8000)>>16);
		cP->metrics.base 			= (cP->scalerP->yAscender + cP->scalerP->yLineGap/2)>>16;
		cP->metrics.maxWidth		= cP->scalerP->xMaxLinearAdvanceWidth;	
		cP->metrics.ttPointSize		= vsize;	
		cP->metrics.firstCharCode	= kCodeStart;	
		cP->metrics.lastCharCode	= kMaxCharCode;	
		cP->metrics.numCharacters	= kMaxCharCode - kCodeStart + 1;	
		return cP;
	}
}

void mmlSetTextProperties( mmlFontContext fcP, mmlFont fontP, int fontSize,
	mmlColor fore, mmlColor back, textMix copyMode, int flags, f28Dot4 tracking  )
{
	fcP->currentStyle.fontP = fontP;
	fcP->currentStyle.fontSize = fontSize;
	fcP->currentStyle.foreColor = fore;
	fcP->currentStyle.backColor = back;
	fcP->currentStyle.copyMode = copyMode | flags;
	fcP->currentStyle.tracking = tracking;
	fcP->currentStyle.xScale = fcP->gcP->textWidthScale;
	fcP->currentCacheP = getGlyphCache( fcP, &fcP->currentStyle );
}

void mmlInitTextStyle( mmlTextStyle* tsP, mmlFont fontP, int fontSize,
	mmlColor fore, mmlColor back, textMix copyMode, int flags, f28Dot4 tracking  )
{
	tsP->fontP = fontP;
	tsP->fontSize = fontSize;
	tsP->foreColor = fore;
	tsP->backColor = back;
	tsP->copyMode = copyMode | flags;
	tsP->tracking = tracking;
	tsP->xScale = 0x10000;
}	

void mmlInitScaledTextStyle( mmlTextStyle* tsP, mmlFont fontP, int fontSize,
	mmlColor fore, mmlColor back, textMix copyMode, int flags, f28Dot4 tracking, f16Dot16 xScale  )
{
	tsP->fontP = fontP;
	tsP->fontSize = fontSize;
	tsP->foreColor = fore;
	tsP->backColor = back;
	tsP->copyMode = copyMode | flags;
	tsP->tracking = tracking;
	tsP->xScale = xScale;
}	

void mmlSetTextStyle( mmlFontContext fcP, mmlTextStyle* tsP )
{
	fcP->currentStyle = *tsP;
	fcP->currentCacheP = getGlyphCache( fcP, &fcP->currentStyle );
}

#ifndef NO_DRAWTEXT

void mmlSimpleDrawText( mmlFontContext fcP,  mmlDisplayPixmap* screenP,
	textCode str[], int numGlyphs, m2dRect* rP)
{
	texSimpleDraw( fcP, str, numGlyphs, &fcP->currentStyle, rP, screenP );
}

void mmlSimpleDrawBaseline( mmlFontContext fcP,  mmlDisplayPixmap* screenP,
	textCode str[], int numGlyphs, int baseX, int baseY)
{
	m2dRect r;
	mmlLayoutMetrics* mP = mmlGetStyleLayoutMetrics( fcP, &fcP->currentStyle );
	m2dSetRect( &r, baseX, baseY - mP->base, screenP->wide-1, screenP->high-1);
	texSimpleDraw( fcP, str, numGlyphs, &fcP->currentStyle, &r, screenP ); 
}

static void texBlit( mmlFontContext fcP, mmlTextStyle* sP, DrawGlyphParamBlock* dP,
	int parSize, int numLetters )
{
	mmlGC* gP = fcP->gcP;
	if( numLetters <= 0 ) return;
/* force any recently rendered glyphs out of cache into memory */
	_DCacheSync();
	dP->translucent = gP->translucentText;
	if( (sP->copyMode & 0xF) == eBlend )
		mmlExecutePrimitive( gP, eTxBlend, dP, parSize, numLetters, 0);
	else if( (sP->copyMode & 0xF) == eOpaque )
		mmlExecutePrimitive( gP, eTxBlt, dP, parSize, numLetters, 0);
	else if( (sP->copyMode & 0xF) == eClutAlpha )
		{
			dP->indexVals = (gP->textDiv<<24) | (gP->textMin<<16) | (gP->textMax<<8) | (gP->textBase);
			mmlExecutePrimitive( gP, eTxAlpha, dP, parSize, numLetters, 0);
		}
}

/* Draw one line of num characters into frame, clipped to rectangle, in the textStyle.
   Modify bottom right of rect to tell what got drawn.
*/
void texSimpleDraw( mmlFontContext fcP, textCode t[], int num, mmlTextStyle* sP,
	 m2dRect* rP, mmlDisplayPixmap* frameP )
{
	int sizeSet, rsbOld;
	int lineWide, letter, letterStart, numIllegal;
	glyphCache* gP = getGlyphCache(fcP, sP );  /* make one if it doesn't exist */
	int parSize = sizeof( DrawGlyphParamBlock )+ num * sizeof( glyphDescriptor );
	DrawGlyphParamBlock* dP = malloc( parSize );
	assert( rP != NULL );
	assert( rP->rightBot.y > rP->leftTop.y );
	assert( rP->rightBot.x > rP->leftTop.x );
	assert( num > 0  );
	assert( frameP != NULL );
	if( dP == NULL )
	{
		initializeCache( fcP );
		gP = getGlyphCache(fcP, sP );
		dP = malloc( parSize );
		assert( dP != NULL );
	}
	dP->dstBase = frameP->memP;
	dP->dstStridePix = (frameP->dmaFlags >> 13) & ~7;
	dP->dstFormat = frameP->dmaFlags & 0xF0;
	if( dP->dstFormat == 0x20 ) dP->dstFormat = 0x80;
	dP->dstFormat |= (frameP->dmaFlags & 0x800);

	dP->dstTop = rP->leftTop.y;
	dP->dstHighPix = rP->rightBot.y - rP->leftTop.y + 1;
	if( dP->dstHighPix > gP->metrics.columnHeight )
	{
		dP->dstHighPix = gP->metrics.columnHeight;
		dP->excess = 0;
	}
	else dP->excess = gP->metrics.columnHeight - dP->dstHighPix;
	dP->nTrailCols = 0;
	dP->foreColor = sP->foreColor;
	dP->backColor = sP->backColor;
	
	lineWide = rP->rightBot.x - rP->leftTop.x + 1;
	letterStart = 0;
	letter = letterStart;
	rsbOld = 0;
	sizeSet = 0;
	numIllegal = 0;
	while( letter < num )
	{
		int leftWhite;
		mmlStatus stat;
		glyphProp* propP;
restart:
		stat = GetCacheEntry( fcP, gP, t[letter], &propP, &sizeSet );
		if( stat == eIllegalCharCode )
		{
			++letter;
			++numIllegal;
			goto restart;
		}
		if( stat != eOK )
		{
			DrawGlyphParamBlock* ddP = malloc( parSize );
			memcpy( ddP, dP, parSize );
			ddP->nGlyphsTotal = letter-letterStart-numIllegal;	
			ddP->nTrailCols = 0;
			ddP->dstLeft = rP->leftTop.x;
			ddP->dstWidePix = rP->rightBot.x - rP->leftTop.x + 1;
			rP->leftTop.x = rP->leftTop.x + ddP->dstWidePix - lineWide;
		// note texBlit frees ddp
			texBlit( fcP, sP, ddP, parSize, letter-letterStart-numIllegal );
			initializeCache( fcP );
			gP = getGlyphCache(fcP, sP );
			letterStart = letter;
			numIllegal = 0;
			goto restart;
		}
		if( ((propP->left + propP->right + sP->tracking)>>4) + propP->bodyWidthPix > lineWide ) break;
		leftWhite = (propP->left + rsbOld  + 0x8)>>4;
		rsbOld = propP->right + sP->tracking;
		dP->glyph[letter-letterStart-numIllegal].glyphAdr = propP->pixData;
		dP->glyph[letter-letterStart-numIllegal].nLeftCols = leftWhite;
		dP->glyph[letter-letterStart-numIllegal].size = propP->entrySizeLongs;
		lineWide -= (leftWhite + propP->bodyWidthPix );
		++letter;
	}
	dP->nGlyphsTotal = letter-letterStart - numIllegal;	
	if( sP->copyMode & kFillRect ) dP->nTrailCols = lineWide;
	else dP->nTrailCols = (rsbOld>>4) < lineWide ? (rsbOld>>4) : lineWide;
	dP->dstLeft = rP->leftTop.x;
	dP->dstWidePix = rP->rightBot.x - rP->leftTop.x + 1;
	rP->rightBot.x -= ( lineWide - dP->nTrailCols );
	rP->rightBot.y = rP->leftTop.y + dP->dstHighPix - 1;
	texBlit( fcP, sP, dP, parSize, letter-letterStart-numIllegal );
}

#endif // NO_DRAWTEXT

/* Get size of rect that will contain a partial string of text rendered in
current text style.  The initial rect specifies the top left of the beginning
of the string, and its clipping boundaries.
rwb ToFix - take action on run-out-of-cache condition
*/
void mmlGetTextBox( mmlFontContext fcP, textCode t[], int first, int last, m2dRect* rP )
{
	int sizeSet	= 0;
	int rsbOld	= 0;
	int linePosition;
	int letter	= 0;
	glyphCache* gP = getGlyphCache(fcP, &fcP->currentStyle );  /* make one if it doesn't exist */
	
	assert( last >= first );
	assert(rP != NULL );
	assert(rP->rightBot.y > rP->leftTop.y );
	assert(rP->rightBot.x > rP->leftTop.x );
	linePosition = rP->leftTop.x;
	
	while( letter <= last && linePosition <= rP->rightBot.x )
	{
		int leftWhite;
		mmlStatus stat;
		glyphProp* propP;
restart:
		stat = GetCacheEntry( fcP, gP, t[letter], &propP, &sizeSet );
		if( stat == eIllegalCharCode )
		{
			++letter;
			goto restart;
		}
		if( stat != eOK )
		{
			initializeCache( fcP );
			gP = getGlyphCache(fcP, &fcP->currentStyle );
			goto restart;
		}
		leftWhite = (propP->left + rsbOld  + 0x8)>>4;
		rsbOld = propP->right + (&fcP->currentStyle)->tracking;
		if( letter == first ) rP->leftTop.x = linePosition;
		linePosition += (leftWhite + propP->bodyWidthPix );
		++letter;
	}
	if( linePosition+ (rsbOld>>4)-1 < rP->rightBot.x ) rP->rightBot.x = linePosition + (rsbOld>>4) - 1;
	rP->rightBot.y = rP->leftTop.y + gP->metrics.columnHeight -1;
}
		
/* Return cacheEntry info.  If cache entry doesn't exist make one.
   Begin glyph cache with a single block (blocksize big).  Grow in blocksize
   chunks, unless it would exceed max glyphcache size.
   
   Why do we need sizeset?  Size should have been set in TextStyle?  
*/
mmlStatus GetCacheEntry(mmlFontContext fcP, glyphCache* gP, textCode k,
	glyphProp** propPP, int* sizeSetP )
{
	mmlStatus stat	= eOK;
	glyphProp* propP;
	assert( gP != NULL );
	assert( sizeSetP != NULL );
	
	if( k< kCodeStart || k  > kMaxCharCode ) return eIllegalCharCode;
	propP = &gP->entry[ k - kCodeStart ];
	if( propP->pixData == NULL )
	{
		T2K* scP = (T2K*)gP->scalerP;
		int sizeLongs, nTopWhite, errCode;
		assert( gP->fontP->tech == eTrueType || gP->fontP->tech == eT2K );
		
		if( *sizeSetP == 0 )
		{
			T2K_TRANS_MATRIX temp;
			temp.t00 = gP->matrix.t00;
			temp.t01 = gP->matrix.t01;
			temp.t10 = gP->matrix.t10;
			temp.t11 = gP->matrix.t11;
//			T2K_NewTransformation( scP, true, (64*gP->xScale)>>16, 72, &temp, &errCode );
			T2K_NewTransformation( scP, 0, (64*gP->xScale)>>16, 72, &temp, &errCode );
			*sizeSetP = 1;
		}
		T2K_RenderGlyph( scP, k, 0, 0, GREY_SCALE_BITMAP_HIGH_QUALITY, T2K_SCAN_CONVERT | T2K_USE_FRAC_PEN, &errCode );
		sizeLongs = (7 * scP->width + 3)/4;
redoGlyph:
		if( fcP->nextGlyphAdr + sizeLongs > fcP->lastGlyphAdr )
		{
			uint32 *nextBlockP, *thisBlockP;
			uint32 blockSizeLongs = sizeLongs > fcP->blockSizeLongs ? sizeLongs : fcP->blockSizeLongs;
			fcP->currentSizeLongs += blockSizeLongs;
			if( fcP->currentSizeLongs > fcP->maxCacheSizeLongs ) return eCacheFull;
			nextBlockP = calloc( blockSizeLongs, 4 );
			if( nextBlockP == NULL ) return eCacheFull;
			thisBlockP = fcP->lastGlyphAdr - blockSizeLongs + 1;
			*thisBlockP = (uint32)nextBlockP;
			fcP->nextGlyphAdr = nextBlockP + 1;
			fcP->lastGlyphAdr = nextBlockP + blockSizeLongs - 1;
		}
		propP->pixData 	= fcP->nextGlyphAdr;
		propP->left	= scP->fLeft26Dot6 >> 2;
		if( propP->left < 0 ) propP->left = 0;
		propP->right	= ((scP->xAdvanceWidth16Dot16 >> 10) - scP->fLeft26Dot6 - (scP->width<<6) ) >> 2;
		if( propP->right < 0 ) propP->right = 0;
		propP->bodyWidthPix = scP->width;
		nTopWhite = gP->metrics.base - ((scP->fTop26Dot6 + 0x20) >> 6);
		stat = texPackGlyph( (uint32*)scP->baseAddr, fcP->nextGlyphAdr, scP->height, scP->width,
			scP->rowBytes, gP->metrics.columnHeight , nTopWhite, &fcP->nextGlyphAdr, fcP->lastGlyphAdr );
		if( stat == eGlyphTooBig )
		{
			sizeLongs *= 2;
		 	goto redoGlyph;
		}
		propP->entrySizeLongs = fcP->nextGlyphAdr - propP->pixData;	
		T2K_PurgeMemory( scP, 1, &errCode );
		if( errCode != 0 ) stat = eT2Kerr;
	}
	*propPP = propP;
	return stat;
}

/* Two functions to return the address of the metrics struct associated with a given 
cache.  This provides info such as height, base, maxAdvanceWidth, etc.
	Returns address of actual metrics struct in cache, does not do a copy.
*/
mmlLayoutMetrics* mmlGetStyleLayoutMetrics( mmlFontContext fcP, mmlTextStyle* tS )
{
	glyphCache* cP = getGlyphCache( fcP, tS );
	return &(cP->metrics);
}

mmlLayoutMetrics* mmlGetLayoutMetrics( mmlFontContext fcP )
{
	return &(fcP->currentCacheP->metrics); 
}
/* Initialize the font context. There is probably only ever one.
Allocate memory for it, because we want to pass an opaque pointer
as an argument, so that we can isolate the details of fonts, scalers, 
and so on.
*/
mmlStatus mmlInitFontContext( mmlGC* gc, mmlSysResources *sysResP,
	 mmlFontContext* fcAdr, int cacheSizeLongs )
{
	mmlFontStuff* fcP = calloc( sizeof( mmlFontStuff ), 1);
	if( fcP == NULL ) return eSysMemAllocFail;
	fcP->maxCacheSizeLongs = cacheSizeLongs;
	fcP->blockSizeLongs = 1024;				/* num longs in each cache block */
	fcP->gcP = gc;
	fcP->numFonts = 0;
	*fcAdr = fcP;
	gc->fontContextP = fcP;
	fcP->firstCacheP = NULL;
	fcP->textModel = eOldModel;
	if( cacheSizeLongs != 0 )
		return initializeCache( fcP );
	return eOK;
}
/* Need setter for text model, because fontContext is supposed to be opaque.
*/
void mmlSetTextModel( mmlFontContext fcP, textModel model )
{
	fcP->textModel = model;
}


/* return registered fonts
	Call with numFonts == 0, to find out how many typefaces are registered.
	Call with numFonts = k, to get array of first k typefaces.
	If k > numFonts, numFonts will be set to number registered typefaces,
	and only that number of fonts will be returned.
*/
void mmlGetRegisteredFonts( mmlFontContext fcP, mmlFont fonts[], int* numFontsP )
{
	assert( numFontsP != NULL );
	assert( fonts != NULL );
	if( *numFontsP == 0 ) *numFontsP = fcP->numFonts;
	else
	{
		mmlFontStruct* f = &fcP->firstFont;
		int j = 0;
		while( j < *numFontsP && f != NULL )
		{
			if( f->tech != 0 ) fonts[j++] = f;
	 		f = f->nextFont;
		}
		*numFontsP = j;
	}
}

/* Return pointer to textcode array containing common name of font */
void mmlGetFontName( mmlFont f, textCode** nameP )
{
	*nameP = f->fontName;
}

static void addFontLink( mmlFontStruct* p, mmlFont toAdd )
{
	assert( p != NULL );
	assert( toAdd != NULL );
	while( p->nextFont != NULL ) p = p->nextFont;
	p->nextFont = toAdd;
	p->nextFont->nextFont = NULL;
}

/* Release memory and T2k structs allocated for this font */
static void ReleaseFont( mmlFont font )
{
	int errCode = 0;
	assert( font != NULL );
	font->fontName = NULL;
	if( font->scalerP ) DeleteT2K( font->scalerP, &errCode );
	assert( errCode == 0);
	Delete_sfntClass( font->fontSfnt, &errCode );
	assert( errCode == 0);
	Delete_InputStream( font->fontStream, &errCode  );
	assert( errCode == 0);
	font->tech = 0;
}

/* Remove a font object from font context.
   Release memory for font structure.
   Also Release associated stream, sfnt, and scaler.
*/
void mmlRemoveFont( mmlFontContext fcP, mmlFont font )
{
	mmlFontStruct		*fontP;
	glyphCache 		*cP;
	assert( fcP->numFonts > 0 );
	assert( font != NULL );
	
	/* First release all caches for the removed font */
	
	cP=fcP->firstCacheP;
	while(cP != NULL && cP->fontP == font )
	{
		fcP->firstCacheP = cP->nextCache;
		free( cP );
		cP = fcP->firstCacheP;
	}
	while( cP != NULL && cP->nextCache != NULL )
	{
		if( cP->nextCache->fontP == font )
		{
			cP->nextCache = cP->nextCache->nextCache;
			free( cP->nextCache );
		}
		else cP = cP->nextCache;
	}
			
	/* Next release font storage */	
	fontP = &fcP->firstFont;	
	if( fontP == font )
	{
		fontP->tech = 0;
		ReleaseFont( font );
		--fcP->numFonts;	
	}
	else 
	while( fontP->nextFont != NULL )
	{
		if( fontP->nextFont == font )
		{
			fontP->nextFont = font->nextFont;
			--fcP->numFonts;
			ReleaseFont( font );
			free( font );
			break;
		}
		else fontP = fontP->nextFont;
	}
}
		
/* Create a font object and add it to list of registered fonts 
 * dont check whether its already been created
 * if fonts[] is full, add to font chain.
*/
mmlFont mmlAddFont( mmlFontContext fcP, textCode typeface[],
	typeTechnology tech, uint8* location, int size )
{
	int errCode;
	mmlFontStruct* fontP;
	assert( location != NULL );
	assert( size > 0 );
	assert( tech == eTrueType || tech == eT2K || tech == eNonScalable );
	if( fcP->numFonts == 0 )
	{
		fontP = &fcP->firstFont;
		fontP->nextFont = NULL;
	}
	else
	{
		fontP = malloc( sizeof( mmlFontStruct ) );
		assert( fontP != NULL );
		addFontLink( &fcP->firstFont, fontP );
	}
	fontP->tech = tech;
	fontP->fontName = typeface;
	++fcP->numFonts;
	if( tech == eTrueType || tech == eT2K )
	{
		if( fcP->memHandler == NULL )
		{
			fcP->memHandler = tsi_NewMemhandler( &errCode );
			assert( errCode == 0 );
		}
		fontP->fontStream = New_InputStream3( fcP->memHandler, location, size, &errCode );
		assert( errCode == 0 );
		fontP->fontSfnt = New_sfntClass( fcP->memHandler, tech, fontP->fontStream, NULL, &errCode );
		assert( errCode == 0 );
		fontP->scalerP = NULL;
	}
	if( tech == eNonScalable )
	{
		glyphCache 	*cP;
		ufnt			*fP = (ufnt*)location;
		locator		*locP;
		int			ntab, nSizes, j, start;
		infoTable	 	*iP;
		uint32		*sP;
		uint32		tag;
		
		SWAP32(&fP->xTab.id);
        	assert( fP->xTab.id == 'NUON' );
		ufnOff2ptr( fP );	
		locP = fP->xTab.table;
		ntab = fP->xTab.numTables;
		iP = ufnGetAdr( locP, ntab, 'INFO' );
		nSizes = iP->numSizes;
		sP = iP->sizes;
		
		if( fcP->firstCacheP == NULL )
		{
			tag = ufnMakeCacheTag ( sP[0] );
			fcP->firstCacheP = ufnGetAdr( locP, ntab, tag );
			cP = fcP->firstCacheP;
			cP->fontP = fontP;
			start = 1;
		}
		else
		{
			cP = fcP->firstCacheP;
			while( cP->nextCache != NULL ) cP = cP->nextCache;
			start = 0;
		}
		for( j=start; j<nSizes; ++j )
		{
			tag = ufnMakeCacheTag( sP[j] );
			cP->nextCache = ufnGetAdr( locP, ntab, tag );
			cP = cP->nextCache;
			cP->fontP = fontP;
		}
		cP->nextCache = NULL;	
	}
	return fontP;
}
