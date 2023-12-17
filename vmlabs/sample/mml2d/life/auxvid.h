/*
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission 
 */


/* Prototypes for convenient video management functions 
 */
#include <nuon/video.h>
#include <nuon/mml2d.h>

#define MIN( x, y ) ( (x) < (y) ? x : y )

void mmlConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int horFilter, int hScale );
void mmlConfigOSD( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int hScale );
void mmlConfigMain( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset );
