/*
 * Copyright (c) 2000 VM Labs, Inc.
 * All rights reserved.
 *
 * Confidential and Proprietary Information of VM Labs, Inc.
 */

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#include "vidoverlay.h"

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;

mmlDisplayPixmap	gl_screenbuffers[3];

// Indices into the gl_screenbuffers array

int					gl_drawbuffer = 0;
int					gl_displaybuffer = 1;
int					gl_overlaybuffer = 2;

int 				screenwidth = SCREENWIDTH;
int					screenheight = SCREENHEIGHT;
int					videofilter;
int					linewidths = 0;

int					videofilters[] = { eNoVideoFilter, eTwoTapVideoFilter, eFourTapVideoFilter };

////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// Create a full screen (720x480) image of the supplied frame buffer
////////////////////////////////////////////////////////////////////////////

void VideoSetup(mmlDisplayPixmap *main_pixmap, mmlDisplayPixmap *overlay_pixmap, int filter)
{
    VidDisplay display;
    VidChannel main_channel;
    VidChannel overlay_channel;
	int videomode;
					
    memset(&display, 0, sizeof(display));
    memset(&main_channel, 0, sizeof(main_channel));
    memset(&overlay_channel, 0, sizeof(overlay_channel));

	videomode = _VidQueryConfig(&display);
    display.dispwidth = -1;
    display.dispheight = -1;
    display.bordcolor = DEFAULT_BORDER_COLOR;
    display.progressive = 0;

	//////////////////////////////////////////////////////////////
	// This part controls the video signal...
	//////////////////////////////////////////////////////////////
    main_channel.dmaflags = main_pixmap->dmaFlags;
    main_channel.base = main_pixmap->memP;
    main_channel.dest_xoff = -1;
    main_channel.dest_yoff = -1;
	
	main_channel.dest_width = VIDEO_WIDTH;
	main_channel.dest_height = (videomode == VIDEO_MODE_NTSC) ? VIDEO_HEIGHT_NTSC : VIDEO_HEIGHT_PAL;  

	//////////////////////////////////////////////////////////////
	// The rest of this controls how the frame buffer is accessed
	//////////////////////////////////////////////////////////////
    main_channel.src_xoff = 0;
    main_channel.src_yoff = 0;
	main_channel.src_width = main_pixmap->wide;
    main_channel.src_height = main_pixmap->high;
    main_channel.vfilter = filter;
    main_channel.hfilter = VID_HFILTER_4TAP;

	//////////////////////////////////////////////////////////////
	// This part controls the video signal...
	//////////////////////////////////////////////////////////////
    overlay_channel.dmaflags = overlay_pixmap->dmaFlags;
    overlay_channel.base = overlay_pixmap->memP;
    overlay_channel.dest_xoff = -1;
    overlay_channel.dest_yoff = -1;

	overlay_channel.dest_width = VIDEO_WIDTH;
	overlay_channel.dest_height = (videomode == VIDEO_MODE_NTSC) ? VIDEO_HEIGHT_NTSC : VIDEO_HEIGHT_PAL;

#if (OVERLAY_BITS != 32)	
	overlay_channel.alpha = 0x80;
#else
	overlay_channel.alpha = 0xff;
#endif
	
	//////////////////////////////////////////////////////////////
	// Overlay channel information
	//////////////////////////////////////////////////////////////    
	overlay_channel.src_xoff = 0;
    overlay_channel.src_yoff = 0;
	overlay_channel.src_width = overlay_pixmap->wide;
    overlay_channel.src_height = overlay_pixmap->high;
    overlay_channel.vfilter = filter;
    overlay_channel.hfilter = VID_HFILTER_4TAP;

    _VidConfig(&display, &main_channel, &overlay_channel, (void *)0);

}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void reset_pixmap(int buf, int width, int height, int pixfmt )
{
long framebuf;

	framebuf = 0x40000000 + (0x200000 * buf);
	mmlInitDisplayPixmaps( &gl_screenbuffers[buf], &gl_sysRes, width, height, pixfmt, 1, (void *)framebuf );
}

void init_screenbuffers()
{
	gl_drawbuffer = 0;
	gl_displaybuffer = 1;
	gl_overlaybuffer = 2;
	
	reset_pixmap(gl_drawbuffer, SCREENWIDTH, SCREENHEIGHT, MAIN_PIXFORMAT );
    ClearScreen(&gl_screenbuffers[gl_drawbuffer], MAIN_BACKGROUND );
	
	reset_pixmap(gl_displaybuffer, SCREENWIDTH, SCREENHEIGHT, MAIN_PIXFORMAT );
	ClearScreen(&gl_screenbuffers[gl_displaybuffer], MAIN_BACKGROUND );

	reset_pixmap(gl_overlaybuffer, OVL_SCREENWIDTH, OVL_SCREENHEIGHT, OVERLAY_PIXFORMAT );
    ClearScreen(&gl_screenbuffers[gl_overlaybuffer], OVERLAY_BACKGROUND );

	VideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_screenbuffers[gl_overlaybuffer], videofilters[videofilter]);
}

void swap_screenbuffers()
{
int tmp;

	tmp = gl_displaybuffer;
	gl_displaybuffer = gl_drawbuffer;
	gl_drawbuffer = tmp;

	// Reset video hardware to new buffer   
	VideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_screenbuffers[gl_overlaybuffer], videofilters[videofilter]);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int main()
{
int overlay_height;
int original_overlay_height;

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	// Initialize graphics context
	mmlInitGC( &gl_gc, &gl_sysRes );	

	init_screenbuffers();
	original_overlay_height = gl_screenbuffers[gl_overlaybuffer].high;
	overlay_height = original_overlay_height;

	/* sit in a loop */
    while(1)
	{
		test_controller();

		gl_screenbuffers[gl_overlaybuffer].high = overlay_height--;
		if( overlay_height < (original_overlay_height / 5) )
			overlay_height = original_overlay_height;         

		// Draw the display
		create_display(&gl_screenbuffers[gl_drawbuffer], &gl_screenbuffers[gl_overlaybuffer] );
        
		// Point the video hardware at the display buffer
		swap_screenbuffers();
		
		// Wait for VBLANK
		_VidSync(1);
	}

	/* Never get here */
	return 0;
}

