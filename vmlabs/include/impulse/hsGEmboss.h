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

#ifndef hsGEmboss_DEFINED
#define hsGEmboss_DEFINED

#include "hsGBitmap.h"

///
struct hsGEmbossRecord {
	///	amount to emboss
	hsScalar	fRadius;
	///	0, 0, 1 is "regular"
	hsScalar	fLight[3];
	/// 	0..1
	hsScalar	fKs;
	/// 	0..1
	hsScalar	fKd;

	void	Reset();
	void	Normalize();		// pins values to legal limits
	void	Read(hsInputStream* stream);
	void	Write(hsOutputStream* stream);

	friend int operator==(const hsGEmbossRecord& a, const hsGEmbossRecord& b)
	{
		return	a.fRadius	== b.fRadius &&
				a.fLight[0]	== b.fLight[0] &&
				a.fLight[1]	== b.fLight[1] &&
				a.fLight[2]	== b.fLight[2] &&
				a.fKd		== b.fKd &&
				a.fKs		== b.fKs;
	}			
	friend int operator!=(const hsGEmbossRecord& a, const hsGEmbossRecord& b)
	{
		return !(a == b);
	}
	
	///
	void	EmbossAlpha(const hsGBitmap* src, hsGBitmap* dst);
};

#endif
