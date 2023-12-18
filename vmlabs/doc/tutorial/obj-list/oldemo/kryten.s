;
; kryten.s
;
; This will, hopefully, handle all linked list
; events and object initialisation code, leaving
; room in moo_cow for the actual HL object running.

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
	.dc.l	init_asteroid
    .dc.l   init_llama
    .dc.l   init_brick

buffer:

	.ds.l	32


object_size = 16		;size of an Object, in longs
ob_type = object+60		;where the Type information lurks

   .segment instruction_ram

    st_s    #($20100000+4*1024),sp

; get MPE-number


    ld_s    configa,r4
    ld_s    rzinf+12,r5
    bits    #4,>>#8,r4
    st_s    r4,mpenum
    sub r5,r4
	st_s	r4,logical_mpenum	;note what we are logically

	jsr	ol_setup,nop			;call setup

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




ol_setup:

	init_cmd_ptr = r12
	make_n = r13
	dest_list_ptr = r14
	dest_list_base = r15
	ranmsk = r16
	ranseed1 = r17
	ranseed2 = r18
	ranseed3 = r19
	cownt = r20

; we get: r1 = Free RAM pointer
; r2 = Setup command string external address

	mv_v	v0,v2		;save stuff

; init RSGs

	mv_s	#$a3000000,ranmsk		;for pseudo random seq gen
	mv_s	#$37264865,ranseed1
	mv_s	#$76737362,ranseed2
	mv_s	#$10958767,ranseed3	

; load the command list

	mv_s	#init_cmd,r2
{
	jsr	 dma_read
}
{
	add	#8,r2,init_cmd_ptr
	mv_s	r10,r1
}
	mv_s	#64,r0		;list is up to 256 bytes long
	jsr	dma_finished,nop

; load the prototypes address list

	ld_s	init_cmd,r1				;proto address list passed here
	jsr	dma_read
	mv_s	#init_proto_addresses,r2
	mv_s	#64,r0
	jsr	dma_finished,nop
	mv_s	#init_list_array,dest_list_ptr	;start with the first list
	copy	r9,dest_list_base			;it will be based at free RAM
	sub	r3,r3							;initial manufacture is virgin list

; now start to interpret the string, building the current list

dolist:

	ld_s	(init_cmd_ptr),r1	;get next command
	add	#4,init_cmd_ptr
	btst	#31,r1				;set means EOL
	bra	ne,donelist,nop
	mv_s	#init_proto_addresses,r2	;going to get proto address
	lsr	#16,r1,r20						;extract proto #
	lsl	#2,r20
	add	r20,r2
	ld_s	(r2),r0				;got proto address
	jsr	manufacture				;builds a list of objects
	bits	#15,>>#0,r1			;got number to make
	copy	r9,r2				;free RAM to make them at
	copy	r2,r9
	bra	dolist,nop	
		
donelist:

	st_s	dest_list_base,(dest_list_ptr)



; write out the list array

	ld_s	init_cmd+4,r1
	jsr	dma_write
	mv_s	#8,r0
	mv_s	#init_list_array,r2
	jsr	dma_finished,nop	
 
    bra	fin,nop

random:

; run the pseudo random sequence generator

	btst	#0,r0
	rts	ne
	rts
	lsr	#1,r0
	eor	ranmsk,r0

	
transfer:

; Unlink an object from one list, and add it to another list.
; Enter with: r0 = Address of object in FROM list
; r1 = Address of object in TO list
; Return: r0 = Address of next object in FROM list (or 0 if empty)
; r1 = nexrt object in TO list (actually previous FROM one)
; Object r0 will be added *after* object r1.

	push	v2
	push	v1,rz

; first, load the pointer fields of both objects:

	mv_v	v0,v2
	copy	r0,r1		;FROM list object
	jsr	dma_read
	mv_s	#16,r0		;want it all in case there is an init routine
	mv_s	#buffer,r2
	jsr	dma_finished,nop

	copy	r9,r1
	jsr	dma_read
	mv_s	#2,r0
	mv_s	#buffer+64,r2
	jsr	dma_finished,nop

; now unlink the object from the source list

	ld_s	buffer,r1
	nop
	cmp	#0,r1			;(will usually be 0)
	bra	eq,no_prev,nop
	jsr	dma_read
	mv_s	#2,r0
	mv_s	#buffer+72,r2	;was 16
	jsr	dma_finished,nop
	ld_s	buffer+4,r0
	nop
	st_s	r0,buffer+76	;next is now next of the transfer object
	ld_s	buffer,r1
	jsr	dma_write
	mv_s	#2,r0
	mv_s	#buffer+72,r2
	jsr	dma_finished,nop

no_prev:

	ld_s	buffer+4,r1		;get next object
	jsr	dma_read
{
	copy	r1,r10			;return this as the from list pointer
	mv_s	#2,r0
}
	mv_s	#buffer+72,r2
	jsr	dma_finished,nop
	ld_s	buffer,r0
	nop
	st_s	r0,buffer+72
	ld_s	buffer+4,r1
	jsr	dma_write
	mv_s	#2,r0
	mv_s	#buffer+72,r2
	jsr	dma_finished,nop

; now transfer object is unhooked from source list
; add it to the dest list

	ld_s	buffer+68,r11	;get NEXT of object in list we are adding to
	st_s	r8,buffer+68	;place link to the object being inserted
	copy	r9,r1
	jsr	dma_write
	mv_s	#2,r0
	mv_s	#buffer+64,r2
	jsr	dma_finished,nop
	st_s	r11,buffer+4		;NEXT becomes next of object being inserted
	st_s	r9,buffer			;PREV becomes the object we just linked to

; run any initialisation code for the object just linked

	push	v2
	jsr	 run_routine
	ld_s	buffer+36,r0
	nop
	pop	v2
	nop

; then write out the object

	copy	r8,r1
	jsr	dma_write
	mv_s	#16,r0
	mv_s	#buffer,r2
	jsr	dma_finished,nop

; if there is any object following the one we inserted (ie we did not
; insert at the end of the list) then load it and update its PREV field		

	copy	r11,r1			;anything?
	bra	eq,trans_done,nop
	jsr	dma_read
	mv_s	#2,r0
	mv_s	#buffer+64,r2
	jsr	dma_finished,nop
	st_s	r8,buffer+64		;Update this
	jsr	dma_write
	mv_s	#2,r0
	mv_s	#buffer+64,r2
	jsr	dma_finished,nop

trans_done:

	copy	r10,r0		;return updated FROM list pointer
	copy	r8,r1		;new TO list is what we just inserted
	pop	v1,rz
	pop	v2
	rts	t,nop

seek:

; Find an object.  Enter with object list pointer in r0.
; R1 = either Object # to find or just (large positive) to return end.

	push	v1,rz
	mv_s	r0,r4
	copy	r1,r5
	copy	r4,r1
	

gnex:

	jsr	dma_read
	mv_s	#2,r0		;just get Prev and Next
	mv_s	#buffer,r2
	jsr	dma_finished,nop

; dec object counter & exit if -ve

	copy	r4,r0		;to return address if finished
	sub	#1,r5
	ld_s	buffer+2,r1
	bra	lt,seekdone,nop
	cmp	#0,r1
	bra	ne,gnex,nop
	
; done if we got here

seekdone:

	pop	v1,rz
	nop
	rts	t,nop
	
manufacture:

; What this does is take an object prototype (address in r0), and
; make a linked list of (r1) objects in free RAM pointed to by
; r2.  Enter with r3=0 *if* this is the first object on a new list.
; If r3 is nonzero, the routine will begin appending objects
; to the previous object assumed to still be in RAM.

	push	v2
	push	v3,rz
	mv_v	v0,v2

; check if this is a virgin list (r3=0)

	sub	r12,r12			;no prev object initially
	cmp	#0,r3
	bra	eq,virgin,nop

; Link on to the object already in RAM.

	copy	r3,r12		;this is prev object
	st_s	r2,init_proto+4	;new object's future address is prev object next
	copy	r3,r1
	jsr	dma_write
	mv_s	#2,r0
	mv_s	#init_proto,r2	;just update the pointer field
	jsr	dma_finished,nop

virgin:

; load up the prototype

	copy	r8,r1		;external address of proto
	jsr	dma_read
	mv_s	#12,r0
	mv_s	#init_proto,r2
	jsr	dma_finished,nop	;got just the proto header

	ld_s	init_proto+32,r0	;this is the length of the whole object
	jsr	dma_read
{
	mv_s r8,r1	
	copy	r0,r11			;save length
}
{
	mv_s	#init_proto,r2
	lsr	#2,r0
}
	jsr	dma_finished,nop

; got the entire object proto in init_proto.

	add	r10,r11,r13		;and the "next" object will be here...
	sub	cownt,cownt
manuf:

	sub	#1,r9				;dec object # count
	bra	gt,morethan1,nop	;if it's the last object, zero the next field
	sub	r13,r13

morethan1:

; put the links into the head of the object

	st_s	r12,init_proto
	st_s	r13,init_proto+4

; run any initialisation code for the object

	push	v2
	jsr	 run_routine
	ld_s	init_proto+36,r0
	nop
	pop	v2
	nop


; write the object to the RAM pointed at by r10

	lsr	#2,r11,r0		;length of an object
	jsr	dma_write
	mv_s	#init_proto,r2
{
	mv_s	r10,r14
	copy	r10,r1
}
	jsr	dma_finished,nop

; get ready for the next object

	add	#1,cownt
	copy	r10,r12		;the one we just wrote will be prev
	cmp	#0,r9
	bra	gt,manuf		;loop for all of the objects
	copy	r13,r10		;what was next becomes current...
	add	r11,r13			;and this will be next

; okay, get ready to return some info (new RAM pointer, in r2)

	add	r11,r12,r2		;address of next free RAM is in r2.
	copy	r14,r3		;address of last object written
	pop	v3,rz
	pop	v2
	rts	t,nop


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

; *************
; object init routines
; *************

set_prev:

; Type routine that sets the prev screen address
; for a sprite Object (feedback or blurfield)

    ld_s    last,r0
	rts
    nop
    st_s    r0,object+36

init_asteroid:

; This generates a pseudorandom velocity for
; an instance of an Asteroid object.

	push	v0,rz
	copy	ranseed1,r0
	jsr	random,nop
	copy	r0,ranseed1
	copy	ranseed2,r0
	jsr	random,nop
	copy	r0,ranseed2
	st_s	r0,init_proto+60    ;Randomize "Object time slew"
	lsl	#9,ranseed1,r0
	lsl	#9,ranseed2,r1
	asr	#15,r0
	asr	#15,r1
	st_s	r0,init_proto_vars+4    ;Randomize X velocity
	st_s	r1,init_proto_vars+20   ;Randomize Y velocity
	pop	v0,rz
	nop
bugger_all:	rts	t,nop

init_llama:

; All this does is set the local timeslew on an
; object according to the value of "cownt".

    rts
    lsl #2,cownt,r0
    st_s    r0,init_proto+60

init_brick:

; Make a Breakout brick, and give it a nice colour.

    copy    cownt,r0
    lsr #4,cownt,r1
    bits    #3,>>#0,r0
    bits    #3,>>#0,r1
    lsl #4,r1,r2
    add r0,r2
    lsl #4,r0
    lsl #3,r1
    add #$20,r0
    add #$30,r1
    lsl #16,r0
    or  r1,r0
    rts
	st_s	r0,init_proto_vars+112  
    st_s    r2,init_proto+60



	.include	"dma.s"
	.include	"sincos.s"
	.include	"runpipe.s"