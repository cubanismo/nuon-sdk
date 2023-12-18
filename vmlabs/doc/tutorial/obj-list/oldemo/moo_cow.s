;
; moo_cow.s
;
; Macro-Object Organizer/Common Object Writer (MOO_COW)
; (anything for a stupidly contrived and beastie oriented
; acronym)

	.include	"merlin.i"
    .include    "ol_demo.i"
	.segment	local_ram

_base   = local_ram_base

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

moo_cmd = RSqrtLUT
moo_stub = RSqrtLUT+512
moo_wave = moo_stub+64
moo_results = moo_wave+16
moo_ranges = moo_results+128

init_proto = moo_cmd
init_proto_vars = init_proto+64
init_cmd = init_proto+768
init_proto_addresses = init_cmd+256
init_list_array = init_proto_addresses+256

colcache = RecipLUT

; collision mode bit names

COCA = 1
_COCA = 0
COPOINT = 0
COBOX = 2
COCIRC = 4
CODBEN = 8
_CODBEN = 3
CODB = $10
_CODB = 4
COLEN = $20
_COLEN = 5
COLA = $40
_COLA = 40


COINF0 = $100
_COINF0 = 8
COINF1 = $200
_COINF1 = 9
COINF2 = $400
_COINF2 = 10
COINF3 = $800
_COINF3 = 11





; events bit names

COLLISION = $100000
_COLLISION = 4+16


	.origin init_list_array+64

last:	.dc.s	0
moo_base:	.dc.s	0
cow_base:	.dc.s	0
joy_x:	.dc.s	0
joy_y:	.dc.s	0
joy_bits:	.dc.s	0
tempword:   .dc.s   0
lctr:	.dc.s	0
ext_data:	.dc.l	0

local_routines:

	.dc.l	bugger_all
	.dc.l	set_prev
	.dc.l	bugger_all
    .dc.l   bugger_all
    .dc.l   bugger_all
    .dc.l   event_brick
    .dc.l   event_ball

wave_types:

	.dc.l	sawtooth_wave
	.dc.l	triangle_wave
	.dc.l	sine_wave	
	.dc.l	cos_wave

boundary_actions:

	.dc.l	nothing
	.dc.l	wrap
	.dc.l	bounce
	.dc.l	max

joybits:

	.dc.b	24,25,0,0
    .dc.b   16,17,18,19

	.align.v

buffer:

	.ds.l	32

object_size = 16		;size of an Object, in longs

ob_type = object+60		;where the Type information lurks


; now comes da stuff to start up, call, and shut down MOO

   .segment instruction_ram

    st_s    #($20100000+4*1024),sp

; get MPE-number


    ld_s    configa,r4
    ld_s    rzinf+12,r5
    bits    #4,>>#8,r4
    st_s    r4,mpenum
    sub r5,r4
	st_s	r4,logical_mpenum	;note what we are logically


	st_s	r0,last
;    st_s    r1,ctr
	st_s	r1,dest				;dest screen passed here
	st_s	r2,cow_base
	st_s	r3,moo_base

;	cmp	#0,r0			;passing r0 zero means: do OL setup
;	bra	eq,ol_setup,nop

; get joystick data
; (this is only placed inside the loop
; to allow the analog joy sim object to
; work).

	jsr	get_stat,nop
    lsl #16,r3,r0
    lsl #24,r3,r1
	st_s	r0,joy_x
	st_s	r1,joy_y
	st_s	r3,joy_bits


	ld_s	memstat,r4			;get memory status
	nop
    bclr    #0,r4               ;boshes reciplut

; get sine table if needed

	btst	#1,r4				;is SineLUT loaded?
	bra	ne,sine_loaded,nop		;if 1, yup
{
	jsr	dma_read				;go load stuff
	mv_s	#256,r0				;256 Longs, specifically
	bset	#1,r7				;flag it has loaded
}
	mv_s	#external_sine,r1	;external addy of sine table
	mv_s	#SineLUT,r2	    	;local sine RAM

sine_loaded:


    bclr	#2,r4
    st_s    r4,memstat

; go moo!

    jsr moo_cow,nop


; flag completion externally (single MPE process)

fin:

    ld_s    mpenum,r4
    sub r6,r6
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
    
	

moo_cow:

; The Glorious Bovine Routine

	push	v0,rz

	moo_ptr = r8
	cow_ptr = r9
	eval_ptr = r10
	result_base = r11
	wave_base = r12
	range_base = r13
	store = r14
	ans = r15
	prev_ans = r16
	pending_op = r17
	set_addr = r18
    coll_cached = r19
    coll_pointer = r20

	ld_s	moo_base,moo_ptr
	ld_s	cow_base,cow_ptr
	sub coll_cached,coll_cached     ;clear collision-cache count
    mv_s    #colcache,coll_pointer  ;point to start of collision cache

mooooo:

; get joystick data

	jsr	get_stat,nop
    lsl #16,r3,r0
    lsl #24,r3,r1
;    asr #24,r0
;    asr #24,r1
	st_s	r0,joy_x
	st_s	r1,joy_y
	st_s	r3,joy_bits

    jsr load_moo,nop

; Now, check for a defined object proto, and if there is one, load it.

	ld_s	moo_stub+24,r1
	nop
	cmp	#0,r1				;Zero here means we are *not* building an Object
	jsr	ne,dma_read			;or else load it into Object
	mv_s	#16,r0
	mv_s	#object,r2
	jsr	dma_finished,nop

noxd:

; okay, now object prototype (if any) and external data (if any)
; are safely loaded....

    push    v5
	jsr	evaluate					;do the funky evaluate thing
	mv_s	#moo_results,result_base	
	nop
    pop v5

;    bra no_collision,nop

; get ready for first-pass collision stuff.

    ld_s    moo_stub+56,r0      ;get collision flags
    ld_s    moo_stub+48,r1
    bits    #7,>>#0,r0
    bits    #15,>>#0,r1
    or  r1,r0
    st_s    r0,moo_stub+56      ;initialise collision info bits
            
    btst    #_COLEN,r0
    bra eq,no_collision         ;no collisions for this object.
    btst    #_COCA,r0           ;check for cache-collect
    bra eq,no_cacheit,nop
    
; add the current object's details to the collision cache

    ld_v    moo_stub+48,v1
    ld_s    object,r1

    bclr    #_COLLISION,r6
    mv_s    moo_ptr,r7
    copy    r1,r4               ;collect collision particulars
    st_v    v1,(coll_pointer)
    bra cached                  ;cached object just hasta do this
    add #16,coll_pointer    
    add #1,coll_cached          ;increase number of cached Thangs

no_cacheit:
                                                    
    copy    coll_cached,r22      ;?any in cache?
    bra eq,no_collision,nop     ;None.
    push    v5                  ;save current cache-pointer.

; Gonna load up my local object details onto v0

    ld_v    moo_stub+48,v0
    sub #16,coll_pointer
    ld_s    object,r0
    
; Now gonna loop doing collision-detect for the # of cached entries.

chk_cache:
    
    jsr collide                 ;this calls the actual collide-routine.
    ld_v    (coll_pointer),v1     ;Collision cache details loaded in v1
    nop
    st_v    v1,(coll_pointer)   ;update this vector, if it changed
    sub #16,coll_pointer
    sub #1,r22                  ;dec counter
    bra gt,chk_cache,nop        ;loop till done     

    pop v5                      ;restore ol' cache pointer

; write back events

    st_s    r2,moo_stub+56      ;wrote back event flags
    nop

no_collision:    


    jsr event_check,nop         ;check events and take action.    
    jsr write_moo_header,nop

cached:

; write back external-data

	ld_s	ext_data,r1
	ld_s	moo_stub+8,r0	;need type field, it has the length
	cmp	#0,r1
	bra	eq,noxdwri			;no external data if 0
	bits	#5,>>#24,r0	;extract length of external data in longs
	bra	eq,noxdwri			;if 0 it was a mistake
	jsr	dma_write		;otherwise write it...
	mv_s	#buffer,r2	;from here.
	nop
    jsr     dma_finished,nop

noxdwri:

; now, call a local routine, depending on the object-type...

    push    v4
    push    v5
	ld_s	moo_stub+8,r0
	jsr	run_routine
	nop
	bits	#7,>>#0,r0
    pop v5
    pop v4

; and finally, write out the object to the List, if appropriate,
; and also any modified external data.

	ld_s	moo_stub+24,r1
	nop
	cmp	#0,r1				;Zero here means we are *not* building an Object
	bra	eq,nobwri,nop
{
	jsr	dma_write		;write if true
	mv_s	cow_ptr,r1
	add	#64,cow_ptr
}
	mv_s	#16,r0
	mv_s	#object,r2
	jsr	dma_finished,nop

nobwri:

gnext:

; check for finished (next = 0)


	ld_s	moo_stub+4,moo_ptr
	nop
	cmp	#0,moo_ptr
	bra	ne,mooooo,nop

; check for anything in the collision-cache

    cmp #0,coll_cached
    bra eq,moo_done,nop

; now, traverse the collision cache, and take action for anything that needs it...

    ld_v    colcache,v0     ;fetch cache entry
    jsr load_moo            ;load moostuff
    copy    r3,moo_ptr
    nop

;nocdb:
    st_s    r2,moo_stub+56  ;set event flags from cache    

    jsr event_check,nop     ;process events
    jsr write_moo_header,nop

moo_done:

; write an end object onto the cow_list

    mv_s    #$ff,r0
    st_s    r0,object+60    ;make it into an End object

    mv_s    #16,r0
    jsr dma_write
    mv_s    cow_ptr,r1
    mv_s    #object,r2
    jsr dma_finished,nop    ;wrote an end object

	pop	v0,rz
	nop
	rts	t,nop

write_moo_header:

; write out the header of an object

    push    v0,rz
	mv_s	#16,r0
	jsr	dma_write
	mv_s	moo_ptr,r1
	mv_s	#moo_stub,r2	;get base of Object
	jsr	dma_finished,nop
    pop v0,rz
    nop
    rts t,nop

load_moo:

; Load in the object at <moo_ptr>
; Okay.  Read from the linked list...

    push    v0,rz
	mv_s	#16,r0
	jsr	dma_read
	mv_s	moo_ptr,r1
	mv_s	#moo_stub,r2	;get base of Object
	jsr	dma_finished,nop

	ld_s	ctr,r1
	ld_s	moo_stub+8,r16	;get length of local params
	st_s	r1,lctr
	ld_s	moo_stub+12,wave_base
	bits	#7,>>#16,r16		;extract length in vects
	lsl	#4,r16					;length in bytes
	copy	r16,r17				;save length for loading the waves
	cmp	#0,wave_base
	bra	ne,waves_nonlocal,nop	;nonzero, waves are elsewhere
	copy	moo_ptr,wave_base	;if zero, waves are here..
	add	#64,wave_base			;plus this offset.

waves_nonlocal:

; wave_base should be correct so locate the ranges..

	ld_s	moo_stub+16,range_base
	add	moo_ptr,r16					;if ranges are local they will be here
	add	#64,r16
	cmp	#0,range_base
	bra	ne,ranges_nonlocal,nop
	copy	r16,range_base
	add	#64,r16

ranges_nonlocal:

; load the ranges

	copy	range_base,r1	
	jsr	dma_read
	mv_s	#moo_ranges,r2
{
	copy	r2,range_base
 	mv_s	#16,r0
}
	jsr	dma_finished,nop

; Load in the wave block, and update it.

	lsr	#2,r17,r0		;Wave block length in longwords
    bra eq,no_waves
	jsr	dma_read
	mv_s	#moo_cmd,r2	;use this as it is not yet used
	copy	wave_base,r1
	jsr	dma_finished,nop

    push    v5
	jsr	update_waves,nop	;update the waves
    pop v5
	
	lsr	#2,r17,r0		;Wave block length in longwords
	jsr	dma_write
	mv_s	#moo_cmd,r2	;use this as it is not yet used
	copy	wave_base,r1
	jsr	dma_finished,nop

no_waves:

; check for a secondary data block, and load it if there is one

	ld_s	moo_stub+8,r0
	nop
	bits	#5,>>#24,r0
	bra	eq,no_block2,nop

; determine if secondary data block is local or remote

	ld_s	moo_stub+28,r1
	nop
	cmp	#0,r1
	bra	ne,l_params,nop		;external
	copy	r16,r1			;otherwise they are after the range-table
	lsl	#2,r0,r2			;convert length to bytes
	add	r2,r16				;and update r16

l_params:

	jsr	dma_read
	st_s	r1,ext_data		;save external data address
	mv_s	#buffer,r2		;load external data to buffer
	jsr	dma_finished,nop		

no_block2:

; range_base is sorted, locate the command...

	ld_s	moo_stub+20,eval_ptr
;	add	#64,r16						;if command is local it's here
	nop
	cmp	#0,eval_ptr
	bra	ne,command_nonlocal,nop
	copy	r16,eval_ptr
command_nonlocal:	

;	ld_s	moo_stub+16,r1	;ranges

	copy	eval_ptr,r1
	jsr	dma_read
	mv_s	#moo_cmd,r2
{
	mv_s	#64,r0
	copy	r2,eval_ptr
}
	jsr	dma_finished,nop
    pop v0,rz
    nop
    rts t,nop



event_check:

; check if an event occurred and take action if it did.

; check Events

    ld_s    moo_stub+56,r2      ;get Events
    ld_s    moo_stub+48,r1      ;get Event Enable
    lsr #16,r2
    lsr #16,r1
    ld_s    moo_stub+36,r0      ;get Event vectors
    and r2,r1                    ;merge events and enable mask
    rts eq                      ;no event happened and is allowed
    bits    #7,>>#8,r0          ;extract event-handler
    nop

; an event happened, r0 falls through to run_routine.


run_routine:

; run a local or external routine. # passed in r0

;    rts t,nop

	push	v0,rz
    bits    #7,>>#0,r0
	btst	#7,r0				;bit 7 set means run external routine.
	bra	ne,run_extern
	bclr	#7,r0
	nop
	mv_s	#local_routines,r1
	lsl	#2,r0
	add	r0,r1
	ld_s	(r1),r0
	nop
	jsr	(r0),nop

	pop	v0,rz
	nop
	rts	t,nop



collide:

; collide a point (in cache/V1) with a box (local/V0)

    push    v2      ;make workspace
{
    push    v3
    asr #16,r0,r8   ;extract local object X
}
    lsl #16,r0,r9
    asr #16,r9      ;extract local Y
    asr #16,r4,r12
    lsl #16,r4,r13
    asr #16,r13     ;extract remote X and Y


    sub r8,r12
    bra lt,ncol
    sub r9,r13
    bra lt,ncol

; extract dimensions

{
    mv_s    r1,r10
    copy    r1,r11
}
    bits    #15,>>#16,r10
    bits    #15,>>#0,r11
    sub r10,r12
    bra gt,ncol
    sub r11,r13
    bra gt,ncol,nop


; point and box collided

; set COLLISION flag in Events, and debounce flag in local objects

    bset    #_COLLISION,r2
    bset    #_COLLISION,r6  ;set Collision events in both Thangs

; blend the objects' infobits

    copy    r2,r10
    copy    r6,r11
    bits    #7,>>#8,r10     ;extract infobits
    bits    #7,>>#8,r11 
    lsl #8,r10
    lsl #8,r11
    or  r10,r11
    or  r11,r6
    or  r11,r2


;    bset    #_CODB,r2
;    bset    #_CODB,r6       ;likewize set Collision Debounce thangs        
    pop v3
    pop v2               
    rts t,nop



ncol:
    pop v3
    pop v2               
    rts t,nop

run_extern:

; run an external routine.
; To do it, first we gotta find a free external processor.

	copy	r0,r4		;save routine #
runx:
	mv_s	#4,r0
	jsr	dma_read		;Fetch in the current MPE state vector
	mv_s	#status+16,r1
	mv_s	#moo_cmd,r2		;can re-use command space, since command is already done
	jsr	dma_finished,nop

; now look for a zero in the vector (=free MPE)

	mv_s	#moo_cmd,r0	    ;base of the status words
    ld_s    rzinf+12,r1     ;this is base MPE
    ld_s    rzinf+8,r2      ;this is number of MPEs    
;	mv_s	#1,r1			;dest MPE number
;	mv_s	#3,r2			;number of MPEs to check.

    lsl #2,r1,r3
    add r3,r0               ;point to start of status words we're interested in

look41:

	ld_s	(r0),r3			;get value
	nop
	cmp	#0,r3				;zero=free MPE
	bra	eq,got_free,nop			;hooray!
	sub	#1,r2
	bra gt,look41
	add	#4,r0
	add	#1,r1
	bra	runx,nop			;loop until one becomes free.

got_free:

; going to launch code number <r4> on mpe <r1>

	copy	r4,r0
	jsr	run_ext,nop			;start up code on remote MPE
	pop	v0,rz
	nop
	rts	t,nop


run_ext:

; load and run on external mpe
; r0 = Routine number; r1 = MPE #

    push    v2,rz
    push    v1
    mv_v    v0,v1

    lsl #2,r5,r1
    mv_s    #status+16,r2
    add r2,r1
    mv_s    #1,r0
    jsr dma_write
    st_s    r0,moo_cmd
    mv_s    #moo_cmd,r2
    jsr dma_finished,nop	;flag MPE as running

; get in the bit of the external Routines table that has the relevant
; addresses and lengths

	lsl	#5,r4,r1			;get index into routine table
	mv_s	#external_routines,r6
	add	r6,r1				;pointing at data of various routines...

; load in 8 longs of data to moo_cmd

	jsr	dma_read
	mv_s	#8,r0
	mv_s	#moo_cmd,r2
	copy	r2,r4
	jsr	dma_finished,nop




;    lsl #5,r4               ;routine table entries are 32 bytes
;    mv_s    #routines,r0    ;get routine table base
;    add r0,r4               ;here's the address of the routine

{
   ld_s (r4),r1         ;external RAM address of code section
   add  #4,r4  
}
{
    ld_s (r4),r0        ;MPE address of code section
    add #4,r4
    jsr load_remote_dta ;call load-remote with data address
}
{
    ld_s    (r4),r3     ;size of load, in longs
    add #8,r4           ;point to the data
}
    copy    r5,r2       ;target MPE number  




{
   ld_s (r4),r1         ;external RAM address of code section
   add  #4,r4  
}
{
    ld_s (r4),r0        ;MPE address of code section
    add #4,r4
    jsr load_remote_dta ;call load-remote with data address
}
{
    ld_s    (r4),r3     ;size of load, in longs
    sub #24,r4          ;point back to the code
}
    copy    r5,r2       ;target MPE number  
	jsr	StartMPE	

{
	ld_v	object,v1	;pass first vector of object to the MPE.
    copy    r5,r0
}
    sub r1,r1                       ;start from base of IRAM
	pop v1
    pop v2,rz
    nop
    rts t,nop   

load_remote_dta:

; load remote onto data RAM on MPE# r2, r1 and r3 as for 
; straight load_remote, r0 has the dtram address to load to

    push    v0,rz
ld_rem:
    lsl #23,r2              ;make offset to external MPE address
    add r0,r2               ;made remote address.
    ld_s    mdmactl,r0
    jsr dma_finished,nop    ;ensure all prior DMA is finished
lrem:



    mv_s    #64,r0          ;max DMA length
    sub r0,r3               ;dec length
    bra ge,lremote,nop
    add r3,r0               ;fix length if <64
lremote:
    lsl #16,r0              ;shift length to right position
    bset    #13,r0          ;set READ
    bset    #28,r0          ;set REMOTE
    st_v    v0,dma__cmd         ;set up the command
    st_s    #dma__cmd,mdmacptr   ;launch the DMA     
    ld_s    mdmactl,r0
    add #256,r1
    add #256,r2
    jsr dma_finished,nop    ;ensure it has loaded onto the remote MPE



    cmp #0,r3
    bra gt,lrem,nop         ;loop until all is lloaded

    pop v0,rz
    nop
    rts t,nop


set_prev:

; Type routine that sets the prev screen address
; for a sprite Object (feedback or blurfield)

    ld_s    last,r0
	rts
    nop
    st_s    r0,object+36


event_brick:

; the Event routine for a Breakout brick.

;    rts
;    ld_s    moo_stub+48,r0
    ld_s    moo_stub+56,r1
    nop
    btst    #_COINF1,r1
    rts ne,nop
;    bset    #_COINF2,r0
    rts
    st_s    #0,moo_stub+24        ;disable render   
    st_s    #0,moo_stub+56        ;disable collisions    

event_ball:

; first disable collisions

       

    ld_s    moo_stub+56,r0
    ld_s    moo_stub+48,r1
    btst    #_COINF3,r0             ;collision with bat re-enables collision w/brick
    bra eq,bend,nop                     ;does not cause reverse
    btst    #_COINF1,r1
    rts eq,nop
    bclr    #_COINF1,r1
    bra knobend,nop

bend:   
    btst    #_COINF1,r1
    rts ne
    bset    #_COINF1,r1
knobend:
    st_s    r1,moo_stub+48


    push    v7,rz
    jsr loadwave
    mv_s    #2,r28    
    nop
    ld_v    moo_wave,v0
    nop
    neg r1
    st_v    v0,moo_wave
    jsr savewave,nop
    pop v7,rz
    nop
    rts t,nop


bugger_all:

; just return

	rts	t,nop

evaluate:

; Run an Object's command string to generate the Results.

	push	v7,rz
;unknown:
	sub	store,store		;initial mode isn't store.
	sub	prev_ans,prev_ans
	sub	pending_op,pending_op
	

eval_loop:

	sub	set_addr,set_addr

ev:

	ld_b	(eval_ptr),r28
	add	#1,eval_ptr
	bits	#7,>>#24,r28		;get next byte


; check for the end

	cmp	#$3a,r28			;':'
	bra	ne,not_end,nop

;unknown:


; done

	pop	v7,rz
	nop
	rts	t,nop

savewave:

; save wave# r28 out of moo_wave

    push    v7,rz
	lsl	#4,r28
	add	wave_base,r28,r1
	jsr	dma_write
	mv_s	#4,r0
	mv_s	#moo_wave,r2
    bra lwend,nop

loadwave:

; load wave# r28 to moo_wave

    push    v7,rz
	lsl	#4,r28
	add	wave_base,r28,r1
	jsr	dma_read
	mv_s	#4,r0
	mv_s	#moo_wave,r2
lwend:
	jsr	dma_finished,nop
    pop v7,rz
    nop
    rts t,nop

fuckfuck:

	ld_s	object,r31
	mv_s	#1,r31

not_end:


; check for uppercase letter (representing a wave or position)

	cmp	#$41,r28		;'A'
	bra	lt,not_var
	cmp	#$5a,r28		;'Z'
	bra	le,uppercase
	cmp	#$61,r28		;'a'
	bra	lt,not_var
	cmp	#$7a,r28		;'z'
	bra	le,lowercase,nop

not_var:

; Not a variable, so must be some modifier...

	cmp	#$24,r28			;$ = "Address of"
	bra	eq,addrof
	cmp	#$5f,r28		;underscore
	bra	eq,underscore,nop
	cmp	#$40,r28		;@
	bra	ne,unknown,nop

; @ stands for joystick.  @x and @y return the position of the
; analog stick.

	ld_b	(eval_ptr),r28
	add	#1,eval_ptr
	lsr	#24,r28
	cmp	#$78,r28
	bra	eq,lxjoy
	cmp	#$79,r28
	bra	eq,lyjoy

; Could be a button index.  If it is, get the bit state of
; the selected button.  Return ans=1 if it's pressed, or else 0.

	copy	r28,r0
	sub	#$30,r0		;assume it *is* an index...
	mv_s	#joybits,r1	;index into a table that contains bit numbers
	add	r0,r1			;address...
	ld_b	(r1),r0		;get bit #
	ld_s	joy_bits,ans	;current joybits
	lsr	#24,r0				;bit number to low of r0
	bits	#0,>>r0,ans	;extract the relevant bit
	eor	#1,ans			;flip so is 1 if pressed
	bra	eq,flerm,nop
	bra	flerm
	mv_s	#$7fffffff,ans
	nop

addrof:

	ld_s	ext_data,set_addr
    bra	ev,nop

lyjoy:

; get Y joy

	ld_s	joy_y,ans
	bra	flerm,nop

lxjoy:

; get X joy

	ld_s	joy_x,ans
	bra	flerm,nop

underscore:

; Underscore is always followed by a lowercase letter.
; It denotes a reference to the second data area (at buffer)
; instead of the primary data area (at object).

	ld_b	(eval_ptr),r28
	add	#1,eval_ptr
	bra	lc2
	mv_s	#buffer,r29
	lsr	#24,r28		

; if we get here, definitely a lowercase letter...

lowercase:

	mv_s	#object,r29	;base of vars
lc2:

; check for a modifier following the variable

	ld_b	(eval_ptr),r30		;get any modifier
	nop
	lsr	#24,r30

	sub	#$61,r28
	cmp	#0,store
	bra	ne,assign_var			;go do assign if asked for	


{
;	bra	flerm					;or else get the result
	lsl	#2,r28
}
	cmp	#0,set_addr
	bra	ne,flerm
	add	set_addr,r28,ans
	sub	set_addr,set_addr		;we can get the *address* of a var.
	add	r29,r28
	ld_s	(r28),ans

; check for modifiers afterward (for byte or word access)

	cmp	#$3c,r30			;"<"
	bra	ne,nhiword,nop
	bra	flerm
	lsr	#16,ans
	add	#1,eval_ptr
nhiword:
	cmp	#$3e,r30
	bra	ne,nloword,nop
{
	bra	flerm
	add	#1,eval_ptr
}
	lsl	#16,ans
	lsr	#16,ans
nloword:
	bra	flerm,nop



; if we're here it's definitely an uppercase letter. 
; No matter what the context, it means we gotta load
; up the wave or position vector...

uppercase:

	sub	#$41,r28
;    jsr loadwave,nop            ;load wave# r28
;    lsl #4,r28                  ;conform new loadwave
	lsl	#4,r28
	add	wave_base,r28,r1
	jsr	dma_read
	mv_s	#4,r0
	mv_s	#moo_wave,r2
	jsr	dma_finished,nop


; If the uppercase letter is followed by a numeric index, then
; we are referring to a component of the vector, rather than
; the evaluation of that vector as a wave.

	ld_b	(eval_ptr),r29		;get next
	nop							;don't increment, yet
	lsr	#24,r29
	sub	#$30,r29				;'0'
	bra	lt,wf_eval				;it's not an index
	cmp	#3,r29					;valid?
	bra	gt,wf_eval,nop			;only 0-3 are...
	add	#1,eval_ptr				;It was valid, so move the pointer
	lsl	#2,r29					;make an index
	mv_s	#moo_wave,r30
	add	r29,r30					;here's where it's at...
	cmp	#0,store
	bra	ne,assign_wave,nop		;if mode is assign, go and do that...
	bra	flerm
	ld_s	(r30),ans			;load value
	nop

wf_eval:

; evaluate the waveform

	jsr	do_wave
	ld_v	moo_wave,v1		;load for evaluation
	nop
	copy	r0,ans

flerm:

; check for any pending operations and do one if it's there

	cmp	#0,pending_op		;aught to do?
;	bra	eq,no_pending_op,nop
	bra	eq,eval_loop,nop

; *** wave merge options will go here ***

    cmp #$25,pending_op     ;"%" means Store To
    bra ne,not_stash,nop
    st_s    ans,tempword    ;store value in tempword
    copy    prev_ans,r1
    jsr dma_write
    mv_s    #1,r0
    mv_s    #tempword,r2
    jsr dma_finished,nop
    bra clop,nop
    

not_stash:
    cmp #$23,pending_op     ;"#" means Load Indirect From
    bra ne,not_lind,nop

    
 ;   jsr dma_finished,nop
    lsl #2,prev_ans         ;assume load is longword size
    add ans,prev_ans,r1        ;generate address to load from
    jsr dma_read
    mv_s    #1,r0
    mv_s    #tempword,r2

    jsr dma_finished,nop

;    ld_s    tempword,ans
;    ld_s    object,r31
;    mv_s    #1,r31
    

    bra clop
    ld_s    tempword,ans
    nop

    


;    ld_s    (prev_ans),ans  ;get value

not_lind:

	cmp	#$2b,pending_op		;'+'
	bra	ne,not_add,nop
bladd:
	bra	clop

	add	prev_ans,ans
	nop

not_add:

;    cmp #$78,pending_op     ;"x" (16 mul)
    cmp #$2f,pending_op     ;"x" (16 mul)
    bra ne,numul,nop
    mul prev_ans,ans,>>#16,ans
    mv_s    #$ff,r1
    copy    ans,r0
    abs r0
    cmp r1,r0
    bra ge,clop,nop
    bra clop 
    sub ans,ans
    nop

numul:    

	cmp	#$2a,pending_op		;"*"
	bra	ne,not_mul,nop
	bra	clop
	mul	prev_ans,ans,>>#31,ans
	nop

not_mul:

clop:
	sub	pending_op,pending_op
    bra eval_loop,nop

unknown:
no_pending_op:


; check for special cases that are not combining functions
; check for conditional assign

	cmp	#$3f,r28		;'?'
	bra	ne,noncondass
	cmp	#0,ans			
	bra	ne,assign,nop

; if conditional is 0, skip assign statements up to ";"

skipass:

	ld_b	(eval_ptr),r28
	add	#1,eval_ptr
	lsr	#24,r28
	cmp	#$3b,r28	
	bra	ne,skipass
	bra	eval_loop,nop
	nop



noncondass:
	cmp	#$3d,r28			;'='
	bra	ne,not_assign,nop

assign:

; okay, set up for assign and loop back

	bra	eval_loop
	mv_s	#1,store
	nop

not_assign:

; check for functions that apply immediately to the last generated result

    cmp #$7e,r28            ;~ (Neg)
    bra ne,notneg,nop
    bra eval_loop
    neg ans
  
    
    
notneg:
	cmp	#$21,r28			;'!' (Int)
	bra	ne,not_int,nop
    bra eval_loop
	asr	#16,ans
	nop

not_int:

	cmp	#$5b,r28			;'['
	bra	ne,not_range,nop

; next op is a Range command on the current value - let's do it

	ld_b	(eval_ptr),r1
	add	#1,eval_ptr
	lsr	#24,r1
	ld_b	(eval_ptr),r2
	add	#2,eval_ptr			;skip closing "]" that is just there for legibility
	lsr	#24,r2
	sub	#$30,r1
	sub	#$30,r2
	lsl	#2,r1
	lsl	#2,r2
	mv_s	#moo_ranges,r3
	add	r3,r1
	add	r3,r2
	ld_s	(r1),r1
	jsr	range_limit
	ld_s	(r2),r2		;get required range out of table
	copy	ans,r0


; okay, returns with range scaled answer in r0, go look for new command
		
	copy	r0,ans
    bra eval_loop,nop

not_range:

; This must be a combining op.  Copy the current result and set the op pending.

	bra	eval_loop
	copy	ans,prev_ans
	copy	r28,pending_op

assign_var:

; If we come here, we are ready to dump the result and start again.
; check for a modifier in r30...

	add	r29,r28
	cmp	#$3c,r30				;is following thang a hi word select?
	bra	eq,do_hiword
	cmp	#$3e,r30
	bra	eq,do_loword			;do the hi/lo word cases
	cmp	#$30,r30				;check for byte select (numeric index follows)
	bra	lt,jassign
	cmp	#$34,r30
	bra	gt,jassign,nop

; byte store, if we get here

	sub	#$30,r30
	mv_s	#$ff000000,r31
	lsl	#3,r30
	ls	r30,r31				;these bits mask the relevant byte
	ld_s	(r28),r0		;get existing value
	not	r31
	and	r31,r0				;cleared prev data
	bits	#7,>>#0,ans
	bra	do_part
	lsl	#24,ans
	ls	r30,ans				;move result to hole


jassign:

	bra	eval_loop
	st_s	ans,(r28)			;var address was passed in here.
	sub	store,store				;did that.

do_hiword:

	ld_s	(r28),r0
	nop
	bits	#15,>>#0,r0
	lsl	#16,ans
do_part:
	or	ans,r0
	add	#1,eval_ptr
	bra	eval_loop
	st_s	r0,(r28)
	sub	store,store

do_loword:

	ld_s	(r28),r0
	nop
	lsr	#16,r0
	bra	do_part
	lsl	#16,r0
	bits	#15,>>#0,ans
	


assign_wave:

; Assign is to a waveform part.  We need to get the index.

	st_s	ans,(r30)				;store it

	add	wave_base,r28,r1		;write it back out
	jsr	dma_write
	mv_s	#4,r0
	mv_s	#moo_wave,r2
	jsr	dma_finished,nop

	bra	eval_loop
	sub	store,store
	nop


do_wave:

; enter with a wave in v1.  Return the updated wave
; in v1, with the resultant value in r0.

	ld_s	moo_stub+60,r1	;global time slew
    ld_s    lctr,r0      ;get current raw clock
	nop
	add	r1,r0
    sub r0,r4,r0
    bits    #15,>>#0,r0
    mul r6,r0,>>#0,r0   ;scale
    copy	r7,r1		;get wavetype
    lsl #8,r5
    add r5,r0
    lsl #8,r0
    asr #16,r0
;    add r5,r0           ;add phase in after scaling
    mv_s	#wave_types,r2	;base of wave jump table
	bits	#7,>>#0,r1		;get wave index


	lsl	#2,r1
	add	r1,r2 
;    lsl #8,r0
	ld_s	(r2),r1		;get address of wave routine
    nop
;    asr #16,r0          ;return a value +/- 7fff 
    mv_s    #$8000,r2
    cmp r0,r2
    jmp ne,(r1)
    add #1,r0
    jmp	(r1),nop		;go do wave type   
        
sawtooth_wave:

; enter with r0 = timer value.  Return with 32-bit signed sawtooth value in r0.

    rts
    lsl #16,r0          ;Hey, this one's easy.
    nop

triangle_wave:

; generate 32-bit signed triangle from timer value.

    mv_s    #$8000,r1
    abs r0              ;0 - 7fff - 0
{
    rts
    lsl #1,r0           ;0 - ffff - 0
}        
    sub r1,r0           ;-$8000 - 7fff - -$8000
    lsl #16,r0          ;make full range.
       
sine_wave:

; generate a sinewave from timer value.

	or	#1,r0
	push	v1			;preserve the wave vector
	push	v2,rz		;need ta save rz
	jsr	sincos,nop		;ahh, good old sincos
	pop	v2,rz
	nop
	rts	
	pop	v1
	lsl	#1,r1,r0		;make sin fill all 32bits

cos_wave:

; as sine wave but return the cosine

	or	#1,r0
	push	v1			;preserve the wave vector
	push	v2,rz		;need ta save rz
	jsr	sincos,nop		;ahh, good old sincos
	pop	v2,rz
	nop
	rts	
	pop	v1
	lsl	#1,r0			;make cos fill all 32bits

 

range_limit:

; scale the full-wave value in r0 to the range (r1-r2)


    sub r1,r2           ;get range
    lsl #1,r1
    add r2,r1           ;make midpoint
    mul r2,r0,>>#31,r0  ;scale
    rts
;    asr #1,r1
    add r1,r0
    asr #1,r0
    
update_waves:

; Enter with a wave block loaded at moo_cmd.
; This routine modifies the phase of waves that are "off", and
; handles positional (non-wave) stuff.

	ld_s	moo_stub+8,r0
	nop
	bits	#7,>>#16,r0		;Number of waves.
	rts	eq,nop				;Return if none.
 	mv_s	#moo_cmd,r1		;Base of wave struct.
	ld_s	lctr,r2			;Current time.

runw:

	ld_v	(r1),v1			;get wave
	nop
	btst	#31,r7			;Positional?
	bra	ne,positional		;Yup - handled differently
	btst	#30,r7			;running?
	bra	eq,runw0,nop
	mv_s	r2,r4			;Not running, so set phase=timer

runw0:

; done, write back updated wave

	st_v	v1,(r1)
	sub	#1,r0
	bra	gt,runw
	add	#16,r1
	nop

;finished

	rts	t,nop

positional:

; This code handles parameters that are not Waveforms
; First load up the Limits...

{
	mv_s	r7,r21
	copy	r7,r20
}
	bits	#3,>>#4,r20
	bits	#3,>>#0,r21
	lsl	#2,r20
	lsl	#2,r21
	add	range_base,r20
	add	range_base,r21
{
	ld_s	(r20),r20
	bclr	#16,r7
}
{
	ld_s	(r21),r21			;got the limits in r20 (low) and r21 (high)
	bclr	#17,r7			;clear boundary transition bits
}


	mul	r6,r5,>>#16,r5
    mv_s    #$ff,r22
    copy    r5,r23
    abs r23
    cmp r22,r23
    bra ge,ntrunc,nop
    sub r5,r5
ntrunc:    
    

	cmp	#0,r5

{
	mv_s	r7,r22			;to extract action type
	bra	ge,chkhi			;check hi bound if moving towards it
}
	add	r5,r4				;and do velocity.  Position now in r4.
{
	mv_s	#boundary_actions,r23	;base of jmp table
	bits	#7,>>#8,r22		;extract action_type
}

; check low bound

	cmp	r20,r4
	bra	gt,nbound
{
	bra	nbound
}
	nop
	bset	#16,r7			;set transition bit

chkhi:

	cmp	r21,r4
	bra	lt,nbound,nop
	bset	#17,r7
	
nbound:

	ftst	#3,<>#-16,r7	;test boundary transition
{
	lsl	#2,r22				;make index
	bra	eq,runw0
}
	add	r22,r23			;routine address
	ld_s	(r23),r23	;get it						
	nop
	jmp	(r23),nop		;call it

nothing:

	bra	runw0,nop

wrap:

	btst	#16,r7
	bra	ne,wraplo,nop
	bra	runw0
	sub	r21,r4			;wrap on high boundary
	add	r20,r4

wraplo:

	bra	runw0
	add	r21,r4
	nop

bounce:

	bra	runw0
	neg	r5
	add	r5,r4

max:

	btst	#16,r7
	bra	ne,min,nop

	bra	runw0
	copy	r21,r4
	sub	r5,r5

min:

	bra	runw0
	copy	r20,r4
	sub	r5,r5	


	.include	"dma.s"
	.include	"sincos.s"
	.include	"runpipe.s"