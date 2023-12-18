;
; cls.moo = a MacrOObject that
; clears a block of screen.

cl_s:

	.dc.s	0		    ;Prev
	.dc.s	0			;Next
	.dc.s	0	    	;length of param block
   	.dc.s	0           ;param address, if not local

	.dc.s	null_ranges	    ;Address of ranges table, if not local
	.dc.s	null_command	;this'll be where the command string is, if not local
	.dc.s	clsobj          ;here's the proto
	.dc.s	0

    .dc.s   cl_s_end-cl_s   ;total object size
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0

	.align.v

cl_s_end: