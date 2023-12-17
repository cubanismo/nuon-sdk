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

#ifndef hsRegistry_DEFINED
#define hsRegistry_DEFINED

#include "hsMemory.h"

class hsInputStream;
class hsOutputStream;

class hsRegistry {
	class hsRegistryDict*	fDict;
	int						fCount;
public:
	typedef void* (*Proc)(hsRegistry* reg, hsInputStream* stream);

			hsRegistry();
			~hsRegistry();

	void	Reset();
	int		Count() const { return fCount; }
	Proc	Get(Int32 index);
	Proc	Find(const char name[], Int32* index);

	void	Register(const char name[], Proc proc);
	void	Unregister(const char name[]);
	
	void*	ReanimateName(const char name[], hsInputStream* stream);
	void*	ReanimateIndex(int index, hsInputStream* stream);
};

template <class T> class hsTRegistry {
public:
	static T* CreateFromStream(hsRegistry* reg, hsInputStream* stream)
	{
		return new T(reg, stream);
	}

	static void Register(hsRegistry* reg)
	{
		reg->Register(T::ClassName(), (hsRegistry::Proc)CreateFromStream);
	}

	static void Register(hsRegistry* reg, const char className[])
	{
		reg->Register(className, (hsRegistry::Proc)CreateFromStream);
	}
};

#define	hsRegister_Class(ClassName, reg)		hsTRegistry<ClassName>::Register(reg)

#endif
