/*
 * Title	 			DMA include file for 'C'
 * Desciption		Useful equates for Main Bus DMA
 * Version			1.1
 * Start Date		06/10/1998
 * Last Update	10/15/1998
 * By						Phil
 * Of						Miracle Designs
*/

#ifndef __mdDMA_
#define __mdDMA_


/* DMA Transfer Type*/
#define	LINEAR				(0<<14)
#define	MOTION				(2<<14)
#define	PIXEL					(3<<14)

#define	READ					(1<<13)
#define	WRITE 				(0<<13)

#define	HORIZONTAL		(0<<8)
#define	VERTICAL			(1<<8)


/* Linear transfer modes (these are NOT complete)*/
#define	CONTIGUOUS				(0)
#define	BYTE_MODE					(1)
#define	ALTERNATE_LONG		(2)
#define	EVERY4TH_LONG			(4)
#define	EVERY8TH_LONG			(6)
#define	ALTERNATE_WORD		(3)
#define	EVERY4TH_WORD		 	(5)
#define	EVERY8TH_WORD			(7)

/* Pixel transfer modes*/
#define	TR_16B_ZONLY		(0<<4)
#define	TR_4B						(1<<4)
#define	TR_16B_NOZ			(2<<4)
#define	TR_8B			 			(3<<4)
#define	TR_32B_NOZ			(4<<4)
#define	TR_16B_WITHZ		(5<<4)
#define	TR_32B_WITHZ		(6<<4)
#define	TR_32B_ZONLY		(7<<4)
#define	CV_32B_16B			(8<<4)
#define TR_16B3C_WITHZ	(9<<4)
#define TR_16B3B_WITHZ	(10<<4)
#define TR_16B3A_WITHZ	(11<<4)
#define TR_16B3_ZONLY		(12<<4)
#define TR_16B2B_WITHZ	(13<<4)
#define TR_16B2A_WITHZ	(14<<4)
#define TR_16B2_ZONLY		(15<<4)


/* Z Comparator*/
#define	WR_Z					(0<<1)					/*WRite source Z*/
#define	NW_Z					(7<<1)					/*No Write source Z*/
#define	WR_ZEQ				(5<<1)					/*WRite if source Z EQual*/
#define	WR_ZNE				(2<<1)					/*WRite if source Z Not Equal*/
#define	WR_ZLO				(6<<1)					/*WRite if source Z LOwer*/
#define	WR_ZLE				(4<<1)					/*WRite if source Z Lower or Equal*/
#define	WR_ZGR				(3<<1) 					/*WRite if source Z GReater*/
#define	WR_ZGE				(1<<1)	 				/*WRite if source Z Greater or Equal*/


/* Miscellaneous*/
#define	CLUSTER				(1<<11)
#define	DUP						(1<<26)
#define	DIRECT				(1<<27)
#define	REMOTE				(1<<28)
#define	CHAIN					(1<<29)
#define	BATCH					(1<<30)
#define	LAST					(1<<30)
#define	PLAST					(1<<31)


#endif
