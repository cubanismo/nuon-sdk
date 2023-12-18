/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "sg.h"


// This version of display_score takes the score and bestscore values
// passed by game.c or demo.c.  The bestscore values are stored in an
// extern table and so not forgotten when (for example) moving from
// game to demo and back to game again
// Note: "mode" doesn't appear to be used in ftn
int display_score2(mmlFontContext fc, mmlFont sysP, int x, int y, int mode, int displayFPS, double framespersec, int score, int bestscore)
{

  extern int PixMap;
  extern  mmlDisplayPixmap screen[3];

  m2dRect r;
  textCode t[60];
  int len;

  //  mmlSetTextProperties(fc, sysP, 15, kBlack, kBlackff, eOpaque, 0,0);
  mmlSetTextProperties(fc, sysP, 15, kBlack, kGrey, eBlend, 0,0);

  m2dSetRect( &r, x, y, SCRN_WIDTH, y+15 );    
  len = sprintf(t, "Score: %d", score);
  mmlSimpleDrawText( fc, &screen[PixMap], t, len, &r );

  // print Best Score so far
  m2dSetRect( &r, x+120, y, SCRN_WIDTH, y+15 );    
  len = sprintf(t, "Best Score: %d", bestscore);
  mmlSimpleDrawText( fc, &screen[PixMap], t, len, &r );

  if (displayFPS == 1){
    if ((SOURCE_WIDTH == 512) && (SOURCE_HEIGHT == 352)){
      m2dSetRect( &r, 95, 308, SCRN_WIDTH, 308+15 );    
    }else{
      m2dSetRect( &r, 130, 215, SCRN_WIDTH, 215+15 );    
    }
    len = sprintf(t, "FPS: %3.1f", framespersec);
    mmlSimpleDrawText( fc, &screen[PixMap], t, len, &r );
  }

  return 0;
}


// returns a non-zero positive bonus if all the balls have 
// been cleared, otherwise returns zero
int det_bonus(int n_colours, int current_score)
{
  int bonus = 0;

  // check to see if all balls have been cleared
  if (Balls.colour[0][ROW_NUM-1] == -99){
    //calculate bonus, for 3 colours double current score, for 4
    //colours mult by 4
    bonus = current_score * pow(2,(n_colours-2));
  }

  return bonus;
}
