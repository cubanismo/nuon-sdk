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

#ifndef hsString_DEFINED
#define hsString_DEFINED

#include "hsTypes.h"

#if HS_BUILD_FOR_PALM
	extern int hsStrlen(const char s[]);
	extern int hsStrcmp(const char s[], const char t[]);
	extern char* hsStrcpy(char dst[], const char src[]);
	extern void hsStrcat(char dst[], const char src[]);
#else
	#include <string.h>

	#define hsStrlen(str)			strlen(str)
	#define hsStrcmp(s1, s2)		strcmp(s1, s2)
	#define hsStrcpy(dst, src)		strcpy(dst, src)
	#define hsStrcat(dst, src)		strcat(dst, src)
#endif

#if HS_BUILD_FOR_UNIX
	#define hsStrcasecmp(s1, s2)		strcasecmp(s1, s2)
	#define hsStrncasecmp(s1, s2, n)	strncasecmp(s1, s2, n)
#else
	int	hsStrcasecmp(const char s1[], const char s2[]);
	int	hsStrncasecmp(const char s1[], const char s2[], int n);
#endif

#define hsStrEQ(s1, s2)			(hsStrcmp(s1, s2) == 0)

char*	hsStrdup(const char str[]);

/*	A pstring has a length byte at the beginning, and no trailing 0 */

char*			hsP2CString(const unsigned char pstring[], char cstring[]);
unsigned char*	hsC2PString(const char cstring[], unsigned char pstring[]);

#endif
