	;;
	;; video and joystick setup code
	;;
	;; Copyright (c) 1997 VM Labs, Inc.
	;; All rights reserved.
	;; Confidential and Proprietary Information
	;; of VM Labs, Inc.
	;;
	;; This file is poorly documented and contains
	;; much magic; alas, it has been through
	;; too many hands already.
	;; See video.def for info about customizing
	;; this. It almost certainly will NOT work
	;; with any SCRNHEIGHT other than 240.
	;;
	
	JOY_ID = $01
	;;JOY_ID = $A5
		
        .module video

        .export _InitVideo
	.export __fieldcount
	.export __joydata
	

        .segment  local_ram
	
	;;
	;; here are the important video VDG registers
	;;
	.align.v
vid_vdg_1:
vdg_scale_factor:
	.dc.s	0
vdg_plen:
	.dc.s	0
vdg_control:
	.dc.s	0
	; unused
	.dc.s	0
	
	;;
	;; here are the video DMA registers written
	;; on each interrupt
	;;
	
	.align.v
vid_dma_even1:
	.ds.s	4
vid_dma_even2:
	.ds.s	4

vid_dma_odd1:
	.ds.s	4
vid_dma_odd2:
	.ds.s	4

	
	;; count of fields
__fieldcount:
	.dc.s	0

	;; last data from joystick
__joydata:
	.dc.s	$7f7f0000


	.segment instruction_ram
start:

; ----------------------------------------------------------------------------
; set up general IO as the comm. bus target
;
comm_send_io:
        ld_s   (commctl),r0            ; poll for transmit data empty
        nop

        btst    #15,r0
        bra     ne,comm_send_io
        nop
        mv_s    #$00002045,r0		; set the general IO interface as the target
        mv_s    #$0,r6       		; dummy data
        mv_s    #$0,r7			; dummy data

        st_s   r0,(commctl)
	;; fall through to comm_send
	
; ----------------------------------------------------------------------------
; comm_send
; ----------------------------------------------------------------------------
; transmits vector 1 to a previously setup target
; r0 is corrupted
 
	
comm_send:
; poll for transmit data empty
        ld_io   (commctl),r0
        nop
        btst    #15,r0
        bra     ne,comm_send
        nop
        nop
 
; write to the transmit data register and so start transfer
 
        rts
        st_v    v1,(commxmit)
        nop
 
; ----------------------------------------------------------------------------
; comm_recv
; ----------------------------------------------------------------------------
; receives vector 1 
; r0 is corrupted
 
comm_recv:
; poll for receive buffer full
        ld_s	(commctl),r0
        nop
        btst    #31,r0
        bra     eq,comm_recv
        nop
        nop
 
; read the receive register, which empties it
 
        rts
        ld_v    (commrecv),v1
        nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; handle joystick
; check for joystick comm bus events
; is, and do the right thing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

check_joystick:
	push	v0,rz

check_comm:
        ld_s	(commctl),r0
        nop
        btst    #31,r0
	bra	eq,`no_joystick,nop
	
        jsr     handle_commbus,nop
	bra	check_comm,nop
	
`no_joystick:
	; send a request to read controller 1 status
	jsr	comm_send_io
	mv_s	#$00000202,r4		; read controller 1 status
	mv_s	#$0,r5			; dummy
	
	pop	v0,rz	
	nop
	rts
	nop
	nop
	
handle_commbus:
	push	v0,rz
	;; we got a packet here from the controller interface
	ld_v	(commrecv),v1		; fetch joystick data
	nop
	
	;;
	;; data arrived; either this is controller status (in
	;; which case r4 is 0) or it is joystick data (in which
	;; case r4 is the joystick ID). Look to see which
	;; it is.
	;;

	cmp	#0,r4			; state 1: controller status arrived
	bra	ne,state2,nop

controller_data:
	btst	#31,r5			; check for transmit buffer full
	bra	ne,state0,nop		; if buffer is full, go back to state 0

	; transmit buffer is empty -- we can send a request to transmit
	; data
	jsr	comm_send_io
	mv_s	#$80000201,r4		; send controller 1 data
	mv_s	#(JOY_ID << 24),r5	; send out the joystick ID

	pop	v0,rz
	nop
	rts
	nop
	nop

state2:
	; we got data from the joystick -- save it
	st_s	r5,__joydata

	;; fall through to state 0
state0:	
	; send a request to read controller 1 status
	jsr	comm_send_io
	mv_s	#$00000202,r4		; read controller 1 status
	mv_s	#$0,r5			; dummy

	pop	v0,rz
	nop
	rts
	nop
	nop

	; fall through
	
; ----------------------------------------------------------------------------
; video setup
; Description:
;       This subroutine takes the following parameters:
;       r0 == pointer to vdg register block
;             this points to the vdg_scale_factor, vdg_plen, and vdg_control
;             register values, in that order
;       r1 == pointer to dma vector block; 2 sets of 8 values (2 vectors) to
;             be sent to the DMA registers on each VBI
;             the first set is for even lines, the next for odd lines
;
;	After setting up the screen, the program will loop between
;	two video interrupts.  One is setup for interrupt at line 19 
;	and the other one is setup to run at line 261.  During these
;	interrupt, this program will write to the DMA registers to 
;	request one field worth of data.  This program will loop between
;	these interrupts forever (unless the main routine crashes).
;
; Further complication: the video interrupt handlers also respond
; to incoming joystick data from the joystick. So unless and until
; video is enabled, no joystick events will be received.
;

_InitVideo:
	st_s	#0,inten1		; disable all interrupts
		
	push	v2,rz			; preserve rz
	copy	r0,r8			; save parameter 1
	copy	r1,r9			; save parameter 2

	; copy over the DMA registers
{	ld_s	(r9),r0
	add	#4,r9
}
{	ld_s	(r9),r1
	add	#4,r9
}
{	ld_s	(r9),r2
	add	#4,r9
}
	ld_s	(r9),r3
	add	#4,r9

	st_v	v0,vid_dma_even1
{	ld_s	(r9),r0
	add	#4,r9
}
{	ld_s	(r9),r1
	add	#4,r9
}
{	ld_s	(r9),r2
	add	#4,r9
}
	ld_s	(r9),r3
	add	#4,r9

	st_v	v0,vid_dma_even2
{	ld_s	(r9),r0
	add	#4,r9
}
{	ld_s	(r9),r1
	add	#4,r9
}
{	ld_s	(r9),r2
	add	#4,r9
}
	ld_s	(r9),r3
	add	#4,r9

	st_v	v0,vid_dma_odd1
{	ld_s	(r9),r0
	add	#4,r9
}
{	ld_s	(r9),r1
	add	#4,r9
}
{	ld_s	(r9),r2
	add	#4,r9
}
	ld_s	(r9),r3
	add	#4,r9

	st_v	v0,vid_dma_odd2
	
	;
	; now the vdg registers
	; if the vdg registers haven't changed,
	; then we don't need to re-initialize video
	;
	ld_s	vdg_scale_factor,r3
{	ld_s	(r8),r0
	add	#4,r8
}
{	ld_s	(r8),r1
	add	#4,r8
}
{	ld_s	(r8),r2
	add	#4,r8
}
{	cmp	r0,r3
	ld_s	vdg_plen,r3
}
	bra	ne,vdg_changed,nop
{	cmp	r1,r3
	ld_s	vdg_control,r3
}
	bra	ne,vdg_changed,nop
	cmp	r2,r3
	bra	eq,enable_interrupts,nop
	
vdg_changed:
	sub	r3,r3
	st_v	v0,vid_vdg_1

	; fall through to the setup code
	
; ----------------------------------------------------------------------------
; set up the joystick interface
; first, get our own id into register r5
;
	ld_io	configa,r5
	nop
	bits	#7,>>#8,r5

	; set up the "send to MPE n" command for controller 1
	lsl	#16,r5
;	or	#$01000546,r5
	mv_s	#$01000546,r4
    or r4,r5

        mv_s    #$80000202,r4           ; write to controller 1 control
	jsr     comm_send_io,nop



	; set the VDG Engine as the comm. bus target
bpp2:
        ld_io   (commctl),r0            ; poll for transmit data empty
        nop
        btst    #15,r0
        bra     ne,bpp2
        nop
        mv_s    #$00002041,r0
        st_io   r0,(commctl)

/* Write to the Scaling Factor with a 1.0 (x1) */
	mv_s	#$80000014,r4
	ld_s	vdg_scale_factor,r5
	jsr 	comm_send,nop
        
/* Write to the PLEN register */
	mv_s	#$80000104,r4
	ld_s	vdg_plen,r5			; get vdg_plen value
	jsr 	comm_send,nop

/* write to the FIFO1 */
        jsr     comm_send
        mv_s    #$80000020,r4
        mv_s    #$E004FC00,r5

/* write to the ALEN */
        jsr     comm_send
        mv_s    #$80000118,r4
        mv_s    #$000000EF,r5
       
/* write to the PVEN */
        jsr     comm_send
        mv_s    #$800000B0,r4
        mv_s    #$00000105,r5

frame:

/* write to the HINT */
        jsr     comm_send
        mv_s    #$80000128,r4
        mv_s    #$00000001,r5

/* write to the VINT */
        jsr     comm_send
        mv_s    #$8000012C,r4
        mv_s    #$00000013,r5

/* write to the control register */
	ld_s	vdg_control,r5
        jsr     comm_send
        mv_s    #$80000000,r4
	nop

/* write to the Video Init */
        jsr     comm_send
        mv_s    #$80000130,r4
        mv_s    #$00000000,r5


; now set up ready to receive video interrupts	 

enable_interrupts:
	mv_s	#video_isr,r0		; set up the interrupt vector
	st_s	r0,intvec1
	st_s	r0,intvec2

	mv_s	#$80000000,r0
	st_s	r0,intclr		; clear video interrupt

	st_s	#$95,intctl		; clear masks

	mv_s	#$80000000,r0		; enable video interrupt
	st_s	r0,inten1

	pop	v2,rz			; restore rz
	nop
	rts
	nop
	nop

; the video interrupt service routine
	; for odd fields
video_isr:
	push	v1
	push	r0,cc,rzi1,rz

	/* check for joystick events */
	jsr	check_joystick,nop

; set the DMA Engine as the comm. bus target
bpp1:
        ld_io   (commctl),r0            ; poll for transmit data empty
        nop
        btst    #15,r0
        bra     ne,bpp1
        nop
        mv_s    #$00002047,r0
        st_io   r0,(commctl)

	ld_v	vid_dma_odd1,v1
        jsr     comm_send,nop

	ld_v	vid_dma_odd2,v1
        jsr     comm_send,nop

; set the VDG Engine as the comm. bus target
bpp20:
        ld_io   (commctl),r0            ; poll for transmit data empty
        nop
        btst    #15,r0
        bra     ne,bpp20
        nop
        mv_s    #$00002041,r0
        st_io   r0,(commctl)

	/* write to the HINT */
        jsr     comm_send
        mv_s    #$80000128,r4
        mv_s    #$00000001,r5

	/* write to the VINT */
        jsr     comm_send
        mv_s    #$8000012C,r4
        mv_s    #$00000105,r5

	/* update field count */
	ld_s	__fieldcount,r4
	nop
	add	#1,r4
	st_s	r4,__fieldcount

	mv_s	#video_isr1,r0		; set up the interrupt vector
	st_io	r0,intvec1

	mv_s	#$80000000,r0
	st_io	r0,intclr		; clear video interrupt

	pop	r0,cc,rzi1,rz
	pop	v1

	rti	rzi1			; and interrupt done!
	nop
	nop

; the video interrupt service routine
; for even fields
video_isr1:

	push	v1
	push	r0,cc,rzi1,rz

	/* check for joystick events */
	jsr	check_joystick,nop

; set the DMA Engine as the comm. bus target
bpp5:
        ld_io   (commctl),r0            ; poll for transmit data empty
        nop
        btst    #15,r0
        bra     ne,bpp5
        nop
        mv_s    #$00002047,r0
        st_io   r0,(commctl)

	ld_v	vid_dma_even1,v1
        jsr     comm_send,nop

	ld_v	vid_dma_even2,v1
        jsr     comm_send,nop

; set the VDG Engine as the comm. bus target
bpp25:
        ld_io   (commctl),r0            ; poll for transmit data empty
        nop
        btst    #15,r0
        bra     ne,bpp25
        nop
        mv_s    #$00002041,r0
        st_io   r0,(commctl)

/* write to the HINT */
        jsr     comm_send
        mv_s    #$80000128,r4
        mv_s    #$00000001,r5

/* write to the VINT */
        jsr     comm_send
        mv_s    #$8000012C,r4
        mv_s    #$00000013,r5

	/* update field count */
	ld_s	__fieldcount,r4
	nop
	add	#1,r4
	st_s	r4,__fieldcount

; now set up ready to receive video interrupts	 

	mv_s	#video_isr,r0		; set up the interrupt vector
	st_io	r0,intvec1

	mv_s	#$80000000,r0
	st_io	r0,intclr		; clear video interrupt

	pop	r0,cc,rzi1,rz
	pop	v1

  	rti	rzi1			; and interrupt done!
	nop
	nop



	;;
	;; SetUpVideo
	;; Assembly language routine to set video
	;; up in a predefined mode (whatever is given
	;; in video.def)
	;;
	;;

	;;	.include "video.def" (if not already included)
	
	.segment local_ram
	; VDG register data
orig_vdg_data:
	.dc.s	(1<<30) | (fix(SCRNWIDTH/720,11) << 16)
	.dc.s	SCRNWIDTH*4
	.dc.s	0x180 | screen_bpp
	.dc.s	0

orig_dma_data:
	; even field data
	.dc.s	0x0a000000 | dma_height
	.dc.s	0x0b000000 | SCRNWIDTH
	.dc.s	0x0c000000 | evenscalepos
	.dc.s	0x0d000000 | 0x4000
	.dc.s	0x50000000
	.dc.s	(SCRNBASE >> 7)
	.dc.s	0x080f0000 | (dmaXsize) | (lines << 14) | (clines << 12)
	.dc.s	0x09000007 | (binc << 20) | (fldup << 16) | (CLUSTER << 14) | (DMA_XFER_TYPE << 7) | (vibits << 11)

	; odd field data
	.dc.s	0x0a000000 | dma_height | (interlace << 12)
	.dc.s	0x0b000000 | SCRNWIDTH
	.dc.s	0x0c000000 | oddscalepos
	.dc.s	0x0d000000 | 0x4000
	.dc.s	0x50000000
	.dc.s	(SCRNBASE >> 7)
	.dc.s	0x080f0000 | (dmaXsize) | (lines << 14) | (clines << 12)
	.dc.s	0x09000007 | (binc << 20) | (fldup << 16) | (CLUSTER << 14) | (DMA_XFER_TYPE << 7) | (vibits << 11)



	.segment instruction_ram
	.export SetUpVideo
SetUpVideo:
	jmp	_InitVideo
	mv_s	#orig_vdg_data,r0
	mv_s	#orig_dma_data,r1
	
	.export	SetVidBase
SetVidBase:
{       mv_s    #vid_dma_even1+(5*4),r1
        bits    #24,>>#7,r0
        rts
}
{       st_s    r0,(r1)
        add     #(8*4),r1
}
        st_s    r0,(r1)
