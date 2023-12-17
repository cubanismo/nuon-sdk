/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


/*
 * Game Controller defines
 *
 */

/* define the symbol _OLD_JOYSTICK before including this
 * file if you want the old structure definition
 */

#ifndef JOYSTICK_H
#define JOYSTICK_H


#ifdef __cplusplus
extern "C" {
#endif

/////////////////////////////////
// Controller properties values
/////////////////////////////////

#define CTRLR_STDBUTTONS        (0x00000001)
#define CTRLR_DPAD              (0x00000002)
#define CTRLR_SHOULDER          (0x00000004)
#define CTRLR_EXTBUTTONS        (0x00000008)

#define CTRLR_ANALOG1           (0x00000010)
#define CTRLR_ANALOG2           (0x00000020)
#define CTRLR_WHEEL             (0x00000040)
#define CTRLR_PADDLE            (0x00000040)
#define CTRLR_THROTTLEBRAKE     (0x00000080)

#define CTRLR_THROTTLE          (0x00000100)
#define CTRLR_BRAKE             (0x00000200)
#define CTRLR_RUDDER            (0x00000400)
#define CTRLR_TWIST             (0x00000400)
#define CTRLR_MOUSE             (0x00000800)

#define CTRLR_TRACKBALL         (0x00000800)

#define CTRLR_QUADSPINNER1      (0x00001000)
#define CTRLR_QUADSPINNER2      (0x00002000)
#define CTRLR_THUMBWHEEL1       (0x00004000)
#define CTRLR_THUMBWHEEL2       (0x00008000)

#define CTRLR_FISHINGREEL       (0x00010000)
#define CTRLR_QUADJOY1          (0x00020000)
#define CTRLR_GENERIC           (0x00040000)
#define CTRLR_RESERVED          (0x00080000)

#define CTRLR_REMOTE            (0x00100000)
#define CTRLR_EXTENDED          (0x00200000)

/////////////////////////////////////////
// New-style POLYFACE button layout?
/////////////////////////////////////////

#ifndef _NEW_BUTTON_LAYOUT_
#define _NEW_BUTTON_LAYOUT_ 1
#endif

#if _NEW_BUTTON_LAYOUT_

// Bit numbers for buttons
#define CTRLR_BITNUM_DPAD_RIGHT			(8)
#define CTRLR_BITNUM_DPAD_UP			(9)
#define CTRLR_BITNUM_DPAD_LEFT			(10)
#define CTRLR_BITNUM_DPAD_DOWN			(11)
#define CTRLR_BITNUM_BUTTON_A			(14)
#define CTRLR_BITNUM_BUTTON_B			(3)
#define CTRLR_BITNUM_BUTTON_START		(13)
#define CTRLR_BITNUM_BUTTON_NUON		(12)
#define CTRLR_BITNUM_BUTTON_C_DOWN		(15)
#define CTRLR_BITNUM_BUTTON_C_RIGHT		(0)
#define CTRLR_BITNUM_BUTTON_C_LEFT		(2)
#define CTRLR_BITNUM_BUTTON_C_UP		(1)
#define CTRLR_BITNUM_BUTTON_R			(4)
#define CTRLR_BITNUM_BUTTON_L			(5)

#define CTRLR_BITNUM_UNUSED_1			(6)
#define CTRLR_BITNUM_UNUSED_2			(7)

//////////////
#else // if _NEW_BUTTON_LAYOUT_
//////////////

// Bit numbers for buttons
#define	CTRLR_BITNUM_DPAD_RIGHT			(0)
#define	CTRLR_BITNUM_DPAD_UP			(1)
#define	CTRLR_BITNUM_DPAD_LEFT			(2)
#define	CTRLR_BITNUM_DPAD_DOWN			(3)
#define	CTRLR_BITNUM_BUTTON_A			(8)
#define	CTRLR_BITNUM_BUTTON_B			(11)
#define	CTRLR_BITNUM_BUTTON_START		(4)
#define	CTRLR_BITNUM_BUTTON_NUON		(14)
#define	CTRLR_BITNUM_BUTTON_C_DOWN		(9)
#define	CTRLR_BITNUM_BUTTON_C_RIGHT		(10)
#define	CTRLR_BITNUM_BUTTON_C_LEFT		(12)
#define	CTRLR_BITNUM_BUTTON_C_UP		(13)
#define	CTRLR_BITNUM_BUTTON_R			(5)
#define	CTRLR_BITNUM_BUTTON_L			(6)

#define CTRLR_BITNUM_UNUSED_1			(7)
#define CTRLR_BITNUM_UNUSED_2			(15)

#endif

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////
// Bit masks for buttons
//////////////

// CTRLR_DPAD group
#define CTRLR_DPAD_RIGHT        (1<<CTRLR_BITNUM_DPAD_RIGHT)
#define CTRLR_DPAD_UP           (1<<CTRLR_BITNUM_DPAD_UP)
#define CTRLR_DPAD_LEFT         (1<<CTRLR_BITNUM_DPAD_LEFT)
#define CTRLR_DPAD_DOWN         (1<<CTRLR_BITNUM_DPAD_DOWN)


// CTRLR_STDBUTTONS group
#define CTRLR_BUTTON_A          (1<<CTRLR_BITNUM_BUTTON_A)
#define CTRLR_BUTTON_B          (1<<CTRLR_BITNUM_BUTTON_B)
#define CTRLR_BUTTON_START      (1<<CTRLR_BITNUM_BUTTON_START)
#define CTRLR_BUTTON_Z          (1<<CTRLR_BITNUM_BUTTON_NUON)	// Don't use CTRLR_BUTTON_Z, use CTRLR_BUTTON_NUON instead
#define CTRLR_BUTTON_NUON       (1<<CTRLR_BITNUM_BUTTON_NUON)

// CTRLR_EXTBUTTONS group
#define CTRLR_BUTTON_C_DOWN     (1<<CTRLR_BITNUM_BUTTON_C_DOWN)
#define CTRLR_BUTTON_C_RIGHT    (1<<CTRLR_BITNUM_BUTTON_C_RIGHT)
#define CTRLR_BUTTON_C_LEFT     (1<<CTRLR_BITNUM_BUTTON_C_LEFT)
#define CTRLR_BUTTON_C_UP       (1<<CTRLR_BITNUM_BUTTON_C_UP)

// CTRLR_SHOULDER group
#define CTRLR_BUTTON_R          (1<<CTRLR_BITNUM_BUTTON_R)
#define CTRLR_BUTTON_L          (1<<CTRLR_BITNUM_BUTTON_L)

// UNUSED group
#define CTRLR_UNUSED_1			(1<<CTRLR_BITNUM_UNUSED_1)
#define CTRLR_UNUSED_2			(1<<CTRLR_BITNUM_UNUSED_2)


// Infrared Keys (max of 32 items)
#define IR_STOP                 (1<<0)
#define IR_SETUP                (1<<1)
#define IR_ENTER                (1<<2)
#define IR_RESUME               (1<<3)
#define IR_DISPLAY              (1<<4)
#define IR_MENU                 (1<<5)
#define IR_TOP                  (1<<6)
#define IR_ANGLE                (1<<7)
#define IR_SUBTITLE             (1<<8)
#define IR_AUDIO                (1<<9)
#define IR_ZOOM                 (1<<10)
#define IR_VOLUME               (1<<11)
#define IR_SKIP_NEXT            (1<<12)
#define IR_SKIP_PREV            (1<<13)
#define IR_FF                   (1<<14)
#define IR_FR                   (1<<15)
#define IR_SF                   (1<<16)
#define IR_SR                   (1<<17)
#define IR_CLEAR                (1<<18)
#define IR_KEY_0                (1<<19)
#define IR_KEY_1                (1<<20)
#define IR_KEY_2                (1<<21)
#define IR_KEY_3                (1<<22)
#define IR_KEY_4                (1<<23)
#define IR_KEY_5                (1<<24)
#define IR_KEY_6                (1<<25)
#define IR_KEY_7                (1<<26)
#define IR_KEY_8                (1<<27)
#define IR_KEY_9                (1<<28)
#define IR_EJECT                (1<<29)
#define IR_NUON                 (1<<30)
#define IR_POWER_OFF            (unsigned long)(1<<31)


//////////////
// Old-style Bit masks for buttons
//////////////

#define JOY_RIGHT       CTRLR_DPAD_RIGHT
#define JOY_UP          CTRLR_DPAD_UP
#define JOY_LEFT        CTRLR_DPAD_LEFT
#define JOY_DOWN        CTRLR_DPAD_DOWN

#define JOY_START       CTRLR_BUTTON_START
#define JOY_Z           CTRLR_BUTTON_NUON	// Don't use JOY_Z, use JOY_NUON instead
#define JOY_NUON        CTRLR_BUTTON_NUON

#define JOY_A           CTRLR_BUTTON_A
#define JOY_B           CTRLR_BUTTON_B
#define JOY_C_DOWN      CTRLR_BUTTON_C_DOWN
#define JOY_C_RIGHT     CTRLR_BUTTON_C_RIGHT
#define JOY_C_LEFT      CTRLR_BUTTON_C_LEFT
#define JOY_C_UP        CTRLR_BUTTON_C_UP

#define JOY_R           CTRLR_BUTTON_R
#define JOY_L           CTRLR_BUTTON_L


/* defines for buttons C-F */
#define CTRLR_BUTTON_C CTRLR_BUTTON_C_DOWN
#define CTRLR_BUTTON_D CTRLR_BUTTON_C_LEFT
#define CTRLR_BUTTON_E CTRLR_BUTTON_C_RIGHT
#define CTRLR_BUTTON_F CTRLR_BUTTON_C_UP

#define JOY_C CTRLR_BUTTON_C
#define JOY_D CTRLR_BUTTON_D
#define JOY_E CTRLR_BUTTON_E
#define JOY_F CTRLR_BUTTON_F


#ifdef _OLD_JOYSTICK

////////////////////////////////////////////////////////////////////////////
// Old-style Controller Data Structure
////////////////////////////////////////////////////////////////////////////

typedef volatile struct
{
// scalar 0
   unsigned int         changed : 1;
   unsigned int         status : 1;
   unsigned long        manufacture_id : 10;
   unsigned long        properties : 20;
// scalar 1
   unsigned short       buttonset;
     signed char        xAxis;
     signed char        yAxis;
// scalar 2
   unsigned char        throttle;
   unsigned char        brake;
     signed char        d1;
     signed char        d2;
// scalar 3
   unsigned long        extra_buttons;
} ControllerData;

////////////////////////////////////////////////////////////////////////////
// Old-style Macros for button testing.
// For example:  button_a_pressed = ButtonA(joydata[stick]);
////////////////////////////////////////////////////////////////////////////

// Masks off unused button positions & returns remaining button bits
#define Buttons(a) (a.buttonset & ~(CTRLR_UNUSED_1|CTRLR_UNUSED_2))

#define ButtonA(a) (a.buttonset & JOY_A)
#define ButtonB(a) (a.buttonset & JOY_B)
#define ButtonZ(a) (a.buttonset & JOY_Z)

#define ButtonR(a) (a.buttonset & JOY_R)
#define ButtonL(a) (a.buttonset & JOY_L)
#define ButtonStart(a) (a.buttonset & JOY_START)

#define ButtonUp(a) (a.buttonset & JOY_UP)
#define ButtonDown(a) (a.buttonset & JOY_DOWN)
#define ButtonLeft(a) (a.buttonset & JOY_LEFT)
#define ButtonRight(a) (a.buttonset & JOY_RIGHT)

#define ButtonCUp(a) (a.buttonset & JOY_C_UP)
#define ButtonCDown(a) (a.buttonset & JOY_C_DOWN)
#define ButtonCLeft(a) (a.buttonset & JOY_C_LEFT)
#define ButtonCRight(a) (a.buttonset & JOY_C_RIGHT)

#else /* _OLD_JOYSTICK */

////////////////////////////////////////////////////////////////////////////
// Controller Data Structure
////////////////////////////////////////////////////////////////////////////

typedef volatile struct
{
// scalar 0
        unsigned int            changed : 1;
        unsigned int            status : 1;
        unsigned long           manufacture_id : 8;
        unsigned long           properties : 22;

// scalar 1
        unsigned short          buttons;

        union __attribute__ ((packed))
        {
                signed char     xAxis;
                signed char     wheel;
                signed char     paddle;
                signed char     rodX;
        } d1;

        union __attribute__ ((packed))
        {
                signed char     yAxis;
                signed char     rodY;

        } d2;

// scalar 2
        union __attribute__ ((packed))
        {
                signed char     xAxis2;
                unsigned char   throttle;
                signed char     throttle_brake;
        } d3;

        union __attribute__ ((packed))
        {
                unsigned char   yAxis2;
                unsigned char   brake;
                signed char     rudder;
                signed char     twist;
        } d4;

        union __attribute__ ((packed))
        {
                signed char     quadjoyX;
                signed char     mouseX;
                signed char     thumbwheel1;
                signed char     spinner1;
                signed char     reelY;
        } d5;

        union __attribute__ ((packed))
        {
                signed char     quadjoyY;
                signed char     mouseY;
                signed char     thumbwheel2;
                signed char     spinner2;
        } d6;

// scalar 3
        unsigned long   remote_buttons;

} ControllerData;

////////////////////////////////////////////////////////////////////////////
// Macros for button testing.
// For example:  button_a_pressed = ButtonA(joydata[stick]);
////////////////////////////////////////////////////////////////////////////

// Masks off unused button positions & returns remaining button bits
#define Buttons(a) (a.buttons & ~(CTRLR_UNUSED_1|CTRLR_UNUSED_2))

#define ButtonA(a) (a.buttons & CTRLR_BUTTON_A)
#define ButtonB(a) (a.buttons & CTRLR_BUTTON_B)

#define ButtonZ(a) (a.buttons & CTRLR_BUTTON_Z)

#define ButtonR(a) (a.buttons & CTRLR_BUTTON_R)
#define ButtonL(a) (a.buttons & CTRLR_BUTTON_L)
#define ButtonStart(a) (a.buttons & CTRLR_BUTTON_START)

#define ButtonUp(a) (a.buttons & CTRLR_DPAD_UP)
#define ButtonDown(a) (a.buttons & CTRLR_DPAD_DOWN)
#define ButtonLeft(a) (a.buttons & CTRLR_DPAD_LEFT)
#define ButtonRight(a) (a.buttons & CTRLR_DPAD_RIGHT)

#define ButtonCUp(a) (a.buttons & CTRLR_BUTTON_C_UP)
#define ButtonCDown(a) (a.buttons & CTRLR_BUTTON_C_DOWN)
#define ButtonCLeft(a) (a.buttons & CTRLR_BUTTON_C_LEFT)
#define ButtonCRight(a) (a.buttons & CTRLR_BUTTON_C_RIGHT)

#define Joystick_Reset(a) (((a.buttons & \
                (CTRLR_BUTTON_START|CTRLR_BUTTON_L|CTRLR_BUTTON_R)) == \
                (CTRLR_BUTTON_START|CTRLR_BUTTON_L|CTRLR_BUTTON_R)) && \
                ((a.buttons & \
                ~(CTRLR_BUTTON_START|CTRLR_BUTTON_L|CTRLR_BUTTON_R)) == 0))



////////////////////////////////////////////////////////////////////////////
// Macros for analog and quadrature information
// For example:  joystick_x = JoyXAxis(_Controller[1]);
////////////////////////////////////////////////////////////////////////////

#define JoyXAxis(a) (a.d1.xAxis)
#define JoyYAxis(a) (a.d2.yAxis)

#define Joy1XAxis(a) (a.d1.xAxis)
#define Joy1YAxis(a) (a.d2.yAxis)

#define Joy2XAxis(a) (a.d3.xAxis)
#define Joy2YAxis(a) (a.d4.yAxis)

#define WheelPos(a) (a.d1.wheel)
#define PaddlePos(a) (a.d1.paddle)

#define FishingRodX(a) (a.d1.rodX)
#define FishingRodY(a) (a.d2.rodY)
#define FishingReel(a) (a.d5.reelY)

#define Throttle(a) (a.d3.throttle)
#define Brake(a) (a.d4.brake)

#define ThrottleBrake(a) (a.d3.throttle_brake)

#define Rudder(a) (a.d4.rudder)
#define Twist(a) (a.d4.twist)

#define QuadJoyXAxis(a) (a.d5.quadjoyX)
#define QuadJoyYAxis(a) (a.d6.quadjoyY)

#define MouseX(a) (a.d5.mouseX)
#define MouseY(a) (a.d6.mouseY)

#define TrackballX(a) (a.d5.mouseX)
#define TrackballY(a) (a.d6.mouseY)

#define Thumbwheel1(a) (a.d5.thumbwheel1)
#define Thumbwheel2(a) (a.d6.thumbwheel2)

#define Spinner1(a) (a.d5.spinner1)
#define Spinner2(a) (a.d6.spinner2)



#endif /* _OLD_JOYSTICK */

////////////////////////////////////////////////////////////////////////////
// Returns pointer to the BIOS copy of the controller data buffer
////////////////////////////////////////////////////////////////////////////

int _DeviceDetect(int slot);

ControllerData *_ControllerInitialize(void);
void *_ControllerExtendedInfo(int slot);

/* NOTE: the ControllerData struct is already marked as volatile */
extern ControllerData *_Controller;

#ifdef __cplusplus
}
#endif

#endif
