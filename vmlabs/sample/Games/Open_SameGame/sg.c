
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include "sg.h"
#include "sg_xtract.h"

// balltable contains the rectangles which will contain the tiles this
// information used in the high_lite_group ftn
m2dRect balltable[5][4];

// animtable contains the rectangles which specify the tiles for the
// animation sequences; right now we assume no more than a max of 10
// steps for each sequence (and all tiles much have the same number
// of steps in the same game)
m2dRect animtable[8][10];

int PixMap;
int Score = 0;
int Highest_Score = 0;

// set some default values for SameGame (values taken from Generic setup, I think); these
// should be overwritten by the contents of sg.cnf
char Path[128] = "Contents/Generic/";
int SOURCE_WIDTH=360, SOURCE_HEIGHT=240, SCRN_WIDTH=360, SCRN_HEIGHT=240;
int VFILT_4TAP=1, COL_NUM=9, ROW_NUM=6, SQU_WIDTH=31, UP_LEFT_X=40, UP_LEFT_Y=16;
int BOTTOM_RT_X=319, BOTTOM_RT_Y=202, MATS=1, NUM_MATS=3, MAT_WIDTH=279, MAT_HEIGHT=186;
int TGA_WIDTH = 288, TGA_HEIGHT = 192, NUM_ANIM_STEPS=10;
int TILE_TRANSPARENCY=0, INV_R=182, INV_G=226, INV_B=61, CURSOR_WIDTH=10, CURSOR_RAD=5;
int CUR_SPEED=150, CUR_L_X=120, CUR_L_Y=0, CUR_R_X=129, CUR_R_Y=9, PTR_L_X=100, PTR_L_Y=0;
int PTR_R_X=112, PTR_R_Y=10, PTR_PLAY_X=137, PTR_PLAY_Y=68, PTR_LEVEL_X=137, PTR_LEVEL_Y=94;
int PTR_DEMO_X=137, PTR_DEMO_Y=171, PTR_EXIT_X=137, PTR_EXIT_Y=192, PTR2_L_X=100, PTR2_L_Y=0;
int PTR2_R_X=112, PTR2_R_Y=10, PTR2_NORM_X=140, PTR2_NORM_Y=110, PTR2_CHALLENGE_X=140;
int PTR2_CHALLENGE_Y=128, PTR2_SUPERCHAL_X=140, PTR2_SUPERCHAL_Y=145;
int PTR_TITLE_TRANSPARENT=0, NUM_DEMO_GAMES=4, PLAY1_L_X=0, PLAY1_L_Y=50;
int PLAY1_R_X=79, PLAY1_R_Y=85, PLAY2_L_X=0, PLAY2_L_Y=0, PLAY2_R_X=79, PLAY2_R_Y=35;
int PLAY_L_X=141, PLAY_L_Y=12, SCORE_X=65, SCORE_Y=203;

// variables to be loaded in from sg.cnf
//
struct Variables Variables[] = {
  {"VFILT_4TAP", &VFILT_4TAP, 0},
  {"SOURCE_WIDTH", &SOURCE_WIDTH, 0},
  {"SOURCE_HEIGHT", &SOURCE_HEIGHT, 0},
  {"SCRN_WIDTH", &SCRN_WIDTH, 0},
  {"SCRN_HEIGHT", &SCRN_HEIGHT, 0},
  {"COL_NUM", &COL_NUM, 0},
  {"ROW_NUM", &ROW_NUM, 0},
  {"SQU_WIDTH", &SQU_WIDTH, 0},
  {"UP_LEFT_X", &UP_LEFT_X, 0},
  {"UP_LEFT_Y", &UP_LEFT_Y, 0},
  {"MATS", &MATS, 0},
  {"NUM_MATS", &NUM_MATS, 0},
  {"MAT_WIDTH", &MAT_WIDTH, 0},
  {"MAT_HEIGHT", &MAT_HEIGHT, 0},
  {"TGA_WIDTH", &TGA_WIDTH, 0},
  {"TGA_HEIGHT", &TGA_HEIGHT, 0},
  {"NUM_ANIM_STEPS", &NUM_ANIM_STEPS, 0},
  {"TILE_TRANSPARENCY", &TILE_TRANSPARENCY, 0},
  {"INV_R", &INV_R, 0},
  {"INV_G", &INV_G, 0},
  {"INV_B", &INV_B, 0},
  {"CURSOR_WIDTH", &CURSOR_WIDTH, 0},
  {"CURSOR_RAD", &CURSOR_RAD, 0},
  {"CUR_SPEED", &CUR_SPEED, 0},
  {"CUR_L_X", &CUR_L_X, 0},
  {"CUR_L_Y", &CUR_L_Y, 0},
  {"CUR_R_X", &CUR_R_X, 0},
  {"CUR_R_Y", &CUR_R_Y, 0},
  {"PTR_L_X", &PTR_L_X, 0},
  {"PTR_L_Y", &PTR_L_Y, 0},
  {"PTR_R_X", &PTR_R_X, 0},
  {"PTR_R_Y", &PTR_R_Y, 0},
  {"PTR_PLAY_X", &PTR_PLAY_X, 0},
  {"PTR_PLAY_Y", &PTR_PLAY_Y, 0},
  {"PTR_LEVEL_X", &PTR_LEVEL_X, 0},
  {"PTR_LEVEL_Y", &PTR_LEVEL_Y, 0},
  {"PTR_DEMO_X", &PTR_DEMO_X, 0},
  {"PTR_DEMO_Y", &PTR_DEMO_Y, 0},
  {"PTR_EXIT_X", &PTR_EXIT_X, 0},
  {"PTR_EXIT_Y", &PTR_EXIT_Y, 0},
  {"PTR2_L_X", &PTR2_L_X, 0},
  {"PTR2_L_Y", &PTR2_L_Y, 0},
  {"PTR2_R_X", &PTR2_R_X, 0},
  {"PTR2_R_Y", &PTR2_R_Y, 0},
  {"PTR2_NORM_X", &PTR2_NORM_X, 0},
  {"PTR2_NORM_Y", &PTR2_NORM_Y, 0},
  {"PTR2_CHALLENGE_X", &PTR2_CHALLENGE_X, 0},
  {"PTR2_CHALLENGE_Y", &PTR2_CHALLENGE_Y, 0},
  {"PTR2_SUPERCHAL_X", &PTR2_SUPERCHAL_X, 0},
  {"PTR2_SUPERCHAL_Y", &PTR2_SUPERCHAL_Y, 0},
  {"PTR_TITLE_TRANSPARENT", &PTR_TITLE_TRANSPARENT, 0},
  {"NUM_DEMO_GAMES", &NUM_DEMO_GAMES, 0},
  {"PLAY1_L_X", &PLAY1_L_X, 0},
  {"PLAY1_L_Y", &PLAY1_L_Y, 0},
  {"PLAY1_R_X", &PLAY1_R_X, 0},
  {"PLAY1_R_Y", &PLAY1_R_Y, 0},
  {"PLAY2_L_X", &PLAY2_L_X, 0},
  {"PLAY2_L_Y", &PLAY2_L_Y, 0},
  {"PLAY2_R_X", &PLAY2_R_X, 0},
  {"PLAY2_R_Y", &PLAY2_R_Y, 0},
  {"PLAY_L_X", &PLAY_L_X, 0},
  {"PLAY_L_Y", &PLAY_L_Y, 0},
  {"SCORE_X", &SCORE_X, 0},
  {"SCORE_Y", &SCORE_Y, 0},
  {NULL, NULL, 0}
  };

// SameGame has up to 6 game sounds
struct Sound Click, ChangeTile, BigDelete, BigDeleteAll, Bonus, NoBonus;

// load in sg.dat at compile time
extern char datapick[];
asm(".data\n.align.s \n _datapick:: .binclude \"sg.dat\"\n.text ");


int main( )
{
  long joy_edge;
  clock_t tBeg, tEnd;
  int exit, currentB, diff, numButtons;
  int i, x, y, sw, sq;
  int j, k;
  double sec;

  // for writing text
  char text[128];
  m2dRect r;

  extern int PixMap;

  extern m2dRect balltable[5][4];

  // for writing the text
  mmlFont sysP;
  mmlFontContext fc;


  // read the index part of output.dat (first 6K) into structure The_Index
  if (USE_DATA_FILE)
    read_in_index(DATA_FILE);

  // read in the config file "sg.cnf" which is either in the
  // current directory along with sg.cof, or in sg.dat
  if (Read_CNF_File() < 0)
    return -1;

  // calculate bottom right corner of the table based on the info read
  // from sg.cnf above
  BOTTOM_RT_X = (UP_LEFT_X + (SQU_WIDTH * COL_NUM));
  BOTTOM_RT_Y = (UP_LEFT_Y + (SQU_WIDTH * ROW_NUM));

  // To Do: check that values in sg.cnf are within bounds

  // check to see if the sg.cnf file contained all anticipated settings
  i = 0;
  while (Variables[i].Name != NULL){ 
    if (Variables[i].Flag == 0){
      if (ON_DVD == 0)
	printf("The variable %s wasn't found in sg.cnf.  Using a default value which may or may not work.\n", Variables[i].Name);
    }
    i++;
  }

  // check to see if table size is within range
  if ((COL_NUM > MAX_COL_NUM) || (ROW_NUM > MAX_ROW_NUM)){
    if (ON_DVD == 0)
	printf("ROW_NUM exceeds 15 or COL_NUM exceeds 20\n");
    return -1;
  };


  // lots 'o code to set up sysRes, fonts, and DisplayPixmaps; also
  // reads in the artwork and the sounds; as this code is seldom 
  // modified and as it takes up several screens, we tuck it away in
  // init_nuon.c
#include "init_nuon.c"


  // the initial screen
  PixMap = 0;


/********************************************************/
// set up the rectangles which grab the blits in tiles.tga; the
// width=height of the tiles is given by SQU_WIDTH and we assume each
// tile in tiles.tga has a 1 pixel border around it

  // needed to calculate the rectanges
  sw = SQU_WIDTH - 1;

  m2dSetRect( &balltable[0][0], 1,        1, 1+sw, 1+sw);
  m2dSetRect( &balltable[0][1], 1, 3+(1*sw), 1+sw, 3+(2*sw));
  m2dSetRect( &balltable[0][2], 1, 5+(2*sw), 1+sw, 5+(3*sw));
  m2dSetRect( &balltable[0][3], 1, 7+(3*sw), 1+sw, 7+(4*sw));

  m2dSetRect( &balltable[1][0], 3+sw,        1, 3+(2*sw), 1+sw);
  m2dSetRect( &balltable[1][1], 3+sw,     3+sw, 3+(2*sw), 3+(2*sw));
  m2dSetRect( &balltable[1][2], 3+sw, 5+(2*sw), 3+(2*sw), 5+(3*sw));
  m2dSetRect( &balltable[1][3], 3+sw, 7+(3*sw), 3+(2*sw), 7+(4*sw));


  m2dSetRect( &balltable[2][0], 5+(2*sw),        1, 5+(3*sw), 1+sw);
  m2dSetRect( &balltable[2][1], 5+(2*sw),     3+sw, 5+(3*sw), 3+(2*sw));
  m2dSetRect( &balltable[2][2], 5+(2*sw), 5+(2*sw), 5+(3*sw), 5+(3*sw));
  m2dSetRect( &balltable[2][3], 5+(2*sw), 7+(3*sw), 5+(3*sw), 7+(4*sw));


  m2dSetRect( &balltable[3][0], 7+(3*sw),        1, 7+(4*sw), 1+sw);
  m2dSetRect( &balltable[3][1], 7+(3*sw),     3+sw, 7+(4*sw), 3+(2*sw));
  m2dSetRect( &balltable[3][2], 7+(3*sw), 5+(2*sw), 7+(4*sw), 5+(3*sw));
  m2dSetRect( &balltable[3][3], 7+(3*sw), 7+(3*sw), 7+(4*sw), 7+(4*sw));

/********************************************************/

  /************************************************************/
  // set up the rectangles which grab blits for the animation; note
  // that here we make the dimensions dependent on SQU_WIDTH as done
  // above for the balltable setup
  //
  // turns out I didn't need sw, sq is more direct and to the point
  sq = SQU_WIDTH;

  // load the rectangle coordinates of the animation tiles into the 
  // animation table; this is the looped (and much, much shorter)
  // version of all code below
  //
  // note that we assume there are 8 different types of animation tiles;
  // one for each of the 4 different types plus the four special tiles
  for (j = 0; j < 8; j++)
    for (k = 0; k < NUM_ANIM_STEPS; k++){
      m2dSetRect( &animtable[j][k], (k+1)+(k*sq), (j+1)+(j*sq), k+((k+1)*sq), j+((j+1)*sq));
    }
  /************************************************************/



  // initialize Best scores 
  for (i = 0; i < 2; i++)
    Best_Scores.Demo[i] = 0;
  for (i = 0; i < 3; i++)
    Best_Scores.Game[i] = 0;


  // initialize main menu
  currentB = 0;
  diff = 0;
  numButtons = 4;

  // initialize everything else 
  x = 0;
  y = 0;
  exit = 0;

  // look at the clock; after 4 minutes of inactivity the demo will
  // automatically start; if there is any activity in the title screen
  // (moving the cursor, playing a game, etc) then tBeg will be set to
  // the current time after such activity ends
  tBeg = clock();

  while (!exit){

    // poll the joystick
    joy_edge = getkey();  

    if ((joy_edge & JOY_A)){
      switch (currentB) {
      case 0: case 1: 	// play the game
	// note: we can go straight into the game from "Level" button
	if (diff == 0)
	  game(fc, sysP, 3, 0); 
	if (diff == 1)
	  game(fc, sysP, 4, 1); 
	if (diff == 2)
	  game(fc, sysP, 4, 0); 
	tBeg = clock();
	break;
      case 2:  // run demo
	if (diff == 0)
	  demo(fc, sysP, 3); 
	if ((diff == 1) || (diff == 2))
	  demo(fc, sysP, 4); 
	tBeg = clock();
	break;
      case 3: // exit game
	exit = 1;
	break;
      default: 
	break;
      }
    }

    if ((joy_edge & JOY_LEFT) || (joy_edge & JOY_RIGHT)){
      switch (currentB){
      case 1: 
	if (Click.length > 0)
	  PlaySound(&Click, 0xffff);
	// cycle level difficulty 
	diff = (diff < 2) ? diff+1 : 0;
	tBeg = clock();
	break;
      default:
	break;
      }
    }

    // cycle through menu options
    if (joy_edge & JOY_UP){
      // cycle up
	if (Click.length > 0)
	  PlaySound(&Click, 0xffff);
      currentB = (currentB == 0) ? (numButtons-1) : currentB-1;
      tBeg = clock();
      }
    if (joy_edge & JOY_DOWN){
      // cycle down
	if (Click.length > 0)
	  PlaySound(&Click, 0xffff);
      currentB = (currentB == (numButtons-1)) ? 0 : currentB+1;
      tBeg = clock();
      }

    // after 4 minutes of no activity start the demo
    tEnd = clock();
    sec = (tEnd>tBeg) ? (double)(tEnd-tBeg)/(CLOCKS_PER_SEC) : -99;
    if (sec > 240){      // 4 min = 240 seconds
      i = (diff == 0) ? 3 : 4;
      // start demo
      demo(fc, sysP, i); 
      tBeg = clock();
    }

    // draw title screen
    title(fc, sysP, currentB, diff);
    
  }  // end of "while (!exit){"

  _BiosReboot();
  return 0;
}


// ftn to poll the joystick
long getkey()
{
  long new_joy;
  long joy_edge;
  static long last_joy;

  // get joystick button(s) pressed (check joypad and IR remote)
  new_joy = (_Controller[1].buttonset | _Controller[0].buttonset);
  // isolate the (pressed) buttons which were not pressed last time
  joy_edge = (new_joy ^ last_joy) & new_joy;
  // update old joystick value
  last_joy = new_joy;

return joy_edge;
}
