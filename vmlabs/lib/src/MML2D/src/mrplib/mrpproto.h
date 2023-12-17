
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* PIX Type Defs, etc.
 * rwb 6/5/98
 * defines used by pixel manipulation MediaRenderingProcs
 * also prototypes for auxillary functions.
 */
#ifndef mrpproto_h
#define mrpproto_h

#include "mrptypes.h"
#include "parblock.h"
#include "biosdma.h"

/*-------------------------------------------------------------------------------------------------
	prototypes
-------------------------------------------------------------------------------------------------*/
mrpStatus copDefault(BiCopyParamBlock* par, indexBlock* indexInP,
	indexBlock* indexOutP, odmaCmdBlock* odmaP, mdmaCmdBlock* mdmaP,
	int transVidQ,  int transFrameQ, int transColor )__attribute__ ((section ("bicI")));
mrpStatus copUns1RGB16Vid(BiCopyParamBlock* par, indexBlock* indexInP,
	indexBlock* indexOutP, odmaCmdBlock* odmaP, mdmaCmdBlock* mdmaP,
	int transVidQ,  int transFrameQ )__attribute__ ((section ("bic1")));
mrpStatus copUns0RGB16Vid(BiCopyParamBlock* par, indexBlock* indexInP,
	indexBlock* indexOutP, odmaCmdBlock* odmaP, mdmaCmdBlock* mdmaP,
	int transColor )__attribute__ ((section ("bic0")));
mrpStatus copUnsClut16No(BiCopyParamBlock* par, indexBlock* indexInP,
	indexBlock* indexOutP, odmaCmdBlock* odmaP, mdmaCmdBlock* mdmaP,
	int transVidQ,  int transFrameQ )__attribute__ ((section ("bicC")));
mrpStatus CopyRectFast( int environs, CopyRectFastParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus CopyRGBFast( int environs, CopyRectFastParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus CopyRect16( int environs, CopyRectFastParamBlock* parBlockP, int arg2, int arg3 ); 
void copyfast16A( int pixToDo, int srcStart, int dstStart,
	odmaCmdBlock* odmaP, mdmaCmdBlock* mdmaP );

void DmaReadRow(  char* internAdr, char* srcAdr, int numScalars, odmaCmdBlock* odmaP ) __attribute__ ((section ("bicI")));
void DmaWriteBlock( char* tileBase, int blockWidthBytes, int nRows, int numPixels, 
 	char* screenBase, int screenStrideBytes, int dLeft, int dTop, int dstType,
 	mdmaCmdBlock* mdmaP)__attribute__ ((section ("bicI")));
void RepeatPixels( indexBlock* rBlockP, int xLast, int numPix )__attribute__ ((section ("bicI")));
void RepeatRows( indexBlock* rBlockP, int row, int pixPerRow, int numRows )__attribute__ ((section ("bicI")));
void ColorCvrt( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int srcType )__attribute__ ((section ("bicI")));
void ColorCvrtTrans( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int srcType )__attribute__ ((section ("bicI")));
void ColorCvrtBB( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int srcType )__attribute__ ((section ("bicI")));
void ColCvrt1RGB16( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int transFlag )__attribute__ ((section ("bic1")));
void ColCvrt0RGB16( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int transColor )__attribute__ ((section ("bic0")));
void ScaleTileRow( indexBlock* rBlockP, int srcBeg, int dstBeg,
		int hnum, int hden, int recipH, int nBlocks )__attribute__ ((section ("bicI")));
void ScaleTileRowTrans( indexBlock* rBlockP, int srcBeg, int dstBeg,
		int hnum, int hden, int recipH, int numBlocks, int transRow,
		void* screenBase, int flags, int xDesc, int yDesc, mdmaCmdBlock* mdmaP )__attribute__ ((section ("bicI")));
void ScaleTileCol( indexBlock* rBlockP, int srcBeg, int dstBeg,
		int vnum, int vden, int recipV, int nBlocks )__attribute__ ((section ("bicI")));
mrpStatus BiCopy(int environs, BiCopyParamBlock* par, int arg2, int arg3 )__attribute__ ((section ("bicC"))); 
void MoveTileRow( indexBlock* rBlockP, int srcBeg, int dstBeg,
		int hnum )__attribute__ ((section ("bicI")));
void MoveTileCol( indexBlock* rBlockP, int srcBeg, int dstBeg,
		int vnum )__attribute__ ((section ("bicI")));
int mrpSetup( int env, int parBlockSizeLongs, odmaCmdBlock** odmaP,
	mdmaCmdBlock** mdmaP, int** parP, uint8** tileP, int** endP );
void mrpSysRamMove( int numScalars,  char* internAdr, char* srcAdr,
  odmaCmdBlock* odmaP, int readQ, int waitQ);
int blendPix( int mask, mmlColor* foreColorP, mmlColor* backColorP, int linCtrl );
int blendPixAlpha( int mask, mmlColor* foreColorP, mmlColor* backColorP, int linCtrl );
void MovePixDirect( int flags, uint32* buffer, void* frameP, int x, int y,
 int numPix, int vert, uint32* tile, int readQ );	
void SmallFillDirect(int flags, void* frameAdr, int xDesc, int yDesc, void* mdmaBlock, int color ); 

mrpStatus SmallFillDispatch( int environs, void* frameP, int coords, int flags );
mrpStatus SdramFill(int environs, SdramFillParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_line1(int environs, DrawLineParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_line2(int environs, DrawLineParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_line3(int environs, DrawLineParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_line4(int environs, DrawLineParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_line5(int environs, DrawLineParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_line6(int environs, DrawLineParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_line3clut(int environs, DrawLineParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_line7clut(int environs, DrawLineParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_ellipse(int environs, DrawEllipseParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_clut_ellipse(int environs, DrawEllipseParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus draw_arc(int environs, DrawEllipseParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus TexBlt(int environs, DrawGlyphParamBlock* parAdr, int numGlyphs, int arg3 );
mrpStatus MrpInfo(int environs, SdramFillParamBlock* parBlockP, int selector, int arg3 );
mrpStatus CopySDRAM(int environs, CopySDRAMParamBlock* parBlockP, int arg2, int arg3 ); 
mrpStatus MovePixDispatch( int environs, void* frameP, uint32* buffer, int flags );

int findAddress( int tab[][2], int index );
//void odmaWait( );

/*-------------------------------------------------------------------------------------------------
	Two possible build options:
	- GUI = OEM specific, that is, one of { Toshiba, Samsung, Raite, ... }
		- DMA calls are built in to MML2D
		- the DVD player is the customer for MML2D
	- NATIVE = OEM independent, that is, a graphics app, probably not running a DVD player
		- calls BIOS for DMA
		- games (and other graphics apps) are the customers for MML2D
rwb revised 4/9/00
	- all clients call BIOS dma functions
-------------------------------------------------------------------------------------------------*/
/* #if defined(DVD) -- we will need to supply these functions if we decide that we
need dma functions that execute out of iram for performance reasons */
#if 0

#define MRP_DmaWait(control)                                 icode_Dma_wait(control)

#define MRP_DmaDo(control,comblock,waitq)                    icode_Dma_do(control,comblock,waitq)

#define MRP_DmaXfer(control,commandblock,waitq,nitems,vertq) \
		icode_Dma_xfer(control,commandblock,waitq,nitems,vertq)

#else	/* NATIVE */
					
#define MRP_DmaWait(control)				 	                _Dma_wait(control)

#define MRP_DmaDo(control,commandblock,waitq)					\
		_Dma_do(control,commandblock,waitq)

#define MRP_DmaXfer(control,commandblock,waitq,nitems,vertq)	\
		bio_lib_xfer(control,commandblock,waitq,nitems,vertq)
		
#endif /* GUI */
		
#endif
