/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

// 10/7/01 changing STD_BORDER to 12 for better empirical result
/*
    Do the anamorphic fix from an arbitrary W by H image into
    360 by 240, with a four-pixel border at each side.

    9/28/01 (mh)
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "image.h"
#define STD_WIDTH  360
#define STD_HEIGHT 240
//#define STD_BORDER 4
#define STD_BORDER 12

int BlankLine(char *str)
{
    while (*str) {
        if (!isspace(*str++))
            return 0;
    }
    return 1;
}

void RemoveTrailingWhitespace(char *str)
{
    char *p;
    int n;

    n = strlen(str);
    p = str + n - 1;
    while (isspace(*p)) {
        *p = 0;
        p--;
    }
}

// improved version, without having to create a "spare" image
int CreateStandardImage (Image in, Image out, pixel background)
{
    int i,j,w,h,W,H;
    double x,y,xfactor,yfactor,lo,hi;
    pixel C;

    // check that output image is properly sized and fill with background color
    W = ImageWidth(out);
    H = ImageHeight(out);
    if ((W != STD_WIDTH) || (H != STD_HEIGHT)) {
        printf("Output image of non-standard dimensions %d by %d\n", W, H);
        return 0;
    }

    // fill in the side borders
    for (j = 0; j < STD_HEIGHT; j++) {
        for (i = 0; i < STD_BORDER; i++) {
            SetPixel(out, i, j, background);
            SetPixel(out, STD_WIDTH-1-i, j, background);
        }
    }

    w = ImageWidth(in);
    h = ImageHeight(in);

    // check for image too wide
    if (3*w > 4*h) {
        W = w;
        H = (3*W+2)/4;  // +2 for rounding
        lo = (H-h)/2.0;
        hi = (H+h)/2.0;
        xfactor = (W - 1.0) / (STD_WIDTH - 1.0 - 2.0*STD_BORDER);
        yfactor = (H - 1.0) / (STD_HEIGHT - 1.0);
        for (i = STD_BORDER; i < STD_WIDTH-STD_BORDER; i++) {
            x = (i - STD_BORDER) * xfactor;
            for (j = 0; j < STD_HEIGHT; j++) {
                y = j * yfactor;
                if (y < lo || y > hi)
                    C = background;
                else {
                    C = BilinearInterp(in, x, y-lo);
                }
                SetPixel(out, i, j, C);
            }
        }
    }

    // check for image too tall
    else if (3*w < 4*h) {
        H = h;
        W = (4*H+2)/3;  // +2 for rounding
        lo = (W-w)/2.0;
        hi = (W+w)/2.0;
        xfactor = (W - 1.0) / (STD_WIDTH - 1.0 - 2.0*STD_BORDER);
        yfactor = (H - 1.0) / (STD_HEIGHT - 1.0);
        for (i = STD_BORDER; i < STD_WIDTH-STD_BORDER; i++) {
            x = (i - STD_BORDER) * xfactor;
            for (j = 0; j < STD_HEIGHT; j++) {
                if (x < lo || x > hi) {
                    C = background;
                }
                else {
                    y = j * yfactor;
                    C = BilinearInterp(in, x-lo, y);
                }
                SetPixel(out, i, j, C);
            }
        }
    }

    else {
        xfactor = (w - 1.0) / (STD_WIDTH - 1.0 - 2.0*STD_BORDER);
        yfactor = (h - 1.0) / (STD_HEIGHT - 1.0);
        for (i = STD_BORDER; i < STD_WIDTH-STD_BORDER; i++) {
            x = (i - STD_BORDER) * xfactor;
            for (j = 0; j < STD_HEIGHT; j++) {
                y = j * yfactor;
                C = BilinearInterp(in, x, y);
                SetPixel(out, i, j, C);
            }
        }
    }
    return 1;
}

#define NAME_ROOT "nuon_"
#define LEN 128

void main(int argc, char *argv[])
{
    Image in, out;
    char in_fname[LEN], out_name[32], *p;
    FILE *f;
    pixel bg;
    int i,quality;

    bg = NamedColor("black");   // black background only
    if (argc < 2) {
        printf("usage: anamorph jpeg_listfile [quality]\n");
        printf("\twhere quality is between 1 and 100, and defaults to 95\n");
        exit(1);
    }
    f = fopen(argv[1], "r");
    if (!f) {
        printf("Cannot open jpeg_listfile: %s\n", argv[1]);
        exit(2);
    }
    if (argc > 2) {
        quality = atoi(argv[2]);
    }
    else {
        quality = 95;
    }
    if (!InitImage(&out, STD_WIDTH, STD_HEIGHT)) {
        printf("unable to initialize image\n");
        exit(3);
    }

    // start with a Null image
    in = MakeNullImage();
    
    i = 1;
    while (fgets(in_fname,LEN,f)) {
        p = strchr(in_fname,';');
        if (p) *p = 0;
        RemoveTrailingWhitespace(in_fname);
        if (BlankLine(in_fname))
            continue;
        if (!LoadJpegImage(&in, in_fname)) {
            printf("Error loading image %s\n", in_fname);
            continue;
        }
        if (!CreateStandardImage(in, out, bg)) {
            printf("Error return from CreateStandardImage\n");
            printf("\twhile processing %s\n", in_fname);
            continue;
        }
        sprintf(out_name, "%s%03d.jpg", NAME_ROOT, i);
        if (!DumpJpegImage(&out, out_name, quality)) {
            printf("Error writing image, while processing %s\n", in_fname);
        }
        i++;
        printf(".");
    }
    printf("\n");
    DestroyImage(&in);
    DestroyImage(&out);
    exit(0);
}


