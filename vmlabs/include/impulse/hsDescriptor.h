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

#ifndef hsDescriptorDefined
#define hsDescriptorDefined

#include "hsScalar.h"

struct hsDescriptorHeader;
typedef hsDescriptorHeader*		hsDescriptor;
typedef const hsDescriptorHeader*	hsConstDescriptor;

#ifndef HS_DEBUGGING
	#include "hsDescriptor_Internal.h"
#endif

UInt32	hsDescriptor_ComputeSize(UInt32 count, const UInt32 sizes[]);

hsDescriptor hsDescriptor_New(UInt32 size);	// calls HSMemory::New()
hsDescriptor hsDescriptor_New(UInt32 count, const UInt32 sizes[]);	
// Copy src into dst. If dst == nil then allocate it using HSMemory::New()
hsDescriptor hsDescriptor_Copy(hsConstDescriptor src, hsDescriptor dst = nil);
// Assumes that desc was allocated with HSMemory::New()
void		hsDescriptor_Delete(hsDescriptor desc);

#ifdef HS_DEBUGGING
	void		hsDescriptor_Reset(hsDescriptor desc);
	UInt32	hsDescriptor_Size(hsConstDescriptor desc);
	hsBool	hsDescriptor_Equal(hsConstDescriptor a, hsConstDescriptor b);
	UInt32	hsDescriptor_AdditionalSize(UInt32 size);
	// Return the location for the new data
	void*	hsDescriptor_Add(hsDescriptor desc, UInt32 tag, UInt32 length);
	inline void hsDescriptor_Add32(hsDescriptor desc, UInt32 tag, UInt32 data)
	{
		*(UInt32*)hsDescriptor_Add(desc, tag, sizeof(UInt32)) = data;
	}

	inline void hsDescriptor_AddScalar(hsDescriptor desc, UInt32 tag, hsScalar data)
	{
		*(hsScalar*)hsDescriptor_Add(desc, tag, sizeof(hsScalar)) = data;
	}
#else
	inline void hsDescriptor_Reset(hsDescriptor desc)
	{
		desc->fLength	= sizeof(hsDescriptorHeader);
		desc->fCount	= 0;
	}
	inline UInt32 hsDescriptor_Size(hsConstDescriptor desc)
	{
		return desc->fLength;
	}
	inline hsBool hsDescriptor_Equal(hsConstDescriptor a, hsConstDescriptor b)
	{
		const UInt32*	ptr_a = (UInt32*)a;
		const UInt32*	ptr_b = (UInt32*)b;
		UInt32		longCount = a->fLength >> 2;

		do {
			if (*ptr_a++ != *ptr_b++)
				return false;
		} while (--longCount);

		return true;
	}
	inline void* hsDescriptor_Add(hsDescriptor desc, UInt32 tag, UInt32 length)
	{
		DescRec*	rec	= (DescRec*)((char*)desc + desc->fLength);
		rec->fTag		= tag;
		rec->fLength	= length;

		void*	recData = rec->GetData();
		UInt32	longLength = hsLongAlign(length);

		// clear the last long in case length is not long aligned
		// we want it cleared so that the CheckSum will be reproducible
		if (longLength > length)
			*(UInt32*)((char*)recData + longLength - sizeof(UInt32)) = 0;

		desc->fCount	+= 1;
		desc->fLength	+= sizeof(DescRec) + longLength;
		return recData;
	}
	inline void hsDescriptor_Add32(hsDescriptor desc, UInt32 tag, UInt32 value)
	{
		DescRec*	rec	= (DescRec*)((char*)desc + desc->fLength);
		rec->fTag		= tag;
		rec->fLength	= sizeof(UInt32);

		*(UInt32*)rec->GetData() = value;

		desc->fCount	+= 1;
		desc->fLength	+= sizeof(DescRec) + sizeof(UInt32);
	}
	inline void hsDescriptor_AddScalar(hsDescriptor desc, UInt32 tag, hsScalar value)
	{
		DescRec*	rec	= (DescRec*)((char*)desc + desc->fLength);
		rec->fTag		= tag;
		rec->fLength	= sizeof(hsScalar);

		*(hsScalar*)rec->GetData() = value;

		desc->fCount	+= 1;
		desc->fLength	+= sizeof(DescRec) + sizeof(hsScalar);
	}
	inline UInt32 hsDescriptor_AdditionalSize(UInt32 size)
	{
		return sizeof(DescRec) + hsLongAlign(size);
	}
#endif

// Return the location of the found data, or nil if not found
const void* hsDescriptor_Find(hsConstDescriptor desc, UInt32 tag, UInt32* length, void* data);
void*	hsDescriptor_Find(hsDescriptor desc, UInt32 tag, UInt32* length, void* data);

void		hsDescriptor_Remove(hsDescriptor desc, UInt32 tag);
void		hsDescriptor_UpdateCheckSum(hsDescriptor desc);

//
// 		Some helpers for 32bit data (int and scalar)

#ifdef HS_DEBUGGING
	UInt32	hsDescriptor_Find32(hsConstDescriptor desc, UInt32 tag);
	hsScalar	hsDescriptor_FindScalar(hsConstDescriptor desc, UInt32 tag);
#else
	inline UInt32 hsDescriptor_Find32(hsConstDescriptor desc, UInt32 tag)
	{
		return *(UInt32*)hsDescriptor_Find(desc, tag, nil, nil);
	}
	inline hsScalar hsDescriptor_FindScalar(hsConstDescriptor desc, UInt32 tag)
	{
		return *(hsScalar*)hsDescriptor_Find(desc, tag, nil, nil);
	}
#endif

#endif
