
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/*-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------*/
#if !defined(BIOSDMA_H)
#define BIOSDMA_H

/*-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------*/
extern void icode_Dma_wait( int ctrl );
extern void icode_Dma_do( int ctrl, void* cmdBlockPtr, int waitQ );
extern void _Dma_wait( int ctrl );
extern void _Dma_do( int ctrl, void* cmdBlockPtr, int waitQ );


#endif /* BIOSDMA_H */
