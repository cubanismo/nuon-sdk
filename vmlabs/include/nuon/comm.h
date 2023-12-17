/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


#ifndef _COMM_H
#define _COMM_H

#ifdef __cplusplus
extern "C" {
#endif

void _CommSend(int who, long packet[]);
void _CommSendInfo(int who, int info, long packet[]);
void _CommSendDirect(long p0, long p1, long p2, long p3, int who, int info);
int _CommRecvInfo(int *info, long packet[]);
int _CommRecvInfoQuery(int *info, long packet[]);
int _CommSendRecv(int who, long packet[]);
/* note info field is at end of param list not second */
int _CommSendRecvInfo(int who, long packet[],int info);

#ifdef __cplusplus
}
#endif

#endif /* _COMM_H */
