;
; SimpleOLR.s
;
; This does a really simple OLR setup.

	.include	"merlin.i"
    .include    "ol_demo.i"

; some useful constants for the object definitions

    UseSine = $200000
    UseRecip = $100000
    UseSqrt = $400000
    IgnoreSplit = $10000                        

; define th number of rendering MPEs and the screen split height
    
    slice_height = 16
    n_mpes = 3
    base_mpe = 1


        .segment    external_ram
        .align.v
_status:
    .dc.s   0,0,0,0         ;status
    .dc.s   0,0,0,0                             

_routines:

; external copy of the Routines table

    .ds.s   256

recips:
     .include    "_reciplut.i"
sines:
     .include    "_sinelut.i"
sqrts:
     .include    "_rsqrtlut.i"

; default environment, to be placed on rendering MPEs

init_state:

    .dc.s   0,0,0,$ff00             ;mem status, clock etc

; now the screen state

	.dc.s	dmaFlags				;DMA mode
	.dc.s	dmaScreen2			;Address
	.dc.s	$01680000			;X hi:lo clip
	.dc.s	$00ef0000			;Y hi:lo clip

; render zone info - set up according to the definitions above

	.dc.s	0
	.dc.s	slice_height					;Size of render zones
	.dc.s	n_mpes					;Total number of MPEs
	.dc.s	base_mpe					;to keep vect align

; here are the binary images of the functions that we wanna use

binaries:

	.include	"ol_sprite.hex"		;let's have some sprites...
	.include	"ol_warps.hex"		;and one of those warp thingies
	.include	"ol_line.hex"		;and some linedraw...
	.include	"test_ob.hex"		;this is the very basic test object

	.dc.s	$f00baaaa				;EOL

	sprite = 0						;function numbers
	warps = 1
	line = 2
	test = 3
	olr = 3

	.align.v

tile_img:

	.include	"llama.hex"
	.align.v

; here is the OL that we are going to draw

my_ol:

; here is a Sprite object.

	.dc.s	$00b40078			;packed 16bit x:y destination position
	.dc.s	$016800f0			;size X:Y 
	.dc.s	$00000000			;base page offset (16:16, x)
	.dc.s	$00000000			;base page offset (16:16, y)

	.dc.s	$00010a80			;X scale
	.dc.s	$00010a80			;Y scale
	.dc.s	$0041				;Rotate angle
	.dc.s	$3f000000			;Translucency/Mix  (2:30)

    .dc.s   (dmaFlags|$2000)
	.dc.s	external_ram_base			;base page address
	.dc.s	$00808000			;transparent pixel value
	.dc.s	$40c08000			;target value for tint

    .dc.s   0
    .dc.s   0
    .dc.s   0
	.dc.s	(UseSine|UseRecip|sprite)


; here is a Second Order Warp object.

	.dc.s	$00a40070			;packed 16bit x:y destination position
	.dc.s	$00200020			;size X:Y 
	.dc.s	$0000000			;u
	.dc.s	$0000000			;v

	.dc.s	$00001000			;tui
	.dc.s	$00000400			;tvi
	.dc.s	$ffe00004			;tuii/tvii
	.dc.s	$00000000			;tus

    .dc.s   0
	.dc.s	tile_img			;tile source address
	.dc.s	$0001000			;tvs
	.dc.s	$fff30012			;tuss/tvss

    .dc.s   0             
    .dc.s   0
    .dc.s   0
    .dc.s   (UseRecip|warps|$200)	;subtype 2 of Warps

; Object List linedraw object

	.dc.s	$00b40078			;x1:y1 (or centre position, for polyline) 
	.dc.s	$00     			;x2:y2
	.dc.s	$71deca00			;packed colour 1
	.dc.s	$71deca00			;packed colour 2

	.dc.s	$00c000c0			;packed scales x:y (polyline)
	.dc.s	$0ff00008			;Translucency/endpoint radius (radius in low 8 bits)
	.dc.s	$0				;Rotate angle (polyline)
	.dc.s 	llama			;Address of polyline list in external RAM (0 if not a polyline)

    .dc.s   0,0,0,0

    .dc.s	0					;unused (at the moment, future line modes may use)
	.dc.s	0
	.dc.s	0
    .dc.s   (UseRecip|UseSine|UseSqrt|IgnoreSplit|line)


; OLR End object

    .dc.s   0,0,0,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,$800000ff   ;OL terminator

test_ol:

	.dc.s	$51f05a00	;red
	.dc.s	$91223600	;green
	.dc.s	$306ef000	;blue
	.dc.s	$71deca00	;pink

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	0

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	0

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	test		;object type

    .dc.s   0,0,0,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,$800000ff   ;OL terminator

llama:

	.dc.s	$ffc6ffd9,$ffd0ffe0,$fff0ffe3,$fff3fff0			;a llovely llovely llama
	.dc.s	$fff3002a,$fff00030,$fff20035,$fff70037
	.dc.s	$fff50034,$fff30030,$fff6002a,$0035002a
	.dc.s	$00350020,$00300026,$00130025,$000e0018
	.dc.s	$0010fff9,$0014fff0,$0035fff0,$0035ffe4
	.dc.s	$0030ffe9,$0010ffe8,$000affe0,$0000ffd9
	.dc.s	$ffdcffd7,$ffd9ffce,$ffd4ffce,$ffd0ffdb
	.dc.s	$ffc6ffd9,$80000001


	.segment	local_ram
	.align.v

ctr:    .dc.s   10
param0: .dc.s   0
dest:   .dc.s   dmaScreen2                      
last:   .dc.s   0
olbase: .dc.s   0
cframe:  .dc.s   0
    .align.v
buffer: .ds.s   64
routines:   .ds.s   16                 ;used in accessing the Routines table  
dma__cmd:   .dc.s   0,0,0,0,0,0,0,0

	.segment	instruction_ram

goat:


	st_s	#(local_ram_base+4096),sp
    st_s    #$aa,intctl           ;turn off any existing video

    jsr InitBinaries,nop        ;set up the Routines table    
    jsr InitOLREnv,nop    
    jsr SetUpVideo,nop         ;initialise video


loop:

; here is the main loop that draws the screen

    ld_s    ctr,r0          ;run a framecounter
    nop
    add #1,r0
    st_s    r0,ctr
    mv_s    #dmaScreenSize,r0       ;this lot selects one of
    mv_s    #dmaScreen3,r3          ;three drawscreen buffers
    ld_s    dest,r1                 ;this should be inited to a
                                    ;valid screen buffer address
    nop
    cmp     r3,r1
    bra     ne,updatedraw
{
    mv_s    r1,r2                   ;save prevFrame (feedback
    add     r0,r1                   ;effects can use it)
}
    st_s    r2,last                 ;save prev frame
    mv_s    #dmaScreen1,r1          ;reset buffer base
updatedraw:
    st_s    r1,dest                 ;set current drawframe address
    ld_s    __fieldcount,r0
    nop
    st_s    r0,cframe                ;set current frame #
    jsr drawframe,nop
;	jsr	drawtestframe,nop
    ld_s    dest,r0         ;get address we just wrote to...
    jsr SetVidBase,nop

oneframe:

; wait until at least one frame is passed

    ld_s    __fieldcount,r0
    ld_s    cframe,r1
    nop
    cmp r1,r0
    bra eq,oneframe,nop
    bra loop,nop

drawframe:

    push    v0,rz

; load in the list, massage it a bit

	mv_s	#my_ol,r1
	jsr	dma_read
	mv_s	#buffer,r2
	mv_s	#48,r0
	jsr	dma_finished,nop

; set address of prev frame in the Sprite object,
; to make it do feedback; also, move the warp tile
; origin, using __fieldcount

	ld_s	last,r0
	ld_s	__fieldcount,r1
	st_s	r0,buffer+36
	copy	r1,r2
	ld_s	buffer+128,r3
	bits	#8,>>#0,r2
	bits	#15,>>#0,r3
	lsl	#16,r2
	or	r2,r3
	st_s	r3,buffer+128
	lsl	#8,r1
	st_s	r1,buffer+152
	lsl	#5,r1
	st_s	r1,buffer+72
	lsl	#1,r1
	st_s	r1,buffer+76

;write the list back out

	mv_s	#my_ol,r1
	jsr	dma_write
	mv_s	#buffer,r2
	mv_s	#48,r0
	jsr	dma_finished,nop

; draw a raw OLR list.

;    st_s    #0,param0       ;zero means list mode
    mv_s    #my_ol,r0 	;list to draw
    st_s    r0,olbase       ;base of the OL
;    mv_s    #test,r0        ;run the OL renderer (can be any function that contains OLR stub)
    jsr LoadRunOLR,nop         
    jsr WaitMPEs,nop
    pop v0,rz
    nop
    rts t,nop

drawtestframe:

	push	v0,rz
    st_s    #0,param0       ;zero means list mode
    mv_s    #test_ol,r0 	;list to draw
    st_s    r0,olbase       ;base of the OL
    mv_s    #test,r0        ;run the OL renderer (can be any function that contains OLR stub)
    jsr LoadRunOLR,nop         
    jsr WaitMPEs,nop
    pop v0,rz
    nop
    rts t,nop



    .include    "video.def"
    .include    "olr.s"
    .include    "video.s"
    .include    "comms.s"
    .include    "dma.s"    