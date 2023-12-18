/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */


#define _OLD_JOYSTICK 1

#include <nuon/mml2d.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>

#include <nuon/video.h>
#include <nuon/joystick.h>
#include <nuon/nise.h>
#include <nuon/dma.h>


// MML2D fonts
   extern uint8 SysFontBold[];
   extern uint8 SysFontBoldEnd[];
// extern uint8 SysFont[];
// extern uint8 SysFontEnd[];


#define MIN( x, y ) ( (x) < (y) ? x : y )

/* Some graphics settings */
#define DEFAULT_BORDER_COLOR kBlack

/* transparent colour */
#define kBlackff 0x108080ff

mmlSysResources sysRes;
mmlGC gc;
mmlDisplayPixmap screen[3], balls, background, playagain, mat, mats[10], anim, titlebackgrnd;
VidDisplay display;
VidChannel mainch, video_ch;

// set to 1 if creating a cof file which will be run from a DVD
#define ON_DVD 0

// (old code) used for background, it matches the grey in BALLS2.tga and
// BALLS3.tga
#define kGrey 0x7B808000

// maximum number of rows and columns in a SameGame table
#define MAX_COL_NUM 20
#define MAX_ROW_NUM 15

extern char Path[];    // path for the artwork and sounds

extern int SOURCE_WIDTH, SOURCE_HEIGHT, SCRN_WIDTH, SCRN_HEIGHT;
extern int VFILT_4TAP, COL_NUM, ROW_NUM, SQU_WIDTH, UP_LEFT_X, UP_LEFT_Y;
extern int BOTTOM_RT_X, BOTTOM_RT_Y;
extern int MATS, NUM_MATS, MAT_WIDTH, MAT_HEIGHT, NUM_ANIM_STEPS;
extern int TILE_TRANSPARENCY, INV_R, INV_G, INV_B, CURSOR_WIDTH, CURSOR_RAD;
extern int CUR_SPEED, CUR_L_X, CUR_L_Y, CUR_R_X, CUR_R_Y, PTR_L_X, PTR_L_Y;
extern int PTR_R_X, PTR_R_Y, PTR_PLAY_X, PTR_PLAY_Y, PTR_LEVEL_X, PTR_LEVEL_Y;
extern int PTR_DEMO_X, PTR_DEMO_Y, PTR_EXIT_X, PTR_EXIT_Y, PTR2_L_X, PTR2_L_Y;
extern int PTR2_R_X, PTR2_R_Y, PTR2_NORM_X, PTR2_NORM_Y, PTR2_CHALLENGE_X;
extern int PTR2_CHALLENGE_Y, PTR2_SUPERCHAL_X, PTR2_SUPERCHAL_Y;
extern int PTR_TITLE_TRANSPARENT, NUM_DEMO_GAMES, PLAY1_L_X, PLAY1_L_Y;
extern int PLAY1_R_X, PLAY1_R_Y, PLAY2_L_X, PLAY2_L_Y, PLAY2_R_X, PLAY2_R_Y;
extern int PLAY_L_X, PLAY_L_Y, SCORE_X, SCORE_Y;

// structure which will hold the settings read in from sg.cnf; default settings
// are set in sg.c
struct Variables {
  char *Name;
  int *Value;
  int Flag;
};

// structure for holding a sound sample
struct Sound {
  int frequency;  // for now, 24kHz
  int length;     // length of sound, in bytes
  short *data;    // pointer to sound data
};

int det_group();
int det_neigh_group(int i, int j, int count);
int count_balls();
int colour_stats(int colour_number);
int group_stats(int group_num);
int num_special_balls();
int count_colours(int n_colours);
int det_colour_frm_groupnum(int group_num);
void print_ball_table();
int high_lite_group(int group_num);
int high_lite_group2(int group_num);
int high_lite_group3(int group_num, int old_group_num, int toggled, int cur_moved, int old_cur_x, int old_cur_y);
int draw_cursor(int cur_x, int cur_y);
int draw_cursor2(int cur_x, int cur_y);
int draw_cursor4(int cur_x, int cur_y);
int delete_group(int group_num);
int singleton(int i, int j);
int squeeze_left(int k);
long getkey();
int set_new_table(int n_colours, int seed, int special);
int display_score(mmlFontContext fc, mmlFont sysP, int x, int y, int mode, int displayFPS, double framespersec);
int display_score(mmlFontContext fc, mmlFont sysP, int x, int y, int mode, int displayFPS, double framespersec);
int display_score2(mmlFontContext fc, mmlFont sysP, int x, int y, int mode, int displayFPS, double framespersec, int score, int bestscore);
int demo(mmlFontContext fc, mmlFont sysP, int n_colours);
int game(mmlFontContext fc, mmlFont sysP, int n_colours, int special);
void _BiosReboot(void);
int play_again(mmlFontContext fc, mmlFont sysP, int Score, int n_colours);
int play_again2(mmlFontContext fc, mmlFont sysP, int Score, int n_colours);
int det_bonus(int n_colours, int current_score);
// int Print_Rules(mmlFontContext fc, mmlFont sysP);
int ReadTGA(unsigned char *tga, long dmaflags, void *base,
        int xOutOffset, int yOutOffset, unsigned long *clut);
int ReadTGAfrmFile(char *filename, long dmaflags, void *base);
int toggle_colour(int cur_x, int cur_y);
int Challengerules(mmlFontContext fc, mmlFont sysP);
void myCopyRectDis(mmlGC *gc, mmlDisplayPixmap *srcP, mmlDisplayPixmap *destP, m2dRect *r, m2dPoint corner);
void myCopyRectDisBlend(mmlGC *gc, mmlDisplayPixmap *srcP, mmlDisplayPixmap *destP, m2dRect *r, m2dPoint corner);
int title(mmlFontContext fc, mmlFont sysP, int currentB, int diff);
int pause_a_bit(double seconds);
int copy_mat_to_backgrnd(int i);
void MyCopyRect(int upleft_x, int upleft_y, int botright_x, int botright_y, mmlDisplayPixmap *srcPtr, int pt_x, int pt_y, mmlDisplayPixmap *dstPtr);
void MyCopyRectTrans(int upleft_x, int upleft_y, int botright_x, int botright_y, mmlDisplayPixmap *srcPtr, int pt_x, int pt_y, mmlDisplayPixmap *dstPtr);
int Read_CNF_File();
char* find_good_line(char *buf);
int ReadSound(const char *name, struct Sound *sound);
void PlaySound(struct Sound *sound, int volume);
int Applaud_Large_Group(int group_num, int initial_n_colours[4], int n_colours);
int animate_group(mmlFontContext fc, mmlFont sysP, int group_num, int n_colours, int count, int mode);
int animate_group2(mmlFontContext fc, mmlFont sysP, int group_num, int old_group_num, int n_colours, int count, int mode);
void mmlConfigOSD(VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int hScale);
void My_ConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int horFilter, int hScale, int wScale );
void My_ConfigMain( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset );


struct Balls {
  int colour[MAX_COL_NUM][MAX_ROW_NUM];  // "-99" indicates no ball
  int group[MAX_COL_NUM][MAX_ROW_NUM];   // the group to which the ball belongs 
                                 // ("-1" indicates a group of size 1)
  int special[MAX_COL_NUM][MAX_ROW_NUM]; // indicates whether ball is changeable
} Balls;


// Structure for storing the highest scores.  There are 5 different
// scores saved.
struct Best_Scores {
  int Demo[2];  // for the two demo cases: 3 colours or 4 colours 
                // (the challenge and super challenge demo versions 
                // are the same)
  int Game[3];  // for the 3 levels of game: normal (3 colour) and 
                // super challenge and challenge (both 4 colour);  
                // 0 = normal, 1 = super challenge, 2 = challenge
} Best_Scores;


extern struct Variables Variables[];

extern struct Sound Click, BigDelete, BigDeleteAll, ChangeTile, Bonus, NoBonus;

extern int PixMap;

extern int Colours[];
extern int Score;
extern int Highest_Score;

