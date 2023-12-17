/*  Copyright (c) 2001, VM Labs, Inc., All rights reserved.
 *  Confidential and Proprietary Information of VM Labs, Inc
 */


// This is a test of xtract ftns found in xtract.c


  ////////////////////////////////////////////////////////////////
  // Assumptions: The catenated files are in the file output.dat.
  // The file we wish to extract will be written to FoundIt.
  ////////////////////////////////////////////////////////////////


#include "xtract.h"

int
main(int argc, char *argv[])
{
  char *buf;
  int i=0, fd, num;
  long size;
  char *file;

  struct Index_of_Files Index_Entry;  

  if (argc < 2){
    fprintf(stderr, "%s usage:\n", argv[0]);
    fprintf(stderr, "  Pass the file you wish to extract from output.dat\n");
    fprintf(stderr, "  and it will be written to FoundIt.\n");
    return -1;
  }
  if (argc > 2){
    fprintf(stderr, "Too many variables.  %s only takes the name\n", argv[0]);
    fprintf(stderr, "of the file you wish to extract from output.dat. \n");
    return -1;
  }

  file = argv[1];

  // read the index part of output.dat (first 6K) into structure The_Index
  read_in_index("output.dat");

  // a test to see if get_num_entries works correctly
  num = get_num_entries();
  fprintf(stderr, "Number of entries in Index are: %d\n", num);

  // find_name_in_index returns -1 if file not found
  i = find_name_in_Index(file, &Index_Entry);
  fprintf(stderr, "Index containing %s is %d\n", file, i);

  if (i > -1){
    // "network to host" ftn which converts from big-endian to whatever 
    // this system is using  (NUON uses big-endian)
    size = ntohl(Index_Entry.size);
    fprintf(stderr, "Size is %ld\n", size);

    buf = malloc(size);
    
    printf("get_file returns %d\n", get_file("output.dat", i, buf));

    // read file from output.dat into buf
    get_file("output.dat", i, buf);
    
    // create the output file to place file in
    fd = creat("FoundIt", PERMS);
    
    // write file to output file FoundIt
    if (write(fd, buf, size) < 0){
      fprintf(stderr, "Can't write %s to FoundIt\n", file);
      return -1;
    }

    close(fd);

  }else{
    fprintf(stderr, "File %s not found\n", file);
  }

  return 0;
}


