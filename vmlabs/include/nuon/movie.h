/*Copyright (C) 1996-2001 VM Labs, Inc.

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

#ifndef __MOVIE_H_
#define __MOVIE_H_

#ifdef __cplusplus
extern "C" {
#endif

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

typedef struct
{
	char	*fname;
	int		start;
	int		length;
	int		layer;
	int		physsect;

} VOB_File;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// Error/Success codes returned from _PlayClip functions

#define VOB_NOFILE		(4)
#define VOB_ERROR		(3)
#define VOB_TIMEOUT		(2)
#define	VOB_USERBREAK	(1)
#define VOB_OK			(0)

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int _PlayClip(char *fname, int start, int length, int audiotrack, int (*app_callback)(int));

int _PlayClipV( VOB_File *vob, int audiotrack, int (*app_callback)(int));

int _PlayClipList( VOB_File *list, int listsize, int audiotrack, int (*app_callback)(int));

////////////////////////////////////////////////////////////////////////////
// New MPEG-playback library
////////////////////////////////////////////////////////////////////////////

#define MPEGCB_ERROR					0
#define	MPEGCB_PICTURE_ATTRIBUTES		1
#define MPEGCB_MOVIE_END				2
#define MPEGCB_BUFFER_EMPTY				3
#define MPEGCB_SET_DISPLAY				4


extern void MPEGInit(void);
extern void MPEGStartMPE2(void);
extern void MPEGDecode(int mpe,int info, long *commrecv);
extern void MPEGSetBuffer(int adr,int len);
extern void MPEGSetCallback(int type,void *func);
extern void MPEGSetBuffers(void *mpeg_buffer, int mpeg_len, void *audio_buffer, int audio_len);
extern void MPEGInitVideo(int handle,int sector, int *mux,int width, int height,int sound);


#ifdef __cplusplus
}
#endif

#endif
