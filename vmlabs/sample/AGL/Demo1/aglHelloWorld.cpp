/* Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 *
 * AglHelloWorld -- the AlphaMask Hello World code sample, adapted
 * for NUON
 * 
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
#pragma include_alias( <impulse/hsGDashPathEffect.h>, <hsGDashPathEffect.h> )
#endif

#include <impulse/hsGExtruderizer.h>
#include <impulse/hsGBlurMaskFilter.h>
#include <impulse/hsGGradientShader.h>
#include <impulse/hsGEmbossMaskFilter.h>
#include <impulse/hsGDashPathEffect.h>


void DrawAGLDemo (NuonRaster *nr, TestSetup *pts) {

	nr->Save();

	// Create an offscreen device, for rendering into (This allocates
	// the device -- and its bits -- each time the window is updated.)
	////// hsGOffscreenDevice device;
	// set its width, height, and pixel depth
	const int offsetFrom00 = 64;
	const int width = 400;
	const int height = 300;
	////// nr->SetSize(width, height, 32);
	
	// Erase the pixels.  (This gets overwritten by the
	// next block which draws the gradient, but it's handy to see how
	// to do.)
	hsGColor bgColor = {0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF};	
	nr->Erase(&bgColor);

	// offset the whole thing from the corner
	nr->Translate (hsIntToScalar(offsetFrom00), hsIntToScalar(offsetFrom00));
	// Clip to a rounded rectangle
	hsRect clipBounds = {hsIntToScalar(0), hsIntToScalar(0), 
						hsIntToScalar(width), hsIntToScalar(height)};
	hsPath clipPath;
	clipPath.AddRRect(&clipBounds, hsIntToScalar(60), hsIntToScalar(60));
	nr->ClipPath(&clipPath);


	// Allocate an attribute to control the drawing style.
	// This will be repeatedly modified and reused below.
#ifdef WIN32
	hsGAttribute attr;
#else
	hsGAttribute attr(hsGAttribute::kAntiAlias);
#endif
	
	// Draw a gradient wash from black to blue.
	hsPoint points[2] = {{hsIntToScalar(0),hsIntToScalar(0)}, 
				{hsIntToScalar(width), hsIntToScalar(height)}};
	hsScalar intervals[2] = {0, 1};  
	hsGColor colors[2];
	colors[0].SetARGB(0xFFFF, 0x0000, 0x0000, 0x0000);	// start
	colors[1].SetARGB(0xFFFF, 0x0000, 0x0000, 0xFFFF);	// stop
	hsGLinearGradientShader gradient;
	gradient.SetGradient(2, colors, intervals, gradient.kClampTile);
	gradient.SetPoints(&points[0], &points[1]);
	attr.SetShader(&gradient);
	nr->DrawFull(&attr);
	attr.SetShader(0);

	// Make an oval.
	hsPath oval;
	hsRect ovalBounds = {hsIntToScalar(100), hsIntToScalar(50), 
		hsIntToScalar(200), hsIntToScalar(250)};
	oval.AddOval(&ovalBounds);
	
	// Fill the oval with a radial green->blue gradient.
	colors[0].SetARGB(0xFFFF, 0x0000, 0xFFFF, 0x0000);
	colors[1].SetARGB(0xFFFF, 0x0000, 0x0000, 0xFFFF);
	hsPoint center = {hsIntToScalar(150), hsIntToScalar(150)};
	hsScalar radius = hsIntToScalar(100);
	hsGRadialGradientShader radial;
	radial.SetGradient(2, colors, intervals, radial.kClampTile);
	radial.SetRadial(&center, radius);
	attr.SetShader(&radial);
	nr->DrawPath(&oval, &attr);
	attr.SetShader(0);


	// Frame the oval in blue.
	attr.SetARGB(0xFFFF, 0x0000, 0x0000, 0xFFFF);
	attr.SetFrameMode();
	attr.SetFrameSize(hsIntToScalar(20));
	nr->DrawPath(&oval, &attr);


	// Rotate the device, and draw "AlphaMask" in large red letters.
	// (Instead of using Save() and Restore(), we could also have used
	// a nested block, and declared an object of type hsGSaveRestore.)
	nr->Save();
	nr->Rotate(hsIntToScalar(30), hsIntToScalar(width/2), hsIntToScalar(height/2));
	attr.SetTextSize(hsIntToScalar(50));
	attr.SetARGB(0xFFFF, 0xFFFF, 0x0000, 0x0000);
	nr->DrawParamText(9, "AlphaMask", hsIntToScalar(50), hsIntToScalar(200), &attr);
	nr->Restore();

	// Dash the outline of letters "AGL", and draw the dashes embossed.
	// Set the font, if it's available
	attr.SetTextSize(hsIntToScalar(190));
	if (hsGFontID fontId = hsGFontList::Find(hsGFontList::kFamilyName, "Times New Roman"))
		attr.SetFontID(fontId);

	// Get the outline of the letters as a path, and move them
	// to the middle.
	hsPath lettersShape;
	attr.GetTextPath(3, "AGL", &lettersShape);
	lettersShape.Translate(hsIntToScalar(0), hsIntToScalar(215));
	// Set them to draw framed (instead of filled), and dashed.
	attr.SetFrameMode();
	attr.SetFrameSize(hsIntToScalar(5));
	hsScalar dashArray[] = {hsIntToScalar(10), hsIntToScalar(5)};
	hsGDashPathEffect dasher(2, dashArray, 1);
	attr.SetPathEffect(&dasher);
	// Set up a light source for embossing.
	hsGEmbossRecord embossRecord;
	embossRecord.fRadius = hsIntToScalar(4);
	embossRecord.fLight[0] = hsIntToScalar(-1);
	embossRecord.fLight[1] = hsIntToScalar(-1);
	embossRecord.fLight[2] = hsIntToScalar(1);
	//embossRecord.fKs = .1f;
	//embossRecord.fKd = .6f;
	embossRecord.fKs = hsFixedToScalar(6554);  // 0.1 expressed in 16.16 fixed
	embossRecord.fKd = hsFixedToScalar(39322); // 0.6 expressed in 16.16 fixed
	embossRecord.Normalize();
	hsGEmbossMaskFilter embosser(&embossRecord, 0);
	attr.SetMaskFilter(&embosser);
	// Set the color to magenta, and draw.
	attr.SetARGB(0xFFFF, 0xFFFF, 0x0000, 0xFFFF);
	nr->DrawPath(&lettersShape, &attr);
	attr.SetMaskFilter(0);
	attr.SetPathEffect(0);


	// Finally, copy the buffer to the screen.
	nr->rasterize();

	nr->Restore();
}
