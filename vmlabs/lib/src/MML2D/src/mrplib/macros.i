
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Useful macros
   rwb 5/7/98
*/

/* store min( x, y) in result
   make most likely variable x 
*/
.macro	min x,y,result
	cmp 	x,y
(	bra	lt, `over, nop
	mv_s	y, result
}
	mv_s	x, result
`over:	
.mend

/* store max( x, y) in result
   make most likely variable x 
*/
.macro	max x,y,result
	cmp 	x,y
(	bra	gt, `over, nop
	mv_s	y, result
}
	mv_s	x, result
`over:	
.mend

/* wait for dma to complete
*/
.macro	dmaWait ctl, reg
`loop:	ld_s	(ctl), reg
	nop
	bits	#4, >>#0, reg
	bra	ne, `loop, nop
.mend


