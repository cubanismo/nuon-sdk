/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

typedef struct {
	short	magic;
	short	submagic;
	long	base;
	long	sectsize;
	long	devsize;
	long	driver;
	long	loadsize;
	char	name[40];
} bootblock;

#define	SB_MEMORY_PARALLEL	0x3010
#define	SB_MEMORY_SERIAL	0x3020
#define	SB_MEMORY_LATCHED	0x3030

#define	SB_MEMORY_MAGIC	0x0666

#define	SBM_DRIVER	1
#define	SBM_APPCODE	2
#define	SBM_FS		3

bootblock	* _GetMemDevice(int i, int * port, int * id, int * err);
int	_WriteMemDevSector(bootblock * bb, long sectno, char * ram);
int	_ReadMemDev(bootblock * bb, long flashaddr, char * rambuf, long len);
