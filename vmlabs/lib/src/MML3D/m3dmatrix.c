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
 * MML 3D matrix functions
 *
 */

//#define DEBUG
#include <stdlib.h>
#include <nuon/mutil.h>
#include "m3d.h"

#ifdef DEBUG
#include <stdio.h>

void
m3dPrintMatrix(m3dMatrix *mat)
{
    int i;

    for (i = 0; i < 4; i++) {
	printf("%08x %08x %08x %08x\n", mat->r[i][0], mat->r[i][1], mat->r[i][2],
	       mat->r[i][3]);
    }
}
#endif

/*
 * make a matrix the identity
 */

void
m3dIdentityMatrix(m3dMatrix *mat)
{
    int i, j;
    for (i = 0; i < 4; i++) {
	for (j = 0; j < 4; j++) {
	    mat->r[j][i] = 0;
	}
    }

    mat->r[0][0] = M3DI(1);
    mat->r[1][1] = M3DI(1);
    mat->r[2][2] = M3DI(1);
    mat->r[3][3] = M3DI(1);
}

/*
 * fill in the rotation parts of
 * a matrix from Euler angles;
 * xrot is rotations around X axis,
 * yrot is rotations around Y axis,
 * zrot is rotations around Z axis
 * The rotations are performed in
 * the listed order
 */
void
m3dEulerMatrix(m3dMatrix *M, m3dreal xrot, m3dreal yrot, m3dreal zrot)
{
    m3dreal cos_x, sin_x;
    m3dreal cos_y, sin_y;
    m3dreal cos_z, sin_z;

    /* find the sine and cosine, as 2.30 numbers */
    FixSinCos(xrot, &sin_x, &cos_x);
    FixSinCos(yrot, &sin_y, &cos_y);
    FixSinCos(zrot, &sin_z, &cos_z);

    /* multiply 2.30 numbers, and convert the result to 16.16 */
    M->r[0][0] = FixMul(cos_y,cos_z,30+14);
    M->r[0][1] = FixMul(-cos_y,sin_z,30+14);
    M->r[0][2] = (-sin_y)>>14;
    M->r[0][3] = 0;

    M->r[1][0] = (FixMul(cos_x,sin_z,30) - FixMul(FixMul(sin_x,sin_y,30),cos_z,30)) >> 14;
    M->r[1][1] = (FixMul(cos_x,cos_z,30) + FixMul(FixMul(sin_x,sin_y,30),sin_z,30)) >> 14;
    M->r[1][2] = FixMul(-sin_x,cos_y,30+14);
    M->r[1][3] = 0;

    M->r[2][0] = (FixMul(sin_x,sin_z,30) + FixMul(FixMul(cos_x,sin_y,30),cos_z,30)) >> 14;
    M->r[2][1] = (FixMul(sin_x,cos_z,30) - FixMul(FixMul(cos_x,sin_y,30),sin_z,30)) >> 14;
    M->r[2][2] = FixMul(cos_x,cos_y,30+14);
    M->r[2][3] = 0;

    /* set up the last row */
    M->r[3][0] = M->r[3][1] = M->r[3][2] = 0;
    M->r[3][3] = M3DI(1);
}


/*
 * fill in the position parts of
 * a matrix from three constants
 */
void
m3dPlaceMatrix(m3dMatrix *dest, m3dreal x, m3dreal y, m3dreal z)
{
    dest->r[0][3] = x;
    dest->r[1][3] = y;
    dest->r[2][3] = z;
}


/*
 * find the inverse of a transformation
 * matrix, i.e. a matrix which is a concatentation
 * of translations and rotations
 */

void
m3dInvertTransformMatrix(m3dMatrix *dest, m3dMatrix *src)
{
    m3dMatrix pos, rot;
    int i, j;

#ifdef DEBUG
    printf("INVERT: Input matrix:\n");
    m3dPrintMatrix(src);
#endif
    /* invert the rotation part by finding its transpose */
    for (i = 0; i < 3; i++) {
	for (j = 0; j < 3; j++) {
	    rot.r[j][i] = src->r[i][j];
	}
    }
    for (i = 0; i < 3; i++) {
	rot.r[3][i] = rot.r[i][3] = 0;
    }
    rot.r[3][3] = M3DI(1);

    /* find the inverse of the translation part */
    m3dIdentityMatrix(&pos);
    pos.r[0][3] = -src->r[0][3];
    pos.r[1][3] = -src->r[1][3];
    pos.r[2][3] = -src->r[2][3];

    /* finally calculate their product */
    m3dMatrixMultiply(dest, &rot, &pos);

#ifdef DEBUG
    printf("Output matrix:\n");
    m3dPrintMatrix(src);
    fflush(stdout);
#endif
}

/*
 * multiply matrices A and B to produce matrix C
 * all three pointers MUST point to different
 * matrices!!
 */

void
m3dMatrixMultiply(m3dMatrix *C, m3dMatrix *A, m3dMatrix *B)
{
    int i,j;
    m3dreal x, y, z, d;

    /* for now, only bother with the three top rows */
    for (i = 0; i < 3; i++) {
	x = A->r[i][0];
	y = A->r[i][1];
	z = A->r[i][2];
	d = A->r[i][3];

	for (j = 0; j < 4; j++) {
	    C->r[i][j] =
		FixMul(x, B->r[0][j], M3D_SHIFT) +
		FixMul(y, B->r[1][j], M3D_SHIFT) +
		FixMul(z, B->r[2][j], M3D_SHIFT) +
		FixMul(d, B->r[3][j], M3D_SHIFT);
	}
    }
}
