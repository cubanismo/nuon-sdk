/*
 * Copyright (C) 1995-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */
	;
	; 3D pipeline parameter block
	; Version 1.0 for C
	;

	; all of these are global variables
	.module
	.segment m3dram
	
	.align.v
	
param_block:

	; the first part of the parameter block is designed
	; to look like Jeff's stuff
	
	; destination bitmap description
dest_info:

dest_dma_flags:
	.ds.s	1	; DMA flags for destination screen
dest_base_addr:
	.ds.s	1	; destination screen base address
dest_clip_info:
	.ds.s	1	; X clip (min X in high word, max X in low word)
	.ds.s	1	; Y clip (min Y in high word, max Y in low word)

	; rendering info
render_info:

cur_mpe:
	.ds.s	1	; which MPE this is
reserved1:
	.ds.s	1	; reserved (could be number of tris per MPE?)
total_mpes:
	.ds.s	1	; total rendering MPEs
num_polys:	
	.ds.s	1	; number of polygons in model
	

	;
	; 3D pipeline specific stuff
	;
	
	; current transformation matrix: 4x4
	; (must be vector aligned)
cur_matrix:
	.ds.s	16

camera:
camera_focal_length:
	.ds.s	1	; focal length for camera (16.16 fixed point)
camera_back_clip:
	.ds.s	1	; distance to back clipping plane (16.16 fixed point)
camera_center_x:
	.ds.s	1	; center of viewpoint (16.16 fixed point)
camera_center_y:
	.ds.s	1	; center of viewpoint (16.16 fixed point)
	
	; pointer to triangle data
model_data:
	.ds.s	1
reserved2:
	.ds.s	1	; reserved for future expansion

	;
	; pointers to pipeline pieces
	;
pipeline_funcs:
	
loadpoly_func:
	.ds.s	1	; function to load a polygon in standard form
xform_func:
	.ds.s	1	; function to transform a point
persp_func:
	.ds.s	1	; function to do perspective projection

calcclip_func:
	.ds.s	1	; function to calculate clipping coordinates
doclip_func:
	.ds.s	1	; function to clip a polygon to the viewing frustum
light_func:
	.ds.s	1	; lighting function
polygon_func:
	.ds.s	1	; top level polygon drawing function

pixel_func:
	.ds.s	1	; pixel generating function

	;; standard "assistance" functions
recip_func:
	.ds.s	1	; reciprocal function

reserved3:
	.ds.s	1	; reserved (forces vector alignment)

light_data:
	.ds.s	16	; lighting coefficients

clip_data:
	.ds.s	16	; clipping planes
	
	;
	; in the current implementation, any initialized data
	; (such as the recip lookup table) needs to be part
	; of the parameters!
	;
	;
	; table storage for recip, etc.
	;

RecipLUT:
	.ds.s	64
	
	