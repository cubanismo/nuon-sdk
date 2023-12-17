/*
 * Graphics demo main routine
 *
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <nuon/bios.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>
#include <nuon/sdram.h>
#include <nuon/msprintf.h>
#include "demo.h"

extern void kprintf(const char *, ...);

#ifndef MPE_ANY
#define MPE_ANY 0
#endif

/*
 * SCREEN SETUP
 */
#include "ray/raydefs.h"
#include "mandel/mandel.h"

VidDisplay display;
VidChannel mainchannel, osdchannel;
int osd_on;

/*
 * set up a video channel
 */
void
CreateChannel(VidChannel *chan, int how, void *screen, long dmaflags,
              int srcwide, int srchigh, int filter)
{
    int destwide, desthigh;
    VidDisplay disp;

    /* provide defaults */
    _VidQueryConfig(&disp);
    if (srcwide == 352 || srcwide == 704)
        destwide = 704;
    else {
        destwide = disp.dispwidth;
    }
    desthigh = disp.dispheight;

    switch(how) {
    case VIDEO_FULLSCREEN:
    default:
        /* use default width & height */
        break;
    case VIDEO_LETTERBOX:
        /* use default width, with letterbox height */
        desthigh = 360;
        break;
    case VIDEO_ONE_TO_ONE:
        desthigh = srchigh;
        destwide = srcwide;
        break;
    case VIDEO_DOUBLE:
        desthigh = 2*srchigh;
        destwide = 2*srcwide;
        break;
    }

    memset(chan, sizeof(*chan), 0);
    chan->dmaflags = dmaflags;
    chan->base = screen;
    chan->dest_xoff = chan->dest_yoff = -1;
    chan->dest_width = destwide;
    chan->dest_height = desthigh;
    chan->src_xoff = chan->src_yoff = 0;
    chan->src_width = srcwide;
    chan->src_height = srchigh;
    chan->vfilter = VID_VFILTER_2TAP;
    chan->hfilter = filter;
}

/*
 * show the main channel, and (if osd_on is set) the overlay channel
 * "base" is the new screen for the main channel
 */
void
ShowScreen(void *base)
{
    mainchannel.base = base;
    if (osd_on) {
        _VidConfig(&display, &mainchannel, &osdchannel, 0);
    } else {
        _VidConfig(&display, &mainchannel, 0, 0);
    }
}

/*
 * erase the screen by drawing 8x8 rectangle blocks; not perfectly efficient,
 * but pretty good
 * NOTE: assumes that the screen height and width are multiples of 8!
 * Also assumes that the screen uses the "standard" DMAFLAGS from demo.h.
 */

void
FillScreen(void *screen, long color)
{
    long x, y;

    for (x = 0; x < MAX_SCRN_WIDTH; x += 8) {
	for (y = 0; y < MAX_SCRN_HEIGHT; y += 8) {
	    _raw_plotpixel(DMAFLAGS, screen, (8<<16)|x, (8<<16)|y, color);
	}
    }
}

/* triple buffered screen, plus an extra for overlays */
void *screen[4];
int drawbuf, dispbuf;



/* code and data for the ray trace programs */
extern int ray2c_start[], ray2c_size[], ray2d_start[], ray2d_size[];
extern int rayc_start[], rayc_size[], rayd_start[], rayd_size[];
extern int mandelc_start[], mandelc_size[], mandeld_start[], mandeld_size[];

int ray_mpe[MAX_MPES];
int num_mpes;

#define MAX_OBJECT 2

unsigned short lastbuttons = 0;
unsigned long lastremote = 0;

/* info for frames per second */
static unsigned long lasttime;

/*
 * Help screens for the demos
 */
MenuEntry waterhelp[] = {
/*  { "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", -1 } */
    { "Use the direction pad to move the", -1 },
    { "shiny ball around. Use A (Enter on", -1},
    { "the remote control) to move it down", -1},
    { "and B (Exit on the remote) to move", -1 },
    { "it up. Press Start or Play to get", -1},
    { "back to the main menu.", -1},
    { (char *)0, -1}
};

Menu watermenu = { -1, waterhelp };

MenuEntry boxhelp[] = {
/*  { "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", -1 } */
    { "Use the direction pad to move the", -1 },
    { "selected object around. Use A (Enter", -1},
    { "on the remote) to move it down,", -1},
    { "B (Exit on the remote) to move it up", -1 },
    { "", -1},
    { "The glowing white ball is initially", -1 },
    { "selected to move. To change this,", -1},
    { "use the L and R buttons on top of", -1},
    { "the joystick, or chapter forward", -1},
    { "and back on the remote. These will", -1},
    { "cycle among the light, shiny ball,", -1},
    { "and box with the logo.", -1},
    { (char *)0, -1}
};

Menu boxmenu = { -1, boxhelp };

/*
 * Run a ray trace program
 */

int
runraytrace(int which)
{
    int i;
    unsigned short buttons, joyedge;
    unsigned long remote, remedge;
    int xval, yval;
    long joystick;
    /* which object is moving */
    int object = 0;
    Menu *helpmenu;

    /* set up the correct help screen, and start up the ray trace MPEs */
    ClearMenu();
    if (which == 1) {
        helpmenu = &boxmenu;
        for (i = 0; i < num_mpes; i++) {
            StartMPE(ray_mpe[i], ray2c_start, (long)ray2c_size,
                     ray2d_start, (long)ray2d_size);
        }
    } else {
        helpmenu = &watermenu;
        for (i = 0; i < num_mpes; i++) {
            StartMPE(ray_mpe[i], rayc_start, (long)rayc_size,
                     rayd_start, (long)rayd_size);
        }
    }

    /* configure main channel for ray trace */
    CreateChannel(&mainchannel, VIDEO_FULLSCREEN, screen[dispbuf], DMAFLAGS,
                  SCRNWIDTH, SCRNHEIGHT, VID_HFILTER_4TAP);

    for(;;) {
        /* compute joystick data */
        /* first, or together remote, joystick 1, and joystick 2 states */
        buttons = _Controller[0].buttons | _Controller[1].buttons | _Controller[5].buttons;
        remote = _Controller[0].remote_buttons;

        /* check for exit button */
        joyedge = (buttons ^ lastbuttons) & buttons;
        remedge = (remote ^ lastremote) & remote;
        lastbuttons = buttons;
        lastremote = remote;

        /* break on either joystick START button or some IR menu buttons */
        if (joyedge & CTRLR_BUTTON_START)
            break;
        if (remedge & (IR_MENU|IR_TOP))
            break;

        /* toggle help menu based on NUON button */
        if ((joyedge & CTRLR_BUTTON_NUON) || (remedge & IR_NUON)) {
            DrawMenu(helpmenu);
            osd_on = !osd_on;
        }

        /* mask off bits 4-7 (those will be used for the object number) */
        buttons &= ~(CTRLR_BUTTON_L|CTRLR_BUTTON_R|CTRLR_UNUSED_1|CTRLR_UNUSED_2);
        /* also mask off the START button */
        buttons &= ~CTRLR_BUTTON_START;

        /* left and right shoulders on the joystick, or chapter back
           and forward on the remote, change the object number */
        if ((joyedge & CTRLR_BUTTON_L) || 
            (remedge & (IR_SKIP_PREV | IR_FR))) {
            object--;
            if (object < 0) object = MAX_OBJECT;
        } else if ((joyedge & CTRLR_BUTTON_R) || 
                 (remedge & (IR_SKIP_NEXT | IR_FF))) {
            object++;
            if (object > MAX_OBJECT)
                object = 0;
        }

        /* now send the object number in bits 4-7 */
        buttons |= (object << 4);

        /* now do the analog joystick */
        xval = JoyXAxis(_Controller[1]);
        if (xval > -12 && xval < 12) xval = 0;
        yval = JoyYAxis(_Controller[1]);
        if (yval > -12 && yval < 12) yval = 0;

        /* simulate the analog joystick with the DPAD */
        if (buttons & CTRLR_DPAD_LEFT)
            xval = -64;
        else if (buttons & CTRLR_DPAD_RIGHT)
            xval = 64;
        if (buttons & CTRLR_DPAD_UP)
            yval = 64;
        else if (buttons & CTRLR_DPAD_DOWN)
            yval = -64;

        joystick = (buttons << 16) | ((xval & 0xff)<<8) | (yval & 0xff);

        /* send synchronization packet to MPEs */
        /* the packet format is:
           first scalar: screen base
           second scalar: screen DMA flags
           third scalar: MPE info: high word = total MPEs, low = this MPE
           fourth scalar: joystick data
        */

        for (i = 0; i < num_mpes; i++) {
            _CommSendDirect((long)screen[drawbuf], DMAFLAGS, (num_mpes<<16)|i, joystick,
                            ray_mpe[i], 0);
        }

        /* make sure the last _VidSetup has happened */
        _VidSync(0);

        /* once all packets have been sent, we know that the previous
           screen has finished drawing; so display it now */
//        _VidSetup(screen[dispbuf], DMAFLAGS, SCRNWIDTH, SCRNHEIGHT, 2);
        ShowScreen(screen[dispbuf]);
        /* move to next screen */
        dispbuf = drawbuf;
        drawbuf++;
        if (drawbuf > 2) drawbuf = 0;
    }

    /* stop the ray trace MPEs */
    for (i = 0; i < num_mpes; i++) {
        StopMPE(ray_mpe[i]);
    }

    return 0;
}

MenuEntry mandelhelp[] = {
/*  { "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", -1 } */
    { "Use the direction pad to move up,", -1 },
    { "down, left, and right. Use A (Enter", -1},
    { "on the remote control) to zoom in,", -1},
    { "and B (Exit on the remote) to zoom", -1 },
    { "out. Press Start or Play to get", -1},
    { "back to the main menu.", -1},
    { (char *)0, -1}
};

Menu mandelmenu = { -1, mandelhelp };

int
runmandel(void)
{
    unsigned short buttons, joyedge;
    unsigned long remote, remedge;
    unsigned long joystick;
    int i;
    int debug;
    unsigned long thistime;
    unsigned long thisfield, lastfield, speed;  /* used for joystick control */
    int frames, fps;
    int xval, yval;

    debug = 0;
    fps = 30;

    /* set up to display help */
    ClearMenu();

    /* configure main channel for mandelbrots */
#ifdef MANDEL_LETTERBOX
    CreateChannel(&mainchannel, VIDEO_LETTERBOX, screen[dispbuf], DMAFLAGS,
                  MANDEL_WIDTH, MANDEL_HEIGHT, VID_HFILTER_4TAP);
#else
    CreateChannel(&mainchannel, VIDEO_FULLSCREEN, screen[dispbuf], DMAFLAGS,
                  MANDEL_WIDTH, MANDEL_HEIGHT, VID_HFILTER_4TAP);
#endif

    /* start up the mandelbrot MPEs */
    for (i = 0; i < num_mpes; i++) {
        StartMPE(ray_mpe[i], mandelc_start, (long)mandelc_size,
                 mandeld_start, (long)mandeld_size);
    }

    /* find which field we're on */
    lasttime = _TimeElapsed(0,0);

    /* set up some defaults for the rendering speed */
    thisfield = _VidSync(-1);
    lastfield = thisfield-1;

    frames = 0;

    for(;;) {
        /* compute joystick data */
        /* first, or together remote, joystick 1, and joystick 2 states */
        buttons = _Controller[0].buttons | _Controller[1].buttons | _Controller[5].buttons;
        remote = _Controller[0].remote_buttons;

        /* check for exit button */
        joyedge = (buttons ^ lastbuttons) & buttons;
        remedge = (remote ^ lastremote) & remote;
        lastbuttons = buttons;
        lastremote = remote;

        /* break on either joystick START button or some IR menu buttons */
        if (joyedge & CTRLR_BUTTON_START) {
            /* if the C down button is down, too, just toggle debugging */
            if (buttons & CTRLR_BUTTON_C_DOWN) {
                debug = !debug;
                joyedge = 0;
            } else {
                /* otherwise break out of the loop */
                break;
            }
        }
        if (remedge & (IR_MENU|IR_TOP))
            break;

        /* toggle help menu based on NUON button */
        if ((joyedge & CTRLR_BUTTON_NUON) || (remedge & IR_NUON)) {
            DrawMenu(&mandelmenu);
            osd_on = !osd_on;
        }

        /* mask off bits 4-7 (those will be used for the field rate) */
        buttons &= ~(CTRLR_BUTTON_L|CTRLR_BUTTON_R|CTRLR_UNUSED_1|CTRLR_UNUSED_2);
        /* also mask off the START button */
        buttons &= ~CTRLR_BUTTON_START;

        /* stick the number of fields elapsed since the last frame into
           bits 4-7 of the buttons; these will be used by the mandelbrot
           program to scale the speed of movement */
        speed = thisfield - lastfield;
        lastfield = thisfield;
        if (speed > 15) speed = 15;
        buttons |= (speed << 4);

        /* now do the analog joystick */
        xval = JoyXAxis(_Controller[1]);
        if (xval > -12 && xval < 12) xval = 0;
        yval = JoyYAxis(_Controller[1]);
        if (yval > -12 && yval < 12) yval = 0;

        /* simulate the analog joystick with the DPAD */
        if (buttons & CTRLR_DPAD_LEFT)
            xval = -64;
        else if (buttons & CTRLR_DPAD_RIGHT)
            xval = 64;
        if (buttons & CTRLR_DPAD_UP)
            yval = 64;
        else if (buttons & CTRLR_DPAD_DOWN)
            yval = -64;

        joystick = (buttons << 16) | ((xval & 0xff)<<8) | (yval & 0xff);


        /* send info to rendering MPEs */
        for (i = 0; i < num_mpes; i++) {
            _CommSendDirect((long)screen[drawbuf], DMAFLAGS, (num_mpes<<16)|i, joystick,
                            ray_mpe[i], 0);
        }

        /* make sure the last _VidSetup has happened */
        thisfield = _VidSync(0);
        frames++;

        /* if more than 1000 milliseconds have elapsed, update the
           frames per second */
        thistime = _TimeElapsed(0,0);
        if (thistime - lasttime > 1000) {
            lasttime = thistime;
            fps = frames;
            frames = 0;
        }

        /* once all packets have been sent, we know that the previous
           screen has finished drawing; so display it now */
        if (debug) {
            char buf[128];
            msprintf(buf, "%3d fps", fps);
            DebugWS(DMAFLAGS, screen[dispbuf], 32, 32, FGCOLOR, buf);
        }

//        _VidSetup(screen[dispbuf], DMAFLAGS, MANDEL_WIDTH, MANDEL_HEIGHT, 2);
        ShowScreen(screen[dispbuf]);
        /* move to next screen */
        dispbuf = drawbuf;
        drawbuf++;
        if (drawbuf > 2) drawbuf = 0;
    }

    /* stop the ray trace MPEs */
    for (i = 0; i < num_mpes; i++) {
        StopMPE(ray_mpe[i]);
    }

    return 0;
}

/*
 * wait for all buttons on joysticks to go up
 */
static void
clearbuttons(void)
{
    do {
        lastbuttons = _Controller[0].buttons | _Controller[1].buttons | _Controller[5].buttons;
        /* mask off bits 4-7 (those will be used for the object number) */
        lastbuttons &= ~(CTRLR_BUTTON_L|CTRLR_BUTTON_R|CTRLR_UNUSED_1|CTRLR_UNUSED_2);

        lastremote = _Controller[0].remote_buttons;
    } while (lastbuttons | lastremote);
}

int
main()
{
    int i;

//    _CompatibilityMode(1); // for high speed action on Aries 3

    /* allocate memory for screens */
    for (i = 0; i < 4; i++) {
        screen[i] = SDRAMAlloc(MAX_SCRN_WIDTH*MAX_SCRN_HEIGHT*4);
        FillScreen(screen[i], BGCOLOR);
    }
    /* initialize video */
    _VidQueryConfig(&display);
    CreateChannel(&mainchannel, VIDEO_FULLSCREEN, screen[0], DMAFLAGS, MAX_SCRN_WIDTH, MAX_SCRN_HEIGHT, VID_HFILTER_4TAP);
    CreateChannel(&osdchannel, VIDEO_DOUBLE, screen[3], DMAFLAGS, MAX_SCRN_WIDTH, MAX_SCRN_HEIGHT, VID_HFILTER_NONE);

    FillScreen(screen[OSD_SCREEN], 0x00000000);
    osd_on = 1;
    ShowScreen(screen[0]);


    /* allocate MPEs */
    _MediaShutdownMPE(); /* release audio & drive CD for our use */
    num_mpes = 0;
    for (i = 0; i < MAX_MPES; i++) {
        ray_mpe[i] = _MPEAlloc(MPE_ANY);
        if (ray_mpe[i] < 0) break;
        num_mpes++;
    }

    for(;;) {
        i = sky_menu();
        clearbuttons();

        switch(i) {
        case 0:
            runraytrace(0);
            break;
        case 1:
            runraytrace(1);
            break;
        case 2:
            runmandel();
            break;
        }
    }
    return 0;
}

