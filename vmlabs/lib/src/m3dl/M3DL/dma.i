/*
 * Title  		DMA include file
 * Desciption		Useful equates for Main Bus DMA
 * Version		1.1
 * Start Date		02/27/1998
 * Last Update		10/15/1998
 * By	  		Phil
 * Of	  		Miracle Designs
*/

.if !defined(__DMA_INC)

__DMA_INC	=	1

;* DMA Transfer Type
LINEAR		=	(0<<14)
MOTION		=	(2<<14)
PIXEL	  	=	(3<<14)

READ	  	=	(1<<13)
WRITE 		=	(0<<13)

HORIZONTAL	=	(0<<8)
VERTICAL	=	(1<<8)


;* Linear transfer modes (these are NOT complete)
CONTIGUOUS	=	(0)
BYTE_MODE	=	(1)
ALTERNATE_LONG	=	(2)
EVERY4TH_LONG	=	(4)
EVERY8TH_LONG	=	(6)
ALTERNATE_WORD	=	(3)
EVERY4TH_WORD	= 	(5)
EVERY8TH_WORD	= 	(7)

;* Pixel transfer modes
TR_16B_ZONLY	=	(0<<4)
TR_4B		=	(1<<4)
TR_16B_NOZ 	=	(2<<4)
TR_8B		=	(3<<4)
TR_32B_NOZ	=	(4<<4)
TR_16B_WITHZ	=	(5<<4)
TR_32B_WITHZ	=	(6<<4)
TR_32B_ZONLY	=	(7<<4)
CV_32B_16B	=	(8<<4)
TR_16B3C_WITHZ	=	(9<<4)
TR_16B3B_WITHZ	=	(10<<4)
TR_16B3A_WITHZ	=	(11<<4)
TR_16B3_ZONLY	=	(12<<4)
TR_16B2B_WITHZ	=	(13<<4)
TR_16B2A_WITHZ	=	(14<<4)
TR_16B2_ZONLY	=	(15<<4)


;* Z Comparator
WR_Z		= 	(0<<1)	;WRite source Z
NW_Z		=	(7<<1)	;No Write source Z
WR_ZEQ		=	(5<<1)	;WRite if source Z EQual
WR_ZNE		=	(2<<1)	;WRite if source Z Not Equal
WR_ZLO		=	(6<<1)	;WRite if source Z LOwer
WR_ZLE		=	(4<<1)	;WRite if source Z Lower or Equal
WR_ZGR		=	(3<<1)	;WRite if source Z GReater
WR_ZGE		=	(1<<1)	;WRite if source Z Greater or Equal


;* Miscellaneous
CLUSTER		=	(1<<11)
DUP		= 	(1<<26)
DIRECT		= 	(1<<27)
REMOTE		= 	(1<<28)
CHAIN		= 	(1<<29)
BATCH		= 	(1<<30)
LAST		= 	(1<<30)
PLAST		= 	(1<<31)


.endif
