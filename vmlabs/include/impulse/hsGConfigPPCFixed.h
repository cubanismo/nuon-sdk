/*
 * Copyright (C) 1999 all rights reserved by AlphaMask, Inc. Cambridge, MA USA
 *
 * This software is the property of AlphaMask, Inc. and it is furnished
 * under a license and may be used and copied only in accordance with the
 * terms of such license and with the inclusion of the above copyright notice.
 * This software or any other copies thereof may not be provided or otherwise
 * made available to any other person or entity except as allowed under license.
 * No title to and ownership of the software or intellectual property
 * therewithin is hereby transferred.
 *
 * ALPHAMASK MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY
 * OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 * TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. ALPHAMASK SHALL NOT BE LIABLE FOR
 * ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR
 * DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 *
 * This information in this software is subject to change without notice
*/

#ifndef hsConfig_DEFINED
#define hsConfig_DEFINED

/*********************************************************************
 *	hsTypes.h derives other defines from this file, including HS_RELEASE
 */

#if !(__profile__)
	#define HS_DEBUGGING
#endif

#define TARGET_API_MAC_CARBON		1
#define HS_BUILD_FOR_MAC_CARBON		1

/*********************************************************************
 *	Define only 1 of these
 */

/*	#define HS_BUILD_FOR_MAC68K		1		*/
	#define HS_BUILD_FOR_MACPPC		1
/*	#define HS_BUILD_FOR_WIN32		1		*/
/*	#define HS_BUILD_FOR_UNIX		1		*/
/*	#define HS_BUILD_FOR_PALM		1		*/


/*********************************************************************
 *	These are the optional feature settings
 */

#define HS_CAN_USE_FLOAT					1
#define HS_SCALAR_IS_FLOAT					0

#define HS_IMPULSE_SUPPORT_DEVICE32			1
#define HS_IMPULSE_SUPPORT_DEVICE16			1
#define HS_IMPULSE_SUPPORT_DEVICE8			1
#define HS_IMPULSE_SUPPORT_GRAY4			0

#define HS_IMPULSE_SUPPORT_BITMAP32			1
#define HS_IMPULSE_SUPPORT_BITMAP8			1

#define HS_IMPULSE_SUPPORT_SQUAREPEN		1

#endif
