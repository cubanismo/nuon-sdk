;
; ol_render: traverse an Object List and render the Objects.

;***************************
;
; OBJECT-LIST ROUTINE RULES
;      AND STRATEGIES
;
;***************************

; The idea of the Object List system is to allow you to get
; various graphics elements up and running quickly, and to
; present a common interface to the 2D routines that is easy
; to use and which facilitates rendering over multiple MPEs.
;
; To use the Object List system, one just builds an Object List, and
; loads up OL_RENDER and lets it fly.
;
; OL_RENDER does the following:
;
; Reads the next object from the OLP.
; If it is an End object, terminates the MPE.
; Obtains the MPE number and sets up the Task Splitting params.
; If Outer Level Task Splitting is enabled then:
; - Get clip window params of Object.
; - Generate successive strips and modify the clip window params.
; - If the strip is inside the window, load the environment.
; - Run the routine with the clip params calculated.
; - Repeat until the window is covered.
; If Outer Level Task Splitting is not enabled, just set up
; the environment and call the routine.
;
; Setting Up the Environment
; ==========================
;
; In order to render a strip, the OLR needs to set up any
; math tables, and the object code in IRAM, that are needed.
; The routine uses the global MEMSTAT and the object-local
; OB_TYPE to do this before the routine is called.  Code and
; math tables are only loaded if they are not already in RAM
; when the object is processed.


	.include	"merlin.i"
    .include    "scrndefs.i"
    .include    "ol_demo.i"     ;external RAM setup info

; Common Object environment
; =========================
;
; The next set of equates define an environment that all
; Object-List compliant graphics routines should use.

	.segment	local_ram

_base   = init_env

ctr = _base
mpenum = ctr+4
logical_mpenum = mpenum+4
memstat = logical_mpenum+4
dest_screen = _base+16
dest = dest_screen+4
rzinf = dest_screen+16
object = rzinf+16
dma__cmd = object+64
ol_buffer = dma__cmd+32

RecipLUT = dma__cmd+128
SineLUT = RecipLUT+512
RSqrtLUT = SineLUT+1024
olp = RSqrtLUT+768

object_size = 16		;size of an Object, in longs

ob_type = object+60		;where the Type information lurks

	.segment	instruction_ram

; register equates for the OL system

	_type = r8
	_ctr = r9
	_dest = r10
	_olp = r11
	_subtype = r12
	_ob = r13
	_ymin = r14
	_ymax = r15
	_slices = r16
	_zonelo = r17
	_zonehi = r18
    _oneshot = r19

goat:

	st_s	#(local_ram_base+4096),sp	;init SP to top of DTRAM

; when starting an MPE, the Motherprocess passes in some params
; in v0, so set them up

    mv_s    r0,_oneshot ;nonzero means just do one object
	st_s	r1,ctr		;timer counter
	st_s	r2,dest		;dest screen address
	st_s	r3,olp		;base of the Object List
	mv_v	v0,v2		;keep these out of the way


    mv_s    #rzinf,r1

    ld_s    configa,r0
    ld_s    rzinf+12,r5         ;base MPE
    bits    #4,>>#8,r0
    st_s    r0,mpenum
;	sub	#base_mpe,r0					;this is based on MPEs 2 and 3...
    sub r5,r0
	st_s	r0,logical_mpenum	;note what we are logically
    st_s    r0,(r1)				;logical MPE#        

ol_loop:

; load up the next Object

	jsr	dma_wait,nop	;wait for DMA ready
{
	mv_s	#object_size,r0	;how many longs to load
	jsr	dma_read			;call to load them
}
{
	mv_s	_olp,r1				;from the current OLP
	add	#(object_size*4),_olp	;(increment it)
}
	mv_s	#object,r2			;here is where to load it to
	jsr	dma_finished,nop		;wait until it is loaded

; got the Object - is it the end of the list?

	ld_s	ob_type,_ob	;get type info
	nop
	copy	_ob,_type
	copy	_ob,_subtype
	bits	#7,>>#0,_type		;extract main Type
	bits	#7,>>#8,_subtype	;and subtype


    
	cmp	#$ff,_type				;obtype 255 = End
	bra	eq,ol_done,nop			;finish	if end object reached.

; The Object is for real.  Check for outer level task split

	btst	#16,_ob				;outer level splitting disable?
	bra	eq,ol_tasksplit,nop		;No so go do it

; There is no Outer Level Task Split.  So load the good old env and go.


	jsr	setup_env,nop		;Prepare...
	push	v1
    push    v4
	push	v2				;save our context...
	jsr	it,nop				;Do it...
	pop	v2
    pop v4
	pop	v1					;restore our context...
	bra	ol_end,nop			;Then do the next object.

ol_tasksplit:

; We have outer level task splitting.  Prepare to call the
; object multiple times, modifying the clip params as we go.

	ld_s	dest_screen+12,_ymin	;pickup the Y clip params
	nop
	lsr	#16,_ymin,_ymax			;extract max-Y
	bits	#15,>>#0,_ymin		;and minimum

; do multiple MPE code

	mv_s	#0,_slices			;slice counter

slic:


	ld_s	rzinf+4,r1		;get slice size
	ld_s	logical_mpenum,r2	;get our logical mpe#
	ld_s	rzinf+8,r3			;total # of mpes


	
	mul	r1,r2,>>#0,r2		;this is the base offset
	mul	r1,r3,>>#0,r3		;this is the chunk size
	nop

; start line of render zone is (chunk offset*slice number)+base offset

	mul	_slices,r3,>>#0,r3
	nop
	add	r3,r2,_zonelo
	add	_zonelo,r1,_zonehi				;get lo and hi edges of current zone
    sub #1,_zonehi                   ;clip is inclusive

	cmp	_zonelo,_ymax
	bra	lt,restore_yclip				;start>hibound; the object's done

	cmp	_zonehi,_ymin
	bra	gt,next_zone		;end<lobound; do next zone

; preserve the original y clip info before I mod it

	push	v3				;save original Y-clip info

	cmp	_zonelo,_ymin
	bra	gt,nboto,nop			;if Ymin > Zonelo, then use Ymin...	
	copy _zonelo,_ymin			;else, just use zonelo.		

nboto:

	cmp	_zonehi,_ymax
	bra	lt,ntopo,nop			;if Ymax < Zonehi then use Ymax
	copy _zonehi,_ymax			;or else use zonehi.

ntopo:

; now, set _ymin and _ymax to be the Y clip params

	lsl	#16,_ymax
	or _ymax,_ymin
	st_s	_ymin,dest_screen+12	;set them up

; then save state and call the routine

	jsr setup_env,nop		;set up environment
	push	v2
	push	v4				;save our stuff
	jsr	it,nop				;call it
	pop	v4
	pop	v2					;get back stuff
next_zone:	

	bra slic	;go to next slice
	pop	v3			;get back y-clip stuff too
	add	#1,_slices	;enumerate next slice	

restore_yclip:

; restore yclip modified by subdivision

	lsl	#16,_ymax
	or _ymax,_ymin
	st_s	_ymin,dest_screen+12	;set them up

ol_end:

    cmp #0,_oneshot         ;check for oneshot mode
    bra eq,ol_loop,nop

twat_it:
ol_done:

; finished, shut dowm and sync with the other MPEs
; first, invalidate code-loaded section in MEMSTAT

    ld_s    memstat,r0
    nop
    mv_s    #$ff00,r1
    or r0,r1
    st_s    r1,memstat

; flag completion externally

    ld_s    mpenum,r4
    sub r6,r6
    st_s    r6,object
    lsl #2,r4
    mv_s    #status+16,r1
    add r4,r1
    jsr dma_write
    mv_s    #object,r2
    mv_s    #1,r0

; and halt.

HaltMPE:

	halt
	nop
	nop

get_stat:

; get the status vector

    push    v7,rz
    jsr dma_finished,nop
    mv_s    #4,r0
    jsr dma_read
    mv_s    #status,r1
    mv_s    #object,r2
    jsr dma_finished,nop
    pop v7,rz
    ld_v    object,v0
    rts t,nop
    
put_stat:            

; put the status vector (v0)

    push    v7,rz
    st_v    v0,object
    jsr dma_finished,nop
    mv_s    #4,r0
    jsr dma_write
    mv_s    #status,r1
    mv_s    #object,r2
    jsr dma_finished,nop
    pop v7,rz
    nop
    rts t,nop


setup_env:

; Set up the math table environment and load source code, if needed.

	push	v0,rz			;save stuff
    jsr dma_finished,nop
	ld_s	memstat,r7		;get current state
	copy	_ob,r5			;get the object info
	bits	#3,>>#20,r5		;extract and shift maths needs

; test for, and load, needed math tables


	btst	#0,r5				;is RecipLUT present?
	bra	eq,recip_loaded		    ;if 1, yup
    btst    #0,r7
    bra ne,recip_loaded,nop
{
	jsr	dma_read				;go load stuff
	mv_s	#128,r0				;128 Longs, specifically
	bset	#0,r7				;flag it has loaded
}
	mv_s	#external_recip,r1	;external addy of recip table
	mv_s	#RecipLUT,r2	    ;local recip RAM


recip_loaded:

	btst	#1,r5				;is SineLUT loaded?
	bra	eq,sine_loaded		    ;if 1, yup
    btst    #1,r7
    bra ne,sine_loaded,nop
{
	jsr	dma_read				;go load stuff
	mv_s	#256,r0				;256 Longs, specifically
	bset	#1,r7				;flag it has loaded
}
	mv_s	#external_sine,r1	;external addy of sine table
	mv_s	#SineLUT,r2	    	;local sine RAM

sine_loaded:

	btst	#2,r5				;is RSqrtLUT loaded?
	bra eq,got_math,nop			;if 1, yup
    btst    #2,r7
    bra ne,got_math,nop
{
	jsr	dma_read				;go load stuff
	mv_s	#192,r0				;192 Longs, specifically
	bset	#2,r7				;flag it has loaded
}
	mv_s	#external_sqrt,r1	;external addy of sqrt table
 	mv_s	#RSqrtLUT,r2	    ;local sqrt RAM

got_math:


; okay, DTRAM environment is setup; now load the actual code (if it is not loaded already)

	copy	r7,r0
	bits	#7,>>#8,r0		;this is what is current
	cmp	r0,_type			;_type is what the object needs
	bra	eq,got_code,nop		;already got the code.
	lsl	#8,_type,r0
    bits    #7,>>#0,r7      ;remove any existing Type...
	or	r0,r7				;put type into the memstat

; load in the code overlay at it:

	lsl	#5,_type,r1			;get index into routine table
	mv_s	#external_routines,r6
	add	r6,r1				;pointing at data of various routines...

; load in 8 longs of data to ol_buffer

	jsr	dma_read
	mv_s	#8,r0
	mv_s	#ol_buffer,r2
	jsr	dma_finished,nop

; now read the info out of ol_buffer and load the MPE


	
	mv_s	#ol_buffer,r5
	
{
	ld_s	(r5),r1			;xram address of data
	add	#4,r5
}
{
	ld_s	(r5),r2			;mpe address to load into...
	add	#4,r5
}
{
	ld_s	(r5),r0			;length of load
	add	#8,r5
}
	jsr dma_read,nop		;load iram
	jsr	dma_finished,nop

{
	ld_s	(r5),r1			;xram address of data
	add	#4,r5
}
{
	ld_s	(r5),r2			;mpe address to load into...
	add	#4,r5
}
	ld_s	(r5),r0			;length of load
	jsr	dma_read,nop
	jsr	dma_finished,nop	;loaded both

got_code:

; environment is loaded, so save away memstat and return

	pop	v0,rz
	st_s	r7,memstat
	nop
	rts	t,nop

; stuff used from libraries

	.include	"dma.s"
	.include	"comms.s"

it:

; overlays load to here


