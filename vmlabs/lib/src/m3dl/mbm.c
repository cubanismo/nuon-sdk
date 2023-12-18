/*
 * Title	 			MBM.C
 * Desciption		Merlin 3D Library Texture Functions
 * Version			1.0
 * Start Date		09/16/1998
 * Last Update	02/25/2000
 * By						Phil
 * Of						Miracle Designs
 * History:
 *  12/14/1998 Bug Fix Bilinear DMA
 *  02/25/2000 Bilinear DMA Removed
 *             loadaddress removed (always cleared at startup)
 * Known bugs:
*/

#include <m3dl/m3dl.h>
#include <m3dl/mbm.h>
#include <nuon/cache.h>

mdUINT32 mdGetMBMInfo(mbmfile, numtexs, numbms)
mdBYTE		*mbmfile;					 	//Ptr to MBM file
mdUINT32	*numtexs;						//Ptr to #of Textures in MBM
mdUINT32	*numbms;						//Ptr to #of Bitmaps in MBM
{
	mbmFILEDESC		*fd;
	mdUINT32*			mbm;

	mbm = (mdUINT32*)(mbmfile);
	if ((*mbm) == 0x4D424D10) {
		fd = (mbmFILEDESC*)(mbm+((sizeof(mbmHEADER))>>2));	 	//Ptr FileDesc
		*numtexs = fd->numtextures;
		*numbms = fd->numbitmaps;
		return 1;
	} else {
		*numtexs = 0;
		*numbms = 0;
		return 0;
	}; //if
}; //mdGetMBMInfo()

mdUINT32	mdTextureFromMBM(mbmfile, dest, tex, bm)
mdBYTE			*mbmfile;						//Ptr to MBM file
mdBYTE			*dest; 							//Destination address
mdTEXTURE		*tex;								//Ptr to texture array
mdBITMAP		*bm;								//Ptr to bitmap array
{
	mdUINT32	*mbm;
	mdUINT32	*fp;								//File Position
	mbmFILEDESC	*fd;
	mbmBITMAPNFO *bmnfo;
	mbmCLUTNFO *clnfo;
	mbmTEXTURE	*mt;
	mbmTEXTUREOFFSET *mtofs;
	mdUINT32	i,j;
	mdUINT32	texpos, bmpos;
	mdUINT32	bmsize, clsize, stripsize;
	mdUINT32	width,height;
	mdUINT32	dst;								//dst

	mbm = (mdUINT32*)(mbmfile);
	//Loop Textures
	if ((*mbm) == 0x4D424D10) {
		//Set dst
		dst = (mdUINT32)(dest);
		//Extract #s
		fd = (mbmFILEDESC*)(mbm+((sizeof(mbmHEADER))>>2));	 	//Ptr mbmFILEDESC
		fp = (mdUINT32 *)(fd+1);				//Ptr file

		for (i=0; i<fd->numtextures; i++) {
			mt = (mbmTEXTURE *)(fp);                       //Ptr mbmTEXTURE
			fp += ((sizeof(mbmTEXTURE))>>2);								//Increase fp
			width = mt->width;
			height = mt->height;
			for (j=0; j<mt->miplevels; j++) {
				mtofs = (mbmTEXTUREOFFSET *)(fp);
				bmnfo = (mbmBITMAPNFO*)(mbm + (mtofs->bitmapoffset>>2));
				bmnfo->loadaddress = 0;				//Clear loadaddress
				bmnfo->pixtype = mt->pixtype;
				bmnfo->width = width;
				bmnfo->height = height;
				width = width>>1;
				height = height>>1;
				fp += ((sizeof(mbmTEXTUREOFFSET))>>2);	 			//Increase fp
			}; //for j
		}; //for i

		//Align fp
		fp = (mdUINT32*)(((mdUINT32)fp+7)&0xFFFFFFF8);

		for (i=0; i<fd->numbitmaps; i++) {
			bmnfo = (mbmBITMAPNFO*)(fp);
			fp += ((sizeof(mbmBITMAPNFO))>>2); 				 			//Increase fp

			bmsize = ((bmnfo->width*bmnfo->height)<<4);
			stripsize = (32>>2);														//Minimum 8Bit
			switch (bmnfo->pixtype & 7) {
				case PIX_4B:
					bmsize = (bmsize>>1);
					stripsize = stripsize<<1;
					break;
				case PIX_16B:
					bmsize = (bmsize<<1);
					stripsize = stripsize>>1;
					break;
			}; /*switch*/

			if (dst != 0) {
				if ((bmnfo->loadaddress & 0xDFFFFFFF) == mdNULL) {
					if (1) {
	/*
	 BILINEAR DMA REMOVED ON 02-25-2000
					if ((dst & 0x80000000) || (bmnfo->width < stripsize) || (bmsize < 256)) {
	 */
						//align on 8byte boundary
						dst = ((dst + 0x7) & 0xFFFFFFF8);
						bmnfo->loadaddress = dst | (LD_LINEAR);
					} else {
						//align on 512byte boundary
						dst = ((dst + 0x1FF) & 0xFFFFFE00);
						bmnfo->loadaddress = dst;
					}; //if
					dst += bmsize;
				}; //if
				//Copy bitmap
				_mdCopyBitmap((mdBYTE*)(fp), (mdBYTE*)(bmnfo->loadaddress & 0xDFFFFFFF),
								(bmnfo->pixtype&7),bmnfo->width<<2, bmnfo->height<<2);
			} else {
				bmnfo->loadaddress = ((mdUINT32)fp) | (LD_LINEAR);
			}; //if
			fp += (bmsize>>2); 										 			//Increase fp
		}; //for i


		for (i=0; i<fd->numcluts; i++) {
			clnfo = (mbmCLUTNFO*)(fp);
			fp += ((sizeof(mbmCLUTNFO))>>2); 			 			//Increase fp

			clsize = (((clnfo->numcolors+3) & 0x1FC)<<1);

			if (dst != 0) {
				if ((clnfo->loadaddress & 0xDFFFFFF8) == mdNULL) {
					dst = ((dst + 0x7) & 0xFFFFFFF8);
					clnfo->loadaddress = dst | (LD_LINEAR);
					dst += clsize;
				}; //if
				_mdCopyBitmap((mdBYTE *)(fp), (mdBYTE *)(clnfo->loadaddress & 0xDFFFFFF8),
											 PIX_8B, 4, (clsize>>2));
			} else {
				clnfo->loadaddress = ((mdUINT32)fp) | (LD_LINEAR);
			}; //if
			fp += (clsize>>2); 										 			//Increase fp
		}; //for i

		//Reset positions
		texpos = 0;
		bmpos = 0;

		//Reset filepointer
		fp = (mdUINT32 *)(fd+1);				//Ptr file

		for (i=0; i<fd->numtextures; i++, texpos++) {
			mt = (mbmTEXTURE *)(fp);                           //Ptr mbmTEXTURE
			tex[texpos].pixtype = mt->pixtype;
			tex[texpos].miplevels = mt->miplevels;
			tex[texpos].width = mt->width;
			tex[texpos].height = mt->height;
			fp += ((sizeof(mbmTEXTURE))>>2);								//Increase fp
			tex[texpos].bmnfo = &bm[bmpos];
			for (j=0; j<tex[texpos].miplevels; j++, bmpos++) {
				mtofs = (mbmTEXTUREOFFSET *)(fp);
				bmnfo = (mbmBITMAPNFO*)(mbm + (mtofs->bitmapoffset>>2));
				bm[bmpos].bitmap = bmnfo->loadaddress;
				if (mtofs->clutoffset != mdNULL) {
					clnfo = (mbmCLUTNFO*)(mbm + (mtofs->clutoffset>>2));
					bm[bmpos].clut = clnfo->loadaddress | ((clnfo->numcolors>>2)&0x7)
														 | (((clnfo->numcolors>>2)&0x78)<<22);
				} else {
					bm[bmpos].clut = mdNULL;
				}; //if
				fp += ((sizeof(mbmTEXTUREOFFSET))>>2);	 			//Increase fp
			}; //for j
		}; //for i
		_DCacheSync();										//Synchronize Cache
		return dst-(mdUINT32)(dest); 		//Successful
	} else {
		return 0; 									//Error
	}; //if
}; //mdTextureFromMBM()


