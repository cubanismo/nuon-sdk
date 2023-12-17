
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
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

// Set up the black loading screen
   mmlInitDisplayPixmaps(&loading, &sysRes, 720, 480, e888Alpha,1,NULL);
   m2dFillColr( &gc, &loading, NULL, kBlack );
// Print "loading" word while pictures and sounds are being read in
   mmlSetTextProperties(fc, sysP, 50, kWhite, kBlack, eBlend, 0,0);
   m2dSetRect( &r, 285, 150, 480, 150+50 );    
   i = sprintf(text, "Loading");  // i is the length of the text
   mmlSimpleDrawText( fc, &loading, text, i, &r );
// set text back where it was (not sure this is necessary, but hey)
   mmlSetTextProperties(fc, sysP, 15, kBlack, kGrey, eBlend, 0, 0); 

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
//  mmlConfigOSD( &video_ch, &screen[0], 0, 0, 1 );
  mmlConfigOSD( &video_ch, &loading, 0, 0, 1 );

/* Configure the VDG channels and activate them */
  _VidConfig(&display, &video_ch, (void *)0, (void *)0);


//////////////////////////////////////////////////////
// If USE_DATA_FILE is 1 then art (and sounds) are read
// from the DATA_FILE.  Otherwise we use the Path variable 
// specified in sg.cnf 


// READ IN THE ARTWORK

/* read in the tiles */
  mmlInitDisplayPixmaps( &balls, &sysRes, 256, 256, e888Alpha, 1, NULL );
  if (!USE_DATA_FILE){
    sprintf(text, "%stiles.tga", Path);
    ReadTGAfrmFile(text, balls.dmaFlags, balls.memP);
  }else{
    ReadTGAfrmDatFile("tiles.tga", balls.dmaFlags, balls.memP);
  }

/* read in the game background picture */
  mmlInitDisplayPixmaps( &background, &sysRes, SOURCE_WIDTH, SOURCE_HEIGHT, e888Alpha, 1, NULL );
  if (!USE_DATA_FILE){
    sprintf(text, "%sbackground.tga", Path);
    ReadTGAfrmFile(text, background.dmaFlags, background.memP);
  }else{
    ReadTGAfrmDatFile("background.tga", background.dmaFlags, background.memP);
  }

// for the background mat (picture uncovered when deleting tiles)
//  mmlInitDisplayPixmaps( &backgrnd_pic, &sysRes, 288, 192, e888Alpha, 1, NULL );
  mmlInitDisplayPixmaps( &backgrnd_pic, &sysRes, TGA_WIDTH, TGA_HEIGHT, e888Alpha, 1, NULL );


// read in the animation
if (NUM_ANIM_STEPS > 0){ 
  // read in the animation artwork  NOTE: size is assumed 352x272
  mmlInitDisplayPixmaps( &anim, &sysRes, 352, 272, e888Alpha, 1, NULL );
  if (!USE_DATA_FILE){
    sprintf(text, "%sanimate.tga", Path);
    ReadTGAfrmFile(text, anim.dmaFlags, anim.memP);
  }else{
    ReadTGAfrmDatFile("animate.tga", anim.dmaFlags, anim.memP);
  }
}

// read in the extra artwork
  mmlInitDisplayPixmaps( &playagain, &sysRes, 256, 256, e888Alpha, 1, NULL );
  if (!USE_DATA_FILE){
    sprintf(text, "%sextra.tga", Path);
    ReadTGAfrmFile(text, playagain.dmaFlags, playagain.memP);
  }else{
    ReadTGAfrmDatFile("extra.tga", playagain.dmaFlags, playagain.memP);
  }

// read in the title screen picture
  mmlInitDisplayPixmaps( &titlebackgrnd, &sysRes, SOURCE_WIDTH, SOURCE_HEIGHT, e888Alpha, 1, NULL );
  if (!USE_DATA_FILE){
    sprintf(text, "%stitle_pic.tga", Path);
    ReadTGAfrmFile(text, titlebackgrnd.dmaFlags, titlebackgrnd.memP);
  }else{
    ReadTGAfrmDatFile("title_pic.tga", titlebackgrnd.dmaFlags, titlebackgrnd.memP);
  }


// READ IN SOUNDS

// Read in the sounds which are located in the appropiate folder in
// the Contents directory OR in sg.dat
//
// Whenever ReadSound fails, the sound.length is set equal to 0, 
// and we always check for this before playing the sound.  Thus
// the game will run ok even if a sound file is not found.


  if (!USE_DATA_FILE){
    sprintf(text, "%sclick.raw", Path);
    ReadSound(text, &Click);
  }else{
    ReadSoundfrmDatFile("click.raw", &Click);
  }

  if (!USE_DATA_FILE){
    sprintf(text, "%schangetile.raw", Path);
    ReadSound(text, &ChangeTile);
  }else{
    ReadSoundfrmDatFile("changetile.raw", &ChangeTile);
  }

  if (!USE_DATA_FILE){
    sprintf(text, "%sbigdelete.raw", Path);
    ReadSound(text, &BigDelete);
  }else{
    ReadSoundfrmDatFile("bigdelete.raw", &BigDelete);
  }

  if (!USE_DATA_FILE){
    sprintf(text, "%sbigdeleteall.raw", Path);
    ReadSound(text, &BigDeleteAll);
  }else{
    ReadSoundfrmDatFile("bigdeleteall.raw", &BigDeleteAll);
  }

  if (!USE_DATA_FILE){
    sprintf(text, "%sbonus.raw", Path);
    ReadSound(text, &Bonus);
  }else{
    ReadSoundfrmDatFile("bonus.raw", &Bonus);
  }

  if (!USE_DATA_FILE){
    sprintf(text, "%snobonus.raw", Path);
    ReadSound(text, &NoBonus);
  }else{
    ReadSoundfrmDatFile("nobonus.raw", &NoBonus);
  }


// initialize the audio libraries
  AUDIOInit();

