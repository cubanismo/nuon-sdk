/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * 
 * * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 * Palette building routines for Nuon color tables
 */


#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include "palettes.h"


/***********************************************************/
// make a primary/secondary palette of < 256 colors
// use 28 variants each of 7 colors -> 196 colors
#define COLOR_FAMILIES 7
#define ENTRIES 28
enum {red=0, blue=1, green=2, yellow=3, cyan=4, magenta=5, gray=6};

NuonYccColorTable *MakeSmallerPalette (void)
{
	NuonYccColorTable *cTable = new NuonYccColorTable();
	assert (cTable != NULL);

	hsGColor rgb16Bit;
	hsGColor sat16Bit [COLOR_FAMILIES];
	hsGColor dec16Bit [COLOR_FAMILIES - 1];
	hsColor32 rgb8Bit [COLOR_FAMILIES * ENTRIES];

	assert ((COLOR_FAMILIES * ENTRIES) <= COLOR_TABLE_DEPTH);

	int deltaColor = 0x10000 / (ENTRIES/2);

	unsigned perCountColor;

	//decrement arrays for getting from white to saturation
	dec16Bit[red].SetARGB (0, 0, deltaColor, deltaColor);
	dec16Bit[blue].SetARGB (0, deltaColor, deltaColor, 0);
	dec16Bit[green].SetARGB (0, deltaColor, 0, deltaColor);
	dec16Bit[yellow].SetARGB (0, 0, 0, deltaColor);
	dec16Bit[cyan].SetARGB (0, deltaColor, 0, 0);
	dec16Bit[magenta].SetARGB (0, 0, deltaColor, 0);

	//saturated colors
	sat16Bit[red].SetARGB (0xFFFF, 0xFFFF, 0, 0);
	sat16Bit[blue].SetARGB (0xFFFF, 0, 0, 0xFFFF);
	sat16Bit[green].SetARGB (0xFFFF, 0, 0xFFFF, 0);
	sat16Bit[yellow].SetARGB (0xFFFF, 0xFFFF, 0xFFFF, 0);
	sat16Bit[cyan].SetARGB (0xFFFF, 0, 0xFFFF, 0xFFFF);
	sat16Bit[magenta].SetARGB (0xFFFF, 0xFFFF, 0, 0xFFFF);
	sat16Bit[gray].SetARGB (0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF);

	for (int colorFamily = red; colorFamily < (COLOR_FAMILIES - 1); colorFamily++) {

		// white to saturation
		rgb16Bit.SetARGB (0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF);
		for (perCountColor = 0; perCountColor < ENTRIES/2; perCountColor++) {

			// set
			rgb8Bit[(colorFamily * ENTRIES) + perCountColor].Set( 
				UInt8(rgb16Bit.fA >> 8), 
				UInt8(rgb16Bit.fR >> 8), 
				UInt8(rgb16Bit.fG >> 8), 
				UInt8(rgb16Bit.fB >> 8));


			// decrement
			rgb16Bit.SetARGB (0xFFFF, 
				(rgb16Bit.fR > deltaColor ? 
						rgb16Bit.fR - dec16Bit[colorFamily].fR : 0),
				(rgb16Bit.fG > deltaColor ? 
						rgb16Bit.fG - dec16Bit[colorFamily].fG : 0),
				(rgb16Bit.fB > deltaColor ? 
						rgb16Bit.fB - dec16Bit[colorFamily].fB : 0));
		}

		// saturation to black
		rgb16Bit.SetARGB (	sat16Bit[colorFamily].fA, 
							sat16Bit[colorFamily].fR, 
							sat16Bit[colorFamily].fG, 
							sat16Bit[colorFamily].fB);
		for (perCountColor = ENTRIES/2; perCountColor < ENTRIES; perCountColor++) {

			// set
			rgb8Bit[(colorFamily * ENTRIES) + perCountColor].Set( 
				UInt8(rgb16Bit.fA >> 8), 
				UInt8(rgb16Bit.fR >> 8), 
				UInt8(rgb16Bit.fG >> 8), 
				UInt8(rgb16Bit.fB >> 8));

			// decrement
			rgb16Bit.SetARGB (0xFFFF, 
				(rgb16Bit.fR > deltaColor ? rgb16Bit.fR - deltaColor : 0),
				(rgb16Bit.fG > deltaColor ? rgb16Bit.fG - deltaColor : 0),
				(rgb16Bit.fB > deltaColor ? rgb16Bit.fB - deltaColor : 0));
		}
	}

	// saturated form of gray is white, where we start
	deltaColor /= 2;	
	rgb16Bit.SetARGB (0xFFFF, 0xFFFF, 0xFFFF, 0xFFFF);
	for (perCountColor = 0; perCountColor < ENTRIES; perCountColor++) {

		// set
		rgb8Bit[(gray * ENTRIES) + perCountColor].Set( 
			UInt8(rgb16Bit.fA >> 8), 
			UInt8(rgb16Bit.fR >> 8), 
			UInt8(rgb16Bit.fG >> 8), 
			UInt8(rgb16Bit.fB >> 8));

		// decrement
		rgb16Bit.SetARGB (0xFFFF, 
			(rgb16Bit.fR > deltaColor ? rgb16Bit.fR - deltaColor : 0),
			(rgb16Bit.fG > deltaColor ? rgb16Bit.fG - deltaColor : 0),
			(rgb16Bit.fB > deltaColor ? rgb16Bit.fB - deltaColor : 0));
	}



	cTable->SetColors (rgb8Bit, 0, (COLOR_FAMILIES * ENTRIES));
	return cTable;
}
/***********************************************************/

/***********************************************************/
#define NUM_COLORS 16
#define NUM_TRANSLUCENCIES (COLOR_TABLE_DEPTH/NUM_COLORS)

NuonYccColorTable *ChromaAndAlpha (void)
{
	NuonYccColorTable *cTable = new NuonYccColorTable();
	assert (cTable != NULL);

	NuonYccColor nColors[COLOR_TABLE_DEPTH];

	int deltaColor = 0xF0/NUM_COLORS * 4;
	int deltaTrans = 0x100/NUM_TRANSLUCENCIES;
	int accum;

	// opaque set
	int colors;

	// vary Cr & Cb
	accum = 0; 
	for (colors = 0; colors < NUM_COLORS/4; colors++) {
		nColors[colors] = 0xB0000000 + (accum << 16);
		accum += deltaColor;
		if (accum > 0xFF) accum = 0xFF;
	}

	accum = 0;
	for (colors = NUM_COLORS/4; colors < NUM_COLORS/2; colors++) {
		nColors[colors] = 0xB0FF0000 + (accum << 8);
		accum += deltaColor;
		if (accum > 0xFF) accum = 0xFF;
	}

	accum = 0xF0 - deltaColor;
	for (colors = NUM_COLORS/2; colors < (NUM_COLORS/2 + NUM_COLORS/4); colors++) {
		nColors[colors] = 0xB000FF00 + (accum << 16);
		accum -= deltaColor;
		if (accum < 0) accum = 0;
	}

	accum = 0xF0 - deltaColor;
	for (colors = (NUM_COLORS/2 + NUM_COLORS/4); colors < NUM_COLORS; colors++) {
		nColors[colors] = 0xB0000000 + (accum << 8);
		accum -= deltaColor;
		if (accum < 0) accum = 0;
	}

	//do translucencies
	int transl;
	for (colors = 0; colors < NUM_COLORS; colors++) {
		accum = deltaTrans;

		for (transl = 1; transl < NUM_TRANSLUCENCIES; transl++) {
			nColors[(transl * NUM_TRANSLUCENCIES) + colors] =
							(nColors[colors] & 0xFFFFFF00) + accum;
			accum += deltaTrans;
			if (accum > 0xFF) accum = 0xFF;
		}
	}

	// overwrite last valid count with transparent color
	nColors[COLOR_TABLE_DEPTH - 1] = 0x000000FF;

	cTable->SetColors (nColors, 0, COLOR_TABLE_DEPTH);

#if defined (PRINT_DEBUG)
	// state (for debug)
	//cTable->PrintState ("ChromaAndAlpha", 1);
#endif

	return cTable;
}
/***********************************************************/

/***********************************************************/
// a wrapper to use a default translucency value (~80% transparent)
NuonYccColorTable *UniformTranslucency (void)
{

	UInt8 transValue = (UInt8) (0xFF * 0.6);
	return UniformTranslucency (transValue);
}


// a translucent palette builder with selectable translucency
// This is Nuon translucency; i.e. 0xFF is completely transparent
NuonYccColorTable *UniformTranslucency (UInt8 transValue)
{
	NuonYccColorTable *cTable = new NuonYccColorTable;

	hsGColorTable *aglTable = new hsGColorTable;
	assert ((cTable != NULL) && (aglTable != NULL));

	// Impulse's well-balanced default table
	aglTable->SetDefaultColorTable();

	UInt8 alphas[COLOR_TABLE_DEPTH];
	for (int i=0; i<(COLOR_TABLE_DEPTH-2); i++) alphas[i] = transValue;
	alphas[COLOR_TABLE_DEPTH-1] = 0xFF;  // transparent

	cTable->SetColors (aglTable->PeekColors(), 0, aglTable->GetCount(),
							0, alphas);

	delete aglTable;

	return cTable;
}
/***********************************************************/
