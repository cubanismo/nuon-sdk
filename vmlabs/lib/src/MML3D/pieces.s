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
	; 3D pipeline -- overall component include file
	; Version 1.0 for C
	;

RUN_IN_CACHE = 0

.if RUN_IN_PLACE
	RUN_IN_CACHE = 1
.endif
	
.if RUN_IN_CACHE
	CODEALIGN = 32
	.cache
.else
	CODEALIGN = 8
	.nocache
.endif	
	.text
	.nooptimize		; already hand optimized!
	
	.include "pipeline.s"
	.include "reciphi.s"
	.include "loadpoly.s"

//	.include "xformhi.s"
	.include "xformlo.s"
	.include "clip.s"
	.include "light.s"
	.include "persp.s"


	.if 1
	.include "poly.s"	
	.include "pixel.s"
	.include "bilerp.s"
	.endif

	.if INCLUDE_EDGEAA
	.include "aapoly.s"
	.include "aabilerp.s"
	.endif

	.include "mpegpix.s"
		
	.segment m3dram
	.origin $20100000
	.include "param.s"
	.include "global.s"



