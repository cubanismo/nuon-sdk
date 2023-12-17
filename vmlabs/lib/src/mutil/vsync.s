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
	; compatibility cruft; the
	; old VidSync() call is implemented
	; by the BIOS _VidSync(1).
	;
	.import __VidSync
	.export _VidSync
_VidSync:
	jmp	__VidSync
	mv_s	#1,r0
	nop
	