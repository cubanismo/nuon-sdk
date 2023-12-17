/*
 * Copyright (C) 1995-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */
	;
	; 3D pipeline polygon load routine
	; Version 1.0 for MML3D
	;
	; local storage required:
	;   only standard amount
	; stack required:
	;	12 long words
	
	; input parameters: none
	; output: r0 == 0 if no more triangles remain
	;
	.module loadpoly_s
	.export _loadpoly_init, _loadpoly_end
	
	.import render_info
	.import cur_mpe
	.import total_mpes
	.import dmacmd, load_inpbuf1, load_inpbuf2
	.import inp_polygon
	.import loadpoly_data
	.import	cur_matrix
	.import model_data
	.import num_polys
	
	; POLYGON INPUT BUFFER
	INPBUFSIZ = 112
	TRISIZE = 112
	INPTRIS = (INPBUFSIZ/TRISIZE)        ;; room for this many triangles

	;
	; registers
	;
	
	; v2 (a scratch register, need not be saved before use)
	retaddr =	v2[0]
	tempptr =	v2[1]
	polyptr =	v2[2]		; pointer to "standard form" of polygon
	
	; v3 must be saved/restored
	numtris	=	v3[0]		; global count of # of triangles left to render
	triptr =	v3[1]		; pointer within local RAM
	localtris =	v3[2]		; number of tris left within local RAM
	localptr =	v3[3]		; pointer to buffer

	; v4 must be saved/restored
	externptr =	v4[0]		; pointer to current read position in SDRAM
	trisperload =	v4[1]		; # of triangles processed per DMA load
	memoffset =	v4[2]		; offset to add when fetching memory
	dmactlreg =	v4[3]		; pointer to DMA control register
	
	; v5 must be saved/restored
	point =		v5		; temporary storage for a point
	
	; local storage
	; there are 16 long words available (64 bytes)
	v3_save = loadpoly_data
	v4_save = loadpoly_data+16
	campos = loadpoly_data+32	; a small vector
	
	.align CODEALIGN
	
_loadpoly_init:
	push	v4	
	push	v3

	;
	; now set up the DMAs, as necessary
	;
	; first, figure out which DMA (main bus or other bus) to use
	;
	ld_s	model_data,externptr	; get pointer to model data
	push	v0,rz
	
	btst	#31,externptr			; is high bit set?
{	bra	ne,main_dma_ok1,nop
	mv_s	#addrof(odmactl),dmactlreg	; assume other bus DMA
}

	mv_s	#addrof(mdmactl),dmactlreg
	
main_dma_ok1:

	mv_s	#load_inpbuf1,triptr
	
	;
	; figure out the offset for the next DMA; this is based on
	; our "MPE number" as determined from the parameter block
	;

	mv_s	#INPBUFSIZ,r2
	ld_s	cur_mpe,r0		; get MPE number
	ld_s	total_mpes,memoffset	; get total number of MPEs
	mul	r2,r0,>>#0,r0
	mul	r2,memoffset,>>#0,memoffset
	add	r0,externptr

	; start up the next DMA
	; the NextDMA subroutine also guarantees that the last DMA
	; has finished
	mv_s	#load_inpbuf2,localptr
{	bra	NextDMA,nop
	ld_io	pcexec,retaddr
}

	ld_s	cur_mpe,r0		; get MPE number
	ld_s	total_mpes,r1		; get total # of MPEs
	ld_s	num_polys,numtris	; get number of triangles

	mul	#INPTRIS,r0,>>#0,r0
	mul	#INPTRIS,r1,>>#0,r1
	sub	r0,numtris		; decrement by number of triangles other MPEs did
	add	r1,numtris		; add initial offset

	sub	localtris,localtris	; there are no triangles in local ram now


	; save local variables	

	st_v	v3,v3_save
	st_v	v4,v4_save
	
	; return from initialization
	pop	v0,rz
	pop	v3
	pop	v4
{	rts	nop
	add	#loadpoly - _loadpoly_init,r0
}
	
	;
	; actual loadpoly routine
	;
	
loadpoly:
	;
	; save local variables
	;
	push	v3
	push	v4
	push	v5
	ld_v	v3_save,v3
	ld_v	v4_save,v4
;;	nop
	
triloop:
	;
	; do we need to go back to SDRAM to fetch more triangles
	;
	cmp	#0,localtris
{	bra	gt,filledbuffers
	mv_s	#load_inpbuf1,r0
}
	mv_s	#load_inpbuf2,r1
	eor	r1,r0

{	bra	NextDMA
	mv_s	#INPTRIS, localtris		; we will have this many triangles available
	copy	localptr,triptr
}
{	eor	r0,localptr		; next read goes in the "other" buffer
	ld_io	(pcexec),retaddr
}
	nop

	;; we wish to calculate the number of triangles rendered by other MPEs
	;; this is (# of MPES - 1) * INPTRIS
	;;
	ld_s	total_mpes,r0
	nop
	mul	#INPTRIS,r0,>>#0,r0
	nop
	sub	r0,numtris
	bra	le,no_more_triangles,nop


	; at this point, the area of RAM pointed to by "triptr" has been filled
	; in with 4 triangles, and a DMA has started to put four more triangles
	; into the area pointed to by "localptr"

filledbuffers:
	mv_s	#inp_polygon,polyptr
{	mv_s	triptr,r0		; save off triptr
	add	#TRISIZE,triptr		; move to next triangle
}
	; assume the triangle is facing us
	; (FIXME: no backface culling here, yet)
	; load it in and put it into standard format
{	subm	v1[0],v1[0]
	mv_s	#1,v1[1]		; material type == texture
	add	#4,r0			; skip first reserved word (number of points)
}
{	ld_s	(r0),v1[2]		; get texture
	add	#12,r0			; skip texture and rest of vector
}
	st_s	#3, rc0			; set up counter for # of points
	mv_s	#3, v1[3]		; set last element of face to # of points
{	st_v	v1,(polyptr)		; save material data
	add	#16,polyptr,r1		; copy current output pointer into r1
}
	;
	; load the 3 points
	;
ldptlp:
{	ld_v	(r0),v1			; load X,Y,Z,U
	dec	rc0
	add	#16,r0
}
{	ld_v	(r0),point		; load NX,NY,NZ,V
	bra	c0ne,ldptlp
	add	#16,r0
}
{	st_v	v1,(r1)			; branch delay slot #1
	add	#16,r1
	bra	ret_from_loadpoly	; branch annulled if previous branch taken
}
{	st_v	point,(r1)		; branch delay slot #2
	add	#16,r1
}

{	mv_s	#1,r0			; indicate successful return
	sub	#1,localtris
}

	;; NOTREACHED: branch above goes to ret_from_loadpoly
no_more_triangles:
	sub	r0,r0			; indicate to caller that we're done

ret_from_loadpoly:
	;
	; save local variables, restore the callers
	;
	st_v	v3,v3_save
	st_v	v4,v4_save
	pop	v5
	pop	v4
{	rts	nop
	pop	v3
}


	;*****************************************
	;* Subroutine:
	;* Wait for the last DMA to complete
	;* Then initiate a new DMA for the next
	;* INPBUFSIZ/4 long words (INPTRIS triangles) worth of data
	;******************************************

NextDMA:
	;
	; wait for the initial DMA to be finished
	;
NDMA_dma_wait:
	ld_s	(dmactlreg),r0
	nop
	bits	#4,>>#0,r0		; is previous DMA finished yet?
	bra	ne,NDMA_dma_wait,nop

;
; begin the next DMA now (so it will be ready when we need it)
; copy 64 longwords from "externptr" to "localptr", and update
; "externptr".
;
{	mv_s	#((INPBUFSIZ/4)<<16)|(1<<13),r4	; DMA longword read, 64 long words
	copy	externptr,r5		; external address
}
{	mv_s	#dmacmd,r7		; address of command block
	copy	localptr,r6		; internal address
	jmp	(retaddr)		; return to caller
}
{	st_v	v1,(r7)			; initialize command block
	addm	memoffset,externptr	; move to next external address for this MPE
	add	#16,dmactlreg		; point to Xdmacptr
}
{	st_s	r7,(dmactlreg)		; start DMA
	sub	#16,dmactlreg
}

_loadpoly_end:
	
