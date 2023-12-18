             
	.include	"ol_render.s"	;common base code an' stuff

    bra draw_sprite,nop

	.segment	local_ram
    
    dest_read = RSqrtLUT
    source_tile = dest_read+512
    buffy = source_tile
    dma__cmd2 = source_tile+1088
    dma__cmd3 = dma__cmd2+32
    .origin dma__cmd3+32    

    .include    "sincos.s"

	.segment	local_ram

        
pixjump:

; jump table for sprite types

    .dc.s   pixgen          ;this is whatever "special" type is loaded
    .dc.s   pixgen0
    .dc.s   pixgen1         ;basic types 0, and 1 are built-in
    .dc.s   pixgen6

    .align.v

       
; Destination buffer to write pixels into prior to DMA

dest_buffer:

	.dc.s	$ffffff00,0,0,0,0,0,0,0
	.dc.s	0,0,0,0,0,0,0,0
	.dc.s	0,0,0,0,0,0,0,0
	.dc.s	0,0,0,0,0,0,0,0

; spave to doublebuffer it

	.dc.s	$ffffff00,0,0,0,0,0,0,0
	.dc.s	0,0,0,0,0,0,0,0
	.dc.s	0,0,0,0,0,0,0,0
	.dc.s	0,0,0,0,0,0,0,0


	srce_x = r8
	srce_y = r9
	srce_xsize = r10
	srce_ysize = r11
	srce_xcen = r16
	srce_ycen = r17

	dest_x1 = r18
	dest_y1 = r19
	dest_x2 = r20
	dest_y2 = r21
	dest_x3 = r22
	dest_y3 = r23
	dest_x4 = r28
	dest_y4 = r29

	dest_xsize = r20
	dest_ysize = r21
	dest_xtile = r22
	dest_ytile = r23

	buffer_offset = r24
	srcx = r25
	srcy = r26
	first_strike = r8
	ang = r8
	dest_info = r9
	srcix = r18
	srciy = r19
	xscal = r22
	yscal = r23
	

	fromsource = v6		;Matrix that goes from source to dest space
	tosource = v7		;Matrix that goes from dest to source space

	tilesize = 14		;Coz one extra pixel is loaded around the tile edge.
	cachesize = 16		;total cache size (square)
	dmasize = 32		;length of a dma strip @ dest
    
    ranseed1 = r8
    ranmask = r9
    sprcount = r10

	pixel1 = v0
	pixel = v0
	pixel2 = v1
	pixel3 = v2
	pixel4 = v3
	pixel5 = v4
	xi = tosource[0]
	yi = tosource[2]
	x = r20
	_y = r21
	dma_dbase = r24
	mix = r25
	four = r26
	dest_r = r27
	bg_pixel = object+40
	trans = object+28
;    .include    "sinelut.i"

	.segment   	instruction_ram




draw_sprite:

	push	v0,rz
    ld_s    memstat,r0
    nop
    bclr    #2,r0
    st_s    r0,memstat      ;routine invalidates SQRTLUT.
    
    jsr dma_finished,nop
;    ld_s    mpenum,r4
;    nop
;    cmp #0,r4
;    bra eq,camel,nop

    mv_s    #object,r9
	mv_s	dest_info,r0			;point at object
	ld_v	(r0),v1					;get first vector of object
	add	#16,r0						;point to next vector
{
	mv_s	r6,srce_xcen			;set sprite offset X
	copy	r7,srce_ycen			;sprite offset Y
}
{
	mv_s	r5,srce_ysize	;extract source x- and y-size 
	lsr	#16,r5,srce_xsize
}
{
	ld_v	(r0),v5					;get angle and scales...
	bits	#15,>>#0,srce_ysize
}
    nop
    bset    #0,r22
; set up the matrix that goes from source to dest

	jsr	sincos						;get the trig
	copy	r22,r0					;!sincos needs flags set!
	mv_s	r22,ang					;save the angle
{
	mv_s	r0,fromsource[0]		;set cos
	sub	r1,#0,fromsource[1]			;set -sin
}
{
	mv_s	r1,fromsource[2]		;set sin
	copy	r0,fromsource[3]		;set cos
}
	mv_v	fromsource,tosource
	mul	r20,fromsource[0],>>#24,fromsource[0]	;scale, make it 16:16 (used in rot8)
	mul	r21,fromsource[1],>>#24,fromsource[1]	;scale, make it 16:16
	mul	r20,fromsource[2],>>#24,fromsource[2]	;scale, make it 16:16
	mul	r21,fromsource[3],>>#24,fromsource[3]	;scale, make it 16:16

; I need the recips of the scales for the dest tile size calculation

	jsr	recip						;get 1/xscale
	mv_s	r20,r0
{
	abs	r0
	mv_s	#16,r1					;#fracbitz
}
{
	btst	#31,r20					;to restore sign
}
	bra	eq,nrsign1
	sub	#24,r1
	ls	r1,r0,r12					;1/xscale in r12
	neg	r12							
nrsign1:


	jsr	recip					
	mv_s	r21,r0
{
	abs	r0
	mv_s	#16,r1					;#fracbitz
}
	btst	#31,r21					;to restore sign
	bra	eq,nrsign2
	sub	#24,r1
	ls	r1,r0,r13					;1/yscale in r13
	neg	r13							
nrsign2:

; save the recips for retrieval later on

	push	v3

; now make yscale/xscale in r12, xscale/yscale in r13

	mul	r21,r12,>>#24,r12
	mul	r20,r13,>>#24,r13
	mv_s	r12,r14				;save 4 signs
	copy	r13,r15
	abs	r12
	mv_s	#$10000,r0			;These can never be greater than 1.0.
	cmp	r0,r12
	bra	le,ox1
	abs	r13
	mv_s	r20,xscal			;get xscale to a temp store
	mv_s	r0,r12

ox1:

	cmp	r0,r13
	bra	le,ox2
	mv_s	r21,yscal			;get yscale out
	btst	#31,r14
	mv_s	r0,r13

ox2:

; restore signs

	bra	eq,nneg11
	btst	#31,r15
	mv_s	#0,r0
	subm	r12,r0,r12

nneg11:

	bra	eq,nneg22
	abs	tosource[0]
	abs	tosource[1]	
	neg	r13

nneg22:

; okay, got that matrix.  Now calculate the optimum dest tile size
; 


; do some calculations for the optimum tile size


	jsr	recip
	add	tosource[1],tosource[0],r0	;(sin x plus cos x)
	mv_s	#30,r1					;@ 30 bits of prec
	sub	#16,r1
	ls	r1,r0,r1					;get recip in r1
	mv_s	#tilesize,r0			;Size of active bit of tile cache
	mul	tosource[1],r0,>>#14,r0		;tile size * sin of the angle @ 16:16
	mv_s	#(-tilesize<<15),r4		;half tilesize
	mul	r0,r1,>>#16,r1				;r1 now has (L sin x/(sin x+cos x)) where L=active cache size.
	mv_s	#(tilesize<<16),r2
	abs	r1
	sub	r0,r0
	sub	r1,r2						;r1 has "a", r2 has "b"
	copy r0,r3						;half length
	add	r4,r0						;r2,r3 = (b,0) centered
	add	r4,r1						;r0,r1 = (0,a) centered
	add	r4,r2						;r2,r3 = (b,0) centered
	add	r4,r3						;r2,r3 = (b,0) centered
	jsr	sincos						;get the trig
	push	v0						;save for doing y
	copy	ang,r0
	abs	r0
	abs	r1

{
	mv_s	r0,tosource[0]		;set cos
	sub	r1,#0,tosource[1]			;set -sin
}
{
	mv_s	r1,tosource[2]		;set sin
	copy	r0,r31		;set cos
}
 	pop	v0
	mul	xscal,tosource[0],>>#30,tosource[0]	;make it 16:16
	mul	yscal,tosource[1],>>#30,tosource[1]	;make it 16:16
	mul	r12,r0,>>#16,r0
 	mul	r12,r2,>>#16,r2
	mul	r13,r1,>>#16,r1
 	mul	r13,r3,>>#16,r3				;Correct for scaling differential
	mul	tosource[0],r0,>>#16,r0
	mul	tosource[1],r1,>>#16,r1
	mul	tosource[0],r2,>>#16,r2
	mul	tosource[1],r3,>>#16,r3
	add	r1,r0						;final x
	add	r3,r2						;final x2
	sub	r0,r2						;should be optimal x-length
	abs	r2
	lsr	#16,r2,dest_xtile			;save final x size
;	add	#1,dest_xtile
    add #1,srce_xsize
    add #1,srce_ysize

	cmp	#dmasize,dest_xtile			;limit tile size to dma size
	bra	le,baabaa
{
    mv_s    srce_xsize,r0
    lsl #1,srce_xsize
}
{
    lsl #1,srce_ysize
    mv_s    srce_ysize,r1
}
;	lsr	#1,srce_xsize,r0
;	lsr	#1,srce_ysize,r1
	mv_s	#dmasize,dest_xtile
baabaa:

	copy	dest_xtile,dest_ytile
	st_s	#6,acshift
	push	v5						;save dest_xtile,dest_ytile


; Translate corner points into destination space

;    lsr #1,srce_xsize,r0
;    lsr #1,srce_ysize,r1

	jsr rot8
	neg	r0
	neg	r1
	jsr	rot8
	mv_s r4,dest_x1
{
	mv_s	r2,dest_y1
	add	srce_xsize,r0
}
	jsr	rot8
	mv_s r4,dest_x2
{
	mv_s	r2,dest_y2
	add	srce_ysize,r1
}
	jsr	rot8
	mv_s r4,dest_x3
{
	mv_s	r2,dest_y3
	sub	srce_xsize,r0
}
	mv_s r4,dest_x4
	mv_s	r2,dest_y4
    st_s    #0,acshift

; sort points into box order

    lsr #1,srce_xsize
    lsr #1,srce_ysize
    sub #1,srce_xsize
    sub #1,srce_ysize

	cmp	dest_y1,dest_y2
	jmp	ge,srt1,nop
{
	mv_s	dest_y2,dest_y1
	copy	dest_y1,dest_y2
}
{
	mv_s	dest_x2,dest_x1
	copy	dest_x1,dest_x2
}
srt1:
	cmp	dest_y1,dest_y3
	jmp	ge,srt2,nop
{
	mv_s	dest_y3,dest_y1
	copy	dest_y1,dest_y3
}
{
	mv_s	dest_x3,dest_x1
	copy	dest_x1,dest_x3
}
srt2:
	cmp	dest_y1,dest_y4
	jmp	ge,srt3,nop
{
	mv_s	dest_y4,dest_y1
	copy	dest_y1,dest_y4
}
{
	mv_s	dest_x4,dest_x1
	copy	dest_x1,dest_x4
}

srt3:

; get dest_y2 and dest_x2 to be the next highest

	cmp	dest_y2,dest_y3
	jmp	ge,srt4,nop
{
	mv_s	dest_y3,dest_y2
	copy	dest_y2,dest_y3
}
{
	mv_s	dest_x3,dest_x2
	copy	dest_x2,dest_x3
}
srt4:
	cmp	dest_y2,dest_y4
	jmp	ge,srt5,nop
{
	mv_s	dest_y4,dest_y2
	copy	dest_y2,dest_y4
}
{
	mv_s	dest_x4,dest_x2
	copy	dest_x2,dest_x4
}
srt5:

; finally put dest_y3 and dest_y4 in order

	cmp	dest_y3,dest_y4
	jmp	ge,srt6
	mv_s	dest_info,r0		;point r0 at clip info
	sub	#32,r0
{
	mv_s	dest_y4,dest_y3
	copy	dest_y3,dest_y4
}
{
	mv_s	dest_x4,dest_x3
	copy	dest_x3,dest_x4
}
srt6:

; now get position and extent of total bounding box

	mv_s	dest_y1,dma_ypos		;this is top
	sub	dest_y1,dest_y4,r3		;this is vertical size
	ld_v	(r0),v7				;get clip box info (do it here to avoid a nop later on)
	sub	dest_x2,dest_x3,r2		;this is horizontal size
	bra	ge,gibbon1				;if greater then dest_x2 is left edge
	mv_s	dest_x2,dma_xpos	;copy assuming left edge
	ld_s	(dest_info),r20		;get dest x and ypos in r20	(do it here to avoid a nop)
	copy	dest_x3,dma_xpos	;this if x2 not left edge

gibbon1:

; got b-box pos in (dma_xpos,dma_ypos), size in (r2,r3).
; now clip the position and size against the viewport


	abs	r2						; x abs, from previous stuff	

{
	mv_s	r30,r28
	lsr	#16,r30,r29				;extract clip params
}
{
	mv_s	r31,r30
	lsr	#16,r31
}
{
	mv_s	r20,r21
	lsl	#16,r28
}
	lsl	#16,r30
	lsl	#16,r21
	lsl	#16,r29
	lsl	#16,r31

    lsr #16,dma_ypos
    lsl #16,dma_ypos
    lsr #16,dma_xpos
    lsl #16,dma_xpos


	add	dma_xpos,r20,r0
	add	dma_ypos,r21,r1			;moved to dest position

	cmp	r29,r0					;check against LH edge of viewport
	jmp	ge,camel0				;trivial reject
	cmp	r31,r1					;check against high Y of viewport
	jmp	ge,camel0				;trivial reject
	add	r0,r2,r22				;position of RH edge
    cmp r28,r22
	jmp	le,camel0				;reject if -ve
	add	r1,r3,r23				;position of high Y edge
    cmp r30,r23
	jmp	le,camel0				;reject if -ve

; okay, it is somewhere on screen


	sub	r28,r0					;clip to left edge
	jmp	ge,xclip_1,nop				;not needed if +ve
	add	r0,r2					;update width
	sub	r0,dma_xpos				;and position

xclip_1:

	sub	r30,r1					;clip to low y
	jmp	ge,yclip_1,nop
	add	r1,r3
	sub	r1,dma_ypos

yclip_1:

	sub	r29,r22					;check RH edge
	jmp	le,xclip_2,nop
	sub	r22,r2					;dec width

xclip_2:
	sub	r31,r23					;check hi Y edge
	jmp	le,yclip_2,nop
	sub	r23,r3

yclip_2:


	pop	v5
    nop
	lsr	#16,r2,dest_xsize       
   	lsr #16,r3,dest_ysize


    add #1,dest_xsize
    add #1,dest_ysize

; finish making tosource matrix (add in scales)

	jsr	sincos						;get the trig
	mv_s	ang,r0
	neg	r0
{
	mv_s	r0,tosource[0]		;set cos
	sub	r1,#0,tosource[1]			;set -sin
}
{
	mv_s	r1,tosource[2]		;set sin
	copy	r0,r31		;set cos
}

; do some calculations for the optimum tile size


	pop	v0					;get back the recips we made earlier on
	copy	dest_xtile,srcix
	copy	dest_ytile,srciy		;prepare to make increment-per-tile
	mul	r0,tosource[0],>>#30,tosource[0]	;make it 16:16
	mul	r0,tosource[1],>>#30,tosource[1]	;make it 16:16
	mul	r1,tosource[2],>>#30,tosource[2]	;make it 16:16
	mul	r1,r31,>>#30,r31	;make it 16:16
	mul	tosource[0],srcix,>>#8,srcix
	mul	tosource[2],srciy,>>#8,srciy	;make it
	mv_s	dma_xpos,r0
	mv_s	dma_ypos,r1					;current top corner
;    mv_s    #$ffff0000,r2
;    and r2,r0
;    and r2,r1


	copy	r0,r2
	copy	r1,r3
	mul	tosource[0],r0,>>#24,r0
	mul	tosource[1],r1,>>#24,r1
	mul	tosource[2],r2,>>#24,r2
	mul	r31,r3,>>#24,r3
	add	r0,r1,srcx
	add	r2,r3,srcy						;make co-ords in source space

    asr #8,tosource[0]
    asr #8,tosource[1]
    asr #8,tosource[2]
    asr #8,tosource[3]

	jsr dosprite,nop
    jsr dma_finished,nop
	pop	v0,rz
	nop
end:

;{
;  	before 	(begin
;				(format #t "Completed: ")
;				(showtix)
;			)
	rts
;}
	nop
	nop

mpe_num = r4				;Stuff for multi-MPE slicing up.
slice_size = r5
total_mpes = r6
slice_count = r7
y__lo = r0
y__hi = r1
chunk_size = r2
slice_offset = r3

dosprite:


	push	v0,rz
	mv_s	#source_tile,r0
	st_s	r0,uvbase
	st_s	r0,xybase
	mv_s	#$10400010,r0	
	st_s	r0,uvctl
	st_s	r0,xyctl
	st_s	#$10400000,linpixctl

	jsr	dma_finished
	ld_s	mdmactl,r0
	sub	buffer_offset,buffer_offset	;init double buffer offset to 0



; Traverse the dest rectangle by (dest_xtile,dest_ytile) sized blocks

xloop0:

	push	v5				;save xsize, ysize, xtile and ytile
	push	v3				;save dma_xpos, dma_ypos
	push	v6				;save srcx,srcy
	mv_s	#0,first_strike


yloop0:


	sub	dest_ytile,dest_ysize	;step over x size
	mv_s	dest_xtile,r0
	push	v5					;save, going to modify xtile
	bra	ge,yl0					;skip if size doesn't go -ve
{
	push	v3
	copy	dest_ytile,r2		;need this unmolested in load_sourcetile or else!
}
	push	v6
	add	dest_ysize,dest_ytile	;shorten the size for last horizontal tile
yl0:

; Grab up the current sourcetile

	jsr load_sourcetile,nop
	jmp	lt,notile,nop			;returns -ve if tile is right off source
	add	srce_xcen,srcx
	add	srce_ycen,srcy
	sub	r6,>>#-16,srcx
	sub	r7,>>#-16,srcy
	  
; now do one scanline of the tile

xloop1:

	sub	dest_xtile,dest_xsize,r0
	bra	gt,xl_10
	nop
	nop
	add	r0,dest_xtile
xl_10:

	mv_s	dest_xtile,dma_len

yloop1:
    ld_s    trans,r0
    nop
    bits    #3,>>#0,r0
    lsl #2,r0
    mv_s  #pixjump,r1
    add r0,r1
    ld_s    (r1),r1
    nop
;	jsr	pixgen				;go do it
    jsr (r1)                ;call selected sprite type
	st_s	srcx,ru
	st_s	srcy,rv
	add	tosource[1],srcx
	sub	#1,dest_ytile
	bra	gt,yloop1
	add	#1,>>#-16,dma_ypos
	add	r31,srcy

notile:

 	pop	v6
 	pop	v3
	pop	v5

	copy	tosource[1],r0
	copy	r31,r1

	mul	dest_xtile,r0,>>#0,r0
	mul	dest_ytile,r1,>>#0,r1
	add	r0,srcx
	add	r1,srcy	


	add	dest_ytile,>>#-16,dma_ypos
	cmp	#0,dest_ysize
	jmp	gt,yloop0,nop
	pop	v6
	pop	v3
	pop	v5
  
flork:

	add	srcix,srcx
	add	srciy,srcy
	sub	dest_xtile,dest_xsize
	bra	le,camel
	jmp	xloop0
	add	dest_xtile,>>#-16,dma_xpos
    nop



camel0:					;escape from trivial reject - needs to pop x2 then return		

	pop	v1
	pop	v0
TotallyDone:
camel:
sxit:
	pop	v0,rz
	nop
	rts

load_sourcetile:

; get the source extents of the current tile, and load in the
; appropriate bit
;
; first, find the position of the lowest pixel in the source 


	mv_s	srcx,r4
	mv_s	srcy,r5

{
	mul	tosource[1],r0,>>#0,r0	
	add	srcix,srcx,r1
}
	add	srciy,srcy,r3


; and find lowest

{
	mul	r31,r2,>>#0,r2					;got tile step in r0/r2
	cmp	r1,r4
}
	jmp	le,xlo1,nop
	mv_s	r1,r4
xlo1:
	cmp	r3,r5
	jmp	le,ylo1,nop
	mv_s	r3,r5
ylo1:

{
	add	r0,r1
	addm	r2,r3,r3					;next co-ords
}
;  find lowest

	cmp	r1,r4
	jmp	le,xlo2
	add	r4,r0
	add	r5,r2						;last co-ordpair in r0/r2
	mv_s	r1,r4
xlo2:
	cmp	r3,r5
	jmp	le,ylo2,nop
	mv_s	r3,r5
ylo2:


; find lowest

	cmp	r0,r4
	jmp	le,xlo3,nop
	mv_s	r0,r4
xlo3:
	cmp	r2,r5
	jmp	le,ylo3,nop
	mv_s	r2,r5
ylo3:

; now (r4,r5) has co-ords of lowest source point to be cached, uncentered

	push	v7					;I need some space here.
	asr	#16,r4
	asr	#16,r5					;int them
	mv_s	r4,r6
	mv_s	r5,r7
	asr	#16,srce_xcen,r0
	asr	#16,srce_ycen,r1
	add	r0,r6
	add	r1,r7
	asr	#1,srce_xsize,r0
	asr	#1,srce_ysize,r1
	add	r0,r4
	add	r1,r5
    
	add	#cachesize,r4,r2
	jmp	le,cachefail
	add	#cachesize,r5,r3
	jmp	le,cachefail			;rejecting tiles that lie wholly outside of source
	cmp	srce_xsize,r4
	jmp	ge,cachefail
	cmp	srce_ysize,r5
	jmp	ge,cachefail,nop

; if we get here we need to load up the cache.


	push	v0,rz
	mv_s	#source_tile,r30
	sub	srce_xsize,r2		;check for RH edge
	bra	lt,nrhsclip
	mv_s	#0,r28
	mv_s	#cachesize,r31			;Y size (can get altered by hi/lo clip)
	mv_s	r2,r28			;set fill to BG from right after load


nrhsclip:

	cmp	#0,r4				;check for LH edge		
	bra	gt,nlhsclip
	mv_s	#0,r29
	copy	r29,r1			;will be flag for total fill
	copy	r4,r29
	abs	r29					;set fill to BG from left after load
	lsl	#2,r29,r2			;offset for load
	add	r2,r30				;add offset
	sub	r4,r4				;and make origin 0

nlhsclip:

	cmp	#0,r5				;check for lo edge
	bra	gt,nloclip
	sub	r1,r1
	nop
{
	mv_s r5,r0
	add	r5,r31				;dec total vert size also
}
{
	mv_s	#1,r1			;flag total fill
	abs	r0
	subm	r5,r5,r5				;and zero this
}
	lsl	#6,r0
	add	r0,r30				;offset 



nloclip:

	sub	srce_ysize,r3		;check for hi edge
	jmp	lt,nhiclip,nop
{
	mv_s	#1,r1
	sub	r3,r31				;dec total loadsize
}

nhiclip:

	cmp	#0,r1
	jmp	eq,nofill,nop
	push	v1
	push	v7
	jsr	fill,nop
	pop	v7
	pop	v1
	
nofill:


	copy	dest_info,r1	
	asr	#16,srce_xcen,r2
;    copy    r4,r2
{
	add	#32,r1					;r2 points at base page DMA mode
	addm	r2,r4,r2
}
{
	ld_s	(r1),r0				;r0 got the base DMA mode
	asr	#16,srce_ycen,r3
;    copy    r5,r3
}
	add	r5,r3
    nop
{
	mv_s	#cachesize,r4
	add	#4,r1					;point at the base page address
}
{
	ld_s	(r1),r1				;nab the address
	or	r4,>>#-16,r2
}
;    cmp #0,r31
;    bra le,d_z
;    cmp #cachesize,r31
;    bra le,no_dz,nop
;d_z:
;    mv_s    #$baabaaba,r21
;    ld_s    object,r20
;    mv_s    #1,r20
;;    mv_s    #1,r31
;no_dz:        

	or	r31,>>#-16,r3
	mv_s	#dma__cmd2,r4
	st_v	v0,(r4)			;set flagz
	add	#16,r4

 
	jsr	dma_wait
	st_s	r30,(r4)			;set iadd
	sub	#16,r4
	st_s	r4,mdmacptr
	jsr	dma_finished,nop
	cmp	#0,r28
	jsr	gt,fill_from_right,nop
	cmp	#0,r29
	jsr	gt,fill_from_left,nop
	pop	v0,rz
	sub	r4,r4
	rts
	pop	v7

cachefail:

	sub	r0,r0
	rts
	pop	v7
	sub	#1,r0

pixgen:

; include the pixel generation mode of your choice here

	.include	"sp_pixg4.s"

out:

{
	ld_s	(dest_info),r2			;get x and y
	copy	dest_info,r6			;and get ready to point at dest DMA mode and address
}
	sub	#32,r6						;pointing @ dest DMA base and mode
{
	mv_s	r2,r3
	add	dma_xpos,r2
}
{
	ld_s	(r6),r0					;get dest map info
	lsl	#16,r3
}
{
	add	#4,r6
	addm	dma_ypos,r3,r3
}
{
	ld_s	(r6),r1
	lsr	#16,r2
}
	lsr	#16,r3
{
	mv_s	#dest_buffer,r5
	or	dma_len,>>#-16,r2
}
{
	mv_s	#dma__cmd,r4	
	addm	buffer_offset,r5,r5
	or	#1,<>#-16,r3			;r2 and r3 have dma x and y position
}


	lsr	#2,buffer_offset,r7		;to d-buffer the cmd-buffer   ** buffer_offset change lsr 3 to lsr 2 **
	add	r7,r4

; now set up the dma

	push	v0,rz
	jsr	dma_wait
{
	st_v	v0,(r4)			;set first word
	add	#16,r4
}
{
	st_s	r5,(r4)
	sub	#16,r4
}
	pop	v0,rz
	nop
	rts
	st_s	r4,mdmacptr
	eor	#1,<>#-7,buffer_offset


read_dest:



{
	ld_s	(dest_info),r2		;get x and y
	copy	dest_info,r4		;gonna point to dest params
}
{
	sub	#32,r4					;point to dest params
}
{
	mv_s	#dest_read,r5		;point to dest buffer
	lsl	#16,r2,r3				;extract y
	addm	dma_xpos,r2,r2
}		
{
	mv_s	buffer_offset,r6	;copy buffer pointer, gonna flip it
	add	#1,>>#-16,r3			;point at *next* line
}
{
	ld_s	(r4),r0				;pick up DMA flags
	eor	#1,<>#-7,r6				;flip to opposite buffer
	addm	dma_ypos,r3,r3
}
;	lsr	#1,r6					;and the buffer is only 128-bytes.
	nop							;*** try shit
{
	mv_s	#4,r7				;wanna add 4, no alu slot...
	cmp	#0,first_strike			;is this the first time around?
}
{
	bra	ne,nfirstt
	lsr	#16,r2
	addm	r7,r4,r4			;so I am gonna add using the mul
}
{
	mv_s	#1,r1				;Y height
	lsr	#16,r3
}
{
	mv_s	#dma__cmd3,r7
}
	add	#1,r1					;inc y-height first time
	sub	r6,r6					;and always load at the top of the buffer.
	sub	#1,r3					;not on line+1 if first time
nfirstt:
{
	ld_s	(r4),r1				;fetch dest screen address
	or	r1,>>#-16,r3			;r2 and r3 have dma x and y position
	addm	r6,r5,r4			;make buffer address
}
	bset	#13,r0				;maybe I'll find another place to stick this.

	mv_s	#dmasize,r6
	or r6,>>#-16,r2


; now set up the dma

	push	v0,rz
{
	jsr	dma_wait
	st_v	v0,(r7)			;set first word
	add	#16,r7
}
{
	st_s	r4,(r7)
	sub	#16,r7
}
;	lsr	#1,buffer_offset,r4		;want to generate read address, use this buffer offset
    copy    buffer_offset,r4
	pop	v0,rz
{
	st_s	r7,mdmacptr
	add	r4,r5					;r5 will point @ current buffer to read srce pixels from.
}
	ld_s	mdmactl,r0
	cmp	#0,first_strike
	jmp	eq,dma_finished
	rts
	mv_s	#1,first_strike
	nop						

fill:

	mv_s	#cachesize,r29

fill_from_left:

; fill r29 columns of pixels to background, from the left side of the srce txture

	st_s	r29,rc1
	mv_s	#source_tile,r1
	mv_s	#(64*16)-4,r28
foof:
	mv_s	#bg_pixel,r0
	ld_s	(r0),r0
	nop
	mv_s	#64,r2
filll:
	mv_s	#4,r3
ffl:
{
	st_s	r0,(r1)
	addm	r2,r1,r1
	sub	#1,r3
}
{
	st_s	r0,(r1)
	add	r2,r1
	bra	gt,ffl
}
{
	st_s	r0,(r1)
	add	r2,r1
}
{
	st_s	r0,(r1)
	add	r2,r1
}
	dec	rc1
	jmp	c1ne,filll
	rts
	sub	r28,r1			;truncated nop for rts!


    
rot8:

	mul	r0,fromsource[0],>>acshift,r4		;Sub to rotate r0/r1 by fromsource.
	mul	r1,fromsource[1],>>acshift,r5		;used to save space!!!!
	mul	r0,fromsource[2],>>acshift,r2		;returns x in r4, y in r2.
{
	add	r5,r4
	mul	r1,fromsource[3],>>acshift,r3
}
	nop
	add	r3,r2

; now ceil r4 and r2

    mv_s    #1,r3       ;fracbits for ceil

{
    push    v0,rz
    copy    r2,r0
}
    jsr ceil,nop
{
    mv_s    r4,r0
    copy    r0,r5
}
    jsr ceil,nop
{
    pop v0,rz            
    copy    r0,r4
}
    nop
    rts
    mv_s    r5,r2
    nop
    
ceil:

; make a r3-bit integer by rounding up

{
    mv_s    r0,r1
    abs r0
}
    ls r3,r0
    add #1,r0
    btst    #31,r1
    rts eq
    rts
    nop
    neg r0


    nop
    nop
;    asr #1,r4
;    asr #1,r2


fill_from_right:

; fill r28 columns of pixels to background, from the right side of the srce txture

	st_s	r28,rc1
	bra	foof
	mv_s	#source_tile+(4*15),r1
	mv_s	#(64*16)+4,r28





;	.segment	local_ram
;	.align.v
;    .include    "reciplut.i"
	.segment	instruction_ram
pixgen0:
    .include    "sp_pixg0.s"
pixgen1:
    .include    "sp_pixg1.s"
pixgen6:
    .include    "sp_pixg6.s"
   	.include	"recip.s"
