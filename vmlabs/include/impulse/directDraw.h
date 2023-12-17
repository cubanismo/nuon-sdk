/*
   Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
*/

#ifndef __DIRDRAW_
#define __DIRDRAW_

#ifdef __cplusplus
extern "C" {
#endif

char* NUON_ReadVideoRowBytes( void* tileP, int dmaFlags, void* vidmemP, long buf[], int numBytes, int x, int y );
void NUON_WriteVideoRowBytes( void* tileP, int dmaFlags, void* vidmemP, unsigned char buf[], int numBytes, int x, int y );
void NUON_WriteDirectRowBytes( void* tileP, int dmaFlags, void* vidmemP, int count, int numBytes, int x, int y );

#ifdef __cplusplus
}
#endif

#endif /* __DIRDRAW_ */
