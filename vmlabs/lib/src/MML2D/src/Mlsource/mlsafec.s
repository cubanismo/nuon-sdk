
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

//------------------------------------------------------------------------
// File Name:   mlsafec.s
//
// Version:     1.0.001
//
// Contents:    Assembly-language implementation of
//
//              mmlColor __findSafeColor(mmlColor color, colorLimits *limits);
//
//              where mmlColor is a 32-bit Type 4 pixel, and limits points
//              points to a vector-aligned array of three scalars in FBITS
//              fixed-point format.
//
// Notes:       SECOND PASS: OPTIMIZATIONS under way (mostly just
//              packetizing so far); additional cycles can be harvested by:
//              (1) reusing registers more cleverly, saving one or more
//                  vector pushes onto the C stack (cause of cache misses!)
//              (2) inlining the RSqrt routine, and using the single
//                  iteration, 16-bit accurate version which is probably
//                  adequate for this application.
//
// Build 001 (12 Jan 2001, mh) Original version from C subroutine in
//           libraries/MML2D/src/mlsource/mlcolor.c.
//       002 (25 May 2001, rws) Annotated version.  Changed file name
//           and name of function to allow replacement of existing
//           C-language version.
//------------------------------------------------------------------------
//------------------------------------------------------------------------        
// Constant defintions
//------------------------------------------------------------------------        
FBITS       = 20
Bfac        = fix(0.872, FBITS)         ; Cb weight to compute chroma C
Rfac        = fix(1.230, FBITS)         ; Cr weight to compute chroma C
Lfac        = fix(1.0/219.0, FBITS)     ; luma range scale factor
Cfac        = fix(1.0/224.0, FBITS)     ; chroma range scale factor
OneHalf     = fix(0.5, FBITS)
MinusHalf   = -OneHalf
//------------------------------------------------------------------------        
// Register usage
//------------------------------------------------------------------------        
color       = r0        ; input mmlColor
limits      = r1        ; pointer to controlling color limit values
struct      = v1        ; copy of controlling color limit values
rmax        = v1[0]     ; aliases
rmin        = v1[1]
chmax       = v1[2]
yk          = r8        ; luma Y value with FBITS binary fraction precision
crk         = r9        ; chroma Cr value with FBITS binary fraction precision
cbk         = r10       ; chroma Cb value with FBITS binary fraction precision
tmp1        = r11
tmp2        = r12
scale       = r13
Y           = r14
Cr          = r15
Cb          = r16
LFAC        = r17
CFAC        = r18
BFAC        = r19
RFAC        = r20
Csq         = r21       ; computed chroma (or its square)
R           = r22       ; MUST be even register!
next        = r23       ; MUST be successor to R

//------------------------------------------------------------------------
// The color limits (pointed to by r1) are in a vector-aligned structure.
// Only three scalars are required here:
// [0] rmax, relative maximum for composite video signal Y+C
// [1] rmin, relative minimum for composite video signal Y+C
// [2] chmax, relative max chroma span for composite video signal Y+C
// All three values are expressed as fixed-point with FBITS bits of
// fraction.
//------------------------------------------------------------------------
        .text
        .cache
        .export ___findSafeColor
___findSafeColor:
        ; Gain access to r12..r31 using C stack
        sub     #16,r31
{       st_v    v3,(r31)
        sub     #16,r31
}
{       st_v    v4,(r31)
        sub     #16,r31
}
        st_v    v5,(r31)

        ;----------------------------------------------------------------
        ; Extract the luma and chroma components from the given color.
        ; They are expected to be in the appropriate ITU-R BT.601 range:
        ;     16 <= yk <= 235
        ;     16 <= crk,cbk <= 240
        ; The components are then scaled to their canonical forms:
        ;    0.0 <= Y <= 1.0
        ;   -0.5 <= Cr,Cb <= 0.5
        ; If the originals do not satisfy the BT.601 requirements, then
        ; there will be some luma or chroma distortion as the components are
        ; clamped to their valid extrema.
        ;
        ; Set up constants needed for conversion as well:
        ; YFAC, LFAC, CFAC
        ;
        ; Code from C version of function:
        ;   yk  = ((color >> 24) & 0xff);
        ;   crk = ((color >> 16) & 0xff);
        ;   cbk = ((color >> 8) & 0xff);
        ;   Y = FixMul((yk - 16)<<FBITS, fac3, FBITS);
        ;   Y = (Y < 0) ? 0 : (Y > (1<<FBITS)) ? (1<<FBITS) : Y;
        ;   temp1 = 1<<(FBITS-1);       // one-half
        ;   temp2 = -temp1;             // minus one-half
        ;   Cr = FixMul((crk - 128)<<FBITS, fac4, FBITS);
        ;   Cr = (Cr < temp2) ? temp2 : (Cr > temp1) ? temp1 : Cr;
        ;   Cb = FixMul((cbk - 128)<<FBITS, fac4, FBITS);
        ;   Cb = (Cb < temp2) ? temp2 : (Cb > temp1) ? temp1 : Cb;
        ;----------------------------------------------------------------
{       mv_s    color,yk
        copy    color,crk
}
{       bits    #7,>>#24,yk
        mv_s    color,cbk
}
{       bits    #7,>>#16,crk
        ld_v    (limits),struct         ; Pick up color limits
}        
        bits    #7,>>#8,cbk
{
        bits    #7,>>#0,color
        mv_s    #Lfac,LFAC
}
        ; Compute Y, Cr, and Cb
{       mv_s    #Cfac,CFAC
        sub     #16,yk,Y                ; Y = yk - 16
}
        mul     LFAC,Y,>>#0,Y           ; Y *= LFAC, now in FBITS
        sub     #128,crk,Cr             ; Cr = crk - 128
{       mul     CFAC,Cr,>>#0,Cr
        sub     #OneHalf,Y              ; prepare to bound
}
{       sat     #FBITS,Y                ; Y between - and + 0.5
        mv_s    #Bfac,BFAC
}
        add     #OneHalf,Y              ; Y between 0 and 1.0
{       mv_s    #Rfac,RFAC
        sat     #FBITS,Cr
}
        sub     #128,cbk,Cb             ; Cb = cbk - 128
        mul     CFAC,Cb,>>#0,Cb
        nop
        sat     #FBITS,Cb

        ;----------------------------------------------------------------
        ; Compute square of chroma to use during tests:
        ;   C**2 = U**2 + V**2
        ;        = (0.872 * Cb)**2 + (1.230 * Cr)**2
        ;
        ; Code from C version of function:
        ;  temp1 = FixMul(fac1, Cb, FBITS);
        ;  temp1 = FixMul(temp1, temp1, FBITS);
        ;  temp2 = FixMul(fac2, Cr, FBITS);
        ;  temp2 = FixMul(temp2, temp2, FBITS);
        ;  Csq = temp1 + temp2;
        ;----------------------------------------------------------------
        copy    Cb,tmp1
{       mul     BFAC,tmp1,>>#FBITS,tmp1
        sub    Y,rmin  ; rmin -= Y
}
        sub     Y,rmax  ; rmax -= Y
{       mul     tmp1,tmp1,>>#FBITS,tmp1
        abs     rmax
        mv_s    Cr,tmp2
}
        mul     RFAC,tmp2,>>#FBITS,tmp2
        abs     rmin
{       mul     tmp2,tmp2,>>#FBITS,tmp2
        abs     chmax
}
        butt    rmax,rmin,R             ; R = a+b, next = b-a
{       add     tmp1,tmp2,Csq
        mul     #1,R,>>#1,R             ; R = (a+b)/2
}
        abs     next                    ; next = |b-a|
        sub     next,>>#1,R             ; R = min{a,b}

        butt    R,chmax,R               ; repeat to find min{R,|chmax|}
        mul     #1,R,>>#1,R    
        abs     next           
        sub     next,>>#1,R    

        ;----------------------------------------------------------------
        ; Now square R for comparison with Csq:
        ;  R = _min(abs(limits->rmax - Y), abs(limits->rmin - Y));
        ;  R = _min(R, abs(limits->chmax));
        ;----------------------------------------------------------------
        copy    R,tmp1
        mul     tmp1,tmp1,>>#FBITS,tmp1  ; tmp1 = R^2
        nop
       
        ;----------------------------------------------------------------
        ; Here we compute and apply scale factor.  This involves saving
        ; registers and calling RSqrt().
        ;  if (Csq > FixMul(R, R, FBITS)) {
        ;      temp1 = FixRSqrt(Csq, FBITS, FBITS);
        ;      scale = FixMul(temp1, R, FBITS);
        ;      Cr = FixMul(Cr, scale, FBITS);
        ;      Cb = FixMul(Cb, scale, FBITS);
        ;  }
        ; For quick testing, we use the C-callable version from MUTILs.
        ;----------------------------------------------------------------
        cmp     tmp1,Csq                ; compare Csq to R^2
        bra     le,skip                 ; no scale factors applied here
        mv_s    #fix(224,FBITS),tmp1    ; [Delay]
        lsl     #24,yk                  ; [Delay]

        push    v0
        push    v1
        push    v2,rz
{       jsr     _FixRSqrt
        mv_s    Csq,r0
}
        mv_s    #FBITS,r1               ; [Delay]
        mv_s    #FBITS,r2               ; [Delay]

{       pop     v2,rz
        copy    r0,scale
}
{       pop     v1
        mul     R,scale,>>#FBITS,scale  ; scale = sqrt(R^2/Csq)
}
        pop     v0
        mul     scale,Cr,>>#FBITS,Cr
        mul     scale,Cb,>>#FBITS,Cb

skip:
        ;----------------------------------------------------------------
        ; Integerize the adjusted chroma components and insert them into
        ; the original color (preserve original luma and control bytes).
        ; Note: 257<<(FBITS-1) is Fixed Point 128.5, where the .5 is for
        ; rounding.
        ;  temp1 = FixMul(Cr, (224<<FBITS), FBITS) + (257<<(FBITS-1));
        ;  temp2 = FixMul(Cb, (224<<FBITS), FBITS) + (257<<(FBITS-1));
        ;  crk = temp1 >> FBITS;
        ;  cbk = temp2 >> FBITS;
        ;
        ; Repack the color with modified components
        ;  return makeColor(yk,crk,cbk,(color & 0xff));
        ;----------------------------------------------------------------
        mul     tmp1,Cr,>>#FBITS,Cr
        mul     tmp1,Cb,>>#FBITS,Cb
        add     #fix(128.5,FBITS),Cr
{       add     #fix(128.5,FBITS),Cb
        mv_s    Cr,crk
}
{       mv_s    Cb,cbk
        bits    #7,>>#FBITS,crk
}
{       bits    #7,>>#FBITS,cbk
        addm    yk,color
}
        lsl     #16,crk
{       lsl     #8,cbk
        addm    crk,color
}
        add     cbk,color

        ; Wash up and go home
{       ld_v    (r31),v5
        add     #16,r31
}
{       ld_v    (r31),v4
        add     #16,r31
        rts
}
{       ld_v    (r31),v3
        add     #16,r31
}
        nop
