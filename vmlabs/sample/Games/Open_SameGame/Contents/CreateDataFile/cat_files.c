/*  Copyright (c) 2001, VM Labs, Inc., All rights reserved.
 *  Confidential and Proprietary Information of VM Labs, Inc
 */

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#define DEBUGGING 1

#define MAX_NUM 192 // max num of files to be stored; since each
                    // struct is 32 bytes, want 192 structs which
                    // gives a total of 6K (and 6K is a mult of 2K)
#define TWO_K 2048
#define PERMS 0666   // read & write for owner, group, others
#define NAME_LENGTH 23
#define INDEX_SIZE 6144   // this is 6K, value determines MAX_NUM
#define CHUNK_SIZE 16384  // mult of 2K, this is the size of the reads


struct The_Index_of_Files {
  char name[NAME_LENGTH+1];  // leave room to put in end of string/line 
  char size[4];
  char location[4];
};

static struct The_Index_of_Files The_Index[MAX_NUM];


int
main(int argc, char *argv[])
{
  int fd, fd2;
  long filesize;
  unsigned int padded, temp;
  int size, total;
  unsigned int location = INDEX_SIZE;
  int remainder;
  char *buf1;
  char *buf2;
  int i, j;
  unsigned int num;

  filesize = 0;
  i = 0;
  j = 0;
  total = 0;
  padded = 0;


  /* 
   options to pass: -l to list the files to be included and calculate
                     the size of the final product, but don't create
                     this product -h help; same output as usage; -o
                     output file or have this necessary the way zip
                     does it?  
  */

  // want "Usage..." to appear if there are no arguments passed, if -h
  // is passed, or if garbage is passed.
  //
  // Still under construction
  //
  if (argc < 2){
    fprintf(stderr, "%s usage: \n", argv[0]);
    return -1;
  }
  // check that we don't have too many files
  if (argc > MAX_NUM-1){
    fprintf(stderr, "too many files, %s can handle only %d\n", argv[0], MAX_NUM-1);
    return -1;
  }

  if (DEBUGGING){
    printf("\nNumber of files: %d\n\n", argc-1);
    printf("      Name      Size    Padded Size\n");
    printf("      ----      ----    -----------\n");
  }

  // first cycle through the list and gather info to create the index
  for (i = 0; i < argc-1; i++){

    if ((fd = open(argv[i+1], O_RDONLY, 0)) == -1){

      // can't open file, print message and exit
      fprintf(stderr, "In index loop: can't open %s\n", argv[i+1]);
      return -1;

    }else{
      
      if (DEBUGGING)
	fprintf(stderr, "%10s", argv[i+1]);

      // record name of file -note upper limit on length of names
      strncpy(The_Index[i].name, argv[i+1], NAME_LENGTH);
      The_Index[i].name[NAME_LENGTH+1] = '\0';

      // calculate filesize
      filesize = lseek(fd, 0L, SEEK_END);
      lseek(fd, 0L, SEEK_SET);

      if (DEBUGGING)
	fprintf(stderr, "    %6ld", filesize);

      // calculate the ceiling of (filesize/TWO_K)
      num = ((filesize % TWO_K) == 0) ? (int)(filesize/TWO_K) : (int)(filesize/TWO_K)+1;
      // another way to calculate the ceiling, kinda elegant
      // num = (int)((filesize+TWO_K-1) / TWO_K);

      // location of this file; using padded value from last time thru
      // this loop
      location += padded;

      // calculate padded size of this file
      padded = num*TWO_K;
      total += padded;

      if (DEBUGGING)
	fprintf(stderr, "      %6d\n", padded);

      // store (actural) size of file in 4 bytes
      temp = filesize;
      for (j = 3; j > -1; j--){
	The_Index[i].size[j] = temp & 255;
	temp = temp >> 8;
      }
      
      // store location of file in output.dat in 4 bytes
      temp = location;
      for (j = 3; j > -1; j--){
	The_Index[i].location[j] = temp & 255;
	temp = temp >> 8;
      }
    }  // if statement
    close(fd);
  } // for loop

  // put null character in name following last to signify end of 
  // list, even though The_Index array should already be 
  // initialized with zeros
  The_Index[argc-1].name[0] = '\0';

  if (DEBUGGING){
    printf("\nSize of output.dat: %d\n", total+INDEX_SIZE);
    printf("\n\n");
  }

  // create the output file
  fd2 = creat("output.dat", PERMS);
  
  // write index to output file
  if (write(fd2, The_Index, INDEX_SIZE) < 0){
    fprintf(stderr, "Can't write The_Index to output file\n");
    return -1;
  }

  // memory for storing the reads
  if ((buf1 = malloc(CHUNK_SIZE)) == NULL){
    fprintf(stderr, "unable to allocate memory for the read/write chunks\n");
    return -1;
  }

  // want a 2K block of memory for padding files
  if ((buf2 = malloc(TWO_K)) == NULL){
    fprintf(stderr, "unable to allocate memory for buffer of zeros\n");
    return -1;
  }
  // fill this memory with zeros
  for (i = 0; i < TWO_K; i++)
    *(buf2+i) = 0;


  // loop which does the actual reading, writing, and padding of files
  for (i = 0; i < argc-1; i++){
    if ((fd = open(argv[i+1], O_RDONLY, 0)) != -1){
      // read in file in chunk_size b chunks and immed write
      total = 0;
      while ((size = read(fd, buf1, CHUNK_SIZE)) > 0){
	if (write(fd2, buf1, size) < 0){
	  fprintf(stderr, "In read/write/pad loop: can't write a chunk of %s\n", argv[i+1]);
	  return -1;
	} 
	total += size;
      }
      // pad the file, if necessary
      remainder = total % TWO_K;
      if (remainder > 0){
	if (write(fd2, buf2, TWO_K-remainder) < 0){
	  fprintf(stderr, "In read/write/pad loop: can't write remaining chunk of %s\n", argv[i+1]);
	  return -1;
	}
      }
    }else{
      // if can't open file, print message and exit
      fprintf(stderr, "In read/write/pad loop: can't open %s\n", argv[i+1]);
      return -1;
    }
    close(fd);
  } // for loop

  // close output.dat
  close(fd2);

  return 0;
}




////////////////////////////////////////////////////
//
// ftns to find and extract files from a .dat file
//
////////////////////////////////////////////////////

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
get_num_entries()
{
  char zeros[NAME_LENGTH+1];
  int i = 0;

  for (i = 0; i < NAME_LENGTH+1; i++)
    zeros[i] = '0';

  // find first occurance of name field full of zeros or find i =
  // MAX_NUM; the index of this occurance is also the number of
  // (non-zero) entries in The_Index
  while ((strcmp(zeros, The_Index[i].name) != 0)  && (i < MAX_NUM))
    i++;
  
  if (i == 0){
    printf("Index appears to be empty\n");
    return - 1;
  }

  return i;
}


// ftn, given a name, returns index such that The_Index[i] contains
// that name; returns -1 on failure
int
find_name_in_Index(char *name)
{
  int i = 0, found = 0;

  while ((i < MAX_NUM) && (!found)){
    if (strcmp(name, The_Index[i].name) == 0)
      found = 1;
    i++;
  }

  if (i == MAX_NUM)
    return -1;
  else
    return i-1;
}



// given the .dat filename and an index in The_Index
// and a pointer to enough memory, read the appropiate
// file into memory; returns -1 on failure
int 
get_file(char *filename, int i, char *ptr)
{
  int fd;

  // open .dat file
  if ((fd = open(filename, O_RDONLY, 0)) == -1){
    fprintf(stderr, "In get_file: can't open %s\n", filename);
    return -1;
  }

  // go to proper location in .dat file
  if (lseek(fd, *(The_Index[i].location), 0) == -1){
    fprintf(stderr, "In get_file: can't seek to location\n");
    return -1;
  }

  // read file into memory
  if (read(fd, ptr, *(The_Index[i].size)) == -1){
    fprintf(stderr, "In get_file: read into memory failed\n");
    return -1;
  }

  close(fd);
  return 0;
}
