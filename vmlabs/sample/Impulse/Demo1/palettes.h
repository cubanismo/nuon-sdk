/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 *
 * header for the general-purpose set of Nuon palette builders
*/
#ifndef PALETTES_H
#define PALETTES_H

#ifdef WIN32
#pragma include_alias( <impulse/NuonRaster.h>, <NuonRaster.h> )
#pragma include_alias( <impulse/NuonYccColorTable.h>, <NuonYccColorTable.h> )
#endif

#include <impulse/NuonRaster.h>
#include <impulse/NuonYccColorTable.h>

NuonYccColorTable *MakeSmallerPalette (void);
NuonYccColorTable *ChromaAndAlpha (void);

// a wrapper to use a default translucency value
NuonYccColorTable *UniformTranslucency (void);

// a translucent palette builder with selectable translucency
// This is Nuon translucency; i.e. 0xFF is completely transparent
NuonYccColorTable *UniformTranslucency (UInt8 transValue);


#endif PALETTES_H

