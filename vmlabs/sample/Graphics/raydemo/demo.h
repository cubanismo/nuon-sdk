/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

/* various global defines for the graphics demo */
#define MAX_SCRN_WIDTH  352
#define MAX_SCRN_HEIGHT 240
#define MAX_MPES 8

#ifndef DMA_XFER_TYPE
#define DMA_XFER_TYPE 4
#endif

#ifndef DMAFLAGS
#define XSIZE ((MAX_SCRN_WIDTH/8)<<16)
#define DMAFLAGS (DMA_PIXEL_WRITE | XSIZE | (DMA_XFER_TYPE<<4) | (1<<11))
#endif

#define BGCOLOR 0x40808000 /* dark grey */
#define FGCOLOR 0xc0808000 /* white */

void CreateChannel(VidChannel *ch, int how, void *base, long dmafl, int srcw, int srch,
                   int filter);
void ShowScreen(void *base);
void FillScreen(void *base, long color);

/* defines for CreateChannel "how" parameter */
#define VIDEO_FULLSCREEN 0
#define VIDEO_LETTERBOX  1
#define VIDEO_ONE_TO_ONE 2
#define VIDEO_DOUBLE     3

extern VidDisplay display;
extern VidChannel mainchannel, osdchannel;

extern int ray_mpe[];
extern int num_mpes;

extern void *screen[4];
#define OSD_SCREEN 3
extern int dispbuf, drawbuf;
extern int osd_on;

/* joystick button info */
extern unsigned short lastbuttons;
extern unsigned long lastremote;


/* menu interaction code & data structures */
typedef struct menuentry {
    char *text;       /* text to print */
    int  retval;      /* value to return if selected, if this is selectable */
} MenuEntry;

#define SELECTABLE(b) (((b).retval != -1) && (b).text[0])

typedef struct menu {
    int whichmenu;   /* where the cursor is */
    MenuEntry *entry;
} Menu;


int ShowMenu(Menu *);
void DrawMenu(Menu *);
void ClearMenu(void);
int sky_menu(void);
