
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <netinet/in.h>

#ifdef NUON
#define ntohl(x) (x)
#endif

#define PERMS 0666   // read & write for owner, group, others
#define NAME_LENGTH 23
#define MAX_NUM 192 // max num of files to be stored; since each
                    // struct is 32 bytes, want 192 structs which
                    // gives a total of 6K (and 6K is a mult of 2K)
#define INDEX_SIZE 6144   // this is 6K, value determines MAX_NUM


struct Index_of_Files {
  char name[NAME_LENGTH+1];  // '+1' there for end of string
  long size;
  long location;
  //  char size[4];   // on NUON side wish to change these four char to int
  //  char location[4];   // on NUON side wish to change these four char to int
};


// sg_xtract.c
int read_in_index(char *name);
int get_num_entries(void);
int find_name_in_Index(const char *name, struct Index_of_Files *Name_Entry);
int get_file(char *filename, int i, char *ptr);
