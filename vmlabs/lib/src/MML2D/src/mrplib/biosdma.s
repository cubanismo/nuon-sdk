/*
   Copyright (c) 1995-2000, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
*/

.segment tags
        .asciiz __FILE__ " $Revision: 1.9 $ $Date: 2000/06/28 20:45:35 $"

/* Two BIOS DMA functions that abstract the DMA registers differently
than  _DMALinear and _DMABiLinear.  These functions are used heavily
by the mml2d library.
*/

		.text

//****************************************************************
// EXTERN_C void _Dma_wait( int ctrl );
//
// Wait until r0 Bus DMA is finished and DCache is also quiet.
// ctrl = #odmactl ($20500500) or #mdmactl ($20500600)
// Clobbers r10, r11
// Called by _bio_dma_do
//----------------------------------------------------------------
		.export __Dma_wait
		
__Dma_wait:
`10:	ld_s	dcachectl,r10			// To make sure the dcache is quiet
		ld_s	(r0), r11		// To make sure the mdma is ready
		bits	#3,>>#28,r10		// Check dcachectl state machine
{		bra	ne,`10, nop		// Loop until cache ctl indicates ready
		bits	#4,>>#0,r11
}
		bra	ne,`10, nop		// Loop until mdmactl indicates ready
		rts	nop

//****************************************************************
// EXTERN_C void _Dma_do( int ctrl, void* cmdBlockPtr, int waitQ );
//
// Use r0 bus DMA to do a DMA;
// Executes dma command block pointed at by r1
// Return while DMA is executing, unless r2 is nonzero.
// Calls _Dma_wait
// Clobbers r8, r9, r10, r11
//----------------------------------------------------------------
		.export	__Dma_do

__Dma_do:
{		ld_s	rz, r9			// save rz for return
		add	#16, r0, r8		// r8 = address of x_dmacptr
}
		jsr	__Dma_wait, nop
{		st_s	r1, (r8)
		cmp	#0, r2
}
		jsr	ne, __Dma_wait, nop
		st_s	r9, rz
		rts	
                nop
                nop
