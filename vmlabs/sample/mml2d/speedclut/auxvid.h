/*
   Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
*/

/* Prototypes for convenient video management functions 
 */
#include <nuon/video.h>
#include <nuon/mml2d.h>

#define MIN( x, y ) ( (x) < (y) ? x : y )

void mmlConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int horFilter, int hScale );
void mmlConfigOSD( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int hScale );
void mmlConfigMain( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset );
