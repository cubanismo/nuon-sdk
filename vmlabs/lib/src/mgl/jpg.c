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
#include <jpeg/jpeglib.h>

extern void jpeg_mem_src(j_decompress_ptr cinfo, JOCTET * indata, size_t insize);

GLTexture *mglInitJPEGTexture(JOCTET *jpeg_start, GLuint jpeg_size, GLuint pixelType,
	GLint scale, GLuint sdramFlag)
{
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;
    int i, n;
	int row_stride;
    JOCTET *s;
    JSAMPARRAY buffer;
    int x, y;
    unsigned int *lp;
    GLTexture *tp = NULL;

#ifdef DEBUG
	if (!jpeg_start) {
		printf("mglInitJPEGTexture: Error, null JPEG pointer.\n");
		return NULL;
	}
#endif

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);

    jpeg_mem_src(&cinfo, jpeg_start, jpeg_size);
    jpeg_read_header(&cinfo, GL_TRUE);

	switch (pixelType) {
	case e888Alpha:
	case e655:
	    cinfo.out_color_space = JCS_YCbCr;
	    break;
	case eGRB655:
		cinfo.out_color_space = JCS_RGB;
		break;
	default:
#ifdef DEBUG
		printf("mglInitJPEGTexture: Invalid output pixel format.\n");
#endif
		return NULL;
	}
    cinfo.scale_num = 1;
    cinfo.scale_denom = scale;

    jpeg_start_decompress(&cinfo);
    row_stride = cinfo.output_components * cinfo.output_width;
    buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, cinfo.rec_outbuf_height);

	// Allocate texture
	tp = mglNewTexture(cinfo.output_width, cinfo.output_height, pixelType, sdramFlag);
	if (tp == NULL) return NULL;

	lp = tp->pbuffer;
    y = 0;
    while (cinfo.output_scanline < cinfo.output_height) {
		n = jpeg_read_scanlines(&cinfo, buffer, cinfo.rec_outbuf_height);
		for (i = 0; i < n; i++) {
		unsigned long color;

		    s = buffer[i];
			switch(pixelType) {
			case e888Alpha:
				for (x = 0; x < cinfo.output_width; x++) {
					color = COLOR_8888Alpha(s[0], s[2], s[1], 0);
				    *lp++ = color;
		    		s += 3;
				}
				break;

			case e655:
				// we must output 2 pixels at a time
				for (x = 0; x < cinfo.output_width; x+=2) {
					color = (COLOR_655(s[0], s[2], s[1]) << 16) | COLOR_655(s[3], s[5], s[4]);
			    	s += 6;
			    	*lp++ = color;
				}
				break;

			case eGRB655:
				// we must output 2 pixels at a time
				for (x = 0; x < cinfo.output_width; x+=2) {
					color = (COLOR_GRB655(s[0], s[1], s[2]) << 16) | COLOR_GRB655(s[3], s[4], s[5]);
				    s += 6;
			    	*lp++ = color;
				}
				break;

				default:
					break;
	    	}
	    	y++;
    	}
    }

	// Free resources, insure data is written from cache and return texture pointer
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);

    return tp;
}
