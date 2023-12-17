/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

; merlin.i - definitions for the Merlin MMP 

.module

; size of an instruction 
bytesPerInstruction =   2

; internal memory
internal_memory_base =  $20000000     ; address of first mpe
internal_memory_size =  $00800000     ; address space per mpe

; NOT NECESSARY - should default
; local memory map 
; local_reg_base =        $20000000
; local_rom_base =        $20100000
; local_ram_base =        $20200000
; rpu_reg_base =          $31000000

; instruction memory map 
; instruction_rom_base =  $20300000
; instruction_rom_size =  (8196 * bytesPerInstruction)
; instruction_ram_base =  $20400000
; instruction_ram_size =  (2048 * bytesPerInstruction)

; external memory map 
external_ram_base =     $40000000
external_ram_size =     (2 * 1024 * 1024)

/* dma register addresses */
DREG_DMA0 =      $60000000
DREG_MEM0 =      $61000000
DREG_X_LIM =     $62000000
DREG_Y_LIM =     $63000000
DREG_XY_DEBUG =  $64000000
DREG_A_MIN_LIM = $65000000
DREG_A_MAX_LIM = $66000000
DREG_A_DEBUG =   $67000000
DREG_REFRESH =   $68000000
DREG_DIRECT =    $69000000
DREG_INIT =      $6a000000
DREG_NOP =       $50000000

/* DREG_MEM0_TCAS bit 0         
Tcas 0=pipelined, 1=prefetch //??? only pipelined implemented in alpha */

DREG_MEM0_TCAS_PIPELINED = $00000000
DREG_MEM0_TCAS_PREFETCH  = $00000001

/* DREG_MEM0_TRCD bits 2-1
ras to cas delay (min)               -2 (2..5) */

DREG_MEM0_TRCD_2 = $00000000
DREG_MEM0_TRCD_3 = $00000002
DREG_MEM0_TRCD_4 = $00000004
DREG_MEM0_TRCD_5 = $00000006

/* DREG_MEM0_TRAS bits 6-3
ras to pre delay (min)               -1 (1..16) */

DREG_MEM0_TRAS_1  = $00000000
DREG_MEM0_TRAS_2  = $00000008
DREG_MEM0_TRAS_3  = $00000010
DREG_MEM0_TRAS_4  = $00000018
DREG_MEM0_TRAS_5  = $00000020
DREG_MEM0_TRAS_6  = $00000028
DREG_MEM0_TRAS_7  = $00000030
DREG_MEM0_TRAS_8  = $00000038
DREG_MEM0_TRAS_9  = $00000040
DREG_MEM0_TRAS_10 = $00000048
DREG_MEM0_TRAS_11 = $00000050
DREG_MEM0_TRAS_12 = $00000058
DREG_MEM0_TRAS_13 = $00000060
DREG_MEM0_TRAS_14 = $00000068
DREG_MEM0_TRAS_15 = $00000070
DREG_MEM0_TRAS_16 = $00000078

/* DREG_MEM0_TRP bits 9-7
ras precharge delay (min)            -1 (1..8) */

DREG_MEM0_TRP_1 = $00000000
DREG_MEM0_TRP_2 = $00000080
DREG_MEM0_TRP_3 = $00000100
DREG_MEM0_TRP_4 = $00000180
DREG_MEM0_TRP_5 = $00000200
DREG_MEM0_TRP_6 = $00000280
DREG_MEM0_TRP_7 = $00000300
DREG_MEM0_TRP_8 = $00000380

/* DREG_MEM0_TRRD bits 12-10
ras to ras delay (min)               -1 (1..8) */

DREG_MEM0_TRRD_1 = $00000000
DREG_MEM0_TRRD_2 = $00000400
DREG_MEM0_TRRD_3 = $00000800
DREG_MEM0_TRRD_4 = $00000C00
DREG_MEM0_TRRD_5 = $00001000
DREG_MEM0_TRRD_6 = $00001400
DREG_MEM0_TRRD_7 = $00001800
DREG_MEM0_TRRD_8 = $00001C00  

/* DREG_MEM0_TDPL bits 14-13
write to precharge delay (min)       -1 (1..4) */

DREG_MEM0_TDPL_1 = $00000000
DREG_MEM0_TDPL_2 = $00002000
DREG_MEM0_TDPL_3 = $00004000
DREG_MEM0_TDPL_4 = $00006000

/* DREG_MEM0_SIZE16 bit 15
1=16Mbits, 0=64Mbits */

DREG_MEM0_SIZE16 = $00008000
DREG_MEM0_SIZE64 = $00000000

/* DREG_MEM0_DEPTH2 bit 16
1= 2 (x16) chips */

DREG_MEM0_DEPTH1 = $00000000
DREG_MEM0_DEPTH2 = $00010000

/* DREG_MEM0_WIDTH8 bit 17	  
1= x8, 0=x16                                        */

DREG_MEM0_WIDTH16 = $00000000
DREG_MEM0_WIDTH8  = $00020000

/* DREG_MEM0_ENABLE bit 18	  
1=enable sdram, 0=disable (required during power up)*/

DREG_MEM0_DISABLE = $00000000
DREG_MEM0_ENABLE  = $00040000

/* DREG_MEM0_WBUG   bit 19  	  
1 =Tdpl based on end burst, 0 =Tdpl based on last write*/

DREG_MEM0_WBUG_END = $00080000
DREG_MEM0_WBUG_LW  = $00000000


/* dma sdram control command */
DSDCMD_LONG_CAS = $00000
DSDCMD_WORD_CAS = $10000
DSDCMD_NULL_CAS = $18000
DSDCMD_RAS 		= $20000
DSDCMD_MRS 		= $28000
DSDCMD_CBR 		= $30000
DSDCMD_PRE 		= $38000

