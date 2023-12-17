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

/*
 * C write string routine, for debugging use
 *
 * This routine uses the low level _raw_plotpixel
 * interface to draw characters using short
 * horizontal and vertical line segments.
 * It is primarily intended for debugging
 * support; it is *not* a replacement for
 * a real font library, by any imaginable
 * stretch of the imagination!!
 */

#include "mutil.h"
#include <nuon/dma.h>

/* line information structure */
/* each of xinfo and yinfo contains a
 * 16 bit length in the upper bits, and
 * a 16 bit pixel offset in the lower bits
 */

struct linedata {
    long xinfo;
    long yinfo;
};

static struct linedata lines[];

/* font data (forward declaration) */
static long numbers[];      /* numbers */
static long lcletters[26];    /* lower case letters */
static long punct1[];

#define CHARACTER_WIDTH 9
#define CHARACTER_HEIGHT 14

void
DebugWS(long dmaflags, void *dmaaddr, int xpos, int ypos, long color, const char *str)
{
    long xinfo, yinfo;
    int c, i;
    unsigned long bits;

    while (*str) {
	c = *str++;
	if (c >= '0' && c <= '?') {  /* includes ascii characters 0-9 : ; < = > */
	    bits = numbers[c - '0'];
	} else if (c >= 'a' && c <= 'z') {
	    bits = lcletters[c - 'a'];
	} else if (c >= 'A' && c <= 'Z') {
	    /* we should do a separate table for upper case */
	    bits = lcletters[c - 'A'];
	} else if (c >= '+' && c <= '.') {
	    bits = punct1[c - '+'];
	} else {
	    bits = 0;
	}

	/* now see which bits are set; those
	   tell us which lines to draw */
	i = 0;
	while (bits) {
	    if (bits & 1) {
		xinfo = lines[i].xinfo + xpos;
		yinfo = lines[i].yinfo + ypos;
		_raw_plotpixel(dmaflags, dmaaddr, xinfo, yinfo, color);
	    }
	    bits = bits >> 1;
	    i++;
	}

	/* move to next character position */
	xpos += CHARACTER_WIDTH;
    }
}

/*
 * the lines we have to work with
 * basically everything is laid out in a 7x12 grid
 * that looks kind of like an LED
 * vertical strokes have names like
 * LEFT_TOP
 * horizontal strokes have names like
 * TOP_BAR
 */

#define LEFT_TOP (1<<0)
#define LEFT_MID (1<<1)
#define LEFT_BOT (1<<2)
#define LEFT_SIDE_LOWER (LEFT_MID + LEFT_BOT)
#define LEFT_SIDE (LEFT_TOP+LEFT_SIDE_LOWER)

#define MIDDLE_TOP (1<<3)
#define MIDDLE_MID (1<<4)
#define MIDDLE_BOT (1<<5)

#define RIGHT_TOP (1<<6)
#define RIGHT_MID (1<<7)
#define RIGHT_BOT (1<<8)
#define RIGHT_SIDE_LOWER (RIGHT_MID+RIGHT_BOT)
#define RIGHT_SIDE (RIGHT_TOP+RIGHT_SIDE_LOWER)

#define TOP_BAR   (1<<9)
#define MID_BAR   (1<<10)
#define LOWER_BAR (1<<11)
#define BOTTOM_BAR (1<<12)

#define TOP_RIGHT_BAR (1<<13)
#define LOWER_RIGHT_BAR (1<<14)
#define BOTTOM_LEFT_BAR (1<<15)

#define PERIOD_DOT (1<<16)
#define COMMA_DOT  (1<<17)
#define CENTER_DOT (1<<18)

/* Here are the DMA X and Y commands for the lines.
 * Each consists of two words, one for X and one for
 * Y. The high 16 bits of each word contains the width
 * of the stroke; the low 16 bits contains the
 * offset (from the upper left of the character) of
 * where the stroke should start.
 */
struct linedata lines[] = {
    { (1L<<16)|(0), (7L<<16)|(0) }, /* left top */
    { (1L<<16)|(0), (4L<<16)|(6) },
    { (1L<<16)|(0), (4L<<16)|(9) },

    { (1L<<16)|(3), (7L<<16)|(0) }, /* middle top */
    { (1L<<16)|(3), (4L<<16)|(6) }, /* middle mid */
    { (1L<<16)|(3), (4L<<16)|(9) }, /* middle low */

    { (1L<<16)|(6), (7L<<16)|(0) }, /* right top */
    { (1L<<16)|(6), (4L<<16)|(6) },
    { (1L<<16)|(6), (4L<<16)|(9) },

    { (7L<<16)|(0), (1L<<16)|(0) }, /* top bar */
    { (7L<<16)|(0), (1L<<16)|(6) },
    { (7L<<16)|(0), (1L<<16)|(9) },
    { (7L<<16)|(0), (1L<<16)|(12) },

    { (4L<<16)|(3), (1L<<16)|(0) }, /* top right bar */
    { (4L<<16)|(3), (1L<<16)|(9) },
    { (4L<<16)|(0), (1L<<16)|(12) },

    /* some single dots and short lines for punctuation */
    { (1L<<16)|(3), (1L<<16)|(12) }, /* period */
    { (1L<<16)|(3), (3L<<16)|(12) }, /* comma */
    { (1L<<16)|(3), (1L<<16)|(9) }, /* center dot */

};

/*
 * the numerals 0 through 9, plus colon and semi-colon
 */

static long numbers[] = {
    /* 0 - 2 */
    LEFT_SIDE + RIGHT_SIDE + TOP_BAR + BOTTOM_BAR,
    MIDDLE_TOP + MIDDLE_MID + MIDDLE_BOT,
    TOP_BAR + MID_BAR + BOTTOM_BAR + RIGHT_TOP + LEFT_SIDE_LOWER,

    /* 3-5 */
    TOP_BAR + MID_BAR + BOTTOM_BAR + RIGHT_SIDE,
    MID_BAR + LEFT_TOP + RIGHT_SIDE,
    TOP_BAR + MID_BAR + BOTTOM_BAR + LEFT_TOP + RIGHT_SIDE_LOWER,

    /* 6-8 */
    LEFT_SIDE + MID_BAR + BOTTOM_BAR + TOP_BAR + RIGHT_SIDE_LOWER,
    TOP_BAR + RIGHT_SIDE,
    TOP_BAR + MID_BAR + BOTTOM_BAR + LEFT_SIDE + RIGHT_SIDE,

    /* 9 */
    TOP_BAR + MID_BAR + BOTTOM_BAR + LEFT_TOP + RIGHT_SIDE,

    /* some punctuation */
    PERIOD_DOT + CENTER_DOT,     /* colon */
    COMMA_DOT + CENTER_DOT,      /* semicolon */
    0,                           /* less than sign (<) */
    LOWER_BAR + MID_BAR,         /* equals (=) */
    0,                           /* greater than sign (>) */
    0,                           /* question mark (?) */
};

/*
 * the lower case letters
 */

static long lcletters[26] = {
    /* abcde */
    BOTTOM_BAR + LOWER_BAR + MID_BAR + RIGHT_SIDE_LOWER + LEFT_BOT,
    LEFT_SIDE + MID_BAR + BOTTOM_BAR + RIGHT_SIDE_LOWER,
    LEFT_SIDE_LOWER + MID_BAR + BOTTOM_BAR,
    LEFT_SIDE_LOWER + MID_BAR + BOTTOM_BAR + RIGHT_SIDE,
    LEFT_SIDE_LOWER + MID_BAR + LOWER_BAR + BOTTOM_BAR + RIGHT_MID,

    /* fghijk */
    MID_BAR + TOP_RIGHT_BAR + MIDDLE_TOP + MIDDLE_MID + MIDDLE_BOT,
    LEFT_MID + MID_BAR + LOWER_BAR + BOTTOM_BAR + RIGHT_SIDE_LOWER,
    LEFT_SIDE + MID_BAR + RIGHT_SIDE_LOWER,

    MIDDLE_MID + MIDDLE_BOT,
    BOTTOM_BAR + LEFT_BOT + RIGHT_SIDE_LOWER,
    LEFT_SIDE + MIDDLE_TOP + MID_BAR + RIGHT_SIDE_LOWER,

    /* lmnop */
    MIDDLE_TOP + MIDDLE_MID + MIDDLE_BOT,
    MID_BAR + LEFT_SIDE_LOWER + MIDDLE_MID + MIDDLE_BOT + RIGHT_SIDE_LOWER,
    MID_BAR + LEFT_SIDE_LOWER + RIGHT_SIDE_LOWER,
    MID_BAR + BOTTOM_BAR + LEFT_SIDE_LOWER + RIGHT_SIDE_LOWER,
    MID_BAR + LOWER_BAR + LEFT_SIDE_LOWER + RIGHT_MID,

    /* qrstuv */
    MID_BAR + LOWER_BAR + RIGHT_SIDE_LOWER + LEFT_MID,
    MID_BAR + LEFT_SIDE_LOWER,
    MID_BAR + LOWER_BAR + BOTTOM_BAR + LEFT_MID + RIGHT_BOT,
    MID_BAR + MIDDLE_TOP + MIDDLE_MID + MIDDLE_BOT,
    BOTTOM_BAR + LEFT_SIDE_LOWER + RIGHT_SIDE_LOWER,
    BOTTOM_LEFT_BAR + LOWER_RIGHT_BAR + LEFT_SIDE_LOWER + MIDDLE_BOT + RIGHT_MID,

    /* wxyz */
    /* FIXME: "x" doesn't look very good */
    BOTTOM_BAR + LEFT_SIDE_LOWER + RIGHT_SIDE_LOWER + MIDDLE_BOT + MIDDLE_MID,
#if 0
    MID_BAR + BOTTOM_BAR + MIDDLE_MID + MIDDLE_BOT,  /* x?? */
#else
    MIDDLE_MID + MIDDLE_BOT + LOWER_BAR + RIGHT_BOT, /* new x from Tricia */
#endif
    LOWER_BAR + BOTTOM_BAR + LEFT_MID + RIGHT_SIDE_LOWER,
    MID_BAR + LOWER_BAR + BOTTOM_BAR + LEFT_BOT + RIGHT_MID
};


/* some miscellaneous punctuation */
static long punct1[] = {
    MIDDLE_MID + MIDDLE_BOT + LOWER_BAR,   /* plus sign (+) */
    COMMA_DOT,                             /* comma (,) */
    LOWER_BAR,                             /* minus sign (-) */
    PERIOD_DOT,                            /* period (.) */
};
