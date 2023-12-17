;*
;* Merlin graphics code for drawing a mandelbrot
;*
;*
#include "mandel.h"

;------------------------------------------------------------------------------
;	Register Equates
;------------------------------------------------------------------------------


	r_yLimit 	= r31
	r_xLimit 	= r30
	r_iy 		= r29
	r_ix 		= r28
	r_ht 		= r27
	r_Temp 		= r26
	r_wid 		= r25
	r_xMax 		= r24
	r_xMin 		= r23
	r_yMax 		= r22
	r_yMin 		= r21
	r_halfwid 	= r20
	r_xPos 		= r19
	r_yPos 		= r18
	r_halfht 	= r17
	r_delta 	= r16
	WaitCount 	= r2
	zr_even 	= r8
	zr_temp 	= r10
	zr 		= r9
	zi 		= r14
	zr2 		= r13
	zi2 		= r12
	r_colors 	= r11

	r_Xdelta	= r15

;------------------------------------------------------------------------------
;	Defines
;------------------------------------------------------------------------------


	MAX_WIDTH	= 352
        SCR_WIDTH       = MANDEL_WIDTH
        SCR_HEIGHT      = MANDEL_HEIGHT

        bilinearMode    = 4  ;6   ; 32 bit pixel
        dmaPixelType    = 4  ;6   ; 32 bit pixel
	dmaPixelSize 	= 2	; 32 bit pixel

        dmaPixelWrite = 6  ;4    ;6
	dmaBufferSize = 8
	dmaTransferMax = dmaBufferSize / dmaPixelSize


;------------------------------------------------------------------------------
;	Data
;------------------------------------------------------------------------------

	.segment	mandeld
	.origin $20100000
	.align.v	; align these structures for vector operations

screen_width:   .dc.s SCR_WIDTH
screen_height:  .dc.s SCR_HEIGHT

x_center:	.dc.s fix(-0.256278832,29)
y_center:	.dc.s fix(0.850589734,29)
width:		.dc.s fix(0.000045777,29)

//
// depth (= no. of iterations before we give up)
// this must be a multiple of 4
// there are actually two values of depth: the normal (default),
// and the "moving" depth to use while we're moving around in
// the set. These can be made different, in which case the view
// gets more detail when we stop moving;  in practice this isn't
// really very nice

//DEFAULT_DEPTH = 128
DEFAULT_DEPTH = 128
MOVING_DEPTH = DEFAULT_DEPTH
//MOVING_DEPTH = 96

depth:          .dc.s DEFAULT_DEPTH

//init_x_center:  .dc.s fix(-0.256281832,29)
//init_y_center:	.dc.s fix(0.850589734,29)

init_x_center:  .dc.s fix(-0.29,29)
init_y_center:	.dc.s fix(0.00,29)
init_width:	.dc.s fix(3.999999,29)

//step_scale:     .dc.s fix(0.98,29)
//step_out_scale: .dc.s fix(1/0.98,29)
step_scale:     .dc.s fix(0.995,29)
step_out_scale: .dc.s fix(1/0.995,29)

pixelStart:     .dc.s 0
pixelStep:      .dc.s 1  ;3   ;1
joystick:	.dc.s 0

	.macro COLOR_YCC y, cr, cb
	.dc.s	fix(0.7*y, 30)
	.dc.s	fix(0.7*cr,30)
	.dc.s	fix(0.7*cb,30)
	.dc.s	0
	.mend

	.macro mkseg_YCC y,cr,cb
		`i = 9
		.while `i <= 16
		    scale =	`i/16
		    COLOR_YCC scale*y, scale*cr, scale*cb
		    `i = `i + 1
		.end
	.mend

	.align.v
colors:
	;; magenta
	mkseg_YCC 0.413000, 0.418690, 0.331260
	;; violet
	mkseg_YCC 0.694772, 0.177320, 0.140298
	;; blue
	mkseg_YCC 0.114000, -0.081310, 0.499999
	;; cyan
	mkseg_YCC 0.701000, -0.5, 0.168740
	;; green
	mkseg_YCC 0.587000, -0.418690, -0.331260
	;; yellow
	mkseg_YCC 0.886000, 0.081310, -0.5
	;; orange
	mkseg_YCC 0.678824, 0.229083, -0.383085
	;; red
	mkseg_YCC 0.299000, 0.5, -0.16874

;*
;*		Local Screen/Pixel Buffer
;*
		.align.v
LocalBuffer:						
	        .ds.s   dmaBufferSize * 2

;*
;*		DMA Block
;*
		.align.v
dmaCmd:
dmaFlags:	.ds.s	1
dmaBase:	.ds.s	1
dmaX:		.ds.s	1
dmaY:		.ds.s   1
dmaIAddr:	.ds.s	1

		.align.sv
dmaPointers:
		.ds.s	2

;*
;*		STack
;*
StackBase:
	        .ds.s   32
StackTop:

;------------------------------------------------------------------------------
;	Code Section
;------------------------------------------------------------------------------

	.nocache
        .segment mandelc
	.origin $20300000

;*
;*	 Initialize hardware
;*
prolog:
	mv_s	#StackTop,r31
	st_s	r31,(sp)

        mv_s    #LocalBuffer,r1
        st_s    r1,(xybase)
        mv_s    #SCR_WIDTH | (bilinearMode << 20) | (1 << 28),r1
        st_s    r1,(xyctl)
        st_s    #1,(svshift)           ; 8.24 format
        st_io   #29,acshift

.if 0
        mv_s    #((MAX_WIDTH / 8) << 16) | (3 << 14) | (1 << 11) | (dmaPixelType << 4),r0
	//// THIS CODE IS OBSOLETE, see the comm bus receive code below
        ; setup the dma command
	st_s	r0,dmaFlags
        mv_s    #SCREEN,r0
	st_s	r0,dmaBase
.endif
        mv_s    #LocalBuffer,r0
        st_s    r0,dmaIAddr

skipstart:
                            
;*
;* 	Set up the big loop
;*
	ld_s	init_x_center,r0
	nop
	st_s	r0,x_center
	ld_s	init_y_center,r0
	nop
	st_s	r0,y_center
	ld_s	init_width,r0
	nop
	st_s	r0,width

;*
;* 	Set up the parameters
;*
bigloop:
	// wait for a comm bus packet from the host
	// packet contains: 0 = screen address
	//                  1 = DMA flags
	//                  2 = num mpes (high 16 bits), this mpe # (low bits)
	//                  3 = joystick bits
	;; unlock the comm bus so we can receive messages
	st_io	#0,commctl
	nop

`waitcbus:
	ld_s	commctl,r0
	nop
	btst	#31,r0	;  data ready yet?
	bra	eq,`waitcbus,nop

	;; OK, there's a packet ready
	;; first, lock the comm bus so nobody can send us anything
	;; while we deal with the packet
	st_s	#(1<<30),commctl   ; set receive disable bit

	;; now, load the packet
	ld_v	commrecv,v0
	nop
	st_s	r0,dmaBase
	st_s	r1,dmaFlags
	st_s	r3,joystick
	copy	r2,r0
	bits	#15,>>#16,r2	// extract high bits
	bits	#15,>>#0,r0	// extract low bits
	st_s	r2,pixelStep	// save # of MPEs
	st_s	r0,pixelStart	// save this MPE

	//
	ld_s	screen_width,r0
	nop
	sub	r1,r1,r1
        jsr     recip
	nop
	nop
	ld_s	screen_height,r_ht
	sub	#30,r1,r_Temp		; Temp = AccFBITS - OutFBITS
	as	r26,r0,r0	      	; r_Temp = 1/screen_width (2.30)
	mv_s	r0,r_Temp
	mul	r_Temp,r_ht,>>#0,r_ht	; ac = screen_height/screen_width (34.30)
					; r_ht = screen_height/screen_width (2.30)
	ld_s	width,r_wid		; r_wid = width (3.29)
	nop
	mul	r_wid,r_ht,>>#30,r_ht	; ac = width * screen_height/screen_width (5.59)
					; r_ht = width * screen_height/screen_width (3.29)

        ld_s    x_center,r_xMax
   nop
;        asr     #1,r_wid,r_halfwid
        mv_s    r_xMax,r_xMin
;        add     r_halfwid,r_xMax,r_xMax
;        sub     r_halfwid,r_xMin,r_xMin
        ld_s    y_center,r_yMax
        nop
;        asr     #1,r_ht,r_halfht
        mv_s    r_yMax,r_yMin
;        add     r_halfht,r_yMax,r_yMax
        mv_s    r_Temp,r_delta
;        sub     r_halfht,r_yMin,r_yMin
        mul     r_wid,r_delta,>>#30,r_delta ; ac = width/screen_width (5.59)
                                        ; r_delta = width/screen_width (3.29)
        mv_s    #SCR_WIDTH/2,r_halfwid
        mul     r_delta,r_halfwid,>>#0,r_halfwid
        nop
        add     r_halfwid,r_xMax
        sub     r_halfwid,r_xMin
        mv_s    #SCR_HEIGHT/2,r_halfht
        mul     r_delta,r_halfht,>>#0,r_halfht
        nop
        add     r_halfht,r_yMax
        sub     r_halfht,r_yMin

	ld_s	pixelStep,r_Xdelta
	nop
	mv_s	r_yMax,r_yPos
	mul	r_delta,r_Xdelta,>>#0,r_Xdelta

;*
;* 	Set up the outer loops (bumping x first, then y)
;*
	ld_s	screen_height,r_yLimit
	nop
	asl	#16,r_yLimit
	ld_s	screen_width,r_xLimit
	nop
	asl	#16,r_xLimit

	mv_s	#colors,r_colors

	sub	r_iy,r_iy,r_iy
	st_s	r_iy,(rx)
	st_s	r_iy,(ry)

yloop:

	ld_s pixelStart,r_xPos
        ld_s	pixelStart,r_ix
	mul	r_delta,r_xPos,>>#0,r_xPos
	nop
	add	r_xMin,r_xPos
{	; mv_s	r_xMin,r_xPos
	asl	#16,r_ix }
xloop:
doPixel:
        ld_s    depth,r8     // get depth (must be a multiple of 4)
{	copy	r_xPos,zr
}
{	copy	r_yPos,zi     
	st_s	r8,(rc0)
}
	;; let c = (r_xPos, r_yPos), a complex number
	;; consider the sequence
	;; z_{i+1} = (z_i)*(z_i) + c
	;; where z_0 = c
	;; we have:
	;; new zr = zr*zr-zi*zi + r_xPos
	;; new zi = 2*zr*zi + r_yPos

	;; inner loop: 4 iterations in 22 ticks
{	mul	zi,zi,>>acshift,zi2
}
{	mul	zr,zr,>>acshift,zr2
	mv_s	zi,r0
}
{	mul	zr,r0,>>#28,r0		// r0 := 2*zr*zi
	mv_s	zi,r1
}
{	mul	r1,r1,>>#29+4,r1	// r1 := zi*zi>>4
	mv_s	zr,r2
	butt	zi2,zr2,zr_even
}
ploop:
{	bra	vs,pixelDone,nop                ; test result of "butt" 
	mul	r2,r2,>>#29+4,r2	// r2 := zr*zr>>4
	add	r_yPos,r0,zi	        // final zi result
	dec	rc0
}
{	add	r_xPos,zr               // final zr result
	mul	zi,zi,>>acshift,zi2
	mv_s	zi,r0
}
{	bits	#4,>>#27,r1
	mul	zr,zr,>>acshift,zr2
}
{	bra	ne,pixelDone,nop
	bits	#4,>>#27,r2
	mv_s	zi,r1
	mul	zr,r0,>>#28,r0		// r0 := 2*zr*zi
}
{	bra	ne,pixelDone,nop
	mul	r1,r1,>>#29+4,r1	// r1 := zi*zi>>4
	mv_s	zr,r2
	butt	zi2,zr2,zr_even
}

// iteration 2
{	bra	vs,pixelDone,nop                ; test result of "butt" 
	mul	r2,r2,>>#29+4,r2	// r2 := zr*zr>>4
	add	r_yPos,r0,zi	        // final zi result
	dec	rc0
}
{	add	r_xPos,zr               // final zr result
	mul	zi,zi,>>acshift,zi2
}
{	bits	#4,>>#27,r1
	mul	zr,zr,>>acshift,zr2
	mv_s	zi,r0
}
{	bra	ne,pixelDone,nop
	bits	#4,>>#27,r2
	mul	zr,r0,>>#28,r0		// r0 := 2*zr*zi
	mv_s	zi,r1
}
{	bra	ne,pixelDone,nop
	mul	r1,r1,>>#29+4,r1	// r1 := zi*zi>>4
	mv_s	zr,r2
	butt	zi2,zr2,zr_even
}

// iteration 3
{	bra	vs,pixelDone,nop                ; test result of "butt" 
	mul	r2,r2,>>#29+4,r2	// r2 := zr*zr>>4
	add	r_yPos,r0,zi	        // final zi result
	dec	rc0
}
{	add	r_xPos,zr               // final zr result
	mul	zi,zi,>>acshift,zi2
}
{	bits	#4,>>#27,r1
	mul	zr,zr,>>acshift,zr2
	mv_s	zi,r0
}
{	bra	ne,pixelDone,nop
	bits	#4,>>#27,r2
	mul	zr,r0,>>#28,r0		// r0 := 2*zr*zi
	mv_s	zi,r1
}
{	bra	ne,pixelDone,nop
	mul	r1,r1,>>#29+4,r1	// r1 := zi*zi>>4
	mv_s	zr,r2
	butt	zi2,zr2,zr_even
}

// iteration 4
{	bra	vs,pixelDone,nop                ; test result of "butt" 
	mul	r2,r2,>>#29+4,r2	// r2 := zr*zr>>4
	add	r_yPos,r0,zi	        // final zi result
	dec	rc0
}
{	bits	#4,>>#27,r1
}
{	bra	ne,pixelDone,nop
	bits	#4,>>#27,r2
}
{	bra	ne,pixelDone,nop
	add	r_xPos,zr               // final zr result
	mul	zi,zi,>>acshift,zi2
}
{	mul	zr,zr,>>acshift,zr2
	mv_s	zi,r0
	bra	c0ne,ploop
}
{	mul	zr,r0,>>#28,r0		// r0 := 2*zr*zi
	mv_s	zi,r1
}
{	mul	r1,r1,>>#29+4,r1	// r1 := zi*zi>>4
	mv_s	zr,r2
	butt	zi2,zr2,zr_even
}

overflow:
	bra	haveColor
	sub_sv	v1,v1		// use black
	nop

pixelDone:
	ld_s	depth,r1
	ld_s	(rc0),r8
	copy	r_colors,r0
	sub	r8,r1,r8
	and	#63,r8
	add	r8,>>#-4,r0
        ld_v    (r0),v1
	// fall through

haveColor:
`waitdma:
        ; wait for the previous dma to complete
	ld_s	(mdmactl),r3
	nop
	and     #$1f,r3
 	bra	ne,`waitdma,nop

	st_p	v1,(xy)

      {	mv_s	#1<<16,r4
	copy	r_ix,r5
      }
      { mv_s	#1<<16,r6
	copy	r_iy,r7
      }

;*
;*	launch a DMA write
;*

;*
;*	 get the x and y pointers and counts
;*

;*
;* 	setup the dma
;*
	ld_s    (xybase),r_Temp
	st_sv	v1,dmaX
	st_s	r_Temp,dmaIAddr
;*
;* 	start the dma
;*
        mv_s    #dmaCmd,r_Temp
        st_s    r_Temp,(mdmacptr)

	ld_s	pixelStep,r_Temp
	nop
	add	r_Temp,>>#-16,r_ix
	cmp	r_ix,r_xLimit
	jmp  	cc,xloop		; ne
	add	r_Xdelta,r_xPos,r_xPos
	nop
;	nop

      { add	#1,>>#-16,r_iy
	subm	r_delta,r_yPos,r_yPos
      }
;	nop
;	nop
	cmp	r_iy,r_yLimit
	jmp  	ne,yloop
	nop
	nop

	;; OK, done one iteration here
	;; load the joystick and see if we should move in or out
	START_BIT =   (13+16)
	A_BIT     =   (14+16)
	B_BIT     =   (3+16)
	NUON_BIT  =   (12+16)

	ld_s	joystick,r2
	st_s	#DEFAULT_DEPTH,depth	// assume normal # of iterations
	copy	r2,r3
	bits	#3,>>#(16+4),r3		// extract the "speed" parameter

	;; start button == go back to beginning
	btst	#START_BIT,r2
	bra	ne,skipstart,nop

	;; A button == zoom in
	btst	#A_BIT,r2
	bra	eq,`no_a_button,nop

	ld_s	step_scale,r0
	ld_s	width,r1
	st_io	r3,rc0		// save speed parameter
`zoomloop:
	dec	rc0
	bra	c0ne,`zoomloop
        mul     r0,r1,>>#29,r1
	nop

	// while we're  zooming, we might not do as many iterations
        st_s	#MOVING_DEPTH,depth

	// don't zoom in too much
	cmp	#$2000,r1
	bra	ge,`widthok,nop
	mv_s	#$2000,r1
`widthok:
        st_s    r1,width

`no_a_button:
	;; B button == zoom out
	btst	#B_BIT,r2
	bra	eq,`no_b_button,nop

	ld_s	step_out_scale,r0
	ld_s	width,r1
	nop

	st_io	r3,rc0		// save speed parameter
`zoomoutloop:
        mul     r0,r1,>>#29,r1
	dec	rc0
	bra	mvs,skipstart,nop
	bra	c0ne,`zoomoutloop,nop

	// while we're  zooming, do MOVING_DEPTH iterations
        st_s	#MOVING_DEPTH,depth
        st_s    r1,width

`no_b_button:
	// move around based on X and Y
	ld_s	joystick,r0
	ld_s	joystick,r1
	lsl	#16,r0		// r0 will be X movement
	lsl	#24,r1		// r1 will be Y movement
	asr	#24,r0
	asr	#24,r1
	or	r0,r1,r2	// check for any movement
	bra	eq,bigloop,nop

	// scale analog stick by the speed
	mul	r3,r0,>>#0,r0
	mul	r3,r1,>>#0,r1

	st_s	#MOVING_DEPTH,depth
	ld_s	x_center,r_xPos
	ld_s	y_center,r_yPos
	mul	r_delta,r0,>>#6,r0
	mul	r_delta,r1,>>#6,r1
	add	r0,r_xPos
	add	r1,r_yPos
	st_s	r_xPos,x_center
	st_s	r_yPos,y_center

        jmp     bigloop
        nop
        nop


	.align.v
done:
	nop

        .segment mandeld
        .include "reciplut.i"

	.segment mandelc
        .include "recip.s"
