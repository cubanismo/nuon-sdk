/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/


#include "gl.h"
#include "glutils.h"
#include "debug.h"

typedef struct BITMAPFILEHEADER
{
   unsigned short 	type;
   unsigned long    size;
   short     		xHotspot;
   short     		yHotspot;
   unsigned long    offsetToBits;
}  BITMAPFILEHEADER;

typedef struct BITMAPHEADER
{
    unsigned long size;
    long  width;
    long  height;
    unsigned short numBitPlanes;
    unsigned short numBitsPerPlane;
    unsigned long compressionScheme;
    unsigned long sizeOfImageData;
    unsigned long xResolution;
    unsigned long yResolution;
    unsigned long numColorsUsed;
    unsigned long numImportantColors;
    unsigned short resolutionUnits;
    unsigned short padding;
    unsigned short origin;
    unsigned short halftoning;
    unsigned long halftoningParam1;
    unsigned long halftoningParam2;
    unsigned long colorEncoding;
    unsigned long identifier;
} BITMAPHEADER;

// BITMAPHEADER types
#define TYPE_BMP 		0x4D42
#define TYPE_ICO 		0x4349
#define TYPE_ICO_COLOR 	0x4943
#define TYPE_PTR 		0x5450
#define TYPE_PTR_COLOR 	0x5043
#define TYPE_ARRAY      0x4142

// Compression types
#define COMPRESSION_NONE 		0
#define COMPRESSION_RLE_8     	1
#define COMPRESSION_RLE_4       2
#define COMPRESSION_HUFFMAN1D  	3
#define COMPRESSION_BITFIELDS   3
#define COMPRESSION_RLE_24      4
#define COMPRESSION_LAST        4

// Halftoning algorithms
#define HALFTONING_NONE             0
#define HALFTONING_ERROR_DIFFUSION  1
#define HALFTONING_PANDA            2
#define HALFTONING_SUPER_CIRCLE		3

// Origin types
#define ORIGIN_LOWER_LEFT  (0)
#define ORIGIN_LAST        (0)

// Color table encoding
#define COLOR_ENCODING_RGB   (0)
#define COLOR_ENCODING_LAST  (0)

// Converts little-endian 16 bit unsigned integer to big-endian
static unsigned short USHORTLittle(void *vp)
{
	unsigned short v1 = (unsigned short)(*(unsigned char *)vp++);
	unsigned short v2 = (unsigned short)(*(unsigned char *)vp++);
	return 	v1 | (v2 << 8);
}

// Converts little-endian 32 bit unsigned integer to big-endian
static unsigned long ULONGLittle(void *vp)
{
	unsigned long v1 = (unsigned long)(*(unsigned char *)vp++);
	unsigned long v2 = (unsigned long)(*(unsigned char *)vp++);
	unsigned long v3 = (unsigned long)(*(unsigned char *)vp++);
	unsigned long v4 = (unsigned long)(*(unsigned char *)vp++);
	return v1 | (v2 << 8) | (v3 << 16) | (v4 << 24);
}

GLTexture *mglInitBMPTexture(void *bp, GLuint convertToYCrCb, GLuint sdramFlag)
{
	GLTexture *tp = NULL;
	unsigned char *pp;
	BITMAPFILEHEADER fileHeader = {0, 0, 0, 0, 0};
	BITMAPHEADER header = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
	unsigned int r, g, b;
	short fileType;
	unsigned long lineWidth = 0;
	long depth = 0;
	long oldFormat = 0;
	long bytesRead = 0;
	long inverted = 0;
	unsigned short tempVal;
	int i, j;
	void *oldbp = bp;
	unsigned int pixelType = 0;

#ifdef DEBUG
	if (!bp) {
		printf("mglInitBMPTexture: Error, null BMP pointer.\n");
		return NULL;
	}
#endif

	// First obtain bitmap file type
	fileType =  USHORTLittle(bp);

	// Handle bitmap according to file type
	switch (fileType) {
    case TYPE_ARRAY:
	   printf("mglInitBMPTexture: Multiple bitmaps not yet support.\n");
	   return NULL;
       break;

    case TYPE_BMP:
    case TYPE_ICO:
    case TYPE_ICO_COLOR:
    case TYPE_PTR:
    case TYPE_PTR_COLOR:
		// Read bitmap file header
   		fileHeader.type = USHORTLittle(bp);
	    bp += 2;
       	fileHeader.size = ULONGLittle(bp);
	    bp += 4;
        fileHeader.xHotspot = USHORTLittle(bp);
   		bp += 2;
    	fileHeader.yHotspot = USHORTLittle(bp);
	    bp += 2;
    	fileHeader.offsetToBits = ULONGLittle(bp);
		bp += 4;

		// Read bitmap header
		header.size = ULONGLittle(bp);
 	   	bp += 4;
    	bytesRead = 4;

    	/*
    	 * If the size is 12 bytes or less, than this is an "old format"
    	 * structure.  So the width and height fields will have to be read
    	 * differently.
    	 */
    	if (header.size <= 12)
			oldFormat = 1;
    	else
			oldFormat = 0;

 	    /*
     	 * Width and height are read differently for old and new format files.  In
    	 * the old format, they're 16-bit values.  In the new format, they're
    	 * 32-bits long.
    	 */
    	if (oldFormat) {
			tempVal = USHORTLittle(bp);
			header.width = tempVal;
			bp += 2;
			bytesRead += 2;
    	}
    	else {
			header.width = ULONGLittle(bp);
			bp += 4;
			bytesRead += 4;
    	}
    	if (bytesRead >= header.size)
    		return NULL;

    	if (oldFormat) {
			tempVal = USHORTLittle(bp);
			header.height = tempVal;
			bp += 2;
			bytesRead += 2;
    	}
    	else {
			header.height = ULONGLittle(bp);
			bp += 4;
			bytesRead += 4;
    	}
    	if (bytesRead >= header.size)
    		return NULL;

    	/*
    	 * From this point on, old and new formats are identical to each other,
   		 * and we can proceed as if there was no difference.  For each field, we
    	 * read it in and increment the count of bytes read.  If at any time we
    	 * have read the amount we got earlier (in the size field), then stop and
    	 * leave the rest of the fields as zeros.
    	 */
    	header.numBitPlanes = USHORTLittle(bp);
    	bytesRead += 2;
    	bp += 2;
    	if (bytesRead >= header.size)
			return NULL;

    	header.numBitsPerPlane = USHORTLittle(bp);
    	bytesRead += 2;
		bp += 2;
		depth = header.numBitPlanes * header.numBitsPerPlane;

    	if (header.size > 12) {

    		/*
    		 * Old format stop here.  But we don't have to check, because in that
    		 * format, 12 bytes have been read and the function will have exited
    		 * without any extra checking.
     		*/
     		if (bytesRead < header.size) {
	    		header.compressionScheme = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
    		}

    		if (bytesRead < header.size) {
			    header.sizeOfImageData = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
			}

    		if (bytesRead < header.size) {
	    		header.xResolution = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
    		}

			if (bytesRead < header.size) {
			    header.yResolution = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
			}

  			if (bytesRead < header.size) {
	    		header.numColorsUsed = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
    		}

    		if (bytesRead < header.size) {
	    		header.numImportantColors = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
			}

			if (bytesRead < header.size) {
			    header.resolutionUnits = USHORTLittle(bp);
    			bytesRead += 2;
    			bp += 2;
    		}

    		if (bytesRead < header.size) {
	 		    header.padding = USHORTLittle(bp);
    			bytesRead += 2;
				bp += 2;
			}

 			if (bytesRead < header.size) {
			    header.origin = USHORTLittle(bp);
    			bytesRead += 2;
				bp += 2;
			}

	    	if (bytesRead < header.size) {
			    header.halftoning = USHORTLittle(bp);
    			bytesRead += 2;
				bp += 2;
			}

    		if (bytesRead < header.size) {
			    header.halftoningParam1 = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
			}

			if (bytesRead < header.size) {
	    		header.halftoningParam2 = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
			}

			if (bytesRead < header.size) {
	    		header.colorEncoding = ULONGLittle(bp);
			    bytesRead += 4;
				bp += 4;
			}

			if (bytesRead < header.size) {
			    header.identifier = ULONGLittle(bp);
    			bytesRead += 4;
				bp += 4;
			}

    		/*
    		 * If there are more bytes in the file than this, then the file is using a
    		 * future format that doesn't exist yet.  Skip over the bytes.  Assuming
    		 * this future format somewhat resembles what we know now, ignoring the
    		 * fields will be safe.  We _MUST_ skip them, though, since the color
    		 * table begins on the byte after this structure, and we have to position
    		 * the file pointer there.
    		 */
    		bp += (header.size - bytesRead);

		}

		// Perform sanity checks
		depth = header.numBitPlanes * header.numBitsPerPlane;
		if ((depth > 32) ||
			(header.compressionScheme > COMPRESSION_LAST) ||
			(header.origin > ORIGIN_LAST) ||
			(header.colorEncoding > COLOR_ENCODING_LAST) ||
			(header.width < 1) ||
			(header.height == 0) ||
			(header.numBitPlanes > 1) ||
			((header.numBitsPerPlane != 4) &&
		 	(header.numBitsPerPlane != 8) &&
		 	(header.numBitsPerPlane != 24)) ||
			(header.compressionScheme != COMPRESSION_NONE)) {
			printf("mglInitBMPTexture: Invalid or unsupported bitmap format.\n");
			return NULL;
		}

		// Check for inversion
		if (header.height < 0) {
			inverted = 0;
			header.height = -header.height;
    		}
    		else
			inverted = 1;

		// Determine pixel type
		switch(depth) {
			case 4:
				pixelType = convertToYCrCb ? eClut4 : eClut4GRB888Alpha;
				lineWidth = header.width >> 1;
				break;
			case 8:
				pixelType = convertToYCrCb ? eClut8 : eClut8GRB888Alpha;
				lineWidth = header.width;
				break;
			case 24:
				pixelType = convertToYCrCb ? e655 : eGRB655;
				lineWidth = header.width << 1;
				break;
			default:
				printf("mglInitBMPTexture: Invalid or unsupported bitmap format.\n");
				return NULL;
		}

		// Allocate texture

		tp = mglNewTexture(header.width, header.height, pixelType, sdramFlag);
		if (tp == NULL) return NULL;

    	// Read color table
		switch (pixelType)
		{
			case eClut4:
			case eClut8:
				pp = (unsigned char *)(tp->clut);
				for (i = 0; i < tp->clutSize; i++) {
					b = *(unsigned char *)bp++;
					g = *(unsigned char *)bp++;
					r = *(unsigned char *)bp++;
					if (header.size > 12) bp++;
					*((unsigned long *)pp) = mglColorFromRGB(r, g, b) | 0xff;
					pp += 4;
				}
				break;
			case eClut4GRB888Alpha:
			case eClut8GRB888Alpha:
				pp = (unsigned char *)(tp->clut);
				for (i = 0; i < tp->clutSize; i++) {
					b = *(unsigned char *)bp++;
					g = *(unsigned char *)bp++;
					r = *(unsigned char *)bp++;
					if (header.size > 12) bp++;
					*((unsigned long *)pp) = COLOR_GRB888Alpha(r, g, b, 0xff);
					pp += 4;
				}
				break;
			case e655:
			case eGRB655:
			default:
				break;
		}

		// Read pixmap

		bp = oldbp + fileHeader.offsetToBits;
		pp = (unsigned char *)(tp->pbuffer);
		if (inverted) pp += (header.height - 1) * lineWidth;

		switch (pixelType)
		{
			case eClut4:
			case eClut8:
			case eClut4GRB888Alpha:
			case eClut8GRB888Alpha:
				for (i = 0; i < header.height; i++) {
					for (j = 0; j < lineWidth; j++) {
						*pp++ = *(unsigned char *)bp++;
					}
					if (inverted) pp -= 2 * lineWidth;
       				}
				break;
			case e655:
				for (i = 0; i < header.height; i++) {
					for (j = 0; j < header.width; j++) {
						b = *(unsigned char *)bp++;
						g = *(unsigned char *)bp++;
						r = *(unsigned char *)bp++;
						*(unsigned short *)pp = (unsigned short)(mglColor16FromRGB(r, g, b) >> 16);
						pp += 2;
					}
					if (inverted) pp -= 2 * lineWidth;
	       			}
			case eGRB655:
				for (i = 0; i < header.height; i++) {
					for (j = 0; j < header.width; j++) {
						b = *(unsigned char *)bp++;
						g = *(unsigned char *)bp++;
						r = *(unsigned char *)bp++;
						*(unsigned short *)pp = COLOR_GRB655(r, g, b);
						pp += 2;
					}
					if (inverted) pp -= 2 * lineWidth;
	       			}
				break;
			default:
				// shouldn't happen
				DEBUG_ASSERT(0);
				break;
		}

		break;

    default:
    	printf("mglInitBMPTexture: Invalid bitmap type.\n");
		mglDeleteTexture(tp);
    	return NULL;
	}

	return tp;
}
