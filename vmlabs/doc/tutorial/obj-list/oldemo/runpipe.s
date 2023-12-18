	.module	runpipe
	.export StartMPE
	.export CloneMPE
;    .export WaitForMPE
	
	.segment local_ram
	.align.v
DMACMD:
	.dc.s	0,0,0,0
SCRATCH:
	.dc.s	0,0,0,0

MASTER_MPE = 0

	.segment instruction_ram
	
	;
	; start an (already loaded) MPE
	;
	; registers used:
	; all but v7
	
	; vector registers v3-v7 are working registers
	dma_vect	=	v3
	dma_size	=	dma_vect[0]
	dma_extaddr	=	dma_vect[1]
	dma_intaddr	=	dma_vect[2]
	dma_flags	=	dma_vect[3]

	dma_ctlreg	=	v4[0]
	temp0		=	v4[1]
	temp1		=	v4[2]
	subr		=	v4[3]

	xfer_size	=	v5[0]
	max_size	=	v5[1]	; max. size of a DMA transfer
	cur_size	=	v5[2]	; current size of DMA transfer
	mpe_counter	=	v5[3]
	
	use_self	=	v6[0]
	listptr		=	v6[1]
	mpe_base	=	v6[2]
	x_num_mpes	=	v6[3]	; copy of num_mpes

	;
	; StartMPE
	; start an MPE up at the base of iram
	; parameters: r0 == mpe number
	;             r1 == flag: 0 means start from base of iram
        ;                         1 means restart from present pc
    ; modified by yak
    ; now passes v1 from the caller to v0 in the MPE being started
    
	
StartMPE:
	push	v7,rz
	
	;
	; we have to set up the following values:
	;
	; pcfetch == base of iram (only if r1 is non-zero)
        ; usejoyval == value to use for the joystick
        ;
        ; excepclr == 1 (clears the "halt" bit)
	; mpectl == 2 (sets the "go" bit)
	;
	mv_s	#SetScalar,subr

	copy	r0,mpe_base
	asl	#23,mpe_base
	
        cmp     #0,r1
	; set pcfetch if r1 == 0
	jsr	eq,(subr)
	mv_s	#addrof(pcfetch),dma_extaddr	; pcfetch register address
{	add	mpe_base,dma_extaddr
	mv_s	#$20300000,temp0	; initial pc value
}

        ; set excepclr
        jsr     (subr)
        mv_s    #addrof(excepclr),dma_extaddr
{       add     mpe_base,dma_extaddr
        mv_s    #1,temp0
}

    ;set  r0
    mv_s    r4,temp0
    jsr (subr)
    mv_s    #addrof(r0),dma_extaddr
    add     mpe_base,dma_extaddr
    
    ;set r1
    mv_s    r5,temp0
    jsr (subr)
    mv_s    #addrof(r1),dma_extaddr
    add     mpe_base,dma_extaddr
    
    

    ;set r2
    jsr (subr)
    mv_s    #addrof(r2),dma_extaddr
{   add     mpe_base,dma_extaddr
    mv_s    r6,temp0
}
    ;set r3
    jsr (subr)
    mv_s    #addrof(r3),dma_extaddr
{   add     mpe_base,dma_extaddr
    mv_s    r7,temp0
}

    

	; finally, set mpectl
	jsr	(subr)
	mv_s	#addrof(mpectl),dma_extaddr	; MPE control register address
{	add	mpe_base,dma_extaddr	
	mv_s	#2,temp0		; MPE GO bit
}

	pop	v7,rz
	nop
	rts
	nop
	nop
	
	;
	; CloneMPE: copies the current iram and dtram (4K of each)
	; into another MPE
	;
	; parameters: r0 == destination MPE
	;
	
CloneMPE:
	push	v7,rz
	
	copy	r0,mpe_base
	asl	#23,mpe_base

; copy iram
	mv_s	#0,dma_flags		; DMA write
	mv_s	#4*1024,dma_size	; size for DMA
	jsr	do_dma
	mv_s	#$20300000,dma_extaddr
{	mv_s	dma_extaddr,dma_intaddr
	add	mpe_base,dma_extaddr
}

; copy dtram
	mv_s	#0,dma_flags		; DMA write
	mv_s	#4*1024,dma_size	; size for DMA
	jsr	do_dma
	mv_s	#$20100000,dma_extaddr
{	mv_s	dma_extaddr,dma_intaddr
	add	mpe_base,dma_extaddr
}
	pop	v7,rz
	nop
	rts
	nop
	nop
	
	; 
	; SetScalar: set a single word in another MPE
	; temp0 == value to set
	; dma_extaddr == external address
	;
	; GetScalar: get a single word from another MPE
	; dma_extaddr == external address
	; dma_flags must be set up appropriately
	;
	
SetScalar:
	mv_s	#0,dma_flags
{	mv_s	#4,dma_size
;;	bra	do_dma
}
	mv_s	#SCRATCH,dma_intaddr
	st_s	temp0,(dma_intaddr)	; set up for DMA
	
	; fall through to "do_dma"

	;
	; subroutine:
	; given that dma_vect is set up with appropriate values,
	; launch a DMA, and wait for it to complete
	;
do_dma:

	; round up to next largest number of bytes
	add	#3,dma_size,xfer_size
{	and	#~3,xfer_size
	mv_s	#63*4,max_size		; max. transfer size in bytes
}

	; check for which DMA to use (main bus or other bus)
.if 1
	mv_s	#addrof(mdmactl),dma_ctlreg
	btst	#31,dma_extaddr
	bra	eq,start_xfer,nop
.endif
	mv_s	#addrof(odmactl),dma_ctlreg

start_xfer:
	;
	; Figure out how many bytes to DMA this time
	;
	cmp	max_size,xfer_size
	bra	ge,bigxfer		; if (xfer_size - max_size >= 0, use max_size)
	mv_s	max_size,dma_size
	nop
	
	mv_s	xfer_size,dma_size

bigxfer:
{	mv_s	dma_size,cur_size
	asl	#(16-2),dma_size	; put in the upper 16 bits, as words
}
	or	dma_flags,dma_size	; now DMA flags are set up for longword read


	; wait for DMA pending to go clear
wait_pending:
	ld_s	(dma_ctlreg),temp0
	nop
;;	btst	#4,temp0
	bits	#4,>>#0,temp0
        and     #$f,temp0
	bra	ne,wait_pending
	mv_s	#DMACMD,temp1
	nop
	
{	st_v	dma_vect,(temp1)
	add	#16,dma_ctlreg		; point to control register
}
	; launch the DMA
	st_s	temp1,(dma_ctlreg)	; start DMA
	sub	#16,dma_ctlreg

	; update DMA variables
	add	cur_size,dma_extaddr
	add	cur_size,dma_intaddr
	sub	cur_size,xfer_size
	bra	gt, start_xfer,nop
	
	; wait for the DMA to finish
wait_dma:
	ld_s	(dma_ctlreg),temp0
	nop
	bits	#4,>>#0,temp0
	bra	ne,wait_dma
	rts
	nop
	nop


