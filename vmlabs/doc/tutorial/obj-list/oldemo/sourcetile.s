
; sourcetile.s
;
; manipulate sourcetiles for FX that use 'em

	.include	"merlin.i"
    .include    "ol_demo.i"



    .segment    local_ram
    
_base = local_ram_base

ctr = _base
mpenum = ctr+4
logical_mpenum = mpenum+4
memstat = logical_mpenum+4
dest_screen = _base+16
dest = dest_screen+4
rzinf = dest_screen+16
tempcol = rzinf+12
object = rzinf+16
dma__cmd = object+64
RecipLUT = dma__cmd+128


;RecipLUT = object+64
SineLUT = RecipLUT+512
RSqrtLUT = SineLUT+1024

;dma__cmd = RecipLUT
microtexture = RecipLUT
;microtexture = test_dma+512


n_mpes = 3              ;the total number of MPEs to use
slice_height = 16       ;size of screen slice allocated
                        ;to each MPE


    .origin microtexture+1024


params: .ds.s   20
    .align.v
layers: .ds.s   16      ;space for up to 4 layers
mask:   .ds.s   8       ;room for an 8x8 mask to me loaded
nlayers:    .dc.s   0
tileadd:    .dc.s   0
    .align.v
        
passcol:    .dc.s   0
passpos:    .dc.s   0
passmask:   .dc.s   0
passblend:  .dc.s   0


	pixel0 = v0
    pixel1 = v1
	pixel2 = v2		;these can all be used for holding pixels or whatever
	pixel3 = v3
    pixel4 = v4
    pixel5 = v5


    .segment instruction_ram
    .origin $20300000


    st_s    #($20100000+4*1024),sp
    st_s    r2,tileadd      ;address of source tile passed in
    st_s    r0,nlayers
    jsr dma_read            ;r1 passes ext address of the layer block
    lsl #2,r0               ;this is total in longs
    mv_s    #layers,r2
    jsr dma_finished,nop
    

; get MPE-number


;    ld_s    configa,r0
;    nop
;    bits    #4,>>#8,r0
;    st_s    r0,mpenum
;	sub	#1,r0					;this is based on MPEs 1 to 3...
;	st_s	r0,logical_mpenum	;note what we are logically

; set up the render zone information structure
; for the zone size and logical MPE number


    jsr setup,nop
    mv_s    #$ff00,r4
    st_s    r4,memstat

    
no_twiddle:    

    ld_s    tileadd,r1
    nop
    jsr dma_read               
    mv_s    #256,r0             ;get source tile
    mv_s    #microtexture,r2
    jsr dma_finished,nop
    jsr perframe,nop

; write out stuff

    ld_s    tileadd,r1
    jsr dma_write               
    mv_s    #256,r0             ;put source tile
    mv_s    #microtexture,r2
    jsr dma_finished,nop


; flag completion externally (single MPE process)

fin:

    ld_s    configa,r4
    sub r6,r6
    bits    #4,>>#8,r4
    st_s    r6,object
    lsl #2,r4
    mv_s    #status+16,r1
    add r4,r1
    jsr dma_write
    mv_s    #object,r2
    mv_s    #1,r0

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
poo:    nop
    rts t,nop



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

    ld_s    nlayers,r4
    nop
    mv_s    #layers,r5


layerloop:

    ld_v    (r5),v0
    add #16,r5
    st_v    v0,passcol        
    

    
    ld_s    passmask,r1
    jsr dma_read
    mv_s    #8,r0
    mv_s    #mask,r2
    jsr dma_finished,nop    ;load in external 16x16 mono bitmap to use for a "brush"

    mv_s    #microtexture,r2
    st_s    r2,uvbase


    st_s    #16,rc1  ;gonna do 16x16 pattern.
    ld_s    passpos,mtx
    nop
    lsl #16,mtx,mty

	st_s	mtx,ru
	st_s	mty,rv
    
    mv_s    #mask,r0
    ld_s    passblend,r7
    nop
    



lloop:   

    ld_w    (r0),r1     ;get 16 bits of mask
    st_s    #16,rc0
    add #2,r0
        
lloop2:

    btst    #16,r1
    bra eq,no_fx,nop        ;ignore unset bits of mask
            
	jsr	pixcalc
    ld_p	passcol,v7
    ld_p	(uv),v6
	st_p	v7,(uv)

no_fx:

    dec rc0
    bra c0ne,lloop2
    addr    #1,ru
    lsr #1,r1
    
    addr    #1,rv
    dec rc1
    bra c1ne,lloop,nop  

    sub #1,r4
    bra ne,layerloop,nop

skippy:
        pop v2
        pop v1
        pop	v0,rz
        nop
        rts
        nop

pixcalc:

        nop
        sub_p	v6,v7
		mul_p	r7,v7,>>#14,v7
        rts
        add_p	v6,v7				;dest pixel
		nop
		nop

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
  




    .include "merlin.i"
    .include "scrndefs.i"
    .include "comms.s"
    .include "dma.s"
