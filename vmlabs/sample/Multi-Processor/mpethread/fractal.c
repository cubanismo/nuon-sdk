/*
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

/* Example of how to use the _MPEAllocThread function */
#include <stdlib.h>
#include <math.h>
#include <nuon/dma.h>
#include <nuon/sdram.h>
#include <nuon/mpe.h>
#include <nuon/bios.h>

/* address of the screen buffer in SDRAM */
static unsigned char *SCREENBASE;

/* width and height of the frame buffer */
#define WIDTH 720
#define HEIGHT 480

#define PIXEL_TYPE 4          /* DMA flags for 32bpp pixels */
#define BYTES_PER_PIXEL 4     /* size of pixels in bytes */

#define XSIZE ((WIDTH/8)<<16)
#define DMAFLAGS (XSIZE | DMA_PIXEL_WRITE | (PIXEL_TYPE<<4) | DMA_CLUSTER_BIT)

/* color to which to clear the screen */
#define BGCOLOR 0x10808000

/* define for how to plot a pixel */
inline void PlotPixel(int x, int y, int color)
{
    _raw_plotpixel(DMAFLAGS, SCREENBASE, (1<<16)|x, (1<<16)|y, color);
}

int ColorToInt(double r, double g, double b)
{
    int y,cr,cb;
    double Y,Cr,Cb;

    Y = 0.299*r + 0.587*g + 0.114*b;
    Cr = 0.713*(r - Y);
    Cb = 0.564*(b - Y);

    y = 219*Y + 16.5;
    cr = 224*Cr + 128.5;
    cb = 224*Cb + 128.5;

    return (y<<24) | (cr<<16) | (cb<<8);
}

#define sign(a,b) ((b)<0 ? ((a)<0 ? (a) : -(a)) : ((a)<0 ? -(a) : (a)))

/* NB: the definition of RAND_MAX in stdlib.h was wrong in older
   versions of the libraries */
#undef RAND_MAX
#define RAND_MAX 0x7fff

double ran(void)
{
    return (double)rand()/(double)RAND_MAX;
}

int RandomColorInt(void)
{
    double r, g, b;

    r = ran();
    g = ran();
    b = ran();
    return ColorToInt(r, g, b);
}

void PaintBackground(int startx, int starty, int endx, int endy, int color)
{
    int x,y;

    for (x = startx; x < endx; x++)
        for (y = starty; y < endy; y++)
            PlotPixel(x, y, color);
}

int round(double x)
{
    return (x < 0) ? (int)(x - 0.5) : (int)(x + 0.5);
}

#define MAXPTS 750
#define MAXITER 250

#define SCALE 2


struct thread_param {
    int xoff;
    int yoff;
    int width;
    int height;
};

void
do_thread(struct thread_param *arg)
{
    int ix, iy;
    int color;
    int iter, pt;
    int xoff, yoff;
    int width, height;
    double sa,sb,sc,s,xold,xnew,y,centerx,centery;

    xoff = arg->xoff;
    yoff = arg->yoff;
    width = arg->width;
    height = arg->height;

    while (1)
	{
        PaintBackground(xoff, yoff, xoff+width, yoff+height, BGCOLOR);

        sa = 100*ran() - 50;
        sb = 100*ran() - 50;
        sc = 100*ran() - 50;
        
		s = 1.2 * (6.0 - (fabs(sa) + fabs(sb) + fabs(sc))/30.0);
        xold = y = 0;
        centerx = SCALE*(width * (ran()/2.0 + 0.25));
        centery = SCALE*(height * (ran()/2.0 + 0.25));

        for (iter = 0; iter < MAXITER; iter++)
		{
            color = RandomColorInt();

            for (pt = 0; pt < MAXPTS; pt++)
			{
                ix = round(centerx + xold * s)/SCALE;
                iy = height - (round(centery + y * s)/SCALE) + 1;

                if (ix >= 0 && ix < width && iy >= 0 && iy < height)
                    PlotPixel(xoff + ix, yoff + iy, color);

                xnew = y - sign(1,xold)*sqrt(fabs(sb*xold-sc));
                y = sa - xold;
                xold = xnew;
            }
        }
    }

}

/* stack for the user thread */
#define STACK_SIZE 128
static long thread_stack[STACK_SIZE] __attribute__((aligned(16)));

int
main(int argc, char **argv)
{
    struct thread_param arg1, arg2;
    int mpe;

    /* we will need MPE 0, so shut down the media code */
    _MediaShutdownMPE();

    /* allocate a frame buffer */
    SCREENBASE = SDRAMAlloc(WIDTH*HEIGHT*BYTES_PER_PIXEL);

    /* set up the screen */
    _VidSetup(SCREENBASE, DMAFLAGS, WIDTH, HEIGHT, 0);

    /* fill with grey */
    PaintBackground(0, 0, WIDTH, HEIGHT, 0x80D04000);

    /* try to get an MPE */
    mpe = _MPEAlloc(MPE_HAS_CACHES);
    if (mpe < 0) {
	/* we failed to get the MPE... */
	/* report an error somehow in a normal program */
    } else {
	arg1.xoff = 0;
	arg1.yoff = 0;
	arg1.width = WIDTH/2;
	arg1.height = HEIGHT/2;

	_MPERunThread(mpe, do_thread, &arg1, thread_stack+STACK_SIZE);
    }

    arg2.xoff = WIDTH/2;
    arg2.yoff = HEIGHT/2;
    arg2.width = WIDTH/2;
    arg2.height = HEIGHT/2;
    do_thread(&arg2);
    
    return 0;
}
