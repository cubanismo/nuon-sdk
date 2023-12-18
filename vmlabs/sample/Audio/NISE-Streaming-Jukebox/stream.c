#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <errno.h>
#include <nuon/time.h>
#include <nuon/cache.h>
#include <nuon/mediaio.h> 
#include <nuon/nise.h>
#include <nuon/bios.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>

#include "nuon-dat.h"

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define STREAMBUFFERSECTORS 	(256)
#define SECTORSIZE 				(2048)
#define STREAMINGDEVICE			MEDIA_DVD

#define SCREENWIDTH				(640)
#define SCREENHEIGHT			(240)

#define START_XPOS				(75)
#define START_YPOS				(40)
#define TEXTSIZE				(40)

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

PCMHEAD sound;
PCMPOS  pan;

typedef struct
{
	int	start;
	int	size;
} Streaming_Audio;


int audiofile = 0;

int track_start_time = 0;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define TOTAL_RECORDS_IN_JUKEBOX	(14)				// array index of last item

Streaming_Audio audiofiles[] = 
{
	{ SPACE_RAW_BLOCK, SPACE_RAW_NUMBLOCKS },			// Definitions from NUON-DAT.H
	{ DOPEL_RAW_BLOCK, DOPEL_RAW_NUMBLOCKS },
	{ SCRAB_RAW_BLOCK, SCRAB_RAW_NUMBLOCKS },
	{ DARI1_RAW_BLOCK, DARI1_RAW_NUMBLOCKS },
	{ SYVAR_RAW_BLOCK, SYVAR_RAW_NUMBLOCKS },
	{ MSTER_RAW_BLOCK, MSTER_RAW_NUMBLOCKS },
	{ NIGHT_RAW_BLOCK, NIGHT_RAW_NUMBLOCKS },
	{ DARI2_RAW_BLOCK, DARI2_RAW_NUMBLOCKS },
	{ GUN_RAW_BLOCK, GUN_RAW_NUMBLOCKS },
	{ METAL_RAW_BLOCK, METAL_RAW_NUMBLOCKS },
	{ GALAC_RAW_BLOCK, GALAC_RAW_NUMBLOCKS },
	{ GRID_RAW_BLOCK, GRID_RAW_NUMBLOCKS },
	{ RAYFO_RAW_BLOCK, RAYFO_RAW_NUMBLOCKS },
	{ GAIDN_RAW_BLOCK, GAIDN_RAW_NUMBLOCKS },
	{ GEKIR_RAW_BLOCK, GEKIR_RAW_NUMBLOCKS },
};

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void start_streaming(void)
{
int startSector,size;

	startSector = audiofiles[audiofile].start;
	size = audiofiles[audiofile].size;

	AUDIOSetupStreamingAudio(startSector,startSector+size-1);
									   
	while( AUDIOStreamingAudioStatus() != 1 )
	{
	}
	AUDIOStartStreamingAudio();
	
	/* Adjust master volumes */
	AUDIOMixer(0x20000000,0x20000000);

	track_start_time = GetTimer(0,0);
}



int main()
{
mmlSysResources sysRes;
mmlGC gc;
mmlFontContext fc;
mmlDisplayPixmap screen;
m2dRect r;
mmlFont sysfontP;
int timer_msec, minutes, seconds, last_seconds;
int nuon_media_device, nuon_media_blocksize;
long buffer;
int ypos;
char msg1[100];
char msg2[100];
char msg3[100];
char msg4[100];
int track_length_minutes, track_length_seconds;

	/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );
	
	/* Setup fonts */
	mmlInitFontContext( &gc, &sysRes, &fc, 4096 );
	
	sysfontP = mmlAddFont( fc, "SysFont", eTrueType, (void *)SysFont, 70000 );

	/* Initialize a single display pixmap as a framebuffer
       720 pixels wide by 480 lines tall, using 32 bit YCC-alpha pixels. */

	mmlInitDisplayPixmaps( &screen, &sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	mmlSimpleVideoSetup(&screen, &sysRes, eTwoTapVideoFilter);

	/* Init Audio */
	AUDIOInit();

	// Initialize the timer
	InitTimer();
	
	/* Setup Streaming Audio */
    buffer=(long)malloc(STREAMBUFFERSECTORS*SECTORSIZE);

	nuon_media_device = _MediaOpen(STREAMINGDEVICE, "nuon.dat", 0, &nuon_media_blocksize );

	if( nuon_media_device == 0 )
	{
		exit(0);
	}

	if( ! AUDIOInitStreamingAudio(nuon_media_device,buffer,STREAMBUFFERSECTORS) )
	{
		// Failure!       
		exit(0);
	}
		// Success
	start_streaming();

	last_seconds = -1;

	for(;;)
	{
	static int last_avfile = -1;

		// Calculate track time
		timer_msec = GetTimer(0,0) - track_start_time;
		minutes = (timer_msec / 60000);
	
		timer_msec -= (minutes * 60000);
		seconds = (timer_msec / 1000);

		{
		int numsamples, numseconds;
		
			// Convert number of sectors into number of samples
			numsamples = (audiofiles[audiofile].size * SECTORSIZE) / 2;
			
			// Don't count both tracks of stereo data
			numsamples /= 2;

			// Convert number of samples into number of seconds
			numseconds = numsamples / 32000;

			track_length_minutes = (numseconds / 60);
			track_length_seconds = numseconds - (track_length_minutes * 60);
		}
	
		sprintf( msg4, "%d : %02d",  minutes, seconds );
	
		if( last_avfile != audiofile )
		{
			/* Set all the pixels in the display pixmap */
			m2dFillColr( &gc, &screen, NULL, kGray );
			
			sprintf( msg1, "Track %d    ", audiofile+1 );
			ypos = START_YPOS;
			m2dSetRect( &r, START_XPOS, ypos, SCREENWIDTH, ypos + (TEXTSIZE * 3) );
			mmlSetTextProperties( fc, sysfontP, TEXTSIZE, kRed, kGray, eBlend, 0, 0 );
			mmlSimpleDrawText( fc, &screen, msg1, strlen(msg1), &r );
	
			sprintf( msg2, "Starting Sector = %d", audiofiles[audiofile].start );
			ypos += TEXTSIZE;      
			m2dSetRect( &r, START_XPOS, ypos, SCREENWIDTH, ypos + TEXTSIZE );
			mmlSetTextProperties( fc, sysfontP, TEXTSIZE, kBlue, kGray, eBlend, 0, 0 );
			mmlSimpleDrawText( fc, &screen, msg2, strlen(msg2), &r );
			
			sprintf( msg3, "Length In Sectors = %d", audiofiles[audiofile].size );
			ypos += TEXTSIZE;      
			m2dSetRect( &r, START_XPOS, ypos, SCREENWIDTH, ypos + TEXTSIZE );
			mmlSetTextProperties( fc, sysfontP, TEXTSIZE, kBlue, kGray, eBlend, 0, 0 );
			mmlSimpleDrawText( fc, &screen, msg3, strlen(msg3), &r );

			sprintf( msg3, "Length In Time = %d : %02d", track_length_minutes, track_length_seconds );
			ypos += TEXTSIZE;      
			m2dSetRect( &r, START_XPOS, ypos, SCREENWIDTH, ypos + TEXTSIZE );
			mmlSetTextProperties( fc, sysfontP, TEXTSIZE, kBlue, kGray, eBlend, 0, 0 );
			mmlSimpleDrawText( fc, &screen, msg3, strlen(msg3), &r );

			last_avfile = audiofile;
		}
		
		if( seconds != last_seconds )
		{
			ypos = START_YPOS;      
			m2dSetRect( &r, SCREENWIDTH/2, ypos, SCREENWIDTH, ypos + TEXTSIZE );
			
			// Fill the target region
			m2dFillColr( &gc, &screen, &r, kGray );
			mmlSetTextProperties( fc, sysfontP, TEXTSIZE, kRed, kGray, eBlend, 0, 0 );
			mmlSimpleDrawText( fc, &screen, msg4, strlen(msg4), &r );

			// Check to see if we've hit end of song
			if( minutes >= track_length_minutes )
			{
				if( seconds >= track_length_seconds )
				{
					// If we hit end of song, then go to next one
					audiofile++;
					if( audiofile > TOTAL_RECORDS_IN_JUKEBOX )
						audiofile = 0;
					
					AUDIOStopStreamingAudio();
					start_streaming();
				}
			}
		}
		
		// Check controller for track selection
		if( ButtonA(_Controller[1]) || ButtonB(_Controller[1]) )
		{
			if( ButtonA(_Controller[1]) )
			{
				audiofile++;
				if( audiofile > TOTAL_RECORDS_IN_JUKEBOX )
					audiofile = 0;
			}
			else if( ButtonB(_Controller[1] ) )
			{
				audiofile--;
				if( audiofile < 0 )
					audiofile = TOTAL_RECORDS_IN_JUKEBOX;
			}

			AUDIOStopStreamingAudio();
            start_streaming();
		}
		
		last_seconds = seconds;
	}
}

