/*
 * Title	 			M3DL.H
 * Desciption		M3DL C Functions
 * Version			3.01
 * Start Date		09/16/1998
 * Last Update	02/16/2000
 * By						Phil
 * Of						Miracle Designs
*/

#ifndef __mdM3DLInc_
#define __mdM3DLInc_

#include <nuon/bios.h>
#include <nuon/mutil.h>
#include <m3dl/pixel.h>
#include <m3dl/dma.h>
#include <m3dl/mdtypes.h>

//	Screen Modes
#define mdGRBsb	(1<<8)			//Screen Buffer RGB
#define md32Bsb	(1<<9)			//Screen Buffer 32Bit

//	Primitive id
#define mptTILE	((5<<3)|2)
#define mptSPRT	((6<<3)|2)
#define mptTRI	((7<<3)|3)
#define mptQUAD	((7<<3)|4)
#define mptIMG	((9<<3)|2)

//	Primitive Type Codes
#define mpcPC		(1<<7)
#define mpcBIL	(1<<8)
#define mpcTEX	(1<<9)
#define mpcZBUF (1<<10)
#define mpcRGB	(1<<11)
#define mpcALP	(1<<12)
#define mpcDPQ	(1<<13)
#define mpcCLU	(1<<14)
#define mpcCLV	(1<<15)


//  Primitive Types (2D - Render Primitives)
#define mpTILE_F			(mptTILE|mpcRGB)
#define mpTILE_FZ			(mptTILE|mpcRGB|mpcZBUF)
#define mpTILE_Z			(mptTILE|mpcZBUF)

#define mpSPRT				(mptSPRT|mpcTEX|mpcZBUF)
#define mpSPRT_F			(mptSPRT|mpcTEX|mpcZBUF|mpcRGB)
#define mpSPRT_A 			(mptSPRT|mpcTEX|mpcZBUF|mpcALP)
#define mpSPRT_FA			(mptSPRT|mpcTEX|mpcZBUF|mpcRGB|mpcALP)
#define mpSPRT_D 			(mptSPRT|mpcTEX|mpcZBUF|mpcDPQ)
#define mpSPRT_FD			(mptSPRT|mpcTEX|mpcZBUF|mpcRGB|mpcDPQ)
#define mpSPRT_B			(mptSPRT|mpcTEX|mpcZBUF|mpcBIL)
#define mpSPRT_BF			(mptSPRT|mpcTEX|mpcZBUF|mpcBIL|mpcRGB)
#define mpSPRT_BA			(mptSPRT|mpcTEX|mpcZBUF|mpcBIL|mpcALP)
#define mpSPRT_BFA		(mptSPRT|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcALP)
#define mpSPRT_BD			(mptSPRT|mpcTEX|mpcZBUF|mpcBIL|mpcDPQ)
#define mpSPRT_BFD		(mptSPRT|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcDPQ)

#define mpIMG					(mptIMG|mpcTEX|mpcZBUF)
#define mpIMG_F				(mptIMG|mpcTEX|mpcZBUF|mpcRGB)
#define mpIMG_A 			(mptIMG|mpcTEX|mpcZBUF|mpcALP)
#define mpIMG_FA			(mptIMG|mpcTEX|mpcZBUF|mpcRGB|mpcALP)
#define mpIMG_D 			(mptIMG|mpcTEX|mpcZBUF|mpcDPQ)
#define mpIMG_FD			(mptIMG|mpcTEX|mpcZBUF|mpcRGB|mpcDPQ)
#define mpIMG_B				(mptIMG|mpcTEX|mpcZBUF|mpcBIL)
#define mpIMG_BF			(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcRGB)
#define mpIMG_BA			(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcALP)
#define mpIMG_BFA			(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcALP)
#define mpIMG_BD			(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcDPQ)
#define mpIMG_BFD			(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcDPQ)

#define mpTRI_G				(mptTRI|mpcZBUF|mpcRGB)
#define mpTRI_GA			(mptTRI|mpcZBUF|mpcRGB|mpcALP)
#define mpTRI_GD			(mptTRI|mpcZBUF|mpcRGB|mpcDPQ)
#define mpTRI_T 			(mptTRI|mpcZBUF|mpcTEX|mpcZBUF)
#define mpTRI_TG 			(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcRGB)
#define mpTRI_TA 			(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcALP)
#define mpTRI_TGA			(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcRGB|mpcALP)
#define mpTRI_TD 			(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcDPQ)
#define mpTRI_TGD			(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcRGB|mpcDPQ)
#define mpTRI_BT 			(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL)
#define mpTRI_BTG  		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcRGB)
#define mpTRI_BTA  		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcALP)
#define mpTRI_BTGA 		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcALP)
#define mpTRI_BTD  		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcDPQ)
#define mpTRI_BTGD 		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcDPQ)
#define mpTRI_PCT 		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC)
#define mpTRI_PCTG 		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcRGB)
#define mpTRI_PCTA 		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcALP)
#define mpTRI_PCTGA		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcRGB|mpcALP)
#define mpTRI_PCTD 		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcDPQ)
#define mpTRI_PCTGD		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcRGB|mpcDPQ)
#define mpTRI_PCBT 		(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL)
#define mpTRI_PCBTG  	(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcRGB)
#define mpTRI_PCBTA  	(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcALP)
#define mpTRI_PCBTGA 	(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcRGB|mpcALP)
#define mpTRI_PCBTD  	(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcDPQ)
#define mpTRI_PCBTGD 	(mptTRI|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcRGB|mpcDPQ)

#define mpQUAD_G			(mptQUAD|mpcZBUF|mpcRGB)
#define mpQUAD_GA			(mptQUAD|mpcZBUF|mpcRGB|mpcALP)
#define mpQUAD_GD			(mptQUAD|mpcZBUF|mpcRGB|mpcDPQ)
#define mpQUAD_T 			(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF)
#define mpQUAD_TG 		(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcRGB)
#define mpQUAD_TA 		(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcALP)
#define mpQUAD_TGA		(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcRGB|mpcALP)
#define mpQUAD_TD 		(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcDPQ)
#define mpQUAD_TGD		(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcRGB|mpcDPQ)
#define mpQUAD_BT 		(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL)
#define mpQUAD_BTG  	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcRGB)
#define mpQUAD_BTA  	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcALP)
#define mpQUAD_BTGA 	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcALP)
#define mpQUAD_BTD  	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcDPQ)
#define mpQUAD_BTGD 	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcDPQ)
#define mpQUAD_PCT 		(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC)
#define mpQUAD_PCTG 	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcRGB)
#define mpQUAD_PCTA 	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcALP)
#define mpQUAD_PCTGA	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcRGB|mpcALP)
#define mpQUAD_PCTD 	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcDPQ)
#define mpQUAD_PCTGD	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcRGB|mpcDPQ)
#define mpQUAD_PCBT 	(mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL)
#define mpQUAD_PCBTG  (mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcRGB)
#define mpQUAD_PCBTA  (mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcALP)
#define mpQUAD_PCBTGA (mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcRGB|mpcALP)
#define mpQUAD_PCBTD  (mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcDPQ)
#define mpQUAD_PCBTGD (mptQUAD|mpcZBUF|mpcTEX|mpcZBUF|mpcPC|mpcBIL|mpcRGB|mpcDPQ)

#define mpIMG				(mptIMG|mpcTEX|mpcZBUF)
#define mpIMG_F			(mptIMG|mpcTEX|mpcZBUF|mpcRGB)
#define mpIMG_A 		(mptIMG|mpcTEX|mpcZBUF|mpcALP)
#define mpIMG_FA		(mptIMG|mpcTEX|mpcZBUF|mpcRGB|mpcALP)
#define mpIMG_D 		(mptIMG|mpcTEX|mpcZBUF|mpcDPQ)
#define mpIMG_FD		(mptIMG|mpcTEX|mpcZBUF|mpcRGB|mpcDPQ)
#define mpIMG_B			(mptIMG|mpcTEX|mpcZBUF|mpcBIL)
#define mpIMG_BF		(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcRGB)
#define mpIMG_BA		(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcALP)
#define mpIMG_BFA		(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcALP)
#define mpIMG_BD		(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcDPQ)
#define mpIMG_BFD		(mptIMG|mpcTEX|mpcZBUF|mpcBIL|mpcRGB|mpcDPQ)


//	External References
extern const char libm3dl_version[];					//Ascii LibVersion

//	Enums
typedef enum _mdTRANSMODE {
	TRANSMODE_NORMAL = 0,
	TRANSMODE_ADDITIVE,
	TRANSMODE_SUBTRACTIVE
} mdTRANSMODE;

//	C Structures
typedef struct _mdBITMAP {
	mdUINT32	bitmap;
	mdUINT32	clut;
} mdBITMAP;

typedef struct _mdCOLOR {
	mdUINT8	g;
	mdUINT8	r;
	mdUINT8	b;
	mdUINT8	a;
} mdCOLOR;

typedef struct _mdTEXTURE {
	mdUINT8	pixtype;
	mdUINT8	miplevels;
	mdUINT8	width;
	mdUINT8	height;
	mdBITMAP	*bmnfo;
} mdTEXTURE;

typedef struct _mdIMAGEDATA {
	mdUINT8	pixtype;
	mdUINT8	miplevels;
	mdUINT8	width;
	mdUINT8	height;
	mdBITMAP	*bmnfo;
} mdIMAGEDATA;

typedef struct _mdDRAWBUF {
	mdUINT32 sdramaddr;
	mdUINT32 dmaflags;
} mdDRAWBUF;

typedef struct _mdDRAWCONTEXT {
	mdUINT16 actbuf;
	mdUINT16 numbuf;

	mdUINT16 dispw;
	mdUINT16 disph;

	mdUINT16 rendx;
	mdUINT16 rendy;

	mdUINT16 rendw;
	mdUINT16 rendh;

	mdUINT16 flags;
	mdUINT16 select;				//Bit 0: Odd/Even - Bit 1: Znormal/ZFlip

	mdUINT32 zcmpflags[2];

	mdUINT32 lastfield;

	mdDRAWBUF	buf[3];				//Maximum Triple Buffer
} mdDRAWCONTEXT;


typedef struct _mdTILE {
		mdScrRECT	sr;										//Screen Rectangle
		mdCOLOR	color;									//1 long
} mdTILE;


typedef struct _mdSPRITE {
		mdScrRECT	sr;										//Screen Rectangle

		mdCOLOR	color;									//1 long

		mdTEXTURE	*tex;               	//1 long

		mdINT16	u0;											//1 long
		mdINT16	v0;

		mdINT16	uofs;		                //1 long
		mdINT16	vofs;
} mdSPRITE;


typedef struct _mdIMAGE {
		mdScrRECT	sr;										//Screen Rectangle

		mdCOLOR	color;									//1 long

		mdIMAGEDATA	*img;              	//1 long

		mdINT16	u0;											//1 long
		mdINT16	v0;

		mdINT16	uofs;		                //1 long
		mdINT16	vofs;
} mdIMAGE;


typedef struct _mdTRI {
		mdScrV3			v[3];		 					//9 longs

		mdCOLOR		c[3];								//3 longs

		mdTEXTURE	*tex;               //1 long

		mdINT16	u0;                   //1 long
		mdINT16	v0;

		mdINT16	u1;                   //1 long
		mdINT16	v1;

		mdINT16	u2;                   //1 long
		mdINT16	v2;
} mdTRI;


typedef struct _mdQUAD {
		mdScrV3			v[4];							//12 longs

		mdCOLOR		c[4];								//4 longs

		mdTEXTURE	*tex;               //1 long

		mdINT16	u0;                   //1 long
		mdINT16	v0;

		mdINT16	u1;                   //1 long
		mdINT16	v1;

		mdINT16	u2;                   //1 long
		mdINT16	v2;

		mdINT16	u3;                   //1 long
		mdINT16	v3;
} mdQUAD;


typedef struct _mdSBOARD {
		mdV3			base;		 						//3 longs
		md16DOT16	w;    		          //1 long
		md16DOT16	h;									//1 long
} mdSBOARD;


typedef struct _mdTBOARD {
		mdV3			base;		 						//3 longs
		mdV2			ofs[3];		 					//6 longs
} mdTBOARD;


typedef struct _mdQBOARD {
		mdV3			base;		 						//3 longs
		mdV2			ofs[4];		 					//8 longs
} mdQBOARD;


typedef struct _mdCLIPTRI {
		mdV3		v[4];									//12 longs

		mdCOLOR		c[4];								//4 longs

		mdUINT32	uv[4];							//4 longs
} mdCLIPTRI;


typedef struct _mdPRIM {
		mdUINT32	primcode;						//1 long

		union {
			mdSPRITE	sprt;
			mdQUAD		poly;
		} prim;
} mdPRIM;


typedef struct _mdAABB {
	mdV3	min;											//Min x,y,z of Axis Aligned Bounding Box
	mdV3	max;                      //Max x,y,z of Axis Aligned Bounding Box
} mdAABB;


//	Primitive Setters
void	mdSetRGB(mdCOLOR* _col, mdUINT8 _r, mdUINT8 _g, mdUINT8 _b);
void	mdSetRGBA(mdCOLOR* _col, mdUINT8 _r, mdUINT8 _g, mdUINT8 _b, mdUINT8 _a);
void	mdSetAlpha(mdCOLOR* _col, mdUINT8 _a);
void	mdSetScrVector(mdScrV3* _v, md28DOT4 _x,md28DOT4 _y,md16DOT16 _z);
void	mdSetScrRECT(mdScrRECT* _sr, md28DOT4 _x,md28DOT4 _y,md16DOT16 _z, mdU12DOT4 _w, mdU12DOT4 _h);

#define mdSetRGB(_col,_r,_g,_b) \
								((_col)->r=(_r),(_col)->g=(_g),(_col)->b=(_b))
#define mdSetRGBA(_col,_r,_g,_b,_a) \
								((_col)->r=(_r),(_col)->g=(_g),(_col)->b=(_b),(_col)->a=(_a))
#define mdSetALPHA(_col,_a) \
								((_col)->a=(_a))
#define mdSetScrVector(_v,_x,_y,_z) \
								((_v)->x = (_x),(_v)->y = (_y), (_v)->z = (_z))
#define mdSetScrRECT(_sr,_x,_y,_z,_w,_h) \
								((_sr)->x = (_x),(_sr)->y = (_y), (_sr)->z = (_z), (_sr)->w = _w, (_sr)->h = (_h))


//	Material Functions
mdUINT32	mdGetMBMInfo(mdBYTE *mbm, mdUINT32 *numtexs, mdUINT32 *numbms);
mdUINT32	mdTextureFromMBM(mdBYTE *mbm, mdBYTE *dest, mdTEXTURE *texture, mdBITMAP *bitmap);
mdUINT32	mdImageDataFromMBI(mdBYTE *mbi, mdBYTE *dest, mdIMAGEDATA *imgdata, mdBITMAP *bitmap);
mdUINT32	_mdCopyBitmap(mdBYTE *obussrcaddr, mdBYTE *dstaddr,
							 mdUINT32 pixtype, mdUINT32 width, mdUINT32 height);

#define mdImageDataFromMBI(_mbi, _dest, _imgdata, _bitmap) \
					(mdTextureFromMBM(_mbi, _dest, (mdTEXTURE *)_imgdata, _bitmap))

//Screen Mode Includes
mdUINT32 mdSetBufYCC16B_NOZ(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, mdUINT32 nrendbuf, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);
mdUINT32 mdSetBufYCC32B_NOZ(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, mdUINT32 nrendbuf, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);

mdUINT32 mdSetBufYCC16B_WITHZ(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, mdUINT32 nrendbuf, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);
mdUINT32 mdSetBufYCC16B_WITHZSHARED(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, mdUINT32 nrendbuf, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);
mdUINT32 mdSetBufYCC32B_WITHZ(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, mdUINT32 nrendbuf, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);

mdUINT32 mdSetBufGRB16B_NOZ_YCC16B(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);
mdUINT32 mdSetBufGRB16B_NOZ_YCC32B(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);
mdUINT32 mdSetBufGRB32B_NOZ_YCC32B(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);

mdUINT32 mdSetBufGRB16B_WITHZ_YCC16B(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);
mdUINT32 mdSetBufGRB16B_WITHZ_YCC32B(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);
mdUINT32 mdSetBufGRB32B_WITHZ_YCC32B(mdDRAWCONTEXT* dcx, mdBYTE *sdramstart, md28DOT4 dispw, md28DOT4 disph, md28DOT4 rendx, md28DOT4 rendy,	md28DOT4 rendw,md28DOT4 rendh);


//	Clear ALL pixel buffers Draw/Display Context.. DO NOT EXECUTE VERY FRAME
void mdClearDraw(mdDRAWCONTEXT*, mdCOLOR*);
void mdClearDisp(mdDRAWCONTEXT*, mdCOLOR*);
mdUINT32 SwapDrawBufGRB(mdDRAWCONTEXT*);
mdUINT32 SwapDrawBufYCC(mdDRAWCONTEXT*);


//  Setup Rendering Code on MPEs
mdUINT32	mdSetupMPRChain(mdUINT32 startmpe, mdUINT32 nummpes);

//  Exit Rendering Code on MPEs
void	mdRemoveMPRChain(void);

//	Send Screen Buffer Information to MPRs
void	mdActiveDrawContext(mdDRAWCONTEXT *drawcontext);

//	Send GRB -> YCrCb Conversion Packet
void	mdDrawConv(mdDRAWCONTEXT *drawcontext);

//	Send Blend Color Packet
void	mdActiveBlendColor(mdCOLOR *color);

//	Send Transparency Mode Packet
void	mdSetTransparencyMode(mdTRANSMODE transmode, md2DOT30 backgroundmultiplier);

//	Wait for MPR Activity to finish
void	mdDrawSync(void);

//	Send Tile Primitive to MPR
void	mdDrawTile(mdUINT32 ptype, mdScrRECT *xyzandwh, mdCOLOR *color);

//	Send Sprite Primitive to MPR
void	mdDrawSprite(mdUINT32 ptype, mdScrRECT *xyzandwh,
									 mdCOLOR *color, mdTEXTURE *texture, mdUINT32 *uvinfo);
void	mdDrawImage(mdUINT32 ptype, mdScrRECT *xyzandwh,
									 mdCOLOR *color, mdIMAGEDATA *imgdata, mdUINT32 *uvinfo);

//	Send Polygon Primitive to MPR
void	mdDrawPoly(mdUINT32 ptype, mdScrV3 *vertices,
									 mdCOLOR *color, mdTEXTURE *texture, mdUINT32 *uvinfo);

//  Send Tile, Sprite or Poly to MPR
void	mdDrawPrim(mdPRIM* prim);


// On Chip Variables
//BEWARE: These MUST be retrieved with _GetLocalVar() !
extern mdMATRIX MPT_TransformMatrix;
extern mdINT32 MPT_Tx, MPT_Ty, MPT_Tz;
extern md12DOT20 MPT_ScaleX;
extern md12DOT20 MPT_ScaleY;
extern md28DOT4 MPT_OffX;
extern md28DOT4 MPT_OffY;
extern md16DOT16 MPT_NearZ, MPT_FarZ;
extern mdCOLOR	MPT_Ambient;

// Useful Setters
void	mdSetXScale(md12DOT20 _sclx);
void	mdSetYScale(md12DOT20 _scly);
void	mdSetXYScale(md12DOT20 _sclx, md12DOT20 _scly);

void	mdSetXOffset(md28DOT4 _ofsx);
void	mdSetYOffset(md28DOT4 _ofsy);
void	mdSetXYOffset(md28DOT4 _ofsx, md28DOT4 _ofsy);
void	mdSetAmbientColor(mdCOLOR* _acol);


#define mdSetXScale(_sclx) \
					(_SetLocalVar(MPT_ScaleX,_sclx))
#define mdSetYScale(_scly) \
					(_SetLocalVar(MPT_ScaleY,_scly))
#define mdSetXYScale(_sclx, _scly) \
					(_SetLocalVar(MPT_ScaleX,_sclx), \
					 _SetLocalVar(MPT_ScaleY,_scly))

#define mdSetXOffset(_ofsx) \
					(_SetLocalVar(MPT_OffX,_ofsx))
#define mdSetYOffset(_ofsy) \
					(_SetLocalVar(MPT_OffY,_ofsy))
#define mdSetXYOffset(_ofsx, _ofsy) \
					(_SetLocalVar(MPT_OffX,_ofsx), \
					 _SetLocalVar(MPT_OffY,_ofsy))
#define mdSetAmbientColor(_acol) \
					(_SetLocalVar(MPT_Ambient,*(mdUINT32*)(_acol)))



//	Useful Getters
md12DOT20	mdGetXScale(void);
md12DOT20	mdGetYScale(void);

md28DOT4	mdGetXOffset(void);
md28DOT4	mdGetYOffset(void);
mdU16DOT16 mdGetNearZ(void);
mdU16DOT16 mdGetFarZ(void);


#define mdGetXScale() \
				 (_GetLocalVar(MPT_ScaleX))
#define mdGetYScale() \
				 (_GetLocalVar(MPT_ScaleY))
#define mdGetXOffset() \
				 (_GetLocalVar(MPT_OffX))
#define mdGetYOffset() \
				 (_GetLocalVar(MPT_OffY))
#define mdGetNearZ() \
				 (_GetLocalVar(MPT_NearZ))
#define mdGetFarZ() \
				 (_GetLocalVar(MPT_FarZ))


//	Transformation Matrix Functions
void mdPlaceTransformMatrix(md16DOT16 _tx,md16DOT16 _ty,md16DOT16 _tz);
void mdVecPlaceTransformMatrix(mdV3 *_v);
void mdTransTransformMatrix(md16DOT16 _tx,md16DOT16 _ty,md16DOT16 _tz);
void mdVecTransTransformMatrix(mdV3 *_v);

void mdMulTransformMatrix(mdMATRIX *mat);
void mdSetTransformMatrix(mdMATRIX *tmat0);
void mdGetTransformMatrix(mdMATRIX *mout);
void mdGetTransformMatrixTrans(mdV3 *vout);

#define mdPlaceTransformMatrix(_tx, _ty, _tz) \
					(_SetLocalVar(MPT_Tx,(_tx)), \
					 _SetLocalVar(MPT_Ty,(_ty)), \
  				 _SetLocalVar(MPT_Tz,(_tz)))
#define mdVecPlaceTransformMatrix(_v) \
					(_SetLocalVar(MPT_Tx,(_v)->x), \
					 _SetLocalVar(MPT_Ty,(_v)->y), \
					 _SetLocalVar(MPT_Tz,(_v)->z))
#define mdTransTransformMatrix(_tx, _ty, _tz) \
					(_SetLocalVar(MPT_Tx,(_GetLocalVar(MPT_Tx) + (_tx))), \
					 _SetLocalVar(MPT_Ty,(_GetLocalVar(MPT_Ty) + (_ty))), \
					 _SetLocalVar(MPT_Tz,(_GetLocalVar(MPT_Tz) + (_tz))))
#define mdVecTransTransformMatrix(_v) \
					(_SetLocalVar(MPT_Tx,(_GetLocalVar(MPT_Tx) + (_v)->x)), \
					 _SetLocalVar(MPT_Ty,(_GetLocalVar(MPT_Ty) + (_v)->y)), \
					 _SetLocalVar(MPT_Tz,(_GetLocalVar(MPT_Tz) + (_v)->z)))
#define	mdMulTransformMatrix(mat) \
					(mdMulMatrix(&MPT_TransformMatrix, mat, &MPT_TransformMatrix))


//	General Matrix Functions
void mdPlaceMatrix(mdMATRIX* _tm, md16DOT16 _tx,md16DOT16 _ty,md16DOT16 _tz);
void mdTransMatrix(mdMATRIX* _tm, md16DOT16 _tx,md16DOT16 _ty,md16DOT16 _tz);
void mdVecPlaceMatrix(mdMATRIX* _tm, mdV3 *_v);
void mdVecTransMatrix(mdMATRIX* _tm, mdV3 *_v);
void mdGetMatrixTrans(mdMATRIX* _tm, mdV3* _vout);

#define mdPlaceMatrix(_tm, _tx, _ty, _tz) \
					((_tm)->m[0][3] = (_tx), (_tm)->m[1][3] = (_ty), (_tm)->m[2][3] = (_tz))
#define mdTransMatrix(_tm, _tx, _ty, _tz) \
					((_tm)->m[0][3] += (_tx), (_tm)->m[1][3] += (_ty), (_tm)->m[2][3] += (_tz))
#define mdVecPlaceMatrix(_tm, _v) \
					((_tm)->m[0][3] = (_v)->x, (_tm)->m[1][3] = (_v)->y, (_tm)->m[2][3] = (_v)->z)
#define mdVecTransMatrix(_tm, _v) \
					((_tm)->m[0][3] += (_v)->x, (_tm)->m[1][3] += (_v)->y, (_tm)->m[2][3] += (_v)->z)

void	mdIdentityMatrix(mdMATRIX *tmat0);
void	mdTransposeMatrix(mdMATRIX *tmat0, mdMATRIX *tmat1);
void	mdSetMatrixStack(mdBYTE *msp);
void	mdPushMatrix(void);
void	mdPopMatrix(void);
void	mdMulMatrix(mdMATRIX *tmat0, mdMATRIX *tmat1, mdMATRIX *tmat2);
void	mdRotMatrixX(md16DOT16 anglex, mdMATRIX *tmat);
void	mdRotMatrixY(md16DOT16 angley, mdMATRIX *tmat);
void	mdRotMatrixZ(md16DOT16 anglez, mdMATRIX *tmat);
void	mdRotMatrix(mdV3 *anglexyz, mdMATRIX *tmat);
void	mdRotMatrixXYZ(mdV3 *anglexyz, mdMATRIX *tmat);
void	mdRotMatrixYXZ(mdV3 *anglexyz, mdMATRIX *tmat);
void	mdRotMatrixZYX(mdV3 *anglexyz, mdMATRIX *tmat);


//	Frustum Setter
void	mdSetNearZ(mdU16DOT16 nearz);
void	mdSetFarZ(mdU16DOT16 farz);
void	mdSetNearFarZ(mdU16DOT16 nearz, mdU16DOT16 farz);
void	mdSetFrustum(md16DOT16 fov, mdUINT32 width, mdUINT32 height, \
									 md16DOT16 physaspect, mdU16DOT16 nearz, mdU16DOT16 farz);


//	Point, Triangle & Quadrangle Transformation Functions
void			mdRot(mdV3* vin, mdV3* vout);
void			mdRot3(mdV3* vin, mdV3* vout);
void			mdRot4(mdV3* vin, mdV3* vout);
void			mdRotN(mdV3* vin, mdV3* vout, mdUINT32 N);

void			mdRotTrans(mdV3* vin, mdV3* vout);
void			mdRotTrans3(mdV3* vin, mdV3* vout);
void			mdRotTrans4(mdV3* vin, mdV3* vout);
void			mdRotTransN(mdV3* vin, mdV3* vout, mdUINT32 N);

void			mdPers(mdV3* vin, mdScrV3* vsout);
void			mdPers3(mdV3* vin, mdScrV3* vsout);
void			mdPers4(mdV3* vin, mdScrV3* vsout);
void			mdPersN(mdV3* vin, mdScrV3* vsout, mdUINT32 N);

mdUINT32	mdCull3(mdScrV3* vsin);
mdUINT32	mdCull4(mdScrV3* vsin);

mdUINT32	mdPersCull3(mdV3* vin, mdScrV3* vsout);
mdUINT32	mdPersCull4(mdV3* vin, mdScrV3* vsout);

mdUINT32	mdRotTransClip(mdV3* vin, mdV3* vout);
mdUINT32	mdRotTransClip3(mdV3* vin, mdV3* vout);
mdUINT32	mdRotTransClip4(mdV3* vin, mdV3* vout);
mdUINT32	mdRotTransClipN(mdV3* vin, mdV3* vout, mdUINT32 N);

void			mdRotTransPers(mdV3* vin, mdScrV3* vsout);
void			mdRotTransPers3(mdV3* vin, mdScrV3* vsout);
void			mdRotTransPers4(mdV3* vin, mdScrV3* vsout);
void			mdRotTransPersN(mdV3* vin, mdScrV3* vsout, mdUINT32 N);

mdUINT32	mdRotTransPersCull3(mdV3* vin, mdScrV3* vsxyz);
mdUINT32	mdRotTransPersCull4(mdV3* vin, mdScrV3* vsxyz);

mdUINT32	mdClip(mdScrV3* vsin);
mdUINT32	mdClip3(mdScrV3* vsin);
mdUINT32	mdClip4(mdScrV3* vsin);
mdUINT32	mdClipN(mdScrV3* vsin, mdUINT32 N);

//	Board Transformation Functions (essentially 3D Sprites - Constant Z)
mdUINT32	mdRTPSBoard(mdSBOARD *sbin, mdScrRECT* rcout);
mdUINT32	mdRTPDpqSBoard(mdSBOARD *sbin, mdScrRECT* rcout, mdCOLOR* rgba);
mdUINT32	mdRTPClipSBoard(mdSBOARD *sbin, mdScrRECT* rcout);
mdUINT32	mdRTPDpqClipSBoard(mdSBOARD *sbin, mdScrRECT* rcout, mdCOLOR* rgba);

mdUINT32	mdRTPTBoard(mdTBOARD *tbin, mdScrV3* vsxyz);
mdUINT32	mdRTPDpqTBoard(mdTBOARD *tbin, mdScrV3* vsxyz, mdCOLOR* rgba);
mdUINT32	mdRTPClipTBoard(mdTBOARD *tbin, mdScrV3* vsxyz);
mdUINT32	mdRTPDpqClipTBoard(mdTBOARD *tbin, mdScrV3* vsxyz, mdCOLOR* rgba);

mdUINT32	mdRTPQBoard(mdQBOARD *qbin, mdScrV3* vsxyz);
mdUINT32	mdRTPDpqQBoard(mdQBOARD *qbin, mdScrV3* vsxyz, mdCOLOR* rgba);
mdUINT32	mdRTPClipQBoard(mdQBOARD *qbin, mdScrV3* vsxyz);
mdUINT32	mdRTPDpqClipQBoard(mdQBOARD *qbin, mdScrV3* vsxyz, mdCOLOR* rgba);


//	Vector Functions
void			mdSetVector(mdV3* _v, md16DOT16 _x,md16DOT16 _y,md16DOT16 _z);
void			mdAddVector(mdV3* _vin1, mdV3* _vin2, mdV3* _vout);
void			mdSubVector(mdV3* _vin1, mdV3* _vin2, mdV3* _vout);


#define 	mdSetVector(_v,_x,_y,_z) \
								((_v)->x = _x,(_v)->y = _y, (_v)->z = _z)
#define 	mdAddVector(_vin1,_vin2,_vout) \
						((_vout)->x = (_vin1)->x + (_vin2)->x, \
						 (_vout)->y = (_vin1)->y + (_vin2)->y, \
						 (_vout)->z = (_vin1)->z + (_vin2)->z)
#define 	mdSubVector(_vin1,_vin2,_vout) \
						((_vout)->x = (_vin2)->x - (_vin1)->x, \
						 (_vout)->y = (_vin2)->y - (_vin1)->y, \
						 (_vout)->z = (_vin2)->z - (_vin1)->z)


mdINT32			mdDotProduct(mdV3* vin0, mdV3* vin1, md16DOT16 *dotprod);
mdINT32			mdDotProductSFT(mdV3* vin0, mdV3* vin1, mdINT32 shift, mdINT32 *dotprod);
mdINT32			mdCrossProduct(mdV3* vin0, mdV3* vin1, mdV3* vout);
mdINT32			mdCrossProductSFT(mdV3* vin0, mdV3* vin1, mdINT32 shift, mdV3* vout);

void				mdVectorNormal(mdV3* vin, mdV3* vout);
void				mdVectorNormalSFT(mdV3* vin, mdV3* vout, mdINT32 vecshift);
mdU16DOT16	mdVectorMagnitude(mdV3* vin);
void				mdApplyMatrix(mdMATRIX *mat, mdV3* vin, mdV3* vout);


//	Quaternion Functions
void	mdSetQuat(mdQUAT* _q, md8DOT24 _s, md8DOT24 _vx, md8DOT24 _vy, md8DOT24 _vz);
void	mdAddQuat(mdQUAT* _qin1, mdQUAT* _qin2, mdQUAT* _qout);
void	mdSubQuat(mdQUAT* _qin1, mdQUAT* _qin2, mdQUAT* _qout);

void	mdQuatLerp(mdQUAT *qstart, mdQUAT *qend, md2DOT30 time, mdQUAT* qout);
void	mdQuatNormal(mdQUAT *qin, mdQUAT *qout);
void	mdQuat2Matrix(mdQUAT *qin, mdMATRIX *mout);
void	mdMatrix2Quat(mdMATRIX *min, mdQUAT *qout);
mdINT32	mdQuatDotProduct(mdQUAT* qin0, mdQUAT* qin1, md8DOT24 *dotprod);
mdINT32	mdQuatDotProductSFT(mdQUAT* qin0, mdQUAT* qin1, mdINT32 shift, mdINT32 *dotprod);

#define 	mdSetQuat(_q,_s,_vx,_vy,_vz) \
								((_q)->s = _s,(_q)->vx = _vx,(_q)->vy = _vy, (_q)->vz = _vz)
#define 	mdAddQuat(_qin1,_qin2,_qout) \
						((_qout)->s = (_qin1)->s + (_qin2)->s, \
						 (_qout)->vy = (_qin1)->vx + (_qin2)->vx, \
						 (_qout)->vy = (_qin1)->vy + (_qin2)->vy, \
						 (_qout)->vz = (_qin1)->vz + (_qin2)->vz)
#define 	mdSubQuat(_qin1,_qin2,_qout) \
						((_qout)->s = (_qin2)->s - (_qin1)->s, \
						 (_qout)->vx = (_qin2)->vx - (_qin1)->vx, \
						 (_qout)->vy = (_qin2)->vy - (_qin1)->vy, \
						 (_qout)->vz = (_qin2)->vz - (_qin1)->vz)


//Trig Math
md16DOT16	mdFastArctan2(md16DOT16 dy, md16DOT16 dx);


//	AABB Related
mdINT32 	mdCalculateAABB(mdBYTE *M3Ddata,mdAABB *aabb);
mdINT32 	mdUpdateAABB(mdBYTE *M3Ddata,mdAABB *aabb);
md16DOT16	mdCheckVisAABB(mdAABB* aabb);
md16DOT16	mdCheckVisNearZAABB(mdAABB* aabb);


//	Depth Cue
void			mdSetFogColor(mdCOLOR* _fogcol);

#define		mdSetFogColor(_fogcol) \
					(mdActiveBlendColor(_fogcol))

void			mdSetFogNearFar(mdU16DOT16 fognear, mdU16DOT16 fogfar);
mdUINT32	mdDepthCue(mdScrV3 *vin, mdCOLOR *cout);
mdUINT32	mdDepthCue3(mdScrV3 *vin, mdCOLOR *cout);
mdUINT32	mdDepthCue4(mdScrV3 *vin, mdCOLOR *cout);
mdUINT32	mdDepthCueN(mdScrV3 *vin, mdCOLOR *cout, mdUINT32 N);


//	Clipper
mdUINT32	mdNearClip3(mdUINT32 ptype,
							mdV3 *vsrc, mdCOLOR *csrc, mdUINT32 *uvsrc,
							mdV3 *vdst, mdCOLOR *cdst, mdUINT32 *uvdst);

//	Render Object Function (The FAST way to render objects, includes DPQ)
void			mdRenderObject(mdBYTE *object, mdTEXTURE *texbase);
void			mdRenderObjectAmbient(mdBYTE *object, mdTEXTURE *texbase);

//	Assembly routine called by mdRenderObject,
//		renders a batch of primitives at once & avoids ICache swaps etc
void			_mdRenderObjData(mdBYTE *object, mdTEXTURE *texbase, mdUINT32 numpolys, void* ScratchArea);
void			_mdRenderObjDataAmbient(mdBYTE *object, mdTEXTURE *texbase, mdUINT32 numpolys, void* ScratchArea);
#endif
