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

#ifndef hsMemory_DEFINED
#define hsMemory_DEFINED

#include "hsTypes.h"
#include "hsTemplates.h"

#if HS_BUILD_FOR_PALM
	#define HS_MEMCPY(d, s, l)		::MemMove(d, (void*)s, l)
	#define HS_MEMMOV(d, s, l)		::MemMove(d, (void*)s, l)
	#define HS_MEMCLR(d, l)			::MemSet(d, l, 0)
	#define HS_MEMCMP(s1, s2, l)	::MemCmp((void*)s1, (void*)s2, l)

#else

#if HS_BUILD_FOR_NUON
	#define HS_MEMCPY(d, s, l)		NuonMemcpy (d, s, l)
#else
	#define HS_MEMCPY(d, s, l)		::memcpy(d, s, l)
#endif

	#define HS_MEMMOV(d, s, l)		::memmove(d, s, l)
	#define HS_MEMCLR(d, l)			::memset(d, 0, l)
	#define HS_MEMCMP(s1, s2, l)	::memcmp(s1, s2, l)
#endif


#if HS_BUILD_FOR_NUON
	static inline void NuonMemcpy (void* dst, const void* src, UInt32 length)
	{
		if (  ( ((UInt32)dst & 0x3) | ((UInt32) src & 0x3) ) == 0)  {
			//dst and src are long-aligned
			::memcpy(dst, src, length);
		}
		else  {
			// do it the hard way
			UInt8 *bsrc = (UInt8*) src;
			UInt8 *bdst = (UInt8*) dst;
			for (UInt32 i = 0; i < length; i++)  *bdst++ = *bsrc++;
		}
	}
#endif




class HSMemory {
public:
#ifdef HS_DEBUGGING
	static void Copy(void* dst, const void* src, UInt32 length);
	static void Move(void* dst, const void* src, UInt32 length);
	static void Clear(void* dst, UInt32 length);
	static hsBool Equal(const void* block1, const void* block2, UInt32 length);
	static void* New(UInt32 size);
	static void	Delete(void* block);
#else
	static inline void Copy(void* dst, const void* src, UInt32 length)
	{
		HS_MEMCPY(dst, src, length);
	}
	static inline void Move(void* dst, const void* src, UInt32 length)
	{
		HS_MEMMOV(dst, src, length);
	}
	static inline void Clear(void* dst, UInt32 length)
	{
		HS_MEMCLR(dst, length);
	}
	static inline hsBool Equal(const void* block1, const void* block2, UInt32 length)
	{
		return HS_MEMCMP(block1, block2, length) == 0;
	}
	static inline void*	New(UInt32 size)
	{
		return new UInt32[(size + 3) >> 2];
	}
	static inline void Delete(void* block)
	{
		delete[] (UInt32*)block;
	}
#endif

	static void*	Dup(UInt32 length, const void* source);	
	static void*	SoftNew(UInt32 size);	// returns nil if can't allocate
};



class hsScratchMem {
	enum {
		kBufferSize = 32
	};
	UInt8*	fMem;
	UInt8	fMemBuffer[kBufferSize];
	UInt32	fLength;
public:
	hsScratchMem() : fLength(kBufferSize)
	{
		fMem = fMemBuffer;
	}
	~hsScratchMem()
	{
		if (fMem != fMemBuffer)
			delete[] fMem;
	}
	UInt8* GetMem(UInt32 length)
	{
		if (length > fLength)
		{	if (fMem != fMemBuffer)
				delete[] fMem;
			fMem = new UInt8[length];
			fLength = length;
		}
		return fMem;
	}
};

class hsChunkAllocator {
	enum {
		kDefaultChunkSize = 4096
	};
	UInt32				fChunkSize;
	struct hsPrivateChunk*	fChunk;
	hsDebugCode(UInt32	fChunkCount;)
public:
			hsChunkAllocator(UInt32 chunkSize = kDefaultChunkSize);
			~hsChunkAllocator();

	void	Reset();
	void	SetChunkSize(UInt32 size);
// Alphamask fix sent 4/27/01
#if 0
	void*	Allocate(UInt32 size, const void* data = nil);		// throws if fails
	void*	SoftAllocate(UInt32 size, const void* data = nil);	// returns nil if fails
#else
	void*	Allocate(UInt32 size, const void* data = nil, bool align32 = true);		// throws if fails
	void*	SoftAllocate(UInt32 size, const void* data = nil, bool align32 = true);	// returns nil if fails
#endif
};

class hsStringStorage {
	hsTArray<char*>		fStrings;
	hsChunkAllocator	fStorage;
public:
				hsStringStorage();
				~hsStringStorage();

	void		Reset();
	Int32		Count() const;
	const char*	Get(Int32 index) const;	// throws on bad index
	hsBool		Find(const char name[], Int32* index) const;
	void		Add(const char name[]);
};



class hsAppender {
	struct hsAppenderHead*	fFirstBlock, *fLastBlock;
	UInt32					fElemSize, fElemCount, fCount;
	
	hsDebugCode(void validate() const;)
	hsDebugCode(friend class hsAppenderValidator;)
	friend class hsAppenderIterator;
public:
			hsAppender(UInt32 elemSize, UInt32 minCount = 16);
			~hsAppender();

	UInt32	ElemSize() const { return fElemSize; }
	UInt32	Count() const { return fCount; }
	hsBool	IsEmpty() const { return fCount == 0; }
	void	Reset();

	void	operator=(const hsAppender& src);
	UInt32	CopyInto(void* data = nil) const;	// return size of data array in bytes

	void*	PushHead();
	void	PushHead(const void* data);
	void*	PushTail();
	void	PushTail(const void* data);
	void	PushTail(int count, const void* data);	// data[] = count * fElemSize
	void*	PeekHead() const;
	void*	PeekTail() const;
	hsBool	PopHead(void* data = nil);
	int		PopHead(int count, void* data = nil);		// data[] = count * fElemSize
	hsBool	PopTail(void* data = nil);

	//	Alternate interfaces

	void*	Prepend() { return this->PushHead(); }
	void*	Append() { return this->PushTail(); }

	void*	Push() { return this->PushHead(); }
	void	Push(const void* data) { this->PushHead(data); }
	hsBool	Pop(void* data = nil) { return this->PopHead(data); }

	void*	Enqueue() { return this->PushTail(); };
	void	Enqueue(const void* data) { this->PushTail(data); }
	void	Enqueue(int count, const void* data) { this->PushTail(count, data); }
	hsBool	Dequeue(void* data = nil) { return this->PopHead(data); }
	int		Dequeue(int count, void* data = nil) { return this->PopHead(count, data); }
};

class hsAppenderIterator {
	const hsAppender*			fAppender;
	const struct hsAppenderHead*	fCurrBlock;
	void*					fCurrItem;
public:
			hsAppenderIterator(const hsAppender* list = nil);
			
	void	ResetToHead(const hsAppender* list = nil);
	void	ResetToTail(const hsAppender* list = nil);
	void*	Next();
	hsBool	Next(void* data);
	int		Next(int count, void* data);
	void*	NextCount(int* countPtr);
	void*	Prev();
	hsBool	Prev(void* data);

	//	Obsolete interface

	void	Reset(const hsAppender* list = nil) { this->ResetToHead(list); }
};



template <class T> class hsTAppender : hsAppender {
public:
			hsTAppender() : hsAppender(sizeof(T)) {}
			hsTAppender(UInt32 minCount) : hsAppender(sizeof(T), minCount) {}

	hsAppender*			GetAppender() { return this; }
	const hsAppender*	GetAppender() const { return this; }

	UInt32	Count() const { return hsAppender::Count(); }
	hsBool	IsEmpty() const { return hsAppender::IsEmpty(); }
	void	Reset() { hsAppender::Reset(); }

	UInt32	CopyInto(T copy[]) const { return hsAppender::CopyInto(copy); }

	T*		PushHead() { return (T*)hsAppender::PushHead(); }
	void	PushHead(const T& item) { *this->PushHead() = item; }
	T*		PushTail() { return (T*)hsAppender::PushTail(); }
	void	PushTail(const T& item) { *this->PushTail() = item; };
	void	PushTail(int count, const T item[]) { this->hsAppender::PushTail(count, item); };
	T*		PeekHead() const { return (T*)hsAppender::PeekHead(); }
	T*		PeekTail() const { return (T*)hsAppender::PeekTail(); }
	hsBool	PopHead(T* item = nil) { return hsAppender::PopHead(item); }
	int		PopHead(int count, T item[] = nil) { return hsAppender::PopHead(count, item); }
	hsBool	PopTail(T* item = nil) { return hsAppender::PopTail(item); }

	//	Alternate intefaces

	T*		Prepend() { return this->PushHead(); }
	T*		Append() { return this->PushTail(); }
	void	PrependItem(const T& item) { this->PushHead(item); }
	void	AppendItem(const T& item) { this->PushTail(item); }

	T*		Push() { return this->PushHead(); }
	void	Push(const T& item) { this->PushHead(item); }
	hsBool	Pop(T* item = nil) { return this->PopHead(item); }

	T*		Enqueue() { return this->PushTail(); };
	void	Enqueue(const T& item) { this->PushTail(item); }
	void	Enqueue(int count, const T item[]) { this->PushTail(count, item); }
	hsBool	Dequeue(T* item = nil) { return this->PopHead(item); }
	int		Dequeue(int count, T item[] = nil) { return this->PopHead(count, item); }
};

template <class T> class hsTAppenderIterator : hsAppenderIterator {
public:
			hsTAppenderIterator() : hsAppenderIterator() {}
			hsTAppenderIterator(const hsTAppender<T>* list) : hsAppenderIterator(list->GetAppender()) {}

	void	ResetToHead() { hsAppenderIterator::ResetToHead(nil); }
	void	ResetToHead(const hsTAppender<T>* list) { hsAppenderIterator::ResetToHead(list->GetAppender()); }
	void	ResetToTail() { hsAppenderIterator::ResetToTail(nil); }
	void	ResetToTail(const hsTAppender<T>* list) { hsAppenderIterator::ResetToTail(list->GetAppender()); }
	T*		Next() { return (T*)hsAppenderIterator::Next(); }
	hsBool	Next(T* item) { return hsAppenderIterator::Next(item); }
	T*		NextCount(int* count) { return (T*)hsAppenderIterator::NextCount(count); }
	T*		Prev() { return (T*)hsAppenderIterator::Prev(); }
	hsBool	Prev(T* item) { return hsAppenderIterator::Prev(item); }

	//	Obsolete interfaces

	void	Reset() { this->ResetToHead(); }
	void	Reset(const hsTAppender<T>* list) { this->ResetToHead(list); }
};
#endif

