/*
 * Copyright (C) 1997-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

/*
 * C interfaces to comm bus routines
 */

#include <nuon/comm.h>

int
CommRecv(long packet[])
{
    int info;
    return _CommRecvInfo(&info, packet);
}

int
CommRecvQuery(long packet[])
{
    int info;
    return _CommRecvInfoQuery(&info, packet);
}

