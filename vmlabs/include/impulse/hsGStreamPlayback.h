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

#ifndef hsGStreamPlayback_DEFINED
#define hsGStreamPlayback_DEFINED

//#define RECORD_DEVICE_TO_FILE

#include "hsGDevice.h"

class hsRegistry;

/** Plays back a stream created by an hsGStreamDevice.

	\sa hsGStreamDevice */
class hsGStreamPlayback {
	struct hsGStreamPlaybackData* fData;
#ifdef RECORD_DEVICE_TO_FILE
	FILE*	fFILE;
#endif
public:
	/** The optional hsRegistry object passed to the construct allows
		any flattened subclasses to be reanimated during playback. The
		file hsGRegisterAll.h declares a function that registers all
		of the features provided with Impulse (gradient shaders,
		dashing path-effects, etc.).

		Example:
		
		\code
		void DrawStream(hsInputStream* inStream, hsGDevice* target)
		{
		    hsRegistry         registry;
		    hsGStreamPlayback  player(&registry);
			
		    hsGRegisterAll(&registry);
			
		    playback.Playback(inStream, target);
		}
		\endcode
	*/
			hsGStreamPlayback(hsRegistry* registry);
			~hsGStreamPlayback();

			/** The target device can be any subclass of hsGDevice,
                including another stream device. You may pass \c nil
                for the constructor of the hsGStreamPlayback, in which
                case any subclassed objects embedded in the stream
                will be ignored. */
	void	Playback(hsInputStream* stream, hsGDevice* target);

#ifdef RECORD_DEVICE_TO_FILE
	void	SetFILE(FILE* f) { fFILE = f; }
#endif
};

#endif
