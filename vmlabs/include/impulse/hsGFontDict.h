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

#ifndef hsGFontDict_DEFINED
#define hsGFontDict_DEFINED

#include "hsGFont.h"
#include "hsTemplates.h"

class hsGFontDict {
	hsTArray<hsGFontID> fList;
public:
	hsBool FontToIndex(hsGFontID fontID, Int32* indexPtr, char name[])
	{
		Int32 index = fList.Find(fontID);
		
		if (index != hsTArray<hsGFontID>::kMissingIndex)
		{	*indexPtr = index;
			return true;
		}
		fList.Append(fontID);
		(void)hsGFontList::GetName(fontID, hsGFontList::kFullName, name);
		return false;
	}

	hsGFontID IndexToFont(Int32 index) const
	{
		return fList.Get(index);
	}

	void RegisterFont(hsGFontID fontID)
	{
		hsAssert(fList.Find(fontID) == hsTArray<hsGFontID>::kMissingIndex, "duplicate font in registry");
		fList.Append(fontID);
	}
};

#endif
