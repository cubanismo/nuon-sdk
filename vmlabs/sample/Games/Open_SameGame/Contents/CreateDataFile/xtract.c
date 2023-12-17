/*  Copyright (c) 2001, VM Labs, Inc., All rights reserved.
 *  Confidential and Proprietary Information of VM Labs, Inc
 */


// ftns which allow one to extract a file from a .dat file created by
// the cat_files program


#include "xtract.h"

static struct Index_of_Files The_Index[MAX_NUM];

// ftn reads in the first 6K of the file into The_Index struct (NUON
// converts the hex into int); it prints a message and exits -1 if
// anything goes wrong
int 
read_in_index(char *name)
{
  int fd;

  // open file
  if ((fd = open(name, O_RDONLY, 0)) == -1){
    fprintf(stderr, "In get_index: can't open %s\n", name);
    return -1;
  }
  // read the first 6K of file into The_Index struct
  if (read(fd, The_Index, INDEX_SIZE) < 0){
    fprintf(stderr, "In get_index: can't read in Index\n");
    return -1;
  }
  close(fd);
  return 0;
}

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
    printf("Index appears to be empty\n");
    return -1;
  }

  return i;
}


// ftn, given a name, returns i such that The_Index[i] contains that
// name (and this is also where size and location information can be
// found); ftn returns -1 if file cannot be found
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
  int fd;
  long location, size;

  // open .dat file
  if ((fd = open(filename, O_RDONLY, 0)) == -1){
    fprintf(stderr, "In get_file: can't open %s\n", filename);
    return -1;
  }

  // go to proper location in .dat file
  location = ntohl(The_Index[i].location);
  if (lseek(fd, location, 0) == -1){
    fprintf(stderr, "In get_file: can't seek to location\n");
    return -1;
  }

  // read filename into memory
  size = ntohl(The_Index[i].size);
  if (read(fd, ptr, size) == -1){
    fprintf(stderr, "In get_file: read into memory failed\n");
    return -1;
  }

  close(fd);
  return 0;
}


// OLD RAMBLINGS

  /* want code to read in TGA from file (check ReadTGA code) and code
     to read cnf file, do an open, then a read to memory which has
     been set aside by a malloc; basically ReadSound does the same.

     Soooo, I want to have a ftn (or two) which one passes a file
     name, and a buf to and it then (a) looks up the file in The_Index
     and (b) reads the file into the memory.

     Hmm, most code opens a file, gets the file size, does a malloc,
     then reads the file in.  So I probably want 2 ftns: one does the
     look up in The_Index and returns the location and filesize; the
     other, given the location and and address to memory goes into the
     .dat file and grabs the file and puts it into memory.  This seems
     to make the most sense.  (Eric says that one could have one ftn
     which does all this, including the malloc.)

     So, when coming back, write these two ftns and have SameGame call
     them.  Hmm.., will SameGame have a cnf file in the future?  If
     so, will it be in the .dat file?  Or separate?  Or will it be
     hardcoded in SameGame?
  */

