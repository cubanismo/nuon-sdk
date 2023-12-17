	;; Ray tracing demo.
	
/* Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

	
// these are just some defaults, which will probably be ignored	
TOTAL_MPES = 1
MPE_NUM = 0

	.nocache
	
        .segment ray2d
	.origin $20100000

	.segment ray2c
	.origin $20300000

	; registers for "wait" routines
	mpenum = v7[0]
	mpecount = v7[1]
	
        iter_count = v7[2]


        mv_s    #0,iter_count
;; initialize linpixctl
	st_s	#(1<<28)|(4<<20),linpixctl


mainloop:
	;; first, wait for instructions to come from the
	;; main processor

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
	ld_v	commrecv,v1
	nop

	;; PACKET FORMAT:
	;; scalar 1: screen pointer
	;; scalar 2: DMA flags
	;; scalar 3: MPE info: #MPEs in high word, mpe number in low word
	;; scalar 4: joystick data (packed):
	;;           high 16 bits: buttons
	;;           low 16 bits: 8 bits of X shift, 8 bits of Y
	;; 
	st_s	r4,dest_base_addr
	st_s	r5,dest_dma_flags
	st_s	r7,usejoyval
	lsr	#16,r6,r0       ; r0 == number of MPEs
	bits	#15,>>#0,r6     ; r6 == MPE number
	st_s	r0,total_mpes
	st_s	r6,cur_mpe
 
	jsr     render
        nop
        nop

        bra     mainloop
        nop
        nop


	.include "raymain.s"

;
; routine to write r0, in binary notation, to the
; screen
;
; registers used:
; r0 == number to write (up to 8 bits)
; r1 == scratch register
; r2 == X position
; r3 == Y position
;
; r4 == old contents of DMA data

WriteLED:
	push	v1,rz
	
	mv_s	#48,r2
	mv_s	#48,r3
	
	;* wait for DMA to be ready
`wv:
	ld_io	mdmactl,r1
	nop
	bits	#4,>>#0,r1
	bra	ne,`wv,nop


	ld_s	dmabuf,r1
	ld_s	dmabuf+16,r4	; old data value
	bset	#27,r1		; set DIRECT bit
	st_s	r1,dmabuf
	st_s	#$c0808000,dmabuf+16	; set direct data value to white
	
	; loop over 8 bits
	st_io	#8,rc0
`digit:
	
	copy	r3,r1		; Y position
	or	#5,<>#-16,r1	; always 4 pixels high
	st_s	r1,dmayptr
	
	mv_s	r2,r1		; X position
	btst	#7,r0
{	bra	ne,`nonzero,nop
	or	#1,<>#-16,r1	; at least 1 pixel wide
}

	or	#4,<>#-16,r1	; 5 pixels wide if 0
`nonzero:
	st_s	r1,dmaxptr

	mv_s	#dmabuf,r1
	st_io	r1,(mdmacptr)

	;* wait for DMA to be ready
`wv2:
	ld_io	mdmactl,r1
	nop
	bits	#4,>>#0,r1
	bra	ne,`wv2,nop

	add	#8,r2		; increment X position
	asl	#1,r0
	dec	rc0
	bra	c0ne,`digit,nop


	st_s	r4,dmabuf+16	; restore DMA data pointer
	pop	v1,rz
	ld_s	dmabuf,r1
	rts
	bclr	#27,r1		; clear DIRECT bit
	st_s	r1,dmabuf
	

#if 0
	;;
	;; comm_send:
	;; sends v1 to target specified in r0	
my_comm_send:

        st_io   r0,(commctl)

        st_v    v1,(commxmit)
fsvwait:
        ld_s    commctl,r0
        nop
        btst    #14,r0
        bra     ne,my_comm_send
        nop
        btst    #15,r0
        bra     ne,fsvwait,nop

        rts
        nop
        nop

	;;
	;; comm_recv:
	;; receives v1
	;;
my_comm_recv:
        ld_io   (commctl),r0
        nop
        btst    #31,r0
        bra     eq,my_comm_recv
        nop
        nop

        rts
        ld_v    (commrecv),v1
        nop
#endif

        .segment ray2d
        .export _rayjoyval
_rayjoyval:
usejoyval:
        .dc.s 0
fps:
	.dc.s	0
curfps:
        .dc.s 0

