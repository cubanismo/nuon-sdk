/*
 * Title	M3DL.I
 * Desciption	M3DL Assembly includes & defines
 * Version	1.0
 * Start Date	09/23/1998
 * Last Update	09/29/1998
 * By		Phil
 * Of		Miracle Designs
*/

/*MPR Screen Buffer Flags*/
sbGRBb	=	8
sb32Mb	=	9
sbILCb	=	10
scDPQb	=	13
sbODDb	=	14
sbZFb	=	15

;* MPR Wait Cycles
WaitMPR	=	25

;* Extra UV
PCBIT	=	(0)
PCDEF	=	(1<<PCBIT)
BLBIT	=	(1)
BLDEF	=	(1<<BLBIT)
;* Draw Types
UVBIT	=	(2)
UVDEF	=	(1<<UVBIT)
ZBIT	=	(3)			;for DrawX
ZDEF	=	(1<<ZBIT)
BTRABIT	=	(3)			;Internal MPR
BTRADEF	=	(BTRABIT<<ZBIT)
RGBBIT	=	(4)
RGBDEF	=	(1<<RGBBIT)
ABIT	=	(5)
ADEF	=	(1<<ABIT)
DBIT	=	(6)
DDEF	=	(1<<DBIT)
EXTRASHF=	(3)


;* Texture Mode bits
BMYCCBIT=	3
BMBTRBIT=	5

;* MPR Commands
;* Break Draw Packet
BDLEN	=	1
BDTP	=	0
BDTYPE	=	((BDTP<<3)|BDLEN)
BDFLAG	=	0
BDDEF	=       ((BDTYPE<<16)|BDFLAG)

;* Screen Buffer Packet
SBLEN	=	1
SBTP	=	1
SBTYPE	=	((SBTP<<3)|SBLEN)
SBFLAG	=	0
SBDEF	=       ((SBTYPE<<16)|SBFLAG)

;* Syncronize Draw Packet
SDLEN	=	1
SDTP	=	2
SDTYPE	=	((SDTP<<3)|SDLEN)
SDFLAG	=	0
SDDEF	=       ((SDTYPE<<16)|SDFLAG)

;* Screen Conversion Packet
SCLEN	=	2
SCTP	=	3
SCTYPE	=	((SCTP<<3)|SCLEN)
SCFLAG	=	0
SCDEF	=       ((SCTYPE<<16)|SCFLAG)

;* Extra Color Packet
ECLEN	=	1
ECTP	=	4
ECTYPE	=	((ECTP<<3)|ECLEN)
ECFLAG	=	0
ECDEF	=       ((ECTYPE<<16)|ECFLAG)

;* Tile Packet
TLLEN	=	2
TLTP	=	5
TLTYPE	=	((TLTP<<3)|TLLEN)
TLDEF	=       (TLTYPE)

;* Sprite Packet
SPLEN	=	2
SPTP	=	6
SPTYPE	=	((SPTP<<3)|SPLEN)
SPDEF	=       (SPTYPE)

;* Triangle Packet
TRLEN	=	3
TRTP	=	7
TRTYPE	=	((TRTP<<3)|TRLEN)
TRDEF	=       (TRTYPE)

;* Quadrangle Packet
QDLEN	=	4
QDTP	=	7
QDTYPE	=	((QDTP<<3)|QDLEN)
QDDEF	=       (QDTYPE)

;* Transparency Mode Packet
TMLEN	=	1
TMTP	=	8
TMTYPE	=	((TMTP<<3)|TMLEN)
TMFLAG	=	0
TMDEF	=       ((TMTYPE<<16)|TMFLAG)

;* Draw Image Packet
DILEN	=	2
DITP	=	9
DITYPE	=	((DITP<<3)|DILEN)
DIFLAG	=	0
DIDEF	=       ((DITYPE<<16)|DIFLAG)


;* Bios Commsend
	.import	__comm_send
	.import	__comm_recv
BIOSCSEND	=	(__comm_send)
BIOSCRECV	=	(__comm_recv)

