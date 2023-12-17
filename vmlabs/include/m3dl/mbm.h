/*
 * Title	 			MBM.H
 * Desciption		Miracle 3D Library MBM File Structures
 * Version			1.0
 * Start Date		10/27/1998
 * Last Update	10/27/1998
 * By						Phil
 * Of						Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

#ifndef __MBMinc_
#define __MBMinc_

#include <m3dl/mdtypes.h>

#define LD_LINEAR	(1<<29)

typedef struct _mbmHEADER {
	mdUINT32	header;
} mbmHEADER;

typedef struct _mbmFILEDESC {
	mdUINT16	numtextures;
	mdUINT16	numbitmaps;
	mdUINT16	numcluts;
	mdUINT16	reserved;
} mbmFILEDESC;

typedef struct _mbmBITMAPNFO {
	mdUINT8		pixtype;
	mdUINT8		width;
	mdUINT8		height;
	mdUINT8		pad;
	mdUINT32	loadaddress;
} mbmBITMAPNFO;

typedef struct _mbmCLUTNFO {
	mdUINT32	numcolors;
	mdUINT32	loadaddress;
} mbmCLUTNFO;

typedef struct _mbmTEXTURE {
	mdUINT8		pixtype;
	mdUINT8		miplevels;
	mdUINT8		width;
	mdUINT8		height;
} mbmTEXTURE;

typedef struct _mbmTEXTUREOFFSET {
	mdUINT32	bitmapoffset;
	mdUINT32	clutoffset;
} mbmTEXTUREOFFSET;

#endif
