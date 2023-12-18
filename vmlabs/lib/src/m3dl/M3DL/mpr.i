/*
 * Title	MPR.I
 * Desciption	MPR Common Assembly includes & defines
 * Version	1.0
 * Start Date	09/23/1998
 * Last Update	12/29/1998
 * By		Phil
 * Of		Miracle Designs
*/

;*
;* Code Cache Bases
;*

mprmainbase	=	0x20300400	;space: 0 bytes
mprouterbase	=	0x20300D00	;space: 0 bytes
mprinnerbase	=	0x20300DA8	;space: 640 bytes


;*
;* Buses Max long transfer
;*

obusmax		= 	(32)	;longs/linear transfer
mbusmax		= 	(64)	;longs/linear transfer


;*
;* Packet Buffer defines
;*

pbufstart	= 0x20100200
pbuflen		= 16			;Length of Command buffer (in packets)
pbufwrap	= pbufstart+((pbuflen*16)-1)

;*
;* Rendering defines
;*

subres	  = 4			;4 Pixels of subresolution
subtype	  = (16+7)		;Subtype in 1st long/1st packet
pixbuflen = 128			;Pixel Buffer length in bytes
;* These are the internal precisions for depth z
;* NOTE: due to recip DOWN round-off error we are allowed to divide by 1
;* eg 0x8000 0000 div 1 will return 7FFFFFFF and we DO NOT need an extra
;* bit of precision to represent ONE!
precdepthz 	= (16+3)		;depth z precision
preciz	  	= (31)			;1.31 invz precision
precuviz  	= (-3)			;uvinvz precision


;* Inner Loop Recips
indexbits	= 7
sizeofscalar	= 2
iprec		= 29



