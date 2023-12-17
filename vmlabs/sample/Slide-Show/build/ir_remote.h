/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#ifndef IR_REMOTE_H
#define IR_REMOTE_H

#include <nuon/bios.h>

typedef struct {
    long buttons;
    unsigned long remote_buttons;
} JustOnButtons;

// prototypes
void InitRemote(void);
void GainKeyControl(unsigned long keybits);
JustOnButtons GetButtons(void);
int NumeralKey(JustOnButtons J, int *n);

// button macros
#define StopKey(J)      (J.remote_buttons & IR_STOP)
#define PlayKey(J)      (J.buttons & JOY_START)
#define RightKey(J)     (J.buttons & JOY_RIGHT)
#define LeftKey(J)      (J.buttons & JOY_LEFT)
#define UpKey(J)        (J.buttons & JOY_UP)
#define DownKey(J)      (J.buttons & JOY_DOWN)
#define EnterKey(J)     (J.remote_buttons & IR_ENTER)
#define NextKey(J)      (J.remote_buttons & IR_SKIP_NEXT)
#define PrevKey(J)      (J.remote_buttons & IR_SKIP_PREV)


#endif

