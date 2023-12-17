; nuon.i - definitions for the NUON MMP

/*Copyright (C) 1995-2001 VM Labs, Inc.

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

.module

; internal memory
internal_memory_base =  $20000000	; address of first mpe
internal_memory_size =  $00800000	; address space per mpe

; local memory map
local_rom_base =        $20000000
local_ram_base =        $20100000

; instruction memory map
instruction_rom_base =  $20200000
instruction_ram_base =  $20300000

; i/o register memory map
local_reg_base =        $20500000
rpu_reg_base =          $31000000

; external memory map
external_ram_base =     $40000000

; system bus memory map
system_bus_ram_base =   $80000000
