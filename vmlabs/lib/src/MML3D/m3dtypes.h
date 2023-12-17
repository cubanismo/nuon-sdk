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
 * misc. data types for 3D MMLs
 *
 */

#ifndef M3DTYPES_H
#define M3DTYPES_H

/*
 * A fixed point data type
 */

#define M3D_SHIFT 16

#define M3D_SCALE ((float)(1 << M3D_SHIFT))

typedef f16Dot16 m3dreal;

/* how to convert floats and ints to fixed */
#define M3DF(d) ((m3dreal)((d)*M3D_SCALE))
#define M3DI(i) ((m3dreal)((i) << M3D_SHIFT))


/* each row of the matrix consists of:
 *   3 rotation components
 *   1 translation
 * the last row is unused, for now
 *
 * So, for example, the translation component
 * of the matrix is the vector
 * (r[0][3], r[1][3], r[2][3])
 */

typedef struct m3dMatrix {
    m3dreal r[4][4];
} m3dMatrix;

/*
 * a structure describing a camera
 */
typedef struct m3dCamera {
    m3dMatrix matrix;
    m3dreal focalLength;
    m3dreal backClip;
} m3dCamera;

/*
 * a structure defining a single light
 */
#define FIX30F(f) (long)((f)*(double)(1<<30))
#define FIX28F(f) (long)((f)*(double)(1<<28))

typedef long f4Dot28;

typedef struct m3dLight {
    f2Dot30 x, y, z;
    f4Dot28 intense;
} m3dLight;

typedef struct m3dLightData {
    f4Dot28 ambient;
    int numlights;
    long res1, res2;
    m3dLight li[3];
} m3dLightData;


/*
 * structures for clipping planes
 */
typedef struct m3dClipPlane {
    short nx, ny, nz, nd;
} m3dClipPlane;


/*
 * functions for matrix arithmetic
 */
void m3dIdentityMatrix(m3dMatrix *mat);
void m3dEulerMatrix(m3dMatrix *mat, m3dreal xrot, m3dreal yrot, m3dreal zrot);
void m3dPlaceMatrix(m3dMatrix *mat, m3dreal x, m3dreal y, m3dreal z);
void m3dInvertTransformMatrix(m3dMatrix *dest, m3dMatrix *src);
void m3dMatrixMultiply(m3dMatrix *dest, m3dMatrix *A, m3dMatrix *B);

/*
 * functions for manipulating camera and light data structures
 */
void m3dInitLights(m3dLightData *lights, m3dreal ambient);
void m3dAddDirectionalLight(m3dLightData *lights, m3dreal x, m3dreal y, m3dreal z,
			    m3dreal intense);

void m3dInitCamera(m3dCamera *camera, m3dreal focalLength, m3dreal maxZ);
void m3dSetCameraMatrix(m3dCamera *camera, m3dMatrix *mat);

#endif
