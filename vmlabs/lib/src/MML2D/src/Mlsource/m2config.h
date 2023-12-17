

/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


#ifndef mlConfig_h
#define mlConfig_h

/* These macro constants are used when compiling and building the 2d libraries.
 * Their values are determined by the platform that is being built.  Their values
 * should NOT be defined separately.  Only the platform values should be 
 * passed in the makefile.
 */
 
 /* When an APP is built, USE_DISPATCHER must be defined in the makefile,if the
 app is to run on the BB or BBTEST platform.
 */

/* Four platforms are defined */
/* BB - Libraries run on MPE3, App runs on PPC, sends Comm Bus packets to 
 * dispatcher running on MPE3.
 */
#ifdef BB
#define USE_DISPATCHER 1
#define FIXED_FRAMEBUFFER 1
#define DISPATCHER_ID 3
#define TESTHOSTID 0x48
/* BBTEST - Libraries run on MPE3, App runs on MPE0, sends Comm Bus packets to
 * dispatcher running on MPE3.
 */ 
#elif defined BBTEST
#define USE_DISPATCHER 1
#define FIXED_FRAMEBUFFER 1
#define DISPATCHER_ID 3
#define TESTHOSTID 0
/* NATIVE - Libraries run on MPE3, App runs on MPE3, directly calls library functions.
 */ 
#else
#define USE_DISPATCHER 0
#define FIXED_FRAMEBUFFER 0
#define DISPATCHER_ID 0
#define TESTHOSTID 0
#endif

/* Macro Constant Documentation :

USE_DISPATCHER == 1 means even tho the C app and libraries may be running
on same MPE, use the Comm Bus dispatch mechanism.

FIXED_FRAMEBUFFER == 1 means that the framebuffer address passed in parameter
blocks is ignored and a platform specific address is substituted.

DISPATCHER_ID CommBus ID of MPE that is running MRP dispatcher.  Always 3 or unused.

TESTHOSTID is only used in BB and BBTEST platforms.  It is the Comm Bus ID used to
send ACKs back to the Application.

*/

#endif