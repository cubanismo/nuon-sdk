
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


	.export	_BackgroundMBIhiycc
	.export	_BackgroundMBIloycc
	.export	_BackgroundMBIhigrb
	.export	_BackgroundMBIlogrb

	.align.v
_BackgroundMBIhiycc:
	.binclude "data/bghiycc.mbi"		;hi res ycc
_BackgroundMBIloycc:
	.binclude "data/bgloycc.mbi"		;lo res ycc
_BackgroundMBIhigrb:
	.binclude "data/bghigrb.mbi"		;hi res grb
_BackgroundMBIlogrb:
	.binclude "data/bglogrb.mbi"		;lo res grb

	.export	_BallMBMhiycc
	.export	_BallMBMhigrb

	.align.v
_BallMBMhiycc:
	.binclude "data/bhiycc.mbm"		;hi res ycc
_BallMBMhigrb:
	.binclude "data/bhigrb.mbm"		;hi res grb

