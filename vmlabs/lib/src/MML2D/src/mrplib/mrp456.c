
/* CopyRight (c) 1995-1998, VM Labs, Inc., All Rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */
/* rwb 6/5/98
 * MRP functions that reserve v6 and v5
 */

#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
Reserve( 24, 25, 26, 27 )
Reserve( 20, 21, 22, 23 )
Reserve( 16, 17, 18, 19 )

#define min( a, b ) ( (a) < (b) ? (a) : (b) )

		
/* ScaleTileRow
Scale hden*numBlocks pixels of a single source row beginning at srcBeg,
into hnum*numBlocks pixels on the same row beginning at srcDst.
Row is specified in Block object
Use scale factor hnum/hden and linear interpolation.
recipH format is 2.30 with the least significant 16 bits set to 0
rwb 7/29/99 bugfix to also use alpha component
*/
void ScaleTileRow( indexBlock* rBlockP, int srcBeg, int dstBeg,
		int hnum, int hden, int recipH, int numBlocks )
{
	int numNeeded, numRemain, alpha, numPix;

	numNeeded = hden;
	numPix = hnum * numBlocks;
	SetIndex(xybase,xyctl,rx,ry,rBlockP->pixBase, rBlockP->control, srcBeg, rBlockP->yIndex )
	SetIndex(uvbase,uvctl,ru,rv,rBlockP->pixBase, rBlockP->control, dstBeg, rBlockP->yIndex )
	Push( v6 )
	Push( v5 )
	Push( v4 )

	ClrPixAlpha( v5 )			//Z = 0;
	GetDRamAlphaPP( v6, xy, rx )  	//V = rBlock++;	
	MulPixAlpha( v6, recipH )	//V *= recipH;		
	numRemain = hnum;
	do
	{
		alpha = min( numRemain, numNeeded );
		MulPixIntAlpha( v6, alpha<<16, v4 )			//Z += (alpha * V );
		AddPixAlpha( v4, v5 )
		numRemain -= alpha;
		if( numRemain == 0 )
		{			
			GetDRamAlphaPP( v6, xy, rx )  	//V = rBlock++;	
			MulPixAlpha( v6, recipH )	//V *= recipH;		
			numRemain = hnum;
		}
		numNeeded -= alpha;
		if( numNeeded == 0 )	
		{
			PutDRamAlphaPP( v5, uv, ru )
			ClrPixAlpha( v5 )			//Z = 0;
			numNeeded = hden;
			--numPix;
		}
	}while( numPix > 0 );
	Pop( v4 )
	Pop( v5 )
	Pop( v6 )
}

/* Read a single tile row from background */
static void ReadBackground(int flags, void* screenBase, int xDesc, int yDesc, indexBlock* rBlockP, mdmaCmdBlock* mdmaP, int transRow )
{

	MRP_DmaWait( kmdmactl );
	Push( v6 )
	SetVector( v6, flags, screenBase, xDesc, yDesc )
	StoreVector( v6, mdmaP )
	SL(mdmaP->dramAdr , rBlockP->pixBase + transRow * 4*(rBlockP->control & 0x7FF));
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
	Pop( v6 )
}	

/* ScaleTileRowTrans
Scale hden*numBlocks pixels of a single source row beginning at srcBeg,
into hnum*numBlocks pixels on the same row beginning at srcDst.
Row is specified in Block object
Use scale factor hnum/hden and linear interpolation.
recipH format is 2.30 with the least significant 16 bits set to 0
11/23/98 rwb Modified for transparent source pixels. This function is only
called if some pixels may be transparent.
flags, xDesc, yDesc, and screenBase are required parameters to dma in the SDRAM row
12/3/98 rwb Transparent pixels are indicated by an alpha value of 0xFF in dtram
*/
void ScaleTileRowTrans( indexBlock* rBlockP, int srcBeg, int dstBeg,
		int hnum, int hden, int recipH, int numBlocks, int transRow,
		void* screenBase, int flags, int xDesc, int yDesc, mdmaCmdBlock* mdmaP )
{
	int numNeeded, numRemain, alpha, numPix, transRead, trans, vSave;

	transRead = 0;	
	numNeeded = hden;
	numPix = hnum * numBlocks;
	SetIndex(xybase,xyctl,rx,ry,rBlockP->pixBase, rBlockP->control, srcBeg, rBlockP->yIndex )
	SetIndex(uvbase,uvctl,ru,rv,rBlockP->pixBase, rBlockP->control, dstBeg, rBlockP->yIndex )
	Push( v6 )
	Push( v5 )
	Push( v4 )

	ClrPix( v5 )			//Z = 0;
	GetDRamAlphaPP( v6, xy, rx )  	//V = rBlock++;
	GetRegister( r27, trans )
	if( trans == kTrans )
	{
		ReadBackground( flags, screenBase, xDesc, yDesc, rBlockP, mdmaP, transRow );
		transRead = 1;
		GetMpeCtrl( rv, vSave )
		SetMpeCtrl( rv, (transRow<<16) )
		GetDRam( v6, uv )
		SetMpeCtrl( rv, vSave )
	}
	MulPix( v6, recipH )	//V *= recipH;		
	numRemain = hnum;
	do
	{
		alpha = min( numRemain, numNeeded );
		MulPixInt( v6, alpha<<16, v4 )			//Z += (alpha * V );
		AddPix( v4, v5 )
		numRemain -= alpha;
		if( numRemain == 0 )
		{
			GetDRamAlphaPP( v6, xy, rx )  	//V = rBlock++;	
			GetRegister( r27, trans )
			if( trans == kTrans )		// transparent
			{
				if( transRead == 0 )
				{
					ReadBackground( flags, screenBase, xDesc, yDesc, rBlockP, mdmaP, transRow );
					transRead = 1;
				}
				GetMpeCtrl( rv, vSave )
				SetMpeCtrl( rv, (transRow<<16) )
				GetDRam( v6, uv )
				SetMpeCtrl( rv, vSave )				
			}
			MulPix( v6, recipH )	//V *= recipH;		
			numRemain = hnum;
		}
		numNeeded -= alpha;
		if( numNeeded == 0 )	
		{
			PutDRamPP( v5, uv, ru )
			ClrPix( v5 )			//Z = 0;
			numNeeded = hden;
			--numPix;
		}
	}while( numPix > 0 );
	Pop( v4 )
	Pop( v5 )
	Pop( v6 )
}


/* ScaleTileCol
Scale vden*numBlocks pixels of a single source column beginning at srcBeg,
into vnum*numBlocks pixels on the same column beginning at srcDst.
Column is specified in Block object
Use scale factor vnum/vden and linear interpolation.
recipV format is 2.30 with the least significant 16 bits set to 0
*/
void ScaleTileCol( indexBlock* rBlockP, int srcBeg, int dstBeg,
		int vnum, int vden, int recipV, int numBlocks )
{
	int numNeeded, numRemain, alpha, numPix;

	numNeeded = vden;
	numPix = vnum * numBlocks;
	SetIndex(xybase,xyctl,rx,ry,rBlockP->pixBase, rBlockP->control, rBlockP->xIndex, srcBeg )
	SetIndex(uvbase,uvctl,ru,rv,rBlockP->pixBase, rBlockP->control, rBlockP->xIndex, dstBeg )
	Push( v6 )
	Push( v5 )
	Push( v4 )

	ClrPixAlpha( v5 )
	GetDRamAlphaPP( v6, xy, ry )  		
	MulPixAlpha( v6, recipV )				
	numRemain = vnum;

	do{			
		alpha = min( numRemain, numNeeded );
		MulPixIntAlpha( v6, alpha<<16, v4 )	
		AddPixAlpha( v4, v5 )
		numRemain -= alpha;
		if( numRemain == 0 )
		{			
			GetDRamAlphaPP( v6, xy, ry )  		
			MulPixAlpha( v6, recipV )				
			numRemain = vnum;
		}
		numNeeded -= alpha;
		if( numNeeded == 0 )	
		{
			PutDRamAlphaPP( v5, uv, rv )	
			ClrPixAlpha( v5 )			
			numNeeded = vden;
			--numPix;
		}
	}while( numPix > 0 );
	Pop( v4 )
	Pop( v5 )
	Pop( v6 )
}
