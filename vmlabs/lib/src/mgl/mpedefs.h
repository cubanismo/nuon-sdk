/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/


#ifndef MPEDEFS_H
#define MPEDEFS_H

#define DATA_OVERLAY_ORIGIN				0x20100000			// .overlay; needs vector alignment
#define MANAGER_OVERLAY_ORIGIN			0x20300000			// .overlay; needs vector alignment
#define COMM_OVERLAY_ORIGIN				0x203000c0			// .overlay; needs vector alignment
#define VERTEX_LOADER_OVERLAY_ORIGIN	0x203000f0			// not .overlay
#define CLIPPER_OVERLAY_ORIGIN			0x20300478			// not .overlay
#define RASTERIZER_OVERLAY_ORIGIN		0x203007d0			// not .overlay

#define DATA_OVERLAY_MAX_SIZE			(0x20101000 - DATA_OVERLAY_ORIGIN)
#define MANAGER_OVERLAY_MAX_SIZE		(COMM_OVERLAY_ORIGIN - MANAGER_OVERLAY_ORIGIN)
#define COMM_OVERLAY_MAX_SIZE			(VERTEX_LOADER_OVERLAY_ORIGIN - COMM_OVERLAY_ORIGIN)
#define CLIPPER_OVERLAY_MAX_SIZE		(RASTERIZER_OVERLAY_ORIGIN - CLIPPER_OVERLAY_ORIGIN)
#define RASTERIZER_OVERLAY_MAX_SIZE		(0x20301000 - RASTERIZER_OVERLAY_ORIGIN)

#define MPE_TASK_COMPLETE				(0x3d + 0x0)
#define MPE_TASK_RENDER					(0x3d + 0x1)

#define MAX_TEX_MEM						528					// scalars; pixmap + clut

#define MAX_LIGHTS						4
#define LIGHT_DATA_SIZE					(4 * MAX_LIGHTS + 3)	// scalars

#define SPECULAR_LUT_BITS				4
#define SPECULAR_LUT_ENTRIES			((1 << SPECULAR_LUT_BITS) + 1)
#define SPECULAR_LUT_SIZE				((SPECULAR_LUT_ENTRIES + 1) >> 1)	// scalars; each entry is a word

#define DMA_CACHE_EOR					0x100				// MPEDMACache1 ^ MPEDMACache2

#define MAX_RENDERING_MPES				3

#define MAX_VERTS						3*512				// max buffered between begin and end

#define GLCOLORSHIFT					8
#define GLCOLORMAX						((1 << GLCOLORSHIFT) - 1)

#define GLMAXSUBDIVISION				16					// 1 is 1/w per pixel in both dimensions!
															// Howdy pardner!  Thinking about making this
															// >16?  Don't!  Unless of course you're
															// willing to increase the number of
															// entries in MPEPolygonScanlineRecipLUT in
															// manage.s (SML 8/18/98)
															//
															// A subdivision of 8 will work up
															// to around where the nearest vertex
															// of a 10 pixel high 240 pixel wide
															// isosceles triangle's bottom vertices
															// are 4x closer to the viewer than
															// the top vertex.	Choose your near
															// z-clipping plane carefully.
															//
															// More generally, it appears that the trick to 
															// accurate subdivision is that the starting z 
															// coordinate of a subdivision is within
															// a factor of 2 of the ending z.  This allows
															// the derivation of a formula for calculating
															// optimal spans:
															//
															// l = -1/(2 * z(left)) * dX/d(1/z)
															// 
															// Where l is the calculated length of a
															// subdivision.  If l > the remainder of
															// a scanline or the space remaining in
															// a DMA cache, just substitute in the
															// shorter length.	If l<=1, you're stuck
															// with 1 divide per pixel.  Please note
															// that the special case of d(1/z)/dX < 1/2^31
															// should be handled as infinite length
															// subdivisions.  Note that we have not
															// implemented this yet, but plan to do so
															// by Aries (SML 8/29/98)

#define CLIP_XMIN						1
#define CLIP_YMIN						3
#define CLIP_ZMIN						5

#define CLIP_XMAX						(CLIP_XMIN - 1)
#define CLIP_YMAX						(CLIP_YMIN - 1)
#define CLIP_ZMAX						(CLIP_ZMIN - 1)

#define CLIP_XMAX_MASK					(1 << CLIP_XMAX)
#define CLIP_YMAX_MASK					(1 << CLIP_YMAX)
#define CLIP_ZMAX_MASK					(1 << CLIP_ZMAX)

#define GLXYZSCREENSHIFT				10

#define GLINVDXSCREENSHIFT				32

#define GLMINZSHIFT						37					// This value controls the minimum allowable value of
															// of z before 1/z encounters an arithmetic overflow.
															// It is currently set for 1.0.  Increase this by one to
															// change this to 0.5 or decrease this by one to increase the
															// minimum allowable z to 2.0 and so on.  Sorry for such a kludge,
															// but this is the price paid for no floating point math.
															// The dynamic range of z where there is at least 16 bits
															// of precision ranges from MINZ to 65536 * MINZ.  Above
															// MINZ, 1/z loses 1 bit of precision per factor of 2
															// beyond MINZ.
															//
															// While I just stated that 1.0 is the minimum z allowable
															// before arithmetic overflow, fixed point roundoff error
															// in z-clipping forces one to stay a small amount say 0.01
															// or so above MINZ (in the default case, this is ~1.01).
	

#define GLZDEPTHSHIFT					31					// The effective operating range for Z is from
															// 1 to 65535 << 15.  This results
															// in a ~16 bit dynamic range for z dimensions
															// where the near clipping plane can be right
															// in your face.  Texturing has been optimized
															// to minimize fixed point roundoff error when
															// polygons are big and in your face.  As polygons
															// get further from the viewer, consult the
															// chart below to calculate when jitter will
															// appear.	A little attention to detail and
															// understanding of the interplay between
															// texture coordinates and z can result in
															// the limitations of this engine being completely
															// invisible.  Hopefully, it will just work for
															// the usual game situations.

#define GLINVWSCREENSHIFT				23					// 1/z ranges from just under 2^31 to 2^15 within
															// the useful dynamic range

#define GLXYZWCLIPSHIFT					10

#ifndef GLXYZWMODELSHIFT
#define GLXYZWMODELSHIFT				10					// must match value in gl.h!
#endif

#ifndef GLTRIGSHIFT
#define GLTRIGSHIFT						14					// must match value in gl.h!
#endif

#ifndef GLNORMALSHIFT
#define GLNORMALSHIFT					14					// must match value in gl.h!
#endif

#ifndef GLTEXCOORDSHIFT
#define GLTEXCOORDSHIFT					18					// must match value in gl.h!
#endif														//
															// This value is the result of a delicate tradeoff
															// between maximum allowable texture dimensions
															// and onscreen stability.	At 14, a 120x120 square
															// can be 1 texel wide and rock stable at a z 
															// distance of 256 and z/256 texels wide for any 
															// larger values of z. Smaller widths/heights than
															// this minimum will jitter.  The jitter gets worse
															// the more one violates this limit.
															//
															// At the same time, fixed point perspective divides 
															// limit texture dimensions to + or - 512.	Increasing
															// GLTEXCOORDSHIFT by 1 will divide the maximum
															// texture coordinate by 2 and double the 1 texel
															// wide stability z value.	Decreasing GLTEXCOORDSHIFT
															// by 1 will double the maximum allowable texture
															// dimension and halve the 1 texel wide stability
															// point.  Simple, eh?	No?  OK, here's a chart:
															// GLTEXCOORDSHIFT	max |s,t|	z stable
															//	11				 4096			 32
															//	12				 2048			 64
															//	 13 			  1024			  128
															//	14				 512			 256
															//	15				 256			 512
															//	 16 			  128			  1024
															//	 17 			  64			  2048
															//
															// The rest of the chart is left as an exercise
															// for the coder!
															//
															// Please note that the maximum texture dimensions
															// includes tiling so if you have an m x n texture,
															// you can only tile it max|s,t|/m and max|s,t|/n
															// times in the m and n dimensions within a single
															// polygon


															// Todos
															// 1) Prevent existence of negative 1/z at ends
															//	  of scanline by moving end of a span in one
															//	  pixel to the left.  If you have a really
															//	  close near z plane (<4 and perhaps elsewhere)
															//	  the right sides of polygons can look weird.
															//	  It's a mostly painless fix, but we may
															//	  never actually see the problem so I'm
															//	  leaving it in for now
															//
															// 2) Change fixed point s/z and t/z to pseudo-
															//	  floating point numbers in order to remove
															//	  perspective divide limitations

#endif // MPEDEFS_H
