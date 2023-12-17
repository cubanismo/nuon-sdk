/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

/* $Id: bios.h,v 1.19 2001/10/25 00:00:33 ersmith Exp $ */

#ifndef _BIOS_H
#define _BIOS_H

#ifdef __cplusplus
extern "C" {
#endif

/************************************************
 Bios information structure and function
 ************************************************/

struct BiosInfo {
    unsigned short major_version;
    unsigned short minor_version;
    unsigned short vm_revision;
    unsigned short oem_revision;
    char *info_string;
    char *date_string;
    unsigned int HAL_version;
};

struct BiosInfo *_BiosGetInfo(void);

/************************************************
 Interrupt setting functions
 ************************************************/

void *_IntSetVector(int which, void *newvector);
void *_IntGetVector(int which);

/* defines for interrupt vector numbers */
#define kIntrVideo      31
#define kIntrSystimer1  30
#define kIntrSystimer0  29
#define kIntrGPIO       28
#define kIntrAudio      27
#define kIntrHost       26
#define kIntrDebug      25
#define kIntrMBDone     24
#define kIntrDCTDone    23
#define kIntrIIC        20
#define kIntrSystimer2  16
#define kIntrCommXmit    5
#define kIntrCommRecv    4
#define kIntrSoftware    1
#define kIntrException   0


/************************************************
 Parental controls
 ************************************************/
void _SetParentalControl(int level);
int _GetParentalControl(void);

/************************************************
 Game loading
 ************************************************/
void _LoadGame(const char *filename);

/************************************************
 Patching jump table
 ************************************************/
void *_PatchJumptable(void *entry, void *function);

/************************************************
 Memory allocation
 ************************************************/
void _MemInit(int dokernel);
void _MemAdd(unsigned long base, unsigned long size, unsigned flags);
void *_MemAlloc(unsigned long size, unsigned align, unsigned flags);
void _MemFree(void *);
void *_MemLocalScratch(int *);

/* flags for _MemAlloc and _MemAdd */
#define kMemSDRAM  1
#define kMemSysRam 2
#define kMemKernel 4

/************************************************
 Emergency broadcast messages
 ************************************************/

int _BiosPoll(char *msg);
#define kPollContinue    0
#define kPollSaveExit    1
#define kPollDisplayMsg  2
#define kPollPauseMsg    3

int _BiosPauseMsg(int rval, char *msg, void *framebuf);


/************************************************
 Other BIOS functions
 ************************************************/

unsigned long _BiosIRMask(int mode, unsigned long mask);
void _BiosExit(int exitcode);
void _BiosReboot(void);

/************************************************
 Low-Level file access functions
 ************************************************/

#include <sys/stat.h>

int _FindName(const char *path, int element, char *buf, int buflen, int *errnum);
int _FileOpen(const char *path, int access, int mode, int *errnum);
int _FileClose( int fd, int *errnum );
int _FileIoctl(int fd, int request, void *argp, int *errnum);
int _FileFstat(int fd, struct stat *buf, int *errnum);
int _FileLseek(int fd, int offset, int whence, int *errnum);
int _FileIsatty ( int fd, int *errnum );
int _FileStat(const char *path, struct stat *buf, int *errnum);
int _FileWrite(int fd, char *buf, int len, int *errnum);
int _FileRead(int fd, char *buf, int len, int *errnum);
int _FileLink(const char *oldpath, const char *newpath, int *errnum);
int _FileLstat(const char *file_name, struct stat *buf, int *errnum);
int _FileUnlink(const char *pathname, int *errnum);

#ifdef __cplusplus
}
#endif


#include <nuon/mpe.h>
#include <nuon/comm.h>
#include <nuon/cache.h>
#include <nuon/audio.h>
#include <nuon/video.h>
#include <nuon/joystick.h>
#include <nuon/time.h>
#include <nuon/mediaio.h>


#endif


