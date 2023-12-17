/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 * This program is a sample for testing the new versions of 
 * NuonRaster, NuonYCCColorTable, and NuonChannelManager
*/


#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "sample.h"


#ifdef WIN32
#pragma include_alias( <impulse/hsGExtruderizer.h>, <hsGExtruderizer.h> )
#pragma include_alias( <impulse/hsGBlurMaskFilter.h>, <hsGBlurMaskFilter.h> )
#pragma include_alias( <impulse/hsGGradientShader.h>, <hsGGradientShader.h> )
#pragma include_alias( <impulse/hsGEmbossMaskFilter.h>, <hsGEmbossMaskFilter.h> )
#pragma include_alias( <impulse/hsGFont.h>, <hsGFont.h> )
#pragma include_alias( <impulse/hsConfig.h>, <hsConfig.h> )
#endif

#include <impulse/hsGExtruderizer.h>
#include <impulse/hsGBlurMaskFilter.h>
#include <impulse/hsGGradientShader.h>
#include <impulse/hsGEmbossMaskFilter.h>
#include <impulse/hsGFont.h>
#include <impulse/hsConfig.h>


//dummy functions
NuonYccColorTable *DoNothingGracefullyCol () { return NULL; }
void DoNothingGracefullyNr (NuonRaster*) {}
void DoNothingGracefullyNrTs (NuonRaster*, TestSetup*) {}
void DoNothingGracefullyNrNrTs (NuonRaster*, NuonRaster*, TestSetup*) {}



/***********************************************************/
// have a good visual look at the color lookup table
// fill the plane with the colors of the CLUT
#define X_DIVS 16
#define Y_DIVS 16
#define MAX_X 592   //deal with overscan (sloppily)
#define MAX_Y 328 


void DrawColors (NuonRaster *nr, TestSetup *pts)
{
	if (!nr) return;

	hsGColorTable *dummyTable = 0;
	const hsColor32 *pColor32 = 0;
	hsGColor color;
	unsigned count;
	
	BlankBackground (nr);

	if (nr->GetDepth() != CLUT_DEPTH) {
		// get impulse to build a default color table 
		dummyTable = new hsGColorTable;
		dummyTable->SetDefaultColorTable();
		pColor32 = dummyTable->PeekColors();
		count = dummyTable->GetCount();
	}
	else
		count = (nr->GetClut())->GetCount();


	hsGAttribute attr;
	hsPath path;
	hsRect r;

	int tableWidth = (nr->mWidth < MAX_X) ? nr->mWidth : MAX_X;
	int startX = (nr->mWidth - tableWidth) >> 1;

	int tableHeight = (nr->mHeight < MAX_Y) ? nr->mHeight : MAX_Y;
	int startY = (nr->mHeight - tableHeight);

	unsigned icolor = 0;
	int x, y, ix, iy;
	int deltaX = tableWidth/X_DIVS;
	int deltaY = tableHeight/Y_DIVS;

	
	assert ((X_DIVS * Y_DIVS) <= COLOR_TABLE_DEPTH);

	unsigned icount = 0;
	for (ix = 0, x = startX;  ix < X_DIVS; ix++, x += deltaX) {
		for (iy = 0, y = startY; (iy < Y_DIVS) && (icount < count); iy++, y += deltaY) {

			if (nr->GetDepth() == CLUT_DEPTH) {
				attr.SetColorIndex (icolor);
				icolor++;
			}
			else {
				color.Set (pColor32);
				attr.SetColor (&color);
				pColor32++;
			}

			r.Set(hsIntToScalar(x), hsIntToScalar(y), 
				hsIntToScalar(x + deltaX), hsIntToScalar(y + deltaY));
			nr->DrawRect( &r, &attr );
			icount++;
		}
	}

	nr->rasterize();

	if (dummyTable) delete dummyTable;
}
/***********************************************************/

/***********************************************************/
void AddFonts(TestSetup *pts)
{
	if (pts->numDefaultFonts == LOAD_ALL) return;
#if defined(WIN32)

	FontFileBlock **fontFileBlkP = &(pts->fontFiles[pts->numDefaultFonts]);
	while (*fontFileBlkP) {
		hsGFontList::AddFontFile((*fontFileBlkP)->fontFileName, (*fontFileBlkP)->fontFormat);
		fontFileBlkP++;

	}
#else  // Nuon

	FontRamBlock **blkP = &(pts->fontRamBlks[pts->numDefaultFonts]);
	while (*blkP) {
		NuonFontList::AddAllocatedFont(*blkP, 0);
		blkP++;
	}

#endif
}
/***********************************************************/

/***********************************************************/
// This code tests the loading and allocation of fonts in the Windows
// version, as well as text drawing and providing useful captions
void DrawCaption( NuonRaster *nr, TestSetup *pts)
{
#ifdef NO_FONT_FILES
	return;
#endif 

	hsGAttribute	attr(hsGAttribute::kAntiAlias);
	char name[256];

	// look for a font by index
	if (pts->captionTextFontIndex >= 0) {
		if (pts->captionTextFontIndex >= (int) hsGFontList::Count()) {
			// triggers adding additional fonts
			AddFonts(pts);
		}
		// (if we didn't get the right font still, this will default gracefully
		attr.SetFontID(hsGFontList::Get(pts->captionTextFontIndex));
	}

	// look for a font by name	
	else if (strlen(pts->captionTextFontName) > 0) {
		attr.SetFontID
		(
			hsGFontList::Find( hsGFontList::kAnyName, 
										pts->captionTextFontName)
		);
		hsGFontList::GetName(attr.GetFontID(), hsGFontList::kAnyName, name);

		if (!strstr( name, pts->captionTextFontName)) {
			// triggers adding additional fonts
			AddFonts(pts);

			// try again
			attr.SetFontID
			(
				hsGFontList::Find( hsGFontList::kAnyName, 
											pts->captionTextFontName)
			);
		}
	}

#if defined(PRINT_DEBUG) && defined(WIN32)
	hsGFontList::GetName(attr.GetFontID(), hsGFontList::kAnyName, name);
	printf ("%s DrawCaption Uses %s\n",pts->testName, name);
#endif


	// Make sure the clip path exposes the area to be written
	hsRect clipBounds = {hsIntToScalar(0), hsIntToScalar(0), 
						hsIntToScalar(nr->mWidth), hsIntToScalar(nr->mHeight)};
	hsPath clipPath;
	clipPath.AddRect(&clipBounds);
	nr->ClipPath(&clipPath);
	
	hsScalar		x = hsIntToScalar(70);
	hsScalar		y;
	int				bottom = nr->mHeight - 40;

	if (nr->GetDepth() == 8) {
		attr.SetColorIndex(pts->captionTextColorIndex);
	}
	else {
		attr.SetColor(&(pts->captionTextColor));
	}

	attr.SetTextSize (hsIntToScalar(pts->captionTextSize));

	y = hsIntToScalar(bottom);
	nr->DrawParamText (strlen(pts->captionLine2), 
							pts->captionLine2, x, y, &attr);

	y = hsIntToScalar(bottom - pts->captionTextSize);
	nr->DrawParamText (strlen(pts->captionLine1), 
							pts->captionLine1, x, y, &attr);

	y = hsIntToScalar(bottom - 2 * pts->captionTextSize);
	nr->DrawParamText (strlen(pts->testName), 
							pts->testName, x, y, &attr);

	nr->rasterize();

}
/***********************************************************/

/***********************************************************/
// Set up a bitmap, without a color table
hsGBitmap *MakeNewBitmap (int width, int height, int sourceDepth)
{
	hsGBitmap *bmp = new hsGBitmap;

	bmp->fWidth = width;
	bmp->fHeight = height;
	bmp->fNuonRasterP = NULL;

	switch (sourceDepth) {
	case 0:
	case 8:
		bmp->SetConfig(hsGBitmap::kIndex8Config);
		bmp->fRowBytes = bmp->fWidth;
		break;
	case 16:
		bmp->SetConfig(hsGBitmap::k555Config);
		bmp->fRowBytes = 2*bmp->fWidth;
		break;
	case 32:
		bmp->SetConfig(hsGBitmap::kARGB32Config);
		bmp->fRowBytes = 4*bmp->fWidth;
		break;
	default:;
	}

	if (sourceDepth != 0) bmp->fImage = (void*) new UInt8 [bmp->fRowBytes * bmp->fHeight];
	else bmp->fImage = NULL;

	return bmp;
}

/***********************************************************/

/***********************************************************/
// Take a raster object without a bitmap, and give it one
// this one attaches the color table directly to the bitmap
// Note that the translucency values of the color table get lost
void AddABitmap1 (NuonRaster *nr)
{
	NuonYccColorTable *cTable = 0;
	NuonAglColorTable *cTableAgl = 0;

	//nr->PrintState ("Initial state without bitmap");

	hsGBitmap *bmp = MakeNewBitmap (nr->mWidth, nr->mHeight, nr->GetSourceDepth());
	if (nr->GetDepth() == 8) {
		cTable = ChromaAndAlpha ();
		cTableAgl = cTable->GetAglColorTable();  
		bmp->SetColorTable (cTableAgl);
	}

	nr->SetPixels(bmp);
		
	//delete allocated things (check to see if all the UnRefs are
	// in place)
	delete bmp;
	if (cTable) delete cTable;

	//nr->PrintState ("Bitmap added: check the pointers");
}
/***********************************************************/

/***********************************************************/
// Take a raster object without a bitmap, and give it one
// this version lets the rasterizer fiddle with the color
// table;  thus the translucency values of the color table 
// are preserved
void AddABitmap2 (NuonRaster *nr)
{
	NuonYccColorTable *cTable = 0;

	//nr->PrintState ("Initial state without bitmap");

	hsGBitmap *bmp = MakeNewBitmap (nr->mWidth, nr->mHeight, nr->GetSourceDepth());

	nr->SetFlags(nr->GetFlags() & ~kUseBmpColorTable);
	nr->SetPixels(bmp);

	if (nr->GetDepth() == 8) {
		cTable = ChromaAndAlpha ();
		nr->SetClut (cTable);
	}
		
	//delete allocated things (check to see if all the UnRefs are
	// in place)
	delete bmp;

	//nr->PrintState ("Bitmap added: check the pointers");
}
/***********************************************************/

/***********************************************************/
// first draw function from the original ImpulseDemo
// Evolved!!! 4/29/01 kml

void OriginalDemoDraw1( NuonRaster *nr, TestSetup *pts )
{
	if (!nr) return;

	hsPath			path,path1;
	hsGAttribute	attr( hsGAttribute::kAntiAlias );


	path.MoveTo( hsIntToScalar(20), hsIntToScalar(20) );
	path.LineTo( hsIntToScalar(200), hsIntToScalar(20) );
	path.CurveTo
	(
		hsIntToScalar(200), hsIntToScalar(50), 
		hsIntToScalar(100), hsIntToScalar(100),
		hsIntToScalar(50), hsIntToScalar(100)
	);
	path.Close();

	// red fill
	attr.SetARGB( 0xFFFF, 0xCD00, 0x3900, 0x3200 );
	nr->DrawPath( &path, &attr );

	// green outline
	attr.SetARGB( 0xFFFF, 0x3600, 0x9500, 0x3400 );
	attr.SetFrameSize( hsIntToScalar(8) );
	attr.SetFrameMode();
	nr->DrawPath( &path, &attr );


	//start rectangle
	// back to red	
	attr.SetARGB( 0xFFFF, 0xCD00, 0x3900, 0x3200 );
	path1.MoveTo( hsIntToScalar(100), hsIntToScalar(100));
	
   hsRect r;
   r.Set(hsIntToScalar(100), hsIntToScalar(100), hsIntToScalar(200), hsIntToScalar(200));
	path1.AddRect( &r );
	//end rectangle 

	// start polygon 
    hsPoint2 poly1[] = { { hsIntToScalar(300), hsIntToScalar(300)}, 
						 { hsIntToScalar(370), hsIntToScalar(350)},
						 { hsIntToScalar(350), hsIntToScalar(400)},
						 { hsIntToScalar(270), hsIntToScalar(350)} };

	path1.MoveTo(hsIntToScalar(300), hsIntToScalar(300));
	path1.AddPoly(4,poly1, true);
	nr->DrawPath( &path1, &attr );
    // end polygon 

#ifndef NO_FONT_FILES
	// blue extruded text
	attr.SetARGB( 0xFFFF, 0x1300, 0x4400, 0xC600 );

	attr.SetTextSize( hsIntToScalar(50) );
	attr.SetFontID(hsGFontList::Get(pts->outlineFontIndex));
	
	hsScalar x = hsIntToScalar(50);
	hsScalar y = hsIntToScalar(190);

	hsGRasterizer*	extrude = new	hsGExtruderizer
									(
										hsIntToScalar( 6 ),
										hsIntToScalar( 12 ),
										0xFFFF,
										0x6000,
										attr.GetTextSize()
									);
	
	attr.SetRasterizer( extrude );
	extrude->UnRef();

  	nr->DrawParamText( 7, "IMPULSE", x, y, &attr );
#endif

	nr->rasterize();
}

/***********************************************************/

/***********************************************************/
void DrawTextEffects( NuonRaster *nr, TestSetup *pts )
{
#ifdef NO_FONT_FILES
	return;
#endif

	if (!nr) return;

	int sbitsFontIndex = pts->sbitsFontIndex;
	int outlineFontIndex = pts->outlineFontIndex;

	if (sbitsFontIndex >= (int) hsGFontList::Count()) {
			// triggers adding additional fonts
			AddFonts(pts);
	}
	if (sbitsFontIndex >= (int) hsGFontList::Count()) sbitsFontIndex = 0;

	if (outlineFontIndex >= (int) hsGFontList::Count()) {
			// triggers adding additional fonts
			AddFonts(pts);
	}
	if (outlineFontIndex >= (int) hsGFontList::Count()) outlineFontIndex = 0;


	hsGAttribute	attr(hsGAttribute::kAntiAlias);


	//Blur
	attr.SetTextSize(hsIntToScalar(48));

	hsGBlurMaskFilter	blur(0, hsIntToScalar(4), true, attr.GetTextSize());
	
	attr.SetARGB(0xFFFF, 0, 0, 0xFFFF);
	attr.SetMaskFilter(&blur);

	attr.SetFontID(hsGFontList::Get(sbitsFontIndex));
	nr->DrawParamText(4, "Blur", hsIntToScalar(120), hsIntToScalar(100), &attr);

	attr.SetFontID(hsGFontList::Get(outlineFontIndex));
	nr->DrawParamText(4, "Blur", hsIntToScalar(260), hsIntToScalar(100), &attr);

	attr.SetMaskFilter(nil);

	//Ramp
	attr.SetTextSize(hsIntToScalar(80));

	hsGLinearGradientShader	grad(attr.GetTextSize());
	hsPoint2				p0 = { 0, 0 };
	hsPoint2				p1 = { hsIntToScalar(10), hsIntToScalar(7) };
	hsGColor				colors[] = { {0xFFFF, 0xFFFF, 0x8000, 0x4000}, {0xFFFF, 0x0, 0x8000, 0x0800} };
	grad.SetPoints(&p0, &p1);
	grad.SetGradient(2, colors, nil, grad.kMirrorTile);
	attr.SetShader(&grad);

	attr.SetARGB(0xFFFF, 0, 0, 0xFFFF);

	attr.SetFontID(hsGFontList::Get(sbitsFontIndex));
	nr->DrawParamText(4, "Ramp", hsIntToScalar(100), hsIntToScalar(190), &attr);

	attr.SetFontID(hsGFontList::Get(outlineFontIndex));
	nr->DrawParamText(4, "Ramp", hsIntToScalar(400), hsIntToScalar(190), &attr);
	attr.SetShader(nil);

	//Emboss
	attr.SetTextSize(hsIntToScalar(60));

	hsGEmbossRecord		rec;
	rec.Reset();
	hsGEmbossMaskFilter	emboss(&rec, attr.GetTextSize());
	hsGTextSpacing		spacing;

	spacing.fCharExtra = hsIntToScalar(8);
	attr.SetTextSpacing(&spacing);
	attr.SetARGB(0xFFFF, 0x4000, 0x4000, 0x4000);
	attr.SetMaskFilter(&emboss);

	attr.SetFontID(hsGFontList::Get(sbitsFontIndex));
	nr->DrawParamText(6, "Emboss", hsIntToScalar(110), hsIntToScalar(300), &attr);

	attr.SetFontID(hsGFontList::Get(outlineFontIndex));
	nr->DrawParamText(6, "Emboss", hsIntToScalar(360), hsIntToScalar(360), &attr);

	nr->rasterize();

	// Do this since the attr deletes last
	attr.SetMaskFilter(nil);
}

/***********************************************************/

/***********************************************************/
inline hsGColorValue RColor(UInt32 mask)
{
	return (hsGColorValue) (rand() & mask);
}

/***********************************************************/

/***********************************************************/
void DrawRotate( NuonRaster *nr, TestSetup *pts )
{
#ifdef NO_FONT_FILES
	return;
#endif

	if (!nr) return;

	hsGAttribute	attr;
	hsScalar		x, y;


	int sbitsFontIndex = pts->sbitsFontIndex;
	int outlineFontIndex = pts->outlineFontIndex;

	if (sbitsFontIndex >= (int) hsGFontList::Count()) {
			// triggers adding additional fonts
			AddFonts(pts);
	}
	if (sbitsFontIndex >= (int) hsGFontList::Count()) sbitsFontIndex = 0;

	if (outlineFontIndex >= (int) hsGFontList::Count()) {
			// triggers adding additional fonts
			AddFonts(pts);
	}
	if (outlineFontIndex >= (int) hsGFontList::Count()) outlineFontIndex = 0;

	
	BlankBackground (nr);

	// only set for antialiasing if the background isn't transparent
	int colorDepth = nr->GetDepth();
	if (colorDepth != CLUT_DEPTH) {
		attr.SetFlags(attr.GetFlags() | hsGAttribute::kAntiAlias);
	}

	attr.SetTextSize(hsIntToScalar(36));

	// first draw it with bitmap fonts
	attr.SetFontID(hsGFontList::Get(sbitsFontIndex));

	x = hsIntToScalar(540);
	y = hsIntToScalar(140);
	int i;

	nr->Save();
	for (i = 0; i < 360; i += 20)
	{
		if (colorDepth == CLUT_DEPTH) {
			attr.SetColorIndex (RColor(0xFF));
		}
		else {
			attr.SetARGB(0xFFFF, RColor(0xFFFF), RColor(0xFFFF), RColor(0xFFFF));
		}
		nr->DrawParamText(4, "nuon", x, y, &attr);
		nr->Rotate(hsIntToScalar(20), x, y);
	}
	nr->Restore();

	nr->Save();

	// then with outline fonts
	attr.SetFontID(hsGFontList::Get(outlineFontIndex));

	x = hsIntToScalar(540);
	y = hsIntToScalar(320);

	for (i = 0; i < 360; i += 20)
	{
		if (colorDepth == CLUT_DEPTH) {
			attr.SetColorIndex (RColor(0xFF));
		}
		else {
			attr.SetARGB(0xFFFF, RColor(0xFFFF), RColor(0xFFFF), RColor(0xFFFF));
		}
		nr->DrawParamText(4, "nuon", x, y, &attr);
		nr->Rotate(hsIntToScalar(20), x, y);
	}
	nr->Restore();

	nr->rasterize();
}

/***********************************************************/

/***********************************************************/
void GradientFillShapeOld ( NuonRaster *nr, TestSetup *pts )
{
	if (!nr) return;


	hsPath			path;
	hsGAttribute	attr( hsGAttribute::kAntiAlias );

	//first, fill the background
	if (nr->GetDepth() == CLUT_DEPTH) {

		// erase transparent (or whatever is in last loc)
		NuonYccColorTable *nrTable = nr->GetClut();
		unsigned count = nrTable->GetCount();
		nr->Erase (count - 1);
	}
	else {
		//background
		hsGColor color;
		color.SetARGB(0xffff, 0x0, 0x0, 0x0);
		nr->Erase (&color);

	}

	attr.SetARGB( 0xFFFF, 0, 0xFFFF, 0xFFFF );	


	path.MoveTo( hsIntToScalar(0), hsIntToScalar(nr->mHeight-1) );
	path.CurveTo
	(
		hsIntToScalar(0), hsIntToScalar(nr->mHeight-1), 
		hsIntToScalar(nr->mWidth/4), hsIntToScalar(nr->mHeight/4),
		hsIntToScalar(nr->mWidth-1), hsIntToScalar(0)
	);

	path.MoveTo( hsIntToScalar(nr->mWidth-1), hsIntToScalar(0) );
	path.CurveTo
	(
		hsIntToScalar(nr->mWidth-1), hsIntToScalar(0), 
		hsIntToScalar(7*nr->mWidth/8), hsIntToScalar(7*nr->mHeight/8),
		hsIntToScalar(0), hsIntToScalar(nr->mHeight-1)
	);

	/*
    hsPoint2 poly1[] = { { hsIntToScalar(0), hsIntToScalar(nr->mHeight-1)}, 
						 { hsIntToScalar(nr->mWidth/4), hsIntToScalar(nr->mHeight/4)},
						 { hsIntToScalar(nr->mWidth-1), hsIntToScalar(0)},
						 { hsIntToScalar(3*nr->mWidth/4), hsIntToScalar(3*nr->mHeight/4)} };

	path.MoveTo(hsIntToScalar(0), hsIntToScalar(nr->mHeight-1));
	path.AddPoly(4,poly1, true);
	*/

	path.Close();
	nr->DrawPath( &path, &attr );

	attr.SetShader(0);

	nr->rasterize();
}

/***********************************************************/
void BlankBackground (NuonRaster *nr)
{
	if (nr->GetDepth() == CLUT_DEPTH) {

		// erase transparent (or whatever is in last loc)
		NuonYccColorTable *nrTable = nr->GetClut();
		unsigned count = nrTable->GetCount();
		nr->Erase (count - 1);
	}
	else {
		//erase black
		hsGColor color;
		color.SetARGB(0xffff, 0x0, 0x0, 0x0);
		nr->Erase (&color);
	}
}

void BlankBackground ( NuonRaster *nr, TestSetup *pts )
{
	BlankBackground (nr);
	nr->rasterize();
}
/***********************************************************/
void ComplexClipAndGradientFill ( NuonRaster *nr, TestSetup *pts )
{
	if (!nr) return;


	hsPath			path;
	hsGAttribute	attr( hsGAttribute::kAntiAlias );

	//first, fill the background
	if (nr->GetDepth() == CLUT_DEPTH) {

		// erase transparent (or whatever is in last loc)
		NuonYccColorTable *nrTable = nr->GetClut();
		unsigned count = nrTable->GetCount();
		nr->Erase (count - 1);
	}
	else {
		//background
		hsGColor color;
		color.SetARGB(0xffff, 0x0, 0x0, 0x0);
		nr->Erase (&color);

	}

	attr.SetARGB( 0xFFFF, 0, 0xFFFF, 0xFFFF );	
	
	// Draw a gradient wash from green to blue.
	hsPoint points[2] = {{hsIntToScalar(0),hsIntToScalar(0)}, 
				{hsIntToScalar(nr->mWidth), hsIntToScalar(nr->mHeight)}};
	hsScalar intervals[4] = {0, hsFixedToScalar(22000), hsFixedToScalar(44000), hsIntToScalar(1)};  
	hsGColor colors[4];
	colors[0].SetARGB(0xFFFF, 0x0000, 0xFFFF, 0x0000);	// start
	colors[1].SetARGB(0xFFFF, 0xFFFF, 0xFFFF, 0x0000);	// stop
	colors[2].SetARGB(0xFFFF, 0x0000, 0x0000, 0xFFFF);	// stop
	colors[3].SetARGB(0xFFFF, 0x0000, 0xFFFF, 0xFFFF);	// stop
	hsGLinearGradientShader gradient;
	gradient.SetGradient(4, colors, intervals, gradient.kClampTile);
	gradient.SetPoints(&points[0], &points[1]);
	attr.SetShader(&gradient);


	path.MoveTo( hsIntToScalar(0), hsIntToScalar(nr->mHeight-1) );
	path.CurveTo
	(
		hsIntToScalar(0), hsIntToScalar(nr->mHeight-1), 
		hsIntToScalar(nr->mWidth/4), hsIntToScalar(nr->mHeight/4),
		hsIntToScalar(nr->mWidth-1), hsIntToScalar(0)
	);

	path.MoveTo( hsIntToScalar(nr->mWidth-1), hsIntToScalar(0) );
	path.CurveTo
	(
		hsIntToScalar(nr->mWidth-1), hsIntToScalar(0), 
		hsIntToScalar(7*nr->mWidth/8), hsIntToScalar(7*nr->mHeight/8),
		hsIntToScalar(0), hsIntToScalar(nr->mHeight-1)
	);


	path.AddCircle (hsIntToScalar((nr->mWidth*640)/720), hsIntToScalar((nr->mHeight*250)/480), 
						hsIntToScalar(50));
	path.AddCircle (hsIntToScalar((nr->mWidth*600)/720), hsIntToScalar((nr->mHeight*384)/480), 
						hsIntToScalar(56));
	path.AddCircle (hsIntToScalar((nr->mWidth*435)/720), hsIntToScalar((nr->mHeight*442)/480), 
						hsIntToScalar(64));
	path.AddCircle (hsIntToScalar((nr->mWidth)*140/720), hsIntToScalar((nr->mHeight)*85/480), 
						hsIntToScalar(40));
	path.AddCircle (hsIntToScalar((nr->mWidth)*73/720), hsIntToScalar((nr->mHeight)*284/480), 
						hsIntToScalar(60));
	path.Close();
	nr->ClipPath(&path);

	nr->DrawFull(&attr);

	attr.SetShader(0);

	nr->rasterize();
}

/***********************************************************/
/***********************************************************/
// extruded text with light colors for the main plane, intended to be 
// mixed with translucent osd plane

void Impulsive( NuonRaster *nr, TestSetup *pts )
{
	if (!nr) return;

	hsPath			path,path1;
	hsGAttribute	attr( hsGAttribute::kAntiAlias );

#ifndef NO_FONT_FILES
	attr.SetARGB( 0xFFFF, 0, 0, 0x8000 );
	attr.SetTextSize( hsIntToScalar(80) );


	// use outline fonts
	attr.SetFontID(hsGFontList::Get(pts->outlineFontIndex));


#if !defined(NUON_NATIVE_FONTS) && defined(WIN32)
	attr.SetFontID (hsGFontList::Find (hsGFontList::kAnyName, "Times New Roman"));
#endif

	hsScalar x = hsIntToScalar(60);
	hsScalar y = hsIntToScalar(140);

	hsGRasterizer*	extrude = new	hsGExtruderizer
									(
										hsIntToScalar( 6 ),
										hsIntToScalar( 16 ),
										0xFFFF,
										0x6000,
										attr.GetTextSize()
									);
	
	attr.SetRasterizer( extrude );
	extrude->UnRef();
  	nr->DrawParamText( 2, "IM", x, y, &attr );
//
//

#if !defined(NUON_NATIVE_FONTS) && defined(WIN32)
	attr.SetFontID (hsGFontList::Find (hsGFontList::kAnyName, "Comic Sans MS"));
#endif

	attr.SetARGB( 0xFFFF, 0x8000, 0, 0x8000 );
	attr.SetTextSize( hsIntToScalar(50) );

	x += hsIntToScalar(100);
	y += hsIntToScalar(100);
	extrude = new	hsGExtruderizer
					(
						hsIntToScalar( 11 ),
						hsIntToScalar( 11 ),
						0xFFFF,
						0x6000,
						attr.GetTextSize()
					);
	
	attr.SetRasterizer( extrude );
	extrude->UnRef();
  	nr->DrawParamText( 6, "IMPULS", x, y, &attr );
//
//

#if !defined(NUON_NATIVE_FONTS) && defined(WIN32)
	attr.SetFontID (hsGFontList::Find (hsGFontList::kAnyName, "Courier New"));
#endif

	attr.SetARGB( 0xFFFF, 0x8000, 0, 0 );
	attr.SetTextSize( hsIntToScalar(70) );

	x += hsIntToScalar(120);
	y += hsIntToScalar(80);
	extrude = new	hsGExtruderizer
					(
						hsIntToScalar( 16 ),
						hsIntToScalar( 6 ),
						0xFFFF,
						0x6000,
						attr.GetTextSize()
					);
	
	attr.SetRasterizer( extrude );
	extrude->UnRef();
  	nr->DrawParamText( 9, "IMPULSIVE", x, y, &attr );


	nr->rasterize();
#endif
}

/***********************************************************/



