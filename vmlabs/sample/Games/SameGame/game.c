/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */


#include "sg.h"

int game(mmlFontContext fc, mmlFont sysP, int n_colours, int special)
{
  extern int PixMap;
  int nextPixMap;
  extern  mmlDisplayPixmap screen[3];

  extern struct Balls Balls;

  extern struct Best_Scores Best_Scores;
  extern int Score;

  long joy_edge, new_joy;
  int cur_x, cur_y, old_cur_x, old_cur_y, cur_moved, toggled, cur_dist;
  int seed, method;

  int exit;
  int bonus;

  int delete;
  int i, m, mm, old_mm, n, group_num, old_group_num, num_of_groups, num_balls, count;
  int col, row;

  int initial_num_colours[4];

  clock_t tBeg, tEnd, cur_tBeg, cur_tEnd, anim_tBeg, anim_tEnd;
  int frame, displayFPS;
  double sec, framespersec;

  // initilize various variables
  exit = 0;
  bonus = 0;
  num_balls = 0;
  num_of_groups = 0;
  Score = 0;
  n = 0;
  m = 0;
  // mm keeps track of the current mat number (when playing POKE
  // version) so that the new mat (in the case that the player
  // completely finished the game), which is chosen randomly, is
  // different from the current mat
  mm = 0;
  old_mm = 0;
  seed = 0;
  for (i = 0; i < n_colours; i++)
    initial_num_colours[i] = 0;
  // Determine count which is the index to Best_Scores.Game
  // 
  // Set count = 0 for 3 colours, count = 2 for challenge (where
  // special is 1), and count = 1 for super challenge (with 4 colours)
  count = (special == 1) ? 2 : n_colours - 3;

  // keep track of whether the cursor has moved or not; need this for
  // highlight3 considerations
  cur_moved = 0;
  // keep track of whether a special ball needs to change colour
  toggled = 0;

  // the group which is/was selected
  group_num = 0;
  old_group_num = 0;

  col = 0;
  row = 0;

  /*************************************************/
  // copy the background picture into the main channel;
  // we want the next screen to have the correct background; part
  // of this background will be copied to all the following screens
  nextPixMap = (PixMap < 2) ? (PixMap+1) : 0;
  MyCopyRect(0, 0, SCRN_WIDTH-1, SCRN_HEIGHT-1, &background, 
             0, 0, &screen[nextPixMap]);
  /*************************************************/

  /******** set up very first game ***********/
  // place the cursor
  cur_x = SOURCE_WIDTH/2; 
  old_cur_x = SOURCE_HEIGHT/2;
  cur_y = SOURCE_WIDTH/2;
  old_cur_y = SOURCE_HEIGHT/2;
  // randomly set up a new table of Balls
  seed = (int)clock();
  set_new_table(n_colours, seed, special);
  // Determine the groups, give them group numbers, return number of
  // (non-singleton) groups.
  num_of_groups = det_group();
  // count the number of occurance of each colour in the table (use this
  // later when deciding whether player has removed significant number
  // of tiles of a certain colour)
  for (i = 0; i < n_colours; i++)
    initial_num_colours[i] = colour_stats(i);
  // initial number of balls in table
  num_balls = COL_NUM * ROW_NUM;
  if (MATS == 1){
    // pick a mat for the background
    mm = NUM_MATS * (double)(rand()-1)/(double)RAND_MAX;
    copy_mat_to_backgrnd(mm);
  }
  // The "delete" variable keeps track of whether a group has just
  // been deleted or not.  The significance being that after a delete
  // we want to use hilight2 to redraw the screen rather than
  // highlite3.  (Highlite2 redraws everything without thinking about
  // it which makes life easier; it does slow down the frame rate BUT
  // at time of a delete the cursor isn't moving anyway, so the user
  // won't notice.)
  //
  // Here we start with delete = 1 so that initially the entire screen
  // is drawn via highlite2.  (Highlite3 takes a copy of the screen
  // from the last buffer and touches it up; obviously there isn't a
  // previous screen of balls when the game is just starting.)
  delete = 1;
  /******************************************/

  // initialize variables for displaying frames per sec
  tBeg = clock();
  frame = 0;
  framespersec = 0.0;
  displayFPS = 0;

  // initialize variable for calculating the cursor speed
  cur_tBeg = clock();

  // The following code handles the text correctly when we are
  // using translucent pixels.  We return font to previous
  // setting when exiting from game.c.
  gc.translucentText = 1;
  mmlSetTextProperties(fc, sysP, 20, kBlack, kBlackff, eOpaque, 0,0);

  // main loop
  while (!exit){

    // Determine where cursor is pointing and which group is
    // currently selected
    if ((cur_x > UP_LEFT_X) && (cur_x < BOTTOM_RT_X)
	&& (cur_y> UP_LEFT_Y) && (cur_y < BOTTOM_RT_Y)){
      // determine the indicated row and column
      col = (int)((cur_x - UP_LEFT_X)/SQU_WIDTH);
      row = (int)((cur_y - UP_LEFT_Y)/SQU_WIDTH);
      //look up the group number; if it's <0 then we have a singleton
      //group or an empty spot and we don't want to highlight that, so
      //set group_num = -2 in this case
      old_group_num = group_num;
      group_num = (Balls.group[col][row] > 0) ? Balls.group[col][row] : -2;
    }else{ 
      // if cursor is not on ball table then highlight no group
      old_group_num = group_num;
      group_num = -2;
    }
    
    // Poll the joystick
    joy_edge = getkey();
    new_joy = _Controller[1].buttonset;
    
    // Exit loop and return to main menu
    if (joy_edge & JOY_START) 
      exit = 1;
    
    // Delete the currently highlighted group and update the score
    if (joy_edge & JOY_A){
      if (group_num > 0){
	delete = 1;
	// before we start the actual delete, look at the size
	// of the group; if it is significantly large, play a 
	// sound clip
	// NOTE: below ftn slightly flawed in that it keeps the initial
	// number of colours and on Challenge level we can change two
	// of these colours.  Maybe do a fix later.
	Applaud_Large_Group(group_num, initial_num_colours, n_colours);
	// because the movement of the cursor is a ftn of time, we need
	// to figure out how long the animate takes and then adjust cur_tBeg
	anim_tBeg = clock();
	// before deleting animate that group
	animate_group2(fc, sysP, group_num, old_group_num, n_colours, count, 1);
	anim_tEnd = clock();
	// adjust cur_tBeg by substracting out the time the animation took
	cur_tBeg = cur_tBeg - (anim_tEnd - anim_tBeg);
	// delete group, returning the size of that group
	n = delete_group(group_num); 
	// update score (groups of size 2 don't earn any points)
	if (n > 2)
	  Score = Score + (int)pow(n-2, n_colours); 
	// count remaining number of balls; this variable used when
	// method = 0 below
	num_balls = count_balls();
	// Re-determine the groups, give them group numbers, and
	// return number of (non-singleton) groups.  (We have to
	// calculate this after every group deletion.)
	num_of_groups = det_group();
	// since the delete probably changed everything, update the
	// old_group_num and group_num values Note: col and row were
	// calculated above and so should be correct.  NOTE: hould
	// old_group_num be -2 or group_num? (Setting it to
	// group_num means we might be redrawing some group which
	// doesn't need it??)  Remember after a delete we use highlite2
	// which redraws the entire screen and so there will be no
	// evidence of the previous highlight on the screen.
	old_group_num = -2;
	group_num = (Balls.group[col][row] > 0) ? Balls.group[col][row] : -2;
      }
    }

    // Change the colour of a special ball; we use the variable
    // "toggle" to keep track of this even though the word "cycle"
    // would have been more appropriate
    toggled = 0;
    if ((special == 1) && (joy_edge & JOY_B)){
      // if cursor is over a special ball then toggle the color of
      // the ball and update the balls table; the toggle_colour ftn
      // returns 1 if a special ball has been toggled
      if (toggle_colour(cur_x, cur_y) == 1){
	// we have to recalculate the groups after toggling the colour
	num_of_groups = det_group();
	// look up the group number (Note: col and row are
	// calculated above)
	old_group_num = group_num;
	group_num = (Balls.group[col][row] > 0) ? Balls.group[col][row] : -2;
	toggled = 1;
	// play the "change tile" sound here instead in the toggle_colour
	// ftn
        if (ChangeTile.length > 0)
          PlaySound(&ChangeTile, 0xffff);
      }
    }
      
    // use C-pad button to toggle frames per second display
    if (joy_edge & JOY_C_RIGHT){
      displayFPS ^= 1;
    }
 
    // if no more groups then calculate the bonus, if any;  I believe
    // we do this here so that the new updated score be displayed at
    // the proper time
    if (num_of_groups == 0){
      bonus = det_bonus(n_colours, Score);
      Score = Score + bonus;
    }

    // calculate how far the cursor should move if it is to move; we
    // do this so that the cursor speed remains relatively constant
    // when the frame rate fluctuates
    cur_tEnd = clock();
    sec=(cur_tEnd>cur_tBeg) ? (double)(cur_tEnd-cur_tBeg)/(CLOCKS_PER_SEC) : -99;
    cur_tBeg = clock();
    // hmm, what to do if sec = -99??
    // cur_dist is the number of pixels the cursor would/will move
    cur_dist = (int)(CUR_SPEED * sec);

    // If the cursor moves (via pressing either up, down, left, or
    // right) then update the old_cur and cur variables
    cur_moved = 0;
    if ((new_joy & JOY_LEFT) || (new_joy & JOY_RIGHT) || (new_joy & JOY_UP) || 
        (new_joy & JOY_DOWN)){
      // these 3 variables are passed to the high_lite_group3 ftn
      cur_moved = 1;
      old_cur_x = cur_x;
      old_cur_y = cur_y;
      // change the appropriate coordinate of the cursor; exactly one of the 
      // below 4 conditions will be met 
      if (new_joy & JOY_LEFT)
	cur_x=(cur_x-CURSOR_RAD-cur_dist < UP_LEFT_X) ? cur_x : cur_x-(cur_dist);
      if (new_joy & JOY_RIGHT)
	cur_x=(cur_x+CURSOR_RAD+cur_dist >BOTTOM_RT_X) ? cur_x : cur_x+(cur_dist);
      if (new_joy & JOY_UP)
	cur_y=(cur_y-CURSOR_RAD-cur_dist < UP_LEFT_Y) ? cur_y : cur_y-(cur_dist);
      if (new_joy & JOY_DOWN)
	cur_y=(cur_y+CURSOR_RAD+cur_dist >BOTTOM_RT_Y) ? cur_y : cur_y+(cur_dist);
    }


    /***************************************************/
    // RENDERING PART:
    // switch screens
    PixMap = (PixMap < 2) ? (PixMap+1) : 0;
    // check that last screen is finished drawning on TV
    //      _VidSync(0);
    // erase the screen
    //    m2dFillColr( &gc, &screen[PixMap], NULL, kBlackff );
    /***************************************************/

    /*********************************************************************/
    // draw balls with group highlited ; we pass group_num = -2
    // when we don't want any group highlighted

    // set method = 0 for hybrid; 1 for highlite2; 2 for 
    // highlite3
    method = 2; 
    
    if (method == 0){
      // HYBRID METHOD: use highlite3 if more than 60 balls and
      //                use highlite2 if less than 60 balls
      // Note: using highlite3 still requires occasional calls
      //      to highlite2, thus the "delete" variable is required
      if ((num_balls > 60) && (delete == 0)){
	high_lite_group3(group_num, old_group_num, toggled, cur_moved,  
			 old_cur_x, old_cur_y);
      }else{
	// we use highlite2 after every delete
	high_lite_group2(group_num);
	delete = 0;
      }
    }else if (method == 1){
      high_lite_group2(group_num);
    }else if (method == 2){
      if (delete == 1) {
	high_lite_group2(group_num);
	delete = 0;
      }else{
	high_lite_group3(group_num, old_group_num, toggled, cur_moved,  
			 old_cur_x, old_cur_y);
      }
    }
    /*********************************************************************/


    if (frame % 9 == 0){
      tEnd = clock();
      sec = (tEnd>tBeg) ? (double)(tEnd-tBeg)/(CLOCKS_PER_SEC) : -99;
      framespersec = frame / sec;
      // at this point start the new time interval; thus we measure
      // the time over n frame intervals
      tBeg = clock();
      frame = 0;
    }

    frame = frame + 1; 

    //  Print score calculated after last delete; this way we see
    //  the score change after the highlighted balls disappear
    //  Also print frames per second, but only if we are not
    //  on frame number 0
    m = Best_Scores.Game[count];
    if ((frame != 0) && (framespersec != 0)){
      display_score2(fc, sysP, SCORE_X, SCORE_Y, 1, displayFPS, framespersec, Score, m);
    }else{
      display_score2(fc, sysP, SCORE_X, SCORE_Y, 1, 0, framespersec, Score, m);
    }

    // draw the cursor
    draw_cursor2(cur_x, cur_y);

    /*************************************************************/
    // DISPLAY SCREEN 
    // my modified version of ConfigMain which allows screen size of
    // 360 x 240
    My_ConfigMain( &video_ch, &screen[PixMap], 0, 0 );
    if (VFILT_4TAP == 1){
      video_ch.vfilter = VID_VFILTER_4TAP;
    }else{
      video_ch.vfilter = VID_VFILTER_2TAP;
    }
    _VidConfig(&display, &video_ch, (void *)0, (void *)0);
    /*************************************************************/

    // check to see if we need to set up a new game/table
    //
    // Next a complicated check to see if the game is truely over.
    // (We made it complicated because of the special balls and
    // probably more complicated than necessary.) Note that ending with
    // one special ball (and no other balls) will not clear the screen
    // since the rules state that a group must have two or more
    // members.
      if (num_of_groups == 0){
	if ((num_special_balls() == 0) || 
	    ((num_special_balls() == 1) && (count_balls() == 1))){
	  // play end of game music
	  // if there is no ball in the lower left hand corner of the table
	  // then we assume that all the balls have cleared
	  if (Balls.colour[0][ROW_NUM-1] == -99){
	    // all balls cleared
	    if (Bonus.length > 0){
	      PlaySound(&Bonus, 0xffff);
	      // let the music play a bit before displaying the "play
	      // again?"  menu
	      pause_a_bit(2.0);
	    }
	  }else{
	    if (NoBonus.length > 0){
	      PlaySound(&NoBonus, 0xffff);
	      pause_a_bit(0.5);
	    }
	  }
	  if (play_again2(fc, sysP, Score, Best_Scores.Game[count]) == 1){
	    // reset cursor
	    cur_x = SOURCE_WIDTH/2;
	    old_cur_x = SOURCE_WIDTH/2;
	    cur_y = SOURCE_HEIGHT/2;
	    old_cur_y = SOURCE_HEIGHT/2;
	    // so that we draw all the balls the first time through
	    delete = 1;
	    // reset group number
	    group_num = 0;
	    old_group_num = 0;
	    // randomly set up a new table of Balls
	    set_new_table(n_colours, 0, special);
	    // Determine the groups, give them group numbers, return number
	    // of (non-singleton) groups.  (We have to calculate this initially
	    // and after every deletion of a group.)
	    num_of_groups = det_group();
	    // initial number of balls in table
	    num_balls = COL_NUM * ROW_NUM;
	    // count the number of occurance of each colour in the table (use this
	    // later when deciding whether player has removed significant number
	    // of tiles of a certain colour)
	    for (i = 0; i < n_colours; i++)
	      initial_num_colours[i] = colour_stats(i);
	    // reset the frames per second variables
	    tBeg = clock();
	    frame = 0;
	    framespersec = 0;
	    // initialize variable for calculating the cursor speed
	    cur_tBeg = clock();
	    // a non-zero bonus means the screen was successfully cleared
	    // and we reward the player by switching to a different
	    // background picture chosen randomly (mm and old_mm are
	    // there to make sure the new mat is different from the old)
	    if ((bonus > 0) && (MATS == 1)){
	      old_mm = mm;
	      mm = NUM_MATS * (double)(rand()-1)/(double)RAND_MAX;
	      if (mm == old_mm)
		mm = (mm < (NUM_MATS-1)) ? mm+1 : 0;
	      copy_mat_to_backgrnd(mm);
	    }
	    /*************************************************/
	    // copy the background picture into the main channel
	    // we want the next screen to have the correct background; part
	    // of this background will be copied to all the following screens
	    nextPixMap = (PixMap < 2) ? (PixMap+1) : 0;
	    MyCopyRect(0, 0, SOURCE_WIDTH-1, SOURCE_HEIGHT-1, &background, 
                       0, 0, &screen[nextPixMap]);
            /*************************************************/
	  }
	  else{
	    exit = 1;
	  }
	  if (Score > Best_Scores.Game[count])
	    Best_Scores.Game[count] = Score;
	  Score = 0;
	}
      }
    
  }
  
  // reset the text
  gc.translucentText = 0;
  mmlSetTextProperties(fc, sysP, 20, kBlack, kGrey, eBlend, 0,0);

  return 0;
}
