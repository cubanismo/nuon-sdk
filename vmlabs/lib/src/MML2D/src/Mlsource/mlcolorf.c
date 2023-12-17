
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


//========================================================================
// Color C API, floating-point functions.
//
// rwb 4/18/97
// rwb 3/19/97 - Floating Point Version - also YCrCb
//  - int functions are incorrect.
// ers 3/26/98 - revised floating point version 
// rws 11/8/00 - added NTSC color-safe code.  You can disable this code
//     by defining the symbol ALLOW_UNSAFE_COLORS.
// rws 30 Nov 2000 - fixed typo in mmlSafeColor().
// rws 16 Jan 2001 - extensive modifications: (1) Split file into mlcolor.c
//     for fixed-point functions and mlcolorf.c for floating-point
//     functions; (2) replaced findSafeColor() with fixed-point version
//     developed by Matthew Halfant; and (3) restructured and editted the
//     source code.  This file needs run-time floating-point support.
//========================================================================

#include "../../nuon/mml2d.h"

//------------------------------------------------------------------------
// Deliver the minimum or maximum of two values, any commensurable types.
//------------------------------------------------------------------------
#define _min(x,y) ((x) < (y) ? (x) : (y))
#define _max(x,y) ((x) > (y) ? (x) : (y))

//------------------------------------------------------------------------
// Bound an expression to the interval [low,high].  Works for any types
// that are commensurable.
//------------------------------------------------------------------------
#define Bound(low, high, x) _max((low), _min((high), (x)))

//------------------------------------------------------------------------
// The following two macros convert CONSTANT floating-point values into
// either 16.16-bit or 12.20-bit fixed-point forms.  Use to populate
// the color limits table.
//------------------------------------------------------------------------
#define Fix16(x) ((f16Dot16)((x)*65536.0+0.5))

//------------------------------------------------------------------------
// Return a NUON color constructed from the given YCrCb values.  The luma
// argument y should lie in the interval [0.0,1.0].  The two chroma
// arguments cr and cb should each lie in the interval [-0.5,+0.5].  The
// returned mmlColor conforms to the ITU-R BT.601 standard.  Safe-color
// limits are applied to prevent chroma oversaturation.
//------------------------------------------------------------------------
mmlColor mmlColorFromYCCf( double y, double cr, double cb )
{
    uint8 yk  = 16 + (int)(219.0*Bound(0.0, 1.0, y));
    uint8 crk = 128 + (int)(224.0*Bound(-0.5, 0.5, cr));
    uint8 cbk = 128 + (int)(224.0*Bound(-0.5, 0.5, cb));
    return mmlSafeColor((yk<<24) | (crk << 16 ) | (cbk << 8));
}

//------------------------------------------------------------------------
// Return a NUON color constructed from the given RGB values.  Each
// argument should lie in the interval [0.0,1.0].  The RGB color is
// converted into YCC form and converted into an mmlColor that conforms to
// the ITU-R BT.601 standard.  Safe-color limits are applied to prevent
// chroma oversaturation.
//------------------------------------------------------------------------
mmlColor mmlColorFromRGBf(  double rf, double gf, double bf )
{
    double  yf =  0.299 * rf + 0.587 * gf + 0.114 * bf;
    double crf =  0.500 * rf - 0.419 * gf - 0.081 * bf;
    double cbf = -0.169 * rf - 0.331 * gf + 0.500 * bf;
    return mmlColorFromYCCf(yf,crf,cbf);
}

//------------------------------------------------------------------------
// Extract YCrCb components of the given NUON color and return them as
// floating-point values in their canonical ranges:
//      0 <= *yP <= 255
//   -0.5 <= *crP <= 0.5
//   -0.5 <= *cbP <= 0.5
// Assumes that the given color conforms to ITU-R BT.601.
//------------------------------------------------------------------------
void mmlGetYCCFloatComponents( mmlColor color, double *yP, double *crP, double *cbP )
{
    int yx, crx, cbx;

    yx = ((color >> 24) & 0xff);
    crx = ((color >> 16) & 0xff);
    cbx = ((color >> 8) & 0xff);

    *yP  = Bound(0.0, 1.0, (yx - 16.0) / 219.0);
    *crP = Bound(-0.5, 0.5, (crx - 128.0) / 224.0);
    *cbP = Bound(-0.5, 0.5, (cbx - 128.0) / 224.0);
}

//------------------------------------------------------------------------
// Extract YCrCb components of the given NUON color, convert them to
// equivalent RGB form, and return the components as floating-point values,
// each in the interval [0.0, 1.0].
//------------------------------------------------------------------------
void mmlGetRGBFloatComponents( mmlColor color, double* rP, double* gP, double* bP)
{
    int yk, crk, cbk;
    double yf, crf, cbf;

    yk  = ((color >> 24) & 0xff);
    crk = ((color >> 16) & 0xff);
    cbk = ((color >> 8) & 0xff);

    yf  = Bound(0.0, 1.0, (yk - 16.0) / 219.0);
    crf = Bound(-0.5, 0.5, (crk - 128.0) / 224.0);
    cbf = Bound(-0.5, 0.5, (cbk - 128.0) / 224.0);

    *rP = Bound(0.0, 1.0, yf + 1.402 * crf);
    *gP = Bound(0.0, 1.0, yf -  0.714 * crf - 0.344 * cbf);
    *bP = Bound(0.0, 1.0, yf + 1.772 * cbf);
}

//------------------------------------------------------------------------
// For advanced users only.  Set explicit custom safe-color limits and
// select the custom set to use from now on.  Arguments ped, smax, smin,
// and cmax are in IRE units and are restricted to the following:
//      0 <= ped
//  -40.0 <= smin < smax < 130.0
//   25.0 <= cmax <= 100.0
// Returns 1 if successful, 0 if one or more of the arguments is invalid.
//------------------------------------------------------------------------
int mmlCustomSafeColorLimits( double ped, double smax, double smin, double cmax )
{
    // The following is an internal function defined in mlcolor.c
    extern void __SetSafeColorLimits(f16Dot16 ped, f16Dot16 smax, f16Dot16 smin, f16Dot16 cmax);

    if (ped < 0.0 || smin < -40.0 || smin >= smax || smax > 130.0
        || cmax < 25.0 || cmax > 100.0)
        return 0;           // invalid argument given   
    __SetSafeColorLimits(Fix16(ped), Fix16(smax), Fix16(smin), Fix16(cmax));
    return 1;
}
