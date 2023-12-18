
; ol_warps.s
;
; an Object that does warps and other useful Thangs.


	.include	"merlin.i"
    .include    "ol_demo.i"

    .include    "ol_render.s"


    .segment    local_ram

test_dma = SineLUT
microtexture = test_dma+512
mtx2 = microtexture+1024


n_mpes = 3              ;the total number of MPEs to use
slice_height = 16       ;size of screen slice allocated
                        ;to each MPE


    .origin mtx2+1024

xtx:
callme:

; microtexture frob-params

    .dc.s   $a3000000          ;This is the mask
    .dc.s	$83659300		    ;2 seeds
    .dc.s   $58255973
    .dc.s   0                           ;X

    .dc.s   0                           ;Y
txcol1:    .dc.s   $ff389500                   ;colour1
fadeto:    .dc.s   $51f0da00            ;fade to this
speed1: .dc.s   0                   ;top layer blend speed

speed2: .dc.s   0                   ;bottom layer fade speed
    .dc.s   0
    .dc.s   0
    .dc.s   0


colour1:	.dc.s	$ff00ff00
colour2: 	.dc.s	$80ff8000
xpos:		.dc.s	-($4000*180)
ypos:		.dc.s	-($4000*120)

xoff:		.dc.s	$39999
yoff:		.dc.s	$43333
xinc:		.dc.s	$ae00
yinc:		.dc.s	$cbaa

xoff2:		.dc.s	0
yoff2:		.dc.s	0
xinc2:		.dc.s	$2200
yinc2:		.dc.s	$3c00
xpos2:		.dc.s	-($4000*180)
ypos2:		.dc.s	-($4000*120)

phase1:		.dc.s	0
ctr2:   .dc.s   0
black:  .dc.s   $10808000
cippy:  .dc.s   0
    .align.v

;ctr:    .dc.s   0
;mpenum: .dc.s   0

    .align.v

params:
;    .include    "warp_params.hex"
    .ds.s   20

pos = params
iu = params+16
iu2 = params+32
su = params+48
su2 = params+64



_su:    .dc.s   0
_sv:    .dc.s   $1000
_ssu:    .dc.s   0
_ssv:    .dc.s   $10

_su2:    .dc.s   0
_sv2:    .dc.s   $1000
_ssu2:    .dc.s   0
_ssv2:    .dc.s   $10


_tu:  .dc.s   0
_tv:  .dc.s   0
_tu2: .dc.s   0
_tv2: .dc.s   0

buffnum:    .dc.s   0

pixgens:

    .dc.s   pixgen0
    .dc.s   pixgen1
    .dc.s   pixgen2
    .dc.s   pixgen3

subtypes:

    .dc.s   stdwarp
    .dc.s   blurblock
    .dc.s   smallwarp
    .dc.s   clearblock
    .dc.s   charmap
    .dc.s   smallwarp2
    

scrnx = r4
scrny = r5
dma_size = r6
xcount = r7


	pixel0 = v0
    pixel = v0      ;for compatibility with old warp stuff
    pixel1 = v1
	pixel2 = v2		;these can all be used for holding pixels or whatever
	pixel3 = v3
    pixel4 = v4
    pixel5 = v5


    tu = r24
    tv = r25
    tu2 = r26
    tv2 = r27
    tui  = r28
    tvi = r29
    tuii = r30
    tvii = r31


    
    scrx = r20
    scry = r21
    
	bufaddr = r4
    temp = r7
    

    tui2  = r20
    tvi2 = r21
    tuii2 = r22
    tvii2 = r23
       


    .segment instruction_ram

warp2o:

    push    v0,rz

	ld_s	memstat,r4			;get memory status
	nop
    bclr    #2,r4               ;we smash local math tables
    bclr    #1,r0
    st_s    r4,memstat





    ld_s    object+60,r0        ;get type
    nop

    bits    #7,>>#8,r0          ;extract subtype
    lsl #2,r0
    mv_s    #subtypes,r1
    add r1,r0
    ld_s    (r0),r0
    nop
    jmp (r0),nop
    
blurblock:

; do a blurfield segment.


    jsr clip_prep,nop
    bra eq,fuck_off
	mv_s	#$10400040,r2			;Width = cacheSize; use ch_norm; pixmap 4	
	st_s	r2,linpixctl            ;only need linear-addressing...                             
    st_s    r15,rc0              ;set number of lines to do
    copy    r13,r10      ;Y position

    ld_s    object+8,r28 ;source-offsets
    nop
    lsl #16,r28,r29
    lsr #16,r28
    lsr #16,r29         ;X-offset is in r28, Y-offset in r29

blurf_outer:

    mv_s    r14,r8     ;screen width
    mv_s    r12,r9       ;X position
    push    v3

blurf_inner:

    mv_s    #64,r11
    sub r11,r8
    bra ge,blurf1,nop
    add r8,r11

blurf1:

; DMA in a slice of the dest screen

    mv_s    #dmaFlags,r0
    bset    #13,r0          ;set READ

    ld_s    object+36,r1
    add r28,r9,r2           ;xpos
    lsl #16,r11,r3          ;size
    or  r3,r2
    add r29,r10,r3          ;ypos
    bset    #16,r3          ;size=1
    st_v    v0,dma__cmd     ;setup at dma_cmd
    mv_s    #microtexture,r0    ;where to load to
    st_s    r0,dma__cmd+16
    st_s    #dma__cmd,mdmacptr  ;launch
    jsr dma_finished,nop

; scale the pixels in the slice towards the desired value

    mv_s    #microtexture,r13   ;where the pixels are
    ld_p    object+44,v4        ;dest colour            
    ld_s    object+28,r12       ;scale factor
    st_s    r11,rc1             ;set size
    
scalepix:

    ld_p    (r13),v5            ;get pixel
    add #4,r13                  ;move ptr
scp:

    sub_p  v4,v5
{
    mul_p  r12,v5,>>#14,v5
    dec rc1    
    sub #4,r13,r14
}
    bra c1ne,scp
{
    ld_p    (r13),v5
    add_p v4,v5,v6       
}
{
    st_p   v6,(r14)
    add #4,r13
}    

; write out the shaded pixels

    mv_s    #dmaFlags,r0
    ld_s    dest,r1
    copy    r9,r2           ;xpos
    lsl #16,r11,r3          ;size
    or  r3,r2
    copy    r10,r3          ;ypos
    bset    #16,r3          ;size=1
    st_v    v0,dma__cmd     ;setup at dma_cmd
    mv_s    #microtexture,r0    ;where to load to
    st_s    r0,dma__cmd+16
    st_s    #dma__cmd,mdmacptr  ;launch
    jsr dma_finished,nop

; loop around for X

    cmp #0,r8       ;check size
    bra gt,blurf_inner
    add r11,r9      ;move x
    nop

; loop around for Y

    pop v3
    dec rc0
    bra c0ne,blurf_outer
    add #1,r10
    nop
    
; done

    pop v0,rz
    nop
    rts t,nop        

clearblock:

; Clear a block of screen to the value passed in (Object+8)
; Clear by 8x8 blocks where possible.
;
; Now extended to allow use of a chain of rectangles.

    ld_s    object+16,r4        ;this is nonzero for a rect-chain.
    nop
    cmp #0,r4
    bra eq,go_rect,nop          ;zero so do nowt.
nxt_block:
    copy    r4,r1
    jsr dma_read
    mv_s    #4,r0
    mv_s    #object,r2          ;read vect from external list
    jsr dma_finished,nop
    add #16,r4                  ;inc this ptr
;    st_s    r4,object+16

;    ld_v    object,v0
;    ld_s    object,r31
;    mv_s    #31,r31

    mv_s    #$80000000,r5       ;this means end
    ld_s    object,r0           ;get position
    nop
    cmp r5,r0
    bra eq,fuck_off,nop             ;done if true

go_rect:    

    push    v1

    jsr clip_prep,nop
    bra eq,nxt_rect
    mv_s    #microtexture,r5    ;Address of command buffer (gonna multibuffer the commands)
    mv_s    #(dmaFlags|$8000000),r0    ;DMA flags for the screentype, OR Direct (bit 27).
    ld_s    object+8,r4     ;Pick up the required colour.
    ld_s    dest,r1         ;set dest screenbase
    sub r6,r6               ;command buffer #

clr_yloop:

    mv_s    #8,r3           ;Default Y size.
    sub r3,r15              ;Dec total Y-size
    bra ge,clr_y1,nop
    add r15,r3              ;Correct for last iteration
clr_y1:
    push    v3              ;save size/pos info
    lsl #16,r3              ;move Ysize to high 16 bits
    or  r13,r3              ;or in Ypos
    
clr_xloop:

{     
    mv_s    #8,r2           ;Default X-size.    
    lsl #5,r6,r7            ;buffer # times 32
}
    sub r2,r14              ;dec x-size
{
    bra ge,clr_x1
    add #1,r6               ;inc multi buffer ptr
}
    and #7,r6               ;use 8x buffers
    add r5,r7               ;add base of buffers
    add r14,r2              ;correct X for last iteration
clr_x1:

    lsl #16,r2              ;X size to hi 16 bits
    or  r12,r2              ;combine with X position
{
    st_v    v0,(r7)         ;setup the DMA
    add #16,r7
}            
{
    st_s    r4,(r7)
    sub #16,r7
}
{
    st_s    r7,mdmacptr     ;launch the DMA
    add #8,r12              ;inc the xpos too
}    

wdmaa:

    ld_s    mdmactl,r20
    nop
    btst    #4,r20
    bra ne,wdmaa,nop        ;wait for DMA ready

    cmp #0,r14              ;check for Xloop done
    bra gt,clr_xloop,nop
    
    pop v3
    nop
    cmp #0,r15              ;check for Yloop done
    bra gt,clr_yloop
    add #8,r13              ;inc ypos also
    nop

nxt_rect:

    pop v1
    nop
    cmp #0,r4
    bra ne,nxt_block,nop        ;loop if it's a rect-chain.


; done

    pop v0,rz
    nop
    rts t,nop      
    
charmap:

; do a simple character-mapped text plane

    bg_charcol = r18
    fg_charcol = r19
    char_xpitch = r20       ; # of 8x8 chars per line
    char_offset = r21       ; offset from char_base
    char_base = r22         ; base of character table
    char_gen = r23          ; base of character images

    y_frac = r24            ; Y fractional offset    
    y_size = r25            ; Y size
    buf_pos = r26           ; where the char gets drawn...
    yfs = r27

    jsr clip_prep,nop
    bra eq,fuck_off
    ld_v    object+16,v5    ;  charmap addresses, pitch, and suchlike
    nop
    copy    char_gen,r1     ;external addy of the chargen
    jsr dma_read
    mv_s    #256,r0         ;load char set 
    mv_s    #mtx2,r2
    jsr dma_finished,nop

{
    mv_s    char_base,r1
    add #64,char_base    ;load colour table
}
    jsr dma_read
    mv_s    #16,r0
    mv_s    #microtexture+768,r2
    jsr dma_finished,nop

    mv_s    #microtexture,r5    ;Address of command buffer (gonna multibuffer the commands)
    mv_s    #dmaFlags,r0    ;DMA flags for the screentype, OR Direct (bit 27).
    ld_s    object+8,bg_charcol     ;Pick up the BG colour.
    ld_s    object+12,fg_charcol    ;get FG colour
    ld_s    dest,r1         ;set dest screenbase
    sub r6,r6               ;command buffer #

    mv_s    #mtx2,char_gen

    ld_s    object,r29      ;get original X and Y position.
    nop
    lsr #16,r29,r28         ;extract int xpos
    bits    #15,>>#0,r29    ;int ypos

    sub r29,r13,yfs    
    lsr #3,yfs,y_size
    bits    #2,>>#0,yfs
    mul char_xpitch,y_size,>>#0,y_size
    nop
    add y_size,char_base    ;get correct line of display!

    copy    r29,yfs

char_yloop:

; load the currently indicated lline of text

    push    v0
    mv_s    #microtexture+832,r2    ;buffer here
{
    jsr dma_read
}
{
    mv_s    char_base,r1            ;from here
    add char_xpitch,char_base       ;move base by pitch...
}
    lsr #1,char_xpitch,r0        

    jsr dma_finished,nop
    pop v0
   

    sub yfs,r13,y_frac    
    and #7,y_frac
    sub y_frac,#8,y_size            ;this is the y-size. 
    copy    y_size,r3
    sub r3,r15              ;Dec total Y-size
    bra ge,char_y1,nop
    add r15,r3              ;Correct for last iteration
char_y1:
    push    v3              ;save size/pos info
    push    v5              ;save char position info
    lsl #16,r3              ;move Ysize to high 16 bits
    or  r13,r3              ;or in Ypos
    mv_s    #microtexture+832,char_base
    
char_xloop:

; generate an 8x8 character at <mtx2>

    mv_s    #microtexture+256,buf_pos       ;gonna build the chardef here
chxl:
    lsl #5,y_frac,r9                        ;offset     
    add r9,buf_pos                          ;sorted start of buffer
    copy    buf_pos,r8                      ;make working copy
    add char_base,char_offset,r9            ;position of character byte in char table
    ld_b    (r9),r9                        ;get charcode
    add #1,char_offset                      ;point to next xhar
    btst    #31,r9          ;bits 128+ are attrib codes
    bra eq,n_attrib,nop
    lsr #28,r9,r10          ;get bg bits
    bits    #3,>>#24,r9     ;extract fg bits
    bits    #2,>>#0,r10
    lsl #2,r9
    lsl #2,r10
    mv_s    #microtexture+768,r11
    add r11,r9
    add r11,r10
    bra chxl    
    ld_s    (r9),fg_charcol
    ld_s    (r10),bg_charcol
n_attrib:
    lsr #21,r9              ;make char into an offset into the chargen
    add y_frac,r9           ;now points to correct byte within chardef
    add char_gen,r9         ;now pointing into the chargen.
    st_s    y_size,rc1    
genrow:

    ld_b    (r9),r10        ;get bit pattern
    add #1,r9               ;point to next one
{
    st_s    #8,rc0          ;no. pixels to generate.
    lsl #1,r10              ;bit 31 into curry...
    dec rc1
}
genbits:
 
    bra cc,sbac                 ;generate the char bitmap

    st_s    bg_charcol,(r8)
    dec rc0
    st_s    fg_charcol,(r8)
sbac:
    bra c0ne,genbits
    add #4,r8
    lsl #1,r10    
    bra c1ne,genrow,nop

; char is now ready, so write it out...
    

{     
    mv_s    #8,r2           ;Default X-size.    
    lsl #5,r6,r7            ;buffer # times 32
}
    sub r2,r14              ;dec x-size
{
    bra ge,char_x1
    add #1,r6               ;inc multi buffer ptr
}
    and #3,r6               ;use 8x buffers
    add r5,r7               ;add base of buffers
    add r14,r2              ;correct X for last iteration
char_x1:

    lsl #16,r2              ;X size to hi 16 bits
    or  r12,r2              ;combine with X position
{
    st_v    v0,(r7)         ;setup the DMA
    add #16,r7
}            
{
    st_s    buf_pos,(r7)
    sub #16,r7
}
{
    st_s    r7,mdmacptr     ;launch the DMA
    add #8,r12              ;inc the xpos too
}    

wdmaach:

    ld_s    mdmactl,r31
    nop
;    btst    #4,r20
    bits    #4,>>#0,r31
    bra ne,wdmaach,nop        ;wait for DMA ready

    cmp #0,r14              ;check for Xloop done
    bra gt,char_xloop,nop
    
    pop v5
    pop v3
    nop
    cmp #0,r15              ;check for Yloop done
    bra gt,char_yloop
    add y_size,r13              ;inc ypos also
    nop

; done

    pop v0,rz
    nop
    rts t,nop 
        
            
stdwarp:    

    jsr clip_prep,nop
    bra eq,fuck_off
    jsr setup,nop
	ld_s	memstat,r4			;get memory status
	nop
    bclr    #2,r4               ;we smash local math tables
    bclr    #1,r4
    bclr    #0,r4
    st_s    r4,memstat

    ld_s    object+40,r1
    nop
    cmp #0,r1
    jsr ne,dma_read               
    mv_s    #256,r0             ;get source tile
    mv_s    #microtexture,r2
    jsr dma_finished,nop

    ld_s    object+44,r1
    nop
    cmp #0,r1
    jsr ne,dma_read               
    mv_s    #256,r0             ;get source tile
    mv_s    #mtx2,r2
    jsr dma_finished,nop


    st_s    #0,buffnum          ;zero the buffer

; now render the strip of plasma defined by the yclip-params 
; load up the warp_params




    ld_s    object+48,r1        ;external params passed in by here
    jsr dma_read
    mv_s    #20,r0
    mv_s    #params,r2
    jsr dma_finished,nop
    
    
     
; copy stuff to temp storage

    ld_v    su,v0
    ld_v    su2,v1
    st_v    v0,_su
    ld_v    pos,v0
    st_v    v1,_su2
    st_v    v0,_tu


    ld_s    object+4,r0
    nop
    bits    #14,>>#1,r0
    neg r0
    jsr recip
{
;    copy    r0,scry    
    mul r0,r0,>>#0,r0
}    
    sub r1,r1

    sub #28,r1
    ls  r1,r0
    st_s    r0,cippy    




    st_s    r15,rc0     ;set Y size

    ld_v    _tu,v6                ;get uv for both layers
    nop
;    ld_s    mpenum,r0
;    nop
  
zz:
    sub #1,r8
    bra le,ygo,nop
yl:
    push    v2
    jsr y_update,nop            ;advance texture pointers due to Y clip
    bra zz
    pop v2
    nop

ygo:    

    mv_s r13,scrny          ;Y position, passed in from clip

yloop:

    push    v3          ;save position/size info
    push    v5
    push    v6                  ;preserve uv across scanline
    ld_v    iu,v7           ;get incs for first bilerp
    ld_v    iu2,v5          ;get incs for second bilerp
    nop
	mv_s    r12,scrnx
	mv_s	#64,dma_size
	mv_s	r14,xcount

    ld_s    object+4,r0
    nop
    bits    #14,>>#17,r0
    neg r0
;    copy    r0,scrx



;    mul scry,scry,>>#0,scry    ;y2
;    nop
;    copy    scrx,r23
        
;    mul r23,r23,>>#0,r23 

xloop:

dmaw2:	
	ld_s	mdmactl,r0
	nop
	bits	#4,>>#0,r0
	bra	ne,dmaw2,nop	

{
    mv_s    #pixgens,r9
	sub	dma_size,xcount
}    
{
    ld_s object+52,r8    
	bra	gt,notend,nop
}
	add	xcount,dma_size
notend:
    bits    #7,>>#0,r8
{
	st_s	dma_size,rc1
    lsl #2,r8
}    

; read source

    jsr dma_it
	mv_s	#dmaFlags,r0
    bset    #13,r0
    jsr dma_finished,nop


; save loop reggies

{
    add r8,r9
	push	v1
}

; call the pixel gen

    ld_s    (r9),r0
    nop
	jsr	(r0),nop

; retrieve loop reggies

	pop	v1


; wait DMA-idle

;    jsr dma_wait,nop

; build DMA-command

    jsr dma_it
	mv_s	#dmaFlags,r0
    nop


    ld_s    buffnum,r1
    nop
    add #1,r1
    st_s    r1,buffnum


	add	#64,scrnx
	cmp	#0,xcount
	bra	gt,xloop,nop

    pop v6
    pop v5
    pop v3

    jsr y_update,nop
    dec rc0
	bra	c0ne,yloop,nop

fuck_off:

    pop v0,rz
    nop
    rts
	nop
	nop

dma_it:

   	mv_s	#dma__cmd,r2
	ld_s	dest,r1
	st_s	r0,(r2)
	add	#4,r2
	st_s	r1,(r2)
	add	#4,r2
	mv_s	scrnx,r0
    lsl #16,dma_size,r1
;	mv_s	#$400000,r1
	or	r1,r0
	st_s	r0,(r2)
	add	#4,r2
	mv_s	scrny,r0
	or	#1,<>#-16,r0
	st_s	r0,(r2)
	mv_s	#test_dma,r0

    ld_s    buffnum,r1
    nop
;    sub #1,r1
    bits    #0,>>#0,r1
    lsl #8,r1
    add r1,r0
    
	add	#4,r2
	st_s	r0,(r2)
    rts
	sub	#16,r2
	st_s	r2,mdmacptr

    
y_update:

    ld_v    _su2,v0           ;steps for second layer
;    add    #1,scry
    nop
    asr #8,r0,r8
    asr #8,r1,r9
{
    add r8,tu2
    addm r9,tv2,tv2
}
{
    add r2,r0
    addm r3,r1,r1
}
    st_v    v0,_su2    
{
    ld_v    _su,v0           ;steps for first layer
}
    add #1,scrny
    asr #8,r0,r8
    asr #8,r1,r9

{
    add r8,tu
    addm r9,tv,tv
    rts
}
{
    add r2,r0
    addm r3,r1,r1
}
    st_v    v0,_su    

smallwarp2:

    jsr clip_prep,nop
    bra eq,fuck_off
    bra smallw
    mv_s    #unfiltered_warp,r0
    st_s    r0,callme

smallwarp:

    tus = r4
    tvs = r5
    tuss = r6
    tvss = r7
    tuis = r0
    tvis = r1

; a small warp that can be held entirely in cache.
; (size=16x16).  Params for warp - size and increments
; are assumed to be already set up in the object data structure.

    jsr clip_prep,nop
    bra eq,fuck_off
    mv_s    #bilerp_warp,r0
    st_s    r0,callme           ;pixgen routine for this variant
smallw:
    ld_s    object+36,r1        ;external address of sourcetile
    jsr dma_read
    mv_s    #256,r0             ;16x16 object
    mv_s    #microtexture,r2    ;load buffer address
    
    jsr setup,nop               ;setup as for warp
    ld_s    object+8,tu         ;get init texture position
    ld_s    object+12,tv
    ld_s    object+16,tui       ;get inc and step
    ld_s    object+20,tvi
    ld_s    object+24,tuii
    
    ld_s    object+28,tus
    ld_s    object+40,tvs        ;(this is step)
    ld_s    object+44,tuss
    ld_s    object+48,tuis
    



    lsl #16,tuii,tvii
    asr #16,tuii
    asr #16,tvii

    lsl #16,tuss,tvss
    asr #16,tvss
    asr #16,tuss

    lsl #16,tuis,tvis
    asr #16,tuis
    asr #16,tvis


;    sub tvi,tvi
;    sub tvii,tvii
;    mv_s    #-28,tvii
;    sub tuii,tuii
    
; Preliminary clipping has been done - use the results passed
; in to update tu and tv to their correct starting positions

    cmp #0,r8
    bra eq,nyu,nop

uyl:

{
    sub #1,r8
    addm    tus,tu
}    
{
    bra ne,uyl
    add tvs,tv
}
{
    add tuss,tus
    addm    tuis,tui
}    
{
    add tvss,tvs     
    addm    tvis,tvi
}    

nyu:



    cmp #0,r10
    bra eq,nxu,nop

uxl:
{
    sub #1,r10
    addm    tui,tu
}    
{
    bra ne,uxl
    add tvi,tv
}
    add tuii,tui
    add tvii,tvi    

nxu:



    push    v1          ;save y params

;    mul tui,r10,>>#0,r10        ;amount of left clip
;    mul r4,r8,>>#0,r8           ;amount of top clip
;    add r10,tu
	ld_s	memstat,r4			;get memory status
    nop
;    add r8,tv                   ;update due to clip            
    bclr    #2,r4               ;we smash local math tables
    bclr    #1,r4
    bclr    #0,r4
    st_s    r4,memstat          ;update memstat
    st_s    r15,rc0             ;set Y size
    mv_s    r12,scrnx
    mv_s    r13,scrny
    mv_s    r14,xcount          ;init sundry other Thangs
    mv_s    #64,dma_size
    st_s    #0,buffnum


; ensure source tile has loaded

    jsr dma_finished,nop
    
ylp:

    push    v6
    push    v7
    push    v1
            
xl:

    jsr dma_wait,nop

; generate some pixels

	sub	dma_size,xcount
	bra	gt,notend2,nop
	add	xcount,dma_size
notend2:
	st_s	dma_size,rc1
    push    v1
        
; generate pixels into the buffer

	mv_s	#test_dma,bufaddr
    ld_s    buffnum,r5
    ld_s    callme,r0
    bits    #0,>>#0,r5
    lsl #8,r5
    add r5,bufaddr
    st_s    tu,ru
    st_s    tv,rv
    st_s    tu,rx
    jsr (r0)
    st_s    tv,ry
    mv_s    #4,r5


    pop v1          ;restore xy, dmasize etc
    jsr dma_it
	mv_s	#dmaFlags,r0
    nop

    ld_s    buffnum,r1
    nop
    add #1,r1
    st_s    r1,buffnum

	add	#64,scrnx
	cmp	#0,xcount
	bra	gt,xl,nop

    pop v1
    pop v7
    pop v6


    ld_s    object+48,tuis
    nop
    lsl #16,tuis,tvis
    asr #16,tuis
    asr #16,tvis
    add tuis,tui
    add tvis,tvi  


    pop v0          ;get back Y params
    add #1,scrny
{
    add r1,tv
    addm    r0,tu,tu
}    
{
    dec rc0
    add r2,r0
}
	bra	c0ne,ylp
    add r3,r1
    push    v0      
    
    pop v0
    bra fuck_off,nop


bilerp_warp:

{
 	ld_p	(uv),pixel				;Grab a pixel from the source
	addr	#1,ru					;go to next horiz pixel
	add	tui,tu
}
{
	ld_p	(uv),pixel2				;Get a second pixel
	addr	#1,rv					;go to next vert pixel
}
{
	ld_p	(uv),pixel4				;get a third pixel
	addr	#-1,ru					;go to prev horizontal pixel
	sub	#4,bufaddr				;point at start of buffer -4
}
{
	ld_p	(uv),pixel3				;get a fourth pixel
	addr	#-1,rv					;go back to original pixel
	sub_sv	pixel,pixel2			;b=b-a
}	
	addr	#1,ry

fbilerp:

; Here is the bilerp part.

{
	mv_v	pixel,pixel5			;save a copy of first pixel, freeing up pixel 1.
	mul_p	ru,pixel2,>>#14,pixel2	;scale according to fractional part of ru
	sub_sv	pixel3,pixel4			;make vector between second 2 pixels
	addr	tvi,ry					;Point ry to next y
}
{
	st_s	tu,(ru)					;Can now update ru, finished multiplying with it.
	mul_p	ru,pixel4,>>#14,pixel4	;scale according to fractional part of ru
	sub_sv	pixel3,pixel
	addr	tui,rx					;(XY) now points at next pixel 1
}
{
	ld_p	(xy),pixel3				;Loading next pixel 1.
	addr	#-1,ry					;POinting to next pixel 3.
	add_sv	pixel2,pixel			;get first intermediate result
	dec	rc1							;Decrementing the loop counter.
}
{
	ld_p	(xy),pixel				;getting next pixel 3.
	sub_sv	pixel,pixel4			;get vector to final value
	addm	r5,bufaddr,bufaddr      ;r5 has const 4
	addr	#1,rx					;Working over to point to pixel 2.
}
{
	mul_p	rv,pixel4,>>#14,pixel4	;scale with fractional part of rv
	add_sv	pixel2,pixel5			;add pix2 to the copy of pix1
	addr	tvi,rv
}
{
	ld_p	(xy),pixel2				;load up next pixel2
	addr	#1,ry					;point to next pixel 4
	bra	c1ne,fbilerp					;start the branch
	add	tuii,tui						;Incrementing the x increment
}
{
    rts
	ld_p	(xy),pixel4				;get next pixel4
	add_sv	pixel4,pixel5			;make final pixel value
	addr	#-1,rx					;start putting these right	
	addm	tvii,tvi,tvi				;do Y-inc-inc
}
{
	st_p	pixel5,(bufaddr)		;Deposit the pixel in the dest buffer
	sub_sv	pixel,pixel2			;b=b-a
	addm	tui,tu,tu						;do x inc
}
    ld_s    rv,tv

unfiltered_warp:


{
    ld_p    (uv),pixel    
    addr    tui,ru
}    
    dec rc1
    mv_s    #$ff000000,r3           ;make z nonzero

notbilerp:

; Here is the bilerp part.

{  
    mv_v    pixel,pixel2
	bra	c1ne,notbilerp					;start the branch
	dec	rc1							;Decrementing the loop counter.
	addm	tuii,tui,tui						;Incrementing the x increment
	addr	tvi,rv					;(XY) now points at next pixel 1
}
{
	ld_p	(uv),pixel				;get next pixel4
	addr	tui,ru					;Point ry to next y
}
{
    st_pz    pixel2,(bufaddr)
    add #4,bufaddr
	addm	tvii,tvi,tvi				;do Y-inc-inc
}

{
    ld_s    ru,tu    
    rts
    sub tuii,tui
}
    ld_s    rv,tv
    sub tui,tu

        

pixgen:

;	.include	"rings.ptx"
;	.include	"warp1.ptx"
;	.include	"warp2.ptx"

;    .include    "foo7.ptx"
    
setup:

; initialise linpixctl etc...

	mv_s	#$10400020,r2			;Width = cacheSize; use ch_norm; pixmap 4	
	st_s	r2,linpixctl
    mv_s    #$104cc010,r2
    st_s    r2,uvctl
    st_s    r2,xyctl
    mv_s    #microtexture,r2
	rts 
    st_s    r2,uvbase
    st_s    r2,xybase

clip_prep:

; prepare current object for clip/draw

; load up Y size; return immediately if the object is outside of
; the current zone

    ld_s    object,r0           ;get position
    ld_s    object+4,r2         ;get size
    ld_s    dest_screen+12,r4   ;get Y clip
    ld_s    dest_screen+8,r6    ;get X clip
    lsl #16,r0,r1
    asr #16,r0
    asr #16,r1                  ;unpack XY
    lsl #16,r2,r3
    lsr #16,r2
    lsr #16,r3                  ;unpack size X and Y
    lsr #16,r4,r5
    bits    #15,>>#0,r4
    lsr #16,r6,r7
    bits    #15,>>#0,r6          ;unpack clip window Thangs
    add r1,r3           ;r3 now has end ypos    
    add r0,r2           ;r2 now has end xpos
    sub #1,r3
    sub #1,r2

    cmp r1,r5           ;check start ypos against far edge of clip port
    bra lt,clipfail     ;object is wholly outside the port
    cmp r3,r4           ;check end ypos against near edge
    bra gt,clipfail     ;again it is outside   

; some part of the object is in the viewport (Y)...

    cmp r0,r7           ;same checks and rejections for X
    bra lt,clipfail
    cmp r2,r6
    bra gt,clipfail
    
; there is definitely some part of the object in the viewport.
; calculate the amount of clip

    sub r4,r1,r8        ;check for overhang at near edge
    bra lt,clp1
    abs r8              ;return either the overhang extent, or 0
    nop
    sub r8,r8
clp1:
    sub r3,r5,r9        ;check for overhang at far edge
    bra lt,clp2
    abs r9              ;return 0 or amount, as before
    nop
    sub r9,r9
clp2:
    sub r6,r0,r10       ;same checks, for X
    bra lt,clp3
    abs r10
    nop
    sub r10,r10
clp3:
    sub r2,r7,r11
    bra lt,clp4
    abs r11
    nop
    sub r11,r11
clp4:
    sub r1,r3
    sub r0,r2           ;restore size
    add #1,r3
    add #1,r2
    add r10,r0          ;update position and size by the clip amounts
    sub r10,r2
    sub r11,r2
    add r8,r1
    sub r8,r3
    sub r9,r3                
    mv_v    v0,v3       ;move v0 somewhere it won't get banged
    rts
    mv_s    #1,r1
    copy    r1,r0       ;set flags for success

clipfail:

    rts                 ;set flags for failure
    sub r0,r0
    nop

    
; now we are ready to draw this object.
; Passed in:
;   r8 = Y top clip
;   r9 = Y bottom clip
;   r10 = X left clip
;   r11 = X right clip
;   r12 = X pos
;   r13 = Y pos
;   r14 = X size
;   r15 = Y size         


pixgen0:

    .include    "foo5.ptx"          
pixgen1:

    .include    "warp1trans.ptx" 
    
pixgen2:

    .include    "warp1circ.ptx"       


pixgen3:

    .include    "warp2.ptx"         ;procedural texture code for doublewarp

    .include    "recip.s"


;    .include "merlin.i"
;    .include "scrndefs.i"
;    .include "comms.s"
;    .include "dma.s"
