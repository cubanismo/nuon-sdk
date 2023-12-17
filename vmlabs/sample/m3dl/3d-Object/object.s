
/*Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

	.data

	.export	_object
	.export	_objtex

	.align.v
_object:
	.binclude "data/troll.m3d"

	.align.v
_objtex:
	.binclude "data/troll.mbm"

