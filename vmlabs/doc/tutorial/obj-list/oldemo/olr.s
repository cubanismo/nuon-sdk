; olr.s
;
; here's the cool stuff you need to run OLR.
    

InitBinaries:

; set up the Routines table with code and data addresses and sizes

	push	v1,rz
    mv_s    #binaries,r4        ;origin of binary code in external ram
    mv_s    #routines,r5        ;address of routines table in local ram
    mv_s    #0,r6               ;count
    mv_s    #_routines,r7       ;external RAM address of routines-table

gebin:

    mv_s    #2,r0       ;get 2 longs
    jsr dma_read
    mv_s    r4,r1       ;from current pointer
    mv_s    #buffer,r2  ;to the buffer        
    jsr dma_finished,nop    ;make sure it's in.
    ld_v    buffer,v0       ;get the stuff
    nop
    mv_s    #$f00baaaa,r2
    cmp r2,r0       ;end of list marker
    bra eq,bindone
    add #8,r4,r8            ;Address of start of code/data in xram
    copy    r0,r9           ;Target address
    lsr #2,r1           ;length to longs
    sub #2,r1,r10        ;minus the two data longs
    st_v    v2,(r5)     ;lay down data
    lsl #2,r1           ;length back to bytes
    add r1,r4           ;point to next data block

    push    v0          ;write the vector out to the table in external ram
    mv_s    #4,r0
    jsr dma_write
    mv_s    r5,r2
    mv_s    r7,r1
    jsr dma_finished,nop
    bra gebin
    pop v0
    add #16,r7

bindone:

; write a copy of the Routines table to external RAM

	pop	v1,rz
	nop
	rts	t,nop


; Run the OLR on the MPEs that are specified


LoadRunOLR_Oneshot:

    sub r3,r3
    bra mr2

RunOLR_Oneshot:

    bra mr2
    st_s    #1,param0 

RunOLR:

    mv_s    #1,r3           ;1 means ignore load
    bra mr,nop

;multi_load_and_run:

LoadRunOLR:


; load and run a routine from the Routines list
; on all the MPEs specified in the OLR params
;
; params: r0 = Routine number

    mv_s    #0,r3           ;zero means do load
mr:
    st_s    #0,param0
mr2:
    mv_s    #olr,r0
    push    v1,rz
    mv_v    v0,v1           ;move v0 away

    lsl #5,r4               ;routine table entries are 32 bytes
    mv_s    #base_mpe,r6           ;MPE number
    st_s    #n_mpes,rc0       
    mv_s    #_routines,r0    ;get routine table base
    add r0,r4               ;here's the address of the routine

; load in the relevant 2 vectors

    mv_s    #8,r0
    jsr dma_read
    mv_s    r4,r1
    mv_s    #routines,r2
    jsr dma_finished,nop

    mv_s    #routines,r4    

    
mrun:

; okay, load is required, set it up.   
; first, set the MPE's long in STATUS to "active"
    
    lsl #2,r6,r0
    mv_s    #status+16,r1
    add r0,r1
    mv_s    #1,r0
    jsr dma_write
    st_s    r0,buffer
    mv_s    #buffer,r2
    jsr dma_finished,nop

; if this is run-only, skip load

    cmp #0,r7
    bra ne,run_only

{
   ld_s (r4),r1         ;external RAM address of code section
   add  #4,r4  
}
{
    ld_s (r4),r0        ;MPE address of code section
    add #4,r4
    jsr load_remote ;call load-remote with data address
}
{
    ld_s    (r4),r3     ;size of load, in longs
    add #8,r4           ;point to the data
}
    copy    r6,r2       ;target MPE number            

; now load the data

{
   ld_s (r4),r1         ;external RAM address of code section
   add  #4,r4  
}
{
    ld_s (r4),r0        ;MPE address of code section
    add #4,r4
    jsr load_remote ;call load-remote with data address
}
{
    ld_s    (r4),r3     ;size of load, in longs
    sub #24,r4          ;point back to the code
}
    copy    r6,r2       ;target MPE number  

run_only:

; and now start up that MPE

    copy    r6,r0
    push    v1
    ld_s    olbase,r7               ;current object or list
    ld_s    dest,r6                 ;send the current screen address
    ld_s    ctr,r5
    jsr StartMPE
    ld_s    param0,r4               ;param appears in r0 on target
    sub r1,r1                       ;start from base of IRAM
    pop v1
    
    
not_this_time:

    dec rc0             ;loop for them all
    bra c0ne,mrun
    add #1,r6           ;target MPE ++
    nop

    pop v1,rz
    nop
    rts t,nop           ;done

WaitMPEs:

; wait till all OLR MPEs are finished

    push    v1
    push    v0,rz

w3:

    jsr get_stat,nop

    mv_s    #(buffer+16+(base_mpe<<2)),r4   ;MPE status longs are here
    mv_s    #n_mpes,r5      ;how many rendering MPEs
    sub r7,r7               ;accumulate results here

wget:

    ld_s    (r4),r6         
    add #4,r4
    sub #1,r5
    bra gt,wget
    or  r6,r7
    nop
    bra ne,w3,nop

    pop v0,rz
    pop v1
    rts t,nop


run1:

; load and run ONE MPE with params passed specified in v1. 
; r0 = Routine number; r1 = MPE #

    push    v2,rz
    push    v1
    mv_v    v0,v1

    lsl #2,r5,r1
    mv_s    #status+16,r2
    add r2,r1
    mv_s    #1,r0
    jsr dma_write
    st_s    r0,buffer
    mv_s    #buffer,r2
    jsr dma_finished,nop



    lsl #5,r4               ;routine table entries are 32 bytes

    mv_s    #_routines,r0    ;get routine table base
    add r0,r4               ;here's the address of the routine

; load in the relevant 2 vectors

    mv_s    #8,r0
    jsr dma_read
    mv_s    r4,r1
    mv_s    #routines,r2
    jsr dma_finished,nop

    mv_s    #routines,r4    


{
   ld_s (r4),r1         ;external RAM address of code section
   add  #4,r4  
}
{
    ld_s (r4),r0        ;MPE address of code section
    add #4,r4
    jsr load_remote ;call load-remote with data address
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
    jsr load_remote ;call load-remote with data address
}
{
    ld_s    (r4),r3     ;size of load, in longs
    sub #24,r4          ;point back to the code
}
    copy    r5,r2       ;target MPE number  

    jsr StartMPE
{
    pop v1
    copy    r5,r0
}
    sub r1,r1                       ;start from base of IRAM
    pop v2,rz
    nop
    rts t,nop   
    
    
    
load_remote:

; load remote onto another MPE from external RAM.
; load address is in r0.
; external address is in r1.
; target MPE number is in r2.
; size of load in longs in r3.

    push    v0,rz
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

InitOLREnv:

; initialise default environment on remote MPEs

    push    v1,rz
    mv_s    #n_mpes,r4          ;total # of rendering MPEs
    mv_s    #base_mpe,r5        ;base MPE of rendering MPEs       

ide:

    mv_s    #init_env,r0        ;internal address in remote MPE space
    mv_s    #init_state,r1      ;external address of data to load
    jsr load_remote         
    copy    r5,r2               ;MPE #
    mv_s    #24,r3              ;length of load

    add #1,r5
    sub #1,r4
    bra gt,ide,nop              ;loop for all rendering MPEs
    pop v1,rz
    nop
    rts t,nop

; the following stuff is taken from Eric's "runpipe"
; StartMPE is modified to set up some values in the
; target MPE r0-r3.

	.segment local_ram
	.align.v
DMACMD:
	.dc.s	0,0,0,0
SCRATCH:
	.dc.s	0,0,0,0
	.segment instruction_ram


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


get_stat:

; get the status vector

    push    v1,rz
    jsr dma_finished,nop
    mv_s    #8,r0
    jsr dma_read
    mv_s    #status,r1
    mv_s    #buffer,r2
    jsr dma_finished,nop
    pop v1,rz
    ld_v    buffer,v0
    rts t,nop
    
put_stat:            

; put the status vector (v0)

    push    v1,rz
    st_v    v0,buffer
    jsr dma_finished,nop
    mv_s    #4,r0
    jsr dma_write
    mv_s    #status,r1
    mv_s    #buffer,r2
    jsr dma_finished,nop
    pop v1,rz
    nop
    rts t,nop
