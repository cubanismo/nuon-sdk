/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 * 1/25/01 kml
 *
 * NuonGamesChannelManager is a derived class of NuonChannelManager
 * which uses BIOS calls for hardware-dependent operations
 */

#ifndef NuonGamesChannelManager_DEFINED
#define NuonGamesChannelManager_DEFINED

#include "NuonPlatformChannelManager.h"



// channel manager for games (bios-controlled)
class NuonGamesChannelManager : public NuonPlatformChannelManager {

	// BIOS channel and display constructs
	VidDisplay		mDisplay;
	VidChannel		*mpChannelMain;
	VidChannel		*mpChannelOsd;

	
public:
	NuonGamesChannelManager();
	virtual ~NuonGamesChannelManager();

	// Show and Hide take an (optional) argument of channels
	// For Show and Hide, setting a channels flag for an inactive (uninitialized) channel 
	// is acknowledged in the return status but otherwise ignored as follows:
	// returns 0 on success, <0 on failure, >0 on one or both requested channels ignored
	// Config checks mmlDisplayPixmap::dmaFlags to verify pixmap can be displayed on
	// the selected channel
	
	// configure a channel before a call to Show()
	// this is where the check for allowed pixel format(s) is done
	virtual int ConfigChannel (const unsigned user, mmlDisplayPixmap *sP, const unsigned channel = kChOsd);

	// show channels that have been configured with a call to ConfigChannel
	virtual int Show (const unsigned channels = (kChOsd | kChMain), 
						 const int alpha = 0);
	// hide channels
	virtual int Hide (const unsigned channels = (kChOsd | kChMain));

	// Loads the OSD hardware Clut
	virtual void SetClut (const NuonYccColorTable *clut);

#if defined (NO_PRINT)
#else
	virtual void PrintState (char *objectName);
#endif
};

#endif  //NuonGamesChannelManager_DEFINED



