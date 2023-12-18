/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "sg.h"


// this version copies in one of two "play again" pictures from the
// appropriate tga file (playagain.tga)
int play_again2(mmlFontContext fc, mmlFont sysP, int Score, int bestscore)
{
  extern int PixMap;
  extern  mmlDisplayPixmap screen[3];

  long joy_edge;

  int exit = 0;
  int yes = 1;


  while (!exit){

    // poll the joystick
    joy_edge = getkey();  

    if ((joy_edge & JOY_A) || (joy_edge & JOY_B)){
      if (yes == 1){
	return 1;
      }else{
	exit = 1;
      }
    }
    
    if ((joy_edge & JOY_LEFT) || (joy_edge & JOY_RIGHT)){
      if (Click.length > 0)
	PlaySound(&Click, 0xffff);
      yes ^= 1;
    }

    /***************************************************/
    // RENDERING PART:
    // switch screens
    PixMap = (PixMap < 2) ? PixMap+1 : 0;
    /***************************************************/

    // First draw the balls table and the score
    //
    // keep drawing the remaining balls, there should be no groups
    // left and so no groups with group number equal 1
    //
    // use high_lite_group2 instead of high_lite_group3 so that
    // the cursor doesn't get drawn (looks "cleaner")
    high_lite_group2(1);

    // display the score; pass a "1" as we are always in game mode
    display_score2(fc, sysP, SCORE_X, SCORE_Y, 1, 0, 0, Score, bestscore);

    // now the "play again" blits use transparency; looks better
    if (yes == 1){
      MyCopyRectTrans(PLAY1_L_X, PLAY1_L_Y, PLAY1_R_X, PLAY1_R_Y, &playagain, 
                      PLAY_L_X, PLAY_L_Y, &screen[PixMap]);
    }else{
      MyCopyRectTrans(PLAY2_L_X, PLAY2_L_Y, PLAY2_R_X, PLAY2_R_Y, &playagain, 
                      PLAY_L_X, PLAY_L_Y, &screen[PixMap]);
    }

    /*************************************************************/
    // DISPLAY SCREEN
    My_ConfigMain( &video_ch, &screen[PixMap], 0, 0 );
    if (VFILT_4TAP == 1){
      video_ch.vfilter = VID_VFILTER_4TAP;
    }else{
      video_ch.vfilter = VID_VFILTER_2TAP;
    }
    _VidConfig(&display, &video_ch, (void *)0, (void *)0);
    /*************************************************************/
    
  }

  return 0;
}

