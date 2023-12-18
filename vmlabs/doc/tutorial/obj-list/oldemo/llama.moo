
;
; llama.moo = a MacrOObject that
; defines a vector llama

llm:

; header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$02000000		;4 longs of secondary space
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0			;local secondary data

	.dc.s	llm_end-llm		;length
	.dc.s	0				;init routine (called when object is first generated)
	.dc.s	0,0

	.dc.s	0,0,0,0

; ranges

    .dc.s   0,0,0,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,0

; local secondary data space

    .dc.s   llama       ;vector list address
    .dc.s   $01000100   ;scales

; command

    .ascii  "_a=h"      ;set VL address
    .ascii  "_b=e:"     ;set scales        

    .align.v

llm_end: