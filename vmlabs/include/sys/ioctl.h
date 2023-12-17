/*
   Copyright (c) 1999-2000, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
 */

#ifndef	_SYS_IOCTL_H_
#define	_SYS_IOCTL_H_

#define UDFGETSTARTSECTOR	0x00010000
#define UDFGETSECTORLENGTH	0x00010001
#define GETFSLENGTH		0x00010002
#define GETFLASHCONFIG		0x00010003
#define ISOGETSTARTSECTOR	0x00010004
#define ISOGETSECTORLENGTH	0x00010005

#define TTY_NONBLOCK        0x00010000

#define SERIAL_BAUD         0x00020000
#define SERIAL_PARITY       0x00020001
  #define SERIAL_PARITY_NONE  0x0
  #define SERIAL_PARITY_ODD   0x1
  #define SERIAL_PARITY_EVEN  0x2

#define ROM_FILE_START         0x00030000
#define ROM_FILE_SIZE          0x00030001
#define ROM_FILE_DIR           0x00030002
#define ROM_SET_DISK_IMAGE     0x00030003
#define ROM_GET_DISK_IMAGE     0x00030004

#define PPP_CONNECT         0x00040000
#define FIONBIO             0x00040001
#define FIONREAD            0x00040002
#define SIOCATMARK          0x00040003
#define TCPPOLL             0x00040004
#define TCPINIT		    0x00040005    /* This is sent to the device not the socket! */
#define PPP_DISCONN	    0x00040006 	  /* Added to allow disconnect from PPP */

#define KBD_GET_COOK_MODE   0x80

#define KBD_COOK_ASCII 0
#define KBD_COOK_RAW 1
#define KBD_COOK_UNICODE 2
#define KBD_COOK_SJIS 3
#define KBD_COOK_RAW_TEXT 4


int ioctl(int d, int request, ...);

#endif
