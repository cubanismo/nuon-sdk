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
	; second overlay
	;

	.overlay func2
	.origin code_overlay
func2entry1:
	ld_s	func2data,r0
	st_s	#2,rc0

powerloop:
	mul	r0,r0,>>#0,r0	; square r0
	dec	rc0
	bra	c0ne,powerloop
	nop
	nop

goback:
{	nop
	after (format #t "~%returning from func2entry1")
}
	rts
	nop
	nop

	;
	; another entry point for the
	; overlay; it does something else
	;
	
func2entry2:
	rts
	ld_s	data2foo,r0
	nop
	
	.overlay data2
	.origin data_overlay
data2foo:
	.dc.s	$f00f0022
func2data:
	.dc.s	3
	