;
; cls3.moo = a MacrOObject that
; clears a block of screen.
;
; This one has three wave variables.

bobord:

	.dc.s	0		    ;Prev
	.dc.s	0			;Next
	.dc.s	$1000000		;length of param block (3 vectors)
   	.dc.s	0           ;param address, if not local

	.dc.s	null_ranges	        ;Address of ranges table, if not local
	.dc.s	0	        ;this'll be where the command string is, if not local
	.dc.s	clsobj      ;here's the proto
	.dc.s	0

    .dc.s   bobord_end-bobord   ;total object size
    .dc.s   0                   
    .dc.s   0,0

    .dc.s   0           
    .dc.s   0           
    .dc.s   0          
    .dc.s   0           ;Time slew


    
; sec data

    .dc.s   bo_rectlist

; This Object also has a local command string.

    .ascii  "_a=e:"

	.align.v

bobord_end:

; might as well shove the rect list in here.

bo_rectlist:

    .dc.s   $00180010
    .dc.s   $000600e0
    .dc.s   $f0808000
    .dc.s   0

    .dc.s   $01200010
    .dc.s   $000600e0
    .dc.s   $f0808000
    .dc.s   0

    .dc.s   $00180010
    .dc.s   $01080006
    .dc.s   $f0808000
    .dc.s   0

    .dc.s   $80000000
    .dc.s   0
    .dc.s   0
    .dc.s   0
    
    