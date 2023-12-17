/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */
	;; new, improved, jpeg'd version
	.data
	.export _catpix128_start
	.export _catpix128_size
_catpix128_start:
	.binclude "fluff128.jpg"
`end:
	_catpix128_size = `end - _catpix128_start
	.align 32
