	;;
	;; Coff file loader for Merlin.
	;;
	;; Copyright (c) 1998 VM Labs, Inc.
	;; All rights reserved.
	;; Confidential and Proprietary Information
	;; of VM Labs, Inc.
	;;
	;; This is a subroutine which accepts as
	;; parameters a target MPE (r0) and a
	;; pointer to a COFF file to load (r1).
	;; It loads that COFF file and starts up
	;; the target MPE.
	;;
	;; asm_load_coff(int mpe, void *coffptr, int flag, void* dtramptr)
	;;
	;; Parameters:
	;; r0 == target MPE number (0-3)
	;; r1 == pointer to COFF file
	;; r2 == flags:
	;;       bit 0: 1 == start the new MPE
	;;              0 == don't start
	;;       bit 1: 1 == halt yourself
	;;              0 == don't halt
	;;
	;; Modified 11/19/98 rwb
	;; r3 == pointer to DTRAM buffer
	;; r4 == pointer to acknowledge packet
	

;.import _loadCOFFHold             ; mrp call so that we can return acknowledge
 
	;; various COFF file constants
	;; NOTE: we assume here that the first
	;; word of the optional header is the
	;; entry point; this is true for files
	;; produced by the Merlin linker
	
	FILE_HEADER_SIZE = 20
	OFF_F_NSCNS = 2			; offset for number of sections
	OFF_F_OPTHDR = 16		; offset for size of optional header
	OFF_F_ENTRYPT = 20		; offset for entry point
	
	SECT_HEADER_SIZE = 44		; size of section header
	OFF_S_PADDR = 8			; offset for physical address
	OFF_S_SIZE = 16			; section size in bytes
	OFF_S_SCNPTR = 20		; file pointer to raw data
	OFF_S_FLAGS = 40		; flags for file
	STYP_NOLOAD = 0x02		; flag: section should not be loaded
	STYP_INFO = 0x200		; flag: section should not be loaded

	;;
	;; data ram usage:
	;; we need a 512 byte buffer in local RAM for DMAs
	;;

;	.segment intdata
; int_buffer:
;	.ds.s	512/4
	
	;;
	;; register usage:
	;;
	;; v0 and v1 are scratch
	;; registers v2-v4 are available
	;; (except for v4[3]
	;;
	filebase = v2[0]	;; base address for file	
	fileptr = v2[1]		;; current location from which to read
	numsecs = v2[2]		;; number of sections to load
	mpebase = v2[3]		;; base address for target MPE
	
	s_flags = v3[0]		;; flags for current section
	s_vaddr = v3[1]		;; destination address for current section
	s_scnptr = v3[2]	;; source address for current section
	s_size = v3[3]		;; size for current section
	
	this_size = v4[0]	;; size of sub-transfer
	entrypt = v4[1]		;; entry point for COFF file
	run_flags = v4[2]	;; flags for whether to start the new MPE, etc.
	
	buffer_base = v5[0]	;; address of DTRAM buffer to be used for transfer
	buffer_ptr = v5[1]	;; current pointer into buffer
	ack_buffer = v5[2]     ;; acknowledge buffer, if 0 don't send an ack_buffer
		
	.text
	.export _asm_load_coff
_asm_load_coff:
	push	v2
	push	v3
	push	v5
	push	v4,rz		;; save rz
	asl	#23,r0,mpebase	;; get the MPE base address
	mv_s	r1,fileptr	;; get the COFF file base address
{	mv_s	r1,filebase	;; and the offset for addresses inside the COFF file
	copy	r2,run_flags
}
	mv_s 	r3, buffer_base ;; buffer_base will always contain base address of DTRAM buffer

         copy  r4, ack_buffer
	;; first make sure the target MPE is halted
	;; this is a two step process: first we reset the MPE
	;; (which will clear out all of its registers),
	;; then we stop it

	jsr	write_register
	add	#addrof(mpectl),mpebase,r1
	mv_s	#(1<<13),r2			; reset the MPE
	
	jsr	write_register
	add	#addrof(mpectl),mpebase,r1
	mv_s	#(1<<2)|1,r2			; now stop it (if it was running)

	;; start by reading the COFF file header
	mv_s	#FILE_HEADER_SIZE+4,r0		; read file header + 1st word of optional header
	jsr	dma_read
{	mv_s	fileptr,r1
	add	r0,fileptr
}
	mv_s	buffer_base, r2


	;; now load up the info from the file header
	;; see the COFF file format guide for details

	add	#OFF_F_NSCNS, buffer_base, buffer_ptr
	ld_w	(buffer_ptr), numsecs			; get number of sections
	add	#OFF_F_OPTHDR, buffer_base, buffer_ptr
	ld_w	(buffer_ptr), r0			; get size of optional header
	add	#OFF_F_ENTRYPT, buffer_base, buffer_ptr
	ld_s	(buffer_ptr), entrypt			
	lsr	#16,numsecs
	lsr	#16,r0
	add	r0,fileptr			; skip optional header
	sub	#4,fileptr			; we already read 4 bytes of optional header,
						; adjust for this
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; loop: for each section, read in the header,
	;; and figure out the source and destination for
	;; data -- then copy the data to its final location
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section_loop:
	; read section header
	mv_s	#SECT_HEADER_SIZE,r0
	jsr	dma_read
{	mv_s	fileptr,r1
	add	r0,fileptr
}
	mv_s	buffer_base,r2

	;; load up info for this section
	add	#OFF_S_FLAGS, buffer_base, buffer_ptr
	ld_s	(buffer_ptr), s_flags			
	add	#OFF_S_PADDR, buffer_base, buffer_ptr
	ld_s	(buffer_ptr), s_vaddr			
	add	#OFF_S_SCNPTR, buffer_base, buffer_ptr
	ld_s	(buffer_ptr), s_scnptr			
	add	#OFF_S_SIZE, buffer_base, buffer_ptr
	ld_s	(buffer_ptr), s_size			
	add	filebase,s_scnptr		;; section pointer is relative to start of file

	;; check for MPE relative addresses; anything in the
	;; MPE 0 address space ($20xxxxxxxx) should be relocated
	;; to the "real" MPE it's running on
	and	#$ff800000,s_vaddr,r0
	cmp	#$20000000,r0
	bra	ne,got_section_data,nop
	
	add	mpebase,s_vaddr			;; address is relative to start of MPE
	
got_section_data:	
	ftst	#STYP_NOLOAD,s_flags		;; is this section loadable?
	bra	ne,skip_section,nop
	ftst	#STYP_INFO,s_flags
	bra	ne,skip_section,nop

	;; OK, now copy s_size bytes from s_vaddr to s_scnptr
copy_section:
	;;
	;; copy at most 256 bytes
	;;
	cmp	#0,s_size
	bra	le,skip_section,nop
copy_loop:
	mv_s	#256,this_size
	cmp	this_size,s_size		; if s_size - this_size >= 0, use this_size
	bra	ge,`size_ok,nop
	copy	s_size,this_size		; otherwise, use s_size
`size_ok:
	;; read this_size bytes from s_scnptr
	mv_s	this_size,r0
	jsr	dma_read
{	mv_s	s_scnptr,r1
	add	this_size,s_scnptr
}
	mv_s	buffer_base,r2

	;; write this_size bytes to s_vaddr
	mv_s	this_size,r0
	jsr	dma_write
{	mv_s	s_vaddr,r1
	add	this_size,s_vaddr
}
	mv_s	buffer_base,r2

	;; now update count of bytes left to copy
	sub	this_size,s_size
	bra	gt,copy_loop,nop
	
skip_section:
	sub	#1,numsecs
	bra	gt,section_loop
	nop
	nop

setup_mpe:

	;; see if the new MPE should be programmed to
	;; start

	btst	#0,run_flags
	bra	eq,dont_start_mpe,nop
	
	;; OK, all data should be in place now
	;; let's set up the target MPE to execute

	;; first, check to see what state it's in
	jsr	read_register
	add	#addrof(mpectl),mpebase,r1
	nop

	bits	#3,>>#24,r0		; extract cycle type
	cmp	#$f,r0			; is it reset0?
	bra	eq,`skipreset,nop	; if it is, don't reset it

	jsr	write_register
	add	#addrof(mpectl),mpebase,r1
	mv_s	#(1<<23)|(9<<24),r2	; set to "jump nop 1" state
	
`skipreset:

	;; wait for DMA to finish
`odmawait:
	jsr	read_register
	add	#addrof(odmactl),mpebase,r1
	nop

	bits	#4,>>#0,r0
	bra	ne,`odmawait,nop
	
`mdmawait:
	jsr	read_register
	add	#addrof(mdmactl),mpebase,r1
	nop

	bits	#4,>>#0,r0
	bra	ne,`mdmawait,nop
	
	;; disable level 1 interrupts
	jsr	write_register
	add	#addrof(inten1),mpebase,r1
	mv_s	#0,r2

	;; mask interrupts
	jsr	write_register
	add	#addrof(intctl),mpebase,r1
	mv_s	#$aa,r2
	
	;; clear all exceptions
	jsr	write_register
	add	#addrof(excepclr),mpebase,r1
	mv_s	#-1,r2

	;; clear commctl
	jsr	write_register
	add	#addrof(commctl),mpebase,r1
	mv_s	#0,r2
	
	;; set PC to the entry point
	jsr	write_register
	add	#addrof(pcfetch),mpebase,r1
	mv_s	entrypt,r2

         jsr    send_host_ack, nop
         
	;; start the MPE!
	jsr	write_register
	add	#addrof(mpectl),mpebase,r1
	mv_s	#2,r2
	bra    ack_already_sent, nop
	
dont_start_mpe:
	;; see if we should halt ourselves
	;; bit 1 == 1 says to halt

         jsr    send_host_ack, nop

ack_already_sent:
	btst	#1,run_flags
	bra	eq,return,nop

	halt
	nop
	nop
	
return:
	pop	v4,rz
	pop	v5
	pop	v3
	rts
	pop	v2

	halt
	nop
	nop
	nop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; subroutine: write_register
	; write data to one register in another MPE
	; parameters:
	; r1 == register to write to
	; r2 == data to write
write_register:
	st_s	r2, (buffer_base)
	bra	dma_write
	mv_s	buffer_base,r2
	mv_s	#4,r0			; write 4 bytes
	
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ; subroutine: read_register
       ; read data from another MPE
       ; parameters:
       ; r1 == register to read
       ; return value:
       ; r0 == value of that register
read_register:
       push    v1,rz
       jsr     dma_read
       mv_s    buffer_base,r2
       mv_s    #4,r0                   ; read 4 bytes

       pop     v1,rz
       ld_s    (buffer_base),r0
       rts
       nop
       nop

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; subroutine dma_write:
	; write up to 256 bytes from external RAM
	; into internal RAM
	;
	; parameters:
	; r0 == size
	; r1 == external address
	; r2 == internal address
	;
	; Registers modified:
	; v0, v1
	;
	; Stack used:
	; 4 long words (used as a DMA transfer buffer)
	;

	; internal register usage
	dma_size = r0
	dma_extaddr = r1
	dma_intaddr = r2
	dma_flags = r3

	dma_addr = r4
	xfer_size = r5
	temp0 = r6
	dma_ctlreg = r7

dma_write:
	bra	common_dma	; next two instructions are in delay slots
	nop
	;; fall through to dma_read -- note that the
	;; first instruction of dma_read also gets executed
	;; by dma_write!!!


	;
	; subroutine dma_read:
	; read up to 256 bytes from external RAM
	; into internal RAM.
	;
	; parameters:
	; r0 == external address
	; r1 == internal address
	; r2 == number of bytes
	;
	; Registers modified:
	; v0, v1
	;
	; Stack used:
	; 4 long words (used as a DMA transfer buffer)
	;
dma_read:
	;;;; NOTE NOTE NOTE: first instruction of dma_read
	;;;; is also executed by dma_write above (it is
	;;;; in a delay slot)
	mv_s	#0,dma_flags
	bset	#13,dma_flags		; set read bit

	; fall through

	;
	; Common subroutine, used for both
	; reads and writes
	;
	
common_dma:
	; round up to next largest number of longwords
{	add	#3,dma_size,xfer_size
	mv_s	dma_flags,r0
}
{	and	#~3,xfer_size
	mv_s	dma_extaddr,temp0
}
	; check for system bus vs. other bus
	; (use the top 4 nybbles)
	bits	#3,>>#28,temp0
	cmp	#4,temp0
{	mv_s	#addrof(mdmactl),dma_ctlreg	; assume main bus
	bra	eq,`bus_ok,nop
}
	;; other bus -- check for other bus bug
	; see if the transfer will end on a "fatal" boundary;
	; if so, do 1 more longword
{	add	xfer_size,dma_extaddr,temp0
	mv_s	#addrof(odmactl),dma_ctlreg
}
	and	#$3fc,temp0
	cmp	#$3fc,temp0
{	bra	ne,`bus_ok,nop
}
	add	#4,xfer_size		; transfer an extra long word to avoid bug
`bus_ok:
	or	xfer_size,>>#-(16-2),r0
	push	v0			; create space on the stack for the DMA command
	ld_io	sp,dma_addr		; get a pointer to the created space

	;; wait for dma to go idle
`wait1:
	ld_s	(dma_ctlreg),temp0
	nop
	bits	#4,>>#0,temp0
	bra	ne,`wait1,nop

	add	#16,dma_ctlreg		; point to the cptr register
	st_s	dma_addr,(dma_ctlreg)	; start the DMA
	sub	#16,dma_ctlreg		; point back at the control register
	
	;; wait for dma to finish
`wait2:
	ld_s	(dma_ctlreg),temp0
	nop
	bits	#4,>>#0,temp0
	bra	ne,`wait2,nop
	
	rts				; return
	pop	v0			; restore the stack pointer
	nop

; subroutine send ack to host
; if we made it this far send back
; an acknowledgement packet to the
; waiting host

send_host_ack:
	push v0, rz
	push v1
	
	cmp #0, ack_buffer
	bra eq, JustReturn, nop
	
	ld_s  (ack_buffer), v1[0]
	add  #4, ack_buffer
	ld_s  (ack_buffer), v1[1]
	add  #4, ack_buffer
	ld_s  (ack_buffer), v1[2]
	add  #4, ack_buffer
	ld_s  (ack_buffer), v1[3]         	
         nop

`t1:
	ld_s	(commctl), r1
	nop
	btst	#15, r1
	bra	ne, `t1, nop
				
	st_s	#($48 | 1<<13), (commctl) 
	st_v	v1, (commxmit)
    
HostAckSent:
	ld_s	(commctl), r1
	nop
	btst	#15, r1
	bra	ne, HostAckSent, nop

JustReturn:
         pop v1
	pop v0, rz
	nop
	rts
	nop
	nop
	


	

