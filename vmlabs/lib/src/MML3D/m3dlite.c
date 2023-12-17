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
 * MML 3D lighting functions
 *
 */

#include <stdlib.h>
#include "m3d.h"

/*
 * initialize a lighting structure
 */

void
m3dInitLights(m3dLightData *light, m3dreal ambient)
{
    /* convert ambient from 16.16 to 4.28 */
    light->ambient = ambient << 12;
    light->numlights = 0;
}

/*
 * add a directional light to a lighting
 * structure
 */

void
m3dAddDirectionalLight(m3dLightData *light, m3dreal x, m3dreal y, m3dreal z, m3dreal intense)
{
    int i;

    i = light->numlights;
    if (i < 3) {
	light->li[i].x = (x << 14);
	light->li[i].y = (y << 14);
	light->li[i].z = (z << 14);
	light->li[i].intense = (intense << 12);
	light->numlights++;
    }
}
