/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

/* sample code for jpeg decompression */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <jpeg/jpeglib.h>
#include <nuon/dma.h>
#include "m3d.h"

extern void jpeg_mem_src(j_decompress_ptr cinfo, JOCTET * indata, size_t insize);

/*
 * initialize a display pixmap from a JPEG file
 * returns: 0 on success, nonzero on failure
 *
 * Parameters:
 * buf == points to the display pixmap structure to be initialized
 * sr == system resources structure
 * jpeg_start == pointer to the start of the JPEG image
 * jpeg_size  == size of the JPEG image
 * pix == pixel format for the pixmap (e888Alpha or e655)
 * scale == scale factor to choose; 1 for 1:1 scaling, 2 for 1:2, 4 for 1:4
 *          (so to convert a 640x480 JPEG to 320x240, use scale=2)
 */
#define APP_PIXMAP 0 /* if nonzero, pixmap will be an application pixmap */

static mmlStatus
mmlInitJpegPixmapScaled(mmlDisplayPixmap *buf, mmlSysResources *sr, JOCTET *jpeg_start,
		   int jpeg_size, mmlPixFormat pix, int scale)
{
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;
    int i, n;
    int row_stride;
    int wide;
    int status;
    JOCTET *s;
    JSAMPARRAY buffer;
    int x, y;
#if APP_PIXMAP
    long *bufMemPtr;
#endif

    assert( pix == e888Alpha || pix == e655 );

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);

    jpeg_mem_src(&cinfo, jpeg_start, jpeg_size);
    jpeg_read_header(&cinfo, TRUE);

    cinfo.out_color_space = JCS_YCbCr;
    cinfo.scale_num = 1;
    cinfo.scale_denom = scale;

    jpeg_start_decompress(&cinfo);
    row_stride = cinfo.output_components * cinfo.output_width;
    buffer = (*cinfo.mem->alloc_sarray)
	((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, cinfo.rec_outbuf_height);

#if !APP_PIXMAP
    /* make the pixmap a multiple of 8 wide */
    wide = (cinfo.output_width + 7) & ~7;
    status = mmlInitDisplayPixmaps(buf, sr, wide, cinfo.output_height, pix, 1, NULL);
#else
    wide = cinfo.output_width;
    status = mmlInitAppPixmaps(buf, sr, wide, cinfo.output_height, pix, 1, NULL);
#endif
    if (status != eOK) {
	fprintf(stderr, "status == %x\n", status);
	goto abort;
    }

    /* recalculate the row stride in long words */
    if (pix == e888Alpha) {
	row_stride = wide;  /* 32 bit pixels */
    } else {
	row_stride = wide/2; /* 16 bit pixels */
    }

    y = 0;
    while (cinfo.output_scanline < cinfo.output_height) {
	n = jpeg_read_scanlines(&cinfo, buffer, cinfo.rec_outbuf_height);

	for (i = 0; i < n; i++) {
	    long color;

	    s = buffer[i];
#if APP_PIXMAP
	    bufMemPtr = ((long *)buf->memP) + y*row_stride;
#endif
	    if (pix == e888Alpha) {
		for (x = 0; x < cinfo.output_width; x++) {
		    color = (s[0] << 24) | (s[2]<<16) | (s[1] << 8);
#if APP_PIXMAP
		    *bufMemPtr++ = color;
#else
		    _raw_plotpixel(buf->dmaFlags, buf->memP, (1<<16)|x, (1<<16)|y, color);
#endif
		    s += 3;
		}
	    } else if (pix == e655) {
		/* we must output 2 pixels at a time */
		for (x = 0; x < cinfo.output_width; x+=2) {
		    color = ((s[0] & 0xfc) << (10-2)) | ((s[2] & 0xf8) << (5-3)) |
			    ((s[1] & 0xf8) >> 3);
		    s += 3;
		    color = color << 16;
		    color |= ((s[0] & 0xfc) << (10-2)) | ((s[2] & 0xf8) << (5-3)) |
			    ((s[1] & 0xf8) >> 3);
		    s += 3;
#if APP_PIXMAP
		    *bufMemPtr++ = color;
#else
		    _raw_plotpixel(buf->dmaFlags, buf->memP, (2<<16)|x, (1<<16)|y, color);
#endif
		}
	    }
	    y++;
	}
    }

abort:
    /* free resources */
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);

    return status;
}


void
m3dInitMaterialFromJPEG(m3dMaterial *mat, mmlSysResources *sr, void *jpegStart, int jpegSize,
		   mmlPixFormat pix)
{
    mmlDisplayPixmap jp;

    if (mmlInitJpegPixmapScaled(&jp, sr, jpegStart, jpegSize, pix, 1) != eOK) {
	abort();
    }

    mat->dmaflags = DMA_PIXEL_READ | jp.dmaFlags;
    mat->dataptr = jp.memP;
    mat->width = jp.wide;
    mat->height = jp.high;
    mat->matflags = 0;
}

/*
 * create a mip-map from a JPEG
 * A mip-map is actually an array of
 * textures, laid out with the
 * smallest texture first and then
 * increasing in size.
 */


void
m3dInitMipMapFromJPEG(m3dMaterial *mat, int maxLevel, mmlSysResources *sr,
		      void *jpegStart, int jpegSize, mmlPixFormat pix)
{
    int scale;
    mmlDisplayPixmap jp;

    if (maxLevel > 5)
	maxLevel = 5;

    /* step through the levels, creating
       scaled images from the JPEG. We start with
       the smallest level, which means dividing
       by 2**maxLevel initially */

    while (--maxLevel >= 0) {
	scale = 1<<maxLevel;
	if (mmlInitJpegPixmapScaled(&jp, sr, jpegStart, jpegSize, pix, scale) != eOK) {
	    abort();
	}
	mat->dmaflags = DMA_PIXEL_READ | jp.dmaFlags;
	mat->dataptr = jp.memP;
	mat->width = jp.wide;
	mat->height = jp.high;
	mat->matflags = (maxLevel << M3D_MIPMAPLEVEL_BITS);

	/* step to the next level */
	mat++;
    }
}
