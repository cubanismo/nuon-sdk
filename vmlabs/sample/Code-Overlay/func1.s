	;;
	;; Overlay sample code
	;;
	;; Copyright 1997 VM Labs, Inc.
	;; All rights reserved.
	;; This file is confidential and proprietary
	;; information of VM Labs disclosed pursuant
	;; to the non-disclosure agreement between
	;; VM Labs and the Recipient.

	
	;
	; first overlay (code + data)
	;

	;
	; the code...
	;
	.overlay func1
	.origin code_overlay
func1entry1:
{	before  (format #t "~%Called func1entry1");
	ld_s	func1data,r0
}
	rts
	add	#1,r0
	nop
	nop

	;
	; and its data
	;
	.overlay data1
	.origin data_overlay
func1data:
	.dc.s	$f00d0000

