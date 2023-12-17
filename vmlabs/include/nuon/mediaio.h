/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


#ifndef MEDIA_IO_H
#define MEDIA_IO_H

#ifdef __cplusplus
extern "C" {
#endif

enum
{
    MEDIA_BOOT_DEVICE=1,
    MEDIA_DVD,
    MEDIA_REMOTE,
    MEDIA_FLASH,
    MEDIA_SBMEM,

/* now for open modes */
    MEDIA_READ = 0,
    MEDIA_WRITE,
    MEDIA_RW,

/* ioctls */
    MEDIA_IOCTL_SET_MODE = 0,
    MEDIA_IOCTL_GET_MODE,
    MEDIA_IOCTL_EJECT,
    MEDIA_IOCTL_RETRACT,
    MEDIA_IOCTL_FLUSH,
    MEDIA_IOCTL_GET_DRIVETYPE,
    MEDIA_IOCTL_READ_BCA,
    MEDIA_IOCTL_GET_START,
    MEDIA_IOCTL_SET_START,
    MEDIA_IOCTL_SET_END,
    MEDIA_IOCTL_GET_PHYSICAL,
    MEDIA_IOCTL_OVERWRITE,
    MEDIA_IOCTL_ERASE,
    MEDIA_IOCTL_SIZE,
    MEDIA_IOCTL_CDDATA_OFFSET,

/* now for read/write modes (callback types) */
    MCB_END     = 0x1<<30,
    MCB_EVERY   = 0x2<<30,
    MCB_ERROR   = 0x3<<30,

/* DVD modes */
    MEDIA_IOCTL_MODE_DATA=0,
    MEDIA_IOCTL_MODE_AUDIO,
    MEDIA_IOCTL_MODE_SUBCH,
    MEDIA_IOCTL_MODE_AUDIO_FUZZY,
};

/* These are selectors for the presence of particular device types */
#define HAVE_BOOT_MEDIA (1<<(MEDIA_BOOT_DEVICE - MEDIA_BOOT_DEVICE))
#define HAVE_DVD_MEDIA (1<<(MEDIA_DVD - MEDIA_BOOT_DEVICE))
#define HAVE_REMOTE_MEDIA (1<<(MEDIA_REMOTE - MEDIA_BOOT_DEVICE))
#define HAVE_FLASH_MEDIA (1<<(MEDIA_FLASH - MEDIA_BOOT_DEVICE))

typedef struct _mediadevinfo
{
   long type;
   long state;
   long sectorsize;
   int  bus;
   int  id;
   int datarate;
} MediaDevInfo;

typedef long ((*MediaCB)(long status, long block));

int _MediaOpen(int, const char *, int, int *);
void _MediaClose(int);
int _MediaGetDevicesAvailable(void);
int _MediaGetInfo(int, MediaDevInfo *);
int _MediaGetStatus(int);

/* callbacks work like this:
 * callback will receive status of, the mode it was called with for
 * normal operation or MCB_ERROR if an error was detected.
 *
 * when mode is MCB_END it is called at the end of the transfer
 *  or if there is an error.  in case of error, return 0 to end tranfer
 *  or non-zero to keep going.  in case of transfer end, return is ignored
 *
 * when mode is MCB_EVERY then callback is called for every sector
 *  or if there is an error.  in case of error, do as above.  Otherwise,
 *  the return address is ignored.
 */
int _MediaRead(long handle,int mode, long start, long count, char *buf, MediaCB cb);
int _MediaWrite(long handle,int mode, long start, long count, char *buf, MediaCB cb);
long _MediaIoctl(long handle,long ctl, char *value);


int _MediaInitMPE(void);
void _MediaShutdownMPE(void);


/* these variables and functions are not yet documented */
long _spinwait(long, long);
extern volatile long _MediaWaiting;


/*
 * Disk control functions
 */
int _DiskEject(void);
int _DiskRetract(void);
int _DiskChange(int flags, int destSlot, unsigned int *newSlot);

#ifdef __cplusplus
}
#endif

#endif
