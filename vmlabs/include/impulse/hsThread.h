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

#ifndef hsThread_Defined
#define hsThread_Defined

#include "hsTypes.h"

typedef UInt32 hsMilliseconds;


#if (HS_BUILD_FOR_MAC68K || HS_BUILD_FOR_PALM)
	#error	"unsupported platform for hsThread"
#elif HS_BUILD_FOR_MACPPC
	#include <Multiprocessing.h>
#elif HS_BUILD_FOR_WIN32
	#include <windows.h>
#elif HS_BUILD_FOR_UNIX
	#include <pthread.h>
	#include <semaphore.h>
#endif

typedef void* hsThreadID;

class hsThread {
	hsBool32	fQuit;
	UInt32		fStackSize;
#if HS_BUILD_FOR_MAC
	MPTaskID	fTaskID;
	MPQueueID	fNotifyQ;
#elif HS_BUILD_FOR_WIN32
	HANDLE		fThreadH;
	HANDLE		fQuitSemaH;
#elif HS_BUILD_FOR_UNIX
	pthread_t	fPThread;
	hsBool		fIsValid;
#endif
protected:
	hsBool		GetQuit() const { return hsIntToBool(fQuit); }
public:
				hsThread(UInt32 stackSize = 0);
	virtual		~hsThread();	// calls Stop()
	
	virtual int		Run() = 0;		// override this to do your work
	virtual void	Start();		// initializes stuff and calls your Run() method
	virtual void	Stop();		// sets fQuit = true and the waits for the thread to stop
	hsThreadID		GetID();

	//	Static functions
	static void*	Alloc(size_t size);	// does not call operator::new(), may return nil
	static void		Free(void* p);		// does not call operator::delete()
	static void		ThreadYield();
	static hsThreadID GetCurrID();

#if HS_BUILD_FOR_WIN32
	DWORD			WinRun();
#endif
};



class hsMutex {
#if HS_BUILD_FOR_MAC
	MPCriticalRegionID	fCriticalRegion;
#elif HS_BUILD_FOR_WIN32
	HANDLE	fMutexH;
#elif HS_BUILD_FOR_UNIX
	pthread_mutex_t	fPMutex;
#endif
public:
			hsMutex();
			~hsMutex();

	void		Lock();
	void		Unlock();
};

class hsTempMutexLock {
	hsMutex*	fMutex;
public:
	hsTempMutexLock(hsMutex* mutex) : fMutex(mutex)
	{
		mutex->Lock();
	}
	~hsTempMutexLock()
	{
		fMutex->Unlock();
	}
};



class hsMonitor {
	hsMutex		fMutex;
	Int32		fCount;
	hsThreadID	fID;
public:
				hsMonitor() : fCount(0), fID(nil) {}
				~hsMonitor();

	hsBool		IsActive() const;
	void		Enter();
	void		Leave();
};

class hsTempMonitor {
	hsMonitor*	fMonitor;
public:
	hsTempMonitor(hsMonitor* monitor) : fMonitor(monitor)
	{
		monitor->Enter();
	}
	~hsTempMonitor()
	{
		fMonitor->Leave();
	}
};



class hsSemaphore {
#if HS_BUILD_FOR_MAC
	MPSemaphoreID	fSemaID;
#elif HS_BUILD_FOR_WIN32
	HANDLE	fSemaH;
#elif HS_BUILD_FOR_UNIX
//	sem_t	fPSema;
	pthread_mutex_t	fPMutex;
	pthread_cond_t	fPCond;
	Int32		fCounter;
#endif
public:
			hsSemaphore();
			~hsSemaphore();

	hsBool		Wait(hsMilliseconds timeToWait = kPosInfinity32);
	void		Signal();
};

#endif
