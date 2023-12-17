/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

// routines here written by Mike Fulton

#include "jpeg.h"
#include "ir_remote.h"

void show_jpeg(mmlDisplayPixmap *scrn, void *jpegdata, int jpeg_size)
{
struct jpeg_decompress_struct cinfo;
struct jpeg_error_mgr jerr;
JOCTET *s, *jpeg_start;
JSAMPARRAY buffer;
int i, n, row_stride;
int x, y;
int scale = 1;
extern volatile int AutoPlay;

    jpeg_start = (JOCTET *)jpegdata;

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);

    jpeg_mem_src(&cinfo, jpeg_start, jpeg_size);
    jpeg_read_header(&cinfo, TRUE);

    cinfo.out_color_space = JCS_YCbCr;
    cinfo.scale_num = 1;
    cinfo.scale_denom = scale;

    jpeg_start_decompress(&cinfo);
    row_stride = cinfo.output_components * cinfo.output_width;
    buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, cinfo.rec_outbuf_height);

    y = 0;
    while (cinfo.output_scanline < cinfo.output_height)
    {
        // testing here makes it easier to enter Manual mode
        if (_Controller[0].remote_buttons & IR_STOP)
            AutoPlay = 0;

        n = jpeg_read_scanlines(&cinfo, buffer, cinfo.rec_outbuf_height);

        for (i = 0; i < n; i++)
        {
            s = buffer[i];
            for (x = 0; x < cinfo.output_width; x++)
            {
            long color;
    
                color = (s[0] << 24) | (s[2]<<16) | (s[1] << 8);
                s += 3;

                // This is roughly 6% of the total decompression time
                _raw_plotpixel(scrn->dmaFlags, scrn->memP, (1<<16)|x, (1<<16)|y, color);
            }
            y++;
        }
    }

    /* free resources */
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
}

/*****************************************************************************/

void decompress_jpeg(void *jpegdata, int jpeg_size, long *outputbuffer)
{
struct jpeg_decompress_struct cinfo;
struct jpeg_error_mgr jerr;
JOCTET *s;
JSAMPARRAY buffer;
int i, n, row_stride;
int x, y;
int scale = 1;

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);
    jpeg_mem_src(&cinfo, (JOCTET *)jpegdata, jpeg_size);
    jpeg_read_header(&cinfo, TRUE);
    cinfo.out_color_space = JCS_YCbCr;
    cinfo.scale_num = 1;
    cinfo.scale_denom = scale;
    jpeg_start_decompress(&cinfo);
    row_stride = cinfo.output_components * cinfo.output_width;
    buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr) &cinfo, JPOOL_IMAGE, row_stride, cinfo.rec_outbuf_height);

    y = 0;
    while (cinfo.output_scanline < cinfo.output_height)
    {
        n = jpeg_read_scanlines(&cinfo, buffer, cinfo.rec_outbuf_height);

        for (i = 0; i < n; i++)
        {
            s = buffer[i];
            for (x = 0; x < cinfo.output_width; x++)
            {
                // Unfortunately, the buffer output by the JPEG routines is not ready-to-use
                // We gotta reshuffle the pixel component to what we want.
                *outputbuffer++ = (s[0] << 24) | (s[2]<<16) | (s[1] << 8);
                s += 3;
            }
            y++;
        }
    }

    // free resources
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
}

