/*
 * Title	 			SETUP.C
 * Desciption		Merlin 3D Library Setup Functions
 * Version			1.0
 * Start Date		02/15/2000
 * Last Update	02/25/2000
 * By						Phil
 * Of						Miracle Designs
 * History:
 * Known bugs:
*/

#include <m3dl/m3dl.h>
#include <nuon/mpe.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>

//Implemented in removmpr.s
void	_mdRemoveMPRChain(void);

extern	mdUINT16	MPR_mpeinfo[];
extern 	void*	MPR_Start[];
extern 	void*	MPR_CodeBase[];
extern 	void*	mprc_start[];
extern 	void*	mprc_size[];
extern 	void*	MPR_Data[];
extern 	void*	MPRData[];
extern 	void*	MPRDataSize[];


#define addrofINTCTL		0x205000F0
#define addrofEXCEPCLR	0x20500020
#define addrofSP				0x205002E0


mdUINT32	mdSetupMPRChain(startmpe, nummpes)
mdUINT32 startmpe;
mdUINT32 nummpes;
{
	mdUINT32	actmpe;

	//Do MPE allocation here
	/*
	 	FixMe: This needs fixing up so mpes are allocated dynamically
		However, the assembly code needs mpe#s to be consecutive
	*/
	for (actmpe=startmpe;actmpe<(startmpe+nummpes);actmpe++) {
		if (_MPEAllocSpecific(actmpe) < 0) {
			return 1;
		}; //if
	}; //for i

	//Setup M3DL MPR Info table
	_SetLocalVar(MPR_mpeinfo[0],(startmpe<<16)|(startmpe+nummpes));
	_SetLocalVar(MPR_mpeinfo[2],(startmpe<<16)|(0));

	//First stop all requested MPRs
	for (actmpe=startmpe;actmpe<(startmpe+nummpes);actmpe++) {
		_MPEStop(actmpe);
	}; //for i

	//Copy Data to M3DL MPRs
	for (actmpe=startmpe;actmpe<(startmpe+nummpes);actmpe++) {
		//Setup code segment
		_MPELoad(actmpe,MPR_CodeBase,mprc_start,(long)mprc_size);

		//Setup data segment (recip table)
		_MPELoad(actmpe,MPR_Data,MPRData,(long)MPRDataSize);
	}; //for i

	//Now start all MPRs
	for (actmpe=startmpe;actmpe<(startmpe+nummpes);actmpe++) {
		//Validate MPE registers
		_MPEWriteRegister(actmpe,(void*)addrofINTCTL,((1<<7)|(1<<3)));
		_MPEWriteRegister(actmpe,(void*)addrofEXCEPCLR,(1<<0));
		_MPEWriteRegister(actmpe,(void*)addrofSP,((long)(MPR_CodeBase))+(4*1024));
		//Boot it!
		_MPERun(actmpe,MPR_Start);
	}; //for i

	//Successful
	return 0;
}; //mdSetupMPRChain()


void	mdRemoveMPRChain(void)
{
	mdUINT32	actmpe;
	mdUINT32	startmpe;
	mdUINT32	endmpe;

	//Get M3DL MPR Info table
	actmpe = _GetLocalVar(MPR_mpeinfo[0]);

	startmpe = actmpe>>16; 				 				//Set Starting MPE
	endmpe = actmpe & 0xFFFF;							//Set Ending MPE (not inclusive)

	//Invoke the old assembly version
	_mdRemoveMPRChain();

	//Free MPEs allocated by _MPEAllocSpecific()
	for (actmpe=startmpe;actmpe<endmpe;actmpe++) {
		_MPEFree(actmpe);
	}; //for i
}; //mdRemoveMPRChain()


#define MAX_XFERSIZE	(32*4)

mdUINT32	_mdCopyBitmap(mdBYTE *srcaddr,mdBYTE *dstaddr,mdUINT32 pixtype,mdUINT32 width,mdUINT32 height)
{
	void	*scratcharea;
	mdINT32	scratchsize;
	mdINT32	bmsizeinbytes;
	mdINT32	minstripsize;
	mdINT32	pixtobytes;
	mdINT32 xfersize;

	scratchsize = 0;
	scratcharea = _MemLocalScratch(&scratchsize);
	if (scratchsize < MAX_XFERSIZE) {
		//Unable to copy because internal memory area is too small
		return 0;
	};

	minstripsize = 32;
	pixtobytes = 0;
	bmsizeinbytes = 0;
	switch (pixtype) {
		case PIX_4B:
			bmsizeinbytes = (width*height)>>1;
			pixtobytes = 1;
			minstripsize = minstripsize<<1;
			break;
		case PIX_8B:
			bmsizeinbytes = (width*height);
			break;
		case PIX_16B:
			bmsizeinbytes = (width*height)<<1;
			pixtobytes = -1;
			minstripsize = minstripsize>>1;
			break;
	}; //switch (pixtype)

	if (bmsizeinbytes > 0) {
		if (1) {
/*
 BILINEAR MODE HAS BEEN REMOVED 02-25-2000
		if (	(((long)dstaddr) & 0x80000000) ||
					(width < minstripsize) ||
					(bmsizeinbytes < 256)
			 ) {
*/
			//Use Linear Destination
			while (bmsizeinbytes > 0) {
				//Set maximum transfer size
				xfersize = MAX_XFERSIZE;
				//Limit transfer size
				if (xfersize > bmsizeinbytes) {
					xfersize = bmsizeinbytes;
				};
				//Read transfer size #of bytes from srcaddr to scratcharea
				_DMALinear((CONTIGUOUS|LINEAR|READ|((xfersize>>2)<<16)),srcaddr,scratcharea);
				srcaddr += xfersize;
				//Write transfer size #of bytes from scratcharea to dstaddr
				_DMALinear((CONTIGUOUS|LINEAR|WRITE|((xfersize>>2)<<16)),dstaddr,scratcharea);
				dstaddr += xfersize;
				bmsizeinbytes -= xfersize;
			}; //while (bmsizeinbytes)
			//Done: return end address
			return (long)dstaddr;
		} else {
			mdINT32	xpos,ypos,xlen;
			mdINT32	linewidth;

			//Use MDMA Bilinear Destination
			for (ypos=0;ypos<height;ypos++) {
				//Set line width in pixels
				linewidth = width;
				//Clear xpos
				xpos = 0;
				while (linewidth > 0) {
					//Convert MAX_XFERSIZE bytes to #of pixels
					xlen = MAX_XFERSIZE<<(pixtobytes);
					//Limit transfer size
					if (xlen > linewidth) {
						xlen = linewidth;
					}; //if
					//Convert xlen (in pixels) to #of bytes for linear dma
					xfersize = xlen>>(pixtobytes);
					//Read transfer size #of bytes from srcaddr to scratcharea
					_DMALinear((CONTIGUOUS|LINEAR|READ|((xfersize>>2)<<16)),srcaddr,scratcharea);
					srcaddr += xfersize;
					//Bilinear Write xlen pixels from scratchaddr to dstaddr window
					_DMABiLinear((HORIZONTAL|PIXEL|WRITE|NW_Z|(pixtype<<4)|((width>>3)<<16)),dstaddr,((xlen<<16)|xpos),((1<<16)|ypos),scratcharea);
					xpos += xlen;
					linewidth -= xlen;
				}; //while (linewidth)
			}; //for ypos
			//Done: return end address
			return ((long)dstaddr)+bmsizeinbytes;
		}; //if
	}; //if

	return 0;
}; //_mdCopyBitmap()
