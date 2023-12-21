/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

	.segment	gfxdata
	
	.export	_BackgroundImage

	.align.v
_BackgroundImage:
	.binclude "bg.MBI"



	.export	_SpriteData

	.align.v
_SpriteData:
	.binclude "sprite.MBM"

	.export	_SpriteData2

	.align.v
_SpriteData2:
	.binclude "sprite2.MBM"


	.export	_SpriteData3

	.align.v
_SpriteData3:
	.binclude "sprite3.MBM"


