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

#ifndef hsRefCnt_Defiend
#define hsRefCnt_Defiend

#include "hsTypes.h"

/** Reference counting mixin.
	
	When a hsRefCnt object is created, its private counter is
	initialized to 1. Each time Ref() is called, the counter is
	incremented. Each time UnRef() is called, the counter is
	decremented. If the counter gets to 0, then the object is
	deleted. It is an error to explicitly delete a hsRefCnt object
	whose counter is $> 1$.  */
class hsRefCnt {
private:
	Int32			fRefCnt;
public:
					hsRefCnt() : fRefCnt(1) {}
	virtual			~hsRefCnt();

	Int32			RefCnt() const { return fRefCnt; }
	void			Ref() { fRefCnt += 1; }
	virtual void	UnRef();
};

#define hsRefCnt_SafeRef(obj)			\
	do {								\
		if (obj)						\
			(obj)->Ref();				\
	} while (0)

#define hsRefCnt_SafeUnRef(obj)			\
	do {								\
		if (obj)						\
			(obj)->UnRef();				\
	} while (0)

#define hsRefCnt_SafeAssign(dst, src)	\
		do {							\
			hsRefCnt_SafeRef(src);		\
			hsRefCnt_SafeUnRef(dst);	\
			dst = src;					\
		} while (0)

#endif
