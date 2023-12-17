/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdio.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>
#include <nuon/synth.h>
#include <nuon/bios.h>
#include <nuon/dma.h>

#define SCREENWIDTH		(360)
#define SCREENHEIGHT	(240)

#define clr_white 			(0xeb808000)	// RGB(255,255,255)
#define clr_black 			(0x10808000)	// RGB(0,0,0)
#define clr_light_red		(0x8bc66900)	// RGB(255,96,96)
#define clr_red 			(0x51f05b00)	// RGB(255,0,0)
#define clr_blue 			(0x296ff000)	// RGB(0,0,255)
#define clr_green 			(0x91233700)	// RGB(0,255,0)
#define clr_orange 			(0x92c13600)	// RGB(255,128,0)
#define clr_light_orange 	(0xb2c13600)	// RGB(255,128,0)
#define clr_light_blue		(0x7276c600)	// RGB(64,64,255)
#define clr_light_green		(0xb3465300)	// RGB(128,255,128)

#define BIG_VOLUME_STEP		(0x400000)
#define SMALL_VOLUME_STEP	(0x010000)
#define PAN_STEP			(0x200000)

///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;
int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

static AUDIO_RESOURCES audiorsc = { 1, 0, 0x40780000, 0 };

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void swap_screenbuffers(void);
void init_screenbuffers(void);
void clearscreen(mmlDisplayPixmap *scrn);

extern short Sine[];
extern short SineEnd[];
extern char MidiFile[];

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void adjust(long *musicvol, long *pcmvol, PCMPOS *Pan )
{
int signbit;

	if( ButtonCUp(_Controller[1]) )
		*musicvol += BIG_VOLUME_STEP;

	if( ButtonCDown(_Controller[1]) )
		*musicvol -= BIG_VOLUME_STEP;

	if( ButtonCLeft(_Controller[1]) )
		*musicvol -= SMALL_VOLUME_STEP;

	if( ButtonCRight(_Controller[1]) )
		*musicvol += SMALL_VOLUME_STEP;

	if( ButtonA(_Controller[1]) )
		*pcmvol += BIG_VOLUME_STEP;

	if( ButtonB(_Controller[1]) )
		*pcmvol -= BIG_VOLUME_STEP;

	if( ButtonR(_Controller[1]) )
		*pcmvol += SMALL_VOLUME_STEP;

	if( ButtonL(_Controller[1]) )
		*pcmvol -= SMALL_VOLUME_STEP;

	if( ButtonLeft(_Controller[1]) )
		Pan->PCMPanLR -= PAN_STEP;

	if( ButtonRight(_Controller[1]) )
		Pan->PCMPanLR += PAN_STEP;

	if( ButtonUp(_Controller[1]) )
		Pan->PCMPanFB += PAN_STEP;

	if( ButtonDown(_Controller[1]) )
		Pan->PCMPanFB -= PAN_STEP;

	if( *pcmvol > 0x40000000 )
		*pcmvol = 0x40000000;

	if( *pcmvol < 0 )
		*pcmvol = 0;

	signbit = Pan->PCMPanFB & 0x80000000;
	Pan->PCMPanFB &= 0x7FFFFFFF;
	if( Pan->PCMPanFB > 0x40000000 )
		Pan->PCMPanFB = 0x40000000;
	Pan->PCMPanFB |= signbit;

	signbit = Pan->PCMPanLR & 0x80000000;
	Pan->PCMPanLR &= 0x7FFFFFFF;
	if( Pan->PCMPanLR > 0x40000000 )
		Pan->PCMPanLR = 0x40000000;
	Pan->PCMPanLR |= signbit;

}


void draw_screen(long musicvol, long pcmvol, PCMPOS *Pan )
{
char str[100];
	
	clearscreen(&gl_screenbuffers[gl_drawbuffer]);

	sprintf( str, "PCM Volume = 0x%08lx\n", pcmvol );
	DebugWS( gl_screenbuffers[gl_drawbuffer].dmaFlags, gl_screenbuffers[gl_drawbuffer].memP, 30, 30, kWhite, str );

	sprintf( str, "MIDI Volume = 0x%08lx\n", musicvol );
	DebugWS( gl_screenbuffers[gl_drawbuffer].dmaFlags, gl_screenbuffers[gl_drawbuffer].memP, 30, 45, kWhite, str );

	sprintf( str, "Pan Left/Right = 0x%08lx\n", Pan->PCMPanLR );
	DebugWS( gl_screenbuffers[gl_drawbuffer].dmaFlags, gl_screenbuffers[gl_drawbuffer].memP, 30, 75, kWhite, str );

	sprintf( str, "Pan Front/Back = 0x%08lx\n", Pan->PCMPanFB );
	DebugWS( gl_screenbuffers[gl_drawbuffer].dmaFlags, gl_screenbuffers[gl_drawbuffer].memP, 30, 90, kWhite, str );
	
	swap_screenbuffers();
}

int main()
{
PCMPOS Pan;
PCMHEAD WaveDefine;
long musicvol, pcmvol;
int voice;

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	AUDIOInitX(&audiorsc);

	// Start MIDI File playing
	SYNTHStartMidiParser((long)MidiFile);

	// Setup and start PCM sound playing
    WaveDefine.PCMWaveBegin = (unsigned long)Sine;
    WaveDefine.PCMLength    = SineEnd - Sine;
    WaveDefine.PCMLoopBegin = 0;
    WaveDefine.PCMLoopEnd   = SineEnd - Sine;
    WaveDefine.PCMBaseFreq  = 0x2000;
    WaveDefine.PCMControl   = 1;

    Pan.PCMPanLR = 0;
    Pan.PCMPanFB = 0;
    Pan.PCMPanUD = 0;

	voice = PCMPlaySample(-1, &WaveDefine, &Pan, 0x40000000, 0x40000000);
	
	pcmvol = 0x20000000;
	musicvol = 0x20000000;

	while(1) 
	{
		adjust( &musicvol, &pcmvol, &Pan );

        AUDIOMixer(musicvol,pcmvol);
        PCMSetPanLR( voice, Pan.PCMPanLR );
		PCMSetPanFB( voice, Pan.PCMPanFB );

		draw_screen( pcmvol, musicvol, &Pan );
		_VidSync(1);      
	}
}

////////////////////////////////////////////////////////////////////////////
// Swap draw and display buffers.  Takes effect next VBLANK
////////////////////////////////////////////////////////////////////////////

void swap_screenbuffers()
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

void init_screenbuffers()
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


