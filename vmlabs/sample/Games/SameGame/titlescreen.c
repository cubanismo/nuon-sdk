/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "sg.h"

// draws the title screen which contains the menu
//
int title(mmlFontContext fc, mmlFont sysP, int currentB, int diff)
{
  extern int PixMap;
  extern mmlDisplayPixmap screen[3];

  int x, y;

  x = 0;
  y = 0;

  /***************************************************/
  // RENDERING PART:
  // switch screens (note that we are triple buffering)
  PixMap = (PixMap < 2) ? (PixMap+1) : 0;
  // check that last screen is finished drawning on TV
  // (we are no longer doing this as we are triple buffering)
  //    _VidSync(0);
  // bring in the title background picture
  MyCopyRect(0, 0, SOURCE_WIDTH-1, SOURCE_HEIGHT-1, &titlebackgrnd, 
             0, 0, &screen[PixMap]);
  /***************************************************/

  // decide where to put the pointer; the values for PTR_PLAY_X
  // and PTR_PLAY_Y are in sg.cnf
  switch (currentB){
  case 0:   // Play  
    x = PTR_PLAY_X; 
    y = PTR_PLAY_Y; 
    break;
  case 1:   // Level
    x = PTR_LEVEL_X;
    y = PTR_LEVEL_Y;
    break;
  case 2:   // Demo
    x = PTR_DEMO_X;
    y = PTR_DEMO_Y;
    break;
  case 3:   // Exit
    x = PTR_EXIT_X;
    y = PTR_EXIT_Y;
    break;
  default:
    break;
  }


  // copy the pointer to the screen
  if (PTR_TITLE_TRANSPARENT == 1){
    MyCopyRectTrans(PTR_L_X, PTR_L_Y, PTR_R_X, PTR_R_Y, &playagain, 
		    x, y, &screen[PixMap]);
  }else{
    MyCopyRect(PTR_L_X, PTR_L_Y, PTR_R_X, PTR_R_Y, &playagain, 
	       x, y, &screen[PixMap]);
  }

  // we always have a pointer to the current difficulty level 
  switch (diff){
  case 0:  // Normal
    x = PTR2_NORM_X;
    y = PTR2_NORM_Y;
    break;
  case 1:  // Challenge
    x = PTR2_CHALLENGE_X;
    y = PTR2_CHALLENGE_Y;
    break;
  case 2:  // Super Challenge
    x = PTR2_SUPERCHAL_X;
    y = PTR2_SUPERCHAL_Y;
    break;
  default:
    break;
  }

  // copy pointer2
  if (PTR_TITLE_TRANSPARENT == 1){
    MyCopyRectTrans(PTR2_L_X, PTR2_L_Y, PTR2_R_X, PTR2_R_Y, &playagain, 
		    x, y, &screen[PixMap]);
  }else{
    MyCopyRect(PTR2_L_X, PTR2_L_Y, PTR2_R_X, PTR2_R_Y, &playagain, 
	       x, y, &screen[PixMap]);
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


  return 0;
  
}
