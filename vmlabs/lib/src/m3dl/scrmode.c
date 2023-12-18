/*
 * Title	 			SCRMODE.C
 * Desciption		Merlin 3D Library Screen Mode Functions
 * Version			1.0
 * Start Date		09/16/1998
 * Last Update	03/28/2000
 * By						Phil
 * Of						Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  01/15/99 Bugfixes
 *  01/15/99 Bugfix dcx[1].actbuf not initialised
 * Known bugs:
*/

#include <m3dl/m3dl.h>
#include <nuon/video.h>

//Screen Mode Functions
mdUINT32 mdSetBufYCC16B_NOZ(dcx, sdramstart, nrendbuf, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
mdUINT32		nrendbuf;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//check buffering
	if ( (nrendbuf<1) || (nrendbuf>3) )
		return(0);

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = nrendbuf;
	dcx[0].dispw = dispw;
	dcx[0].disph = disph;
	dcx[0].rendx = rendx;
	dcx[0].rendy = rendy;
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = 0;
	dcx[0].zcmpflags[1] = 0;

	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	//no Z shared
	sdramlen = dcx[0].dispw*dcx[0].disph*2;		//size in bytes
	for (i=0; i<nrendbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[0].buf[i].sdramaddr = sdramaddr;
		if ((dcx[0].dispw > 360) ||
				( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
			dcx[0].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B_NOZ)|((dcx[0].dispw>>3)<<16));
		} else {
			dcx[0].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_16B_NOZ)|((dcx[0].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufYCC32B_NOZ(dcx, sdramstart, nrendbuf, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
mdUINT32		nrendbuf;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//check buffering
	if ( (nrendbuf<1) || (nrendbuf>3) )
		return(0);

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = nrendbuf;
	dcx[0].dispw = dispw;
	dcx[0].disph = disph;
	dcx[0].rendx = rendx;
	dcx[0].rendy = rendy;
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = 0;
	dcx[0].zcmpflags[1] = 0;

	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	//no Z shared
	sdramlen = dcx[0].dispw*dcx[0].disph*4;		//size in bytes
	for (i=0; i<nrendbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[0].buf[i].sdramaddr = sdramaddr;
		if ((dcx[0].dispw > 360) ||
				( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
			dcx[0].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_32B_NOZ)|((dcx[0].dispw>>3)<<16));
		} else {
			dcx[0].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_32B_NOZ)|((dcx[0].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufYCC16B_WITHZ(dcx, sdramstart, nrendbuf, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
mdUINT32		nrendbuf;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//check buffering
	if ( (nrendbuf<1) || (nrendbuf>3) )
		return(0);

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = nrendbuf;
	dcx[0].dispw = dispw;
	dcx[0].disph = disph;
	dcx[0].rendx = rendx;
	dcx[0].rendy = rendy;
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = WR_ZLO;
	dcx[0].zcmpflags[1] = WR_ZLO;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramlen = dcx[0].dispw*dcx[0].disph*4;		//size in bytes
	for (i=0; i<nrendbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[0].buf[i].sdramaddr = sdramaddr;
		if ((dcx[0].dispw > 360) ||
				( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
			dcx[0].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B_WITHZ)|((dcx[0].dispw>>3)<<16));
		} else {
			dcx[0].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_16B_WITHZ)|((dcx[0].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufYCC32B_WITHZ(dcx, sdramstart, nrendbuf, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
mdUINT32		nrendbuf;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//check buffering
	if ( (nrendbuf<1) || (nrendbuf>3) )
		return(0);

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = nrendbuf;
	dcx[0].dispw = dispw;
	dcx[0].disph = disph;
	dcx[0].rendx = rendx;
	dcx[0].rendy = rendy;
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = WR_ZLO;
	dcx[0].zcmpflags[1] = WR_ZLO;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramlen = dcx[0].dispw*dcx[0].disph*8;		//size in bytes
	for (i=0; i<nrendbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[0].buf[i].sdramaddr = sdramaddr;
		if ((dcx[0].dispw > 360) ||
				( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
			dcx[0].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_32B_WITHZ)|((dcx[0].dispw>>3)<<16));
		} else {
			dcx[0].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_32B_WITHZ)|((dcx[0].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufYCC16B_WITHZSHARED(dcx, sdramstart, nrendbuf, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
mdUINT32		nrendbuf;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;

	//check buffering
	if ( (nrendbuf<1) || (nrendbuf>3) )
		return(0);

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = nrendbuf;
	dcx[0].dispw = dispw;
	dcx[0].disph = disph;
	dcx[0].rendx = rendx;
	dcx[0].rendy = rendy;
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = WR_ZLO;
	dcx[0].zcmpflags[1] = WR_ZLO;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
	dcx[0].buf[0].sdramaddr = sdramaddr;
	dcx[0].buf[1].sdramaddr = sdramaddr;
	if (nrendbuf > 2) {
		//Triple buffer mode
		dcx[0].buf[2].sdramaddr = sdramaddr;
		if ((dcx[0].dispw > 360) ||
				( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
			dcx[0].buf[0].dmaflags =
					((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B3A_WITHZ)|((dcx[0].dispw>>3)<<16));
			dcx[0].buf[1].dmaflags =
					((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B3B_WITHZ)|((dcx[0].dispw>>3)<<16));
			dcx[0].buf[2].dmaflags =
					((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B3C_WITHZ)|((dcx[0].dispw>>3)<<16));
		} else {
			dcx[0].buf[0].dmaflags =
					((HORIZONTAL|PIXEL|WRITE|TR_16B3A_WITHZ)|((dcx[0].dispw>>3)<<16));
			dcx[0].buf[1].dmaflags =
					((HORIZONTAL|PIXEL|WRITE|TR_16B3B_WITHZ)|((dcx[0].dispw>>3)<<16));
			dcx[0].buf[2].dmaflags =
					((HORIZONTAL|PIXEL|WRITE|TR_16B3C_WITHZ)|((dcx[0].dispw>>3)<<16));
		}; //if (cluster2bset)
	} else {
		if ((dcx[0].dispw > 360) ||
				( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
			dcx[0].buf[0].dmaflags =
					((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B2A_WITHZ)|((dcx[0].dispw>>3)<<16));
			dcx[0].buf[1].dmaflags =
					((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B2B_WITHZ)|((dcx[0].dispw>>3)<<16));
		} else {
			dcx[0].buf[0].dmaflags =
					((HORIZONTAL|PIXEL|WRITE|TR_16B2A_WITHZ)|((dcx[0].dispw>>3)<<16));
			dcx[0].buf[1].dmaflags =
					((HORIZONTAL|PIXEL|WRITE|TR_16B2B_WITHZ)|((dcx[0].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //if
	//calc size
	sdramaddr += ((nrendbuf+1)*dcx[0].dispw*dcx[0].disph*2);

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufGRB16B_NOZ_YCC16B(dcx, sdramstart, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = 1;
	dcx[0].dispw = rendw;
	dcx[0].disph = rendh;
	dcx[0].rendx = 0;							//No border in RGB mode
	dcx[0].rendy = 0;             //No border in RGB mode
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = 0;
	dcx[0].zcmpflags[1] = 0;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
	dcx[0].buf[0].sdramaddr = sdramaddr;

	if ((dcx[0].dispw > 360) ||
			( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B_NOZ)|((dcx[0].dispw>>3)<<16));
	} else {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_16B_NOZ)|((dcx[0].dispw>>3)<<16));
	}; //if (cluster2bset)

	sdramaddr += dcx[0].dispw*dcx[0].disph*2;

	//Switch Render buffer into GRB setups
	dcx[0].flags = mdGRBsb;				//Set GRB mode

	//Setup Display Buffer Structure
	dcx[1].actbuf = 0;
	dcx[1].numbuf = 2;						//#of display buffers
	dcx[1].dispw = dispw;
	dcx[1].disph = disph;
	dcx[1].rendw = rendw;
	dcx[1].rendh = rendh;
	dcx[1].rendx = rendx;
	dcx[1].rendy = rendy;
	dcx[1].flags = 0;							//Display is always YCrCb
	dcx[1].select = 0;						//Clear ZComparator Select
	dcx[1].zcmpflags[0] = 0;			//Display Buffer does not support ZComparator
	dcx[1].zcmpflags[1] = 0;      //Display Buffer does not support ZComparator
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[1].lastfield = _fieldcount;
	#else
		dcx[1].lastfield = _VidSync(0);
	#endif

	sdramlen = dcx[1].dispw*dcx[1].disph*2;		//size in bytes
	for (i=0; i<dcx[1].numbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[1].buf[i].sdramaddr = sdramaddr;
		if ((dcx[1].dispw > 360) ||
				( ((dcx[1].dispw & 0xF) == 0) && ((dcx[1].disph & 0xF) == 0) )) {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B_NOZ)|((dcx[1].dispw>>3)<<16));
		} else {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_16B_NOZ)|((dcx[1].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufGRB16B_NOZ_YCC32B(dcx, sdramstart, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = 1;
	dcx[0].dispw = rendw;
	dcx[0].disph = rendh;
	dcx[0].rendx = 0;							//No border in RGB mode
	dcx[0].rendy = 0;             //No border in RGB mode
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = 0;
	dcx[0].zcmpflags[1] = 0;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
	dcx[0].buf[0].sdramaddr = sdramaddr;
	if ((dcx[0].dispw > 360) ||
			( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B_NOZ)|((dcx[0].dispw>>3)<<16));
	} else {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_16B_NOZ)|((dcx[0].dispw>>3)<<16));
	}; //if (cluster2bset)
	sdramaddr += dcx[0].dispw*dcx[0].disph*2;

	//Switch Render buffer into GRB setups
	dcx[0].flags = mdGRBsb;				//Set GRB mode

	//Setup Display Buffer Structure
	dcx[1].actbuf = 0;
	dcx[1].numbuf = 2;						//#of display buffers
	dcx[1].dispw = dispw;
	dcx[1].disph = disph;
	dcx[1].rendw = rendw;
	dcx[1].rendh = rendh;
	dcx[1].rendx = rendx;
	dcx[1].rendy = rendy;
	dcx[1].flags = 0;							//Display is always YCrCb
	dcx[1].select = 0;						//Clear ZComparator Select
	dcx[1].zcmpflags[0] = 0;			//Display Buffer does not support ZComparator
	dcx[1].zcmpflags[1] = 0;      //Display Buffer does not support ZComparator
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[1].lastfield = _fieldcount;
	#else
		dcx[1].lastfield = _VidSync(0);
	#endif

	sdramlen = dcx[1].dispw*dcx[1].disph*4;		//size in bytes
	for (i=0; i<dcx[1].numbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[1].buf[i].sdramaddr = sdramaddr;
		if ((dcx[1].dispw > 360) ||
				( ((dcx[1].dispw & 0xF) == 0) && ((dcx[1].disph & 0xF) == 0) )) {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_32B_NOZ)|((dcx[1].dispw>>3)<<16));
		} else {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_32B_NOZ)|((dcx[1].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufGRB32B_NOZ_YCC32B(dcx, sdramstart, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = 1;
	dcx[0].dispw = rendw;
	dcx[0].disph = rendh;
	dcx[0].rendx = 0;							//No border in RGB mode
	dcx[0].rendy = 0;             //No border in RGB mode
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = 0;
	dcx[0].zcmpflags[1] = 0;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
	dcx[0].buf[0].sdramaddr = sdramaddr;
	if ((dcx[0].dispw > 360) ||
			( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_32B_NOZ)|((dcx[0].dispw>>3)<<16));
	} else {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_32B_NOZ)|((dcx[0].dispw>>3)<<16));
	}; //if (cluster2bset)
	sdramaddr += dcx[0].dispw*dcx[0].disph*4;

	//Switch Render buffer into GRB setups
	dcx[0].flags = mdGRBsb;				//Set GRB mode

	//Setup Display Buffer Structure
	dcx[1].actbuf = 0;
	dcx[1].numbuf = 2;						//#of display buffers
	dcx[1].dispw = dispw;
	dcx[1].disph = disph;
	dcx[1].rendw = rendw;
	dcx[1].rendh = rendh;
	dcx[1].rendx = rendx;
	dcx[1].rendy = rendy;
	dcx[1].flags = 0;							//Display is always YCrCb
	dcx[1].select = 0;						//Clear ZComparator Select
	dcx[1].zcmpflags[0] = 0;			//Display Buffer does not support ZComparator
	dcx[1].zcmpflags[1] = 0;      //Display Buffer does not support ZComparator
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[1].lastfield = _fieldcount;
	#else
		dcx[1].lastfield = _VidSync(0);
	#endif

	sdramlen = dcx[1].dispw*dcx[1].disph*4;		//size in bytes
	for (i=0; i<dcx[1].numbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[1].buf[i].sdramaddr = sdramaddr;
		if ((dcx[1].dispw > 360) ||
				( ((dcx[1].dispw & 0xF) == 0) && ((dcx[1].disph & 0xF) == 0) )) {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_32B_NOZ)|((dcx[1].dispw>>3)<<16));
		} else {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_32B_NOZ)|((dcx[1].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufGRB16B_WITHZ_YCC16B(dcx, sdramstart, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = 1;
	dcx[0].dispw = rendw;
	dcx[0].disph = rendh;
	dcx[0].rendx = 0;							//No border in RGB mode
	dcx[0].rendy = 0;             //No border in RGB mode
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = WR_ZLO;
	dcx[0].zcmpflags[1] = WR_ZLO;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
	dcx[0].buf[0].sdramaddr = sdramaddr;
	if ((dcx[0].dispw > 360) ||
			( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B_WITHZ)|((dcx[0].dispw>>3)<<16));
	} else {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_16B_WITHZ)|((dcx[0].dispw>>3)<<16));
	}; //if (cluster2bset)
	sdramaddr += dcx[0].dispw*dcx[0].disph*4;

	//Switch Render buffer into GRB setups
	dcx[0].flags = mdGRBsb;				//Set GRB mode

	//Setup Display Buffer Structure
	dcx[1].actbuf = 0;
	dcx[1].numbuf = 2;						//#of display buffers
	dcx[1].dispw = dispw;
	dcx[1].disph = disph;
	dcx[1].rendw = rendw;
	dcx[1].rendh = rendh;
	dcx[1].rendx = rendx;
	dcx[1].rendy = rendy;
	dcx[1].flags = 0;							//Display is always YCrCb
	dcx[1].select = 0;						//Clear ZComparator Select
	dcx[1].zcmpflags[0] = 0;			//Display Buffer does not support ZComparator
	dcx[1].zcmpflags[1] = 0;      //Display Buffer does not support ZComparator
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[1].lastfield = _fieldcount;
	#else
		dcx[1].lastfield = _VidSync(0);
	#endif

	sdramlen = dcx[1].dispw*dcx[1].disph*2;		//size in bytes
	for (i=0; i<dcx[1].numbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[1].buf[i].sdramaddr = sdramaddr;
		if ((dcx[1].dispw > 360) ||
				( ((dcx[1].dispw & 0xF) == 0) && ((dcx[1].disph & 0xF) == 0) )) {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B_NOZ)|((dcx[1].dispw>>3)<<16));
		} else {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_16B_NOZ)|((dcx[1].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufGRB16B_WITHZ_YCC32B(dcx, sdramstart, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = 1;
	dcx[0].dispw = rendw;
	dcx[0].disph = rendh;
	dcx[0].rendx = 0;							//No border in RGB mode
	dcx[0].rendy = 0;             //No border in RGB mode
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = WR_ZLO;
	dcx[0].zcmpflags[1] = WR_ZLO;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
	dcx[0].buf[0].sdramaddr = sdramaddr;
	if ((dcx[0].dispw > 360) ||
			( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_16B_WITHZ)|((dcx[0].dispw>>3)<<16));
	} else {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_16B_WITHZ)|((dcx[0].dispw>>3)<<16));
	}; //if (cluster2bset)
	sdramaddr += dcx[0].dispw*dcx[0].disph*4;

	//Switch Render buffer into GRB setups
	dcx[0].flags = mdGRBsb;				//Set GRB mode

	//Setup Display Buffer Structure
	dcx[1].actbuf = 0;
	dcx[1].numbuf = 2;						//#of display buffers
	dcx[1].dispw = dispw;
	dcx[1].disph = disph;
	dcx[1].rendw = rendw;
	dcx[1].rendh = rendh;
	dcx[1].rendx = rendx;
	dcx[1].rendy = rendy;
	dcx[1].flags = 0;							//Display is always YCrCb
	dcx[1].select = 0;						//Clear ZComparator Select
	dcx[1].zcmpflags[0] = 0;			//Display Buffer does not support ZComparator
	dcx[1].zcmpflags[1] = 0;      //Display Buffer does not support ZComparator
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[1].lastfield = _fieldcount;
	#else
		dcx[1].lastfield = _VidSync(0);
	#endif

	sdramlen = dcx[1].dispw*dcx[1].disph*4;		//size in bytes
	for (i=0; i<dcx[1].numbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[1].buf[i].sdramaddr = sdramaddr;
		if ((dcx[1].dispw > 360) ||
				( ((dcx[1].dispw & 0xF) == 0) && ((dcx[1].disph & 0xF) == 0) )) {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_32B_NOZ)|((dcx[1].dispw>>3)<<16));
		} else {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_32B_NOZ)|((dcx[1].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

mdUINT32 mdSetBufGRB32B_WITHZ_YCC32B(dcx, sdramstart, dispw, disph, rendx, rendy, rendw, rendh)
mdDRAWCONTEXT *dcx;
mdBYTE			*sdramstart;
md28DOT4		dispw, disph;
md28DOT4		rendx, rendy;
md28DOT4		rendw, rendh;
{
	mdUINT32		sdramaddr;
	mdUINT32		sdramlen;
	mdUINT32		i;

	//set
	sdramaddr = (mdUINT32)(sdramstart);

	//Setup Render buffer structure
	dcx[0].actbuf = 0;
	dcx[0].numbuf = 1;
	dcx[0].dispw = rendw;
	dcx[0].disph = rendh;
	dcx[0].rendx = 0;							//No border in RGB mode
	dcx[0].rendy = 0;             //No border in RGB mode
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;
	dcx[0].flags = 0;
	dcx[0].select = 0;
	dcx[0].zcmpflags[0] = WR_ZLO;
	dcx[0].zcmpflags[1] = WR_ZLO;
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[0].lastfield = _fieldcount;
	#else
		dcx[0].lastfield = _VidSync(0);
	#endif

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
	dcx[0].buf[0].sdramaddr = sdramaddr;
	if ((dcx[0].dispw > 360) ||
			( ((dcx[0].dispw & 0xF) == 0) && ((dcx[0].disph & 0xF) == 0) )) {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_32B_WITHZ)|((dcx[0].dispw>>3)<<16));
	} else {
		dcx[0].buf[0].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_32B_WITHZ)|((dcx[0].dispw>>3)<<16));
	}; //if (cluster2bset)
	sdramaddr += dcx[0].dispw*dcx[0].disph*8;

	//Switch Render buffer into GRB setups
	dcx[0].flags = mdGRBsb;				//Set GRB mode

	//Setup Display Buffer Structure
	dcx[1].actbuf = 0;
	dcx[1].numbuf = 2;						//#of display buffers
	dcx[1].dispw = dispw;
	dcx[1].disph = disph;
	dcx[1].rendw = rendw;
	dcx[1].rendh = rendh;
	dcx[1].rendx = rendx;
	dcx[1].rendy = rendy;
	dcx[1].flags = 0;							//Display is always YCrCb
	dcx[1].select = 0;						//Clear ZComparator Select
	dcx[1].zcmpflags[0] = 0;			//Display Buffer does not support ZComparator
	dcx[1].zcmpflags[1] = 0;      //Display Buffer does not support ZComparator
	//Set dummy lastfield
	#ifdef USE_FIELDCOUNT
		dcx[1].lastfield = _fieldcount;
	#else
		dcx[1].lastfield = _VidSync(0);
	#endif

	sdramlen = dcx[1].dispw*dcx[1].disph*4;		//size in bytes
	for (i=0; i<dcx[1].numbuf; i++, sdramaddr += sdramlen) {
		sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
		dcx[1].buf[i].sdramaddr = sdramaddr;
		if ((dcx[1].dispw > 360) ||
				( ((dcx[1].dispw & 0xF) == 0) && ((dcx[1].disph & 0xF) == 0) )) {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|CLUSTER|PIXEL|WRITE|TR_32B_NOZ)|((dcx[1].dispw>>3)<<16));
		} else {
			dcx[1].buf[i].dmaflags = ((HORIZONTAL|PIXEL|WRITE|TR_32B_NOZ)|((dcx[1].dispw>>3)<<16));
		}; //if (cluster2bset)
	}; //for i

	sdramaddr = (sdramaddr + 0x1FF) & (0xFFFFFE00);
 	return(sdramaddr-(mdUINT32)(sdramstart));
}

void mdClearDraw(dcx, clr)
mdDRAWCONTEXT *dcx;
mdCOLOR *clr;
{
 	mdTILE 			tile;
	mdUINT32		rendx, rendy;
	mdUINT32		rendw, rendh;
	int i;

 	//Clear Complete Render Memory and ZBuffer
	rendx = dcx[0].rendx;
	rendy = dcx[0].rendy;
	rendw = dcx[0].rendw;
	rendh = dcx[0].rendh;
	dcx[0].rendx = 0;
	dcx[0].rendy = 0;
	dcx[0].rendw = dcx[0].dispw;
	dcx[0].rendh = dcx[0].disph;

	//Set tile parameters
	mdSetScrRECT(&tile.sr,0,0,mdGetFarZ(),dcx[0].dispw<<4,dcx[0].disph<<4);

	for (i=0; i<dcx[0].numbuf; i++) {
		dcx[0].actbuf = i;
		mdActiveDrawContext(&dcx[0]);
		mdDrawTile(mpTILE_FZ, &tile.sr, clr);
	}; // for i
	dcx[0].actbuf = 0; 						//Restore Actual Buffer
	dcx[0].rendx = rendx;
	dcx[0].rendy = rendy;
	dcx[0].rendw = rendw;
	dcx[0].rendh = rendh;

	mdDrawSync();								//Wait for ClearScreen
}

void mdClearDisp(dcx, clr)
mdDRAWCONTEXT *dcx;
mdCOLOR *clr;
{
	mdTILE			tile;
	mdUINT32		rendx, rendy;
	mdUINT32		rendw, rendh;
	int i;

	//Clear Complete Display Memory (To Clear Border) if necessary (RGB mode)
	if ((dcx[0].flags & mdGRBsb) != 0) {
		rendx = dcx[1].rendx;
		rendy = dcx[1].rendy;
		rendw = dcx[1].rendw;
		rendh = dcx[1].rendh;
		dcx[1].rendx = 0;
		dcx[1].rendy = 0;
		dcx[1].rendw = dcx[1].dispw;
		dcx[1].rendh = dcx[1].disph;

		//Set tile parameters
		mdSetScrRECT(&tile.sr,0,0,mdGetFarZ(),dcx[1].dispw<<4,dcx[1].disph<<4);

		for (i=0; i<dcx[1].numbuf; i++) {
			dcx[1].actbuf = i;
			mdActiveDrawContext(&dcx[1]);
			mdDrawTile(mpTILE_F, &tile.sr, clr);
		}; // for i
		dcx[1].rendx = rendx;
		dcx[1].rendy = rendy;
		dcx[1].rendw = rendw;
		dcx[1].rendh = rendh;
		dcx[1].actbuf = 0;					//Restore Actual Buffer
	};

	mdDrawSync();								//Wait for ClearScreen
}

mdUINT32 SwapDrawBufGRB(dcx)
mdDRAWCONTEXT *dcx;
{
	mdUINT32 frames;
	mdUINT32 curfield;					//curfield help variable

	mdDrawSync();								//Wait for MPR activity to finish
	_VidSync(0);								//Wait for Previous frame to finish
	mdDrawConv(&dcx[1]);				//Convert GRB to YCC
	mdDrawSync();								//Wait for Screen Conversion


	// Setup New Video Base
	_VidChangeBase(VID_CHANNEL_MAIN,dcx[1].buf[dcx[1].actbuf].dmaflags,(mdBYTE *)(dcx[1].buf[dcx[1].actbuf].sdramaddr));

	// Swap Screen Buffer
	dcx[1].actbuf++;
	if (dcx[1].actbuf == dcx[1].numbuf)
		dcx[1].actbuf = 0;

	#ifdef USE_FIELDCOUNT
		curfield = _fieldcount;
	#else
		curfield = _VidSync(-1);
	#endif
	frames = curfield - dcx[1].lastfield;
	dcx[1].lastfield = curfield;

	return(frames);
}

mdUINT32 SwapDrawBufYCC(dcx)
mdDRAWCONTEXT *dcx;
{
	mdUINT32 frames;
	mdUINT32 curfield;				//curfield help variable

	// Wait VSync depending on double/triple buffer
	switch (dcx[0].numbuf) {
		case 2:
			// Setup New Video Base
			_VidChangeBase(VID_CHANNEL_MAIN,dcx[0].buf[dcx[0].actbuf].dmaflags,(mdBYTE*)(dcx[0].buf[dcx[0].actbuf].sdramaddr));
			// Wait till Active
			_VidSync(0);
			break;
		case 3:
			//If we are done within 1 field of lastfield, Wait till end of field
			_VidSync(0);
			// Setup New Video Base
			_VidChangeBase(VID_CHANNEL_MAIN,dcx[0].buf[dcx[0].actbuf].dmaflags,(mdBYTE*)(dcx[0].buf[dcx[0].actbuf].sdramaddr));
			break;
	}; //Switch

	// Swap Screen Buffer
	dcx[0].actbuf++;
	if (dcx[0].actbuf == dcx[0].numbuf)
		dcx[0].actbuf = 0;

	//Calculate frames elapsed
	#ifdef USE_FIELDCOUNT
		curfield = _fieldcount;
	#else
		curfield = _VidSync(-1);
	#endif
	frames = curfield - dcx[0].lastfield;
	dcx[0].lastfield = curfield;

	return(frames);
}


