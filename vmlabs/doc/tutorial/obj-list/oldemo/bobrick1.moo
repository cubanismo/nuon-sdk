;
; cls3.moo = a MacrOObject that
; clears a block of screen.
;
; This one has three wave variables.

bobrick1:

	.dc.s	0		    ;Prev
	.dc.s	0			;Next
	.dc.s	$2030000		;length of param block (3 vectors)
   	.dc.s	0           ;param address, if not local

	.dc.s	0	        ;Address of ranges table, if not local
	.dc.s	0	        ;this'll be where the command string is, if not local
	.dc.s	clsobj      ;here's the proto
	.dc.s	0

    .dc.s   bobrick1_end-bobrick1   ;total object size
    .dc.s   $0504       ;Event=#5, Init=#4
    .dc.s   0,0

    .dc.s   ($100000|COINF0)             ;(EVNTEN|??????) - enable Collision Event
    .dc.s   $000f0007           ;Collision Size (X|Y)
    .dc.s   (COBOX|CODBEN|COLEN) ;Events|Collision Flags)
    .dc.s   0           ;Time slew


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
    
; sec data

    .dc.s   0           ;pos
    .dc.s   $000e0006   ;size

; This Object also has a local command string.

    .ascii  "_a=a"
    .ascii  "_b=b"
    .ascii  "A[12]=c0"    
    .ascii  "B[12]=c1"    
    .ascii  "C[12]=c2:"    

	.align.v

bobrick1_end: