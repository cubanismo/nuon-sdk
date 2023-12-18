/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */


/* Initialize the system resources and graphics context to a default state.*/
  mmlPowerUpGraphics( &sysRes );
  mmlInitGC( &gc, &sysRes );


/* SETUP FONTS */
  mmlInitFontContext( &gc, &sysRes, &fc, 16000 );
  sysP = mmlAddFont(fc, "sysFont", eT2K, SysFontBold, SysFontBoldEnd-SysFontBold);  
//  mmlInitFontContext( &gc, &sysRes, &fc, 16000 );
//  sysP = mmlAddFont(fc, "sysFont", eT2K, SysFont, SysFontEnd-SysFont);

// more font stuff
  mmlSetTextProperties(fc, sysP, 15, kBlack, kGrey, eBlend, 0, 0); 

// Initialize a single display pixmap as a framebuffer to be used as
// main channel SOURCE_WIDTH pixels wide by SOURCE_HEIGHT lines tall.
  mmlInitDisplayPixmaps( screen, &sysRes, SOURCE_WIDTH, SOURCE_HEIGHT, e888Alpha, 3, NULL );


// READ IN THE ARTWORK

/* read in the tiles */
  mmlInitDisplayPixmaps( &balls, &sysRes, 256, 256, e888Alpha, 1, NULL );
  sprintf(text, "%stiles.tga", Path);
  ReadTGAfrmFile(text, balls.dmaFlags, balls.memP);

/* read in the game background picture */
  mmlInitDisplayPixmaps( &background, &sysRes, SOURCE_WIDTH, SOURCE_HEIGHT, e888Alpha, 1, NULL );
  sprintf(text, "%sbackground.tga", Path);
  ReadTGAfrmFile(text, background.dmaFlags, background.memP);

// read in the mats; up to 10 mats max
if (MATS > 0){
  for (i = 0; i < NUM_MATS; i++){
    // note: height of these DisplayPixmaps must be a multiple of 16
    mmlInitDisplayPixmaps( &mats[i], &sysRes, 288, 192, e888Alpha, 1, NULL );
    sprintf(text, "%sMat%d.tga", Path, i);
    ReadTGAfrmFile(text, mats[i].dmaFlags, mats[i].memP);
  }
}

if (NUM_ANIM_STEPS > 0){ 
  // read in the animation artwork  NOTE: size is assumed 352x272
  mmlInitDisplayPixmaps( &anim, &sysRes, 352, 272, e888Alpha, 1, NULL );
  sprintf(text, "%sanimate.tga", Path);
  ReadTGAfrmFile(text, anim.dmaFlags, anim.memP);
}

// read in the extra artwork
  mmlInitDisplayPixmaps( &playagain, &sysRes, 256, 256, e888Alpha, 1, NULL );
  sprintf(text, "%sextra.tga", Path);
  ReadTGAfrmFile(text, playagain.dmaFlags, playagain.memP);

// read in the title screen picture
  mmlInitDisplayPixmaps( &titlebackgrnd, &sysRes, SOURCE_WIDTH, SOURCE_HEIGHT, e888Alpha, 1, NULL );
  sprintf(text, "%stitle_pic.tga", Path);
  ReadTGAfrmFile(text, titlebackgrnd.dmaFlags, titlebackgrnd.memP);


// READ IN SOUNDS

// Read in the sounds which are located in the appropiate folder
// in the Contents directory.
// Whenever ReadSound fails, the sound.length is set equal to 0, 
// and we always check for this before playing the sound.  Thus
// the game will run ok even if a sound file is not found.

  sprintf(text, "%sclick.raw", Path);
  ReadSound(text, &Click);

  sprintf(text, "%schangetile.raw", Path);
  ReadSound(text, &ChangeTile);

  sprintf(text, "%sbigdelete.raw", Path);
  ReadSound(text, &BigDelete);

  sprintf(text, "%sbigdeleteall.raw", Path);
  ReadSound(text, &BigDeleteAll);

  sprintf(text, "%sbonus.raw", Path);
  ReadSound(text, &Bonus);

  sprintf(text, "%snobonus.raw", Path);
  ReadSound(text, &NoBonus);

// initialize the audio libraries
  AUDIOInit();



/* Set the screen display pixmaps to gray */
  m2dFillColr( &gc, &screen[0], NULL, kGrey );
  m2dFillColr( &gc, &screen[1], NULL, kGrey );
  m2dFillColr( &gc, &screen[2], NULL, kGrey );

/* Initialize the display configuration */
  memset(&display, 0, sizeof(display));
  display.dispwidth = -1;
  display.dispheight = -1;
  display.bordcolor = DEFAULT_BORDER_COLOR;
  display.progressive = 0;

/* Initialize the main channel from the main display pixmap */
//  My_ConfigMain( &mainch, &background, 0, 0 );


// Initialize the video channel from the screen display pixmap
  mmlConfigOSD( &video_ch, &screen[0], 0, 0, 1 );


/* Configure the VDG channels and activate them */
  _VidConfig(&display, &video_ch, (void *)0, (void *)0);

