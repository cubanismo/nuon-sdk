/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdlib.h>
#include <nuon/dma.h>
#include <nuon/joystick.h>
#include <nuon/video.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>
#include <nuon/termemu.h>
#include "demo.h"

#define WHITE 0xc0808000
#define BLACK 0x10808000
#define GREY  0x80808000
#define GREEN 0x703A4800
#define RED   0x41D46400

/*
 * draw the sky background
 */

long skycodesize;
long skydatasize;

extern long skycode_start[], skycode_size[];
extern long skyram_start[], skyram_size[];

/*
 * set up data structures for sky rendering
 */
#define SKY_MPES 2
int *skydata[SKY_MPES];

void
InitSkyDraw(void)
{
    int i;
    static int firsttime = 1;

    skycodesize = (long)skycode_size;
    skydatasize = (long)skyram_size;

    if (firsttime) {
        /* set up buffers */
        for (i = 0; i < SKY_MPES; i++)
            skydata[i] = malloc(skydatasize);
        /* start up the sky code  using default data */
        for (i = 0; i < SKY_MPES; i++) {
            StartMPE(ray_mpe[i], skycode_start, (long)skycodesize, skyram_start, skydatasize);
        }
        firsttime = 0;
    } else {
        /* start up the sky code using the saved data */
        for (i = 0; i < SKY_MPES; i++) {
            StartMPE(ray_mpe[i], skycode_start, (long)skycodesize, skydata[i], skydatasize);
        }
    }
}

/*
 * start drawing the sky with MPEs
 */

void
StartSkyDraw(long dmaflags, void *dmabase)
{
    long packet[4];
    int i, id;

    /* start up the sky MPEs */
    for (i = 0; i < SKY_MPES; i++) {
	id = ray_mpe[i];

	/* send it its marching orders */
	packet[0] = dmaflags;
	packet[1] = (long)dmabase;
	packet[2] = i;  /* starty */
	packet[3] = MAX_SCRN_HEIGHT/SKY_MPES; /* ycount */
	_CommSend(id, packet);
    }
}

/*
 * finish sky drawing
 */
void
FinishSkyDraw(void)
{
    int i;

    for (i = 0; i < SKY_MPES; i++) {
        StopMPE(ray_mpe[i]);
    }
    /* save the data */
    /* wait for the MPEs to stop for the first time */
    /* then suck their brains out (save data for next iteration) */
    for (i = 0; i < SKY_MPES; i++) {
	CopyFromMPE(ray_mpe[i], skydata[i], (void *)0x20100000, skydatasize);  /* brain suck */
    }
}



#define FONT_WIDE 8
#define FONT_HIGH 16

/* draw centered text starting at line Y */
/* returns a new Y */
int centertext(int y, char *buf, int fg, int bg)
{
    int len;
    int x;

    len = FONT_WIDE*strlen(buf);
    x = (MAX_SCRN_WIDTH - len)/2;
    if (*buf)
        DrawText(buf, x, y, fg, bg);
    return y+FONT_HIGH;
}

#define BG_CLEAR 0x108080ff
#define BG_DARK  0x108080a0


/******************************************************
 * Menu drawing code
 ******************************************************/

void
DrawMenu(Menu *menu)
{
    int y = 32;
    int fg;
    int bg;
    int i;

    for (i = 0; menu->entry[i].text; i++) {
        fg = WHITE;
        if (i == menu->whichmenu)
            bg = BG_DARK;
        else
            bg = BG_CLEAR;
        y = centertext(y, menu->entry[i].text, fg, bg);
    }
}

void
ClearMenu(void)
{
    FillScreen(screen[OSD_SCREEN], BG_CLEAR);
}

/*
 * interact with a menu, and return a result, while running
 * the sky code in the background
 */

int
ShowMenu(Menu *menu)
{
    unsigned short buttons, joyedge;
    unsigned long remote, remedge;
    int NumEntries;
    int xval, yval;

    /* figure out how many items there are in the menu */
    /* while we're at it, look for the first selectable item;
       if menu->whichmenu is -1 then set menu->whichmenu to the
       first selectable we find */
    for (NumEntries = 0; menu->entry[NumEntries].text; NumEntries++) {
        if (menu->whichmenu == -1 && SELECTABLE(menu->entry[NumEntries]))
            menu->whichmenu = NumEntries;
    }

    ClearMenu();

    for(;;) {
        /* draw the menu */
        DrawMenu(menu);

        /* compute joystick data */
        /* first, or together remote, joystick 1, and joystick 2 states */
        buttons = _Controller[0].buttons | _Controller[1].buttons | _Controller[5].buttons;
        remote = _Controller[0].remote_buttons;

        /* if the analog joystick is moving, simulate some buttons */
        xval = JoyXAxis(_Controller[1]);
        yval = JoyYAxis(_Controller[1]);
        if (xval > 32) {
            buttons |= CTRLR_DPAD_RIGHT;
        } else if (xval < -32) {
            buttons |= CTRLR_DPAD_LEFT;
        }
        if (yval > 32) {
            buttons |= CTRLR_DPAD_UP;
        } else if (yval < -32) {
            buttons |= CTRLR_DPAD_DOWN;
        }

        /* check for button down events */
        joyedge = (buttons ^ lastbuttons) & (buttons);
        remedge = (remote ^ lastremote) & (remote);
        lastbuttons = buttons;
        lastremote = remote;

        if (joyedge & (CTRLR_BUTTON_A|CTRLR_BUTTON_START))
            break;

        /* if menu->whichmenu starts out negative, then nothing in the menu
           is selectable: no point trying to move a cursor! */
        if (menu->whichmenu < 0)
            continue;

        if (joyedge & CTRLR_DPAD_UP) {
            do {
                if (menu->whichmenu <= 0) menu->whichmenu = NumEntries;
                menu->whichmenu--;
            } while (!SELECTABLE(menu->entry[menu->whichmenu]));
        } else if (joyedge & CTRLR_DPAD_DOWN) {
            do {
                menu->whichmenu++;
                if (menu->whichmenu >= NumEntries)
                    menu->whichmenu = 0;
            } while (!SELECTABLE(menu->entry[menu->whichmenu]));
        }
    }

    if (menu->whichmenu >= 0)
        return menu->entry[menu->whichmenu].retval;
    else
        return 0;
}

/*
 * Credit and help menus
 */

MenuEntry creditentry[] = {
    { "Text drawing code by Andreas Binner", -1 },
    { "Sky effect by Jeff Minter", -1},
    { "Mandelbrot by Ken Rose", -1},
    { "Raytrace code and general tweaking", -1},
    { "by Eric Smith", -1},
    { "", -1},
    { "Cool hardware by Richard, Louis, John", -1},
    { "and the rest of the VM Labs", -1},
    { "hardware team", -1},
    { "", -1},
    { "Press A or Enter to return", -1},
    { (char *)0, -1}
};

Menu creditmenu = {
    -1,
    &creditentry[0]
};

MenuEntry helpentry[] = {
    { "In all demos, the directional joypad", -1 },
    { "and the A and B buttons move around", -1},
    { "(on the remote control, use", -1},
    { "Enter for A and Exit for B).", -1 },
    { "", -1},
    { "Start (or Play on the remote)", -1},
    { "will get you back to the main menu.", -1},
    { "", -1},
    { "The N or NUON button will toggle", -1},
    { "demo specific help.", -1},
    { "", -1},
    { "Press A or Enter to return", -1},
    { (char *)0, -1}
};

Menu helpmenu = {
    -1,
    &helpentry[0]
};

/* draw the main menu */

#define SHOW_HELP 100
#define SHOW_CREDITS 101

MenuEntry mainentry[] = {
    { "VM Labs Graphics Demos", -1 },
    { "", -1 },
    { "", -1 },
    { "Raytrace 1", 0 },
    { "Raytrace 2", 1 },
    { "Mandelbrot", 2 },
    { "", -1 },
    { "Help", SHOW_HELP },
    { "Credits", SHOW_CREDITS},
    { (char *)0, -1}
};

Menu mainmenu = {
    3,
    &mainentry[0]
};




int 
sky_menu(void)
{
    int i;
    osd_on = 1;

    _VidSync(1);
    CreateChannel(&mainchannel, VIDEO_FULLSCREEN, screen[drawbuf], DMAFLAGS,
                  MAX_SCRN_WIDTH, MAX_SCRN_HEIGHT, VID_HFILTER_4TAP);

    InitTerminalX(0,(long)screen[OSD_SCREEN],
                  osdchannel.dest_width,osdchannel.dest_height,osdchannel.dmaflags,0);

    InitSkyDraw();
    StartSkyDraw(DMAFLAGS, screen[drawbuf]);

    ShowScreen(screen[drawbuf]);
    dispbuf = drawbuf;

    for(;;) {
        i = ShowMenu(&mainmenu);
        if (i == SHOW_HELP) {
            ShowMenu(&helpmenu);
        } else if (i == SHOW_CREDITS) {
            ShowMenu(&creditmenu);
        } else
            break;
    }

    osd_on = 0;
    FinishSkyDraw();

    return i;
}
