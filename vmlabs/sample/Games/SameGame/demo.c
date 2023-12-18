/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "sg.h"

// Plays a demo of the game.  After 4 games are played the title
// screen is briefly displayed.  The computer moves are randomly
// chosen.

int demo(mmlFontContext fc, mmlFont sysP, int n_colours)
{
  extern int PixMap;
  extern mmlDisplayPixmap screen[3];

  extern struct Best_Scores Best_Scores;
  extern int Score;

  int bonus = 0;
  int exit, seed, count;
  long joy_edge;

  int group_num, m, n;
  int num_of_groups = 0;
  // reset the score (but not Best_Scores.Demo of course  :-)
  Score = 0;

  // start with a random table
  seed = (int)clock();
  set_new_table(n_colours, seed, 0);
  num_of_groups = det_group();

  if (MATS == 1){
    // pick a mat for the background
    m = NUM_MATS * (double)(rand()-1)/(double)RAND_MAX;
    copy_mat_to_backgrnd(m);
  }

  n = 0;

  // The following code handles the text correctly when we are
  // using translucent pixels.  We return the font to orginal
  // setting when exiting from this ftn.
  gc.translucentText = 1;
  mmlSetTextProperties(fc, sysP, 20, kBlack, kBlackff, eOpaque, 0,0);

  // keep track of how many games have been played
  count = 0;

  // demo is exited when played hits the Start button
  exit = 0;


  while (!exit){

    // poll the joystick and exit if necessary (we do a *lot* of this
    // throughout the demo so that it be very responsive to the users 
    // request to exit)
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // check to see if we need to start a new game
    if (num_of_groups == 0){
      // a delay between games
      pause_a_bit(1.0);
      // randomly set up a new table of Balls
      set_new_table(n_colours, 0, 0);
      // change Highest Score if necessary, then reset Score
      if (Score > Best_Scores.Demo[n_colours-3])
	Best_Scores.Demo[n_colours-3] = Score;
      Score = 0;
      // keep track of how many games have been played
      count = count + 1;
    }

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // after playing NUM_DEMO_GAMES games we pause to display title screen
    if (count == NUM_DEMO_GAMES){
      count = 0;
      // display the title screen
      //
      // Note: we use formula "diff = 0 iff n_colours = 3" and 
      // "diff = 1 iff n_colours = 4"  This works since we don't
      // use diff = 2 in demo mode.
      //
      title(fc, sysP, 2, n_colours-3);
      // wait
      pause_a_bit(2.5);
      // poll the joystick and exit if necessary
      joy_edge = getkey();  
      if (joy_edge & JOY_START)
	exit = 1;
      // wait some more
      pause_a_bit(2.0);
      if (MATS == 1){
	// pick another mat for the background; we don't force the
	// new mat to be different from the old mat
	m = NUM_MATS * (double)(rand()-1)/(double)RAND_MAX;
	copy_mat_to_backgrnd(m);
      }
    }

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // Look at the table: determine the groups, assign group numbers,
    // return number of (non-singleton) groups.  We calculate this
    // each time through the loop because the deletion of a group
    // changes the table.
    num_of_groups = det_group();

    // if no groups left then check if there is a bonus to be awarded
    if (num_of_groups == 0){
      bonus = det_bonus(n_colours, Score);
      Score = Score + bonus;
    }

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // pick a group for Computer Player to delete
    group_num= (int)((num_of_groups-1)*((double)rand()/(double)RAND_MAX))+1;

    /***************************************************/
    // RENDERING PART:
    // switch screens
    PixMap = (PixMap < 2) ? PixMap+1 : 0;
    /***************************************************/

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // draw, to screen[PixMap], the table with group = group_num
    // highlited; high_lite_group2 is the ftn which draws all the
    // tiles in the table (a bit slow, but in demo mode this doesn't
    // matter)
    high_lite_group2(group_num);

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // print score calculated after last delete; this way we see
    // the score change after the highlighted balls disappear
    display_score2(fc, sysP, SCORE_X, SCORE_Y, 0, 0, 0, Score, 
		   Best_Scores.Demo[n_colours-3]);

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
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

    // slow demo down
    pause_a_bit(0.85);

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // before deleting, animate group = group_num; we pass "0" for
    // old_group_num since it isn't used in demo mode
    animate_group2(fc, sysP, group_num, 0, n_colours, 0, 0);

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // now delete the group and return the size of that group
    n = delete_group(group_num); 
  
    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    // calculate new score using formula (n-2)^(number of colours)
    // where n is the size of the group just deleted; this gives score
    // inflation (compared to the tradition calculation which is
    // (n-2)^2) and reflects the fact that the 4 colour version is
    // harder than the 3 colour version of the game; note that both 4
    // colour versions score the same way, maybe that should be
    // changed in the future?
    if (n > 2)
      Score = Score  + (int)pow(n-2, n_colours); 

    // poll the joystick and exit if necessary
    joy_edge = getkey();  
    if (joy_edge & JOY_START){
      exit = 1;
    }

    
  } // end of "while (!exit)" loop

  // reset the text
  gc.translucentText = 0;
  mmlSetTextProperties(fc, sysP, 20, kBlack, kGrey, eBlend, 0,0);

  return 0;
}

