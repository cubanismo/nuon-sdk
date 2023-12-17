
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

	.export		dma__cmd
	.segment intdata
	.align.v
dma__cmd:		.dc.s   0,0,0,0,0,0,0,0   //TODOJ - change this to refer to paramBlock			