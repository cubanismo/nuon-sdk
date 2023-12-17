/*
 * 
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#ifndef _DMACALLS_H_
#define _DMACALLS_H_

// Offsets into scratch buffer for commands and image data

#define MDMA_CMDBUF1		(0)
#define MDMA_CMDBUF2		(8)
#define ODMA_CMDBUF1		(16)
#define ODMA_CMDBUF2		(20)
#define IMAGE_BUF_OFFSET	(24)

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

typedef struct
{
	long	flags;
	long	*ram_address;
	long	*mpe_address;

} OtherBusDMACommand;

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void odma_command(void *cmd);
void mdma_command(void *cmd);
void odma_clear(void);
void mdma_clear(void);
int odma_status(void);
int mdma_status(void);

#endif
