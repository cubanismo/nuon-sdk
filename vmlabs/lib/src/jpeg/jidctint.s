/*
 * Copyright (C) 2001 VM Labs, Inc.
 *
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

;;----------------------------------------------
;;
;; MPE assembly code implementation of inverse DCT for JPEG.
;; This is intended to be read in conjunction with the C source.
;;
;; We try to keep the C code as comments inside the machine stuff.
;;
;;----------------------------------------------




;;#define JPEG_INTERNALS
;;#include "jinclude.h"
;;#include "jpeglib.h"
;;#include "jdct.h"		/* Private declarations for DCT subsystem */
;;
;;#ifdef DCT_ISLOW_SUPPORTED
;;
;;
;;#if BITS_IN_JSAMPLE == 8
;;#define CONST_BITS  13
;;#define PASS1_BITS  2
;;#else
;;#define CONST_BITS  13
;;#define PASS1_BITS  1		/* lose a little precision to avoid overflow */
;;#endif
;;
;;
;;#if CONST_BITS == 13
;;#define FIX_0_298631336  ((INT32)  2446)	/* FIX(0.298631336) */
;;#define FIX_0_390180644  ((INT32)  3196)	/* FIX(0.390180644) */
;;#define FIX_0_541196100  ((INT32)  4433)	/* FIX(0.541196100) */
;;#define FIX_0_765366865  ((INT32)  6270)	/* FIX(0.765366865) */
;;#define FIX_0_899976223  ((INT32)  7373)	/* FIX(0.899976223) */
;;#define FIX_1_175875602  ((INT32)  9633)	/* FIX(1.175875602) */
;;#define FIX_1_501321110  ((INT32)  12299)	/* FIX(1.501321110) */
;;#define FIX_1_847759065  ((INT32)  15137)	/* FIX(1.847759065) */
;;#define FIX_1_961570560  ((INT32)  16069)	/* FIX(1.961570560) */
;;#define FIX_2_053119869  ((INT32)  16819)	/* FIX(2.053119869) */
;;#define FIX_2_562915447  ((INT32)  20995)	/* FIX(2.562915447) */
;;#define FIX_3_072711026  ((INT32)  25172)	/* FIX(3.072711026) */
;;#else
;;#define FIX_0_298631336  FIX(0.298631336)
;;#define FIX_0_390180644  FIX(0.390180644)
;;#define FIX_0_541196100  FIX(0.541196100)
;;#define FIX_0_765366865  FIX(0.765366865)
;;#define FIX_0_899976223  FIX(0.899976223)
;;#define FIX_1_175875602  FIX(1.175875602)
;;#define FIX_1_501321110  FIX(1.501321110)
;;#define FIX_1_847759065  FIX(1.847759065)
;;#define FIX_1_961570560  FIX(1.961570560)
;;#define FIX_2_053119869  FIX(2.053119869)
;;#define FIX_2_562915447  FIX(2.562915447)
;;#define FIX_3_072711026  FIX(3.072711026)
;;#endif



;; we use 3.13

FIX_0_298631336 = fix(0.298631336, 13)
FIX_0_390180644 = fix(0.390180644, 13)
FIX_0_541196100 = fix(0.541196100, 13)
FIX_0_765366865 = fix(0.765366865, 13)
FIX_0_899976223 = fix(0.899976223, 13)
FIX_1_175875602 = fix(1.175875602, 13)
FIX_1_501321110 = fix(1.501321110, 13)
FIX_1_847759065 = fix(1.847759065, 13)
FIX_1_961570560 = fix(1.961570560, 13)
FIX_2_053119869 = fix(2.053119869, 13)
FIX_2_562915447 = fix(2.562915447, 13)
FIX_3_072711026 = fix(3.072711026, 13)



DCTSIZE = 8


    .cache
    .segment    data
    .align.v
workspace:      .ds.s   DCTSIZE*DCTSIZE

    ;; precalculated output buffer pointer list normally indexed by
    ;;    outptr = output_buf[ctr] + output_col;
    ;; in the C source.
    .align.v
OutPtrBuffer:   .ds.s   DCTSIZE

;;    ;; set up the DCT constants in the order they're encountered in the code
;;    .align.v
;;DCTConstants:   .dc.s   FIX_0_541196100
;;                .dc.s  -FIX_1_847759065
;;                .dc.s   FIX_0_765366865
;;                .dc.s   FIX_1_175875602
;;                .dc.s   FIX_0_298631336
;;                .dc.s   FIX_2_053119869
;;                .dc.s   FIX_3_072711026
;;                .dc.s   FIX_1_501321110
;;                .dc.s  -FIX_0_899976223
;;                .dc.s  -FIX_2_562915447
;;                .dc.s  -FIX_1_961570560
;;                .dc.s  -FIX_0_390180644

;; #define DEQUANTIZE(coef,quantval)  (((ISLOW_MULT_TYPE) (coef)) * (quantval))


QUANT_STEP = 4      ;; element to element
QUANT_JUMP = 32     ;; column to column

QSHIFT     = 16
DSHIFT     = 13
SAMPLE_SAT =  8     ;; number of bits we allow for a sample


;; xyctl and uvctl control types for linear addressing, used by C source.
TYPEBYTE   = $8<<20
TYPESHORT  = $9<<20
TYPELONG   = $A<<20

;;NO_ROW_ZERO_PROCESS = 1

;;GLOBAL(void)
;;jpeg_idct_islow (j_decompress_ptr cinfo, jpeg_component_info * compptr,
;;		 JCOEFPTR coef_block,
;;		 JSAMPARRAY output_buf, JDIMENSION output_col)
;;{
;;  INT32 tmp0, tmp1, tmp2, tmp3;
;;  INT32 tmp10, tmp11, tmp12, tmp13;
;;  INT32 z1, z2, z3, z4, z5;
;;  JCOEFPTR inptr;
;;  ISLOW_MULT_TYPE * quantptr;
;;  int * wsptr;
;;  JSAMPROW outptr;
;;  JSAMPLE *range_limit = IDCT_range_limit(cinfo);
;;  int ctr;
;;  int workspace[DCTSIZE2];	/* buffers data between passes */
;;  SHIFT_TEMPS


;; tmp0 - tmp3, tmp10 - tmp13, and z1 - z5 live in data registers.
;; inptr, wsptr, and outptr live in pointers rx/ry, ru/rv, and rx/ry
;; repectively.  inptr and outptr can use the same pointers since 
;; they are never used at the same time.  


;; scratch vars with nomenclature taken straight from the C source
z1 = r0
z2 = r1
z3 = r2
z4 = r3
z5 = r4
;; followed by extra scratch vars with names following the C style
X6 = r5
X7 = r6
X8 = r7


;; more C source style scratch vars.  These are overlaid onto the
;; same registers we use for the dequantisation factors, since the
;; dequant is done by the time we get to the code using these.

qt0 = r12
qt1 = r13
qt2 = r14
qt3 = r15
qt4 = r16
qt5 = r17
qt6 = r18
qt7 = r19

tmp0  = r12
tmp1  = r13
tmp2  = r14
tmp3  = r15
tmp10 = r16
tmp13 = r17
tmp11 = r18
tmp12 = r19


;; overlaid input and output registers.

in0 = r20
in1 = r21
in2 = r22
in3 = r23
in4 = r24
in5 = r25
in6 = r26
in7 = r27

out0 = r20
out7 = r21
out1 = r22
out6 = r23
out2 = r24
out5 = r25
out3 = r26
out4 = r27


;; overlaid work vectors 
PtrVector0 = v5
PtrVector1 = v6
InVector0  = v5
InVector1  = v6
OutVector0 = v5
OutVector1 = v6


QuantPtr     = r28
OutPtrList   = r28
DCT_ConstPtr = r29

;;  /* Pass 1: process columns from input, store into work array. */
;;  /* Note results are scaled up by sqrt(8) compared to a true IDCT; */
;;  /* furthermore, we scale the results by 2**PASS1_BITS. */
;;
;;
;;  inptr = coef_block;
;;  quantptr = (ISLOW_MULT_TYPE *) compptr->dct_table;
;;  wsptr = workspace;


	.text
	.alignlog 1
	.export _jpeg_idct_islow

_jpeg_idct_islow:
    	ld_s    rz,r29
	    sub     #16,r31
        {
    	st_v    v7,(r31)
	    sub     #16,r31
        }
        {
    	st_v    v6,(r31)
	    sub     #16,r31
        }
        {
    	st_v    v5,(r31)
	    sub     #16,r31
        }
        {
    	st_v    v4,(r31)
	    sub     #16,r31
        }
    	st_v    v3,(r31)
        ;; save the registers we blow away during processing.


;; C source with -O2 uses 3.57 seconds.
;; 1.35 seconds if we return here.
;; 2.6  seconds if we return here after a __synccache on every entry.
;; 2.21 seconds for 8 columns / 8 rows, with all memory except output
;; 2.48 seconds for 8 columns / 8 rows, with all memory including output

        ;; blow off r0 (cinfo), only used for range limit table
        ;; we have a better idea using the sat opcode.


        ;; We know dct_table is 80 bytes from the beginning of compptr,
        ;; but we should really figure out a better way than hard coding 
        ;; the offset into the structure.

        add     r1,#80,tmp0
        ld_s    (tmp0),QuantPtr         ;; quantptr = compptr->dct_table
        nop                             ;; cache bug

        st_s    #0,rx
        st_s    r2,xybase               ;; inptr = coef_block
        st_s    #TYPESHORT,xyctl        ;; we address 16 bit data

        st_s    #0,ru
        st_s    #workspace,uvbase       ;; local stuff
        st_s    #TYPELONG,uvctl         ;; so we can afford scalars.


        ;; precalculate the output buffer pointer list normally indexed by
        ;;    outptr = output_buf[ctr] + output_col;
        ;; in the C source.  MUST be done before setting up QuantPtr
        ;; because quantisation uses the same registers.

        ;; make vector list of addresses here.
        ;; we assume the pixel block addresses live on scalar boundaries.
        mv_s    #OutPtrBuffer,tmp2
        {
        mv_s    r3,tmp0                 ;; tmp0 = output_buf
        copy    r4,tmp1                 ;; tmp1 = output_col
        }
        {
        ld_s    (tmp0),PtrVector0[0]    ;; fetch output_buf[0]
        add     #4,tmp0
        }
        {
        ld_s    (tmp0),PtrVector0[1]
        add     #4,tmp0
        }
        {
        ld_s    (tmp0),PtrVector0[2]
        addm    tmp1,PtrVector0[0]      ;; output_buf[0] + output_col
        add     #4,tmp0
        }
        {
        ld_s    (tmp0),PtrVector0[3]
        addm    tmp1,PtrVector0[1]
        add     #4,tmp0
        }
        {
        ld_s    (tmp0),PtrVector1[0]
        addm    tmp1,PtrVector0[2]
        add     #4,tmp0
        }
        {
        ld_s    (tmp0),PtrVector1[1]
        addm    tmp1,PtrVector0[3]
        add     #4,tmp0
        }
        {
        ld_s    (tmp0),PtrVector1[2]
        addm    tmp1,PtrVector1[0]
        add     #4,tmp0
        }
        {
        ld_s    (tmp0),PtrVector1[3]
        addm    tmp1,PtrVector1[1]
        }
        {
        st_v    PtrVector0,(tmp2)       ;; store first four output addresses
        addm    tmp1,PtrVector1[2]
        add     #16,tmp2
        }
        addm    tmp1,PtrVector1[3]
        st_v    PtrVector1,(tmp2)       ;; store last four output addresses



;;  for (ctr = DCTSIZE; ctr > 0; ctr--) {
;;    /* Due to quantization, we will usually find that many of the input
;;     * coefficients are zero, especially the AC terms.  We can exploit this
;;     * by short-circuiting the IDCT calculation for any column in which all
;;     * the AC terms are zero.  In that case each output is equal to the
;;     * DC coefficient (with scale factor as needed).
;;     * With typical images and quantization tables, half or more of the
;;     * column DCT calculations can be simplified this way.
;;     */
;;    
;;      if ((inptr[DCTSIZE*1] | inptr[DCTSIZE*2] | inptr[DCTSIZE*3] |
;;	            inptr[DCTSIZE*4] | inptr[DCTSIZE*5] | inptr[DCTSIZE*6] |
;;	            inptr[DCTSIZE*7]) == 0) {
;;      /* AC terms all zero */
;;      int dcval = DEQUANTIZE(inptr[DCTSIZE*0], quantptr[DCTSIZE*0]) << PASS1_BITS;
;;      
;;      wsptr[DCTSIZE*0] = dcval;
;;      wsptr[DCTSIZE*1] = dcval;
;;      wsptr[DCTSIZE*2] = dcval;
;;      wsptr[DCTSIZE*3] = dcval;
;;      wsptr[DCTSIZE*4] = dcval;
;;      wsptr[DCTSIZE*5] = dcval;
;;      wsptr[DCTSIZE*6] = dcval;
;;      wsptr[DCTSIZE*7] = dcval;
;;      
;;      inptr++;			/* advance pointers to next column */
;;      quantptr++;
;;      wsptr++;
;;      continue;
;;    }



;;-----------------------------------
;;
;; NOTE: we could probably change JCOEF to int instead of short
;; and get much more speed from the huffman decoding at the expense 
;; of more memory usage.
;;
;;-----------------------------------


        st_s    #DCTSIZE,rc0

ColumnProcess:
        ;; the column AC null test doesn't cost us much 
        ;; since we have to load the input data anyway
        {
        ld_w    (xy),in0                ;; Get DC term
        addr    #(DCTSIZE<<16),rx       ;; bump inptr to DCTSIZE * 1
        dec     rc0                     ;; dec loop counter
        }
        {
        ld_w    (xy),in1                ;; Get first AC term
        addr    #(DCTSIZE<<16),rx       ;; bump inptr to DCTSIZE * 2
        }
        {
        ld_w    (xy),in2                ;; Get second AC term
        addr    #(DCTSIZE<<16),rx       ;; bump inptr to DCTSIZE * 3
        }
        {
        ld_w    (xy),in3                ;; Get third AC term
        copy    in1,z1                  ;; copy first AC term to zero check 
        addr    #(DCTSIZE<<16),rx       ;; bump inptr to DCTSIZE * 4
        }
        {
        ld_w    (xy),in4                ;; Get fourth AC term
        or      in2,z1                  ;; or together for zero check
        addr    #(DCTSIZE<<16),rx       ;; bump inptr to DCTSIZE * 5
        }
        {
        ld_w    (xy),in5                ;; Get fifth AC term
        or      in3,z1                  ;; or together for zero check
        addr    #(DCTSIZE<<16),rx       ;; bump inptr to DCTSIZE * 6
        }
        {
        ld_w    (xy),in6                ;; Get sixth AC term
        or      in4,z1                  ;; or together for zero check
        addr    #(DCTSIZE<<16),rx       ;; bump inptr to DCTSIZE * 7
        }
        {
        ld_w    (xy),in7                ;; Get seventh AC term
        or      in5,z1                  ;; or together for zero check
        addr    #((1-(DCTSIZE*7))<<16),rx ;; inptr++ shared between shortcut
                                        ;; and full process modes since we
                                        ;; already have input data in in0-in7
        }
        {
        ld_s    (QuantPtr),qt0          ;; get DC quant value
        or      in6,z1                  ;; or together for zero check
        }

        or      in7,z1                  ;; or all the AC values together
        ;; this z1 is a throwaway value only used to set up the zero flag
        ;; to see if we can skip the processing ofr this row.

        {
        bra     ne,NotZeroColumn,nop    ;; some non-zero AC terms exist if ne
        add     #QUANT_JUMP,QuantPtr    ;; point to DCTSIZE * 1
        }
        mul     qt0,in0,>>#(QSHIFT-2),in0 ;; generate DC value
        add     #QUANT_STEP-QUANT_JUMP,QuantPtr  ;; pull back to quant++
        {
        st_s    in0,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 1
        }
        {
        st_s    in0,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 2
        }
        {
        st_s    in0,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 3
        }
        {
        st_s    in0,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 4
        }
        {
        st_s    in0,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 5
        }
        {
        bra     c0ne,ColumnProcess      ;; Continue if we need to crunch data
        st_s    in0,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 6
        }
        {
        bra     StartRowProcess         ;; no more columns, so rows are next
        st_s    in0,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 7
        }
        {
        st_s    in0,(uv)
        addr    #((1-(DCTSIZE*7))<<16),ru ;; bump back to wsptr++
        }
        nop     ;; delay slot 2 of bra StartRowProcess

NotZeroColumn:
        ;; we're gonna reorder this stuff some.  We have to dequantize 
        ;; the input coefficients anyway, so we'd might as well do this
        ;; all at once so we don't have to muck about with too many pointers.
        {
        ld_s    (QuantPtr),qt1          ;; get AC 1 quant value
        add     #QUANT_JUMP,QuantPtr 
        }
        {
        ld_s    (QuantPtr),qt2          ;; get AC 2 quant value
        mul     qt0,in0,>>#QSHIFT,in0   ;; generate DC value
        add     #QUANT_JUMP,QuantPtr 
        }
        {
        ld_s    (QuantPtr),qt3          ;; get AC 3 quant value
        mul     qt1,in1,>>#QSHIFT,in1   ;; make dequantized AC 1
        add     #QUANT_JUMP,QuantPtr 
        }
        {
        ld_s    (QuantPtr),qt4          ;; get AC 4 quant value
        mul     qt2,in2,>>#QSHIFT,in2   ;; make dequantized AC 2
        add     #QUANT_JUMP,QuantPtr 
        }
        {
        ld_s    (QuantPtr),qt5          ;; get AC 5 quant value
        mul     qt3,in3,>>#QSHIFT,in3   ;; make dequantized AC 3
        add     #QUANT_JUMP,QuantPtr 
        }
        {
        ld_s    (QuantPtr),qt6          ;; get AC 6 quant value
        mul     qt4,in4,>>#QSHIFT,in4   ;; make dequantized AC 4
        add     #QUANT_JUMP,QuantPtr 
        }
        {
        ld_s    (QuantPtr),qt7          ;; get AC 7 quant value
        mul     qt5,in5,>>#QSHIFT,in5   ;; make dequantized AC 5
        add     #QUANT_STEP-(QUANT_JUMP*7),QuantPtr   ;; pull back to quant++
        }
        {
        jsr     DCT_Core
        mul     qt6,in6,>>#QSHIFT,in6   ;; make dequantized AC 6
        }
        mul     qt7,in7,>>#QSHIFT,in7   ;; make dequantized AC 7, delay slot 1
        nop                             ;; first DCT_Core instruction is addm

        ;; stash the outputs.  Note the intermediate buffer 
        ;; is scalars instead of shorts, much faster.
        {
        st_s    out0,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 1
        }
        {
        st_s    out1,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 2
        }
        {
        st_s    out2,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 3
        }
        {
        st_s    out3,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 4
        }
        {
        st_s    out4,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 5
        }
        {
        bra     c0ne,ColumnProcess      ;; Continue if we need to crunch data
        st_s    out5,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 6
        }
        {
        st_s    out6,(uv)
        addr    #(DCTSIZE<<16),ru       ;; bump wsptr to DCTSIZE * 7
        }
        {
        st_s    out7,(uv)
        addr    #((1-(DCTSIZE*7))<<16),ru ;; bump back to wsptr++
        }


;;    /* Even part: reverse the even part of the forward DCT. */
;;    /* The rotator is sqrt(2)*c(-6). */
;;    
;;    z2 = DEQUANTIZE(inptr[DCTSIZE*2], quantptr[DCTSIZE*2]);
;;    z3 = DEQUANTIZE(inptr[DCTSIZE*6], quantptr[DCTSIZE*6]);
;;    
;;    z1 = MULTIPLY(z2 + z3, FIX_0_541196100);
;;    tmp2 = z1 + MULTIPLY(z3, - FIX_1_847759065);
;;    tmp3 = z1 + MULTIPLY(z2, FIX_0_765366865);
;;    
;;    z2 = DEQUANTIZE(inptr[DCTSIZE*0], quantptr[DCTSIZE*0]);
;;    z3 = DEQUANTIZE(inptr[DCTSIZE*4], quantptr[DCTSIZE*4]);
;;
;;    tmp0 = (z2 + z3) << CONST_BITS;
;;    tmp1 = (z2 - z3) << CONST_BITS;
;;    
;;    tmp10 = tmp0 + tmp3;
;;    tmp13 = tmp0 - tmp3;
;;    tmp11 = tmp1 + tmp2;
;;    tmp12 = tmp1 - tmp2;
;;    
;;    /* Odd part per figure 8; the matrix is unitary and hence its
;;     * transpose is its inverse.  i0..i3 are y7,y5,y3,y1 respectively.
;;     */
;;    
;;    tmp0 = DEQUANTIZE(inptr[DCTSIZE*7], quantptr[DCTSIZE*7]);
;;    tmp1 = DEQUANTIZE(inptr[DCTSIZE*5], quantptr[DCTSIZE*5]);
;;    tmp2 = DEQUANTIZE(inptr[DCTSIZE*3], quantptr[DCTSIZE*3]);
;;    tmp3 = DEQUANTIZE(inptr[DCTSIZE*1], quantptr[DCTSIZE*1]);
;;    
;;    z1 = tmp0 + tmp3;
;;    z2 = tmp1 + tmp2;
;;    z3 = tmp0 + tmp2;
;;    z4 = tmp1 + tmp3;
;;    z5 = MULTIPLY(z3 + z4, FIX_1_175875602); /* sqrt(2) * c3 */
;;    
;;    tmp0 = MULTIPLY(tmp0, FIX_0_298631336); /* sqrt(2) * (-c1+c3+c5-c7) */
;;    tmp1 = MULTIPLY(tmp1, FIX_2_053119869); /* sqrt(2) * ( c1+c3-c5+c7) */
;;    tmp2 = MULTIPLY(tmp2, FIX_3_072711026); /* sqrt(2) * ( c1+c3+c5-c7) */
;;    tmp3 = MULTIPLY(tmp3, FIX_1_501321110); /* sqrt(2) * ( c1+c3-c5-c7) */
;;    z1 = MULTIPLY(z1, - FIX_0_899976223); /* sqrt(2) * (c7-c3) */
;;    z2 = MULTIPLY(z2, - FIX_2_562915447); /* sqrt(2) * (-c1-c3) */
;;    z3 = MULTIPLY(z3, - FIX_1_961570560); /* sqrt(2) * (-c3-c5) */
;;    z4 = MULTIPLY(z4, - FIX_0_390180644); /* sqrt(2) * (c5-c3) */
;;    
;;    z3 += z5;
;;    z4 += z5;
;;    
;;    tmp0 += z1 + z3;
;;    tmp1 += z2 + z4;
;;    tmp2 += z2 + z3;
;;    tmp3 += z1 + z4;
;;    
;;    /* Final output stage: inputs are tmp10..tmp13, tmp0..tmp3 */
;;    
;;    wsptr[DCTSIZE*0] = (int) DESCALE(tmp10 + tmp3, CONST_BITS-PASS1_BITS);
;;    wsptr[DCTSIZE*7] = (int) DESCALE(tmp10 - tmp3, CONST_BITS-PASS1_BITS);
;;    wsptr[DCTSIZE*1] = (int) DESCALE(tmp11 + tmp2, CONST_BITS-PASS1_BITS);
;;    wsptr[DCTSIZE*6] = (int) DESCALE(tmp11 - tmp2, CONST_BITS-PASS1_BITS);
;;    wsptr[DCTSIZE*2] = (int) DESCALE(tmp12 + tmp1, CONST_BITS-PASS1_BITS);
;;    wsptr[DCTSIZE*5] = (int) DESCALE(tmp12 - tmp1, CONST_BITS-PASS1_BITS);
;;    wsptr[DCTSIZE*3] = (int) DESCALE(tmp13 + tmp0, CONST_BITS-PASS1_BITS);
;;    wsptr[DCTSIZE*4] = (int) DESCALE(tmp13 - tmp0, CONST_BITS-PASS1_BITS);
;;    
;;    inptr++;			/* advance pointers to next column */
;;    quantptr++;
;;    wsptr++;
;;  }



StartRowProcess:
        ;; we've done the columns, so it's time to do the rows.
        ;; Now we get to use vector moves!

        ;; get the pointer to the output address list
        mv_s    #OutPtrBuffer,OutPtrList

        st_s    #0,ru

        ;; how many times do we do this?
        st_s    #DCTSIZE,rc0

RowProcess:

ROW_ZERO_TEST = 1

.if (ROW_ZERO_TEST==0)
        {
        jsr     DCT_Core2
        ld_v    (uv),InVector0              ;; Get first half of row
        addr    #(4<<16),ru                 ;; bump ptr to next half
        }
        ld_v    (uv),InVector1              ;; Get second half of row
        {
        addr    #(4<<16),ru                 ;; push ptr to next column
        dec     rc0                         ;; delay slot 2
        }                                   ;; first op of s/r is mv_s
.else
        {
        ld_v    (uv),InVector0              ;; Get first half of row
        sub     tmp0,tmp0
        addr    #(4<<16),ru                 ;; bump ptr to next half
        }
        {
        ld_v    (uv),InVector1              ;; Get second half of row
        add     #1<<4,tmp0
        addr    #(4<<16),ru                 ;; push ptr to next column
        dec     rc0                         ;; delay slot 2
        }
        {
        or      in2,in3,tmp1                ;; test for null row
        addm    tmp0,in0,tmp10
        }
        {
        mul     #1,tmp10,>>#5,tmp10
        or      in4,in5,tmp2                ;; test for null row
        }
        or      in6,in7,tmp3
        or      in1,tmp1                    ;; test for null row
        {
        mv_s    #FIX_0_541196100,X6
        addm    in2,in6,z1                  ;; z1 = z2 + z3
        or      tmp2,tmp3                   ;; test for null row
        }
        {
        mv_s    #-FIX_1_847759065,X7
        or      tmp1,tmp3                   ;; test for null row
        }
        {
        bra     ne,DCT_Core3                ;; only if AC terms are non-null
        mul     X6,z1,>>#0,z1               ;; z1 *= FIX_0_541196100
        butt    in4,in0,tmp0
        }
        {
        mv_s    #FIX_0_765366865,X8
        mul     X7,in6,>>#0,in6             ;; z3 *= -FIX_1_847759065
        sat     #SAMPLE_SAT,tmp10,tmp10
        }
        {
        mul     X8,in2,>>#0,in2             ;; z2 *= FIX_0_765366865
        asl     #DSHIFT,tmp1
        }

        {
        mv_s    #$01010101,tmp12
        add     #$80,tmp10
        }
        {
        ld_s    (OutPtrList),z1
        mul     tmp12,tmp10,>>#0,tmp10
        }
        {
        bra     c0ne,RowProcess
        add     #4,OutPtrList
        }
        {
        bra     Gone
        st_s    tmp10,(z1)                  ;; store first half of row
        add     #4,z1
        }
        st_s    tmp10,(z1)                  ;; store first half of row
        nop

CoreReturn:

.endif


        ;; get the next write location (DCT_Core2 sticks 4 in z2)
        {
        ld_s    (OutPtrList),z1
        or      OutVector0[0],>>#-8,OutVector0[2]
        }

        ;; now generate packed bytes in two scalars for eight pixels.
        {
        addm    z2,OutPtrList
        or      OutVector0[2],>>#-8,OutVector1[0]
        }
        or      OutVector1[0],>>#-8,OutVector1[2]
        or      OutVector1[3],>>#-8,OutVector1[1]


        ;; we can assume these writes will work since 
        ;; the image size will ALWAYS be a multiple of eight.
        {
        bra     c0ne,RowProcess
        or      OutVector1[1],>>#-8,OutVector0[3]
        }
        {
        st_s    OutVector1[2],(z1)          ;; store first half of row
        addm    z2,z1                       ;; bump ptr to next half
        or      OutVector0[3],>>#-8,OutVector0[1]
        }                                   ;; delay slot 1
        st_s    OutVector0[1],(z1)          ;; store second half of row
    nop
                                            ;; delay slot 2

Gone:
        ;; restore smoked registers before returning to C
        {
    	ld_v    (r31),v3
	    add     #16,r31
        }
        {
    	ld_v    (r31),v4
	    add     #16,r31
        }
        {
    	ld_v    (r31),v5
	    add     #16,r31
        }
        {
    	ld_v    (r31),v6
	    add     #16,r31
        }
    	ld_v    (r31),v7
        nop
    	st_s    r29,rz
        rts     
	    add     #16,r31
        nop


;;  /* Pass 2: process rows from work array, store into output array. */
;;  /* Note that we must descale the results by a factor of 8 == 2**3, */
;;  /* and also undo the PASS1_BITS scaling. */
;;
;;  wsptr = workspace;
;;  for (ctr = 0; ctr < DCTSIZE; ctr++) {
;;    outptr = output_buf[ctr] + output_col;
;;
;;    // we don't do zero row tests, since the time taken would outweigh
;;    // the time saved.
;;    
;;    /* Even part: reverse the even part of the forward DCT. */
;;    /* The rotator is sqrt(2)*c(-6). */
;;    
;;    z2 = (INT32) wsptr[2];
;;    z3 = (INT32) wsptr[6];
;;    
;;    z1 = MULTIPLY(z2 + z3, FIX_0_541196100);
;;    tmp2 = z1 + MULTIPLY(z3, - FIX_1_847759065);
;;    tmp3 = z1 + MULTIPLY(z2, FIX_0_765366865);
;;    
;;    tmp0 = ((INT32) wsptr[0] + (INT32) wsptr[4]) << CONST_BITS;
;;    tmp1 = ((INT32) wsptr[0] - (INT32) wsptr[4]) << CONST_BITS;
;;    
;;    tmp10 = tmp0 + tmp3;
;;    tmp13 = tmp0 - tmp3;
;;    tmp11 = tmp1 + tmp2;
;;    tmp12 = tmp1 - tmp2;
;;    
;;    /* Odd part per figure 8; the matrix is unitary and hence its
;;     * transpose is its inverse.  i0..i3 are y7,y5,y3,y1 respectively.
;;     */
;;    
;;    tmp0 = (INT32) wsptr[7];
;;    tmp1 = (INT32) wsptr[5];
;;    tmp2 = (INT32) wsptr[3];
;;    tmp3 = (INT32) wsptr[1];
;;    
;;    z1 = tmp0 + tmp3;
;;    z2 = tmp1 + tmp2;
;;    z3 = tmp0 + tmp2;
;;    z4 = tmp1 + tmp3;
;;    z5 = MULTIPLY(z3 + z4, FIX_1_175875602); /* sqrt(2) * c3 */
;;    
;;    tmp0 = MULTIPLY(tmp0, FIX_0_298631336); /* sqrt(2) * (-c1+c3+c5-c7) */
;;    tmp1 = MULTIPLY(tmp1, FIX_2_053119869); /* sqrt(2) * ( c1+c3-c5+c7) */
;;    tmp2 = MULTIPLY(tmp2, FIX_3_072711026); /* sqrt(2) * ( c1+c3+c5-c7) */
;;    tmp3 = MULTIPLY(tmp3, FIX_1_501321110); /* sqrt(2) * ( c1+c3-c5-c7) */
;;    z1 = MULTIPLY(z1, - FIX_0_899976223); /* sqrt(2) * (c7-c3) */
;;    z2 = MULTIPLY(z2, - FIX_2_562915447); /* sqrt(2) * (-c1-c3) */
;;    z3 = MULTIPLY(z3, - FIX_1_961570560); /* sqrt(2) * (-c3-c5) */
;;    z4 = MULTIPLY(z4, - FIX_0_390180644); /* sqrt(2) * (c5-c3) */
;;    
;;    z3 += z5;
;;    z4 += z5;
;;    
;;    tmp0 += z1 + z3;
;;    tmp1 += z2 + z4;
;;    tmp2 += z2 + z3;
;;    tmp3 += z1 + z4;
;;    
;;    /* Final output stage: inputs are tmp10..tmp13, tmp0..tmp3 */
;;    
;;    outptr[0] = range_limit[(int) DESCALE(tmp10 + tmp3,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[7] = range_limit[(int) DESCALE(tmp10 - tmp3,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[1] = range_limit[(int) DESCALE(tmp11 + tmp2,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[6] = range_limit[(int) DESCALE(tmp11 - tmp2,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[2] = range_limit[(int) DESCALE(tmp12 + tmp1,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[5] = range_limit[(int) DESCALE(tmp12 - tmp1,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[3] = range_limit[(int) DESCALE(tmp13 + tmp0,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[4] = range_limit[(int) DESCALE(tmp13 - tmp0,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    
;;    wsptr += DCTSIZE;		/* advance pointer to next row */
;;  }
;;}
;;
;;#endif /* DCT_ISLOW_SUPPORTED */

DCT_Core:
        ;; start even part
        ;; we exploit the identities z3 = in6 and z2 = in2
        {
        mv_s    #FIX_0_541196100,X6
        addm    in2,in6,z1              ;; z1 = z2 + z3
        add     in4,in0,tmp0
        }
        {
        mv_s    #-FIX_1_847759065,X7
        mul     X6,z1,>>#0,z1           ;; z1 *= FIX_0_541196100
        asl     #DSHIFT,tmp0
        }
        {
        mv_s    #FIX_0_765366865,X8
        mul     X7,in6,>>#0,in6         ;; z3 *= -FIX_1_847759065
        sub     in4,in0,tmp1
        }
        {
        mul     X8,in2,>>#0,in2         ;; z2 *= FIX_0_765366865
        asl     #DSHIFT,tmp1
        }
        add     z1,in6,tmp2
        add     z1,in2,tmp3
        ;; end most of the even part, 
        ;; a couple of butterflies have been moved into empty slots later on

        ;; start odd part.
        {
        mv_s    #FIX_1_175875602,X6
        addm    in3,in7,z3
        add     in1,in5,z4
        }
        {
        mv_s    #-FIX_0_390180644,X7
        addm    z4,z3,z5
        add     in1,in7,z1
        }
        ;; replace tmp0-tmp3 in multiplies by in7-in1, 
        ;; then also in later addends but sums are still tmp0-tmp3
        {
        mv_s    #-FIX_1_961570560,X8
        mul     X6,z5,>>#0,z5           ;; z5 *= FIX_1_175875602
        add     in3,in5,z2
        }
        {
        mv_s    #-FIX_2_562915447,X6
        mul     X7,z4,>>#0,z4           ;; z4 *= -FIX_0_390180644
        butt    tmp3,tmp0,tmp10         ;; even butterfly
        }
        {
        mv_s    #-FIX_0_899976223,X7
        mul     X8,z3,>>#0,z3           ;; z3 *= -FIX_1_961570560
        butt    tmp2,tmp1,tmp11         ;; even butterfly
        }
        {
        mv_s    #FIX_0_298631336,X8
        mul     X6,z2,>>#0,z2           ;; z2 *= -FIX_2_562915447
        add     z5,z4
        }
        {
        mv_s    #FIX_2_053119869,X6
        mul     X7,z1,>>#0,z1           ;; z1 *= -FIX_0_899976223
        add     z5,z3
        }
        {
        mv_s    #FIX_3_072711026,X7
        mul     X8,in7,>>#0,in7         ;; tmp0 *= FIX_0_298631336
        add     z2,z4,tmp1
        }
        {
        mv_s    #FIX_1_501321110,X8
        mul     X6,in5,>>#0,in5         ;; tmp1 *= FIX_2_053119869
        add     z1,z3,tmp0
        }
        {
        mul     X7,in3,>>#0,in3         ;; tmp2 *= FIX_3_072711026
        add     in7,tmp0
        }
        {
        mul     X8,in1,>>#0,in1         ;; tmp3 *= FIX_1_501321110
        add     in5,tmp1
        }

        add     z2,in3,tmp2

        ;; final output stage
        {
        addm    z3,tmp2,tmp2
        butt    tmp0,tmp13,out3
        }
        {
        addm    z1,in1,tmp3
        butt    tmp1,tmp12,out2
        }
        {
        mv_s    #1<<10,r0
        addm    z4,tmp3,tmp3
        butt    tmp2,tmp11,out1
        }
        {
        butt    tmp3,tmp10,out0
        addm    r0,out1
        }

        {
        addm    r0,out0
        asr     #11,out1
        }
        {
        addm    r0,out2
        asr     #11,out0
        }
        {
        addm    r0,out3
        asr     #11,out2
        }
        {
        addm    r0,out4
        asr     #11,out3
        }
        {
        addm    r0,out5
        asr     #11,out4
        }
        {
        rts
        addm    r0,out6
        asr     #11,out5
        }
        {
        addm    r0,out7
        asr     #11,out6
        }
        asr     #11,out7



;;    /* Even part: reverse the even part of the forward DCT. */
;;    /* The rotator is sqrt(2)*c(-6). */
;;    
;;    z2 = (INT32) wsptr[2];
;;    z3 = (INT32) wsptr[6];
;;    
;;    z1 = MULTIPLY(z2 + z3, FIX_0_541196100);
;;    tmp2 = z1 + MULTIPLY(z3, - FIX_1_847759065);
;;    tmp3 = z1 + MULTIPLY(z2, FIX_0_765366865);
;;    
;;    tmp0 = ((INT32) wsptr[0] + (INT32) wsptr[4]) << CONST_BITS;
;;    tmp1 = ((INT32) wsptr[0] - (INT32) wsptr[4]) << CONST_BITS;
;;    
;;    tmp10 = tmp0 + tmp3;
;;    tmp13 = tmp0 - tmp3;
;;    tmp11 = tmp1 + tmp2;
;;    tmp12 = tmp1 - tmp2;
;;    
;;    /* Odd part per figure 8; the matrix is unitary and hence its
;;     * transpose is its inverse.  i0..i3 are y7,y5,y3,y1 respectively.
;;     */
;;    
;;    tmp0 = (INT32) wsptr[7];
;;    tmp1 = (INT32) wsptr[5];
;;    tmp2 = (INT32) wsptr[3];
;;    tmp3 = (INT32) wsptr[1];
;;    
;;    z1 = tmp0 + tmp3;
;;    z2 = tmp1 + tmp2;
;;    z3 = tmp0 + tmp2;
;;    z4 = tmp1 + tmp3;
;;    z5 = MULTIPLY(z3 + z4, FIX_1_175875602); /* sqrt(2) * c3 */
;;    
;;    tmp0 = MULTIPLY(tmp0, FIX_0_298631336); /* sqrt(2) * (-c1+c3+c5-c7) */
;;    tmp1 = MULTIPLY(tmp1, FIX_2_053119869); /* sqrt(2) * ( c1+c3-c5+c7) */
;;    tmp2 = MULTIPLY(tmp2, FIX_3_072711026); /* sqrt(2) * ( c1+c3+c5-c7) */
;;    tmp3 = MULTIPLY(tmp3, FIX_1_501321110); /* sqrt(2) * ( c1+c3-c5-c7) */
;;    z1 = MULTIPLY(z1, - FIX_0_899976223); /* sqrt(2) * (c7-c3) */
;;    z2 = MULTIPLY(z2, - FIX_2_562915447); /* sqrt(2) * (-c1-c3) */
;;    z3 = MULTIPLY(z3, - FIX_1_961570560); /* sqrt(2) * (-c3-c5) */
;;    z4 = MULTIPLY(z4, - FIX_0_390180644); /* sqrt(2) * (c5-c3) */
;;    
;;    z3 += z5;
;;    z4 += z5;
;;    
;;    tmp0 += z1 + z3;
;;    tmp1 += z2 + z4;
;;    tmp2 += z2 + z3;
;;    tmp3 += z1 + z4;
;;    
;;    /* Final output stage: inputs are tmp10..tmp13, tmp0..tmp3 */
;;    
;;    outptr[0] = range_limit[(int) DESCALE(tmp10 + tmp3,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[7] = range_limit[(int) DESCALE(tmp10 - tmp3,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[1] = range_limit[(int) DESCALE(tmp11 + tmp2,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[6] = range_limit[(int) DESCALE(tmp11 - tmp2,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[2] = range_limit[(int) DESCALE(tmp12 + tmp1,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[5] = range_limit[(int) DESCALE(tmp12 - tmp1,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[3] = range_limit[(int) DESCALE(tmp13 + tmp0,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
;;    outptr[4] = range_limit[(int) DESCALE(tmp13 - tmp0,
;;					  CONST_BITS+PASS1_BITS+3)
;;			    & RANGE_MASK];
    
.if (ROW_ZERO_TEST==0)

DCT_Core2:
        ;; start even part
        ;; we exploit the identities z3 = in6 and z2 = in2
        {
        mv_s    #FIX_0_541196100,X6
        addm    in2,in6,z1              ;; z1 = z2 + z3
        add     in4,in0,tmp0
        }
        {
        mv_s    #-FIX_1_847759065,X7
        mul     X6,z1,>>#0,z1           ;; z1 *= FIX_0_541196100
        asl     #DSHIFT,tmp0
        }
        {
        mv_s    #FIX_0_765366865,X8
        mul     X7,in6,>>#0,in6         ;; z3 *= -FIX_1_847759065
        sub     in4,in0,tmp1
        }
        {
        mul     X8,in2,>>#0,in2         ;; z2 *= FIX_0_765366865
        asl     #DSHIFT,tmp1
        }
        add     z1,in6,tmp2
        add     z1,in2,tmp3
        ;; end most of the even part, 
        ;; a couple of butterflies have been moved into empty slots later on

        ;; start odd part.
        {
        mv_s    #FIX_1_175875602,X6
        addm    in3,in7,z3
        add     in1,in5,z4
        }
        {
        mv_s    #-FIX_0_390180644,X7
        addm    z4,z3,z5
        add     in1,in7,z1
        }
        ;; replace tmp0-tmp3 in multiplies by in7-in1, 
        ;; then also in later addends but sums are still tmp0-tmp3
        {
        mv_s    #-FIX_1_961570560,X8
        mul     X6,z5,>>#0,z5           ;; z5 *= FIX_1_175875602
        add     in3,in5,z2
        }
        {
        mv_s    #-FIX_2_562915447,X6
        mul     X7,z4,>>#0,z4           ;; z4 *= -FIX_0_390180644
        butt    tmp3,tmp0,tmp10         ;; even butterfly
        }
        {
        mv_s    #-FIX_0_899976223,X7
        mul     X8,z3,>>#0,z3           ;; z3 *= -FIX_1_961570560
        butt    tmp2,tmp1,tmp11         ;; even butterfly
        }
        {
        mv_s    #FIX_0_298631336,X8
        mul     X6,z2,>>#0,z2           ;; z2 *= -FIX_2_562915447
        add     z5,z4
        }
        {
        mv_s    #FIX_2_053119869,X6
        mul     X7,z1,>>#0,z1           ;; z1 *= -FIX_0_899976223
        add     z5,z3
        }
        {
        mv_s    #FIX_3_072711026,X7
        mul     X8,in7,>>#0,in7         ;; tmp0 *= FIX_0_298631336
        add     z2,z4,tmp1
        }
        {
        mv_s    #FIX_1_501321110,X8
        mul     X6,in5,>>#0,in5         ;; tmp1 *= FIX_2_053119869
        add     z1,z3,tmp0
        }
        {
        mul     X7,in3,>>#0,in3         ;; tmp2 *= FIX_3_072711026
        add     in7,tmp0
        }
        {
        mul     X8,in1,>>#0,in1         ;; tmp3 *= FIX_1_501321110
        add     in5,tmp1
        }

        add     z2,in3,tmp2

        ;; final output stage
        {
        mv_s    #1<<17,tmp0
        addm    z3,tmp2,tmp2
        butt    tmp0,tmp13,out3
        }
        {
        mv_s    #1<<17,tmp1
        addm    z1,in1,tmp3
        butt    tmp1,tmp12,out2
        }
        {
        mv_s    #1<<17,tmp2
        addm    z4,tmp3,tmp3
        butt    tmp2,tmp11,out1
        }
        {
        mv_s    #1<<17,tmp3
        butt    tmp3,tmp10,out0
        }

        {
        mv_s    #1<<30,tmp10
        add_sv  v3,v5,v5            ;; add rounding 
        }
        {
        mv_s    #1<<16,tmp11
        add_sv  v3,v6,v6
        mul_sv  tmp10,v5,>>#32,v5
        }
        mul_sv  tmp10,v6,>>#32,v6
        mul_sv  tmp11,v5,>>#32,v5   ;; two step vector multiply faster than 4
        mul_sv  tmp11,v6,>>#32,v6   ;; successive right shifts for each vector

        ;; saturate the pixel outputs here.
        ;; rather than bugger about with a table, we use the sat instruction
        ;; since samples max out at either 255 or 4095 anyway.
        {
        mv_s    #$80,r0
        sat     #SAMPLE_SAT,out0,out0
        }
        {
        sat     #SAMPLE_SAT,out1,out1
        addm    r0,out0
        }
        {
        sat     #SAMPLE_SAT,out2,out2
        addm    r0,out1
        }
        {
        sat     #SAMPLE_SAT,out3,out3
        addm    r0,out2
        }
        {
        sat     #SAMPLE_SAT,out4,out4
        addm    r0,out3
        }
        {
        sat     #SAMPLE_SAT,out5,out5
        addm    r0,out4
        }
        {
        rts
        sat     #SAMPLE_SAT,out6,out6
        addm    r0,out5
        }
        {
        sat     #SAMPLE_SAT,out7,out7
        addm    r0,out6
        }
        {
        mv_s    #4,z2
        addm    r0,out7
        }

.else   ;; ROW_ZERO_TEST

        {
        mul     X8,in2,>>#0,in2         ;; z2 *= FIX_0_765366865
        asl     #DSHIFT,tmp1
        }
DCT_Core3:
        {
        mul     #1,tmp0,>>#-DSHIFT,tmp0
        add     z1,in6,tmp2
        }
        add     z1,in2,tmp3
        ;; end most of the even part, 
        ;; a couple of butterflies have been moved into empty slots later on

        ;; start odd part.
        {
        mv_s    #FIX_1_175875602,X6
        addm    in3,in7,z3
        add     in1,in5,z4
        }
        {
        mv_s    #-FIX_0_390180644,X7
        addm    z4,z3,z5
        add     in1,in7,z1
        }
        ;; replace tmp0-tmp3 in multiplies by in7-in1, 
        ;; then also in later addends but sums are still tmp0-tmp3
        {
        mv_s    #-FIX_1_961570560,X8
        mul     X6,z5,>>#0,z5           ;; z5 *= FIX_1_175875602
        add     in3,in5,z2
        }
        {
        mv_s    #-FIX_2_562915447,X6
        mul     X7,z4,>>#0,z4           ;; z4 *= -FIX_0_390180644
        butt    tmp3,tmp0,tmp10         ;; even butterfly
        }
        {
        mv_s    #-FIX_0_899976223,X7
        mul     X8,z3,>>#0,z3           ;; z3 *= -FIX_1_961570560
        butt    tmp2,tmp1,tmp11         ;; even butterfly
        }
        {
        mv_s    #FIX_0_298631336,X8
        mul     X6,z2,>>#0,z2           ;; z2 *= -FIX_2_562915447
        add     z5,z4
        }
        {
        mv_s    #FIX_2_053119869,X6
        mul     X7,z1,>>#0,z1           ;; z1 *= -FIX_0_899976223
        add     z5,z3
        }
        {
        mv_s    #FIX_3_072711026,X7
        mul     X8,in7,>>#0,in7         ;; tmp0 *= FIX_0_298631336
        add     z2,z4,tmp1
        }
        {
        mv_s    #FIX_1_501321110,X8
        mul     X6,in5,>>#0,in5         ;; tmp1 *= FIX_2_053119869
        add     z1,z3,tmp0
        }
        {
        mul     X7,in3,>>#0,in3         ;; tmp2 *= FIX_3_072711026
        add     in7,tmp0
        }
        {
        mul     X8,in1,>>#0,in1         ;; tmp3 *= FIX_1_501321110
        add     in5,tmp1
        }

        add     z2,in3,tmp2

        ;; final output stage
        {
        mv_s    #1<<17,tmp0
        addm    z3,tmp2,tmp2
        butt    tmp0,tmp13,out3
        }
        {
        mv_s    #1<<17,tmp1
        addm    z1,in1,tmp3
        butt    tmp1,tmp12,out2
        }
        {
        mv_s    #1<<17,tmp2
        addm    z4,tmp3,tmp3
        butt    tmp2,tmp11,out1
        }
        {
        mv_s    #1<<17,tmp3
        butt    tmp3,tmp10,out0
        }

        {
        mv_s    #1<<30,tmp10
        add_sv  v3,v5,v5            ;; add rounding 
        }
        {
        mv_s    #1<<16,tmp11
        add_sv  v3,v6,v6
        mul_sv  tmp10,v5,>>#32,v5
        }
        mul_sv  tmp10,v6,>>#32,v6
        mul_sv  tmp11,v5,>>#32,v5   ;; two step vector multiply faster than 4
        mul_sv  tmp11,v6,>>#32,v6   ;; successive right shifts for each vector

        ;; saturate the pixel outputs here.
        ;; rather than bugger about with a table, we use the sat instruction
        ;; since samples max out at either 255 or 4095 anyway.
        {
        mv_s    #$80,r0
        sat     #SAMPLE_SAT,out0,out0
        }
        {
        sat     #SAMPLE_SAT,out1,out1
        addm    r0,out0
        }
        {
        sat     #SAMPLE_SAT,out2,out2
        addm    r0,out1
        }
        {
        sat     #SAMPLE_SAT,out3,out3
        addm    r0,out2
        }
        {
        sat     #SAMPLE_SAT,out4,out4
        addm    r0,out3
        }
        {
        sat     #SAMPLE_SAT,out5,out5
        addm    r0,out4
        }
        {
        bra     CoreReturn
        sat     #SAMPLE_SAT,out6,out6
        addm    r0,out5
        }
        {
        sat     #SAMPLE_SAT,out7,out7
        addm    r0,out6
        }
        {
        mv_s    #4,z2
        addm    r0,out7
        }

.endif  ;; ROW_ZERO_TEST


___END:

