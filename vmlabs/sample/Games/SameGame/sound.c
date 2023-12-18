/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "sg.h"

// NOTE: samples should be 24kHz signed 16bit in big-endian format

// function to read a sample from disk; it fills in the "sound"
// structure with info about the sample returns 0 on success, -1 on
// failure
int ReadSound(const char *name, struct Sound *sound)
{
    int fd;
    int size;

    sound->frequency = 24000;


    /* open the file */
    fd = open(name, O_RDONLY);
    if (fd < 0) {
      // couldn't find file; we assume it was left out intentionally
      // and motor along.  (Do print a message though.)
      if (ON_DVD == 0)
	printf("ReadSound: Can't open %s; thus will not be using this clip in the game\n", name);

      sound->data = NULL;
      sound->length = 0;

      return -1;
    }

    /* determine the size of the file */
    size = lseek(fd, 0L, SEEK_END);
    lseek(fd, 0L, SEEK_SET);

    if (size <= 0) {
      /* no data there!! */
      if (ON_DVD == 0)
	printf("ReadSound: No data there; thus will not be using this clip in the game\n");
      close(fd);

      sound->data = NULL;
      sound->length = 0;

      return -1;
    }

    /* allocate memory for and read the data */
    sound->data = malloc(size);
    if (!sound->data) {
      /* out of memory */
      if (ON_DVD == 0)
	printf("ReadSound: out of memory; thus will not be using this clip in the game\n");
      close(fd);

      sound->data = NULL;
      sound->length = 0;

      return -1;
    }

    sound->length = read(fd, sound->data, size);
    close(fd);
    if (sound->length < size) {
      if (ON_DVD == 0)
	printf("ReadSound: Read less than expected; thus will not be using this clip in the game\n");
      free(sound->data);
      
      sound->data = NULL;
      sound->length = 0;
      
      return -1;
    }

    return 0;
}


// Play a sound sample at a given volume (0-0xffff)
void PlaySound(struct Sound *sound, int volume)
{
    PCMVoiceOn(sound->data, (0x1000*sound->frequency)/24000, sound->length/2,
	       0x3f000000, 0, 0);
}


// Play a sound if player removes a large enough group
int Applaud_Large_Group(int group_num, int initial_n_colours[4], int n_colours)
{
  int m, n, p, q, colour;

  // determine the colour of group
  colour = det_colour_frm_groupnum(group_num);

  // proceed if we found a valid colour
  if (colour != -1){

    // count the number of tiles of that colour in the (entire) table
    m = colour_stats(colour);

    // initial number of tiles of that colour in the table
    p = initial_n_colours[colour];

    // size of the group
    n = group_stats(group_num);

    // if the group is large enough we play a clip

    // determine who big we think "large" should be. Probably
    // needs some tweaking
    q = (n_colours == 3) ? 79 : 70;

    // DEBUGGING
    // printf("colour = %d, initial number of colour = %d, total of that colour now = %d, group size = %d, percentage of total colour removed %d\n", colour, p, m, n, (int)((n * 100)/p));

    if ((int)((n * 100)/p) > q){
      if (n == p){
	//i.e.  (n*100)/p = 100 
	if (BigDeleteAll.length > 0){
	  PlaySound(&BigDeleteAll, 0xffff);
	  // let the clip play a bit before proceeding, if there's 
	  // animation we don't want to pause too long
	  if (NUM_ANIM_STEPS > 0)
	    pause_a_bit(0.2);
	  else
	    pause_a_bit(1.3);
	}
      }else{
	// group is large (more than q%, but doesn't contain all the original tiles)
	if (BigDelete.length > 0){
	  PlaySound(&BigDelete, 0xffff);
	  // let the clip play a bit before proceeding
	  if (NUM_ANIM_STEPS > 0)
	    pause_a_bit(0.3);
	  else
	    pause_a_bit(1.3);
	}
      }
    }
  }
  
  return 0;
}
