#
# Makefile for CreateDataFile code
#
# Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
#
# NOTICE: VM Labs permits you to use, modify, and distribute this file
# in accordance with the terms of the VM Labs license agreement
# accompanying it. If you have received this file from a source other
# than VM Labs, then your use, modification, or distribution of it
# requires the prior written permission of VM Labs.



CC = gcc
DBGFLAGS = -g 
OPT= -O

#CFLAGS = $(DBGFLAGS) $(OPT) -Wall -I/usr/local/include
CFLAGS = $(DBGFLAGS) $(OPT) -Wall
LFLAGS = $(DBGFLAGS)

LIBS =

default: Cat_files

Cat_files: cat_files.o
	$(CC) $(LFLAGS) -o Cat_files cat_files.o $(LIBS)

Xtract: xtract_main.o xtract.o
	$(CC) $(LFLAGS) -o Xtract xtract_main.o xtract.o $(LIBS)

xtract.o: xtract.c xtract.h

##############################3

clean:
	$(RM) *.o

realclean:
	$(RM) *.o Cat_files Xtract
