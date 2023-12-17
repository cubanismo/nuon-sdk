	;;
	;; animated sky texture code
	;; Copyright (c) 1997-2001 VM Labs, Inc.
	;; All rights reserved.
	;; Confidential and Proprietary Information of VM Labs, Inc.
	;; 
 	;; NOTICE: VM Labs permits you to use, modify, and distribute this file
 	;; in accordance with the terms of the VM Labs license agreement
 	;; accompanying it. If you have received this file from a source other
	;; than VM Labs, then your use, modification, or distribution of it
 	;; requires the prior written permission of VM Labs.
;


SCRN_WIDTH = 352
SCRN_HEIGHT = 240
	
;;	
;; PIXEL_TYPE must be defined to the kind of pixels we're
;; going to write out: 4 or 6 for 32bpp,
;; 5, 7, 8, 9, etc. for 16bpp
;;
PIXEL_TYPE = 4

.if (PIXEL_TYPE == 6)
	PIXEL_SIZE = 8
.else
	PIXEL_SIZE = 4
.endif

;; YSTEPSIZE is how much to add to the Y coordinate
;; on each new line; in the present implementation
;; multiple MPE rendering is done by having, e.g.,
;; each of two MPEs do every other line, in which
;; case YSTEPSIZE should be 2. Larger values don't
;; seem to work right :-(.
;; Make sure YSTEPSIZE matches SKY_MPES in pigs.c
YSTEPSIZE = 2

;;
;; "WHITE" is the color of the clouds
;; "BLUE" is the color of the background
;;
	WHITE = $90808000
	BLUE = $327c9c00

;	WHITE = $90808000
;	BLUE =  $10808000
	
	.segment    skyram
	.nocache
	.origin $20100000
    
	;; flag: after we've initialized, it will
	;; be nonzero
init_done:
	.dc.s	0
fade_count:
	.dc.s	0		
dest_base_addr:
	.dc.s   0
dest_dma_flags:
	.dc.s 0
dest_starty:
	.dc.s 0
dest_ycount: 
	.dc.s 0
	
;;baseCol:    .dc.s   $ff000000

	.align.v
v2_save:
	.dc.v 0,0,0,0
v3_save:
	.dc.v 0,0,0,0
v4_save:
	.dc.v 0,0,0,0
v5_save:
	.dc.v 0,0,0,0
v6_save:
	.dc.v 0,0,0,0
v7_save:
	.dc.v 0,0,0,0
	
test_dma:
	_ii = 0
	.while _ii < 64
	.dc.s	$ffffff00
	.dc.s 0
	_ii=_ii+1
	.end

dma__cmd:

	.dc.s	0,0,0,0,0,0,0,0

    .align.v

microtexture:
;;	the_col = $1080c000
	the_col = BLUE

	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col

	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
		.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col
	.dc.s	the_col

dma_buffer:

	.dc.s	0

dma_base:

	.dc.s	0

	.align.v

colour1:	.dc.s	$ff00ff00
colour2: 	.dc.s	$80ff8000
xpos:		.dc.s	-($4000*180)
ypos:		.dc.s	-($4000*120)
xoff:		.dc.s	0
yoff:		.dc.s	0
xinc:		.dc.s	$1200
yinc:		.dc.s	$0c00
phase1:		.dc.s	0

    .align.v

xtx:

; microtexture frob-params

    .dc.s   $a3000000          ;This is the mask
    .dc.s	$83659300		    ;2 seeds
    .dc.s   $58255973
    .dc.s   0                           ;X
    .dc.s   0                           ;Y
txcol1:    .dc.s   $ff389500                   ;colour1
fadeto:    .dc.s   $00808000            ;fade to this
ctr:    .dc.s   0

    .align.v

iu:    .dc.s   $1000
iv:    .dc.s   0
su:    .dc.s   0
sv:    .dc.s   $1000

__i2u:    .dc.s  $1000
__i2v:    .dc.s  $100
__s2u:   .dc.s   -$300
__s2v:   .dc.s   -$800

_i3u:   .dc.s   -3
_i3v:   .dc.s   $1
_s3u:   .dc.s   -$1
_s3v:   .dc.s   2



_iu:    .dc.s   $1000
_iv:    .dc.s   0
_su:    .dc.s   0
_sv:    .dc.s   $1000

_i2u:    .dc.s  0
_i2v:    .dc.s  0
_s2u:   .dc.s   0
_s2v:   .dc.s   -$80


scrnx = r4
scrny = r5
dma_size = r6
xcount = r7


; v0 holds calculated pixel values and can be freely used inside the
; texture pixel function.

_D_Vpix		=	v0
_D_Vpixz	=	r3

; v1 is reserved for scratch registers, and I use it a lot to hold
; intermediate pixel values.

_D_Vtemp	=	v1

; v2 is not needed while rendering a scanline (and it is preserved outside
; of the texture loop call, so we can use it without stacking it).
; v3 is also unused and can be used if we stack the contents.

; values interpolated across scanlines. v4 contains the texture co-ordinates
; _D_u and _D_v, so we must leave it alone and have it available inside the loop. 

_D_VX		=	v4
_D_lx		=	r16		; left X
_D_rx		=	r17		; right X
_D_u		=	r18		; left U (texture value, usually)
_D_v		=	r19		; left V (texture value, usually)

; v5 contains more interpolated values.  Usually we will only be concerned with
; _D_i0, which is the diffuse shading value; we use that after generating each pixel
; to apply the correct intensity for the 3D stuff.  _D_w is a third texture space
; co-ordinate that can be used to create 3D procedural textures.

_D_VI		=	v5		; intensity values
_D_i0		=	r20		; shading value (e.g. diffuse intensity)
_D_i1		=	r21		; shading value (e.g. specular intensity)
_D_i2		=	r22		; shading value (e.g. some other shader value)
_D_w		=	r22
_D_z		=	r23		; Z (kept here because pixel color+Z are saved together in st_p)

; v6 and v7 contain the deltas that are added to the interpolated values over a
; scanline.  So we can't bash them inside the loop!

_D_VdX		=	v6
_D_dlx		=	r24		; delta left X (only useful for steps)
_D_drx		=	r25		; delta right X (only useful for steps)
_D_du		=	r26		; delta U	(i.e. dU/dX)
_D_dv		=	r27		; delta V	(i.e. dV/dX)

_D_VdI		=	v7
_D_di0		=	r28		; delta i0 (i.e. dI0/dX)
_D_di1		=	r29
_D_di2		=	r30
_D_dw		=	r30
_D_dz		=	r31

; Okay, now I am going to alias the most commonly used ones from the above
; list to something a bit nicer to type when working on textures :-)

	tu = _D_u
	tv = _D_v		;tu, tv and tw are the texture co-ordinates.
	tw = _D_w
    tiu = _D_du
    tiv = _D_dv     ;tiu, tiv, and tiw are the texture increments.
	tiw = _D_dw
	shade = _D_i0		;shading value
    ishade = _D_di0		;shading delta
	pixel0 = v0
    pixel1 = v1
	pixel2 = v2		;these can all be used for holding pixels or whatever
	pixel3 = v3
    params0 = v2		;and typically I shall use v2 and v3 for params.
    params1 = v3  
	pixel4 = v6
	pixel5 = v7

    i2u = r16
    i2v = r17

    .segment skycode
    .origin $20300000

//    st_s    #($20100000+4*1024),sp

    ; initialise
    
    jsr setup
    nop
    nop

    ;; get data from the comm bus;
    ;; the packet will tell us what to draw,
    ;; as follows:
    ;; r0 == destination dma flags
    ;; r1 == destination base address
    ;; r2 == start Y value
    ;; r3 == y count

    jsr GetVector,nop

    st_s    r0,dest_dma_flags
    st_s    r1,dest_base_addr
    st_s    r2,dest_starty
    st_s    r3,dest_ycount
	
    ; see if we've already started up
    ld_s  init_done,r0
    st_s #1,init_done
	    
    cmp #0,r0
    bra ne,restart,nop



    ; draw an initial frame

  
    mv_s    #0,r12
    mv_s    #$100,r13

loop:

	st_v	v2,v2_save
	st_v	v3,v3_save
	st_v	v4,v4_save
	st_v	v5,v5_save
	st_v	v6,v6_save
	st_v	v7,v7_save
//	halt
	nop
	nop
restart:

	ld_v	v2_save,v2
	ld_v	v3_save,v3
	ld_v	v4_save,v4
	ld_v	v5_save,v5
	ld_v	v6_save,v6
	ld_v	v7_save,v7

    push    v0
    push    v1
    push    v3

    jsr     drawframe,nop
    
    pop v3
    pop v1
    pop v0

    
.if 0
    jsr SendVectorTo
    mv_s    #0,r4       ;send back to MPE 0
    sub_sv  v0,v0
.endif
	
    jmp loop
    nop
    nop

drawframe:
      
; set up some params

    push    v0,rz
    jsr perframe,nop        ;microtexture frobbery
    pop v0,rz
    nop

    mv_s    #$10000,r1		;animate some stuff
    ld_s    phase1,r0
	nop
	add r0,r1
    st_s    r1,phase1
    
    ld_s    ctr,r0
    nop
    add #1,r0
    st_s    r0,ctr

; use ctr value to tweak the warp-params

    push    v1,rz

    jsr gcv
    mv_s    #$80,r0
    mv_s    #$ffff,r1
    asr #2,r0
    st_s    r0,__i2u
    jsr gcv
    mv_s    #$30,r0
    mv_s    #$ffff,r1
    asr #2,r0
    st_s    r0,__i2v
    jsr gcv
    mv_s    #$20,r0
    mv_s    #$ffff,r1
    asr #2,r0
    st_s    r0,__s2u
    jsr gcv
    mv_s    #$70,r0
    mv_s    #$ffff,r1
    asr #2,r0
    st_s    r0,__s2v
    jsr gcv
    mv_s    #$24,r0
    mv_s    #$ffff,r1
    asr #2,r0
    st_s    r0,iu
    jsr gcv
    mv_s    #$53,r0
    mv_s    #$ffff,r1
    asr #2,r0
    st_s    r0,iv
    jsr gcv
    mv_s    #$11,r0
    mv_s    #$ffff,r1
    asr #2,r0
    st_s    r0,su
    jsr gcv
    mv_s    #$46,r0
    mv_s    #$ffff,r1
    asr #2,r0
    st_s    r0,sv
    jsr gcv
    mv_s    #$8,r0
    mv_s    #$ffff,r1
    asr #8,r0
    st_s    r0,_i3u
    jsr gcv
    mv_s    #$c,r0
    mv_s    #$ffff,r1
    asr #8,r0
    st_s    r0,_i3v
    jsr gcv
    mv_s    #$4,r0
    mv_s    #$ffff,r1
    asr #8,r0
    st_s    r0,_s3u
    jsr gcv
    mv_s    #$7,r0
    mv_s    #$ffff,r1
    asr #8,r0
    st_s    r0,_s3v
    
    
        
    pop v1,rz
    nop
    
;    jmp gnuu,nop

	mv_s	#$4000*SCRN_WIDTH,r0		;x upper lim
	mv_s	#$4000*SCRN_HEIGHT,r1		;y upper lim

	ld_v	xoff,v1				;get offsets and directions
	nop
	add	r6,r4
	bra	lt,reflx,nop
	cmp	r0,r4
	bra lt,movey,nop
reflx:
	neg	r6
	add	r6,r4
movey:
	add	r7,r5
	bra	lt,refly,nop
	cmp	r1,r5
	bra lt,donemove,nop
refly:
	neg	r7
	add	r7,r5
donemove:
	st_v	v1,xoff
;	lsr	#1,r0
;	lsr	#1,r1
	sub	r0,r4
	sub	r1,r5
	st_s	r4,xpos
	st_s 	r5,ypos

gnuu:

   
   ld_v iu,v0
   ld_v __i2u,v7
   st_v v0,_iu
   st_v v7,_i2u

    ld_s    dest_ycount,r0
    ld_s    dest_starty,scrny
    st_io   r0,rc0

    mv_s    #(YSTEPSIZE*$1000),r0           ;Y step
    mul scrny,r0,>>#0,r0        ;offset for start scanline   

.if (PIXEL_TYPE == 4 || PIXEL_TYPE == 6)
	mv_s	#$10400020,r2			;Width = cacheSize; use ch_norm; pixmap 4
	st_s	r2,linpixctl
.else
	mv_s	#$10500020,r2			;Width = cacheSize; use ch_norm; pixmap 4
	st_s	r2,linpixctl
.endif

	ld_s	ypos,tv
    ld_s    xpos,tu
	ld_s    _iu,tiu
	ld_s	_iv,tiv
    ld_s    _i2u,i2u
    ld_s    _i2v,i2v
    add r0,tv                   ;offset for start scanline
yloop:
	sub	scrnx,scrnx
	mv_s	#64,dma_size
	mv_s	#SCRN_WIDTH,xcount
;	ld_s	xpos,tu
;	ld_s    _iu,tiu
;	ld_s	_iv,tiv
;    ld_s    _i2u,i2u
;    ld_s    _i2v,i2v

    push    v4
    push    v6

xloop:

dmaw2:	
	ld_s	mdmactl,r0
	nop
	bits	#4,>>#0,r0
	bra	ne,dmaw2,nop	

; generate some pixels

	sub	dma_size,xcount
	bra	gt,notend,nop
	add	xcount,dma_size
notend:
	st_s	dma_size,rc1

; save loop reggies

	push	v1
	push	v2

; call the pixel gen

	push	v0,rz
	jsr	pixgen
	st_s	#0,rx
	st_s	#0,ry	

	pop	v0,rz
	nop

; retrieve loop reggies

	pop	v2
	pop	v1


; wait DMA-idle

dmaw:	
	ld_s	mdmactl,r0
	nop
	bits	#4,>>#0,r0
	bra	ne,dmaw,nop		
		
; build DMA-command

	mv_s	#dma__cmd,r2
	ld_s	dest_dma_flags,r0
	ld_s	dest_base_addr,r1
	st_s	r0,(r2)
	add	#4,r2
	st_s	r1,(r2)
	add	#4,r2
	mv_s	scrnx,r0
//	mv_s	#$400000,r1
	lsl	#16,dma_size,r1
	or	r1,r0
	st_s	r0,(r2)
	add	#4,r2
	mv_s	scrny,r0
	or	#1,<>#-16,r0
	st_s	r0,(r2)
	mv_s	#test_dma,r0
	add	#4,r2
	st_s	r0,(r2)
	sub	#16,r2
	st_s	r2,mdmacptr

	

	add	#64,scrnx
	cmp	#0,xcount
	bra	gt,xloop,nop
	ld_v    _iu,v0
    pop v6
    pop v4
    nop
	add	r2,tu           ;add step increments
	add	r3,tv
    ld_v    _i2u,v7
	add	#YSTEPSIZE,scrny
    asr #8,r30,r24
    asr #8,r31,r25
    add r24,r2
    add r25,r3           ;do second order stuff
    st_v    v0,_iu
    ld_v    _i3u,v0
	dec	rc0
    add r2,r30
    add r3,r31
    st_v    v7,_i2u   
	bra	c0ne,yloop,nop
    rts
	nop
	nop

gcvs:
gcv:
{
    bra gcv0
    ld_s    ctr,r2
}
    nop
    lsr #3,r2
    

    ld_s    ctr,r2
    nop
gcv0:
    mul r2,r0,>>#0,r0
    mv_s    #-1,r3
    and r1,r0
    lsr #1,r1
    and r1,r3
    lsr #1,r1
    sub r3,r0
    rts
    abs r0
    sub r1,r0
pixgen:

;;    .include    "cubic.ptx"
  
; bilerp texture
;

	bufaddr = r4
	_tiu = r6
	_tiv = r7


foo:
    push    v6
{
    mv_s    #test_dma,bufaddr
    asr #8,tiu,_tiu
}
{
    st_s    #17,acshift    
    asr #8,tiv,_tiv
}

	st_s	tu,rx
	st_s	tv,ry
	st_s	tu,ru
	st_s	tv,rv

{
        ld_p    (uv),pixel0      ;Grab a pixel from the source
        addr    #1<<16,ru           ;go to next horiz pixel
        add     _tiu,tu
}

{
        ld_p    (uv),pixel2     ;Get a second pixel
        addr    #1<<16,rv           ;go to next vert pixel
}
{
        ld_p    (uv),pixel4     ;get a third pixel
        addr    #-1<<16,ru          ;go to prev horizontal pixel
}
{
        ld_p    (uv),pixel3     ;get a fourth pixel
        addr    #-1<<16,rv          ;go back to original pixel
        sub_sv  pixel0,pixel2    ;b=b-a
}       
{
;    ld_s    i2u,i2u
        addr    #1<<16,ry
	sub	pixel0[3],pixel0[3]
}	
;    nop


bilerploop:

{
        mv_v    pixel0,pixel5            ;save a copy of first pixel, 
                                        ;freeing up pixel 1.
        mul_p   ru,pixel2,>>#30,pixel2  ;scale according to fractional part of ru
        sub_p  pixel3,pixel4           ;make vector between second 2 pixels
        addr    _tiv,ry                   ;Point ry to next y
}
{
        st_s   tu,ru                  ;Can now update ru, finished multiplying with it.
        mul_p   ru,pixel4,>>#30,pixel4  ;scale according to fractional part of ru
        sub_p  pixel3,pixel0
        addr    _tiu,rx                   ;(XY) now points at next pixel 1
}
{
        ld_p    (xy),pixel3             ;Loading next pixel 3.
        addr    #-1<<16,ry                  ;POinting to next pixel 1.
        add_p  pixel2,pixel0           ;get first intermediate result
        dec     rc1                     ;Decrementing the loop counter.
}
{
        ld_p    (xy),pixel0              ;getting next pixel 1.
        sub_p  pixel0,pixel4            ;get vector to final value
        addr    #1<<16,rx                   ;Working over to point to pixel 2.
}
{
        mul_p   rv,pixel4,>>#30,pixel4  ;scale with fractional part of rv
        add_p  pixel2,pixel5           ;add pix2 to the copy of pix1
        addr    _tiv,rv
}
{
        ld_p    (xy),pixel2             ;load up next pixel2
        addr    #1<<16,ry                   ;point to next pixel 4
	add	_tiv,tv
}
{
        ld_p    (xy),pixel4             ;get next pixel4
        add_p  pixel4,pixel5           ;make final pixel value
        addr    #-1<<16,rx                  ;start putting these right
}

{
        st_pz    pixel5,(bufaddr)       ;Deposit the pixel in the dest buffer
}

    pop pixel5                  ;get "old" v6
    nop
{
    add i2u,r30
    addm i2v,r31,r31
}
{
    push    pixel5
    asr #8,r30,_tiu
}
    asr #8,r31,_tiv   
{
		jmp	c1ne,bilerploop
    ld_v    _i3u,pixel5                  ;get third order thangs
        sub_p  pixel0,pixel2            ;b=b-a
}
{
	add	#PIXEL_SIZE,bufaddr		;; move to next address
        addm    _tiu,tu,tu                  ;do x inc
}
{
    add r28,i2u
    addm    r29,i2v                 ;do third order
}

; postamble
{
    sub r28,i2u
    subm    r29,i2v
}

{
	subm	i2u,_tiu,_tiu
	sub		_tiu,tu
}
{
	pop v6
    sub i2v,_tiv,_tiv
	rts
}
    nop
    nop
;{
;    mv_s    _tiv,tiv
;    copy    _tiu,tiu
;}
    
	
	  
setup:
	;; make sure comm bus is enabled
	st_io	#0,commctl

; initialise linpixctl etc...

	mv_s	#$10400020,r2			;Width = cacheSize; use ch_norm; pixmap 4
	st_s	r2,linpixctl
    mv_s    #$104cc010,r2
    st_s    r2,uvctl
    st_s    r2,xyctl
    mv_s    #microtexture,r2
    st_s    r2,uvbase
    st_s    r2,xybase
;	mv_s	#test_dma,r0
;	st_s	r0,xybase
	rts
	nop
	nop


perframe:

; stuff that modifies the srce texture

		ranmask = r8
        ranseed1 = r9
        ranseed2 = r10
        mtx = r11			;left & right step not used in the actual texture
		mty = r12

	push	v0,rz    
    push    v1
    push    v2

.if (PIXEL_TYPE != 4 && PIXEL_TYPE != 6)
	mv_s	#$10400020,r2			;Width = cacheSize; use ch_norm; pixmap 4
	st_s	r2,linpixctl
.endif
	
    ld_s    ctr,r0
    nop
    lsl #1,r0,r1
    lsr #1,r0,r2
    bits    #7,>>#0,r0
    bits    #7,>>#0,r1
    bits    #7,>>#0,r2
    lsl #24,r0,r4
    lsl #16,r1,r5
    lsl #8,r2,r6
    lsl #16,r0
    lsl #8,r1
;    lsl #24,r2
    mv_s    #$ffff00,r3
    mv_s    #$10101000,r2
    
;    or  r2,r0
;    or r2,r6
    or  r0,r1
    or r4,r5
    or r5,r6

    and r3,r1
;    and r3,r6
;    or  r2,r1
;    or  r2,r6

	ld_s	fade_count,r0
	nop
	btst	#12,r0
	bra	eq,swap1
	add	#1,r0
	st_s	r0,fade_count
	
	mv_s    #BLUE,r6			;; was #$80808000,r6
{	st_s    r6,txcol1
	bra noswap
}
	mv_s    #WHITE,r1			;; was #$10306000,r1
	st_s    r1,fadeto
swap1:
	
	mv_s    #WHITE,r6			;; was #$80808000,r6
	st_s    r6,txcol1
	mv_s    #BLUE,r1			;; was #$10306000,r1
	st_s    r1,fadeto
noswap:
;    st_s    r1,colour1
;    st_s    r6,colour2
   

    ld_v    xtx,v2
    ld_v    xtx+16,v3

		nop
       	and	#1,ranseed1,r3
        mul	ranmask,r3,>>#0,r3
        lsr	#1,ranseed1
        eor	r3,ranseed1				;run ran# gen 
        and	#1,ranseed2,r3
        mul	ranmask,r3,>>#0,r3
        lsr	#1,ranseed2
        eor	r3,ranseed2				;run ran# gen 

.if 1
	asr	#15,ranseed1,r0
        asr	#15,ranseed2,r1
        add	r0,mtx
        add	r1,mty
.else
    mv_s    ranseed1,mtx
    mv_s    ranseed2,mty
.endif
	
    st_v    v2,xtx
    st_v    v3,xtx+16
    


	st_io	mtx,(ru)
	st_io	mty,(rv)

    ld_p	txcol1,v7
    nop
	mv_s	#$1ffffff,r7
	jsr	pixcalc
;    bits	#23,>>#0,r0
    nop
    ld_p	(uv),v6

	st_p	v7,(uv)

;    st_io	r0,(uvbase)

    jmp skippy,nop

	mv_s	#fadeto,r4    
    mv_s	#$7f,r7
clearit:
	nop
    mv_s	#microtexture,r5
	st_s	#256,rc1

tendred:

		jsr	pixcalc
{
        ld_p	(r5),v6				;get source pixel
    	dec	rc1
}
        ld_p	(r4),v7				;get target pixel

	bra	c1ne,tendred
        st_p	v7,(r5)				;update
	add	#4,r5


skippy:
        pop v2
        pop v1
        pop	v0,rz
        nop
        rts
        nop

pixcalc:

		nop
        sub_sv	v6,v7
		mul_p	r7,v7,>>#30,v7
        rts
        add_sv	v6,v7				;dest pixel
		nop
		nop
        

;;    .include "merlin.i"
;;    .include "comms.a"
;*********
;
; comm bus thangs
;
;*********

	transmit_lock = 12
	transmit_retry = 13
	transmit_failed = 14
	transmit_buffer_full = 15
	receive_disable = 30
	receive_buffer_full = 31


SendVectorTo:

; send a vector to the ID# in r4

	st_s	r4,commctl		; set target to send
	st_v	v0,commxmit		; put the vector on the bus
svtwait:
	ld_s	commctl,r5				; wait for transfer to occur
	nop
	btst	#transmit_failed,r5			; check for transmit failed
	bra		ne,SendVectorTo						; if failed, re-send
	btst	#transmit_buffer_full,r5	; check for buffer empty
	bra		ne,svtwait					; if not empty, keep waiting
	rts
	nop
	nop	


GetVector:

; waits to receive a vector from the comm bus

	ld_s	commctl,r5			; get bus status
	nop
	btst	#receive_buffer_full,r5		; wait for Receive Buffer Full
	bra		eq,GetVector,nop	; not ready if this is 0
	rts					; return
	ld_v	commrecv,v0			; fetch the vector into v0
	nop

