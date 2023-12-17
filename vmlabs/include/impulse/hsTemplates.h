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

#ifndef hsTemplates_DEFINED
#define hsTemplates_DEFINED

#include "hsExceptions.h"
#include "hsRefCnt.h"

// Use this for a pointer to a single object of class T allocated with new
template <class T> class hsTempObject {
	T*	fObject;
	hsTempObject<T>&	operator=(const hsTempObject<T>&);
public:
		hsTempObject(T* p) : fObject(p) {}
		~hsTempObject() { delete fObject; }

		operator T*() const { return fObject; }
	T*	operator->() const { return fObject; }

	T*	operator=(T* src) { fObject = src; return fObject; }
};

// Use this for subclasses of hsRefCnt, where UnRef should be called at the end
template <class T> class hsTempRef {
	T*	fObject;
public:
		hsTempRef(T* object = nil) : fObject(object) {}
		~hsTempRef() { if (fObject) fObject->UnRef(); }

		operator T*() const { return fObject; }
	T*	operator->() const { return fObject; }
	
	void operator=(T* src)
	{
		if (fObject != src)
		{	hsRefCnt_SafeUnRef(fObject);
			fObject = src;
		}
	}
};

// Use this for an array of objects of class T allocated with new[]
template <class T> class hsTempArray {
	T*		fArray;
	UInt32	fCount;
	hsTempArray<T>&	operator=(const hsTempArray<T>&);
public:
	hsTempArray(UInt32 count) : fArray(new T[count]), fCount(count)
	{
	}
	hsTempArray(UInt32 count, T initValue) : fArray(new T[count]), fCount(count)
	{
		for (int i = 0; i < count; i++)
			fArray[i] = initValue;
	}
	hsTempArray(T* p) : fArray(p), fCount(1)
	{
	}
	hsTempArray() : fArray(nil), fCount(0)
	{
	}
	~hsTempArray()
	{
		delete[] fArray;
	}

	operator T*() const { return fArray; }
	T* GetArray() const { return fArray; }
	T* Accomodate(UInt32 count)
	{
		if (count > fCount)
		{	delete[] fArray;
			fCount = count;
			fArray = new T[count];
		}
		return fArray;
	}
	
	UInt32	Count() const { return fCount; }
	T*		Detach()
	{
		T*	array = fArray;
		
		fCount	= 0;
		fArray	= nil;
		return array;
	}
};



template <class T> class hsTArray {
	T*		fArray;
	int		fUseCount;
	int		fTotalCount;
	
	inline void	IncCount(int index, int count);
	inline void	DecCount(int index, int count);

#ifdef HS_DEBUGGING
	#define	hsTArray_ValidateCount(count)		hsAssert((count) > 0, "bad count")
	#define	hsTArray_ValidateIndex(index)		hsAssert(unsigned(index) < unsigned(fUseCount), "bad index")
	#define	hsTArray_ValidateInsertIndex(index)	hsAssert(unsigned(index) <= unsigned(fUseCount), "bad index")
	#define	hsTArray_Validate(condition)		hsAssert(condition, "oops")
#else
	#define	hsTArray_ValidateCount(count)
	#define	hsTArray_ValidateIndex(index)
	#define	hsTArray_ValidateInsertIndex(index)
	#define	hsTArray_Validate(condition)
#endif
public:
			hsTArray() : fArray(nil), fUseCount(0), fTotalCount(0) {}
	inline	hsTArray(int count);
	inline	hsTArray(const hsTArray<T>& src);
			~hsTArray() { if (fArray) delete[] fArray; }

	inline hsTArray<T>&	operator=(const hsTArray<T>& src);

	const T&	Get(int index) const { hsTArray_ValidateIndex(index); return fArray[index]; }
	T&		operator[](int index) { hsTArray_ValidateIndex(index); return fArray[index]; }
	const T& operator[](int index) const { hsTArray_ValidateIndex(index); return fArray[index]; }

	T*		FirstIter() { return &fArray[0]; }
	T*		StopIter() { return &fArray[fUseCount]; }
	T*		FirstIter() const { return &fArray[0]; }
	T*		StopIter() const { return &fArray[fUseCount]; }

	int		Count() const { return fUseCount; }
	int		GetCount() const { return fUseCount; }
	inline void	SetCount(int count);
	inline void	Reset();

	T*		Insert(int index)
			{
				hsTArray_ValidateInsertIndex(index);
				this->IncCount(index, 1);
				return &fArray[index];
			}
	void	Insert(int index, const T& item)
			{
				hsTArray_ValidateInsertIndex(index);
				this->IncCount(index, 1);
				fArray[index] = item;
			}
	void	Insert(int index, int count, T item[])
			{
				hsTArray_ValidateCount(count);
				if (count > 0)
				{	hsTArray_ValidateInsertIndex(index);
					this->IncCount(index, count);
					hsTArray_CopyForward(item, &fArray[index], count);
				}
			}
	// This guy is a duplicate for compatibility with the older hsDynamicArray<>
	void	InsertAtIndex(int index, const T& item) { this->Insert(index, item); }

	void	Remove(int index)
			{
				hsTArray_ValidateIndex(index);
				this->DecCount(index, 1);
			}
	void	Remove(int index, int count)
			{
				hsTArray_ValidateCount(count);
				hsTArray_ValidateIndex(index);
				hsTArray_ValidateIndex(index + count - 1);
				this->DecCount(index, count);
			}
	hsBool	RemoveItem(const T& item);

	T*		Push()
			{
				this->IncCount(fUseCount, 1);
				return &fArray[fUseCount - 1];
			}
	void	Push(const T& item)
			{
				this->IncCount(fUseCount, 1);
				fArray[fUseCount - 1] = item;
			}
	void	Append(const T& item)
			{
				this->IncCount(fUseCount, 1);
				fArray[fUseCount - 1] = item;
			}
	T*		Append()
			{
				this->IncCount(fUseCount, 1);
				return &fArray[fUseCount - 1];
			}
	T*		AppendCount(int count)
			{
				hsAssert(count > 0, "bad AppendCount");
				int	useCount = fUseCount;
				this->IncCount(useCount, count);
				return &fArray[useCount];
			}
	inline T Pop();

	enum {
		kMissingIndex	 = -1
	};
	int	 		Find(const T& item) const;	// returns kMissingIndex if not found
	inline T*	ForEach(hsBool (*proc)(T&));
	inline T*	ForEach(hsBool (*proc)(T&, void* p1), void* p1);
	inline T*	ForEach(hsBool (*proc)(T&, void* p1, void* p2), void* p1, void* p2);

	T*		DetachArray()
			{
				T* array = fArray;
				fUseCount = fTotalCount = 0;
				fArray = nil;
				return array;
			}
};

//
//	Public hsTArray methods
//

template <class T> hsTArray<T>::hsTArray(int count) : fArray(nil)
{
	hsTArray_ValidateCount(count);
	fUseCount = fTotalCount = count;
	if (count > 0)
		fArray = new T[count];
}

template <class T> hsTArray<T>::hsTArray(const hsTArray<T>& src) : fArray(nil)
{
	int	count = src.Count();
	fUseCount = fTotalCount = count;

	if (count > 0)
	{	fArray = new T[count];
		hsTArray_CopyForward(src.fArray, fArray, count);
	}
}

template <class T> hsTArray<T>& hsTArray<T>::operator=(const hsTArray<T>& src)
{
	if (this->Count() != src.Count())
		this->SetCount(src.Count());
	hsTArray_CopyForward(src.fArray, fArray, src.Count());
	return *this;
}

template <class T> void hsTArray<T>::SetCount(int count)
{
	if (count == 0)
		this->Reset();
	else
	{	hsTArray_ValidateCount(count);
		if (count > fTotalCount)
		{	if (fArray)
				delete[] fArray;
			fArray = new T[count];
			fUseCount = fTotalCount = count;
		}
		fUseCount = count;
	}
}

template <class T> void hsTArray<T>::Reset()
{
	if (fArray)
	{	delete[] fArray;
		fArray = nil;
		fUseCount = fTotalCount = 0;
	}
}

template <class T> T hsTArray<T>::Pop()
{
	hsTArray_Validate(fUseCount > 0);
	fUseCount -= 1;
	return fArray[fUseCount];
}

template <class T> int hsTArray<T>::Find(const T& item) const
{
	for (int i = 0; i < fUseCount; i++)
		if (fArray[i] == item)
			return i;
	return kMissingIndex;
}

template <class T> hsBool hsTArray<T>::RemoveItem(const T& item)
{
	for (int i = 0; i < fUseCount; i++)
		if (fArray[i] == item)
		{	this->DecCount(i, 1);
			return true;
		}
	return false;
}

//
//	These are the private methods for hsTArray
//

template <class T> void hsTArray_CopyForward(const T src[], T dst[], int count)
{
	for (int i = 0; i < count; i++)
		dst[i] = src[i];
}

template <class T> void hsTArray_CopyBackward(const T src[], T dst[], int count)
{
	for (int i = count - 1; i >= 0; --i)
		dst[i] = src[i];
}

template <class T> void hsTArray<T>::IncCount(int index, int count)
{
	int	newCount = fUseCount + count;

	if (newCount > fTotalCount)
	{	if (fTotalCount == 0)
			fTotalCount = newCount;
		do {
			fTotalCount <<= 1;
		} while (fTotalCount < newCount);
		T*	newArray = new T[fTotalCount];

		if (fArray != nil)
		{	hsTArray_CopyForward(fArray, newArray, index);
			hsTArray_CopyForward(&fArray[index], &newArray[index + count], fUseCount - index);
			delete[] fArray;
		}
		fArray = newArray;
	}
	else
		hsTArray_CopyBackward(&fArray[index], &fArray[index + count], fUseCount - index);
	fUseCount = newCount;
}

template <class T> void hsTArray<T>::DecCount(int index, int count)
{
	if (fUseCount == count)
		this->Reset();
	else
	{	hsTArray_CopyForward(&fArray[index + count], &fArray[index], fUseCount - index - count);
		fUseCount -= count;
	}
}

template <class T> T* hsTArray<T>::ForEach(hsBool (*proc)(T&))
{
	for (int i = 0; i < fUseCount; i++)
		if (proc(fArray[i]))
			return &fArray[i];
	return nil;
}

template <class T> T* hsTArray<T>::ForEach(hsBool (*proc)(T&, void* p1), void* p1)
{
	for (int i = 0; i < fUseCount; i++)
		if (proc(fArray[i], p1))
			return &fArray[i];
	return nil;
}

template <class T> T* hsTArray<T>::ForEach(hsBool (*proc)(T&, void* p1, void* p2), void* p1, void* p2)
{
	for (int i = 0; i < fUseCount; i++)
		if (proc(fArray[i], p1, p2))
			return &fArray[i];
	return nil;
}




#endif

