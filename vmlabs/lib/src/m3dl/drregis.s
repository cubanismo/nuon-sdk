/*
 * Title	 	DRREGIS.S
 * Desciption		Draw Registers for Pixel Generator Functions
 * Version		1.0
 * Start Date		11/03/1998
 * Last Update		11/05/1998
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

;* Outer Loop Registers


_DLGRBA		=	v2
_DLG		=	_DLGRBA[0]
_DLR		=	_DLGRBA[1]
_DLB		=	_DLGRBA[2]
_DLA		=	_DLGRBA[3]

_PMXWXTPBF	=	v2
_PMAX		=       _PMXWXTPBF[0]
_WIDXTOT	=       _PMXWXTPBF[1]
_PBUF		=       _PMXWXTPBF[2]

_DLUVZ		=	v3
_DLU		=	_DLUVZ[0]
_DLV		=	_DLUVZ[1]
_DLiZ		=	_DLUVZ[2]
_DLZ		=	_DLUVZ[3]

_WXCLXHYCTY	=	v3
_WIDXCUR        =	_WXCLXHYCTY[0]
_LX             =       _WXCLXHYCTY[1]
_HGHYCUR	=	_WXCLXHYCTY[2]
_TY             =       _WXCLXHYCTY[3]

_LGRBA		=	v6		;Shared with Inner Loop
_LG		=	_LGRBA[0]
_LR		=	_LGRBA[1]
_LB		=	_LGRBA[2]
_LA		=	_LGRBA[3]

_LUVZ		=	v7		;Shared with Inner Loop
_LU		=	_LUVZ[0]
_LV		=	_LUVZ[1]
_LiZ		=	_LUVZ[2]
_LZ		=	_LUVZ[3]

;* Inner Loop Registers
_DGRBA	=	v4
_DG	=	_DGRBA[0]
_DR	=	_DGRBA[1]
_DB	=	_DGRBA[2]
_DA	=	_DGRBA[3]

_DUVZ	=	v5
_DU	=	_DUVZ[0]
_DV	=	_DUVZ[1]
_DiZ	=	_DUVZ[2]
_DZ	=	_DUVZ[3]

_GRBA	= 	v6
_G	=	_GRBA[0]
_R	=	_GRBA[1]
_B	=	_GRBA[2]
_A	=	_GRBA[3]

_UVZ	=	v7
_U	=	_UVZ[0]
_V	=	_UVZ[1]
_iZ	=	_UVZ[2]
_Z	=	_UVZ[3]

