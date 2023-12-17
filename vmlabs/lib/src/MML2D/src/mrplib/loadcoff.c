
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/*
 * Coff file loader for Merlin.
 * Copyright (c) 1998 VM Labs, Inc.
 * All rights reserved.
 * Confidential and Proprietary Information
 * of VM Labs, Inc.
 *
 * Load a COFF file into another MPE, and possibly
 * start it.
 *
 * rwb 12/3/98 modify to use asm_load_coff with pointer to dtram buffer 
 * rwb 3/25/99 modify to move parameters to local memory before using,
 so we don't run into cache coherency problems.  Uses same model as
 all the graphics mrp's.
 */


#include "../mrplib/parblock.h"
#include "../mrplib/mrpproto.h"
#include "../mrplib/pixmacro.h"
/*
 * the real work is done by the asm_load_coff function, located in
 * loadr.s
 */
extern void asm_load_coff(int mpe, void *coffptr, int flags, void* bufAdr, long* ackPacket);
extern uint32 authenticate(int noparam, uint8* base, uint32 length, uint8* signature, uint8* publicKey);
 
#define PUBLIC_KEY_ADDRESS  	0xf00059B0
#define SIGNATURE_OFFSET	0x1000


int
LoadCOFF(int environs, COFFparamblock *parBlockP, unsigned long* ackPtr, int arg3 )  
{
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	COFFparamblock* parP;
 	uint8* tileBase;
 	int* endP;
 	uint32 passAuthentication = -2;
 	uint32 sigOffset;

 	/* Set up local dtram & read in parameter block */
 	int parSizeLongs = (sizeof(COFFparamblock)+3)>>2;
 	
 	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, &endP ) )
  		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
  	else
  		parP = parBlockP;

	// the length of pong:  chuck is passing us the wrong param here
	//parBlockP->length = 623305;
	
	// The signature is vector aligned.	
         sigOffset = _GetLocal(parBlockP->length) - SIGNATURE_OFFSET;
         	if(sigOffset%16 != 0)
        		sigOffset = sigOffset + (16 - (sigOffset%16));
        	
#ifdef AUTHENTICATE
	passAuthentication =  authenticate(1, (uint8*)_GetLocal(parBlockP->coffAddr), 
                                                                       _GetLocal(parBlockP->length) - SIGNATURE_OFFSET, 
							      (uint8*)_GetLocal(parBlockP->coffAddr) + sigOffset, 
    					                        (uint8*)PUBLIC_KEY_ADDRESS);
    					                        
	if(_GetLocal(parP->mmpAddr) == 0)		 /* default the execution address */
		_SetLocalVar(parP->mmpAddr, (void*)0x20100C00);
#else
	passAuthentication = 0;
#endif
      	if(passAuthentication == 0)
	{
 		asm("st_s	#(1<<31),inten1clr");   // disable video interupts
		asm_load_coff(_GetLocal(parP->whichMPE), (void*)(_GetLocal(parP->coffAddr)), 
					3 , ((void*)_GetLocal(parP->mmpAddr)), ackPtr);
        }
        else
             return eError;
      
        return eFinished; 
}

#ifdef TEST
/*
 * test program for 
 * LoadCOFF
 * loads the COFF file located
 * at label _test_coff in testcoff.s
 * into MPE 0, and runs it
 *
 * compile this program with the supplied Makefile;
 * it should run on MPE 3
 */

extern int test_coff[];

int
main()
{
    COFFparamblock pb;

    pb.whichmpe = 0;
    pb.coffaddr = test_coff;
    pb.flags = START_NEW_MPE;
    LoadCOFF((void *)0, &pb, 0, 0);

    /* fall into an infinite loop */
    for(;;)
	;
}
#endif
