;
; joysim.moo
;
; this object simulates the analog stick from off the cross pad
; if this object is first in a list, analog values are overridden.

; Header block

joysim:

	.dc.s	0			;Prev
	.dc.s	0			;Next
	.dc.s	$04020000		;3 secondary data, 7 vects of variables
	.dc.s	0			;Address of parameter block if not local

	.dc.s	0			;Address of ranges table, if not local
	.dc.s	0			;this'll be where the command string is, if not local
	.dc.s	0		    ;prototype object to use
	.dc.s	0			;no secondary data

	.dc.s	joysim_end-joysim		;length
    .dc.s   0,0,0

    .dc.s   0,0,0,0

 ; variables

	.dc.s	$ff800000			;"analog" X
	.dc.s	0			;increment - set by joypad
	.dc.s	$f000		;fr
	.dc.s	$80000301	;mode = positional; max; lim(0,1)

	.dc.s	$ff800000			;"analog" Y
	.dc.s	0			;increment - set by joypad
	.dc.s	$f000		;fr
	.dc.s	$80000301	;mode = positional; max; lim(0,1)

; ranges

	.dc.s	$ff800000	;least
	.dc.s	$007f0000	;most
	.dc.s	0
	.dc.s	0

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	0

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	0

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	0

; secondary data space

	.dc.s	$3000		;increment per frame
	.dc.s	status+12	;address of the joydata
	.dc.s	0			;zero
	.dc.s	$f800		;'friction'

; command

	.ascii	"_c#_b=a"	;Load existing joystuff.
	.ascii	"A0!=a2"	;Set x
	.ascii	"B0!=a3"	;Set y
	.ascii	"_b%a"		;Write back new joydata.


; now conditional stuff, to increment the "analog" stick.
; Assumes @4=R, @5=U, @6=L, @7=D.

	.ascii	"_a*@4+A1=A1"	;R
	.ascii	"_a~*@5+B1=B1"	;U
	.ascii	"_a~*@6+A1=A1"	;L
	.ascii	"_a*@7+B1=B1"	;D

; scale joyx and joyy towards 0 (centering)

	.ascii	"_d/A0=A0"
	.ascii	"_d/B0=B0:"


	.align.v

joysim_end:

