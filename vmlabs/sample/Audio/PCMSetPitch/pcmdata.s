/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

; Place PCM data into the "pcmdata" segment so we have the option of
; telling the linker where it should go into memory.
	
	.segment pcmdata

	.export	_Sine
	.export	_SineEnd
	
	.align.v
_Sine:
	.binclude "sin500.pcm"
_SineEnd:

