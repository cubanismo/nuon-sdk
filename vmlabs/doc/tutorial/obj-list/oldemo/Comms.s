;*********
;
; comm bus thangs
;
;*********

	transmit_lock = 12
	transmit_retry = 13
	transmit_failed = 14
	transmit_buffer_full = 15
	receive_disable = 30
	receive_buffer_full = 31


SendVectorTo:

; send a vector to the ID# in r4

	st_s	r4,commctl		; set target to send
	st_v	v0,commxmit		; put the vector on the bus
svtwait:
	ld_s	commctl,r5				; wait for transfer to occur
	nop
	btst	#transmit_failed,r5			; check for transmit failed
	bra		ne,SendVectorTo						; if failed, re-send
	btst	#transmit_buffer_full,r5	; check for buffer empty
	bra		ne,svtwait					; if not empty, keep waiting
	rts
	nop
	nop	


GetVector:

; waits to receive a vector from the comm bus

	ld_s	commctl,r5				; get bus status
	nop
	btst	#receive_buffer_full,r5		; wait for Receive Buffer Full
	bra		eq,GetVector				; not ready if this is 0
	rts									; return
	nop
	ld_v	commrecv,v0				; fetch the vector into v0

