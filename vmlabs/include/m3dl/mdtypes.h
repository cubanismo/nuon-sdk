/*
 * Title	 			MDTYPES.H
 * Desciption		Low level C types include file
 * Version			1.0
 * Start Date		09/04/1998
 * Last Update	05/05/1998
 * By						Phil
 * Of						Miracle Designs
*/

#ifndef __mdTYPES_
#define __mdTYPES_

/*Integer declarations*/
typedef	unsigned char	mdUINT8;				//unsigned 8 bits
typedef	signed char	mdINT8;						//signed 8 bits
typedef	unsigned short mdUINT16;			//unsigned 16 bits
typedef	signed short mdINT16;					//signed 16 bits
typedef	unsigned int mdUINT32;				//unsigned 32 bits
typedef	signed int	mdINT32;					//signed 32 bits

typedef	unsigned char	mdBYTE;					//unsigned 8 bits
typedef	unsigned short mdWORD; 				//unsigned 16 bits
typedef	unsigned int mdLONG;					//unsigned 32 bits

/*Fixed point declarations*/
typedef mdINT16		md8DOT8;						//fixed point 8.8 value
typedef mdINT16		md4DOT12;						//fixed point 4.12 value
typedef mdINT16		md2DOT14;						//fixed point 2.14 value

typedef mdUINT32	mdU16DOT16;					//fixed point unsigned 16.16 value
typedef mdUINT16	mdU12DOT4;					//fixed point unsigned 12.4 value

typedef mdINT32		md28DOT4;						//fixed point 28.4 value
typedef mdINT32		md16DOT16;					//fixed point 16.16 value
typedef mdINT32		md12DOT20;					//fixed point 12.20 value
typedef mdINT32		md24DOT8;						//fixed point 24.8 value
typedef mdINT32		md8DOT24;						//fixed point 8.24 value
typedef mdINT32		md4DOT28;						//fixed point 4.28 value
typedef mdINT32		md2DOT30;						//fixed point 2.30 value

typedef struct _mdV2 {
	md16DOT16	x;
	md16DOT16	y;
} mdV2;

typedef struct _mdV3 {
	md16DOT16	x;
	md16DOT16	y;
	md16DOT16	z;
} mdV3;

typedef struct _mdVECTOR {
	mdINT32	x;
	mdINT32	y;
	mdINT32	z;
} mdVECTOR;

typedef struct _mdU3 {
	md4DOT28	x;
	md4DOT28	y;
	md4DOT28	z;
} mdU3;

typedef struct _mdSU3 {
	md2DOT14	x;
	md2DOT14	y;
	md2DOT14	z;
	mdUINT16	pad;
} mdSU3;

typedef struct _mdScrV3 {
	md28DOT4	x;												//28.4 Screen X coordinate
	md28DOT4	y;                        //28.4 Screen Y coordinate
	md16DOT16	z;                        //Z Value
} mdScrV3;

typedef struct _mdScrRECT {
	md28DOT4	x;												//28.4 Screen X coordinate
	md28DOT4	y;                        //28.4 Screen Y coordinate
	md16DOT16	z;                        //Z Value
	mdU12DOT4	w;												//Unsigned 12.4 Screen W value
	mdU12DOT4	h;                    		//Unsigned 12.4 Screen H value
} mdScrRECT;

/*Matrix declarations*/
typedef struct _mdMATRIX {
	md4DOT28	m[3][4];									//tx = [0][3], ty = [1][3], tz = [2][3]
} mdMATRIX;

/*Quaternion declaration*/
typedef struct {
	md8DOT24	s;												//scalar part
	md8DOT24	vx;												//vector part
	md8DOT24	vy;												//vector part
	md8DOT24	vz;												//vector part
} mdQUAT;

#define mdNULL			(0)								//NULL
#define kONE16DOT16	(1<<16)						//ONE
#define kONE4DOT28	(1<<28)						//ONE
#define kONE8DOT24	(1<<24)						//ONE
#define kONE2DOT30	(1<<30)						//ONE
#define kPI16DOT16	(0x3243F)					//Pi = 3.141592654

/*One argument macros*/
#define mdABS(a) 					((((a) < 0) ? -(a) : (a)))

/*Two argument macros*/
#define mdMIN(a,b)				((((a) < (b)) ? (a) : (b)))
#define mdMAX(a,b)				((((a) > (b)) ? (a) : (b)))
#define mdSABSR(a,b)			(((a) < 0) ? (-((-(a))>>(b)))	: ((a)>>(b)))

/*Three argument macros*/
#define mdMIN3(a,b,c) 		((((a) < (b)) ? min(a,c) : min(b,c)))
#define mdMAX3(a,b,c) 		((((a) > (b)) ? max(a,c) : max(b,c)))

/*Four argument macros*/
#define mdMIN4(a,b,c,d)		(((min(a,b) < min(c,d)) ? min(a,b) : min(c,d)))
#define mdMAX4(a,b,c,d)		(((max(a,b) > max(c,d)) ? max(a,b) : max(c,d)))

/*Booleans*/
typedef int mdBOOLEAN;
typedef mdBOOLEAN mdFLAG;
#define mdFALSE	0
#define mdTRUE	1
#define mdOFF		0
#define mdON		1
#define mdNO		0
#define mdYES	  1

#endif
