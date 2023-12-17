/*
 * Misc. interrupt related functions
 */

/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


#ifndef INTR_H
#define INTR_H

#define DISABLE_INTERRUPTS(x) \
   asm volatile ("\tld_io intctl,%0\n" \
                 "\tst_s #$88,intctl\n`1:" : "=r" (x) )

#define RESTORE_INTERRUPTS(x) \
   asm volatile ("\tnop\n" \
                 "\tand #$88,%0,r0\n" \
                 "\teor #$88,r0\n" \
                 "\tlsr #1,r0\n" \
                 "`.2:\tst_s r0,intctl\n" : : "r" (x) : "r0")


#endif
