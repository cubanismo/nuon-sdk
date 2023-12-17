
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

// Below are the ftns which allow one to extract a file from the .dat
// file created by the cat_files program

#include "sg.h"
#include "sg_xtract.h"


static struct Index_of_Files The_Index[MAX_NUM];


// ftn reads in the first 6K of the file into The_Index struct (NUON
// converts the hex into int); it prints a message and exits -1 if
// anything goes wrong
int 
read_in_index(char *name)
{
  extern char datapick[];

  memcpy(The_Index, datapick, INDEX_SIZE);
  return 0;
}

#if 0  // not need as .dat file is compiled into sg.cof
int 
read_in_index(char *name)
{
  int fd;

  // open file
  if ((fd = my_open(name, O_RDONLY, 0)) == -1){
    if (ON_DVD == 0)
      fprintf(stderr, "In get_index: can't open %s\n", name);
    return -1;
  }
  // read the first 6K of file into The_Index struct
  if (read(fd, The_Index, INDEX_SIZE) < 0){
    if (ON_DVD == 0)
      fprintf(stderr, "In get_index: can't read in Index\n");
    return -1;
  }
  my_close(fd);
  return 0;
}
#endif



// ftn returns number of entries in the index if successful; otherwise
// returns -1
int
get_num_entries(void)
{
  char zeros[NAME_LENGTH+1];
  int i;

  for (i = 0; i < NAME_LENGTH+1; i++)
    zeros[i] = 0;

  // find first occurance of name field full of zeros or find i =
  // MAX_NUM; the index of this occurance is also the number of
  // (non-zero) entries in The_Index
  i = 0;
  while ((strcmp(zeros, The_Index[i].name) != 0) && (i < MAX_NUM)){
    //    printf("In while loop: checking %s\n", The_Index[i].name);
    i++;
  }
  
  if (i == 0){
    if (ON_DVD == 0)
      printf("Index appears to be empty\n");
    return -1;
  }

  return i;
}



// ftn, given a name, returns integer i such that The_Index[i]
// contains that name (and this is also where size and location
// information can be found); ftn returns -1 if file cannot be found
int
find_name_in_Index(const char *name, struct Index_of_Files *Name_Entry)
{
  int i = 0;
  int found = 0;

  while ((i < MAX_NUM) && (!found)){
    if (strcmp(name, The_Index[i].name) == 0)
      found = 1;
    i++;
  }

  if (i == MAX_NUM)
    return -1;
  else{
    strcpy(Name_Entry->name, The_Index[i-1].name);
    Name_Entry->size = The_Index[i-1].size;
    Name_Entry->location = The_Index[i-1].location;
    return i-1;
  }
}



// given .dat filename and an index i in The_Index and a pointer to
// enough memory, read the appropiate file into memory; ftn returns -1
// on failure
int 
get_file(char *filename, int i, char *ptr)
{
  long location, size;
  extern char datapick[];

  // get location of file
  location = ntohl(The_Index[i].location); 

  // get size of file
  size = ntohl(The_Index[i].size);

  // copy file into memory
  memcpy(ptr, datapick+location, size);

  return 0;
}


#if 0  // this get_file not used as we are compiling data file into sg.cof
int 
get_file(char *filename, int i, char *ptr)
{
  int fd;
  long location, size;

  // open .dat file
  if ((fd = my_open(filename, O_RDONLY, 0)) == -1){
    if (ON_DVD == 0)
      fprintf(stderr, "In get_file: can't open %s\n", filename);
    return -1;
  }

  // go to proper location in .dat file
  location = ntohl(The_Index[i].location); 

  if (lseek(fd, location, 0) == -1){
    if (ON_DVD == 0)
      fprintf(stderr, "In get_file: can't seek to location\n");
    return -1;
  }

  // read filename into memory
  size = ntohl(The_Index[i].size);

  if (read(fd, ptr, size) == -1){
    if (ON_DVD == 0)
      fprintf(stderr, "In get_file: read into memory failed\n");
    return -1;
  }

  my_close(fd);
  return 0;
}
#endif
