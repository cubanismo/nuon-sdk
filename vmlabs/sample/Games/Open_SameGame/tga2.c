
// modified tga player code for SameGame

/*
 * tga player: plays an 8bpp .TGA file back into a buffer

 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include "sg.h"
#include "sg_xtract.h"

// make sure there is no DEBUG since we do not want to call any printf
// statements
#undef DEBUG

#ifdef DEBUG
#include <stdio.h>
#endif
#include <stdlib.h>
#include <string.h>
#include <nuon/video.h>


#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

#define kBlackff 0x108080ff

typedef unsigned char uchar;


//****************************************************************
// some utility functions
//----------------------------------------------------------------

/* min and max macros */
#ifndef min
#define min(x,y)        ((x) < (y) ? (x) : (y))
#define max(x,y)        ((x) > (y) ? (x) : (y))
#endif

/* Bound an expression to the unit interval [low, high] */
#define Bound(low, high, x)      max((low), min((high), (x)))


static unsigned long
My_YCCAFromRGBA(uchar r, uchar g, uchar b, uchar a)
{
  double rf, gf, bf;
  double yf, crf, cbf;
  int yk, crk, cbk;
  unsigned long color;


  if (((int)r == INV_R) && ((int)g == INV_G) && ((int)b == INV_B)){
    // convert all occurances of colour (INV_R, INV_G, INV_B) to
    // kBlackff which is transparent;  the values for INV_R, INV_G,
    // INV_B are set in sg.cnf  
    color = kBlackff;
  }else{
    // convert to YCCA format

    rf = (double)r/255.0;
    gf = (double)g/255.0;
    bf = (double)b/255.0;
    
    yf = Bound(0.0, 1.0, 0.299 * rf + 0.587 * gf + 0.114 * bf);
    crf = Bound(-0.5, 0.5, 0.500 * rf - 0.419 * gf - 0.081 * bf);
    cbf = Bound(-0.5, 0.5, -0.169 * rf - 0.331 * gf + 0.500 * bf);

    /* 0.5 added below to force rounding */
    yk = 16 + (int)(yf * 219.0 + 0.5);
    crk = 128 + (int)(crf * 224.0 + 0.5);
    cbk = 128 + (int)(cbf * 224.0 + 0.5);

    color = (yk<<24) | (crk << 16 ) | (cbk << 8) | (255-a);
  }

    return color;
}


static unsigned long
YCC16FromRGB(uchar r, uchar g, uchar b)
{
  double rf, gf, bf;
  int yk, crk, cbk;
  unsigned long color;
  double yf, crf, cbf;

  rf = (double)r/255.0;
  gf = (double)g/255.0;
  bf = (double)b/255.0;

  yf = Bound(0.0, 1.0, 0.299 * rf + 0.587 * gf + 0.114 * bf);
  crf = Bound(-0.5, 0.5, 0.500 * rf - 0.419 * gf - 0.081 * bf);
  cbf = Bound(-0.5, 0.5, -0.169 * rf - 0.331 * gf + 0.500 * bf);

  /* 0.5 added below to force rounding */
  yk = (16 + (int)(yf * 219.0 + 0.5)) >> 2;
  crk = (128 + (int)(crf * 224.0 + 0.5)) >> 3;
  cbk = (128 + (int)(cbf * 224.0 + 0.5)) >> 3;

  color = (yk<<26) | (crk << 21 ) | (cbk << 16);
  return color;
}


#define PALETTE_SIZE 256
#define MAX_WIDTH 720

//****************************************************************
// TGA file reading code
//----------------------------------------------------------------

typedef struct {
    uchar id_len;        // length of identifier field
    uchar cmap_type;     // type of color map
    uchar img_type;      // type of image
    ushort cmap_origin;  // index of first color map entry
    ushort cmap_len;     // number of color map entries
    uchar cdepth;       // depth of color map entries
    ushort xorigin, yorigin; // origin of image
    ushort width;
    ushort height;
    uchar  pixel_size;  // image pixel size
    uchar  descrip;     // image descriptor
} TGAHEAD;


// Ftn reads tga artfile from the data file; returns -1 on failure
int ReadTGAfrmDatFile(char *filename, long dmaflags, void *base)
{
  int i;
  //int fd;
  long filesize;
  char *buf;

  struct Index_of_Files Index_Entry;  

  // find_name_in_index returns -1 if file not found
  i = find_name_in_Index(filename, &Index_Entry);
  if (ON_DVD == 0)
    fprintf(stderr, "Index containing %s is %d\n", filename, i);

  if (i < 0){
    if (ON_DVD == 0)
      fprintf(stderr, "File %s not found\n", filename);
    return -1;
  }

  // "network to host" ftn which converts from big-endian to
  // whatever this system is using (NUON uses big-endian)
  filesize = ntohl(Index_Entry.size);
  if (ON_DVD == 0)
    fprintf(stderr, "Size is %ld\n", filesize);
  
  buf = malloc(filesize);
  if (buf == NULL){
    if (ON_DVD == 0)
      fprintf(stderr, "In ReadTGAfrmDatFile:  Malloc request failed\n");
    return -1;
  }
  
  // read file at i'th position in Index into buf
  //  if (get_file("sg.dat", i, buf) < 0){
  if (get_file(DATA_FILE, i, buf) < 0){
    if (ON_DVD == 0)
      fprintf(stderr, "Can't get %s from sg.dat\n", filename);
    return -1;
  }
  
  // then call ReadTGA which is defined below
  ReadTGA(buf, dmaflags, base, 0, 0, NULL);
  
  free (buf);
  
  return 0;
}



// Ftn below allows us to read in tga files at run time

int ReadTGAfrmFile(char *filename, long dmaflags, void *base)
{
  int fd;
  long filesize;
  char* buf;

  // returns -1 if an error occurs
  if ((fd = my_open(filename, O_RDONLY, 0)) == -1){
    if (ON_DVD == 0)
      printf("Can't open file %s\n", filename);
    return -1;
  }

  filesize = lseek(fd, 0L, SEEK_END);
  if (filesize == -1){
    if (ON_DVD == 0)
      printf("lseek failed\n");
    return -1;
  }
  lseek(fd, 0L, SEEK_SET);
  
  buf = malloc(filesize);
  if (buf == NULL){
    if (ON_DVD == 0)
      printf("Malloc request failed\n");
    return -1;
  }

  // check that this returns filesize
  if (read(fd, buf, filesize) == -1){
    if (ON_DVD == 0)
      printf("read into buf failed\n");
    return -1;
  }
  
  my_close(fd);

  // then call ReadTGA which is defined below
  ReadTGA(buf, dmaflags, base, 0, 0, NULL);

  free(buf);

  return 0;
}


// tga points to the first byte of the source tga file
// dmaflags is the dmaflags of destination image
// base is the address of destination image
// xOutOffset is the x position of source in destination
// yOutOffset is the y position of source in destination
// clut is pointer to 256 longs where the clut of the source
// tga file will be put (this can be a NULL pointer if you
// don't care about the clut)

int ReadTGA(unsigned char *tga, long dmaflags, void *base,
        int xOutOffset, int yOutOffset, unsigned long *clut)
{
    TGAHEAD hdr;
    unsigned int c;

    unsigned long localclut[PALETTE_SIZE];
    int fixedalpha = 0;

    int starty, endy, ystep;
    int pixcount;

    int i;
    int is16bpp, istruecolor;
    int y, x;

    if (!tga) {
        return 0;
    }

    if (!clut) {
        clut = localclut;
    }

    hdr.id_len = *tga++;
    hdr.cmap_type = *tga++;
    hdr.img_type = *tga++;
    hdr.cmap_origin = tga[0] | (tga[1] << 8); tga += 2;
    hdr.cmap_len = tga[0] | (tga[1] << 8); tga += 2;
    hdr.cdepth  = tga[0] ; tga += 1;
    hdr.xorigin = hdr.yorigin = 0; tga += 4;  // ignore the origin field
    hdr.width = tga[0] | (tga[1] << 8); tga += 2;
    hdr.height = tga[0] | (tga[1] << 8); tga += 2;
    hdr.pixel_size = *tga++;
    hdr.descrip = *tga++;

    tga += hdr.id_len; // skip identifier

    if (hdr.cmap_type != 1) {
#ifdef DEBUG
        printf("Error: TGA file not color mapped\n");
#endif
        return 0;
    }
    if (hdr.img_type != 9) {
#ifdef DEBUG
        printf("Error: TGA file not RLE encoded\n");
#endif
        return 0;
    }
    if (hdr.cdepth == 24) {
        fixedalpha = 1;        // targa file contains no alphas
    } else if (hdr.cdepth == 32) {
        fixedalpha = 0;        // alphas come from targa file
    } else {
#ifdef DEBUG
        printf("TGA Error: depth of color map entries is %d\n", hdr.cdepth);
#endif
        return 0;
    }

    /* figure out if the destination is a truecolor bitmap, and if
       so, whether it is a 16bpp or 32bpp bitmap */
    {
      int pixtype = (dmaflags >> 4) & 0xf;
      if (pixtype == 3) {  // 8bpp
	istruecolor = is16bpp = FALSE;
      } else {
	istruecolor = TRUE;
	is16bpp = (pixtype != 4);
      }
    }

    /* read the CLUT data; at most 256 entries are allowed */
    if (hdr.cmap_len > PALETTE_SIZE) {
#ifdef DEBUG
        printf("TGA Error: too many CLUT entries (%d)\n", hdr.cmap_len);
#endif
        return 0;
    }

    if (is16bpp) {
      // make CLUT entries 16bpp pixels
        for (i = 0; i < hdr.cmap_len; i++) {
	  clut[i] = YCC16FromRGB(tga[2], tga[1], tga[0]);
	  tga += (fixedalpha) ? 3 : 4;
        }
    } else {
        if (fixedalpha) {
	  // read 24 bit CLUT entries
	  for (i = 0; i < hdr.cmap_len; i++) {
	    clut[i] = My_YCCAFromRGBA(tga[2], tga[1], tga[0], 255);
	    //	    clut[i] = YCCAFromRGBA(tga[2], tga[1], tga[0], 255);
	    tga += 3;
	  }
        } else {
	  // read 32 bit CLUT entries
	  for (i = 0; i < hdr.cmap_len; i++) {
	    clut[i] = My_YCCAFromRGBA(tga[2], tga[1], tga[0], tga[3]);
	    //	    clut[i] = YCCAFromRGBA(tga[2], tga[1], tga[0], tga[3]);
	    tga += 4;
	  }
        }
    }
    
    /* check descriptor byte to see which order the image is stored in */
    if (hdr.descrip & (1<<5)) {
        starty = yOutOffset; endy = hdr.height + yOutOffset; ystep = 1;
    } else {
        starty = (hdr.height-1)+yOutOffset; endy = yOutOffset-1; ystep = -1;
    }

    if (hdr.width > MAX_WIDTH) {
#ifdef DEBUG
        printf("TGA Error: file too wide (%d)\n", hdr.width);
#endif
        return 0;
    }

    if ((hdr.width & 1) && !istruecolor) {
#ifdef DEBUG
        printf("TGA Error: odd width (%d)\n", hdr.width);
#endif
        return 0;
    }

    y = starty;
    x = 0;

    if (istruecolor) {
      do {
	// get next RLE packet
	c = *tga++;
	if (c & 0x80) {
	  /* one pixel repeated */
	  i = (c - 0x80)+1;  /* repeat count */
	  c = clut[*tga++];
	  while (i > 0) {
	    pixcount = (i > 32) ? 32 : i;
	    if (x + pixcount > hdr.width)
	      pixcount = hdr.width - x;
	    _raw_plotpixel(dmaflags, base, (pixcount<<16)|(x+xOutOffset), (1<<16)|y, c);
	    x += pixcount;
	    i -= pixcount;
	    if (x >= hdr.width) {
	      x = 0;
	      y += ystep;
	      if (y == endy) {
		break;
	      }
	    }
	  }
	} else {
	  /* a bunch of unique pixels */
	  i = c+1;
	  while (i-- > 0) {
	    _raw_plotpixel(dmaflags, base, (1<<16)|(x+xOutOffset), (1<<16)|y, clut[tga[0]]);
	    tga++;
	    x++;
	    if (x >= hdr.width) {
	      x = 0;
	      y += ystep;
	      if (y == endy) {
		break;
	      }
	    }
	  }
	}
      } while (y != endy);
    } else {
      // 8bpp -- have to output 2 pixels at a time
      int lastc;
      
      lastc = -1;
      do {
	// get next RLE packet
	c = *tga++;
	if (c & 0x80) {
	  /* one pixel repeated */
	  i = (c - 0x80)+1;  /* repeat count */
	  c = *tga++;
	  while (i-- > 0) {
	    if (lastc < 0) {
	      lastc = c;
	    } else {
	      _raw_plotpixel(dmaflags, base, (2<<16)|(x+xOutOffset), (1<<16)|y,
			     (lastc << 24) | (c << 16));
	      x += 2;
	      lastc = -1;
	      if (x >= hdr.width) {
		x = 0;
		y += ystep;
		if (y == endy) {
		  break;
		}
	      }
	    }
	  }
	} else {
	  /* a bunch of unique pixels */
	  i = c+1;
	  while (i-- > 0) {
	    if (lastc < 0) {
	      lastc = *tga++;
	    } else {
	      c = *tga++;
	      _raw_plotpixel(dmaflags, base, (2<<16)|(x+xOutOffset), (1<<16)|y,
			     (lastc << 24) | (c<<16));
	      x+= 2;
	      lastc = -1;
	      if (x >= hdr.width) {
		x = 0;
		y += ystep;
		if (y == endy) {
		  break;
		}
	      }
	    }
	  }
	}
      } while (y != endy);
    }
    
    return 1;
}
