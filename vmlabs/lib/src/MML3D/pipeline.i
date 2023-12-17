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
	;
	; 3D pipeline defines
	; Version 1.0 for C
	;

	; global variables that various modules will want to import

	; parameter block items

	.import param_block
	.import dest_info
	.import dest_dma_flags
	.import dest_base_addr
	.import dest_clip_info

	.import render_info
	.import cur_mpe
	.import total_mpes

	.import cur_matrix
	.import camera
	.import camera_focal_length
	.import camera_back_clip
	.import	camera_center_x
	.import camera_center_y

	.import	model_data

	.import	pipeline_funcs
	.import	loadpoly_func
	.import	xform_func
	.import	calcclip_func
	.import	doclip_func
	.import	light_func
	.import	persp_func
	.import	polygon_func
	.import	pixel_func
	.import	recip_func

	; global variables
	.import	dmacmd
	.import	pixdmacmd
	.import	save_r31
	.import save_rz
	.import	save_sp

	.import	load_inpbuf1
	.import	load_inpbuf2

	.import	pix_linebuf1
	.import	pix_linebuf2

	.import	inp_polygon

	.import	loadpoly_data
	.import	xform_data
	.import	clip_data
	.import	doclip_data
	.import	light_data
	.import	persp_data
	.import	polygon_data
	.import	pixel_data

	.import	extra_data_ptr
	.import	top_of_stack

	.import	TEXTURE


	; useful defines
NUM_PIPELINE_FUNCS = 8
