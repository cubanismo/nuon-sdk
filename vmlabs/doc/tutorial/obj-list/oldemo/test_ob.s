; test_ob.s
;
; this is a test module to check the Object List renderer
; is running correctly.  All it does is fill horizontal
; strips of the screen full of a colour depending on what
; our MPE number is...

	.include	"ol_render.s"	;common base code an' stuff

	.segment	local_ram

; it'll use the default environment, naturally...

;_base   = init_env

;ctr = _base
;mpenum = ctr+4
;logical_mpenum = mpenum+4
;memstat = logical_mpenum+4
;dest_screen = _base+16
;dest = dest_screen+4
;rzinf = dest_screen+16
;object = rzinf+16
;dma__cmd = object+64
;ol_buffer = dma__cmd+32

;RecipLUT = dma__cmd+128
;SineLUT = RecipLUT+512
;RSqrtLUT = SineLUT+1024
;olp = RSqrtLUT+768



dma_direct = $8000000

	.origin	olp		;dummy
	.dc.s	0
	.segment	instruction_ram


test_ob:

	start_line = r8
	end_line = r9
	fill_colour = r10
	dma_size = r11
	h_pos = r12
	h_size = r13

	push	v0,rz		;save return address


; Right.  Get our logical MPE number and load a colour.

	ld_s	mpenum,r0
	nop
	lsl	#2,r0
	mv_s	#object,r1
	add	r0,r1
	ld_s	(r1),fill_colour			;get colour from object....

; Okay, now get ready to fill our bit of the screen.  Get the Y
; clip params to find out where.

	ld_s	dest_screen+12,start_line
	nop
	lsr	#16,start_line,end_line
	bits	#15,>>#0,start_line		;unpacked start and end line.

; get the height and init a counter

	sub	start_line,end_line
    add #1,end_line         ;clip zones are inclusive start and end line
	st_s	end_line,rc0

; Right, get down to it: write out that colour using direct-mode DMA.

yloop:

	sub	h_pos,h_pos			;start from x=0
	mv_s	#360,h_size		;do 360 pixels worth
		
xloop:

	mv_s	#64,r2			;maximum DMA size
	sub	r2,h_size			;dec the size...
	bra	ge,noadj,nop		;still stuff to go...
	add	h_size,r2			;adjust size if necessary

noadj:

; set up and launch the DMA

	mv_s	#dma__cmd,r4
	mv_s	#(dmaFlags|dma_direct),r0	;dma mode flags for this screen
	ld_s	dest,r1			;destination screenbase
	lsl	#16,r2				;shift X size to high word
	or h_pos,r2				;merge position
	copy	start_line,r3	;copy Y position
	bset	#16,r3			;make the Y size = 1
	st_v	v0,(r4)			;setup first part of the DMA command
	add	#16,r4				;point at next bit
	st_s	fill_colour,(r4)
	sub	#16,r4
	st_s	r4,mdmacptr		;fire away.

; wait until DMA is complete

	jsr	dma_finished,nop

; increment X stuff and loop around

	cmp	#0,h_size			;did X size go negative?
	bra	gt,xloop			;if not, carry on
	add	#64,h_pos			;move to next slot
	nop

; increment Y position until done

	dec	rc0					;count off Y lines
	bra	c0ne,yloop
	add	#1,start_line		;move to next line
	nop

; done.

end:

	pop	v0,rz	;get back return address
	nop
	rts	t,nop	;all done.
