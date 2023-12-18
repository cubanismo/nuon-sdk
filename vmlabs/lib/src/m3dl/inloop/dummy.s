/*
 * Title	DUMMY.S
 * Description	MPR Dummy Inner Loop
 * Version	1.0
 * Start Date	10/09/98
 * Last Update	04/11/98
 * By		Phil
 * Of		Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.overlay	dummy
	.origin		mprinnerbase

	.export _dummy_start, _dummy_size

MPR_dummy:
	ld_s	(MPR_InnerT),r0		;Fetch Inner Code Table Entry
	nop
	sub	#MPR_INTable,r0		;Offset
	lsr	#3,r0			;Inner Loop Code Number
breakpoint
       {
	sub_sv	v0,v0			;Clear v0
	dec	rc0			;Pre-Decrement
       }
`loop:
	bra	c0ne,`loop		;Loop
	st_pz	v0,(xy)			;Store Black
       {
	addr	#1<<16,rx		;Next Pixel
	dec	rc0			;Decrement Loop Counter
       }
       ;--------------------------------;bra c0ne,`loop
	rts
	nop
	nop
       ;--------------------------------;rts

