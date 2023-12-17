/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#include "ir_remote.h"

// perform initialization
void InitRemote(void)
{
    // gain control of some keys
    GainKeyControl(IR_STOP | IR_ENTER | IR_RESUME);
}    

// attempt to gain control of certain keys from the BIOS
void GainKeyControl(unsigned long keybits)
{
    unsigned long mask;

    mask = _BiosIRMask(0, 0);
    _BiosIRMask(1, ~keybits);
}


// return a structure showing which buttons have just been pressed
JustOnButtons GetButtons(void)
{
    JustOnButtons B;
    long buttons, remote_buttons;
    static long old_buttons, old_remote_buttons;

    buttons = _Controller[0].buttons;
    remote_buttons = _Controller[0].remote_buttons;

    B.buttons = (buttons ^ old_buttons) & buttons;
    B.remote_buttons = (remote_buttons ^ old_remote_buttons) & remote_buttons;
    old_buttons = buttons;
    old_remote_buttons = remote_buttons;

    // if any buttons active, wait for them to "go quiet"
    if (buttons || remote_buttons) {
        do {
            buttons = _Controller[0].buttons | _Controller[0].remote_buttons;
        }
        while (buttons);
    }
    return B;
}


// determine if a numeral has been pressed, and if so, which one
int NumeralKey(JustOnButtons J, int *n)
{
    unsigned long test;
    static unsigned long NumMask = IR_KEY_0 | IR_KEY_1 | IR_KEY_2 | IR_KEY_3 | IR_KEY_4 |
                                   IR_KEY_5 | IR_KEY_6 | IR_KEY_7 | IR_KEY_8 | IR_KEY_9;

    test = J.remote_buttons & NumMask;
    if (test) {
        if (n) {
            if (test & IR_KEY_0) *n = 0;
            else if (test & IR_KEY_1) *n = 1;
            else if (test & IR_KEY_2) *n = 2;
            else if (test & IR_KEY_3) *n = 3;
            else if (test & IR_KEY_4) *n = 4;
            else if (test & IR_KEY_5) *n = 5;
            else if (test & IR_KEY_6) *n = 6;
            else if (test & IR_KEY_7) *n = 7;
            else if (test & IR_KEY_8) *n = 8;
            else if (test & IR_KEY_9) *n = 9;
        }
        return 1;
    }
    else
        return 0;
}
        