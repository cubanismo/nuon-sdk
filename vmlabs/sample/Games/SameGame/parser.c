
/* 
 * Copyright (c) 1999-2001, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */


#include "sg.h"

int Read_CNF_File()
{
  int fd, value, i;
  long filesize;
  char *buf, *buf2, *name;

  // If ON_DVD is 1 we assume sg.cnf is in /udf/nuon.  We
  // also turn off printf statements in this case.

  if (ON_DVD == 0){
    if ((fd = open("./sg.cnf", O_RDONLY, 0)) == -1){
      printf("Can't open sg.cnf\n");
      return -1;
    }
  }else{
    if ((fd = open("/udf/nuon/sg.cnf", O_RDONLY, 0)) == -1)
      return -1;
  }

  filesize = lseek(fd, 0L, SEEK_END);
  if (filesize == -1){
    if (ON_DVD == 0)
      printf("lseek failed\n");
    return -1;
  }
  lseek(fd, 0L, SEEK_SET);
  
  buf = malloc(filesize);
  if (buf == NULL){
    if (ON_DVD == 0)
      printf("Malloc request failed\n");
    return -1;
  }

  // check that this returns filesize
  if (read(fd, buf, filesize) != filesize){
    if (ON_DVD == 0)
      printf("read less than the entire file\n");
    return -1;
  }
  
  // put in EOF at the end of this (assumed) ASCII file
  *(buf + filesize) = '\0';

  // now parse the silly thing; don't use buf as this is a pointer to first part of
  // the buffer and we need it went we close

  buf2 = buf;

  //check first to see if the file starts with a comment
  if (*buf != '#'){
    if (ON_DVD == 0)
      printf("The file sg.cnf does not start with a comment\n");
    close(fd);
    free(buf);
    return -1;
  }

  // loop until NULL returned by find_good_line{
  for (;;){
    buf2 = find_good_line(buf2);  // returns NULL if none found
    if (buf2 == NULL)
      break;
    // set the appropriate variable
    name = buf2;
    while (*buf2 != ' ')  // should put in some error checking here;
      buf2++;
    // buf 2 should be pointing at the end of name, so let's change things so that name ends
    // with a zero (so we can do a string compare)
    *buf2 = '\0';
    // move buf2 along so that it points to the first non-space after the name
    buf2++;
    while (*buf2 == ' ')
      buf2++;

    if (strcmp(name, "Path") == 0){
      if (*buf2 != '\"'){
	if (ON_DVD == 0)
	  printf("Contents pathname not surrounded by quotes\n");
	return -1;
      }
      else{  // copy buf2 into Path
	buf2++;  //skip past quote
	i = 0;
	while (*buf2 != '\"'){   // put in other error checking later
	  Path[i] = *buf2;
	  buf2++;
	  i++;
	}
	Path[i] = '\0';
      }
    }else{
      // find the value of the variable and update buf2 so that it now
      // points just past the number (if it doesn't find a number, it
      // returns 0 and doesn't change buf2)
      value = strtol(buf2, &buf2, 10); // what if no number here?
      
      i = 0;
      while (Variables[i].Name != NULL){ 
	if (strcmp(Variables[i].Name, name) == 0){
	  *(Variables[i].Value) = value;
	  Variables[i].Flag = 1;
	  //	  if (ON_DVD == 0)
	  //	    printf("setting %s = %d\n", name, value);
	  break;
	}
	i++;
      }
      if (Variables[i].Name == NULL){
	if (ON_DVD == 0)
	  printf("%s not an acceptable variable name\n", name);
      }
    }

  }  // end of for(;;)

  close(fd);
  free(buf);
  return 0;
}


// ftn finds the next non-commented, non-blank line and returns a pointer
// to the beginning of that line; if there is no such line to find, it 
// returns NULL.  Ftn should be called with buf pointing to the beginning of
// the line.  (Very first time called, it is pointing at a comment.)
char* find_good_line(char *buf)
{

  while(*buf != '\0'){

  //skip to next line
    while ((*buf != '\0') && (*buf != '\n'))
      buf++;
    if (*buf == '\n')
      buf++;

    // check to see if it's good
    // if yes then return pointer, if no then skip to next line
    if (*buf != '\0'){
      if ((*buf != '#') && (*buf != ' ') && (*buf != '\r') && (*buf != '\n'))
	// it's good
	return buf;
    }
  }

  // end of file
  return NULL;
}




