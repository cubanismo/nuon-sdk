/*
 * CONFIG.H
 * Copyright (C) 1989-1998 all rights reserved by Type Solutions, Inc. Plaistow, NH, USA.
 * Author: Sampo Kaasila
 *
 * This software is the property of Type Solutions, Inc. and it is furnished
 * under a license and may be used and copied only in accordance with the
 * terms of such license and with the inclusion of the above copyright notice.
 * This software or any other copies thereof may not be provided or otherwise
 * made available to any other person or entity except as allowed under license.
 * No title to and ownership of the software or intellectual property
 * therewithin is hereby transferred.
 *
 * This information in this software is subject to change without notice
 */
/***********************************************/
#ifndef __T2K_CONFIG__
#define __T2K_CONFIG__

#ifdef UNUSED
#undef UNUSED
#endif
#define UNUSED(x) x


/**********************************************************************/
/**********************************************************************/
/**********************************************************************/
/**** **** **** BEGIN configuration defines  #1 --- #14  **** **** ****/
/* The T2K client has to define the meaning of these 3 functions */
/*** #1 ***/
#define CLIENT_MALLOC( size )			malloc( size )
/* #define CLIENT_MALLOC( size )			AllocateTaggedMemoryNilAllowed(n,"t2k") */
/*** #2 ***/
#define CLIENT_FREE( ptr )				free( ptr )
/* #define CLIENT_FREE( ptr )				FreeTaggedMemory(p,"t2k") */
/*** #3 ***/
#define CLIENT_REALLOC( ptr, newSize )	realloc( ptr, newSize )
/* #define CLIENT_REALLOC( ptr, newSize )	ReallocateTaggedMemoryNilAllowed(ptr, size, "t2k") */

/*** #4 ***/
/* Here the client can optionally redefine assert, by adding two lines according to the below example  */
/* #undef assert  (line1) */
/* Just leave it for some clients, OR	*/
/* #define assert(cond) 				CLIENT_ASSERT( cond ), OR for a _FINAL_ build _ALWAYS_ define as NULL 	*/
/* #define assert(cond) 				NULL					*/


/*** Start of optional features #5 --- #12 ***/
/* The optional features increase ROM/RAM needs, so only enable them if you are using them */
/*** #5 ***/
/* #define 								ENABLE_LINE_LAYOUT */
#define 								ENABLE_LINE_LAYOUT

/*** #6 ***/
/* #define 								ENABLE_KERNING */
#define 								ENABLE_KERNING

/*** #7 we consume 8 * somesize bytes for the cache ***/
/* #define 								LAYOUT_CACHE_SIZE somesize */
#define 								LAYOUT_CACHE_SIZE 149

/*** #8 ***/
/* #define 								ALGORITHMIC_STYLES */

/*** #9 Always enable if you need Type 1 font support ***/
/* #define 								ENABLE_T1 */
#define 								ENABLE_T1

/*** #10 If you have enabled Type 1 support and also need Mac specific Type 1 then also enable this ***/
/* #define 								ENABLE_MAC_T1 */

/*** #11 Always enable if you need CFF font support ***/
/* #define 								ENABLE_CFF */
#define 								ENABLE_CFF

/*** #12 Always enable if you need to be able to read entropy encoded T2K fonts (for compact Kanji fonts) ***/
/* #define 								ENABLE_ORION */
#define 								ENABLE_ORION

/*** #13 enable if you need non RAM/ROM resident fonts. Allows you to leave the fonts on the disk/server etc. ***/
/* #define 								ENABLE_NON_RAM_STREAM */
#define 								ENABLE_NON_RAM_STREAM

/*** #14 enable if you want to use a non-zero winding rule in the scan-converter instead of even-odd fill ***/
/* #define USE_NON_ZERO_WINDING_RULE */
#define USE_NON_ZERO_WINDING_RULE

/*** End of optional features ***/
/**** **** **** END configuration defines  #1 --- #14    **** **** ****/
/* The T2K client is not supposed to change anything else in here beside items #1 -- #14 */
/**********************************************************************/
/**********************************************************************/
/**********************************************************************/


/* Below we just have internal, non-user-configurable stuff */

#define ENABLE_WRITE
#define ENABLE_PRINTF
/* #define SAMPO_TESTING_T2K , should not be defined in a release going out from Type Solutions, Inc. */

/* Only ONE can and has to be defined at a time. They can NEVER be simultaneously defined  */
/* #define ENABLE_AUTO_GRIDDING */
/* #define ENABLE_AUTO_HINTING */
#define ENABLE_AUTO_HINTING

/* #define T2K_SCALER */
#define T2K_SCALER


#ifdef T2K_SCALER
#ifndef ENABLE_AUTO_GRIDDING
#define ENABLE_AUTO_GRIDDING
#endif
#ifdef ENABLE_AUTO_HINTING
#undef ENABLE_AUTO_HINTING
#endif
#ifdef ENABLE_WRITE
#undef ENABLE_WRITE
#endif
#ifdef ENABLE_PRINTF
#undef ENABLE_PRINTF
#endif
#endif /* T2K_SCALER */


#ifdef ENABLE_AUTO_GRIDDING
#undef ENABLE_AUTO_HINTING
#endif

#ifdef SAMPO_TESTING_T2K
#define ENABLE_WRITE
#define ENABLE_PRINTF
#endif /* SAMPO_TESTING_T2K */


#ifdef ENABLE_T1
	#define T1_OR_T2_IS_ENABLED	
#endif

#ifdef ENABLE_CFF
	#ifndef T1_OR_T2_IS_ENABLED
		#define T1_OR_T2_IS_ENABLED
	#endif
#endif


/****      End of configuration defines     ****/
/***********************************************/
#endif /* __T2K_CONFIG__ */

