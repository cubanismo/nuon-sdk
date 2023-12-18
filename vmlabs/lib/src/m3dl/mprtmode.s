/*
 * Title	 	MPRTMODE.S
 * Desciption		MPR Transparency Mode Main Code
 * Version		1.0
 * Start Date		10/05/1999
 * Last Update		10/05/1999
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

;*
;* Include
;*

	.include "M3DL/dma.i"
	.include "M3DL/pixel.i"
	.include "M3DL/m3dl.i"
	.include "M3DL/mpr.i"

;*
;* Constant Declarations
;*

;*
;* Register Declarations
;*

;*
;* Code Overlay
;*
	.overlay	mprtmode
	.origin 	mprmainbase

;*
;* Import
;*
	.import	MPR_Waitallbuses
	.import	MPR_NextCommand

	.import	MPR_sbSDRAM

	.import	MPR_MDMA1, MPR_MDMA2

	.import	MPR_SPRC
	.import	_mprsprc_start, _mprsprc_size
	.import	MPR_SPRCA
	.import	_mprsprca_start, _mprsprca_size
	.import	MPR_SPRCS
	.import	_mprsprcs_start, _mprsprcs_size

	.import	MPR_TRI
	.import	_mprtri_start, _mprtri_size
	.import	MPR_TRIA
	.import	_mprtria_start, _mprtria_size
	.import	MPR_TRIS
	.import	_mprtris_start, _mprtris_size

	.import	MPR_BackGroundAlpha
	.import	MPR_StartTab



;*
;* Export
;*
	.export	MPR_TMODE
	.export	_mprtmode_start, _mprtmode_size

MPR_TMODE:
	ld_v	(v7[0]),v0		;Fetch Packet #1
	nop
	st_s	v0[2],(MPR_BackGroundAlpha)
       {
	mv_s	#_mprsprca_start,v1[0]	;Additive sprite
	cmp	#1,v0[1]		;Additive Mode ?
       }
       {
	mv_s	#_mprsprca_size,v1[1]	;Additive sprite
	bra	eq,SetInStartTable	;Set In Start Table
       }
	mv_s	#_mprtria_start,v1[2]	;Additive polygon
	mv_s	#_mprtria_size,v1[3]	;Additive polygon
       ;--------------------------------;bra eq,SetInStartTable
       {
	mv_s	#_mprsprcs_start,v1[0]	;Subtractive sprite
	cmp	#2,v0[1]		;Subtractive Mode ?
       }
       {
	mv_s	#_mprsprcs_size,v1[1]	;Subtractive sprite
	bra	eq,SetInStartTable	;Set In Start Table
       }
	mv_s	#_mprtris_start,v1[2]	;Subtractive polygon
	mv_s	#_mprtris_size,v1[3]	;Subtractive polygon
       ;--------------------------------;bra eq,SetInStartTable
	mv_s	#_mprsprc_start,v1[0]	;Normal Sprite Code Start
	mv_s	#_mprsprc_size,v1[1]	;Normal Sprite Code Size
	mv_s	#_mprtri_start,v1[2]	;Normal Polygon Code Start
	mv_s	#_mprtri_size,v1[3]	;Normal Polygon Code Size
SetInStartTable:
	st_s	#MPR_NextCommand,(rz)	;Store Return Address
	mv_s	#MPR_StartTab+(SPTP*8),r0  ;Set Store Address
       {
	st_s	v1[0],(r0)		;Store Sprite Code Start
	add	#4,r0			;Increment Ptr
       }
       {
	rts				;Done
	st_s	v1[1],(r0)		;Store Sprite Code Size
	add	#4+((TRTP-(SPTP+1))*8),r0  ;Increment Ptr
       }
       {
	st_s	v1[2],(r0)		;Store Polygon Code Start
	add	#4,r0			;Increment Ptr
       }
       {
	st_s	v1[3],(r0)		;Store Polygon Code Size
	add	#4,r0			;Increment Ptr
       }
       ;--------------------------------;bra MPR_NextCommand

