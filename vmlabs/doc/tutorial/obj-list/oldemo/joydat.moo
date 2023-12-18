;
; joydat.moo = a MacrOObject that
; displays the state of the joystick.

joydat_s:

	.dc.s	0		    ;Prev
	.dc.s	0			;Next
	.dc.s	($02000080|lister)	    	;length of param block
   	.dc.s	0           ;param address, if not local

	.dc.s	null_ranges	    ;Address of ranges table, if not local
	.dc.s	0	            ;this'll be where the command string is, if not local
	.dc.s	chscreenobj2          ;here's the proto
	.dc.s	0

    .dc.s   joydat_s_end-joydat_s   ;total object size
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0

    .dc.s   charmap2,status+12

    .ascii  "_a=c"
    .ascii  "_b=d:"

	.align.v

joydat_s_end: