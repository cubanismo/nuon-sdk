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
	; 3D pipeline
	; Version 1.0 for C
	;

	;
	; This is the assembly code for the top level pipeline.
	; The entry point `pipe_start' is the start of the whole
	; pipeline, and is called by the C code. On entry, the
	; parameter block (see param.s) is assumed to have
	; been filled in completely by the caller. 
	;
	; Register assumptions for the pipeline as a whole:
	;
	; The pipeline is entered by a "jsr" call. Code may be
	; either in system ram/SDRAM or in local ram -- we can't
	; know which, it depends on the MPE. Few registers need to
	; be preserved (if our caller, e.g. some C code, cares
	; about some registers, it needs to save them).
	; EXCEPTIONS:
	;  We must save the C stack pointer (r31) and the
	;  interrupt stack pointer (sp).
	;
	; We return via an "rts" to rz.
	;
	; Register assumptions for the individual functions
	; called by the pipeline:
	;
	; (1) v0, v1, and v2 are scratch registers, not preserved by
	;     subroutines; similarly, rc0 and rc1 are not preserved
	;

	.module pipeline_s
	
	.include "pipeline.i"
	.import extra_data
	
	.export	_pipe_init, _pipe_end
	PTSIZE = 32
	
	.align	CODEALIGN

_pipe_init:
	; save old stack pointer
	ld_io sp,r29
	
	; get return address
	ld_io	rz,r30

	;; changing the stack pointer is fraught
	;; with dangers on the BIOS's MPE
//	st_s	#top_of_stack,sp


	; save return address and C stack pointer
	st_s	r31,save_r31
.if RUN_IN_PLACE
	copy	r0,r31		; save base address of instructions
.else
	mv_s	#$20300000,r31
.endif
	st_s	r30,save_rz
	; fix up "helper function" base
	; addresses
	ld_s	recip_func,r1
	st_s	r29,save_sp	
	add	r31,r1
	st_s	r1,recip_func

	; set up "extra_data_ptr"
	mv_s	#extra_data,r0
	st_s	r0,extra_data_ptr
	
	;
	; call initialization routines for the
	; pipeline components
	;
	mv_s	#pipeline_funcs,r24
	mv_s	#NUM_PIPELINE_FUNCS,r25

init_loop:
	ld_s	(r24),r0	; get a pointer to the "init" function
	st_io	#30,acshift	; set up ac shift (save a nop)
	add	r31,r0		; add base register
	jsr	(r0),nop	; call the init function
	
	sub	#1,r25		; decrement count of initialization functions left
	bra	gt,init_loop    ; loop if more functions
	st_s	r0,(r24)
	add	#4,r24		; move to next init function


	;
	; everything is initialized now; so now run the pipeline
	;
	;
	; things to do:
	; (1) load the polygon
	; (2) transform all its vertices
	; (3) check for clipping, do trivial reject
	; (4) light vertices
	; (5) clip polygon
	; (6) do perspective projection
	; (7) draw the polygon!
	;

	; register allocation
	polyptr = v3[0]		; pointer to base of polygon
	numpts = v3[1]		; number of points in polygon
	andclips = v3[2]	; "and" of clipping codes
	orclips = v3[3]		; "or" of clipping codes

	tempptr = v4[0]		; temporary pointer
	counter = v4[1]		; counter
	subr = v4[2]		; subroutine pointer
		
	tempvect = v5

pipe_loop:

	;
	; step one: load the polygon
	;
	ld_s	loadpoly_func,subr
	nop
	jsr	(subr),nop
	
	;
	; if loadpoly succeeds, it returns a non-zero value in r0
	; otherwise, it returns 0 (indicating that the pipeline is
	; finished)
	;
	cmp	#0,r0
	bra	eq,end_pipe_loop,nop

	;
	; OK, now the polygon is in inp_polygon
	; Let's load up the points and transform them
	;
	mv_s	#inp_polygon+12,polyptr
{	ld_s	(polyptr),numpts
	add	#4,polyptr,tempptr	; now tempptr points at the first point
}
	ld_s	xform_func,subr
	copy	numpts,counter
xformlp:
{	jsr	(subr)			; xform parameters:
	mv_s	tempptr,r0		; r0 == input point
}
	mv_s	tempptr,r1		; r1 == output point
	mv_s	#cur_matrix,r2		; r2 == matrix

	sub	#1,counter
{	bra	ne,xformlp,nop
	add	#PTSIZE,tempptr
}

	; points have been transformed here
	
	;
	; step two: check clipping, do trivial accept/reject
	;
{	ld_s	calcclip_func,subr
	sub	orclips,orclips			; initialize clipping masks: orclips == all 0's
}
	sub	#1,orclips,andclips		; andclips == all 1's
{	mv_s	numpts,counter
	add	#4,polyptr,tempptr		; make tempptr point at first polygon point
}
chklp:
{	jsr	(subr),nop
	copy	tempptr,r0			; r0 == pointer to vertex to check
}
	
	sub	#1,counter
{	bra	ne,chklp
	and	r0,andclips
}
	or	r0,orclips
	add	#PTSIZE,tempptr

	;
	; output of the check: if orclips is 0, none of the points lie on the "negative"
	; side of a clipping plane, and so we can trivially accept
	; if andclips is nonzero, then all of the points are on the "negative" side of
	; some plane, and so we can trivially reject
	;
	cmp	#0,andclips
	bra	ne,pipe_loop,nop

	; (the trivial accept test is moved to after the lighting)

	;
	; step three: lighting
	;

{	ld_s	light_func,subr
	copy	numpts,counter
}
	add	#4,polyptr,tempptr	; make tempptr point at first polygon point
litelp:
{	jsr	(subr)
	mv_s	tempptr,r0		; r0 == vertex to be lit
	add	#16,tempptr		; skip to lighting information within point
}
	ld_v	(tempptr),tempvect	; pre-load lighting information
	nop

{	sub	#1,counter
	mv_s	r0,tempvect[0]
}
{	bra	gt,litelp
	mv_s	r1,tempvect[1]
	copy	r2,tempvect[2]
}
	st_v	tempvect,(tempptr)	; branch delay slot: update lighting information
	add	#(PTSIZE-16),tempptr	; branch delay slot: go to next point

	;
	; step four: clipping
	;

	; trivial accept test -- if orclips == 0, we do not need to perform
	; clipping at all
	
	ld_s	doclip_func,subr
	copy	orclips,r1		; parameter for "doclip" function: OR of clipping codes
{	jsr	ne,(subr),nop
	sub	#12,polyptr,r0		; parameter for "doclip" function: pointer to polygon
}

	;
	; step five: perspective
	;
	ld_s	(polyptr),numpts	; reload # of points (may be changed by clipping)
{	add	#4,polyptr,tempptr	; make tempptr
	ld_s	persp_func,subr
}
{	cmp	#3,numpts
}
{	bra	lt,pipe_loop,nop	; if fewer than 3 points, skip polygon
	mv_s	numpts,counter
}

persplp:
	jsr	(subr)
	mv_s	tempptr,r0
	mv_s	tempptr,r1

	sub	#1,counter
{	bra	gt,persplp,nop
	add	#PTSIZE,tempptr
}
	
	;
	; step 6: actually render the polygon!
	;
	
	ld_s	polygon_func,subr
	nop
{	jsr	(subr),nop
	mv_s	#inp_polygon,r0
}
	
	bra	pipe_loop,nop		; go back to start of pipeline
	
end_pipe_loop:
	
	;
	; wait for all DMA to finish
	;
`wait1:
	ld_io	odmactl,r0
	ld_io	mdmactl,r1
	bits	#4,>>#0,r0
	bra	ne,`wait1
	bits	#4,>>#0,r1
	bra	ne,`wait1,nop
	
	; we've finished with the polygon; now return to our caller
	st_io	#0,acshift		; restore acshift to 0
	ld_s	save_sp,r1
	ld_s	save_rz,r0
	ld_s	save_r31,r31

	; if the return address is 0, halt rather than doing
	; an RTS
	st_io	r1,sp
{	cmp	#0,r0
	st_io	r0,(rz)
}
	rts	ne,nop

	halt
	nop
	nop
	;; two instructions after the halt may be processed,
	;; but we don't care because we're halting
	
_pipe_end:
