/*
 * Title	 	EXTRA.S
 * Desciption		MPE0 High 4Kb Allocations
 * Version		1.0
 * Start Date		09/16/1998
 * Last Update		02/15/2000
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/


	.segment	intdata

	.export		_MPR_mpeinfo
	.export		_MPT_TransformMatrix
	.export		_MPT_Tx, _MPT_Ty, _MPT_Tz
	.export		_MPT_ScaleX, _MPT_ScaleY
	.export		_MPT_OffX, _MPT_OffY
	.export		_MPT_NearZ, _MPT_FarZ
	.export		_MPT_FogNZ, _MPT_FogMulZ


.align.v
_MPR_mpeinfo:
_MPR_startmpe:
	.ds.w	1		;Starting MPE
_MPR_endmpe:
	.ds.w	1		;Ending MPE (not including this MPE#)
_MPR_actmpe:
	.ds.w	1		;Actual MPE
	.ds.w	1		;Dummy
.align.v
_MPT_TransformMatrix:
	.ds.s	3		;R[0][0] R[0][1] R[0][2]
_MPT_Tx:
	.ds.s	1		;Tx
	.ds.s	3		;R[1][0] R[1][1] R[1][2]
_MPT_Ty:
	.ds.s	1		;Ty
	.ds.s	3		;R[2][0] R[2][1] R[2][2]
_MPT_Tz:
	.ds.s	1		;Tz

.align.v
_MPT_ScaleX:
	.ds.s	1		;XScale
_MPT_ScaleY:
	.ds.s	1		;YScale
_MPT_OffX:
	.ds.s	1		;XOffset
_MPT_OffY:
	.ds.s	1		;YOffset

.align.v
_MPT_NearZ:
	.ds.s	1		;NearZ
_MPT_FarZ:
	.ds.s	1		;FarZ
_MPT_FogNZ:
	.ds.s	1		;Fog NearZ
_MPT_FogMulZ:
	.ds.s	1		;(FarZ*255)/(FarZ-NearZ)


	//NOTE: THIS WAS MOVED TO THE DATA SECTION (NO LONGER ON CHIP)

	.data

	.export		_MPT_Ambient
	.export		_MPT_MatrixStack
	.export		_MPT_ScratchArea

	.align.v

_MPT_Ambient:
	.ds.s	1		;Ambient Color
_MPT_MatrixStack:
	.ds.s	1		;Matrix Stack Ptr

