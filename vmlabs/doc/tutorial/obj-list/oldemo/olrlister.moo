;
; olrlister.moo = a MacrOObject that
; displays the first 5 OLR objects on a charactermap overlay.

olrl_s:

	.dc.s	0		    ;Prev
	.dc.s	0			;Next
	.dc.s	($02000080|lister)	    	;length of param block
   	.dc.s	0           ;param address, if not local

	.dc.s	null_ranges	    ;Address of ranges table, if not local
	.dc.s	0	            ;this'll be where the command string is, if not local
;	.dc.s	clsobj          ;here's the proto
	.dc.s	chscreenobj          ;here's the proto
	.dc.s	0

    .dc.s   olrl_s_end-olrl_s   ;total object size
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0

    .dc.s   charmap,ROLRam

    .ascii  "_a=c"
    .ascii  "_b=d:"

	.align.v

olrl_s_end: