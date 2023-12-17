
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Parameter Blocks for Multimedia Rendering Procs
 * rwb 9/20/98
 */

#ifndef m2dParam_h
#define m2dParam_h

#include "mrptypes.h"

//NOTE: TAJ - 11/18/98 -The following defines SHOULD AGAIN BE DEFINED in the MAKEFILE or in a *.i file. The *.s files will
// not see these defs unless they are defined in a format which can be be understood by the assembler or
// in a makefile define.  Victor Prupis has a utility for reformatting the *.h file but that is more
// complication that is not worth going into currently.
#define _DMA_BUFFSIZE  16
#define _DMA_ELPSE_BUFFSIZE  16
#define _POLYLINE_PTS  32

#define X_ASPECT	9
#define Y_ASPECT	8


typedef struct odmaCmdBlock odmaCmdBlock;
struct odmaCmdBlock
{
	int flags __attribute__ ((aligned (16)));
	uint8* sysAdr;
	uint8* dramAdr;
};

typedef struct mdmaCmdBlock mdmaCmdBlock;
struct mdmaCmdBlock
{
	int flags __attribute__ ((aligned (16)));
	uint8* sdramAdr;
	int xDesc;
	int yDesc;
	uint8* dramAdr;
	int	value;		/* for writing dup'd data directly */
};


typedef struct indexBlock indexBlock;
struct indexBlock{
	void*	clutBase;
	void*	pixBase;
	int	control;
	int	xIndex;
	int	yIndex;
};


typedef struct Scopy2ParamBlock Scopy2ParamBlock;
struct Scopy2ParamBlock{
	uint32	destFlags;	/* screenWidth<<13 | 0xC800 (pix transfer, cluster) | pixType<<4 */	
	void*	destAdr;	/* Merlin Address of SDRAM buffer */
	uint32	destX;		/* destBlockWide<<16 | destXBegin */
	uint32	destY;		/* destBlockHigh<<16 | destYBegin */
	uint32	srcFlags;	/* srcScreenWidth<<16 | srcPixType */
	void*	srcAdr;		/* Merlin Address of Sys Ram source framebuffer */
	uint32	srcPos;		/* srcXBegin<<16 | srcYBegin */
	uint32	srcSize;	/* srcBlockWide<<16 | srcBlockHigh */
	void*	clutAdr;	/* Merlin address of clut */
};

typedef struct FillColrParamBlock FillColrParamBlock;
struct FillColrParamBlock{
	uint32	destFlags;	/* 1<<26 | screenWidth<<13 | 0xC800 | SDRAMFormat<<4 */
	void*	destAdr;		/* Merlin Address of SDRAM buffer */
	uint32	destX;		/* destBlockWide<<16 | destXBegin */
	uint32	destY;		/* destBlockHigh<<16 | destYBegin */
	mmlColor color;		/* YCrCb color to use as fill */
};

typedef struct FillMpegParamBlock MpegFillParamBlock;
struct FillMpegParamBlock{
	void*	lumaBase;
	void*	chromaBase;
	uint32	frameLumaWidth;
	uint32	xDesc;
	uint32	yDesc;
	uint32	color;		// 8:8:8:8 Y:Cr:Cb:0	
};

 typedef struct SdramFillParamBlock SdramFillParamBlock;
struct SdramFillParamBlock{
	int	debug;
	int	numRowsFinished;
	int	numRowsTotal;
	int	fillTop;
	int	numRowsPerTurn;
	int	flags;	/* width, cluster, format, z, ... */
	uint8*	base;
	int	xDesc;
	int	value;
};
 
 typedef struct BiCopyParamBlock BiCopyParamBlock;
 struct BiCopyParamBlock{
 	uint32	nSwathsFinished;	/* Filled in by mmlBiCopyCal(..) */
 	uint32	nTilesFinished;	/* Filled in by mmlBiCopyCal(..) */
 	uint32	nTilesTotal;	/* Filled in by mmlBiCopyCal(..) */
 	void*	srcBase;		/* Merlin Address of Sys Ram source framebuffer */
 	uint32	srcStrideBytes;	/* width of src Pixmap, must be mult of 4 */
 	int	srcPixType;
 	int	srcTopStartPix;	/* top left of src rect to be scaled and copied */
 	int	srcLeftStartPix;
 	uint32	srcHighPix;	/* height and width of src rect to be scaled and copied */
 	uint32	srcWidePix;
 	void*	dstBase;		/* Merlin Address of SDRAM buffer. Must be multiple of 512 */
 	uint32	dstStridePix;	/* width of dst Pixmap in bytes, must be mult of 4 */
 	int	dstPixType;
 	int	dstTop;		/* top left of where to copy scaled rectangle */ 
 	int	dstLeft;
 	uint32	dstHighPix;	/* height and width clips of scaled rectangle */
 	uint32	dstWidePix;
 	int	hNum;		/* horizontal scale numerator */
 	int	hDen;		/* horizontal scale denominator */
 	int	vNum;		/* vertical scale numerator */
 	int	vDen;		/* vertical scale denominator */
 	uint32	recipV;		/* Filled in by mmlBiCopyCal(..) */
 	uint32	recipH;		/* Filled in by mmlBiCopyCal(..) */
 	uint32	nTilesWide;	/* Filled in by mmlBiCopyCal(..) */
 	uint32	nTilesHigh;	/* Filled in by mmlBiCopyCal(..) */
 	uint32	tileWidePix;	/* Filled in by mmlBiCopyCal(..) */
 	uint32	tileHighPix;	/* Filled in by mmlBiCopyCal(..) */
	uint32	nBlocksWide;	/* Filled in by mmlBiCopyCal(..) */
	uint32	nBlocksHigh;	/* Filled in by mmlBiCopyCal(..) */
 	uint32	srcPixShift;	/* Filled in by mmlBiCopyCal(..) */
 	void*	clutBase; 	/* Merlin Address of clut if srcPixType is eClut8 or eClut4 */	
				/* also used for transColor if srcType is eRGB0555 */
 };

typedef struct LineData LineData;
struct LineData{
	int	startx_y;		/* x:y, 2 bytes each, endpt. for single line, or center position for polyline */
	int	endx_y;			/* x:y, 2 bytes each, endpt. for single line */
	mmlColor	color1;
	mmlColor	color2;
	uint32	scalex_y;		/* Poly only, Scalex:Scaley, 2 bytes each, in 1.8 format	
                               The maximum value of each is 1.FF,
                               weird behavior at 2.ff:
                               Scalex=2.ff causes x to decrease;
                               Scaley=2.ff causes y to flip orientation*/
	uint32	translucRadius; /* translucency:radius, 2 bytes each */
	int	rotAngle;		/* Poly only, rotation angle */
	int*	pList;			/* Poly only, address of polyline list (0 if not polyline);	*/
};

typedef struct rzinf rzinf;
struct rzinf{
	int	baseMPE;		/* MPE# to render first strip -  should be set to 0, if only 1 MPE */
	int	height;			/* height of render strip */
	int	totRenderMPE;	/* Total # of MPEs which will do rendering */
	int	unused;
};

enum lineType{
	eaaline1 = 1,
	eaaline2,
	eaaline3,
	eaaline4,
	eaaline5,
	eaaline6,
    eaaline3clut,
    eaaline7clut };
typedef enum lineType lineType;

enum ellipseType{
	eellipse1 = 1,
    eellipseclut8 };
typedef enum ellipseType ellipseType;

// NOTE: 1/29/99- DrawLineParamBlock, dma__cmdAddr[8], odmacmdAddr[4], & genbufAddr[_DMA_BUFFSIZE]
// should fit in the memory block in dtram allocated by mrpSetup which is 192 longs
typedef struct DrawLineParamBlock DrawLineParamBlock;
struct DrawLineParamBlock{
    // DrawLineParamBlock needs to be vector- aligned.
    //It will not be vector-aligned with the current "mrpSetup()" version 
	void*	destAdr;		/* Merlin Address of SDRAM buffer */
	uint32  dmaFlags;
	int32	xHiLoClip;
	int32	yHiLoClip;

	rzinf	rzinfData;
	LineData	object;

	int32*	pline_ptr;
	int32	cs[3];
	int32	cinterp[4];
	int32	iv0[4];
	int32	iv1[4];
	int32	pline[_POLYLINE_PTS + 4];		/* polyline table*/
								/* NOTE: 02 Nov 98 - Added 4 to be able to use new odma_wtrd which works */
								/* around Other Bus DMA bug	*/
	int32	trig[4];		/* vector for storing trig */
	int32	max_x[4];
	int32	randNum[4];		/* random numbers */
	mdmaCmdBlock* dma__cmdAddr;
	odmaCmdBlock* odmacmdAddr;
	int32*  genbufAddr;
	int32   idxPerWidth;   // used for clut mode:
                       // ((nClutAlpha-1)<<28)/(0.5 * total width)
};

typedef struct EllipseData EllipseData;
struct EllipseData{
	int32		xc_yc;				/* xcenter:ycenter, 2 bytes each, each int16 */
	int32		rad_width;			/* radius:width, 2 bytes each, each int16 */
	mmlColor	color1;
	mmlColor	color2;			/* unused, just a placeholder */

	int32		scalex_y;		/* xscale:yscale, 2 bytes each, each 8.8 format, max value=0xff.ff */
	uint32		alpha;			/* translucency	*/
  	int32		fill;			/* 0 = Open  1 = Filled	*/
	int32		unused;			/* for vector alignment	*/
};


// NOTE: 1/29/99- DrawEllipseParamBlock, dma__cmdAddr[8], odmacmdAddr[4], & genbufAddr[2*_DMA_ELPSE_BUFFSIZE]
// should fit in the memory block in dtram allocated by mrpSetup which is 192 longs.
// genbufAddr[2*_DMA_ELPSE_BUFFSIZE] has 2*_DMA_ELPSE_BUFFSIZE since 1 buffer is for left-side of ellipse
//   and another buffer is for right-side
typedef struct DrawEllipseParamBlock DrawEllipseParamBlock;
struct DrawEllipseParamBlock{
	void*		destAdr;		/* Merlin Address of SDRAM buffer */
	int32		dmaFlags;
	int32		xHiLoClip;
	int32		yHiLoClip;

	rzinf		rzinfData;

	EllipseData	object;

	int32		view[4];
	int32		mixcache[_DMA_ELPSE_BUFFSIZE];
/*	int			dummy;			// dummy var to make binary table OK   */
	mdmaCmdBlock* dma__cmdAddr;
//	int32*		inbufAddr;
	int32*		genbufAddr;
	int32       idxPerWidth;   // used for clut mode:
                               // ((nClutAlpha-1)<<28)/(0.5 * total width)
	int32		unused;   /* TAJ - 10/5/98 - DrawEllipseParamBlock has to be vector-aligned */
};

typedef struct COFFparamblock {
    void* 		coffAddr;   /* pointer to COFF file in system RAM - Merlin address space */
    uint32		flags;      /* bitmap of flags for startup:
                            bit 0 == 1 to start new MPE, 0 not to start
                            bit 1 == 1 to halt ourselves, 0 to continue running */
    uint32		whichMPE;   /* target MPE */
    void*		mmpAddr;	/* pointer to place the COFF file in Merlin address space 
    					    defaults to 0x20100C00 if 0 is specified. */
    uint32		length;
    int			reserved;
} COFFparamblock;

typedef struct Stillparamblock {
	void* 		imageAddr;	// Pointer to image in system RAM - Merlin address space
	int32		size;		// Size of image (buffer must be padded mod 256 bytes, scalar aligned)
	int32 		reserved1;
	int32 		reserved2;
} Stillparamblock;

 typedef struct linMovParamBlock linMovParamBlock;
 struct linMovParamBlock
 {
	uint32	srcFlags;	/* screenWidth<<13 | 0xC800 (pix transfer, cluster) | pixType<<4 */	
	void*	srcAdr;		/* Merlin Address of SDRAM buffer */
	uint32	srcX;		/* destBlockWide<<16 | destXBegin */
	uint32	srcY;		/* destBlockHigh<<16 | destYBegin */
	uint32	destFlags;	/* screenWidth<<13 | 0xC800 (pix transfer, cluster) | pixType<<4 */	
	void*	destAdr;	/* Merlin Address of SDRAM buffer */
	uint32	destX;		/* destBlockWide<<16 | destXBegin */
	uint32	destY;		/* destBlockHigh<<16 | destYBegin */
	uint32	flags;		/* moveUp << 2 | moveLeft << 1 | changeFormat */
 };

typedef struct glyphDescriptor glyphDescriptor;
struct glyphDescriptor{
	uint32*		glyphAdr;
	uint16		nLeftCols;
	uint16		size;		/* num longs in pixmap */
};

typedef struct DrawGlyphParamBlock DrawGlyphParamBlock;
struct DrawGlyphParamBlock{
 	char*		dstBase;		/* must be mult of 512 */
 	int		dstStridePix;	/* width of dst Pixmap */
 	int		dstFormat;		/* pixtype and Cluster bit */
 	int		dstTop;		/* these 4 describe rect in */ 
 	int		dstLeft;		/* which to place glyphs */
 	int		dstHighPix;		
 	int		dstWidePix;		
	int		excess;
	int		nTrailCols;
	mmlColor	foreColor;
	mmlColor	backColor;
	int		nGlyphsTotal;
	int		indexVals;		/* div | max | base */
	int		translucent;		
	glyphDescriptor	glyph[0];
};

typedef struct InfoParamBlock InfoParamBlock;
struct InfoParamBlock{
	int32	data[4];
};

typedef struct mainchParamBlock mainchParamBlock;
struct mainchParamBlock{
	int	screen_x_offset;
	int	screen_y_offset;
	int	screen_width;
	int	screen_height;
};

typedef struct osdchParamBlock osdchParamBlock;
struct osdchParamBlock{
	int	screen_x_offset;
	int	screen_y_offset;
	int	screen_width;
	int	screen_height;
	void*	srcBuf_address;
	int	srcBuf_xfr_flags; //cluster | (pix << 4)
	int	srcBuf_width;
	int	srcRect_x_offset;
	int	srcRect_y_offset;
	int	srcRect_width;
	int	srcRect_height;
	int	clut_select;
	int	alpha;
	int	vert_filter;
};

typedef struct PcmPlayParamBlock PcmPlayParamBlock;
struct PcmPlayParamBlock{
	uint32	coding_method;	/* Sample coding method */
	uint32	buf;			/* Buffer address (NUON space) */
	uint32	buf_size;		/* Buffer size (bytes) */
	uint32	sample_rate;	/* Sample rate */
	uint8		num_channels;	/* Number of Channels (1,2) */
	uint8		sample_size;	/* Sample Size (8, 16) */
	uint8		byte_endian;	/* Byte endian flag */
	uint8		bit_endian;		/* Bit endian flag */
};

typedef struct PcmGainParamBlock PcmGainParamBlock;
struct PcmGainParamBlock{
	// uint8		lines;
	uint32		lines;
	uint8		front_left;
	uint8		front_right;
	uint8		pad;
};

typedef struct MrpCommand MrpCommand;
struct MrpCommand{
	uint32	functionCode;
	uint32	*parBlockAdr;
	uint32	arg2;
	uint32	arg3;
};


 typedef struct CopySDRAMParamBlock CopySDRAMParamBlock;
 struct CopySDRAMParamBlock{
 	void*	srcBase;		/* Merlin Address of Sys Ram source framebuffer */
 	uint32	srcStrideBytes;	/* width of src Pixmap, must be mult of 4 */
 	int	srcPixType;
 	int	srcTopStartPix;	/* top left of src rect to be scaled and copied */
 	int	srcLeftStartPix;
 	uint32	srcHighPix;	/* height and width of src rect to be scaled and copied */
 	uint32	srcWidePix;
 	void*	dstBase;		/* Merlin Address of SDRAM buffer. Must be multiple of 512 */
 	uint32	dstStrideBytes;	/* width of dst Pixmap in bytes, must be mult of 4 */
 	int	dstPixType;
 	int	dstTop;		/* top left of where to copy scaled rectangle */ 
 	int	dstLeft;
 	uint32	dstHighPix;	/* height and width clips of scaled rectangle */
 	uint32	dstWidePix;
 	uint32	blend;		/* 1 for blend, 0 for srcCopy */
 };

typedef struct CopyClutParamBlock CopyClutParamBlock;
struct CopyClutParamBlock{
	void*	srcBufferAdr;
	int		srcByteWidth;	// width of Pixmap (in bytes)				
	int		srcLeftCol;			
	int		srcTopRow;
	void*	destBufferAdr;
	int		destFlags;		// must be clut8 and Write	
	int		destLeftCol;			
	int		destTopRow;
	int		rowLength;
	int		numRows;
};


typedef struct FillClutParamBlock FillClutParamBlock;
struct FillClutParamBlock
{
	void*		destBufferAdr;
	int		destFlags;		// must be clut8 and Write	
	int		destLeftCol;			
	int		destTopRow;
	int		rowLength;
	int		numRows;
	uint32	fillData;
};

typedef struct CopyRectFastParamBlock CopyRectFastParamBlock;
struct CopyRectFastParamBlock{
	void*	srcBufferAdr;
	int		srcByteWidth;	// width of Pixmap (in bytes)				
	int		srcLeftCol;			
	int		srcTopRow;
	void*		destBufferAdr;
	int		destFlags;		// must be pixtype 8 and Write	
	int		destLeftCol;			
	int		destTopRow;
	int		rowLength;
	int		numRows;
	int		srcPixShift;			
};

typedef struct CopyTileParamBlock CopyTileParamBlock;
struct CopyTileParamBlock{
	void*	srcArrayAdr;
	int		srcPixStride;
	int		srcRectWide;
	int		srcRectHigh;
	int		clutAdrTrans;  // clutAdr | (transIndex<<2)
	void*		destAdr;
	int		destFlags;
	int		destLeftCol;
	int		destTopRow;
};

#endif

