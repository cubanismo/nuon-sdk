/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */
	;; 
	;; post processing routine for anti-aliasing
	;; 

	;;
	;; call this routine with the data cache flushed --
	;; it uses the local data ram extensively
	;; the code is re-entrant, so it can be run on
	;; multiple MPEs
	;;
	;; parameters:
	;; r0 == pointer to input m3dRegion
	;;

	;;
	;; assumptions:
	;; 16 bits of antialiasing info are stored in
	;; the low bits of the Z value (so we're in a
	;; 32 bit pixel + 32 bit Z mode)
	;; there are 4 bits each of top, bottom,
	;; left, and right, in that order

	
	UV_WIDTH = 4
	UV_HEIGHT = 4

	VERT_PIXELS_TO_DO = (UV_HEIGHT-2)
	//VERT_PIXELS_TO_DO = 4

	UV_INV = fix(1/(VERT_PIXELS_TO_DO) + 0.001,30)
	
	;;
	;; NOTE: increasing U actually moves
	;; us in the vertical direction in screen
	;; space (because we read the screen in
	;; the "reverse" X-Y order)
	;;
	U_TILE = 16 - floor(log2(UV_HEIGHT))
	V_TILE = 16 - floor(log2(UV_WIDTH))
	

	;; XY_PIXELS is the number of pixels to hold
	;; on each line; this may be different from
	;; XY_WIDTH, because the latter must be
	;; a multiple of 2
	
	XY_CONST = 2
	XY_PIXELS = XY_CONST*(VERT_PIXELS_TO_DO)
	XY_WIDTH = XY_CONST*UV_HEIGHT
	
	
	PIXEL_SIZE = 8  /* pixel size in bytes */
	
	.segment aadata
	.origin 0x20100100	// leave 256 bytes for parameters
	
	.align.v
in_cmd:
	.dc.s	0		; dma flags
	.dc.s	0x40000000	; screen base address
in_cmd_x:
	.dc.s	0		; X coordinate
in_cmd_y:
	.dc.s	0		; Y coordinate
in_cmd_iaddr:	
	.dc.s	inpbuf		; input area

	.align.v
out_cmd:
	.dc.s	0		; dma flags
	.dc.s	0x40000000	; screen base address
out_cmd_x:
	.dc.s	0		; X coordinate
out_cmd_y:
	.dc.s	0		; Y coordinate
out_cmd_iaddr:		
	.dc.s	outbuf1		; output area

	.align.v
inpbuf:
	.ds.s	UV_WIDTH*UV_HEIGHT*PIXEL_SIZE/4
end_inpbuf:
	
	;; we double-buffer the output
outbuf1:
	.ds.s	XY_WIDTH*PIXEL_SIZE/4
outbuf2:
	.ds.s	XY_WIDTH*PIXEL_SIZE/4
	
	.align.v
init_alphas:
	.ds.s	4
out_line_width:
	.ds.s	1
startx:
	.ds.s	1	
uv_inv:
	.ds.s	1
				
	;; registers to be used
	;; v0-v4:	scratch registers

	alphavec = v5
	topalpha = v5[0]
	botalpha = v5[1]
	leftalpha = v5[2]
	rightalpha = v5[3]
	
	xin = v6[0]
	yin = v6[1]
	lastx = v6[2]
	lasty = v6[3]
	readptr = v7[0]
	temp0 = v7[1]
	temp1 = v7[2]
	;; v7[3] is reserved
	
	.text
	.export _vm_aadummy
_vm_aadummy:
	rts
	nop
	nop
	

	.module aa	
	.overlay aacode
	.origin $20300000
	.nocache

	push	v7,rz
	
	mv_s	#$20100000,r0	; point at parameters
{	ld_s	(r0),temp0	; get dma flags
	add	#4,r0
}
{	ld_s	(r0),temp1	; get dma base address
	add	#4,r0
}
{	ld_w	(r0),xin	; get first X coordinate as a 16.16 number
	add	#2,r0
}
{	ld_w	(r0),lastx	; get last X coordinate as a 16.16 number
	add	#2,r0
}
{	ld_w	(r0),yin	; get first y coordinate as a 16.16 number
	add	#2,r0
}
{	ld_w	(r0),lasty	; get last y coordinate as a 16.16 number
	add	#2,r0
}

	;; set up DMA buffers
	;; output buffer
		
	bset	#8,temp0	; set the "vertical" bit
{	st_s	temp0,out_cmd
	bset	#13,temp0	; set the "read" bit
}
	st_s	temp1,out_cmd + 4	; set the base address
	
	;; input buffer
	;; we're going to be reading vertical strips, so set
	;; the "vertical" bit in the read command
	bset	#8,temp0	; set the "vertical" bit
	
	st_s	temp0,in_cmd
	st_s	temp1,in_cmd + 4
	st_s	#inpbuf,in_cmd_iaddr
	
	;; set up (xy) and (uv) bilinear addressing

	;; set up (xy) for 32+32 bit pixels
	;; for double buffering purposes, we want
	;; ry to wrap at 2, so we set the y_tile
	;; bits to 15
	;; we also look for rx out of range to see
	;; when to flush the buffer
	st_s    #(1<<28)|(6<<20)|(15<<12)|XY_WIDTH,xyctl
	st_io	#outbuf1,xybase
	st_io	#(XY_PIXELS<<16),xyrange
	st_io   #0,rx
	st_io   #0,ry

	;; set up output line width
	mv_s	#XY_WIDTH*PIXEL_SIZE,r0
	st_s	r0,out_line_width
	
	;; set up (uv) for 32+32 bit pixels
	;; boundaries
	st_s    #(1<<28)|(6<<20)|(U_TILE<<16)|(V_TILE<<12)|UV_HEIGHT,uvctl
	st_io	#inpbuf,uvbase
	st_io   #1,ru
	st_io   #1,rv

	;; set up initial alpha values
	mv_s	#$00f00000,topalpha
	mv_s	topalpha,botalpha
	mv_s	topalpha,rightalpha
	mv_s	topalpha,leftalpha
	st_v	alphavec,init_alphas
		
	;;
	;; set up input max. X values
	asr	#16,lasty
	asr	#16,lastx

	;;
	;; initialize xin and yin registers		
	asr	#16,xin
	add	#1,xin
	st_s	xin,startx
	asr	#16,yin
	add	#1,yin

	mv_s	#UV_INV,r0
	st_s	r0,uv_inv
	
	;;
	;; we will use (uv) addressing to pick up the
	;; input pixels, but because we're processing
	;; in raster scan order there's some funny
	;; stuff going on -- we're going to read
	;; vertical strips into horizontal ones in
	;; MPE memory. In other words, rv will
	;; be used to represent X, and ru to
	;; represent Y!!
	;;
	
newline:

	ld_s	startx,xin	; reset x to start of line
	st_io	#(1<<16),rv
	st_io	#(1<<16),ru
	
	;; start the line off by reading the first
	;; 3 vertical strips into the start of the
	;; buffer
	;; this will be the data starting at
	;; (xin-1, yin-1)

	sub	#1,xin,r0
	sub	#1,yin,r1
	
	;; wait for last DMA to finish
`waitpending:
	ld_io	mdmactl,r2	
	or	#UV_WIDTH-1,<>#-16,r0	; pick up 3 vertical strips
{	bits	#4,>>#0,r2
	mv_s	#inpbuf,readptr
}
{	bra	ne,`waitpending,nop
	mv_s	#in_cmd,r3
}
		
{	st_s	r0,in_cmd_x
	or	#UV_HEIGHT,<>#-16,r1	; pick up the full height
}
	st_s	r1,in_cmd_y
{	st_s	readptr,in_cmd_iaddr
	add	#(UV_WIDTH-1)*(UV_HEIGHT)*PIXEL_SIZE,readptr
}
	
	st_io	r3,mdmacptr	; start DMA


	;; handle VERT_PIXELS_TO_DO pixels here
pixloop:
	;; wait for the last read to finish
`waitread:
	ld_io	mdmactl,r1
	add	#2,xin,r0		; pre-calculate next X coordinate
{	bits	#4,>>#0,r1
	st_io	#VERT_PIXELS_TO_DO,rc0
}
{	bra	ne,`waitread,nop
	or	#1,<>#-16,r0
	mv_s	#in_cmd,r3
}
	;; start reading the next vertical strip
{	st_s	readptr,in_cmd_iaddr
	add	#UV_HEIGHT*PIXEL_SIZE,readptr
}
{	st_s	r0,in_cmd_x
	cmp	#end_inpbuf,readptr
}
{	st_io	r3,mdmacptr		; start the read
	bra	lt,`readptrok,nop	; branch if read ptr is OK
}
	
	mv_s	#inpbuf,readptr

`readptrok:

	;; per-pixel stuff
	;; get all 4 pixels, arranged like:
	;;	   v1
	;;	v2 v4 v3
	;;	   v0
	;; Then blend them using the various alphas. Also, note
	;; that if, for example, v1 is ABOVE v4, then we should
	;; not do any blending with v1 -- hence, in this case,
	;; we should set topalpha to 0. We accomplish this
	;; by calculating v1.z - v4.z; if this is >= 0, we multiply
	;; topalpha by 0, otherwise we multiply topalpha by 1
	;;
	;; WARNING WARNING WARNING -- v1 is "corrupted" (it has already been
	;; blended earlier). This may or may not matter...
	;;
nextpix:
{	ld_pz	(uv),v4		; get the current pixel
	addr	#-1<<16,ru	; drop back to Y = -1
	sub	temp0,temp0
}
{	ld_v	init_alphas,alphavec
	sub	#20,temp0		;; now temp0 == -20
}
{	ftst	#$0000ffff,v4[3]	; test for all bits 0
	ld_pz	(uv),v1
	addr	#2<<16,ru		; go to Y = +1
}
{	ld_pz	(uv),v0
	bra	ne,hasalpha,nop
	addr	#-1<<16,ru		; back to Y = 0
	and	v4[3],>>temp0,rightalpha	;; shift left by 20
}
	;; we arrive here if there is no alpha
	
{	addr	#1<<16,ru	; advance to next Y
	dec	rc0		; decrement count of pixels to do
}
{	st_pz	v4,(xy)
	addr	#1<<16,rx
	bra	c0ne,nextpix,nop
}
	;; we've finished all 6 pixels here
finpixels:
	addr	#-VERT_PIXELS_TO_DO<<16,ru	; step back to Y = 0
{	range	rx		; make sure rx is still in range
	add	#1,xin
}
{	jsr	modge,FlushPixels,nop
	cmp	xin,lastx
	addr	#1<<16,rv			; step ahead in X
}
	bra	gt,pixloop,nop

	;; clear out any remaining pixels in the output buffer
{	jsr	FlushPixels,nop
}
	
	add	#VERT_PIXELS_TO_DO,yin		; check for reaching end of picture
	cmp	yin,lasty
	bra	gt,newline,nop

	;; OK, wait for all DMA to finish
`lastwait:
	ld_io	mdmactl,r0
	nop
	bits	#4,>>#0,r0
	bra	ne,`lastwait,nop

	pop	v7,rz
	nop
	ld_io	rz,r1
	nop
	cmp	#0,r1
	rts	ne,nop

	halt
	nop
	nop

	; routine for dealing with alpha
hasalpha:
{	and	v4[3],>>#-16,leftalpha
	subm	v4[3],v1[3]	; compare v1.z (set v1.z = pixel.z - top.z)
	addr	#-1<<16,rv		; back to X = -1
}
{	ld_pz	(uv),v2
	addr	#2<<16,rv		; and forward to X = +1
	and	v4[3],>>#-12,botalpha
}

{	ld_pz	(uv),v3
	lsr	#31,v1[3]		; sets v1[3] to signbit(v1[3])
	subm	v4[3],v0[3]	; set v0[3] = pixel.z - bot.z
	addr	#-1<<16,rv		; back to X = 0
}
{	subm	v4[3],v2[3]	; set v2[3] = pixel.z - left.z
	lsr	#31,v0[3]
}
{	subm	v4[3],v3[3]	; set v3[3] = pixel.z - right.z
	lsr	#31,v2[3]
}
{	lsr	#31,v3[3]
	mul	v2[3],leftalpha,>>#0,leftalpha
}
{	mv_s	#fix(1.0,24),temp0
	mul	v3[3],rightalpha,>>#0,rightalpha
	and	v4[3],>>#-8,topalpha
	
}
{	mul	v0[3],botalpha,>>#0,botalpha
	mv_s	temp0,temp1
	sub	leftalpha,>>#1,temp0
}
{	sub	rightalpha,>>#1,temp0
	mul	v1[3],topalpha,>>#0,topalpha
}

	;; now temp0 == 1.0 - (leftalpha+rightalpha)/2
{	sub	botalpha,>>#1,temp1
	mul	temp0,botalpha,>>#24,botalpha
}
{	sub	topalpha,>>#1,temp1
	mul	temp0,topalpha,>>#24,topalpha
	mv_s	#fix(1.0,24),temp0
}
	;; now temp1 == 1.0 - (topalpha+botalpha)/2
{	mul_p	botalpha,v0,>>#24,v0
	sub	botalpha,temp0
}
{	mul_p	topalpha,v1,>>#24,v1
	sub	topalpha,temp0
}
{	mul	temp1,leftalpha,>>#24,leftalpha
}
{	mul	temp1,rightalpha,>>#24,rightalpha
	add_p	v1,v0
}
{	mul_p	leftalpha,v2,>>#24,v2
	sub	leftalpha,temp0
}
{	mul_p	rightalpha,v3,>>#24,v3
	sub	rightalpha,temp0
}
{	mul_p	temp0,v4,>>#24,v4	
	add_p	v2,v0
}
{	mv_s	v4[3],v0[3]
	dec	rc0
}
{	add_p	v3,v0
	bra	c0ne,nextpix
}
{	add_p	v4,v0
	addr	#1<<16,ru	; step forward to Y = +1
	bra	finpixels
}
{	st_pz	v0,(xy)
	addr	#1<<16,rx
}
	nop
	
	
FlushPixels:
	copy	xin,r4
	copy	yin,r5

	;; wait for all dmas to finish
`waitdma:
	ld_io	mdmactl,r6
	ld_io	ry,r0			; get which buffer we're on (while we're waiting...)
{	bits	#4,>>#0,r6		; check for main bus dma ready
	ld_s	out_line_width,r1	; get width of line
}
{	bra	ne,`waitdma,nop
	or	#VERT_PIXELS_TO_DO,<>#-16,r5	; set Y length to VERT_PIXELS_TO_DO
	ld_io	xybase,r2		; get base address to write
}
	ld_s	uv_inv,r6		; r6 == 1/(UV_HEIGHT-2) (0.30 format)
	ld_io	rx,r3			; number of pixels in the buffer
	bits	#0,>>#16,r0		; extract just bit 16 of ry
	mul	r6,r3,>>#46,r3		; convert rx to an integer, and divide by UV_HEIGHT-2
	mul	r1,r0,>>#0,r0		; calculate offset to this line
	cmp	#0,r3
{	st_io	#0,rx			; zero rx to start at next buffer
	or	r3,>>#-16,r4		; set number of pixels to write
	rts	eq			; return if rx was 0
}
{	st_s	r5,out_cmd_y
	sub	r3,r4			; go back to start of cache line
}
{	st_s	r4,out_cmd_x
	add	r2,r0			; add output buffer base address
	rts
}
{	st_s	r0,out_cmd_iaddr	; set up output buffer address for this DMA
	addr	#1<<16,ry		; toggle to next output buffer
}
	st_io	#out_cmd,mdmacptr	; initiate DMA
	cmp	xin,lastx		; necessary compare

	;;
	;; Kludged up "show edges" function
	;; for demos
	;;

	.module edge	 
	.overlay edgcode
	.origin $20300000
	.nocache

	push	v7,rz
	
	mv_s	#$20100000,r0	; point at parameters
{	ld_s	(r0),temp0	; get dma flags
	add	#4,r0
}
{	ld_s	(r0),temp1	; get dma base address
	add	#4,r0
}
{	ld_w	(r0),xin	; get first X coordinate as a 16.16 number
	add	#2,r0
}
{	ld_w	(r0),lastx	; get last X coordinate as a 16.16 number
	add	#2,r0
}
{	ld_w	(r0),yin	; get first y coordinate as a 16.16 number
	add	#2,r0
}
{	ld_w	(r0),lasty	; get last y coordinate as a 16.16 number
	add	#2,r0
}

	;; set up DMA buffers
	;; output buffer
		
	bset	#8,temp0	; set the "vertical" bit
{	st_s	temp0,out_cmd
	bset	#13,temp0	; set the "read" bit
}
	st_s	temp1,out_cmd + 4	; set the base address
	
	;; input buffer
	;; we're going to be reading vertical strips, so set
	;; the "vertical" bit in the read command
	bset	#8,temp0	; set the "vertical" bit
	
	st_s	temp0,in_cmd
	st_s	temp1,in_cmd + 4
	st_s	#inpbuf,in_cmd_iaddr
	
	;; set up (xy) and (uv) bilinear addressing

	;; set up (xy) for 32+32 bit pixels
	;; for double buffering purposes, we want
	;; ry to wrap at 2, so we set the y_tile
	;; bits to 15
	;; we also look for rx out of range to see
	;; when to flush the buffer
	st_s    #(1<<28)|(6<<20)|(15<<12)|XY_WIDTH,xyctl
	st_io	#outbuf1,xybase
	st_io	#(XY_PIXELS<<16),xyrange
	st_io   #0,rx
	st_io   #0,ry

	;; set up output line width
	mv_s	#XY_WIDTH*PIXEL_SIZE,r0
	st_s	r0,out_line_width
	
	;; set up (uv) for 32+32 bit pixels
	;; boundaries
	st_s    #(1<<28)|(6<<20)|(U_TILE<<16)|(V_TILE<<12)|UV_HEIGHT,uvctl
	st_io	#inpbuf,uvbase
	st_io   #1,ru
	st_io   #1,rv

	;; set up initial alpha values
	mv_s	#$00f00000,topalpha
	mv_s	topalpha,botalpha
	mv_s	topalpha,rightalpha
	mv_s	topalpha,leftalpha
	st_v	alphavec,init_alphas
		
	;;
	;; set up input max. X values
	asr	#16,lasty
	asr	#16,lastx

	;;
	;; initialize xin and yin registers		
	asr	#16,xin
	add	#1,xin
	st_s	xin,startx
	asr	#16,yin
	add	#1,yin

	mv_s	#UV_INV,r0
	st_s	r0,uv_inv
	
	;;
	;; we will use (uv) addressing to pick up the
	;; input pixels, but because we're processing
	;; in raster scan order there's some funny
	;; stuff going on -- we're going to read
	;; vertical strips into horizontal ones in
	;; MPE memory. In other words, rv will
	;; be used to represent X, and ru to
	;; represent Y!!
	;;
	
newline:

	ld_s	startx,xin	; reset x to start of line
	st_io	#(1<<16),rv
	st_io	#(1<<16),ru
	
	;; start the line off by reading the first
	;; 3 vertical strips into the start of the
	;; buffer
	;; this will be the data starting at
	;; (xin-1, yin-1)

	sub	#1,xin,r0
	sub	#1,yin,r1
	
	;; wait for last DMA to finish
`waitpending:
	ld_io	mdmactl,r2	
	or	#UV_WIDTH-1,<>#-16,r0	; pick up 3 vertical strips
{	bits	#4,>>#0,r2
	mv_s	#inpbuf,readptr
}
{	bra	ne,`waitpending,nop
	mv_s	#in_cmd,r3
}
		
{	st_s	r0,in_cmd_x
	or	#UV_HEIGHT,<>#-16,r1	; pick up the full height
}
	st_s	r1,in_cmd_y
{	st_s	readptr,in_cmd_iaddr
	add	#(UV_WIDTH-1)*(UV_HEIGHT)*PIXEL_SIZE,readptr
}
	
	st_io	r3,mdmacptr	; start DMA


	;; handle VERT_PIXELS_TO_DO pixels here
pixloop:
	;; wait for the last read to finish
`waitread:
	ld_io	mdmactl,r1
	add	#2,xin,r0		; pre-calculate next X coordinate
{	bits	#4,>>#0,r1
	st_io	#VERT_PIXELS_TO_DO,rc0
}
{	bra	ne,`waitread,nop
	or	#1,<>#-16,r0
	mv_s	#in_cmd,r3
}
	;; start reading the next vertical strip
{	st_s	readptr,in_cmd_iaddr
	add	#UV_HEIGHT*PIXEL_SIZE,readptr
}
{	st_s	r0,in_cmd_x
	cmp	#end_inpbuf,readptr
}
{	st_io	r3,mdmacptr		; start the read
	bra	lt,`readptrok,nop	; branch if read ptr is OK
}
	
	mv_s	#inpbuf,readptr

`readptrok:

	;; per-pixel stuff
	;; get all 4 pixels, arranged like:
	;;	   v1
	;;	v2 v4 v3
	;;	   v0
	;; Then blend them using the various alphas. Also, note
	;; that if, for example, v1 is ABOVE v4, then we should
	;; not do any blending with v1 -- hence, in this case,
	;; we should set topalpha to 0. We accomplish this
	;; by calculating v1.z - v4.z; if this is >= 0, we multiply
	;; topalpha by 0, otherwise we multiply topalpha by 1
	;;
	;; WARNING WARNING WARNING -- v1 is "corrupted" (it has already been
	;; blended earlier). This may or may not matter...
	;;
nextpix:
{	ld_pz	(uv),v4		; get the current pixel
	addr	#-1<<16,ru	; drop back to Y = -1
	sub	temp0,temp0
}
{	ld_v	init_alphas,alphavec
	sub	#20,temp0		;; now temp0 == -20
}
{	ftst	#$0000ffff,v4[3]	; test for all bits 0
	ld_pz	(uv),v1
	addr	#2<<16,ru		; go to Y = +1
}
{	ld_pz	(uv),v0
	bra	ne,hasalpha,nop
	addr	#-1<<16,ru		; back to Y = 0
	and	v4[3],>>temp0,rightalpha	;; shift left by 20
}
	;; we arrive here if there is no alpha
	
{	addr	#1<<16,ru	; advance to next Y
	dec	rc0		; decrement count of pixels to do
	sub_sv	v4,v4		; black pixel
}
	mv_s	#fix(0.5,30),v4[0]	; change to grey
{	st_pz	v4,(xy)
	addr	#1<<16,rx
	bra	c0ne,nextpix,nop
}
	;; we've finished all 6 pixels here
finpixels:
	addr	#-VERT_PIXELS_TO_DO<<16,ru	; step back to Y = 0
{	range	rx		; make sure rx is still in range
	add	#1,xin
}
{	jsr	modge,FlushPixels,nop
	cmp	xin,lastx
	addr	#1<<16,rv			; step ahead in X
}
	bra	gt,pixloop,nop

	;; clear out any remaining pixels in the output buffer
{	jsr	FlushPixels,nop
}
	
	add	#VERT_PIXELS_TO_DO,yin		; check for reaching end of picture
	cmp	yin,lasty
	bra	gt,newline,nop

	;; OK, wait for all DMA to finish
`lastwait:
	ld_io	mdmactl,r0
	nop
	bits	#4,>>#0,r0
	bra	ne,`lastwait,nop

	pop	v7,rz
	nop
	ld_io	rz,r1
	nop
	cmp	#0,r1
	rts	ne,nop

	halt
	nop
	nop

	; routine for dealing with alpha
hasalpha:
	dec	rc0
	bra	c0ne,nextpix
{	addr	#1<<16,ru	; step forward to Y = +1
	bra	finpixels
}
{	st_pz	v4,(xy)
	addr	#1<<16,rx
}
	nop
	
	
FlushPixels:
	copy	xin,r4
	copy	yin,r5

	;; wait for all dmas to finish
`waitdma:
	ld_io	mdmactl,r6
	ld_io	ry,r0			; get which buffer we're on (while we're waiting...)
{	bits	#4,>>#0,r6		; check for main bus dma ready
	ld_s	out_line_width,r1	; get width of line
}
{	bra	ne,`waitdma,nop
	or	#VERT_PIXELS_TO_DO,<>#-16,r5	; set Y length to VERT_PIXELS_TO_DO
	ld_io	xybase,r2		; get base address to write
}
	ld_s	uv_inv,r6		; r6 == 1/(UV_HEIGHT-2) (0.30 format)
	ld_io	rx,r3			; number of pixels in the buffer
	bits	#0,>>#16,r0		; extract just bit 16 of ry
	mul	r6,r3,>>#46,r3		; convert rx to an integer, and divide by UV_HEIGHT-2
	mul	r1,r0,>>#0,r0		; calculate offset to this line
	cmp	#0,r3
{	st_io	#0,rx			; zero rx to start at next buffer
	or	r3,>>#-16,r4		; set number of pixels to write
	rts	eq			; return if rx was 0
}
{	st_s	r5,out_cmd_y
	sub	r3,r4			; go back to start of cache line
}
{	st_s	r4,out_cmd_x
	add	r2,r0			; add output buffer base address
	rts
}
{	st_s	r0,out_cmd_iaddr	; set up output buffer address for this DMA
	addr	#1<<16,ry		; toggle to next output buffer
}
	st_io	#out_cmd,mdmacptr	; initiate DMA
	cmp	xin,lastx		; necessary compare

