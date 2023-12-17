
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Simple video setup code -- displays a pixmap in
 * the main channel.
 *
 * Only works in native mode.
 */
//#include <nuon/mlpixmap.h>
#include "m2config.h"
#include "../../nuon/mml2d.h"
#include <nuon/bios.h>

void
mmlSimpleVideoSetup(mmlDisplayPixmap* sP, mmlSysResources* srP, mmlVideoFilter filttype)
{
#if (USE_DISPATCHER == 0)
    _VidSetup(sP->memP, sP->dmaFlags, sP->wide, sP->high, filttype);
#endif
}
