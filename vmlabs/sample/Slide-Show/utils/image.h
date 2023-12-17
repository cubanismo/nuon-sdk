/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#ifndef IMAGE_H
#define IMAGE_H

typedef struct {
    int width, height;
    int datasize;       // size of data array in bytes; 0 if unallocated
    unsigned char *data;
} Image;

typedef struct {
    unsigned char r,g,b;
} pixel;

// macro used for getting or setting
#define PIXEL(im,col,row) (*(pixel *)((im).data + 3*((im).width*(row) + (col))))

pixel Pixel(int red, int green, int blue);
int InitImage(Image *I, int width, int height);
void DestroyImage(Image *I);
void ClearImage(Image *I);
Image MakeNullImage(void);
int ImageWidth(Image I);
int ImageHeight(Image I);
pixel GetPixel(Image I, int col, int row);
int SetPixel(Image I, int col, int row, pixel P);
pixel BilinearInterp(Image I, double x, double y);
int LoadJpegImage(Image *I, char *filename);
int DumpJpegImage(Image *I, char *filename, int quality);
int SetColorByName(char *colorname, pixel *P);
pixel NamedColor(char *colorname);


#endif
