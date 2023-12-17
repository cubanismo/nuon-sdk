/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


#ifndef __SYSEVENT_H__
#define __SYSEVENT_H__

#ifndef NUON_SCRIPT

/* event object structure */
typedef struct NuiEventObject  NuiEventObject;
struct NuiEventObject {
    long    objectSize;
    long    timeStamp;
    long    classId;
    long    eventId;
    long    keyCode;
    long    eventParam[2];
};

/* state object structure */
typedef struct NuiStateObject  NuiStateObject;
struct NuiStateObject {
    long        size;               // size of the state object structure
    ulong       version;
    ulong       trayState;          // tray state
    ulong       discType;           // disc type
    ulong       playSpeed;          // player speed
    union {
        ulong   album;              // album number for MP3
        ulong   title;              // title number for DVD
    } albumTitle;
    union {
        ulong   track;              // track number for VCD, CD or MP3
        ulong   chapter;            // chapter number for DVD
    } trackChapter;
    ulong       zoomState;          // bit 17:      1 - zoom mode on
                                    // bit 16:      1 - pan mode on
                                    // bit 15-0:    zoom scale
    ulong       domainState;        // bit 0: 1 - Menu domain
    ulong       menuState;          // bit 0: 1 - Menu is up
};

#endif // NUON_SCRIPT


#define STATE_OBJECT_VERSION        0x01000000      // Version 1.0.0.0

/* event class definitions */

/******************************************************************************
 * Event Class Base: Control
 *
 * [HAL]
 * Generated as result of user interaction (IR key presses, translated joystick
 * presses)
 *
 * [Player, UI]
 * Used for controling application (player) and associated UI
 ******************************************************************************/
#define EVENT_CLASS_BASE_CONTROL                0x0000
//                                            - 0x00ff

#define EVENT_CLASS_PLAYERCONTROL                 0x05 + EVENT_CLASS_BASE_CONTROL
#define EVENT_CLASS_MENUCONTROL                   0x08 + EVENT_CLASS_BASE_CONTROL
#define EVENT_CLASS_SPECIALCONTROL                0x0b + EVENT_CLASS_BASE_CONTROL
#define EVENT_CLASS_CUSTOMCONTROL                 0x0e + EVENT_CLASS_BASE_CONTROL


/******************************************************************************
 * Event Class Base: Control Changing
 *
 * [Player, Nav, PE]
 * Generated prior to an anticipated state transition, usually as a result of
 * processing a Control event
 *
 * [Player, UI]
 * Used by application to prepare for state transition and/or give feedback to
 * user that Control event is being processed
 ******************************************************************************/
#define EVENT_CLASS_BASE_CONTROL_CHANGING       0x0100
//                                            - 0x01ff

#define EVENT_CLASS_PLAYERCONTROL_CHANGING        0x05 + EVENT_CLASS_BASE_CONTROL_CHANGING
#define EVENT_CLASS_MENUCONTROL_CHANGING          0x08 + EVENT_CLASS_BASE_CONTROL_CHANGING
#define EVENT_CLASS_SPECIALCONTROL_CHANGING       0x0b + EVENT_CLASS_BASE_CONTROL_CHANGING
#define EVENT_CLASS_CUSTOMCONTROL_CHANGING        0x0e + EVENT_CLASS_BASE_CONTROL_CHANGING


/******************************************************************************
 * Event Class Base: Control Changed
 *
 * [Player, Nav, PE, HAL]
 * Generated after state transition occurs, can be a direct result of
 * processing a Control event or during normal playback
 *
 * [Player, UI]
 * Used by application to update current status information
 ******************************************************************************/
#define EVENT_CLASS_BASE_CONTROL_CHANGED        0x0200
//                                            - 0x02ff

#define EVENT_CLASS_PLAYERCONTROL_CHANGED         0x05 + EVENT_CLASS_BASE_CONTROL_CHANGED
#define EVENT_CLASS_MENUCONTROL_CHANGED           0x08 + EVENT_CLASS_BASE_CONTROL_CHANGED
#define EVENT_CLASS_SPECIALCONTROL_CHANGED        0x0b + EVENT_CLASS_BASE_CONTROL_CHANGED
#define EVENT_CLASS_CUSTOMCONTROL_CHANGED         0x0e + EVENT_CLASS_BASE_CONTROL_CHANGED


/******************************************************************************
 * Event Class Base: Nav
 *
 * [Player, Nav]
 * Generated to indicate navigational transitions or events
 *
 * [Player, UI]
 *
 ******************************************************************************/
#define EVENT_CLASS_BASE_NAV                    0x0300
//                                            - 0x03ff

#define EVENT_CLASS_NAV_DVD                       0x01 + EVENT_CLASS_BASE_NAV
#define EVENT_CLASS_NAV_DVDA                      0x02 + EVENT_CLASS_BASE_NAV
#define EVENT_CLASS_NAV_VCD                       0x03 + EVENT_CLASS_BASE_NAV
#define EVENT_CLASS_NAV_MP3                       0x04 + EVENT_CLASS_BASE_NAV
#define EVENT_CLASS_NAV_CDA                       0x05 + EVENT_CLASS_BASE_NAV


/******************************************************************************
 * Event Class Base: Nav
 *
 * [Player]
 * Generated to indicate player transitions or events
 *
 * [Player, UI]
 *
 ******************************************************************************/
#define EVENT_CLASS_BASE_PLAYER                 0x0400
//                                            - 0x04ff

#define EVENT_CLASS_DIRECTORSCRIPT                0x01 + EVENT_CLASS_BASE_PLAYER
#define EVENT_CLASS_UI                            0x02 + EVENT_CLASS_BASE_PLAYER
#define EVENT_CLASS_WINDOW                        0x03 + EVENT_CLASS_BASE_PLAYER
#define EVENT_CLASS_WIDGET                        0x04 + EVENT_CLASS_BASE_PLAYER

//#define EVENT_CLASS_CONTROL                     0
//#define EVENT_CLASS_DVD_NAV                     1
//#define EVENT_CLASS_APP                         2

#endif // __SYSEVENT_H__
