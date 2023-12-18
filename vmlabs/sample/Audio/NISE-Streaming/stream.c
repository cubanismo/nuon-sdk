#include <stdlib.h>
#include <stdio.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>
#include <nuon/mediaio.h> 
#include <nuon/nise.h>
#include <nuon/bios.h>
#include <nuon/dma.h>

///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define STREAMBUFFERSECTORS 	(512)
#define SECTORSIZE 				(2048)

#define NUON_DATAFILE			("buffy.raw")
#define STREAMINGDEVICE			MEDIA_REMOTE
#define START_AUDIO_STREAM		(0)
#define SIZE_AUDIO_STREAM		(10000)

#define SCREENWIDTH				(720)
#define SCREENHEIGHT			(480)

#define clr_white 				(0xeb808000)	// RGB(255,255,255)
#define clr_black 				(0x10808000)	// RGB(0,0,0)
#define clr_light_red			(0x8bc66900)	// RGB(255,96,96)
#define clr_red 				(0x51f05b00)	// RGB(255,0,0)
#define clr_blue 				(0x296ff000)	// RGB(0,0,255)
#define clr_green 				(0x91233700)	// RGB(0,255,0)
#define clr_orange 				(0x92c13600)	// RGB(255,128,0)
#define clr_light_orange 		(0xb2c13600)	// RGB(255,128,0)
#define clr_light_blue			(0x7276c600)	// RGB(64,64,255)
#define clr_light_green			(0xb3465300)	// RGB(128,255,128)

///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;
int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

static AUDIO_RESOURCES audiorsc = { 0, 0, 0x40780000, 0 };

PCMHEAD sound;
PCMPOS  pan;

int nuon_media_device, nuon_media_blocksize;
	
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void clearscreen(mmlDisplayPixmap *scrn);
void swap_screenbuffers(void);
void init_screenbuffers(void);
void print_message(int scr, char *msg);

int InitStreaming(void);
void StartStreamingAudio(void);

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void clearscreen(mmlDisplayPixmap *scrn)
{
long x, y, h;

	for (y = 0; y <= scrn->high; y += 8)
	{
		h = ((scrn->high - y) >= 8) ? 8 : (scrn->high - y); 
		
		for (x = 0; x < scrn->wide; x += 8)
		{
			_DMABiLinear(scrn->dmaFlags|DMA_DIRECT_BIT, scrn->memP, (8<<16)|x, (h<<16)|y, (void *)clr_black);
		}
    }
}

////////////////////////////////////////////////////////////////////////////
// Swap draw and display buffers.  Takes effect next VBLANK
////////////////////////////////////////////////////////////////////////////

void swap_screenbuffers(void)
{
int tmp;

	tmp = gl_displaybuffer;
	gl_displaybuffer = gl_drawbuffer;
	gl_drawbuffer = tmp;

	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
// Initialize the draw/display buffers, clear the memory, put one up!
////////////////////////////////////////////////////////////////////////////

void init_screenbuffers(void)
{
	// Initialize index values for gl_screenbuffers[] array
	gl_displaybuffer = 0;
	gl_drawbuffer = 1;

	// Create & clear each buffer

	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_displaybuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_drawbuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	
	clearscreen(&gl_screenbuffers[gl_drawbuffer]);
	clearscreen(&gl_screenbuffers[gl_displaybuffer]);

	// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void print_message(int scr, char *msg)
{
mmlDisplayPixmap *scrn = &gl_screenbuffers[gl_drawbuffer];
static int ds_ypos = 40;

	switch( scr )
	{
		// Just increment Y-POS
		case -1:
			ds_ypos += (int)msg;
			break;

		case 0:
			scrn = &gl_screenbuffers[gl_drawbuffer];
			break;

		case 1:
			scrn = &gl_screenbuffers[gl_displaybuffer];
			break;
	}

	switch( scr )
	{
		case 0:			
		case 1:
			if( ds_ypos > 440 )
			{
				{
				int x, y;
				long scratchsize;
				
					// Get address of internal memory scratch buffer to use for image buffer
					long *imgbuf = _MemLocalScratch((void *)&scratchsize);
				
					for( y = 15; y < scrn->high; y += 2 )
					{
						for( x = 0; x < scrn->wide; x += 16 )
						{
							// Read segment we're gonna move up a line
							_DMABiLinear(	scrn->dmaFlags|(1<<13), scrn->memP, 
											(x)|(16<<16), (y)|(2<<16),
											(void *)imgbuf );
				
							// write it back to new location
							_DMABiLinear(	scrn->dmaFlags, scrn->memP, 
											(x)|(16<<16), (y-15)|(2<<16),
											(void *)imgbuf );
						}
					}
				
					// Now clear bottom of screen
					for (y = (scrn->high-15); y < scrn->high; y++ )
					{
						for (x = 0; x < scrn->wide; x += 8)
						{
							_DMABiLinear(scrn->dmaFlags|DMA_DIRECT_BIT, scrn->memP, (8<<16)|x, (1<<16)|y, (void *)clr_black);
						}
					}
				}
				ds_ypos -= 15;
			}
			
			DebugWS( scrn->dmaFlags, scrn->memP, 40, ds_ypos, kWhite, msg );
			ds_ypos += 15;
			break;
	}
}

///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int InitStreaming(void)
{
int *buffer;
char msgstr[200];
int status;

	/* Setup Streaming Audio */
    buffer=(int *)malloc(STREAMBUFFERSECTORS*SECTORSIZE);

	sprintf( msgstr, "Allocated %d bytes at 0x%08x", (STREAMBUFFERSECTORS*SECTORSIZE), (int)buffer );
	print_message( 1, msgstr );

	sprintf( msgstr, "Attempting to open file: %s", NUON_DATAFILE );
	print_message( 1, msgstr );
	
	nuon_media_device = _MediaOpen(STREAMINGDEVICE, NUON_DATAFILE, 0, &nuon_media_blocksize );

	sprintf( msgstr, "After _MediaOpen, device handle = 0x%08x", (int)nuon_media_device );
	print_message( 1, msgstr );

	if( nuon_media_device )
	{
		print_message(-1, (char *)15);
		print_message( 1, "Calling AUDIOInitStreamingAudio..." );
        status = AUDIOInitStreamingAudio(nuon_media_device,(int)buffer,STREAMBUFFERSECTORS);

		if( ! status )
			sprintf(msgstr, "AUDIOInitStreamingAudio failed!");
		else
			sprintf(msgstr, "AUDIOInitStreamingAudio worked!");
		
		print_message( 1, msgstr );
	}
	else
	{
		status = 0;
	}

	return( status );   
}

///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////


void StartStreamingAudio(void)
{
int sec;
long start_seconds, start_useconds, end_seconds, end_useconds;
double seconds, bps;
int startSector,size;
char msgstr[200];
	
	startSector = START_AUDIO_STREAM;
	size = SIZE_AUDIO_STREAM;

	print_message( 1, "Calling AUDIOSetupStreamingAudio..." );
	sprintf( msgstr, "startSector = %d, last sector = %d!",startSector,startSector+size-1);
	print_message( 1, msgstr );

	// Initialize the timer
	InitTimer();
	GetTimer( &start_seconds, &start_useconds );                       
	
	AUDIOSetupStreamingAudio(startSector,startSector+size-1);

	while( AUDIOStreamingAudioStatus() != 1 )
	{
		print_message( 1, "Waiting for buffer read to complete..." );
		_VidSync( 5 );
	}
	
	GetTimer( &end_seconds, &end_useconds );                       

    sec = end_seconds - start_seconds;
	sec *= 1000000;
    sec += (end_useconds - start_useconds);
	seconds = (double)sec / 1000000.0;

    sprintf( msgstr, "Elapsed time: %f seconds", seconds );
	print_message( 1, msgstr );

	// AUDIOSetupStreamingAudio() fills first half of buffer 
	size = (STREAMBUFFERSECTORS*SECTORSIZE) / 2;

	// Get bytes per second
	bps = (double)size / seconds;

	sprintf( msgstr, "for %d bytes = %f bytes per second", size, bps );
	print_message( 1, msgstr );

	print_message( 1, "Buffer read completed!  Starting play.");
	
	AUDIOStartStreamingAudio();
}

///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int main()
{
int status;
char msgstr[300];

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	print_message( 1, "Initializing AUDIO Library..." );

	/* Init Audio */
	status = AUDIOInitX(&audiorsc);

	sprintf( msgstr, "AUDIOInitX returns: %d (MPE = %d)", status, audiorsc.audioMPE );
	print_message( 1, msgstr );

	if( InitStreaming() )
	{
        StartStreamingAudio();

		/* Adjust master volumes */
		AUDIOMixer(0x20000000,0x20000000);
					
		print_message( 1, "Playing...");
	}
	else
	{
		print_message( 1, "Failure!");
	}

	while(1);
}

