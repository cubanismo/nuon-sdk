
;
; llama4.moo = a MacrOObject that
; defines a vector llama with slightly
; more complex motion

llm4:

; header

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$03060000		;3 longs secondary, 6 vects params
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	lineobj	    ;prototype to use
	.dc.s	0				;no secondary data

	.dc.s	llm4_end-llm4		;length
	.dc.s	0				;init routine (called when object is first generated)
	.dc.s	0,0

	.dc.s	0,0,0,0

; variables

 	.dc.s   $b00000     ;xpos
    .dc.s   $10000      ;vel
    .dc.s   $10000      ;fr.
    .dc.s   $80000201   ;mode (bounce), limits

 	.dc.s   $200000     ;ypos
    .dc.s   $0          ;vel
    .dc.s   $10000      ;fr.
    .dc.s   $80000202   ;mode (bounce), limits

    .dc.s   0
    .dc.s   0
    .dc.s   $18000
    .dc.s   2           ;sine wave

    .dc.s   0
    .dc.s   0
    .dc.s   $13000
    .dc.s   2           ;another sine wave

    .dc.s   0
    .dc.s   0
    .dc.s   $23000
    .dc.s   2           ;another sine wave
    
    .dc.s   0
    .dc.s   0
    .dc.s   $2c000
    .dc.s   2           ;another sine wave
    
    

; ranges

    .dc.s   $400000,$1080000,$c00000,-$60
    .dc.s   $80,-$40,$40,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,0

; local secondary data space

    .dc.s   llama       ;vector list address
    .dc.s   $01000100   ;scales
    .dc.s   $600        ;constant to add to Y velocity    

; command

    .ascii  "_c+B1=B1"  ;add _c to B1
    .ascii  "A0!=a<"    ;set xpos
    .ascii  "C*D[34]+a<=a<"     ;offset xpos
    .ascii  "B0!=a>"    ;set ypos
    .ascii  "E*F[56]+a>=a>"     ;offset ypos
    .ascii  "_a=h"      ;set VL address
    .ascii  "_b=e:"     ;set scales        

    .align.v

llm4_end: