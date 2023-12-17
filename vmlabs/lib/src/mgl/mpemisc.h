/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/


#ifndef MPEMISC_H
#define MPEMISC_H

// Rasterizers
extern long RasterStub[], RasterStub_size[];
extern long RasterC[], RasterC_size[];
extern long RasterCB[], RasterCB_size[];
extern long RasterCB2[], RasterCB2_size[];
extern long RasterST[], RasterST_size[];
extern long RasterSTF[], RasterSTF_size[];
extern long RasterSTFI[], RasterSTFI_size[];
extern long RasterSTI[], RasterSTI_size[];
extern long RasterSTP[], RasterSTP_size[];
extern long RasterSTFP[], RasterSTFP_size[];
extern long RasterSTFPI[], RasterSTFPI_size[];
extern long RasterSTPI[], RasterSTPI_size[];
extern long RasterSTPK[], RasterSTPK_size[];
extern long RasterSTFPK[], RasterSTFPK_size[];
extern long RasterSTPKI[], RasterSTPKI_size[];
extern long RasterSTFPKI[], RasterSTFPKI_size[];
extern long RasterSTFPB[], RasterSTFPB_size[];
extern long RasterSTFPB2[], RasterSTFPB2_size[];

// Vertex loaders
extern long LoadV4Triangles[], LoadV4Triangles_size[];
extern long LoadV8Triangles[], LoadV8Triangles_size[];

// Vertex Lighters
extern long LightI[], LightI_size[];
extern long LightGRB[], LightGRB_size[];

// Vertex transformers
extern long TransformXYZ4[], TransformXYZ4_size[];
extern long TransformXYZW8[], TransformXYZW8_size[];

// Trivial accept/reject code
extern long TrivialV4Triangle[], TrivialV4Triangle_size[];
extern long TrivialV8Triangle[], TrivialV8Triangle_size[];

// Polygon clippers
extern long ClipXYZWUVCTriangle[], ClipXYZWUVCTriangle_size[];
extern long ClipXYZWCTriangle[], ClipXYZWCTriangle_size[];
extern long ClipXYZWUVITriangle[], ClipXYZWUVITriangle_size[];
extern long ClipXYZWUVIFTriangle[], ClipXYZWUVIFTriangle_size[];

// Misc

extern long Manager_start[], Manager_size[];
extern long EventHandler[];
extern long Comm_start[], Comm_size[];
extern long Comm0_start[], Comm0_size[];
extern long Data_start[], Data_size[];

extern long MPETextureCache[];
extern long MPETextureInfo[];
extern long MPELights[];
extern long MPESpecularLUT[];
extern long MPEFogParameter[];
extern long MPEMatrix[];
extern long MPEViewport[];
extern long MPEDMACache1[], MPEDMACache2[];
extern long MPEDMAFlags[];
extern long MPEController[];
extern long MPETaskCounterAddress[];
extern long MPEVertexCache[];

#endif // MPEMISC_H
