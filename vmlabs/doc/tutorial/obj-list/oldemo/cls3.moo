;
; cls3.moo = a MacrOObject that
; clears a block of screen.
;
; This one has three wave variables.

cl_s3:

	.dc.s	0		    ;Prev
	.dc.s	0			;Next
	.dc.s	$30000		;length of param block (3 vectors)
   	.dc.s	0           ;param address, if not local

	.dc.s	0	        ;Address of ranges table, if not local
	.dc.s	0	        ;this'll be where the command string is, if not local
	.dc.s	clsobj      ;here's the proto
	.dc.s	0

    .dc.s   cl_s3_end-cl_s3   ;total object size
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0

; Now, here are vectors describing the waves.

    .dc.s   0       ;This is the base phase.
    .dc.s   0       ;This is the phase offset.
    .dc.s   $a000 ;This is the wave's speed.
    .dc.s   2       ;This is the Type - a Sine wave.

    .dc.s   0       ;This is the base phase.
    .dc.s   0       ;This is the phase offset.
    .dc.s   $f000 ;This is the wave's speed.
    .dc.s   2       ;This is the Type - a Sine wave.

    .dc.s   0       ;This is the base phase.
    .dc.s   0       ;This is the phase offset.
    .dc.s   $16000 ;This is the wave's speed.
    .dc.s   2       ;This is the Type - a Sine wave.


; This Object now has a local Ranges table.

    .dc.s   0       ;Zero is always udeful.
    .dc.s   $14     ;This is the minimum colour value.
    .dc.s   $f0     ;This is the maximum.
    .dc.s   $0       ;No other ranges are defined yet.
    
    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   0
    
    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   0
    
    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   0
    
; This Object also has a local command string.

    .ascii  "A[12]=c0"    
    .ascii  "B[12]=c1"    
    .ascii  "C[12]=c2:"    

	.align.v

cl_s3_end: