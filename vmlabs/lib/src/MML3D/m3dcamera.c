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
 * MML 3D camera functions
 *
 */

#include <stdlib.h>
#include "m3d.h"

/*
 * initialize a camera structure
 */

void
m3dInitCamera(m3dCamera *cam, m3dreal focalLength, m3dreal maxZ)
{
    m3dIdentityMatrix(&cam->matrix);
    cam->focalLength = focalLength;
    cam->backClip = maxZ;
}

/*
 * set the viewing matrix for a camera
 * we will actually want to use the
 * inverse of the matrix for most purposes
 * so that's what we keep
 */

void
m3dSetCameraMatrix(m3dCamera *cam, m3dMatrix *mat)
{
    m3dInvertTransformMatrix(&cam->matrix, mat);
}
