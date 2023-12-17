
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


//========================================================================
// Color C API, fixed-point functions.
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
//     source code.  This file contains NO run-time floating-point
//     arithmetic.
// rws 25 May 2001 - conditionalized code to use the assembler version
//     of __findSafeColor() from mlsafec.s.
//------------------------------------------------------------------------
// The functions in this module produce NUON color (mmlColor) values from
// specified RGB or YCrCb arguments.  They accept only integer or
// fixed-point arguments and use only fixed-point arithmetic.  See the
// companion file mlcolorf.c for corresponding floating-point functions.
//
// A NUON color (mmlColor) is a 32-bit unsigned long number composed of
// luma, two chroma, and one control or alpha value:
//    31     24 23    16 15     8 7      0
//    +--------+--------+--------+--------+
//    |    Y   |   Cr   |   Cb   |  ctrl  |
//    +--------+--------+--------+--------+
//
// The values are expected to lie within the ranges required by the ITU-R
// BT.601 standard:
//    16 <= Y <= 235
//    16 <= Cr <= 240
//    16 <= Cb <= 240
//
// The functions in this module, except for mmlColorFromYCC(), produce
// colors whose components lie in these ranges.  The components will be
// further limited to "safe colors" that lie within the gamut supported by
// a particular video color standard (NTSC or PAL) to avoid oversaturation
// problems with composite video monitors.  Applications can defeat this
// safe-color limitation for special purposes.  They can also specify
// non-standard conversions.
//========================================================================

#include "../../nuon/mml2d.h"
#include <nuon/mutil.h>

//------------------------------------------------------------------------
// Define the following symbol to use the C version of __findSafeColor()
// defined in this file.  Leave the symbol undefined to use the faster
// assembler version from mlsafec.s.
//------------------------------------------------------------------------
//#define USEOLDFINDSAFECOLOR 1

//------------------------------------------------------------------------
// Set the following to correspond to the OEM platform preference.
//------------------------------------------------------------------------
#define DEFAULT_COLOR_LIMITS eSafeColorNTSC
static mmlSafeColorSel limitSelect = DEFAULT_COLOR_LIMITS;
//static mmlSafeColorSel limitSelect = eSafeColorDisable;

//------------------------------------------------------------------------
// Fixed-point calculations in this module are performed using either 16 or
// FBITS of fractional precision.
//------------------------------------------------------------------------
#define FBITS  20
typedef int fDotFBITS;

// Extract the integer part of a fixed-point value with FBITS fractional
// bits, rounding it by truncation.
#define RoundFBITS(x) ((int)(((x)+(1<<(FBITS-1)))>>FBITS))

// The following two macros convert CONSTANT floating-point values into
// their fixed-point approximations with either 16 for FBITS fractional
// bits.  Since the whole computation yields a constant, it is done by the
// compiler and not at run-time.
#define Fix16(x) ((f16Dot16)((x)*65536.0+0.5))
#define FixFBITS(x) ((fDotFBITS)((x)*(double)(1<<FBITS)+0.5))

//------------------------------------------------------------------------
// Deliver the minimum or maximum of two values, any commensurable types.
//------------------------------------------------------------------------
#define _min(x,y) ((x) < (y) ? (x) : (y))
#define _max(x,y) ((x) > (y) ? (x) : (y))

//------------------------------------------------------------------------
// Bound an expression to the unit interval [low, high]
//------------------------------------------------------------------------
#define Bound(low, high, x) _max((low), _min((high), (x)))

//------------------------------------------------------------------------
// Construct a 32-bit mmlColor from its integer components.
//------------------------------------------------------------------------
#define makeColor(y,cr,cb,alpha) (((y)<<24) | ((cr)<<16) | ((cb)<<8) | (alpha))

//------------------------------------------------------------------------
// Conversion to colors that are "safe" for composite video are
// restricted by the limits expressed in the following structure.
// Do not change the order of the following fields.  Future assembly
// language routines may depend on this order.
//------------------------------------------------------------------------
typedef struct {
    fDotFBITS rmax;             // derived relative composite maximum
    fDotFBITS rmin;             // derived relative composite minimum
    fDotFBITS chmax;            // derived relative max chroma span
    mmlSafeColorSel type;       // records associated type

    f16Dot16 ped;               // black level pedestal in IRE
    f16Dot16 smax;              // composite signal maximum IRE
    f16Dot16 smin;              // composite signal minimum IRE
    f16Dot16 cmax;              // chroma amplitude maximum in IRE
}
colorLimits;

//------------------------------------------------------------------------
// There are three predefined color limit sets, one of which is designated
// the default for the platform.  Another set is provided for custom
// limits, so advanced applications can make best use of, for example,
// black-level enhancement and blacker-than-black.
//
// DO NOT CHANGE THE ORDER OF THE FOLLOWING INITIALIZATIONS.
// They correspond to the order of the eSafeColorSel enumerations.
//------------------------------------------------------------------------
static colorLimits presetLimits[] = {
    // Custom color limits (eSafeColorCustom), initialized to 0 IRE setup NTSC.
    {
        FixFBITS((110.0-0.0)/(100.0-0.0)),  // rmax
        FixFBITS((-15.0-0.0)/(100.0-0.0)),  // rmin
        FixFBITS(50.0/(100.0-0.0)),         // chmax
        eSafeColorCustom,                   // type
        Fix16(0.0),                         // ped
        Fix16(110.0),                       // smax
        Fix16(-15.0),                       // smin
        Fix16(50.0),                        // cmax
    },
    // NTSC color limits using a 7.5 IRE setup (eSafeColorNTSC)
    {
        FixFBITS((110.0-7.5)/(100.0-7.5)),  // rmax
        FixFBITS((-15.0-7.5)/(100.0-7.5)),  // rmin
        FixFBITS(50.0/(100.0-7.5)),         // chmax
        eSafeColorNTSC,                     // type
        Fix16(7.5),                         // ped
        Fix16(110.0),                       // smax
        Fix16(-15.0),                       // smin
        Fix16(50.0),                        // cmax
    },
    // NTSC color limits using a 0 IRE setup (eSafeColorNTSCZero)
    {
        FixFBITS((110.0-0.0)/(100.0-0.0)),  // rmax
        FixFBITS((-15.0-0.0)/(100.0-0.0)),  // rmin
        FixFBITS(50.0/(100.0-0.0)),         // chmax
        eSafeColorNTSCZero,                 // type
        Fix16(0.0),                         // ped
        Fix16(110.0),                       // smax
        Fix16(-15.0),                       // smin
        Fix16(50.0),                        // cmax
    },
    // PAL color limits (uses a 0 IRE setup) (eSafeColorPAL)
    {
        FixFBITS((110.0-0.0)/(100.0-0.0)),  // rmax
        FixFBITS((-15.0-0.0)/(100.0-0.0)),  // rmin
        FixFBITS(50.0/(100.0-0.0)),         // chmax
        eSafeColorPAL,                      // type
        Fix16(0.0),                         // ped
        Fix16(110.0),                       // smax
        Fix16(-15.0),                       // smin
        Fix16(50.0),                        // cmax
    },
};

//------------------------------------------------------------------------
// Declare internal functions.  A C version of __findSafeColor() is defined
// below.  A much faster assembler version is defined in mlsafec.s.
//------------------------------------------------------------------------
mmlColor __findSafeColor ( mmlColor color, colorLimits *limits );

//------------------------------------------------------------------------
// Choose the set of safe-color limits to use when restricting NUON colors
// to safe colors.  Returns 1 if successful, 0 if the selector is invalid.
//------------------------------------------------------------------------
int mmlSafeColorLimits ( mmlSafeColorSel select )
{
    switch (select) {
        case eSafeColorDefault:
            limitSelect = DEFAULT_COLOR_LIMITS;
            break;
        case eSafeColorDisable:
        case eSafeColorNTSC:
        case eSafeColorNTSCZero:
        case eSafeColorPAL:
        case eSafeColorCustom:
            limitSelect = select;
            break;
        default:
            return 0;                   // unrecognized selector
    }
    return 1;
}

//------------------------------------------------------------------------
// Convert the given 32-bit NUON color into a safe color and return it
// (preserving the 8-bit control value).  If the color is already safe or
// if safe-color conversions have been disabled, then the argument is
// returend unchanged.
//------------------------------------------------------------------------
mmlColor mmlSafeColor ( mmlColor color )
{
    return (limitSelect == eSafeColorDisable ? color
            : __findSafeColor(color, &presetLimits[limitSelect]));
}

//------------------------------------------------------------------------
// Construct and return a 32-bit color from RGB values, each specified as
// an integer in the range [0,255].  The returned color is rendered safe
// according to the current safe-color limits.  It has a zero control
// value.
//------------------------------------------------------------------------
mmlColor mmlColorFromRGB ( uint8 r, uint8 g, uint8 b )
{
    int Y_601, Cr_601, Cb_601;

    // Arguments are in the range [0,255].  Convert to normalized
    // fixed-point values with FBITS-bit fractions.
    // Y  =  16 + 219*Round(0.299 * R + 0.587 * G + 0.114 * B
    // Cr = 128 + 224*Round(0.713*(0.701 * R - 0.587 * G - 0.l14 * B))
    // Cb = 128 + 224*Round(0.564*(-0.299 * R - 0.587 * G + 0.114 * B))
    // Here, R = r/255, G = g/255, B = b/255.  The computations below use
    // exact conversions, e.g., (0.5/0.701) instead of 0.713.
    // (This computation is fast -- three multiples by constants and two
    // additions for each component.)
    Y_601  =   FixFBITS(219.0 * 0.299/255.0) * r
             + FixFBITS(219.0 * 0.587/255.0) * g
             + FixFBITS(219.0 * 0.114/255.0) * b;
    Cr_601 =   FixFBITS(224.0 * (0.5/0.701) * (0.701/255.0)) * r
             - FixFBITS(224.0 * (0.5/0.701) * (0.587/255.0)) * g
             - FixFBITS(224.0 * (0.5/0.701) * (0.114/255.0)) * b;
    Cb_601 =  -FixFBITS(224.0 * (0.5/0.886) * (0.299/255.0)) * r
             - FixFBITS(224.0 * (0.5/0.886) * (0.587/255.0)) * g
             + FixFBITS(224.0 * (0.5/0.886) * (0.886/255.0)) * b;

    // Integerize and limit to ITU-R BT.601 ranges.
    Y_601  =  16 + Bound(0, 219, RoundFBITS(Y_601));
    Cr_601 = 128 + Bound(-112, 112, RoundFBITS(Cr_601));
    Cb_601 = 128 + Bound(-112, 112, RoundFBITS(Cb_601));

    return mmlSafeColor(makeColor(Y_601,Cr_601,Cb_601,0));
}

//------------------------------------------------------------------------
// Construct and return a 32-bit color from YCrCb values, each specified as
// an integer in the range [0,255].  The specified components are limited
// to 8-bit quantities only.  The control value is zero.
//
// IMPORTANT    The constructed color is NOT converted into a form
//              conforming to ITU-R BT.601, nor are safe-color limits
//              applied.  To restrict the constructed color to BT.601
//              form and to apply safe-color limits, call mmlSafeColor() on
//              the result.
//------------------------------------------------------------------------
mmlColor mmlColorFromYCC ( uint8 y, uint8 cr, uint8 cb )
{
    return makeColor(y & 0xFF, cr & 0xFF, cb & 0xFF, 0);
}

//------------------------------------------------------------------------
// Extract and return the discrete Y, Cr, Cb components of the given NUON
// color.
//------------------------------------------------------------------------
void mmlGetYCCComponents( mmlColor color, uint8* yP, uint8* crP, uint8* cbP )
{
    *yP  = (color >> 24) & 0xFF;
    *crP = (color & 0xFF0000 ) >> 16;
    *cbP = (color & 0xFF00) >> 8;
}

//------------------------------------------------------------------------
// Increase (percent > 0) or decrease (percent < 0) the luma of the given
// color by the given percentage.  The resulting luma is bounded to the
// valid range [0,255].  The resulting color is then made safe.
//------------------------------------------------------------------------
mmlColor lightenColor ( mmlColor color, int percent )
{
    int luma = (color >> 24) & 0xFF;
    int diff = (luma * percent) / 100;
    luma += diff;
    if( luma > 0xFF ) luma = 0xFF;
    if( luma < 0 ) luma = 0;
    return mmlSafeColor((color & 0xFFFFFF) | (luma << 24));
}

#if defined(USEOLDFINDSAFECOLOR)

//------------------------------------------------------------------------
// Analyze the given NUON color using the specified color limits and
// return a safe-color.  If the color violates the limits and would
// produce an unacceptable supersaturated color, then the chroma components
// are reduced by the smallest value that results in an acceptable color.
// In all cases, the luma and chroma values are clamped to legal ITU-R
// BT.601 values.
//------------------------------------------------------------------------
static mmlColor __findSafeColor( mmlColor color, colorLimits *limits )
{
    int yk, crk, cbk;
    fDotFBITS Y, Cr, Cb;
    fDotFBITS scale, Csq, R;
    fDotFBITS temp1, temp2;
    static fDotFBITS fac1 = FixFBITS(0.886*0.492/0.5);  // about 0.872
    static fDotFBITS fac2 = FixFBITS(0.701*0.877/0.5);  // about 1.230
    static fDotFBITS fac3 = FixFBITS(1.0/219.0);
    static fDotFBITS fac4 = FixFBITS(1.0/224.0);

    // Extract the luma and chroma components from the given color.
    // They are expected to be in the appropriate ITU-R BT.601 range:
    //     16 <= yk <= 235
    //     16 <= crk,cbk <= 240
    // The components are then scaled to their canonical forms:
    //    0.0 <= Y <= 1.0
    //   -0.5 <= Cr,Cb <= 0.5
    // If the originals do not satisfy the BT.601 requirements, then
    // there will be some luma or chroma distortion as the components are
    // clamped to their valid extrema.
    yk  = ((color >> 24) & 0xff);
    crk = ((color >> 16) & 0xff);
    cbk = ((color >> 8) & 0xff);

    Y = FixMul((yk - 16)<<FBITS, fac3, FBITS);
    Y = (Y < 0) ? 0 : (Y > (1<<FBITS)) ? (1<<FBITS) : Y;
    temp1 = 1<<(FBITS-1);       // one-half
    temp2 = -temp1;             // minus one-half
    Cr = FixMul((crk - 128)<<FBITS, fac4, FBITS);
    Cr = (Cr < temp2) ? temp2 : (Cr > temp1) ? temp1 : Cr;
    Cb = FixMul((cbk - 128)<<FBITS, fac4, FBITS);
    Cb = (Cb < temp2) ? temp2 : (Cb > temp1) ? temp1 : Cb;

    // Compute square of chroma to use during tests:
    //   C**2 = U**2 + V**2
    //        = (0.872 * Cb)**2 + (1.230 * Cr)**2
    temp1 = FixMul(fac1, Cb, FBITS);
    temp1 = FixMul(temp1, temp1, FBITS);
    temp2 = FixMul(fac2, Cr, FBITS);
    temp2 = FixMul(temp2, temp2, FBITS);
    Csq = temp1 + temp2;

    R = _min(abs(limits->rmax - Y), abs(limits->rmin - Y));
    R = _min(R, abs(limits->chmax));

    if (Csq > FixMul(R, R, FBITS)) {
        temp1 = FixRSqrt(Csq, FBITS, FBITS);
        scale = FixMul(temp1, R, FBITS);
        Cr = FixMul(Cr, scale, FBITS);
        Cb = FixMul(Cb, scale, FBITS);
    }

    // Integerize the adjusted chroma components and insert them into
    // the original color (preserve original luma and control bytes).
    // Note: 257<<(FBITS-1) is Fixed Point 128.5, where the .5 is for rounding.
    temp1 = FixMul(Cr, (224<<FBITS), FBITS) + (257<<(FBITS-1));
    temp2 = FixMul(Cb, (224<<FBITS), FBITS) + (257<<(FBITS-1));
    crk = temp1 >> FBITS;
    cbk = temp2 >> FBITS;

    return makeColor(yk,crk,cbk,(color & 0xff));
}
#endif // defined(FASTFINDSAFECOLOR)

//------------------------------------------------------------------------
// Sets custom color limits and computes supplemental relative quantities
// used in __findSafeColor().  The arguments are all 16.16-bit fixed-point
// numbers, and all have been validated to lie within acceptable ranges.
//------------------------------------------------------------------------
void __SetSafeColorLimits( f16Dot16 ped, f16Dot16 smax, f16Dot16 smin, f16Dot16 cmax )
{
    f16Dot16 range = Fix16(100.0) - ped;
    
    presetLimits[eSafeColorCustom].ped  = ped;
    presetLimits[eSafeColorCustom].smax = smax;
    presetLimits[eSafeColorCustom].smin = smin;
    presetLimits[eSafeColorCustom].cmax = cmax;

    // Compute and save derived relative quantities
    presetLimits[eSafeColorCustom].rmax = FixDiv(smax - ped, range, 16);
    presetLimits[eSafeColorCustom].rmin = FixDiv(smin - ped, range, 16);
    presetLimits[eSafeColorCustom].chmax = FixDiv(cmax, range, 16);
}
