	;;
	;; Overlay sample code
	;;
	;; Copyright 1997 VM Labs, Inc.
	;; All rights reserved.
	;; This file is confidential and proprietary
	;; information of VM Labs disclosed pursuant
	;; to the non-disclosure agreement between
	;; VM Labs and the Recipient.
	;;

	.start startup

	.include "overlay.s"

	.segment instruction_ram
startup:
	; set up the MPE
	st_s	#stack_top,sp
	st_s	#$20,odmactl

	; load the first data overlay
{	mv_s	#_data1_start,r0
	jsr	load_overlay
}
	mv_s	#data_overlay,r1
	mv_s	#_data1_size,r2

	; load the first code overlay
{	mv_s	#_func1_start,r0
	jsr	load_overlay
}
	mv_s	#code_overlay,r1
	mv_s	#_func1_size,r2

	; now run the first code overlay
	jsr	func1entry1,nop

run_second:

	; and load the second data overlay
{	mv_s	#_data2_start,r0
	jsr	load_overlay
}
	mv_s	#data_overlay,r1
	mv_s	#_data2_size,r2

	; load the second code overlay
{	mv_s	#_func2_start,r0
	jsr	load_overlay
}
	mv_s	#code_overlay,r1
	mv_s	#_func2_size,r2

	; now run the second code overlay
	jsr	func2entry1
	nop
	nop

	; try the second entry point now
	jsr	func2entry2
	nop
	nop

done_second:

	; finally, halt
	halt
	nop
	nop

	;
	; space for the code overlay... make sure
	; this starts on a 16 byte boundary
	;

	.align 16
code_overlay:


	.segment local_ram

	;
	; space for the stack
	;
stack_bot:
	.ds.s	256
stack_top:

	;
	; space for the data overlay; again, we'll
	; make sure it starts on a 16 byte boundary
	; (in case it has vector data)
	;

	.align.v
data_overlay:



	.include "func1.s"
	.include "func2.s"
