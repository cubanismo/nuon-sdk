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

#ifndef hsUnicode_Defined
#define hsUnicode_Defined

#include "hsTypes.h"

typedef UInt16 hsUniChar;

class hsUnicode {
public:
	//	These convert Unicode16 into UTF8. They return the number of bytes
	//	needed in the optional utf8[] buffer to hold the answer
	static int	UnicodeToUTF8(hsUniChar unichar, char utf8[] = nil);
	static int	UnicodeToUTF8(int count, hsUniChar unichar[], char utf8[] = nil);

	//	This returns 1 Unicode16 value from the string, and updates the string pointer
	static hsUniChar UTF8ToUnicode(const char** utf8);

	//	This converts a string of utf8 into an array of Unicode16
	//	It returns the number of Unicode16 values converted
	static int	UTF8ToUnicode(int length, const char utf8[], hsUniChar unichar[] = nil);

	//	This counts the number of bytes needed to process "count" characters
	static int	CountToUTF8Length(int count, int length, const char utf8[]);
};
	
#endif
