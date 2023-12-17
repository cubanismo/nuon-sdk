/* Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


	.dc.s	8057	; maxentries
	.dc.s	8057	; number of entries
	.dc.s	0	; state
	.dc.s	0	; current polygon
	.dc.s	0, 0, 0	; nx, ny, nz
	.dc.s	0, 0	; tu, tv
	.dc.s	0	; current material
	.dc.s	tridata	; pointer to entries

	.align.v
tridata:
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad3333, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad3333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad46cf, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad46cf, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8d6e3, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8d6e3, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff880000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8cccd, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad46cf, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad46cf, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8cccd, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad46cf, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad46cf, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8cccd, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8cccd, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff880000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffa8cccd, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad3333, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffad3333, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad3333, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8d6e3, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad46cf, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8d6e3, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff880000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8d6e3, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8d6e3, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff880000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8d6e3, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff880000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff880000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad46cf, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad46cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad46cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8d6e3, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad46cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad3333, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad46cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad46cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad3333, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad3333, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $5f999a, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffce0000, $ffe10000, $5f999a, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $5f999a, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe10000, $5f999a, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $5f999a, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe10000, $5f999a, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe10000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff870000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff870000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff870000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff870000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffa8cccd, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad3333, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad3333, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad3333, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffad3333, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $ffff0000, $300000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $ffff0000, $600000, $0
	.dc.s	$3ffe8785, $7eab3a, $5a9f3, $0
	.dc.s	$ff8702f8, $fffe8000, $49a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $ffff0000, $300000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff8702f8, $fffe8000, $49a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	$ff870000, $fffe8000, $45428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $300000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $ffff0000, $300000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $fffe8000, $45428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $300000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffe8000, $45428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	$ff870000, $fffc0000, $45428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $600000, $0
	.dc.s	$3fc9c21a, $fd0055e0, $fff47a4a, $0
	.dc.s	$ff870000, $fffb8000, $300000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffc0000, $45428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $600000, $0
	.dc.s	$3fc9c21a, $fd0055e0, $fff47a4a, $0
	.dc.s	$ff870000, $fffc0000, $45428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	$ff8702f8, $fffc0000, $49a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff8702f8, $fffc0000, $49a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	$ff8702f8, $fffe8000, $49a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	$ff870000, $ffff0000, $600000, $0
	.dc.s	$3ffe8785, $7eab3a, $5a9f3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff8702f8, $fffc0000, $49a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	$ff870000, $ffff0000, $600000, $0
	.dc.s	$3ffe8785, $7eab3a, $5a9f3, $0
	.dc.s	$ff870000, $fffb8000, $600000, $0
	.dc.s	$3fc9c21a, $fd0055e0, $fff47a4a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe28000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe28000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe18000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fff80000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fff80000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $49bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $45495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe68000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $49bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $45495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x99230d,0,1
	.dc.s	$ff840000, $ffe1e8c1, $ff9c0000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$7c0000, $ffe1e8c1, $ff9c0000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$7c0000, $ffe1e8c1, $63d1d1, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x99230d,0,1
	.dc.s	$7c0000, $ffe1e8c1, $63d1d1, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ff840000, $ffe1e8c1, $63d1d1, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ff840000, $ffe1e8c1, $ff9c0000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe69055, $fffb001f, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffe69055, $fff027e9, $600000, $0
	.dc.s	$c10cd749, $f6978c17, $0, $0
	.dc.s	$ffe69055, $fff027e9, $640000, $0
	.dc.s	$c0866ba4, $fb4bc60c, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe69055, $fffb001f, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffe69055, $fff027e9, $640000, $0
	.dc.s	$c0866ba4, $fb4bc60c, $0, $0
	.dc.s	$ffe69055, $fffb001f, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe69055, $fff027e9, $600000, $0
	.dc.s	$c10cd749, $f6978c17, $0, $0
	.dc.s	$ffe70558, $ffee224e, $600000, $0
	.dc.s	$c8c4f203, $e21607ba, $0, $0
	.dc.s	$ffe70558, $ffee224e, $640000, $0
	.dc.s	$c52c1a78, $e9fcacee, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe69055, $fff027e9, $600000, $0
	.dc.s	$c10cd749, $f6978c17, $0, $0
	.dc.s	$ffe70558, $ffee224e, $640000, $0
	.dc.s	$c52c1a78, $e9fcacee, $0, $0
	.dc.s	$ffe69055, $fff027e9, $640000, $0
	.dc.s	$c0866ba4, $fb4bc60c, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe70558, $ffee224e, $600000, $0
	.dc.s	$c8c4f203, $e21607ba, $0, $0
	.dc.s	$ffe85004, $ffec5ecc, $600000, $0
	.dc.s	$d843f63b, $cf285e62, $0, $0
	.dc.s	$ffe85004, $ffec5ecc, $640000, $0
	.dc.s	$d250dfe5, $d4abe074, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe70558, $ffee224e, $600000, $0
	.dc.s	$c8c4f203, $e21607ba, $0, $0
	.dc.s	$ffe85004, $ffec5ecc, $640000, $0
	.dc.s	$d250dfe5, $d4abe074, $0, $0
	.dc.s	$ffe70558, $ffee224e, $640000, $0
	.dc.s	$c52c1a78, $e9fcacee, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe85004, $ffec5ecc, $600000, $0
	.dc.s	$d843f63b, $cf285e62, $0, $0
	.dc.s	$ffea51d4, $ffeb1f70, $600000, $0
	.dc.s	$ed1b934a, $c3e70d77, $0, $0
	.dc.s	$ffea51d4, $ffeb1f70, $640000, $0
	.dc.s	$e5a94fee, $c6c5f4e4, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe85004, $ffec5ecc, $600000, $0
	.dc.s	$d843f63b, $cf285e62, $0, $0
	.dc.s	$ffea51d4, $ffeb1f70, $640000, $0
	.dc.s	$e5a94fee, $c6c5f4e4, $0, $0
	.dc.s	$ffe85004, $ffec5ecc, $640000, $0
	.dc.s	$d250dfe5, $d4abe074, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffea51d4, $ffeb1f70, $600000, $0
	.dc.s	$ed1b934a, $c3e70d77, $0, $0
	.dc.s	$ffecec42, $ffeaa64c, $600000, $0
	.dc.s	$1c6a001, $c0b63d70, $0, $0
	.dc.s	$ffecec42, $ffeaa64c, $640000, $0
	.dc.s	$fb2a3b54, $c0df31bd, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffea51d4, $ffeb1f70, $600000, $0
	.dc.s	$ed1b934a, $c3e70d77, $0, $0
	.dc.s	$ffecec42, $ffeaa64c, $640000, $0
	.dc.s	$fb2a3b54, $c0df31bd, $0, $0
	.dc.s	$ffea51d4, $ffeb1f70, $640000, $0
	.dc.s	$e5a94fee, $c6c5f4e4, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffecec42, $ffeaa64c, $600000, $0
	.dc.s	$1c6a001, $c0b63d70, $0, $0
	.dc.s	$ffef86ad, $ffeafe63, $600000, $0
	.dc.s	$164fd997, $c4e8bc91, $0, $0
	.dc.s	$ffef86ad, $ffeafe63, $640000, $0
	.dc.s	$f596f22, $c2bb02da, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffecec42, $ffeaa64c, $600000, $0
	.dc.s	$1c6a001, $c0b63d70, $0, $0
	.dc.s	$ffef86ad, $ffeafe63, $640000, $0
	.dc.s	$f596f22, $c2bb02da, $0, $0
	.dc.s	$ffecec42, $ffeaa64c, $640000, $0
	.dc.s	$fb2a3b54, $c0df31bd, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffef86ad, $ffeafe63, $600000, $0
	.dc.s	$164fd997, $c4e8bc91, $0, $0
	.dc.s	$fff1887d, $ffec06ae, $600000, $0
	.dc.s	$2be196f1, $d36a610a, $0, $0
	.dc.s	$fff1887d, $ffec06ae, $640000, $0
	.dc.s	$2493ed7e, $cd406ba9, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffef86ad, $ffeafe63, $600000, $0
	.dc.s	$164fd997, $c4e8bc91, $0, $0
	.dc.s	$fff1887d, $ffec06ae, $640000, $0
	.dc.s	$2493ed7e, $cd406ba9, $0, $0
	.dc.s	$ffef86ad, $ffeafe63, $640000, $0
	.dc.s	$f596f22, $c2bb02da, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff1887d, $ffec06ae, $600000, $0
	.dc.s	$2be196f1, $d36a610a, $0, $0
	.dc.s	$fff2d329, $ffedbf35, $600000, $0
	.dc.s	$3afaf5a9, $eb3d5292, $0, $0
	.dc.s	$fff2d329, $ffedbf35, $640000, $0
	.dc.s	$37151b07, $e268d47e, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff1887d, $ffec06ae, $600000, $0
	.dc.s	$2be196f1, $d36a610a, $0, $0
	.dc.s	$fff2d329, $ffedbf35, $640000, $0
	.dc.s	$37151b07, $e268d47e, $0, $0
	.dc.s	$fff1887d, $ffec06ae, $640000, $0
	.dc.s	$2493ed7e, $cd406ba9, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff2d329, $ffedbf35, $600000, $0
	.dc.s	$3afaf5a9, $eb3d5292, $0, $0
	.dc.s	$fff3482c, $fff027e9, $600000, $0
	.dc.s	$3fa0456f, $fc05f037, $0, $0
	.dc.s	$fff3482c, $fff027e9, $640000, $0
	.dc.s	$3f408ade, $f80be06f, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff2d329, $ffedbf35, $600000, $0
	.dc.s	$3afaf5a9, $eb3d5292, $0, $0
	.dc.s	$fff3482c, $fff027e9, $640000, $0
	.dc.s	$3f408ade, $f80be06f, $0, $0
	.dc.s	$fff2d329, $ffedbf35, $640000, $0
	.dc.s	$37151b07, $e268d47e, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff3482c, $fff027e9, $600000, $0
	.dc.s	$3fa0456f, $fc05f037, $0, $0
	.dc.s	$fff3482c, $fffb001f, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$fff3482c, $fffb001f, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff3482c, $fff027e9, $600000, $0
	.dc.s	$3fa0456f, $fc05f037, $0, $0
	.dc.s	$fff3482c, $fffb001f, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$fff3482c, $fff027e9, $640000, $0
	.dc.s	$3f408ade, $f80be06f, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff3482c, $fffb001f, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$fff9a416, $fffb001f, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$fff9a416, $fffb001f, $640000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff3482c, $fffb001f, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$fff9a416, $fffb001f, $640000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$fff3482c, $fffb001f, $640000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff9a416, $fffb001f, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$fff9a416, $fff027e9, $600000, $0
	.dc.s	$c0bf6cc8, $f80c0c76, $0, $0
	.dc.s	$fff9a416, $fff027e9, $640000, $0
	.dc.s	$c05fb664, $fc06063b, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff9a416, $fffb001f, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$fff9a416, $fff027e9, $640000, $0
	.dc.s	$c05fb664, $fc06063b, $0, $0
	.dc.s	$fff9a416, $fffb001f, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff9a416, $fff027e9, $600000, $0
	.dc.s	$c0bf6cc8, $f80c0c76, $0, $0
	.dc.s	$fffa1917, $ffedbf35, $600000, $0
	.dc.s	$c8eae0cc, $e268ea82, $0, $0
	.dc.s	$fffa1917, $ffedbf35, $640000, $0
	.dc.s	$c50501fc, $eb3d7e9a, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff9a416, $fff027e9, $600000, $0
	.dc.s	$c0bf6cc8, $f80c0c76, $0, $0
	.dc.s	$fffa1917, $ffedbf35, $640000, $0
	.dc.s	$c50501fc, $eb3d7e9a, $0, $0
	.dc.s	$fff9a416, $fff027e9, $640000, $0
	.dc.s	$c05fb664, $fc06063b, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffa1917, $ffedbf35, $600000, $0
	.dc.s	$c8eae0cc, $e268ea82, $0, $0
	.dc.s	$fffb63c2, $ffec06ae, $600000, $0
	.dc.s	$db6c1486, $cd406aa0, $0, $0
	.dc.s	$fffb63c2, $ffec06ae, $640000, $0
	.dc.s	$d41e6a11, $d36a6085, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffa1917, $ffedbf35, $600000, $0
	.dc.s	$c8eae0cc, $e268ea82, $0, $0
	.dc.s	$fffb63c2, $ffec06ae, $640000, $0
	.dc.s	$d41e6a11, $d36a6085, $0, $0
	.dc.s	$fffa1917, $ffedbf35, $640000, $0
	.dc.s	$c50501fc, $eb3d7e9a, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffb63c2, $ffec06ae, $600000, $0
	.dc.s	$db6c1486, $cd406aa0, $0, $0
	.dc.s	$fffd6592, $ffeafe63, $600000, $0
	.dc.s	$f0a696da, $c2bb01ac, $0, $0
	.dc.s	$fffd6592, $ffeafe63, $640000, $0
	.dc.s	$e9b02aeb, $c4e8bb33, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffb63c2, $ffec06ae, $600000, $0
	.dc.s	$db6c1486, $cd406aa0, $0, $0
	.dc.s	$fffd6592, $ffeafe63, $640000, $0
	.dc.s	$e9b02aeb, $c4e8bb33, $0, $0
	.dc.s	$fffb63c2, $ffec06ae, $640000, $0
	.dc.s	$d41e6a11, $d36a6085, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffd6592, $ffeafe63, $600000, $0
	.dc.s	$f0a696da, $c2bb01ac, $0, $0
	.dc.s	$0, $ffeaa64c, $600000, $0
	.dc.s	$2cba9bd, $c08d4826, $0, $0
	.dc.s	$0, $ffeaa64c, $640000, $0
	.dc.s	$fd345643, $c08d4826, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffd6592, $ffeafe63, $600000, $0
	.dc.s	$f0a696da, $c2bb01ac, $0, $0
	.dc.s	$0, $ffeaa64c, $640000, $0
	.dc.s	$fd345643, $c08d4826, $0, $0
	.dc.s	$fffd6592, $ffeafe63, $640000, $0
	.dc.s	$e9b02aeb, $c4e8bb33, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffeaa64c, $600000, $0
	.dc.s	$2cba9bd, $c08d4826, $0, $0
	.dc.s	$29a6e, $ffeafe63, $600000, $0
	.dc.s	$164fd515, $c4e8bb33, $0, $0
	.dc.s	$29a6e, $ffeafe63, $640000, $0
	.dc.s	$f596926, $c2bb01ac, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffeaa64c, $600000, $0
	.dc.s	$2cba9bd, $c08d4826, $0, $0
	.dc.s	$29a6e, $ffeafe63, $640000, $0
	.dc.s	$f596926, $c2bb01ac, $0, $0
	.dc.s	$0, $ffeaa64c, $640000, $0
	.dc.s	$fd345643, $c08d4826, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$29a6e, $ffeafe63, $600000, $0
	.dc.s	$164fd515, $c4e8bb33, $0, $0
	.dc.s	$49c3e, $ffec06ae, $600000, $0
	.dc.s	$2be195ef, $d36a6085, $0, $0
	.dc.s	$49c3e, $ffec06ae, $640000, $0
	.dc.s	$2493eb7a, $cd406aa0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$29a6e, $ffeafe63, $600000, $0
	.dc.s	$164fd515, $c4e8bb33, $0, $0
	.dc.s	$49c3e, $ffec06ae, $640000, $0
	.dc.s	$2493eb7a, $cd406aa0, $0, $0
	.dc.s	$29a6e, $ffeafe63, $640000, $0
	.dc.s	$f596926, $c2bb01ac, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$49c3e, $ffec06ae, $600000, $0
	.dc.s	$2be195ef, $d36a6085, $0, $0
	.dc.s	$5e6e9, $ffedbf35, $600000, $0
	.dc.s	$3afafe04, $eb3d7e9a, $0, $0
	.dc.s	$5e6e9, $ffedbf35, $640000, $0
	.dc.s	$37151f34, $e268ea82, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$49c3e, $ffec06ae, $600000, $0
	.dc.s	$2be195ef, $d36a6085, $0, $0
	.dc.s	$5e6e9, $ffedbf35, $640000, $0
	.dc.s	$37151f34, $e268ea82, $0, $0
	.dc.s	$49c3e, $ffec06ae, $640000, $0
	.dc.s	$2493eb7a, $cd406aa0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$5e6e9, $ffedbf35, $600000, $0
	.dc.s	$3afafe04, $eb3d7e9a, $0, $0
	.dc.s	$65bea, $fff027e9, $600000, $0
	.dc.s	$3fa0499c, $fc06063b, $0, $0
	.dc.s	$65bea, $fff027e9, $640000, $0
	.dc.s	$3f409338, $f80c0c76, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$5e6e9, $ffedbf35, $600000, $0
	.dc.s	$3afafe04, $eb3d7e9a, $0, $0
	.dc.s	$65bea, $fff027e9, $640000, $0
	.dc.s	$3f409338, $f80c0c76, $0, $0
	.dc.s	$5e6e9, $ffedbf35, $640000, $0
	.dc.s	$37151f34, $e268ea82, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$65bea, $fff027e9, $600000, $0
	.dc.s	$3fa0499c, $fc06063b, $0, $0
	.dc.s	$65bea, $fffb001f, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$65bea, $fffb001f, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$65bea, $fff027e9, $600000, $0
	.dc.s	$3fa0499c, $fc06063b, $0, $0
	.dc.s	$65bea, $fffb001f, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$65bea, $fff027e9, $640000, $0
	.dc.s	$3f409338, $f80c0c76, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$65bea, $fffb001f, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$cb7d4, $fffb001f, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$cb7d4, $fffb001f, $640000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$65bea, $fffb001f, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$cb7d4, $fffb001f, $640000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$65bea, $fffb001f, $640000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$cb7d4, $fffb001f, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$cb7d4, $fff027e9, $600000, $0
	.dc.s	$c0bf7522, $f80be06f, $0, $0
	.dc.s	$cb7d4, $fff027e9, $640000, $0
	.dc.s	$c05fba91, $fc05f037, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$cb7d4, $fffb001f, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$cb7d4, $fff027e9, $640000, $0
	.dc.s	$c05fba91, $fc05f037, $0, $0
	.dc.s	$cb7d4, $fffb001f, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$cb7d4, $fff027e9, $600000, $0
	.dc.s	$c0bf7522, $f80be06f, $0, $0
	.dc.s	$d2cd7, $ffedbf35, $600000, $0
	.dc.s	$c8eae4f9, $e268d47e, $0, $0
	.dc.s	$d2cd7, $ffedbf35, $640000, $0
	.dc.s	$c5050a57, $eb3d5292, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$cb7d4, $fff027e9, $600000, $0
	.dc.s	$c0bf7522, $f80be06f, $0, $0
	.dc.s	$d2cd7, $ffedbf35, $640000, $0
	.dc.s	$c5050a57, $eb3d5292, $0, $0
	.dc.s	$cb7d4, $fff027e9, $640000, $0
	.dc.s	$c05fba91, $fc05f037, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$d2cd7, $ffedbf35, $600000, $0
	.dc.s	$c8eae4f9, $e268d47e, $0, $0
	.dc.s	$e7783, $ffec06ae, $600000, $0
	.dc.s	$db6c1282, $cd406ba9, $0, $0
	.dc.s	$e7783, $ffec06ae, $640000, $0
	.dc.s	$d41e690f, $d36a610a, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$d2cd7, $ffedbf35, $600000, $0
	.dc.s	$c8eae4f9, $e268d47e, $0, $0
	.dc.s	$e7783, $ffec06ae, $640000, $0
	.dc.s	$d41e690f, $d36a610a, $0, $0
	.dc.s	$d2cd7, $ffedbf35, $640000, $0
	.dc.s	$c5050a57, $eb3d5292, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$e7783, $ffec06ae, $600000, $0
	.dc.s	$db6c1282, $cd406ba9, $0, $0
	.dc.s	$107953, $ffeafe63, $600000, $0
	.dc.s	$f0a690de, $c2bb02da, $0, $0
	.dc.s	$107953, $ffeafe63, $640000, $0
	.dc.s	$e9b02669, $c4e8bc91, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$e7783, $ffec06ae, $600000, $0
	.dc.s	$db6c1282, $cd406ba9, $0, $0
	.dc.s	$107953, $ffeafe63, $640000, $0
	.dc.s	$e9b02669, $c4e8bc91, $0, $0
	.dc.s	$e7783, $ffec06ae, $640000, $0
	.dc.s	$d41e690f, $d36a610a, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$107953, $ffeafe63, $600000, $0
	.dc.s	$f0a690de, $c2bb02da, $0, $0
	.dc.s	$1313be, $ffeaa64c, $600000, $0
	.dc.s	$2cba6b1, $c08d4867, $0, $0
	.dc.s	$1313be, $ffeaa64c, $640000, $0
	.dc.s	$fd345102, $c08d48c5, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$107953, $ffeafe63, $600000, $0
	.dc.s	$f0a690de, $c2bb02da, $0, $0
	.dc.s	$1313be, $ffeaa64c, $640000, $0
	.dc.s	$fd345102, $c08d48c5, $0, $0
	.dc.s	$107953, $ffeafe63, $640000, $0
	.dc.s	$e9b02669, $c4e8bc91, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1313be, $ffeaa64c, $600000, $0
	.dc.s	$2cba6b1, $c08d4867, $0, $0
	.dc.s	$15ae2c, $ffeafe63, $600000, $0
	.dc.s	$164fd6d2, $c4e8bc34, $0, $0
	.dc.s	$15ae2c, $ffeafe63, $640000, $0
	.dc.s	$f59699a, $c2bb021e, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1313be, $ffeaa64c, $600000, $0
	.dc.s	$2cba6b1, $c08d4867, $0, $0
	.dc.s	$15ae2c, $ffeafe63, $640000, $0
	.dc.s	$f59699a, $c2bb021e, $0, $0
	.dc.s	$1313be, $ffeaa64c, $640000, $0
	.dc.s	$fd345102, $c08d48c5, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$15ae2c, $ffeafe63, $600000, $0
	.dc.s	$164fd6d2, $c4e8bc34, $0, $0
	.dc.s	$17affc, $ffec06ae, $600000, $0
	.dc.s	$2be196f1, $d36a610a, $0, $0
	.dc.s	$17affc, $ffec06ae, $640000, $0
	.dc.s	$2493ed7e, $cd406ba9, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$15ae2c, $ffeafe63, $600000, $0
	.dc.s	$164fd6d2, $c4e8bc34, $0, $0
	.dc.s	$17affc, $ffec06ae, $640000, $0
	.dc.s	$2493ed7e, $cd406ba9, $0, $0
	.dc.s	$15ae2c, $ffeafe63, $640000, $0
	.dc.s	$f59699a, $c2bb021e, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$17affc, $ffec06ae, $600000, $0
	.dc.s	$2be196f1, $d36a610a, $0, $0
	.dc.s	$18faa8, $ffedbf35, $600000, $0
	.dc.s	$3afaf5a9, $eb3d5292, $0, $0
	.dc.s	$18faa8, $ffedbf35, $640000, $0
	.dc.s	$37151b07, $e268d47e, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$17affc, $ffec06ae, $600000, $0
	.dc.s	$2be196f1, $d36a610a, $0, $0
	.dc.s	$18faa8, $ffedbf35, $640000, $0
	.dc.s	$37151b07, $e268d47e, $0, $0
	.dc.s	$17affc, $ffec06ae, $640000, $0
	.dc.s	$2493ed7e, $cd406ba9, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$18faa8, $ffedbf35, $600000, $0
	.dc.s	$3afaf5a9, $eb3d5292, $0, $0
	.dc.s	$196fab, $fff027e9, $600000, $0
	.dc.s	$3fa0456f, $fc05f037, $0, $0
	.dc.s	$196fab, $fff027e9, $640000, $0
	.dc.s	$3f408ade, $f80be06f, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$18faa8, $ffedbf35, $600000, $0
	.dc.s	$3afaf5a9, $eb3d5292, $0, $0
	.dc.s	$196fab, $fff027e9, $640000, $0
	.dc.s	$3f408ade, $f80be06f, $0, $0
	.dc.s	$18faa8, $ffedbf35, $640000, $0
	.dc.s	$37151b07, $e268d47e, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$196fab, $fff027e9, $600000, $0
	.dc.s	$3fa0456f, $fc05f037, $0, $0
	.dc.s	$196fab, $fffb001f, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$196fab, $fffb001f, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$196fab, $fff027e9, $600000, $0
	.dc.s	$3fa0456f, $fc05f037, $0, $0
	.dc.s	$196fab, $fffb001f, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$196fab, $fff027e9, $640000, $0
	.dc.s	$3f408ade, $f80be06f, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$196fab, $fffb001f, $600000, $0
	.dc.s	$ffffae0a, $c0000000, $0, $0
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$ffffae0a, $c0000000, $0, $0
	.dc.s	$320000, $fffb0000, $640000, $0
	.dc.s	$ffffae0a, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$196fab, $fffb001f, $600000, $0
	.dc.s	$ffffae0a, $c0000000, $0, $0
	.dc.s	$320000, $fffb0000, $640000, $0
	.dc.s	$ffffae0a, $c0000000, $0, $0
	.dc.s	$196fab, $fffb001f, $640000, $0
	.dc.s	$ffffae0a, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffee0000, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$320000, $fffb0000, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffee0000, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$320000, $ffee0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$f90090c7, $3f9dc472, $29, $0
	.dc.s	$0, $ffdb8000, $600000, $0
	.dc.s	$2552510, $3f9dc472, $0, $0
	.dc.s	$0, $ffdb8000, $640000, $0
	.dc.s	$fdaadaea, $3f9dc472, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$f90090c7, $3f9dc472, $29, $0
	.dc.s	$0, $ffdb8000, $640000, $0
	.dc.s	$fdaadaea, $3f9dc472, $0, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$f90090c4, $3f9dc471, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffdb8000, $600000, $0
	.dc.s	$2552510, $3f9dc472, $0, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$6ff6f36, $3f9dc472, $0, $0
	.dc.s	$ffce0000, $ffe10000, $640000, $0
	.dc.s	$6ff6f32, $3f9dc473, $ffffffd7, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffdb8000, $600000, $0
	.dc.s	$2552510, $3f9dc472, $0, $0
	.dc.s	$ffce0000, $ffe10000, $640000, $0
	.dc.s	$6ff6f32, $3f9dc473, $ffffffd7, $0
	.dc.s	$0, $ffdb8000, $640000, $0
	.dc.s	$fdaadaea, $3f9dc472, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffee0000, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffce0000, $ffe10000, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffee0000, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffce0000, $ffee0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$51f6, $c0000000, $0, $0
	.dc.s	$ffe69055, $fffb001f, $600000, $0
	.dc.s	$51f6, $c0000000, $0, $0
	.dc.s	$ffe69055, $fffb001f, $640000, $0
	.dc.s	$51f6, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$51f6, $c0000000, $0, $0
	.dc.s	$ffe69055, $fffb001f, $640000, $0
	.dc.s	$51f6, $c0000000, $0, $0
	.dc.s	$ffce0000, $fffb0000, $640000, $0
	.dc.s	$51f6, $c0000000, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$18faa8, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$17affc, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff3482c, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff3482c, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff9a416, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff3482c, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff9a416, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff9a416, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffdb8000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffdb8000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$65bea, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$65bea, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$cb7d4, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$65bea, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$cb7d4, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$cb7d4, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff9a416, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff9a416, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff3482c, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff9a416, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff3482c, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff3482c, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff2d329, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff3482c, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff9a416, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff2d329, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff9a416, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fffa1917, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$cb7d4, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$cb7d4, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$65bea, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$cb7d4, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$65bea, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$65bea, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff1887d, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff2d329, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fffa1917, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff1887d, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fffa1917, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fffb63c2, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffa1917, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff9a416, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff3482c, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffa1917, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff3482c, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff2d329, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffef86ad, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fff1887d, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fffb63c2, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffef86ad, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fffb63c2, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fffd6592, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffb63c2, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fffa1917, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff2d329, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffb63c2, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff2d329, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff1887d, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$5e6e9, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$65bea, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$cb7d4, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$5e6e9, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$cb7d4, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$d2cd7, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffd6592, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fffb63c2, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff1887d, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffd6592, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fff1887d, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffef86ad, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$49c3e, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$5e6e9, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$d2cd7, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$49c3e, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$d2cd7, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$e7783, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$d2cd7, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$cb7d4, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$65bea, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$d2cd7, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$65bea, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$5e6e9, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$29a6e, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$49c3e, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$e7783, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$29a6e, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$e7783, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$107953, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$e7783, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$d2cd7, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$5e6e9, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$e7783, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$5e6e9, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$49c3e, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $fffb0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe69055, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe69055, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe69055, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$107953, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$e7783, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$49c3e, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$107953, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$49c3e, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$29a6e, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$196fab, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$196fab, $fffb001f, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $fffb0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$196fab, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $fffb0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffee0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffce0000, $fffb0000, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffee0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffce0000, $fffb0000, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffce0000, $ffee0000, $640000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe69055, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffe69055, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe69055, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe69055, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe70558, $ffee224e, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$196fab, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$196fab, $fffb001f, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$196fab, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffee0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffee0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$320000, $ffee0000, $640000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe70558, $ffee224e, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe85004, $ffec5ecc, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe70558, $ffee224e, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffe69055, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$18faa8, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$196fab, $fff027e9, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe85004, $ffec5ecc, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffe70558, $ffee224e, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$17affc, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$18faa8, $ffedbf35, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$196fab, $fff027e9, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$18faa8, $ffedbf35, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffef86ad, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$fffd6592, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$320000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$17affc, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$17affc, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$17affc, $ffec06ae, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$15ae2c, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$15ae2c, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$17affc, $ffec06ae, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$15ae2c, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$1313be, $ffeaa64c, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1313be, $ffeaa64c, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$15ae2c, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$1313be, $ffeaa64c, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$1313be, $ffeaa64c, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$107953, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffdb8000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$0, $ffdb8000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffeaa64c, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$29a6e, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$0, $ffeaa64c, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fffd6592, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$29a6e, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$107953, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$29a6e, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$0, $ffeaa64c, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$107953, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$1313be, $ffeaa64c, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$107953, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$107953, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$29a6e, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffd6592, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffeaa64c, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$fffd6592, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffef86ad, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe85004, $ffec5ecc, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffea51d4, $ffeb1f70, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$0, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffef86ad, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffef86ad, $ffeafe63, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffecec42, $ffeaa64c, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $ffee0000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe85004, $ffec5ecc, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe85004, $ffec5ecc, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffee0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffea51d4, $ffeb1f70, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffe85004, $ffec5ecc, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffce0000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffea51d4, $ffeb1f70, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffecec42, $ffeaa64c, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffecec42, $ffeaa64c, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffef86ad, $ffeafe63, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffecec42, $ffeaa64c, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$0, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffce0000, $ffe10000, $640000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffecec42, $ffeaa64c, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffea51d4, $ffeb1f70, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffce0000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $600000, $0
	.dc.s	$fffe4f54, $3ffffffa, $0, $0
	.dc.s	$ff893e6a, $ffe7ffe6, $600000, $0
	.dc.s	$fffe4f54, $3ffffffa, $0, $0
	.dc.s	$ff893e6a, $ffe7ffe6, $ffa00000, $0
	.dc.s	$fffe4f54, $3ffffffa, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $600000, $0
	.dc.s	$fffe4f54, $3ffffffa, $0, $0
	.dc.s	$ff893e6a, $ffe7ffe6, $ffa00000, $0
	.dc.s	$fffe4f54, $3ffffffa, $0, $0
	.dc.s	$ff874e14, $ffe7ffd9, $ffa00000, $0
	.dc.s	$fffe4f54, $3ffffffa, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff88ed91, $ffe82db9, $600000, $0
	.dc.s	$e205bbfb, $c782c659, $0, $0
	.dc.s	$ff88ed91, $ffe82db9, $ffa00000, $0
	.dc.s	$e39a94b4, $c6b316ed, $0, $0
	.dc.s	$ff893e6a, $ffe7ffe6, $ffa00000, $0
	.dc.s	$e070e343, $c85275c6, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff88ed91, $ffe82db9, $600000, $0
	.dc.s	$e205bbfb, $c782c659, $0, $0
	.dc.s	$ff893e6a, $ffe7ffe6, $ffa00000, $0
	.dc.s	$e070e343, $c85275c6, $0, $0
	.dc.s	$ff893e6a, $ffe7ffe6, $600000, $0
	.dc.s	$e070e343, $c85275c6, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff88c7bb, $ffe83f2e, $600000, $0
	.dc.s	$e52f6d6c, $c5e36781, $0, $0
	.dc.s	$ff88c7bb, $ffe83f2e, $ffa00000, $0
	.dc.s	$e52f6d6c, $c5e36781, $0, $0
	.dc.s	$ff88ed91, $ffe82db9, $ffa00000, $0
	.dc.s	$e39a94b4, $c6b316ed, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff88c7bb, $ffe83f2e, $600000, $0
	.dc.s	$e52f6d6c, $c5e36781, $0, $0
	.dc.s	$ff88ed91, $ffe82db9, $ffa00000, $0
	.dc.s	$e39a94b4, $c6b316ed, $0, $0
	.dc.s	$ff88ed91, $ffe82db9, $600000, $0
	.dc.s	$e205bbfb, $c782c659, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff88c1cb, $ffe85cee, $600000, $0
	.dc.s	$cdbfb02d, $dfe41031, $0, $0
	.dc.s	$ff88c1cb, $ffe85cee, $ffa00000, $0
	.dc.s	$cdbfb02d, $dfe41031, $0, $0
	.dc.s	$ff88c7bb, $ffe83f2e, $ffa00000, $0
	.dc.s	$c13d1a7e, $f37826c7, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff88c1cb, $ffe85cee, $600000, $0
	.dc.s	$cdbfb02d, $dfe41031, $0, $0
	.dc.s	$ff88c7bb, $ffe83f2e, $ffa00000, $0
	.dc.s	$c13d1a7e, $f37826c7, $0, $0
	.dc.s	$ff88c7bb, $ffe83f2e, $600000, $0
	.dc.s	$c13d1a7e, $f37826c7, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff88c1cb, $ffe85cee, $600000, $0
	.dc.s	$cdbfb02d, $dfe41031, $0, $0
	.dc.s	$ff889687, $ffe87c85, $600000, $0
	.dc.s	$ed1abc46, $c627fd71, $0, $0
	.dc.s	$ff889687, $ffe87c85, $ffa00000, $0
	.dc.s	$ed1abc46, $c627fd71, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff88c1cb, $ffe85cee, $600000, $0
	.dc.s	$cdbfb02d, $dfe41031, $0, $0
	.dc.s	$ff889687, $ffe87c85, $ffa00000, $0
	.dc.s	$ed1abc46, $c627fd71, $0, $0
	.dc.s	$ff88c1cb, $ffe85cee, $ffa00000, $0
	.dc.s	$cdbfb02d, $dfe41031, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874ee6, $ffe87cc6, $600000, $0
	.dc.s	$fff332b0, $c0000148, $0, $0
	.dc.s	$ff874ee6, $ffe87cc6, $ffa00000, $0
	.dc.s	$fff332b0, $c0000148, $0, $0
	.dc.s	$ff889687, $ffe87c85, $ffa00000, $0
	.dc.s	$ed1abc46, $c627fd71, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874ee6, $ffe87cc6, $600000, $0
	.dc.s	$fff332b0, $c0000148, $0, $0
	.dc.s	$ff889687, $ffe87c85, $ffa00000, $0
	.dc.s	$ed1abc46, $c627fd71, $0, $0
	.dc.s	$ff889687, $ffe87c85, $600000, $0
	.dc.s	$ed1abc46, $c627fd71, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff874ee6, $ffe87cc6, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff889687, $ffe87c85, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff889687, $ffe87c85, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff88c1cb, $ffe85cee, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff88c1cb, $ffe85cee, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff88c7bb, $ffe83f2e, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff88c7bb, $ffe83f2e, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff88ed91, $ffe82db9, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff88ed91, $ffe82db9, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff893e6a, $ffe7ffe6, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff893e6a, $ffe7ffe6, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff88ed91, $ffe82db9, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff88ed91, $ffe82db9, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff88c7bb, $ffe83f2e, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff88c7bb, $ffe83f2e, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff88c1cb, $ffe85cee, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff88c1cb, $ffe85cee, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff889687, $ffe87c85, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff889687, $ffe87c85, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff874ee6, $ffe87cc6, $ffa00000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $ffa00000, $0
	.dc.s	$3fffa5d4, $ff9490f5, $0, $0
	.dc.s	$ff874ee6, $ffe87cc6, $ffa00000, $0
	.dc.s	$3fffa5d4, $ff9490f5, $0, $0
	.dc.s	$ff874ee6, $ffe87cc6, $600000, $0
	.dc.s	$3fffa5d4, $ff9490f5, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff874e14, $ffe7ffd9, $ffa00000, $0
	.dc.s	$3fffa5d4, $ff9490f5, $0, $0
	.dc.s	$ff874ee6, $ffe87cc6, $600000, $0
	.dc.s	$3fffa5d4, $ff9490f5, $0, $0
	.dc.s	$ff874e14, $ffe7ffd9, $600000, $0
	.dc.s	$3fffa5d4, $ff9490f5, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$573333, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$573333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$780000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$5746cf, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$5746cf, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52d6e3, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52d6e3, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$320000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52cccd, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$5746cf, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$5746cf, $ffe28000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$780000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$573333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52cccd, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$573333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52d6e3, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$5746cf, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$573333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$5746cf, $ffe68000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$780000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$573333, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$780000, $ffe10000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$780000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccd, $ffee0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52cccd, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$320000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$52cccd, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$573333, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$573333, $fff80000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$780000, $fffb0000, $5f999a, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$573333, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$573333, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$780000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52d6e3, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$5746cf, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$780000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52d6e3, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$780000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52d6e3, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52d6e3, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52d6e3, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$5746cf, $ffe28000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$5746cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$5746cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52d6e3, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$5746cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$573333, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$780000, $ffe10000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$5746cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$5746cf, $ffe68000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$573333, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52cccd, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52cccd, $ffee0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$573333, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52cccd, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$52cccd, $fff80000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $5f999a, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$780000, $ffe10000, $5f999a, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$780000, $ffe10000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $5f999a, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$780000, $ffe10000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$780000, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $5f999a, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$320000, $fffb0000, $5f999a, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $ffe10000, $5f999a, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$320000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$320000, $ffe10000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$583333, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$53cccd, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$583333, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$790000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$53cccd, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$320000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$53cccd, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$53cccd, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$790000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$320000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$53cccd, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$790000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$53cccd, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$583333, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$790000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$790000, $fffb6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$583333, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$790000, $ffff0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$583333, $fffc0000, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$583333, $fffe6666, $600000, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	$52cccc, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	$52cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$31ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	$52b930, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$52b930, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	$57291d, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffc7, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$57291d, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffc7, $c0000000, $0
	.dc.s	$57291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$77ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$57291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$57291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$573333, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52b930, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	$52b930, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	$31ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$573333, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$57291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$57291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$52b930, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$52b930, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	$31ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$31ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	$31ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$573333, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$573333, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	$77ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$573333, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	$52cccc, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$52cccc, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	$31ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccc, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	$52cccc, $fff80000, $ffa00000, $0
	.dc.s	$5f, $21, $40000000, $0
	.dc.s	$31ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$57291d, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$52b930, $ffe28000, $ffa00000, $0
	.dc.s	$5e, $ffffffca, $40000000, $0
	.dc.s	$31ffff, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$57291d, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$31ffff, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$77ffff, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$57291d, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$57291d, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$77ffff, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$573333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$57291d, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$77ffff, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$573333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$77ffff, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$52b930, $ffe28000, $ffa00000, $0
	.dc.s	$5e, $ffffffca, $40000000, $0
	.dc.s	$52b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$57291d, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$573333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$573333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$52cccc, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$31ffff, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$52b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$52b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$52cccc, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	$573333, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$573333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$52cccc, $fff80000, $ffa00000, $0
	.dc.s	$5f, $21, $40000000, $0
	.dc.s	$573333, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$573333, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb0000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$31ffff, $ffe10000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$31ffff, $ffe10000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb0000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$31ffff, $ffe10000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$31ffff, $fffb0000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe10000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$77ffff, $fffb0000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $fffffffd, $40, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe10000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $fffffffd, $40, $0
	.dc.s	$77ffff, $ffe10000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa7cccc, $fffe6666, $ffa00000, $0
	.dc.s	$5e, $fffffffb, $40000000, $0
	.dc.s	$ffac3333, $fffe6666, $ffa00000, $0
	.dc.s	$60, $ffffffd5, $40000000, $0
	.dc.s	$ffcdffff, $ffff0000, $ff9fffff, $0
	.dc.s	$60, $fffffffb, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa7cccc, $fffe6666, $ffa00000, $0
	.dc.s	$5e, $fffffffb, $40000000, $0
	.dc.s	$ffcdffff, $ffff0000, $ff9fffff, $0
	.dc.s	$60, $fffffffb, $40000000, $0
	.dc.s	$ff86ffff, $ffff0000, $ffa00000, $0
	.dc.s	$5c, $26, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $fffb6666, $ff9fffff, $0
	.dc.s	$5f, $ffffffe3, $40000000, $0
	.dc.s	$ffcdffff, $ffff0000, $ff9fffff, $0
	.dc.s	$60, $fffffffb, $40000000, $0
	.dc.s	$ffac3333, $fffe6666, $ffa00000, $0
	.dc.s	$60, $ffffffd5, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $fffb6666, $ff9fffff, $0
	.dc.s	$5f, $ffffffe3, $40000000, $0
	.dc.s	$ffac3333, $fffe6666, $ffa00000, $0
	.dc.s	$60, $ffffffd5, $40000000, $0
	.dc.s	$ffac3333, $fffc0000, $ffa00000, $0
	.dc.s	$60, $ffffff77, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff86ffff, $fffb6666, $ffa00000, $0
	.dc.s	$5e, $ffffff77, $40000000, $0
	.dc.s	$ffcdffff, $fffb6666, $ff9fffff, $0
	.dc.s	$5f, $ffffffe3, $40000000, $0
	.dc.s	$ffac3333, $fffc0000, $ffa00000, $0
	.dc.s	$60, $ffffff77, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff86ffff, $fffb6666, $ffa00000, $0
	.dc.s	$5e, $ffffff77, $40000000, $0
	.dc.s	$ffac3333, $fffc0000, $ffa00000, $0
	.dc.s	$60, $ffffff77, $40000000, $0
	.dc.s	$ffa7cccc, $fffc0000, $ffa00000, $0
	.dc.s	$5e, $ffffff94, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff86ffff, $ffff0000, $ffa00000, $0
	.dc.s	$5c, $26, $40000000, $0
	.dc.s	$ff86ffff, $fffb6666, $ffa00000, $0
	.dc.s	$5e, $ffffff77, $40000000, $0
	.dc.s	$ffa7cccc, $fffc0000, $ffa00000, $0
	.dc.s	$5e, $ffffff94, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff86ffff, $ffff0000, $ffa00000, $0
	.dc.s	$5c, $26, $40000000, $0
	.dc.s	$ffa7cccc, $fffc0000, $ffa00000, $0
	.dc.s	$5e, $ffffff94, $40000000, $0
	.dc.s	$ffa7cccc, $fffe6666, $ffa00000, $0
	.dc.s	$5e, $fffffffb, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff87ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	$ffa8cccc, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	$ffa8cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	$ffa8b930, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$ffa8b930, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	$ffad291d, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffc7, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$ffad291d, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffc7, $c0000000, $0
	.dc.s	$ffad291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$ffcdffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$ffad291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$ffad291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffad3333, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8b930, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	$ffa8b930, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffad3333, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffad291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffad291d, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffa8b930, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffa8b930, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8cccc, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	$ff87ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffad3333, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	$ffcdffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$ffad3333, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	$ffa8cccc, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$ffa8cccc, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	$ff87ffff, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8cccc, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	$ffa8cccc, $fff80000, $ffa00000, $0
	.dc.s	$5f, $21, $40000000, $0
	.dc.s	$ff87ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad291d, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$ffa8b930, $ffe28000, $ffa00000, $0
	.dc.s	$5e, $ffffffca, $40000000, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad291d, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$ffcdffff, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad291d, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$ffad291d, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$ffcdffff, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffad291d, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$ffcdffff, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffad3333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffcdffff, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	$ffcdffff, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff87ffff, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$ffa8b930, $ffe28000, $ffa00000, $0
	.dc.s	$5e, $ffffffca, $40000000, $0
	.dc.s	$ffa8b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffad291d, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$ffad3333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffa8b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffad3333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffa8cccc, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff87ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$ffa8b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff87ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$ffa8b930, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffa8cccc, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	$ffad3333, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$ffad3333, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff87ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$ffa8cccc, $fff80000, $ffa00000, $0
	.dc.s	$5f, $21, $40000000, $0
	.dc.s	$ffad3333, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff87ffff, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$ffad3333, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$ffcdffff, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff87ffff, $fffb0000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff87ffff, $fffb0000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff87ffff, $ffe10000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff87ffff, $fffb0000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $ffe10000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffcdffff, $fffb0000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffcdffff, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcdffff, $ffe10000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffcdffff, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffcdffff, $ffe10000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffc4113, $fffe6666, $ffa00000, $0
	.dc.s	$62, $fffffef3, $40000000, $0
	.dc.s	$28bd3, $fffe6666, $ff9fffff, $0
	.dc.s	$60, $ffffff0c, $40000000, $0
	.dc.s	$32e154, $ffff0000, $ff9fffff, $0
	.dc.s	$61, $fffffef3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fffc4113, $fffe6666, $ffa00000, $0
	.dc.s	$62, $fffffef3, $40000000, $0
	.dc.s	$32e154, $ffff0000, $ff9fffff, $0
	.dc.s	$61, $fffffef3, $40000000, $0
	.dc.s	$ffcd59a6, $ffff0000, $ffa00000, $0
	.dc.s	$60, $ffffffe7, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$32e154, $fffb6666, $ff9fffff, $0
	.dc.s	$5e, $32, $40000000, $0
	.dc.s	$32e154, $ffff0000, $ff9fffff, $0
	.dc.s	$61, $fffffef3, $40000000, $0
	.dc.s	$28bd3, $fffe6666, $ff9fffff, $0
	.dc.s	$60, $ffffff0c, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$32e154, $fffb6666, $ff9fffff, $0
	.dc.s	$5e, $32, $40000000, $0
	.dc.s	$28bd3, $fffe6666, $ff9fffff, $0
	.dc.s	$60, $ffffff0c, $40000000, $0
	.dc.s	$28bd3, $fffc0000, $ff9fffff, $0
	.dc.s	$61, $ffffff90, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcd59a6, $fffb6666, $ffa00000, $0
	.dc.s	$62, $ffffff90, $40000000, $0
	.dc.s	$32e154, $fffb6666, $ff9fffff, $0
	.dc.s	$5e, $32, $40000000, $0
	.dc.s	$28bd3, $fffc0000, $ff9fffff, $0
	.dc.s	$61, $ffffff90, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcd59a6, $fffb6666, $ffa00000, $0
	.dc.s	$62, $ffffff90, $40000000, $0
	.dc.s	$28bd3, $fffc0000, $ff9fffff, $0
	.dc.s	$61, $ffffff90, $40000000, $0
	.dc.s	$fffc4113, $fffc0000, $ffa00000, $0
	.dc.s	$62, $ffffff5d, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcd59a6, $ffff0000, $ffa00000, $0
	.dc.s	$60, $ffffffe7, $40000000, $0
	.dc.s	$ffcd59a6, $fffb6666, $ffa00000, $0
	.dc.s	$62, $ffffff90, $40000000, $0
	.dc.s	$fffc4113, $fffc0000, $ffa00000, $0
	.dc.s	$62, $ffffff5d, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffcd59a6, $ffff0000, $ffa00000, $0
	.dc.s	$60, $ffffffe7, $40000000, $0
	.dc.s	$fffc4113, $fffc0000, $ffa00000, $0
	.dc.s	$62, $ffffff5d, $40000000, $0
	.dc.s	$fffc4113, $fffe6666, $ffa00000, $0
	.dc.s	$62, $fffffef3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffc0ab01, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	$ffe177ce, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	$ffe177ce, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	$ffe16432, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$ffe16432, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	$ffe5d41f, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffc7, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$ffe5d41f, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffc7, $c0000000, $0
	.dc.s	$ffe5d41f, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$6ab01, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $ffffffe4, $c0000000, $0
	.dc.s	$ffe5d41f, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$ffe5d41f, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffe5de35, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe16432, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	$ffe16432, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa2, $ffffffdb, $c0000000, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe177ce, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffe5de35, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffe5d41f, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe177ce, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffe5d41f, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffe16432, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe177ce, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffe16432, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe177ce, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa4, $1, $c0000000, $0
	.dc.s	$ffc0ab01, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe5de35, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$ffe5de35, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	$6ab01, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$ffe5de35, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	$ffe177ce, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $c, $c0000000, $0
	.dc.s	$ffe177ce, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa2, $14, $c0000000, $0
	.dc.s	$ffc0ab01, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa4, $ffffffff, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe177ce, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	$ffe177ce, $fff80000, $ffa00000, $0
	.dc.s	$5f, $21, $40000000, $0
	.dc.s	$ffc0ab01, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe5d41f, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$ffe16432, $ffe28000, $ffa00000, $0
	.dc.s	$5e, $ffffffca, $40000000, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe5d41f, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$6ab01, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe5d41f, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$ffe5d41f, $ffe28000, $ffa00000, $0
	.dc.s	$5d, $ffffffe0, $40000000, $0
	.dc.s	$6ab01, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe5de35, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffe5d41f, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$6ab01, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe5de35, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$6ab01, $ffe10000, $ff9fffff, $0
	.dc.s	$5c, $3, $40000000, $0
	.dc.s	$6ab01, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffc0ab01, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$ffe16432, $ffe28000, $ffa00000, $0
	.dc.s	$5e, $ffffffca, $40000000, $0
	.dc.s	$ffe16432, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe16432, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffe5d41f, $ffe68000, $ffa00000, $0
	.dc.s	$5d, $0, $40000000, $0
	.dc.s	$ffe5de35, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffe16432, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffe5de35, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffe177ce, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffc0ab01, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa00000, $0
	.dc.s	$5d, $ffffffe8, $40000000, $0
	.dc.s	$ffe16432, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffc0ab01, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$ffe16432, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$ffe177ce, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	$ffe5de35, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$ffe5de35, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffc0ab01, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$ffe177ce, $fff80000, $ffa00000, $0
	.dc.s	$5f, $21, $40000000, $0
	.dc.s	$ffe5de35, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffc0ab01, $fffb0000, $ffa00000, $0
	.dc.s	$5d, $c, $40000000, $0
	.dc.s	$ffe5de35, $fff80000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$6ab01, $fffb0000, $ff9fffff, $0
	.dc.s	$5c, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffc0ab01, $fffb0000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ffc0ab01, $fffb0000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffc0ab01, $ffe10000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffc0ab01, $fffb0000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $ffe10000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$6ab01, $fffb0000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$6ab01, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$6ab01, $ffe10000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$6ab01, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$6ab01, $ffe10000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccc, $fffe6666, $ffa00000, $0
	.dc.s	$5e, $fffffffb, $40000000, $0
	.dc.s	$573333, $fffe6666, $ffa00000, $0
	.dc.s	$60, $ffffffd5, $40000000, $0
	.dc.s	$78ffff, $ffff0000, $ff9fffff, $0
	.dc.s	$60, $fffffffb, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$52cccc, $fffe6666, $ffa00000, $0
	.dc.s	$5e, $fffffffb, $40000000, $0
	.dc.s	$78ffff, $ffff0000, $ff9fffff, $0
	.dc.s	$60, $fffffffb, $40000000, $0
	.dc.s	$31ffff, $ffff0000, $ffa00000, $0
	.dc.s	$5c, $26, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb6666, $ff9fffff, $0
	.dc.s	$5f, $ffffffe3, $40000000, $0
	.dc.s	$78ffff, $ffff0000, $ff9fffff, $0
	.dc.s	$60, $fffffffb, $40000000, $0
	.dc.s	$573333, $fffe6666, $ffa00000, $0
	.dc.s	$60, $ffffffd5, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb6666, $ff9fffff, $0
	.dc.s	$5f, $ffffffe3, $40000000, $0
	.dc.s	$573333, $fffe6666, $ffa00000, $0
	.dc.s	$60, $ffffffd5, $40000000, $0
	.dc.s	$573333, $fffc0000, $ffa00000, $0
	.dc.s	$60, $ffffff77, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb6666, $ffa00000, $0
	.dc.s	$5e, $ffffff77, $40000000, $0
	.dc.s	$78ffff, $fffb6666, $ff9fffff, $0
	.dc.s	$5f, $ffffffe3, $40000000, $0
	.dc.s	$573333, $fffc0000, $ffa00000, $0
	.dc.s	$60, $ffffff77, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $fffb6666, $ffa00000, $0
	.dc.s	$5e, $ffffff77, $40000000, $0
	.dc.s	$573333, $fffc0000, $ffa00000, $0
	.dc.s	$60, $ffffff77, $40000000, $0
	.dc.s	$52cccc, $fffc0000, $ffa00000, $0
	.dc.s	$5e, $ffffff94, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $ffff0000, $ffa00000, $0
	.dc.s	$5c, $26, $40000000, $0
	.dc.s	$31ffff, $fffb6666, $ffa00000, $0
	.dc.s	$5e, $ffffff77, $40000000, $0
	.dc.s	$52cccc, $fffc0000, $ffa00000, $0
	.dc.s	$5e, $ffffff94, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$31ffff, $ffff0000, $ffa00000, $0
	.dc.s	$5c, $26, $40000000, $0
	.dc.s	$52cccc, $fffc0000, $ffa00000, $0
	.dc.s	$5e, $ffffff94, $40000000, $0
	.dc.s	$52cccc, $fffe6666, $ffa00000, $0
	.dc.s	$5e, $fffffffb, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff954fd, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $fffffff3, $c0000000, $0
	.dc.s	$1a21ca, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $fffffff1, $c0000000, $0
	.dc.s	$1a21ca, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $ffe10000, $ffa06666, $0
	.dc.s	$ffffff9f, $19, $c0000000, $0
	.dc.s	$fff954fd, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $12, $c0000000, $0
	.dc.s	$1a0e2e, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $ffe10000, $ffa06666, $0
	.dc.s	$ffffff9f, $19, $c0000000, $0
	.dc.s	$1a0e2e, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	$1e7e1a, $ffe28000, $ffa06666, $0
	.dc.s	$ffffff9f, $e, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $ffe10000, $ffa06666, $0
	.dc.s	$ffffff9f, $19, $c0000000, $0
	.dc.s	$1e7e1a, $ffe28000, $ffa06666, $0
	.dc.s	$ffffff9f, $e, $c0000000, $0
	.dc.s	$1e7e1a, $ffe68000, $ffa06666, $0
	.dc.s	$ffffff9e, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $fffb0000, $ffa06666, $0
	.dc.s	$ffffff9f, $fffffff7, $c0000000, $0
	.dc.s	$3f54fd, $ffe10000, $ffa06666, $0
	.dc.s	$ffffff9f, $19, $c0000000, $0
	.dc.s	$1e7e1a, $ffe68000, $ffa06666, $0
	.dc.s	$ffffff9e, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $fffb0000, $ffa06666, $0
	.dc.s	$ffffff9f, $fffffff7, $c0000000, $0
	.dc.s	$1e7e1a, $ffe68000, $ffa06666, $0
	.dc.s	$ffffff9e, $0, $c0000000, $0
	.dc.s	$1e8831, $ffee0000, $ffa06666, $0
	.dc.s	$ffffff9e, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1a0e2e, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	$1a0e2e, $ffe28000, $ffa06666, $0
	.dc.s	$ffffffa1, $21, $c0000000, $0
	.dc.s	$fff954fd, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $12, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1a21ca, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$1e8831, $ffee0000, $ffa06666, $0
	.dc.s	$ffffff9e, $0, $c0000000, $0
	.dc.s	$1e7e1a, $ffe68000, $ffa06666, $0
	.dc.s	$ffffff9e, $0, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1a21ca, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$1e7e1a, $ffe68000, $ffa06666, $0
	.dc.s	$ffffff9e, $0, $c0000000, $0
	.dc.s	$1a0e2e, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1a21ca, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$1a0e2e, $ffe68000, $ffa06666, $0
	.dc.s	$ffffffa2, $1, $c0000000, $0
	.dc.s	$fff954fd, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $12, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1a21ca, $ffee0000, $ffa06666, $0
	.dc.s	$ffffffa2, $0, $c0000000, $0
	.dc.s	$fff954fd, $ffe10000, $ffa06666, $0
	.dc.s	$ffffffa3, $12, $c0000000, $0
	.dc.s	$fff954fd, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $fffffff3, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1e8831, $ffee0000, $ffa06666, $0
	.dc.s	$ffffff9e, $0, $c0000000, $0
	.dc.s	$1e8831, $fff80000, $ffa06666, $0
	.dc.s	$ffffff9e, $fffffffd, $c0000000, $0
	.dc.s	$3f54fd, $fffb0000, $ffa06666, $0
	.dc.s	$ffffff9f, $fffffff7, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $fffb0000, $ffa06666, $0
	.dc.s	$ffffff9f, $fffffff7, $c0000000, $0
	.dc.s	$1e8831, $fff80000, $ffa06666, $0
	.dc.s	$ffffff9e, $fffffffd, $c0000000, $0
	.dc.s	$1a21ca, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $fffffff1, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $fffb0000, $ffa06666, $0
	.dc.s	$ffffff9f, $fffffff7, $c0000000, $0
	.dc.s	$1a21ca, $fff80000, $ffa06666, $0
	.dc.s	$ffffffa1, $fffffff1, $c0000000, $0
	.dc.s	$fff954fd, $fffb0000, $ffa06666, $0
	.dc.s	$ffffffa3, $fffffff3, $c0000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1a21ca, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	$1a21ca, $fff80000, $ffa00000, $0
	.dc.s	$5f, $21, $40000000, $0
	.dc.s	$fff954fd, $fffb0000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1e7e1a, $ffe28000, $ffa00000, $0
	.dc.s	$61, $ffffffc6, $40000000, $0
	.dc.s	$1a0e2e, $ffe28000, $ffa00000, $0
	.dc.s	$5e, $ffffffca, $40000000, $0
	.dc.s	$fff954fd, $ffe10000, $ffa00000, $0
	.dc.s	$5e, $ffffffd5, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1e7e1a, $ffe28000, $ffa00000, $0
	.dc.s	$61, $ffffffc6, $40000000, $0
	.dc.s	$fff954fd, $ffe10000, $ffa00000, $0
	.dc.s	$5e, $ffffffd5, $40000000, $0
	.dc.s	$3f54fd, $ffe10000, $ff9fffff, $0
	.dc.s	$61, $fffffff0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1e7e1a, $ffe68000, $ffa00000, $0
	.dc.s	$62, $0, $40000000, $0
	.dc.s	$1e7e1a, $ffe28000, $ffa00000, $0
	.dc.s	$61, $ffffffc6, $40000000, $0
	.dc.s	$3f54fd, $ffe10000, $ff9fffff, $0
	.dc.s	$61, $fffffff0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1e8831, $ffee0000, $ffa00000, $0
	.dc.s	$62, $0, $40000000, $0
	.dc.s	$1e7e1a, $ffe68000, $ffa00000, $0
	.dc.s	$62, $0, $40000000, $0
	.dc.s	$3f54fd, $ffe10000, $ff9fffff, $0
	.dc.s	$61, $fffffff0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1e8831, $ffee0000, $ffa00000, $0
	.dc.s	$62, $0, $40000000, $0
	.dc.s	$3f54fd, $ffe10000, $ff9fffff, $0
	.dc.s	$61, $fffffff0, $40000000, $0
	.dc.s	$3f54fd, $fffb0000, $ff9fffff, $0
	.dc.s	$61, $b, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff954fd, $ffe10000, $ffa00000, $0
	.dc.s	$5e, $ffffffd5, $40000000, $0
	.dc.s	$1a0e2e, $ffe28000, $ffa00000, $0
	.dc.s	$5e, $ffffffca, $40000000, $0
	.dc.s	$1a0e2e, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1a0e2e, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$1e7e1a, $ffe68000, $ffa00000, $0
	.dc.s	$62, $0, $40000000, $0
	.dc.s	$1e8831, $ffee0000, $ffa00000, $0
	.dc.s	$62, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$1a0e2e, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$1e8831, $ffee0000, $ffa00000, $0
	.dc.s	$62, $0, $40000000, $0
	.dc.s	$1a21ca, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff954fd, $fffb0000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$fff954fd, $ffe10000, $ffa00000, $0
	.dc.s	$5e, $ffffffd5, $40000000, $0
	.dc.s	$1a0e2e, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff954fd, $fffb0000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$1a0e2e, $ffe68000, $ffa00000, $0
	.dc.s	$5e, $0, $40000000, $0
	.dc.s	$1a21ca, $ffee0000, $ffa00000, $0
	.dc.s	$5e, $ffffffff, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $fffb0000, $ff9fffff, $0
	.dc.s	$61, $b, $40000000, $0
	.dc.s	$1e8831, $fff80000, $ffa00000, $0
	.dc.s	$61, $21, $40000000, $0
	.dc.s	$1e8831, $ffee0000, $ffa00000, $0
	.dc.s	$62, $0, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff954fd, $fffb0000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$1a21ca, $fff80000, $ffa00000, $0
	.dc.s	$5f, $21, $40000000, $0
	.dc.s	$1e8831, $fff80000, $ffa00000, $0
	.dc.s	$61, $21, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff954fd, $fffb0000, $ffa00000, $0
	.dc.s	$5e, $14, $40000000, $0
	.dc.s	$1e8831, $fff80000, $ffa00000, $0
	.dc.s	$61, $21, $40000000, $0
	.dc.s	$3f54fd, $fffb0000, $ff9fffff, $0
	.dc.s	$61, $b, $40000000, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff954fd, $fffb0000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$fff954fd, $ffe10000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$fff954fd, $ffe10000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$fff954fd, $fffb0000, $ffa06666, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$fff954fd, $ffe10000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$fff954fd, $fffb0000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $ffe10000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$3f54fd, $fffb0000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$3f54fd, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$3f54fd, $ffe10000, $ffa06666, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$3f54fd, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$3f54fd, $ffe10000, $ff9fffff, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $ffff0000, $0, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $ffff0000, $300000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff8702f8, $fffe8000, $19a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $ffff0000, $0, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff8702f8, $fffe8000, $19a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	$ff870000, $fffe8000, $15428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $0, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $ffff0000, $0, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $fffe8000, $15428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $0, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffe8000, $15428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	$ff870000, $fffc0000, $15428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $300000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffb8000, $0, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffc0000, $15428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $300000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffc0000, $15428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	$ff8702f8, $fffc0000, $19a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff8702f8, $fffc0000, $19a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	$ff8702f8, $fffe8000, $19a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	$ff870000, $ffff0000, $300000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff8702f8, $fffc0000, $19a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	$ff870000, $ffff0000, $300000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $fffb8000, $300000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe28000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe28000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe18000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fff80000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fff80000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $300000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $19bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $15495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe68000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $19bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $300000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $15495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $ffff0000, $ffd00000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $ffff0000, $0, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff8702f8, $fffe8000, $ffe9a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $ffff0000, $ffd00000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff8702f8, $fffe8000, $ffe9a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	$ff870000, $fffe8000, $ffe5428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $ffd00000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $ffff0000, $ffd00000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $fffe8000, $ffe5428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $ffd00000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffe8000, $ffe5428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	$ff870000, $fffc0000, $ffe5428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $0, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffb8000, $ffd00000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffc0000, $ffe5428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $0, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffc0000, $ffe5428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	$ff8702f8, $fffc0000, $ffe9a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff8702f8, $fffc0000, $ffe9a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	$ff8702f8, $fffe8000, $ffe9a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	$ff870000, $ffff0000, $0, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff8702f8, $fffc0000, $ffe9a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	$ff870000, $ffff0000, $0, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $fffb8000, $0, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe28000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe28000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe18000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fff80000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fff80000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $0, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffe9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffe5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe68000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffe9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $0, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffe5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $ffff0000, $ffa00000, $0
	.dc.s	$3fdc0c5c, $fe1a18af, $fff197e3, $0
	.dc.s	$ff870000, $ffff0000, $ffd00000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff8702f8, $fffe8000, $ffb9a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $ffff0000, $ffa00000, $0
	.dc.s	$3fdc0c5c, $fe1a18af, $fff197e3, $0
	.dc.s	$ff8702f8, $fffe8000, $ffb9a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	$ff870000, $fffe8000, $ffb5428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff870000, $ffff0000, $ffa00000, $0
	.dc.s	$3fdc0c5c, $fe1a18af, $fff197e3, $0
	.dc.s	$ff870000, $fffe8000, $ffb5428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff870000, $fffe8000, $ffb5428f, $0
	.dc.s	$3fdd8477, $fd9b6d76, $fff197e3, $0
	.dc.s	$ff870000, $fffc0000, $ffb5428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $ffd00000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffb8000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff870000, $fffc0000, $ffb5428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff870000, $fffb8000, $ffd00000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	$ff870000, $fffc0000, $ffb5428f, $0
	.dc.s	$3fc9c24a, $fd0055e0, $fff1a551, $0
	.dc.s	$ff8702f8, $fffc0000, $ffb9a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff8702f8, $fffc0000, $ffb9a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	$ff8702f8, $fffe8000, $ffb9a12d, $0
	.dc.s	$3fdc0c2c, $fe1a18af, $fff46cdd, $0
	.dc.s	$ff870000, $ffff0000, $ffd00000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff8702f8, $fffc0000, $ffb9a12d, $0
	.dc.s	$3fc9c1ea, $fd0055e0, $fff74f44, $0
	.dc.s	$ff870000, $ffff0000, $ffd00000, $0
	.dc.s	$3fed49f0, $ff4c61f5, $fffba0eb, $0
	.dc.s	$ff870000, $fffb8000, $ffd00000, $0
	.dc.s	$3fe4e10d, $fe802af0, $fffa3d25, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe28000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffa00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe28000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffa00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $ffa00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe18000, $ffa00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe28000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffee0000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $ffe68000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fff80000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fff80000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fffb0000, $ffa00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $ffd00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $fff80000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffb9bc29, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $ffa00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe18000, $ffa00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff886666, $fffb0000, $ffa00000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffe68000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ff886666, $ffee0000, $ffb5495f, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe18000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffe68000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe28000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffee0000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $fffb0000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fff80000, $ffb9bc29, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $ffd00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe68000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$ff880000, $ffee0000, $ffb5495f, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $ffe18000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff880000, $fffb0000, $ffa00000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$790000, $ffff0000, $5fffff, $0
	.dc.s	$c023f3af, $fe1a182a, $e687b, $0
	.dc.s	$78ffff, $ffff0000, $2fffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78fd07, $fffe8000, $465ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$790000, $ffff0000, $5fffff, $0
	.dc.s	$c023f3af, $fe1a182a, $e687b, $0
	.dc.s	$78fd07, $fffe8000, $465ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	$790000, $fffe8000, $4abd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$790000, $fffb8000, $5fffff, $0
	.dc.s	$c0000000, $2b, $5c, $0
	.dc.s	$790000, $ffff0000, $5fffff, $0
	.dc.s	$c023f3af, $fe1a182a, $e687b, $0
	.dc.s	$790000, $fffe8000, $4abd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$790000, $fffb8000, $5fffff, $0
	.dc.s	$c0000000, $2b, $5c, $0
	.dc.s	$790000, $fffe8000, $4abd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	$790000, $fffc0000, $4abd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $2fffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffb8000, $5fffff, $0
	.dc.s	$c0000000, $2b, $5c, $0
	.dc.s	$790000, $fffc0000, $4abd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $2fffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffc0000, $4abd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	$78fd07, $fffc0000, $465ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78fd07, $fffc0000, $465ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	$78fd07, $fffe8000, $465ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	$78ffff, $ffff0000, $2fffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78fd07, $fffc0000, $465ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	$78ffff, $ffff0000, $2fffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78ffff, $fffb8000, $2fffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe28000, $4643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe28000, $4ab6a1, $0
	.dc.s	$40000000, $ffffffc3, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $5fffff, $0
	.dc.s	$40000000, $ffffffd3, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe28000, $4643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $5fffff, $0
	.dc.s	$40000000, $ffffffd3, $ffffffa3, $0
	.dc.s	$779999, $ffe18000, $2fffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $4ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $fff80000, $4ab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $5fffff, $0
	.dc.s	$40000000, $6, $ffffffa4, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe28000, $4643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $2fffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe18000, $5fffff, $0
	.dc.s	$40000000, $ffffffd3, $ffffffa3, $0
	.dc.s	$779999, $ffe28000, $4ab6a1, $0
	.dc.s	$40000000, $ffffffc3, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $4ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe68000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $2fffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $2fffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $2fffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $4ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffe68000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffee0000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $4ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffee0000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffee0000, $4ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fff80000, $4ab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fff80000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffff9f, $0
	.dc.s	$779999, $fffb0000, $2fffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fff80000, $4ab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $2fffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $5fffff, $0
	.dc.s	$40000000, $6, $ffffffa4, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $2fffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $fff80000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffff9f, $0
	.dc.s	$779999, $ffee0000, $4643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $5fffff, $0
	.dc.s	$40000000, $6, $ffffffa4, $0
	.dc.s	$779999, $ffe18000, $5fffff, $0
	.dc.s	$40000000, $ffffffd3, $ffffffa3, $0
	.dc.s	$779999, $ffe68000, $4ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $5fffff, $0
	.dc.s	$40000000, $6, $ffffffa4, $0
	.dc.s	$779999, $ffe68000, $4ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffee0000, $4ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $2fffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe18000, $5fffff, $0
	.dc.s	$c0000000, $11, $5c, $0
	.dc.s	$780000, $ffe28000, $4ab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $2fffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $4ab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	$780000, $ffe28000, $4643d6, $0
	.dc.s	$c0000000, $ffffffff, $61, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $5fffff, $0
	.dc.s	$c0000000, $fffffff1, $5d, $0
	.dc.s	$780000, $fff80000, $4ab6a1, $0
	.dc.s	$c0000000, $ffffffec, $5e, $0
	.dc.s	$780000, $ffee0000, $4ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $2fffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $4643d6, $0
	.dc.s	$c0000000, $ffffffff, $61, $0
	.dc.s	$780000, $ffe68000, $4643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffe68000, $4ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe28000, $4ab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	$780000, $ffe18000, $5fffff, $0
	.dc.s	$c0000000, $11, $5c, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $2fffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$77ffff, $ffe18000, $2fffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe68000, $4643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $2fffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $ffe68000, $4643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffee0000, $4643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $4ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffee0000, $4643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffe68000, $4643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $4ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe68000, $4643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffe68000, $4ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $5fffff, $0
	.dc.s	$c0000000, $fffffff1, $5d, $0
	.dc.s	$77ffff, $fffb0000, $2fffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $4643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $fffb0000, $5fffff, $0
	.dc.s	$c0000000, $fffffff1, $5d, $0
	.dc.s	$780000, $fff80000, $4643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	$780000, $fff80000, $4ab6a1, $0
	.dc.s	$c0000000, $ffffffec, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $4643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $fff80000, $4643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	$77ffff, $fffb0000, $2fffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $4ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe68000, $4ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe18000, $5fffff, $0
	.dc.s	$c0000000, $11, $5c, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $4ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe18000, $5fffff, $0
	.dc.s	$c0000000, $11, $5c, $0
	.dc.s	$780000, $fffb0000, $5fffff, $0
	.dc.s	$c0000000, $fffffff1, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $ffff0000, $2fffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78ffff, $ffff0000, $ffffffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78fd07, $fffe8000, $165ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $ffff0000, $2fffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78fd07, $fffe8000, $165ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	$790000, $fffe8000, $1abd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $2fffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$78ffff, $ffff0000, $2fffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$790000, $fffe8000, $1abd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $2fffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffe8000, $1abd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	$790000, $fffc0000, $1abd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ffffffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$78ffff, $fffb8000, $2fffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffc0000, $1abd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ffffffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffc0000, $1abd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	$78fd07, $fffc0000, $165ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78fd07, $fffc0000, $165ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	$78fd07, $fffe8000, $165ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	$78ffff, $ffff0000, $ffffffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78fd07, $fffc0000, $165ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	$78ffff, $ffff0000, $ffffffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78ffff, $fffb8000, $ffffffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe28000, $1643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe28000, $1ab6a1, $0
	.dc.s	$40000000, $ffffffc3, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $2fffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe28000, $1643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $2fffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $ffffffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $1ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $fff80000, $1ab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $2fffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe28000, $1643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ffffffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe18000, $2fffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe28000, $1ab6a1, $0
	.dc.s	$40000000, $ffffffc3, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $1ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe68000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ffffffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ffffffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $ffffffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $1ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffe68000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffee0000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $1ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffee0000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffee0000, $1ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fff80000, $1ab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fff80000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffff9f, $0
	.dc.s	$779999, $fffb0000, $ffffffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fff80000, $1ab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $ffffffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $2fffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $ffffffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $fff80000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffff9f, $0
	.dc.s	$779999, $ffee0000, $1643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $2fffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $2fffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $1ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $2fffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $1ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffee0000, $1ab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ffffffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$77ffff, $ffe18000, $2fffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $1ab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ffffffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $1ab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	$780000, $ffe28000, $1643d6, $0
	.dc.s	$c0000000, $ffffffff, $61, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $2fffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $1ab6a1, $0
	.dc.s	$c0000000, $ffffffec, $5e, $0
	.dc.s	$780000, $ffee0000, $1ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ffffffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $1643d6, $0
	.dc.s	$c0000000, $ffffffff, $61, $0
	.dc.s	$780000, $ffe68000, $1643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffe68000, $1ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe28000, $1ab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	$77ffff, $ffe18000, $2fffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffffffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$77ffff, $ffe18000, $ffffffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe68000, $1643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffffffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $ffe68000, $1643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffee0000, $1643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $1ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffee0000, $1643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffe68000, $1643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $1ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe68000, $1643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffe68000, $1ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $2fffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$77ffff, $fffb0000, $ffffffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $1643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $2fffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $1643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	$780000, $fff80000, $1ab6a1, $0
	.dc.s	$c0000000, $ffffffec, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $1643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $fff80000, $1643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	$77ffff, $fffb0000, $ffffffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $1ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe68000, $1ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$77ffff, $ffe18000, $2fffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $1ab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$77ffff, $ffe18000, $2fffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$77ffff, $fffb0000, $2fffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $ffff0000, $ffffffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78ffff, $ffff0000, $ffcfffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78fd07, $fffe8000, $ffe65ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $ffff0000, $ffffffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78fd07, $fffe8000, $ffe65ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	$790000, $fffe8000, $ffeabd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ffffffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$78ffff, $ffff0000, $ffffffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$790000, $fffe8000, $ffeabd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ffffffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffe8000, $ffeabd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	$790000, $fffc0000, $ffeabd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ffcfffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$78ffff, $fffb8000, $ffffffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffc0000, $ffeabd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ffcfffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffc0000, $ffeabd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	$78fd07, $fffc0000, $ffe65ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78fd07, $fffc0000, $ffe65ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	$78fd07, $fffe8000, $ffe65ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	$78ffff, $ffff0000, $ffcfffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78fd07, $fffc0000, $ffe65ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	$78ffff, $ffff0000, $ffcfffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78ffff, $fffb8000, $ffcfffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe28000, $ffe643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe28000, $ffeab6a1, $0
	.dc.s	$40000000, $ffffffc3, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $ffffffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe28000, $ffe643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ffffffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $ffcfffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $ffeab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $fff80000, $ffeab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $ffffffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe28000, $ffe643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ffcfffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe18000, $ffffffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe28000, $ffeab6a1, $0
	.dc.s	$40000000, $ffffffc3, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $ffeab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe68000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ffcfffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ffcfffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $ffcfffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $ffeab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffe68000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffee0000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $ffeab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffee0000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffee0000, $ffeab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fff80000, $ffeab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fff80000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffff9f, $0
	.dc.s	$779999, $fffb0000, $ffcfffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fff80000, $ffeab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $ffcfffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $ffffffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $ffcfffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $fff80000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffff9f, $0
	.dc.s	$779999, $ffee0000, $ffe643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $ffffffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $ffffffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $ffeab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $ffffffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $ffeab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffee0000, $ffeab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ffcfffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$77ffff, $ffe18000, $ffffffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $ffeab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ffcfffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $ffeab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	$780000, $ffe28000, $ffe643d6, $0
	.dc.s	$c0000000, $ffffffff, $61, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffffffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $ffeab6a1, $0
	.dc.s	$c0000000, $ffffffec, $5e, $0
	.dc.s	$780000, $ffee0000, $ffeab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ffcfffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $ffe643d6, $0
	.dc.s	$c0000000, $ffffffff, $61, $0
	.dc.s	$780000, $ffe68000, $ffe643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffe68000, $ffeab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe28000, $ffeab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	$77ffff, $ffe18000, $ffffffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffcfffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$77ffff, $ffe18000, $ffcfffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe68000, $ffe643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffcfffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $ffe68000, $ffe643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffee0000, $ffe643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffeab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffee0000, $ffe643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffe68000, $ffe643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffeab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe68000, $ffe643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffe68000, $ffeab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffffffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$77ffff, $fffb0000, $ffcfffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $ffe643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffffffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $ffe643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	$780000, $fff80000, $ffeab6a1, $0
	.dc.s	$c0000000, $ffffffec, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffe643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $fff80000, $ffe643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	$77ffff, $fffb0000, $ffcfffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffeab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe68000, $ffeab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$77ffff, $ffe18000, $ffffffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffeab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$77ffff, $ffe18000, $ffffffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$77ffff, $fffb0000, $ffffffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $ffff0000, $ffcfffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78ffff, $ffff0000, $ff9fffff, $0
	.dc.s	$c001787a, $7eab1b, $fffa566c, $0
	.dc.s	$78fd07, $fffe8000, $ffb65ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $ffff0000, $ffcfffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$78fd07, $fffe8000, $ffb65ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	$790000, $fffe8000, $ffbabd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ffcfffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$78ffff, $ffff0000, $ffcfffff, $0
	.dc.s	$c012b615, $ff4c61a3, $45f74, $0
	.dc.s	$790000, $fffe8000, $ffbabd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ffcfffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffe8000, $ffbabd70, $0
	.dc.s	$c0227b95, $fd9b6d0f, $e687a, $0
	.dc.s	$790000, $fffc0000, $ffbabd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ff9fffff, $0
	.dc.s	$c0363deb, $fd0055ea, $b8615, $0
	.dc.s	$78ffff, $fffb8000, $ffcfffff, $0
	.dc.s	$c01b1ef5, $fe802b0b, $5c339, $0
	.dc.s	$790000, $fffc0000, $ffbabd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78ffff, $fffb8000, $ff9fffff, $0
	.dc.s	$c0363deb, $fd0055ea, $b8615, $0
	.dc.s	$790000, $fffc0000, $ffbabd70, $0
	.dc.s	$c0363dbb, $fd0055ea, $e5b0d, $0
	.dc.s	$78fd07, $fffc0000, $ffb65ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78fd07, $fffc0000, $ffb65ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	$78fd07, $fffe8000, $ffb65ed2, $0
	.dc.s	$c023f3df, $fe1a182a, $b9383, $0
	.dc.s	$78ffff, $ffff0000, $ff9fffff, $0
	.dc.s	$c001787a, $7eab1b, $fffa566c, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$78fd07, $fffc0000, $ffb65ed2, $0
	.dc.s	$c0363e1b, $fd0055bf, $8b11d, $0
	.dc.s	$78ffff, $ffff0000, $ff9fffff, $0
	.dc.s	$c001787a, $7eab1b, $fffa566c, $0
	.dc.s	$78ffff, $fffb8000, $ff9fffff, $0
	.dc.s	$c0363deb, $fd0055ea, $b8615, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe28000, $ffb643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe28000, $ffbab6a1, $0
	.dc.s	$40000000, $ffffffc3, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $ffcfffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe28000, $ffb643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ffcfffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $ff9fffff, $0
	.dc.s	$40000000, $fffffff2, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $ffbab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $fff80000, $ffbab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $ffcfffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe28000, $ffb643d6, $0
	.dc.s	$40000000, $ffffffc5, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ff9fffff, $0
	.dc.s	$40000000, $fffffff2, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe18000, $ffcfffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe28000, $ffbab6a1, $0
	.dc.s	$40000000, $ffffffc3, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $ffbab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe68000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ff9fffff, $0
	.dc.s	$40000000, $fffffff2, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffee0000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffe18000, $ff9fffff, $0
	.dc.s	$40000000, $fffffff2, $ffffffa0, $0
	.dc.s	$779999, $fffb0000, $ff9fffff, $0
	.dc.s	$40000000, $5, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $ffbab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffe68000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffee0000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $ffe68000, $ffbab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffee0000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$779999, $ffee0000, $ffbab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fff80000, $ffbab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fff80000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffff9f, $0
	.dc.s	$779999, $fffb0000, $ff9fffff, $0
	.dc.s	$40000000, $5, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fff80000, $ffbab6a1, $0
	.dc.s	$40000000, $7, $ffffffa2, $0
	.dc.s	$779999, $fffb0000, $ff9fffff, $0
	.dc.s	$40000000, $5, $ffffffa0, $0
	.dc.s	$779999, $fffb0000, $ffcfffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $ff9fffff, $0
	.dc.s	$40000000, $5, $ffffffa0, $0
	.dc.s	$779999, $fff80000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffff9f, $0
	.dc.s	$779999, $ffee0000, $ffb643d6, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $ffcfffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $ffe18000, $ffcfffff, $0
	.dc.s	$40000000, $ffffffe3, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $ffbab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$779999, $fffb0000, $ffcfffff, $0
	.dc.s	$40000000, $6, $ffffffa2, $0
	.dc.s	$779999, $ffe68000, $ffbab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	$779999, $ffee0000, $ffbab6a1, $0
	.dc.s	$40000000, $0, $ffffffa3, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ff9fffff, $0
	.dc.s	$c0000000, $10, $60, $0
	.dc.s	$77ffff, $ffe18000, $ffcfffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$780000, $ffe28000, $ffbab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ff9fffff, $0
	.dc.s	$c0000000, $10, $60, $0
	.dc.s	$780000, $ffe28000, $ffbab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	$780000, $ffe28000, $ffb643d6, $0
	.dc.s	$c0000000, $ffffffff, $61, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffcfffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $ffbab6a1, $0
	.dc.s	$c0000000, $ffffffec, $5e, $0
	.dc.s	$780000, $ffee0000, $ffbab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $ffe18000, $ff9fffff, $0
	.dc.s	$c0000000, $10, $60, $0
	.dc.s	$780000, $ffe28000, $ffb643d6, $0
	.dc.s	$c0000000, $ffffffff, $61, $0
	.dc.s	$780000, $ffe68000, $ffb643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffe68000, $ffbab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe28000, $ffbab6a1, $0
	.dc.s	$c0000000, $16, $5e, $0
	.dc.s	$77ffff, $ffe18000, $ffcfffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $fffffffd, $40, $0
	.dc.s	$77ffff, $ffe18000, $ff9fffff, $0
	.dc.s	$c0000000, $10, $60, $0
	.dc.s	$780000, $ffe68000, $ffb643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $fffffffd, $40, $0
	.dc.s	$780000, $ffe68000, $ffb643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffee0000, $ffb643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffbab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffee0000, $ffb643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffe68000, $ffb643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffbab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe68000, $ffb643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $ffe68000, $ffbab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffcfffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $fffffffd, $40, $0
	.dc.s	$780000, $fff80000, $ffb643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$77ffff, $fffb0000, $ffcfffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	$780000, $fff80000, $ffb643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	$780000, $fff80000, $ffbab6a1, $0
	.dc.s	$c0000000, $ffffffec, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffb643d6, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$780000, $fff80000, $ffb643d6, $0
	.dc.s	$c0000000, $ffffffec, $60, $0
	.dc.s	$77ffff, $fffb0000, $ff9fffff, $0
	.dc.s	$c0000000, $fffffffd, $40, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffbab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$780000, $ffe68000, $ffbab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$77ffff, $ffe18000, $ffcfffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	3,_material_0xfdcd9d,0,1
	.dc.s	$780000, $ffee0000, $ffbab6a1, $0
	.dc.s	$c0000000, $0, $5d, $0
	.dc.s	$77ffff, $ffe18000, $ffcfffff, $0
	.dc.s	$c0000000, $11, $5e, $0
	.dc.s	$77ffff, $fffb0000, $ffcfffff, $0
	.dc.s	$c0000000, $fffffff6, $5e, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1eb, $ffe7ffd9, $ff9fffff, $0
	.dc.s	$1b0ac, $3ffffffa, $0, $0
	.dc.s	$76c196, $ffe7ffe6, $ff9fffff, $0
	.dc.s	$1b0ac, $3ffffffa, $0, $0
	.dc.s	$76c197, $ffe7ffe6, $5fffff, $0
	.dc.s	$1b0ac, $3ffffffa, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1eb, $ffe7ffd9, $ff9fffff, $0
	.dc.s	$1b0ac, $3ffffffa, $0, $0
	.dc.s	$76c197, $ffe7ffe6, $5fffff, $0
	.dc.s	$1b0ac, $3ffffffa, $0, $0
	.dc.s	$78b1ec, $ffe7ffd9, $5fffff, $0
	.dc.s	$1b0ac, $3ffffffa, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$77126e, $ffe82db9, $ff9fffff, $0
	.dc.s	$1dfa4405, $c782c659, $ffffffd4, $0
	.dc.s	$77126f, $ffe82db9, $5fffff, $0
	.dc.s	$1c656b4c, $c6b316ed, $ffffffd6, $0
	.dc.s	$76c197, $ffe7ffe6, $5fffff, $0
	.dc.s	$1f8f1cbd, $c85275c6, $ffffffd2, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$77126e, $ffe82db9, $ff9fffff, $0
	.dc.s	$1dfa4405, $c782c659, $ffffffd4, $0
	.dc.s	$76c197, $ffe7ffe6, $5fffff, $0
	.dc.s	$1f8f1cbd, $c85275c6, $ffffffd2, $0
	.dc.s	$76c196, $ffe7ffe6, $ff9fffff, $0
	.dc.s	$1f8f1cbd, $c85275c6, $ffffffd2, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$773844, $ffe83f2e, $ff9fffff, $0
	.dc.s	$1ad09294, $c5e36781, $ffffffd9, $0
	.dc.s	$773845, $ffe83f2e, $5fffff, $0
	.dc.s	$1ad09294, $c5e36781, $ffffffd9, $0
	.dc.s	$77126f, $ffe82db9, $5fffff, $0
	.dc.s	$1c656b4c, $c6b316ed, $ffffffd6, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$773844, $ffe83f2e, $ff9fffff, $0
	.dc.s	$1ad09294, $c5e36781, $ffffffd9, $0
	.dc.s	$77126f, $ffe82db9, $5fffff, $0
	.dc.s	$1c656b4c, $c6b316ed, $ffffffd6, $0
	.dc.s	$77126e, $ffe82db9, $ff9fffff, $0
	.dc.s	$1dfa4405, $c782c659, $ffffffd4, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$773e35, $ffe85cee, $ff9fffff, $0
	.dc.s	$32404fd3, $dfe41031, $ffffffb6, $0
	.dc.s	$773e36, $ffe85cee, $5fffff, $0
	.dc.s	$32404fd3, $dfe41031, $ffffffb6, $0
	.dc.s	$773845, $ffe83f2e, $5fffff, $0
	.dc.s	$3ec2e582, $f37826c7, $ffffffa4, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$773e35, $ffe85cee, $ff9fffff, $0
	.dc.s	$32404fd3, $dfe41031, $ffffffb6, $0
	.dc.s	$773845, $ffe83f2e, $5fffff, $0
	.dc.s	$3ec2e582, $f37826c7, $ffffffa4, $0
	.dc.s	$773844, $ffe83f2e, $ff9fffff, $0
	.dc.s	$3ec2e582, $f37826c7, $ffffffa4, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$773e35, $ffe85cee, $ff9fffff, $0
	.dc.s	$32404fd3, $dfe41031, $ffffffb6, $0
	.dc.s	$776978, $ffe87c85, $ff9fffff, $0
	.dc.s	$12e543ba, $c627fd71, $ffffffe4, $0
	.dc.s	$776979, $ffe87c85, $5fffff, $0
	.dc.s	$12e543ba, $c627fd71, $ffffffe4, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$773e35, $ffe85cee, $ff9fffff, $0
	.dc.s	$32404fd3, $dfe41031, $ffffffb6, $0
	.dc.s	$776979, $ffe87c85, $5fffff, $0
	.dc.s	$12e543ba, $c627fd71, $ffffffe4, $0
	.dc.s	$773e36, $ffe85cee, $5fffff, $0
	.dc.s	$32404fd3, $dfe41031, $ffffffb6, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b119, $ffe87cc6, $ff9fffff, $0
	.dc.s	$ccd50, $c0000148, $0, $0
	.dc.s	$78b11a, $ffe87cc6, $5fffff, $0
	.dc.s	$ccd50, $c0000148, $0, $0
	.dc.s	$776979, $ffe87c85, $5fffff, $0
	.dc.s	$12e543ba, $c627fd71, $ffffffe4, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b119, $ffe87cc6, $ff9fffff, $0
	.dc.s	$ccd50, $c0000148, $0, $0
	.dc.s	$776979, $ffe87c85, $5fffff, $0
	.dc.s	$12e543ba, $c627fd71, $ffffffe4, $0
	.dc.s	$776978, $ffe87c85, $ff9fffff, $0
	.dc.s	$12e543ba, $c627fd71, $ffffffe4, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1eb, $ffe7ffd9, $ff9fffff, $0
	.dc.s	$7f, $ffffff87, $40000000, $0
	.dc.s	$78b119, $ffe87cc6, $ff9fffff, $0
	.dc.s	$a8, $1, $40000000, $0
	.dc.s	$776978, $ffe87c85, $ff9fffff, $0
	.dc.s	$8b, $ffffffb5, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1eb, $ffe7ffd9, $ff9fffff, $0
	.dc.s	$7f, $ffffff87, $40000000, $0
	.dc.s	$776978, $ffe87c85, $ff9fffff, $0
	.dc.s	$8b, $ffffffb5, $40000000, $0
	.dc.s	$773e35, $ffe85cee, $ff9fffff, $0
	.dc.s	$7d, $ffffffa7, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1eb, $ffe7ffd9, $ff9fffff, $0
	.dc.s	$7f, $ffffff87, $40000000, $0
	.dc.s	$773e35, $ffe85cee, $ff9fffff, $0
	.dc.s	$7d, $ffffffa7, $40000000, $0
	.dc.s	$773844, $ffe83f2e, $ff9fffff, $0
	.dc.s	$7c, $ffffff7e, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1eb, $ffe7ffd9, $ff9fffff, $0
	.dc.s	$7f, $ffffff87, $40000000, $0
	.dc.s	$773844, $ffe83f2e, $ff9fffff, $0
	.dc.s	$7c, $ffffff7e, $40000000, $0
	.dc.s	$77126e, $ffe82db9, $ff9fffff, $0
	.dc.s	$6d, $ffffff2b, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1eb, $ffe7ffd9, $ff9fffff, $0
	.dc.s	$7f, $ffffff87, $40000000, $0
	.dc.s	$77126e, $ffe82db9, $ff9fffff, $0
	.dc.s	$6d, $ffffff2b, $40000000, $0
	.dc.s	$76c196, $ffe7ffe6, $ff9fffff, $0
	.dc.s	$6f, $ffffff3d, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1ec, $ffe7ffd9, $5fffff, $0
	.dc.s	$ffffff81, $79, $c0000000, $0
	.dc.s	$76c197, $ffe7ffe6, $5fffff, $0
	.dc.s	$ffffff91, $c3, $c0000000, $0
	.dc.s	$77126f, $ffe82db9, $5fffff, $0
	.dc.s	$ffffff93, $d5, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1ec, $ffe7ffd9, $5fffff, $0
	.dc.s	$ffffff81, $79, $c0000000, $0
	.dc.s	$77126f, $ffe82db9, $5fffff, $0
	.dc.s	$ffffff93, $d5, $c0000000, $0
	.dc.s	$773845, $ffe83f2e, $5fffff, $0
	.dc.s	$ffffff84, $82, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1ec, $ffe7ffd9, $5fffff, $0
	.dc.s	$ffffff81, $79, $c0000000, $0
	.dc.s	$773845, $ffe83f2e, $5fffff, $0
	.dc.s	$ffffff84, $82, $c0000000, $0
	.dc.s	$773e36, $ffe85cee, $5fffff, $0
	.dc.s	$ffffff83, $59, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1ec, $ffe7ffd9, $5fffff, $0
	.dc.s	$ffffff81, $79, $c0000000, $0
	.dc.s	$773e36, $ffe85cee, $5fffff, $0
	.dc.s	$ffffff83, $59, $c0000000, $0
	.dc.s	$776979, $ffe87c85, $5fffff, $0
	.dc.s	$ffffff75, $4b, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1ec, $ffe7ffd9, $5fffff, $0
	.dc.s	$ffffff81, $79, $c0000000, $0
	.dc.s	$776979, $ffe87c85, $5fffff, $0
	.dc.s	$ffffff75, $4b, $c0000000, $0
	.dc.s	$78b11a, $ffe87cc6, $5fffff, $0
	.dc.s	$ffffff58, $ffffffff, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1ec, $ffe7ffd9, $5fffff, $0
	.dc.s	$c0005a2c, $ff9490f5, $5e, $0
	.dc.s	$78b11a, $ffe87cc6, $5fffff, $0
	.dc.s	$c0005a2c, $ff9490f5, $5e, $0
	.dc.s	$78b119, $ffe87cc6, $ff9fffff, $0
	.dc.s	$c0005a2c, $ff9490f5, $5e, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$78b1ec, $ffe7ffd9, $5fffff, $0
	.dc.s	$c0005a2c, $ff9490f5, $5e, $0
	.dc.s	$78b119, $ffe87cc6, $ff9fffff, $0
	.dc.s	$c0005a2c, $ff9490f5, $5e, $0
	.dc.s	$78b1eb, $ffe7ffd9, $ff9fffff, $0
	.dc.s	$c0005a2c, $ff9490f5, $5e, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $60b1eb, $0
	.dc.s	$0, $3ffffffa, $1b0ac, $0
	.dc.s	$780001, $ffe7ffe6, $5ec195, $0
	.dc.s	$0, $3ffffffa, $1b0ac, $0
	.dc.s	$ff880001, $ffe7ffe6, $5ec197, $0
	.dc.s	$0, $3ffffffa, $1b0ac, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $60b1eb, $0
	.dc.s	$0, $3ffffffa, $1b0ac, $0
	.dc.s	$ff880001, $ffe7ffe6, $5ec197, $0
	.dc.s	$0, $3ffffffa, $1b0ac, $0
	.dc.s	$ff880001, $ffe7ffd9, $60b1ec, $0
	.dc.s	$0, $3ffffffa, $1b0ac, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe82db9, $5f126e, $0
	.dc.s	$3c, $c782c659, $1dfa4405, $0
	.dc.s	$ff880001, $ffe82db9, $5f1270, $0
	.dc.s	$39, $c6b316ed, $1c656b4c, $0
	.dc.s	$ff880001, $ffe7ffe6, $5ec197, $0
	.dc.s	$40, $c85275c6, $1f8f1cbd, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe82db9, $5f126e, $0
	.dc.s	$3c, $c782c659, $1dfa4405, $0
	.dc.s	$ff880001, $ffe7ffe6, $5ec197, $0
	.dc.s	$40, $c85275c6, $1f8f1cbd, $0
	.dc.s	$780001, $ffe7ffe6, $5ec195, $0
	.dc.s	$40, $c85275c6, $1f8f1cbd, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe83f2e, $5f3844, $0
	.dc.s	$36, $c5e36781, $1ad09294, $0
	.dc.s	$ff880001, $ffe83f2e, $5f3846, $0
	.dc.s	$36, $c5e36781, $1ad09294, $0
	.dc.s	$ff880001, $ffe82db9, $5f1270, $0
	.dc.s	$39, $c6b316ed, $1c656b4c, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe83f2e, $5f3844, $0
	.dc.s	$36, $c5e36781, $1ad09294, $0
	.dc.s	$ff880001, $ffe82db9, $5f1270, $0
	.dc.s	$39, $c6b316ed, $1c656b4c, $0
	.dc.s	$780001, $ffe82db9, $5f126e, $0
	.dc.s	$3c, $c782c659, $1dfa4405, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe85cee, $5f3e34, $0
	.dc.s	$65, $dfe41031, $32404fd3, $0
	.dc.s	$ff880001, $ffe85cee, $5f3e36, $0
	.dc.s	$65, $dfe41031, $32404fd3, $0
	.dc.s	$ff880001, $ffe83f2e, $5f3846, $0
	.dc.s	$7e, $f37826c7, $3ec2e582, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe85cee, $5f3e34, $0
	.dc.s	$65, $dfe41031, $32404fd3, $0
	.dc.s	$ff880001, $ffe83f2e, $5f3846, $0
	.dc.s	$7e, $f37826c7, $3ec2e582, $0
	.dc.s	$780001, $ffe83f2e, $5f3844, $0
	.dc.s	$7e, $f37826c7, $3ec2e582, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe85cee, $5f3e34, $0
	.dc.s	$65, $dfe41031, $32404fd3, $0
	.dc.s	$780001, $ffe87c85, $5f6978, $0
	.dc.s	$26, $c627fd71, $12e543ba, $0
	.dc.s	$ff880001, $ffe87c85, $5f697a, $0
	.dc.s	$26, $c627fd71, $12e543ba, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe85cee, $5f3e34, $0
	.dc.s	$65, $dfe41031, $32404fd3, $0
	.dc.s	$ff880001, $ffe87c85, $5f697a, $0
	.dc.s	$26, $c627fd71, $12e543ba, $0
	.dc.s	$ff880001, $ffe85cee, $5f3e36, $0
	.dc.s	$65, $dfe41031, $32404fd3, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe87cc6, $60b119, $0
	.dc.s	$0, $c0000148, $ccd50, $0
	.dc.s	$ff880001, $ffe87cc6, $60b11b, $0
	.dc.s	$0, $c0000148, $ccd50, $0
	.dc.s	$ff880001, $ffe87c85, $5f697a, $0
	.dc.s	$26, $c627fd71, $12e543ba, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe87cc6, $60b119, $0
	.dc.s	$0, $c0000148, $ccd50, $0
	.dc.s	$ff880001, $ffe87c85, $5f697a, $0
	.dc.s	$26, $c627fd71, $12e543ba, $0
	.dc.s	$780001, $ffe87c85, $5f6978, $0
	.dc.s	$26, $c627fd71, $12e543ba, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $60b1eb, $0
	.dc.s	$c0000000, $ffffff87, $7f, $0
	.dc.s	$780001, $ffe87cc6, $60b119, $0
	.dc.s	$c0000000, $1, $a8, $0
	.dc.s	$780001, $ffe87c85, $5f6978, $0
	.dc.s	$c0000000, $ffffffb5, $8b, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $60b1eb, $0
	.dc.s	$c0000000, $ffffff87, $7f, $0
	.dc.s	$780001, $ffe87c85, $5f6978, $0
	.dc.s	$c0000000, $ffffffb5, $8b, $0
	.dc.s	$780001, $ffe85cee, $5f3e34, $0
	.dc.s	$c0000000, $ffffffa7, $7d, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $60b1eb, $0
	.dc.s	$c0000000, $ffffff87, $7f, $0
	.dc.s	$780001, $ffe85cee, $5f3e34, $0
	.dc.s	$c0000000, $ffffffa7, $7d, $0
	.dc.s	$780001, $ffe83f2e, $5f3844, $0
	.dc.s	$c0000000, $ffffff7e, $7c, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $60b1eb, $0
	.dc.s	$c0000000, $ffffff87, $7f, $0
	.dc.s	$780001, $ffe83f2e, $5f3844, $0
	.dc.s	$c0000000, $ffffff7e, $7c, $0
	.dc.s	$780001, $ffe82db9, $5f126e, $0
	.dc.s	$c0000000, $ffffff2b, $6d, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $60b1eb, $0
	.dc.s	$c0000000, $ffffff87, $7f, $0
	.dc.s	$780001, $ffe82db9, $5f126e, $0
	.dc.s	$c0000000, $ffffff2b, $6d, $0
	.dc.s	$780001, $ffe7ffe6, $5ec195, $0
	.dc.s	$c0000000, $ffffff3d, $6f, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $60b1ec, $0
	.dc.s	$40000000, $79, $ffffff81, $0
	.dc.s	$ff880001, $ffe7ffe6, $5ec197, $0
	.dc.s	$40000000, $c3, $ffffff91, $0
	.dc.s	$ff880001, $ffe82db9, $5f1270, $0
	.dc.s	$40000000, $d5, $ffffff93, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $60b1ec, $0
	.dc.s	$40000000, $79, $ffffff81, $0
	.dc.s	$ff880001, $ffe82db9, $5f1270, $0
	.dc.s	$40000000, $d5, $ffffff93, $0
	.dc.s	$ff880001, $ffe83f2e, $5f3846, $0
	.dc.s	$40000000, $82, $ffffff84, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $60b1ec, $0
	.dc.s	$40000000, $79, $ffffff81, $0
	.dc.s	$ff880001, $ffe83f2e, $5f3846, $0
	.dc.s	$40000000, $82, $ffffff84, $0
	.dc.s	$ff880001, $ffe85cee, $5f3e36, $0
	.dc.s	$40000000, $59, $ffffff83, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $60b1ec, $0
	.dc.s	$40000000, $79, $ffffff81, $0
	.dc.s	$ff880001, $ffe85cee, $5f3e36, $0
	.dc.s	$40000000, $59, $ffffff83, $0
	.dc.s	$ff880001, $ffe87c85, $5f697a, $0
	.dc.s	$40000000, $4b, $ffffff75, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $60b1ec, $0
	.dc.s	$40000000, $79, $ffffff81, $0
	.dc.s	$ff880001, $ffe87c85, $5f697a, $0
	.dc.s	$40000000, $4b, $ffffff75, $0
	.dc.s	$ff880001, $ffe87cc6, $60b11b, $0
	.dc.s	$40000000, $ffffffff, $ffffff58, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $60b1ec, $0
	.dc.s	$ffffff7f, $ff9490f5, $c0005a2c, $0
	.dc.s	$ff880001, $ffe87cc6, $60b11b, $0
	.dc.s	$ffffff7f, $ff9490f5, $c0005a2c, $0
	.dc.s	$780001, $ffe87cc6, $60b119, $0
	.dc.s	$ffffff7f, $ff9490f5, $c0005a2c, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $60b1ec, $0
	.dc.s	$ffffff7f, $ff9490f5, $c0005a2c, $0
	.dc.s	$780001, $ffe87cc6, $60b119, $0
	.dc.s	$ffffff7f, $ff9490f5, $c0005a2c, $0
	.dc.s	$780001, $ffe7ffd9, $60b1eb, $0
	.dc.s	$ffffff7f, $ff9490f5, $c0005a2c, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $ff9f4e14, $0
	.dc.s	$0, $3ffffffa, $fffe4f54, $0
	.dc.s	$ff880001, $ffe7ffe6, $ffa13e69, $0
	.dc.s	$0, $3ffffffa, $fffe4f54, $0
	.dc.s	$780001, $ffe7ffe6, $ffa13e6b, $0
	.dc.s	$0, $3ffffffa, $fffe4f54, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $ff9f4e14, $0
	.dc.s	$0, $3ffffffa, $fffe4f54, $0
	.dc.s	$780001, $ffe7ffe6, $ffa13e6b, $0
	.dc.s	$0, $3ffffffa, $fffe4f54, $0
	.dc.s	$780001, $ffe7ffd9, $ff9f4e15, $0
	.dc.s	$0, $3ffffffa, $fffe4f54, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe82db9, $ffa0ed90, $0
	.dc.s	$3c, $c782c659, $e205bbfb, $0
	.dc.s	$780001, $ffe82db9, $ffa0ed92, $0
	.dc.s	$39, $c6b316ed, $e39a94b4, $0
	.dc.s	$780001, $ffe7ffe6, $ffa13e6b, $0
	.dc.s	$40, $c85275c6, $e070e343, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe82db9, $ffa0ed90, $0
	.dc.s	$3c, $c782c659, $e205bbfb, $0
	.dc.s	$780001, $ffe7ffe6, $ffa13e6b, $0
	.dc.s	$40, $c85275c6, $e070e343, $0
	.dc.s	$ff880001, $ffe7ffe6, $ffa13e69, $0
	.dc.s	$40, $c85275c6, $e070e343, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe83f2e, $ffa0c7ba, $0
	.dc.s	$36, $c5e36781, $e52f6d6c, $0
	.dc.s	$780001, $ffe83f2e, $ffa0c7bc, $0
	.dc.s	$36, $c5e36781, $e52f6d6c, $0
	.dc.s	$780001, $ffe82db9, $ffa0ed92, $0
	.dc.s	$39, $c6b316ed, $e39a94b4, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe83f2e, $ffa0c7ba, $0
	.dc.s	$36, $c5e36781, $e52f6d6c, $0
	.dc.s	$780001, $ffe82db9, $ffa0ed92, $0
	.dc.s	$39, $c6b316ed, $e39a94b4, $0
	.dc.s	$ff880001, $ffe82db9, $ffa0ed90, $0
	.dc.s	$3c, $c782c659, $e205bbfb, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe85cee, $ffa0c1ca, $0
	.dc.s	$65, $dfe41031, $cdbfb02d, $0
	.dc.s	$780001, $ffe85cee, $ffa0c1cc, $0
	.dc.s	$65, $dfe41031, $cdbfb02d, $0
	.dc.s	$780001, $ffe83f2e, $ffa0c7bc, $0
	.dc.s	$7e, $f37826c7, $c13d1a7e, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe85cee, $ffa0c1ca, $0
	.dc.s	$65, $dfe41031, $cdbfb02d, $0
	.dc.s	$780001, $ffe83f2e, $ffa0c7bc, $0
	.dc.s	$7e, $f37826c7, $c13d1a7e, $0
	.dc.s	$ff880001, $ffe83f2e, $ffa0c7ba, $0
	.dc.s	$7e, $f37826c7, $c13d1a7e, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe85cee, $ffa0c1ca, $0
	.dc.s	$65, $dfe41031, $cdbfb02d, $0
	.dc.s	$ff880001, $ffe87c85, $ffa09686, $0
	.dc.s	$26, $c627fd71, $ed1abc46, $0
	.dc.s	$780001, $ffe87c85, $ffa09688, $0
	.dc.s	$26, $c627fd71, $ed1abc46, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe85cee, $ffa0c1ca, $0
	.dc.s	$65, $dfe41031, $cdbfb02d, $0
	.dc.s	$780001, $ffe87c85, $ffa09688, $0
	.dc.s	$26, $c627fd71, $ed1abc46, $0
	.dc.s	$780001, $ffe85cee, $ffa0c1cc, $0
	.dc.s	$65, $dfe41031, $cdbfb02d, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe87cc6, $ff9f4ee5, $0
	.dc.s	$0, $c0000148, $fff332b0, $0
	.dc.s	$780001, $ffe87cc6, $ff9f4ee7, $0
	.dc.s	$0, $c0000148, $fff332b0, $0
	.dc.s	$780001, $ffe87c85, $ffa09688, $0
	.dc.s	$26, $c627fd71, $ed1abc46, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe87cc6, $ff9f4ee5, $0
	.dc.s	$0, $c0000148, $fff332b0, $0
	.dc.s	$780001, $ffe87c85, $ffa09688, $0
	.dc.s	$26, $c627fd71, $ed1abc46, $0
	.dc.s	$ff880001, $ffe87c85, $ffa09686, $0
	.dc.s	$26, $c627fd71, $ed1abc46, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $ff9f4e14, $0
	.dc.s	$40000000, $79, $7f, $0
	.dc.s	$ff880001, $ffe87cc6, $ff9f4ee5, $0
	.dc.s	$40000000, $ffffffff, $a8, $0
	.dc.s	$ff880001, $ffe87c85, $ffa09686, $0
	.dc.s	$40000000, $4b, $8b, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $ff9f4e14, $0
	.dc.s	$40000000, $79, $7f, $0
	.dc.s	$ff880001, $ffe87c85, $ffa09686, $0
	.dc.s	$40000000, $4b, $8b, $0
	.dc.s	$ff880001, $ffe85cee, $ffa0c1ca, $0
	.dc.s	$40000000, $59, $7d, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $ff9f4e14, $0
	.dc.s	$40000000, $79, $7f, $0
	.dc.s	$ff880001, $ffe85cee, $ffa0c1ca, $0
	.dc.s	$40000000, $59, $7d, $0
	.dc.s	$ff880001, $ffe83f2e, $ffa0c7ba, $0
	.dc.s	$40000000, $82, $7c, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $ff9f4e14, $0
	.dc.s	$40000000, $79, $7f, $0
	.dc.s	$ff880001, $ffe83f2e, $ffa0c7ba, $0
	.dc.s	$40000000, $82, $7c, $0
	.dc.s	$ff880001, $ffe82db9, $ffa0ed90, $0
	.dc.s	$40000000, $d5, $6d, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff880001, $ffe7ffd9, $ff9f4e14, $0
	.dc.s	$40000000, $79, $7f, $0
	.dc.s	$ff880001, $ffe82db9, $ffa0ed90, $0
	.dc.s	$40000000, $d5, $6d, $0
	.dc.s	$ff880001, $ffe7ffe6, $ffa13e69, $0
	.dc.s	$40000000, $c3, $6f, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $ff9f4e15, $0
	.dc.s	$c0000000, $ffffff87, $ffffff81, $0
	.dc.s	$780001, $ffe7ffe6, $ffa13e6b, $0
	.dc.s	$c0000000, $ffffff3d, $ffffff91, $0
	.dc.s	$780001, $ffe82db9, $ffa0ed92, $0
	.dc.s	$c0000000, $ffffff2b, $ffffff93, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $ff9f4e15, $0
	.dc.s	$c0000000, $ffffff87, $ffffff81, $0
	.dc.s	$780001, $ffe82db9, $ffa0ed92, $0
	.dc.s	$c0000000, $ffffff2b, $ffffff93, $0
	.dc.s	$780001, $ffe83f2e, $ffa0c7bc, $0
	.dc.s	$c0000000, $ffffff7e, $ffffff84, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $ff9f4e15, $0
	.dc.s	$c0000000, $ffffff87, $ffffff81, $0
	.dc.s	$780001, $ffe83f2e, $ffa0c7bc, $0
	.dc.s	$c0000000, $ffffff7e, $ffffff84, $0
	.dc.s	$780001, $ffe85cee, $ffa0c1cc, $0
	.dc.s	$c0000000, $ffffffa7, $ffffff83, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $ff9f4e15, $0
	.dc.s	$c0000000, $ffffff87, $ffffff81, $0
	.dc.s	$780001, $ffe85cee, $ffa0c1cc, $0
	.dc.s	$c0000000, $ffffffa7, $ffffff83, $0
	.dc.s	$780001, $ffe87c85, $ffa09688, $0
	.dc.s	$c0000000, $ffffffb5, $ffffff75, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $ff9f4e15, $0
	.dc.s	$c0000000, $ffffff87, $ffffff81, $0
	.dc.s	$780001, $ffe87c85, $ffa09688, $0
	.dc.s	$c0000000, $ffffffb5, $ffffff75, $0
	.dc.s	$780001, $ffe87cc6, $ff9f4ee7, $0
	.dc.s	$c0000000, $1, $ffffff58, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $ff9f4e15, $0
	.dc.s	$ffffff7f, $ff9490f5, $3fffa5d4, $0
	.dc.s	$780001, $ffe87cc6, $ff9f4ee7, $0
	.dc.s	$ffffff7f, $ff9490f5, $3fffa5d4, $0
	.dc.s	$ff880001, $ffe87cc6, $ff9f4ee5, $0
	.dc.s	$ffffff7f, $ff9490f5, $3fffa5d4, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$780001, $ffe7ffd9, $ff9f4e15, $0
	.dc.s	$ffffff7f, $ff9490f5, $3fffa5d4, $0
	.dc.s	$ff880001, $ffe87cc6, $ff9f4ee5, $0
	.dc.s	$ffffff7f, $ff9490f5, $3fffa5d4, $0
	.dc.s	$ff880001, $ffe7ffd9, $ff9f4e14, $0
	.dc.s	$ffffff7f, $ff9490f5, $3fffa5d4, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc313d0, $ffe06ccd, $9354d7, $0
	.dc.s	$d1d106aa, $faa4aa0f, $29e2d036, $0
	.dc.s	$ffc75a44, $ffd29b7f, $928083, $0
	.dc.s	$cec19250, $ee8b87e2, $24f6e2aa, $0
	.dc.s	$ffc5d34d, $ffde97b5, $962083, $0
	.dc.s	$d0e71f39, $fde473dd, $2999673a, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc3aa09, $ffee6fc9, $91daa0, $0
	.dc.s	$d112fd76, $7be7eae, $2a81a985, $0
	.dc.s	$ffc313d0, $ffe06ccd, $9354d7, $0
	.dc.s	$d1d106aa, $faa4aa0f, $29e2d036, $0
	.dc.s	$ffc5d34d, $ffde97b5, $962083, $0
	.dc.s	$d0e71f39, $fde473dd, $2999673a, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc3aa09, $ffee6fc9, $91daa0, $0
	.dc.s	$d112fd76, $7be7eae, $2a81a985, $0
	.dc.s	$ffc5d34d, $ffde97b5, $962083, $0
	.dc.s	$d0e71f39, $fde473dd, $2999673a, $0
	.dc.s	$ffc7502e, $ffef16a4, $9622c4, $0
	.dc.s	$ce7155b5, $9283711, $2740f30a, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc6c8dc, $fff85580, $92aaf5, $0
	.dc.s	$cd89faf2, $95067d5, $2613eef8, $0
	.dc.s	$ffc3aa09, $ffee6fc9, $91daa0, $0
	.dc.s	$d112fd76, $7be7eae, $2a81a985, $0
	.dc.s	$ffc7502e, $ffef16a4, $9622c4, $0
	.dc.s	$ce7155b5, $9283711, $2740f30a, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc6c8dc, $fff85580, $92aaf5, $0
	.dc.s	$cd89faf2, $95067d5, $2613eef8, $0
	.dc.s	$ffc7502e, $ffef16a4, $9622c4, $0
	.dc.s	$ce7155b5, $9283711, $2740f30a, $0
	.dc.s	$ffc71e6a, $fff85580, $9320c5, $0
	.dc.s	$ccac61e7, $7ebc795, $254611af, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc75a44, $ffffa53c, $928083, $0
	.dc.s	$cc5d400e, $4dc99c4, $257f890e, $0
	.dc.s	$ffc6c8dc, $fff85580, $92aaf5, $0
	.dc.s	$cd89faf2, $95067d5, $2613eef8, $0
	.dc.s	$ffc71e6a, $fff85580, $9320c5, $0
	.dc.s	$ccac61e7, $7ebc795, $254611af, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc5d34d, $ffde97b5, $962083, $0
	.dc.s	$1e6f3c02, $f81e9bc1, $37831d40, $0
	.dc.s	$ffc75a44, $ffd29b7f, $928083, $0
	.dc.s	$1dad496c, $f3150abd, $37366175, $0
	.dc.s	$ffca90cb, $ffde09fc, $937319, $0
	.dc.s	$232d3345, $fb2e0261, $34484b19, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc7502e, $ffef16a4, $9622c4, $0
	.dc.s	$28796a38, $468554b, $300692bf, $0
	.dc.s	$ffc5d34d, $ffde97b5, $962083, $0
	.dc.s	$1e6f3c02, $f81e9bc1, $37831d40, $0
	.dc.s	$ffca90cb, $ffde09fc, $937319, $0
	.dc.s	$232d3345, $fb2e0261, $34484b19, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc7502e, $ffef16a4, $9622c4, $0
	.dc.s	$28796a38, $468554b, $300692bf, $0
	.dc.s	$ffca90cb, $ffde09fc, $937319, $0
	.dc.s	$232d3345, $fb2e0261, $34484b19, $0
	.dc.s	$ffcac60b, $ffee0404, $92cb29, $0
	.dc.s	$2ea40cf0, $ad301c8, $29b40c0e, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffca90cb, $ffde09fc, $937319, $0
	.dc.s	$3deb8958, $f7a37e7c, $f543c8bc, $0
	.dc.s	$ffc75a44, $ffd29b7f, $928083, $0
	.dc.s	$3c264816, $f05c573c, $f0b89833, $0
	.dc.s	$ffca3e84, $ffe071aa, $8fb8fc, $0
	.dc.s	$3deb8958, $f7a37e7c, $f543c8bc, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffca90cb, $ffde09fc, $937319, $0
	.dc.s	$3deb8958, $f7a37e7c, $f543c8bc, $0
	.dc.s	$ffca3e84, $ffe071aa, $8fb8fc, $0
	.dc.s	$3deb8958, $f7a37e7c, $f543c8bc, $0
	.dc.s	$ffcac60b, $ffee0404, $92cb29, $0
	.dc.s	$3fb0ca9a, $feeaa5bb, $f9cef945, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffca3e84, $ffe071aa, $8fb8fc, $0
	.dc.s	$deba315, $ff310532, $c327b6b0, $0
	.dc.s	$ffc75a44, $ffd29b7f, $928083, $0
	.dc.s	$b0096d4, $f161a1da, $c2abc737, $0
	.dc.s	$ffc63c50, $ffe152d7, $8ecb36, $0
	.dc.s	$16a00e33, $ffeec529, $c6cca4bd, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffcac60b, $ffee0404, $92cb29, $0
	.dc.s	$1ff9158b, $7f4a95f, $caa2a90a, $0
	.dc.s	$ffca3e84, $ffe071aa, $8fb8fc, $0
	.dc.s	$deba315, $ff310532, $c327b6b0, $0
	.dc.s	$ffc63c50, $ffe152d7, $8ecb36, $0
	.dc.s	$16a00e33, $ffeec529, $c6cca4bd, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffcac60b, $ffee0404, $92cb29, $0
	.dc.s	$1ff9158b, $7f4a95f, $caa2a90a, $0
	.dc.s	$ffc63c50, $ffe152d7, $8ecb36, $0
	.dc.s	$16a00e33, $ffeec529, $c6cca4bd, $0
	.dc.s	$ffc644b6, $ffed8093, $8f2a58, $0
	.dc.s	$29268eac, $61d9dfd, $cf95e3d3, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc7b375, $fff85580, $9257c2, $0
	.dc.s	$2ab6d8ff, $6af95ac, $d0ffca44, $0
	.dc.s	$ffcac60b, $ffee0404, $92cb29, $0
	.dc.s	$1ff9158b, $7f4a95f, $caa2a90a, $0
	.dc.s	$ffc644b6, $ffed8093, $8f2a58, $0
	.dc.s	$29268eac, $61d9dfd, $cf95e3d3, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc7b375, $fff85580, $9257c2, $0
	.dc.s	$2ab6d8ff, $6af95ac, $d0ffca44, $0
	.dc.s	$ffc644b6, $ffed8093, $8f2a58, $0
	.dc.s	$29268eac, $61d9dfd, $cf95e3d3, $0
	.dc.s	$ffc74505, $fff85086, $91eb44, $0
	.dc.s	$2c8c6f11, $54db943, $d268c557, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc75a44, $ffffa53c, $928083, $0
	.dc.s	$2cb9c36a, $3202c21, $d2543428, $0
	.dc.s	$ffc7b375, $fff85580, $9257c2, $0
	.dc.s	$2ab6d8ff, $6af95ac, $d0ffca44, $0
	.dc.s	$ffc74505, $fff85086, $91eb44, $0
	.dc.s	$2c8c6f11, $54db943, $d268c557, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc63c50, $ffe152d7, $8ecb36, $0
	.dc.s	$cc9e4961, $f9ff3c86, $db0c987b, $0
	.dc.s	$ffc75a44, $ffd29b7f, $928083, $0
	.dc.s	$cddf2af9, $f2bdf60b, $da7c2088, $0
	.dc.s	$ffc313d0, $ffe06ccd, $9354d7, $0
	.dc.s	$ce47c3c4, $fb1961f6, $d8b2e4f2, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc644b6, $ffed8093, $8f2a58, $0
	.dc.s	$d10e4f7e, $4b4786f, $d5e7a452, $0
	.dc.s	$ffc63c50, $ffe152d7, $8ecb36, $0
	.dc.s	$cc9e4961, $f9ff3c86, $db0c987b, $0
	.dc.s	$ffc313d0, $ffe06ccd, $9354d7, $0
	.dc.s	$ce47c3c4, $fb1961f6, $d8b2e4f2, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc644b6, $ffed8093, $8f2a58, $0
	.dc.s	$d10e4f7e, $4b4786f, $d5e7a452, $0
	.dc.s	$ffc313d0, $ffe06ccd, $9354d7, $0
	.dc.s	$ce47c3c4, $fb1961f6, $d8b2e4f2, $0
	.dc.s	$ffc3aa09, $ffee6fc9, $91daa0, $0
	.dc.s	$d1910b34, $a942ca5, $d6d64e67, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc74505, $fff85086, $91eb44, $0
	.dc.s	$cf2a1a80, $c9a4526, $d9e70cfc, $0
	.dc.s	$ffc644b6, $ffed8093, $8f2a58, $0
	.dc.s	$d10e4f7e, $4b4786f, $d5e7a452, $0
	.dc.s	$ffc3aa09, $ffee6fc9, $91daa0, $0
	.dc.s	$d1910b34, $a942ca5, $d6d64e67, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc74505, $fff85086, $91eb44, $0
	.dc.s	$cf2a1a80, $c9a4526, $d9e70cfc, $0
	.dc.s	$ffc3aa09, $ffee6fc9, $91daa0, $0
	.dc.s	$d1910b34, $a942ca5, $d6d64e67, $0
	.dc.s	$ffc6c8dc, $fff85580, $92aaf5, $0
	.dc.s	$cba5c0ac, $b1fcafd, $ddcd6426, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffcac60b, $ffee0404, $92cb29, $0
	.dc.s	$2ea40cf0, $ad301c8, $29b40c0e, $0
	.dc.s	$ffc7b375, $fff85580, $9257c2, $0
	.dc.s	$328ae439, $9035bce, $2579c34e, $0
	.dc.s	$ffc71e6a, $fff85580, $9320c5, $0
	.dc.s	$30e2923e, $aee3e5d, $27219501, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffcac60b, $ffee0404, $92cb29, $0
	.dc.s	$2ea40cf0, $ad301c8, $29b40c0e, $0
	.dc.s	$ffc71e6a, $fff85580, $9320c5, $0
	.dc.s	$30e2923e, $aee3e5d, $27219501, $0
	.dc.s	$ffc7502e, $ffef16a4, $9622c4, $0
	.dc.s	$28796a38, $468554b, $300692bf, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc7b375, $fff85580, $9257c2, $0
	.dc.s	$328ae439, $9035bce, $2579c34e, $0
	.dc.s	$ffc75a44, $ffffa53c, $928083, $0
	.dc.s	$3364b1b3, $19e8561, $261b41a4, $0
	.dc.s	$ffc71e6a, $fff85580, $9320c5, $0
	.dc.s	$30e2923e, $aee3e5d, $27219501, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$ffc6c8dc, $fff85580, $92aaf5, $0
	.dc.s	$cba5c0ac, $b1fcafd, $ddcd6426, $0
	.dc.s	$ffc75a44, $ffffa53c, $928083, $0
	.dc.s	$ca65e66d, $35ff658, $dd31b99d, $0
	.dc.s	$ffc74505, $fff85086, $91eb44, $0
	.dc.s	$cf2a1a80, $c9a4526, $d9e70cfc, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $fffd8000, $6c40ec, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffb0000, $6c40ec, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $fffd8000, $6c40ec, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $0, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $fffd8000, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffcc0000, $0, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffd80000, $0, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $fffd8000, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffd80000, $0, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffd80000, $fffd8000, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $fffd8000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffd80000, $fffd8000, $7409d5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffd80000, $0, $7409d5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $fffd8000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffd80000, $0, $7409d5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffd80000, $0, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $0, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $0, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $0, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffd80000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $0, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffd80000, $0, $7409d5, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $0, $7409d5, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $0, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $0, $7409d5, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $0, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $fffb0000, $600000, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffcc0000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffd80000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $fffb0000, $600000, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffd80000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffd80000, $fffb0000, $600000, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffcc0000, $fffd8000, $7409d5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffd80000, $fffd8000, $7409d5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffd80000, $fffd8000, $7409d5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffd80000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffd80000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffcc0000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffcc0000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffcc0000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $0, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $0, $7409d5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffd8000, $7409d5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffcc0000, $0, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffd8000, $7409d5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffd8000, $6c40ec, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $0, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffd80000, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffd80000, $fffb0000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$ffd80000, $0, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffd80000, $fffb0000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffd80000, $fffd8000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $fffd8000, $6c40ec, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$280000, $fffb0000, $6c40ec, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$280000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $fffd8000, $6c40ec, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$280000, $fffb0000, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$280000, $0, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $fffd8000, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$280000, $0, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $0, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $fffd8000, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $0, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $fffd8000, $7409d5, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $fffd8000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffd8000, $7409d5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $0, $7409d5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $fffd8000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $0, $7409d5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $0, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $0, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$280000, $0, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$280000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $0, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$280000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$340000, $fffb0000, $600000, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $0, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$340000, $0, $7409d5, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$280000, $0, $7409d5, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $0, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$280000, $0, $7409d5, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$280000, $0, $600000, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $fffb0000, $600000, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$280000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $fffb0000, $600000, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffb0000, $600000, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$280000, $fffd8000, $7409d5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffd8000, $7409d5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffd8000, $7409d5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$280000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$280000, $fffb0000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$280000, $fffd8000, $6c40ec, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $0, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$280000, $0, $7409d5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$280000, $fffd8000, $7409d5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$280000, $0, $600000, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$280000, $fffd8000, $7409d5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$280000, $fffd8000, $6c40ec, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $0, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffb0000, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffb0000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x4d3c2c,0,1
	.dc.s	$340000, $0, $600000, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffb0000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffd8000, $6c40ec, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x32391c,0,1
	.dc.s	$efd93333, $21069, $efe5cccd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$efd93333, $21069, $17ea3333, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1026cccd, $21069, $101a3333, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x32391c,0,1
	.dc.s	$1026cccd, $21069, $101a3333, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1026cccd, $21069, $efe5cccd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$efd93333, $21069, $efe5cccd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$0, $ffdbc000, $29fc85, $0
	.dc.s	$2583d2c, $c06341a2, $0, $0
	.dc.s	$340000, $ffe18000, $29fd51, $0
	.dc.s	$f7ff1a69, $c1673580, $0, $0
	.dc.s	$340000, $ffe18000, $65fd56, $0
	.dc.s	$ff83e8f6, $c0e53b91, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$0, $ffdbc000, $29fc85, $0
	.dc.s	$2583d2c, $c06341a2, $0, $0
	.dc.s	$340000, $ffe18000, $65fd56, $0
	.dc.s	$ff83e8f6, $c0e53b91, $0, $0
	.dc.s	$0, $ffdbc000, $65fc85, $0
	.dc.s	$fda7c2d4, $c06341a2, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$340000, $ffe18000, $29fd51, $0
	.dc.s	$f7ff1a69, $c1673580, $0, $0
	.dc.s	$360000, $ffe10000, $29fd51, $0
	.dc.s	$f07a4bdc, $c1e92f6e, $0, $0
	.dc.s	$360000, $ffe10000, $65fd56, $0
	.dc.s	$f07a4bdc, $c1e92f6e, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$340000, $ffe18000, $29fd51, $0
	.dc.s	$f7ff1a69, $c1673580, $0, $0
	.dc.s	$360000, $ffe10000, $65fd56, $0
	.dc.s	$f07a4bdc, $c1e92f6e, $0, $0
	.dc.s	$340000, $ffe18000, $65fd56, $0
	.dc.s	$ff83e8f6, $c0e53b91, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$360000, $ffe10000, $29fd51, $0
	.dc.s	$f8eeb09c, $3f9bca86, $0, $0
	.dc.s	$0, $ffdb0000, $29fc85, $0
	.dc.s	$25b1a77, $3f9bca86, $0, $0
	.dc.s	$0, $ffdb0000, $65fc85, $0
	.dc.s	$fda4e589, $3f9bca86, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$360000, $ffe10000, $29fd51, $0
	.dc.s	$f8eeb09c, $3f9bca86, $0, $0
	.dc.s	$0, $ffdb0000, $65fc85, $0
	.dc.s	$fda4e589, $3f9bca86, $0, $0
	.dc.s	$360000, $ffe10000, $65fd56, $0
	.dc.s	$f8eeb09c, $3f9bca86, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$0, $ffdb0000, $29fc85, $0
	.dc.s	$25b1a77, $3f9bca86, $0, $0
	.dc.s	$ffca0000, $ffe10000, $29fd51, $0
	.dc.s	$7114f64, $3f9bca86, $0, $0
	.dc.s	$ffca0000, $ffe10000, $65fd56, $0
	.dc.s	$7114f64, $3f9bca86, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$0, $ffdb0000, $29fc85, $0
	.dc.s	$25b1a77, $3f9bca86, $0, $0
	.dc.s	$ffca0000, $ffe10000, $65fd56, $0
	.dc.s	$7114f64, $3f9bca86, $0, $0
	.dc.s	$0, $ffdb0000, $65fc85, $0
	.dc.s	$fda4e589, $3f9bca86, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ffca0000, $ffe10000, $29fd51, $0
	.dc.s	$f85b424, $c1e92f6e, $0, $0
	.dc.s	$ffcc0000, $ffe18000, $29fd51, $0
	.dc.s	$7c170a, $c0e53b91, $0, $0
	.dc.s	$ffcc0000, $ffe18000, $65fd56, $0
	.dc.s	$800e597, $c1673580, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ffca0000, $ffe10000, $29fd51, $0
	.dc.s	$f85b424, $c1e92f6e, $0, $0
	.dc.s	$ffcc0000, $ffe18000, $65fd56, $0
	.dc.s	$800e597, $c1673580, $0, $0
	.dc.s	$ffca0000, $ffe10000, $65fd56, $0
	.dc.s	$f85b424, $c1e92f6e, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ffcc0000, $ffe18000, $29fd51, $0
	.dc.s	$7c170a, $c0e53b91, $0, $0
	.dc.s	$0, $ffdbc000, $29fc85, $0
	.dc.s	$2583d2c, $c06341a2, $0, $0
	.dc.s	$0, $ffdbc000, $65fc85, $0
	.dc.s	$fda7c2d4, $c06341a2, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ffcc0000, $ffe18000, $29fd51, $0
	.dc.s	$7c170a, $c0e53b91, $0, $0
	.dc.s	$0, $ffdbc000, $65fc85, $0
	.dc.s	$fda7c2d4, $c06341a2, $0, $0
	.dc.s	$ffcc0000, $ffe18000, $65fd56, $0
	.dc.s	$800e597, $c1673580, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$0, $ffdbc000, $29fc85, $0
	.dc.s	$0, $fffea3d7, $3ffffff7, $0
	.dc.s	$ffcc0000, $ffe18000, $29fd51, $0
	.dc.s	$ae15, $fffd47ae, $3ffffff0, $0
	.dc.s	$ffca0000, $ffe10000, $29fd51, $0
	.dc.s	$cfee, $fffea3d7, $3ffffff7, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$0, $ffdbc000, $29fc85, $0
	.dc.s	$0, $fffea3d7, $3ffffff7, $0
	.dc.s	$ffca0000, $ffe10000, $29fd51, $0
	.dc.s	$cfee, $fffea3d7, $3ffffff7, $0
	.dc.s	$0, $ffdb0000, $29fc85, $0
	.dc.s	$0, $0, $3ffffffe, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$0, $ffdbc000, $29fc85, $0
	.dc.s	$0, $fffea3d7, $3ffffff7, $0
	.dc.s	$0, $ffdb0000, $29fc85, $0
	.dc.s	$0, $0, $3ffffffe, $0
	.dc.s	$360000, $ffe10000, $29fd51, $0
	.dc.s	$ffff3012, $fffea3d7, $3ffffff7, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$0, $ffdbc000, $29fc85, $0
	.dc.s	$0, $fffea3d7, $3ffffff7, $0
	.dc.s	$360000, $ffe10000, $29fd51, $0
	.dc.s	$ffff3012, $fffea3d7, $3ffffff7, $0
	.dc.s	$340000, $ffe18000, $29fd51, $0
	.dc.s	$ffff51eb, $fffd47ae, $3ffffff0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$340000, $ffe18000, $65fd56, $0
	.dc.s	$35fc, $3b0b8, $c0000034, $0
	.dc.s	$360000, $ffe10000, $65fd56, $0
	.dc.s	$ac13, $2b04c, $c000000f, $0
	.dc.s	$0, $ffdb0000, $65fc85, $0
	.dc.s	$50fa, $58914, $c000004e, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$340000, $ffe18000, $65fd56, $0
	.dc.s	$35fc, $3b0b8, $c0000034, $0
	.dc.s	$0, $ffdb0000, $65fc85, $0
	.dc.s	$50fa, $58914, $c000004e, $0
	.dc.s	$ffca0000, $ffe10000, $65fd56, $0
	.dc.s	$fffffaf0, $430ef, $c0000046, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$340000, $ffe18000, $65fd56, $0
	.dc.s	$35fc, $3b0b8, $c0000034, $0
	.dc.s	$ffca0000, $ffe10000, $65fd56, $0
	.dc.s	$fffffaf0, $430ef, $c0000046, $0
	.dc.s	$ffcc0000, $ffe18000, $65fd56, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$340000, $ffe18000, $65fd56, $0
	.dc.s	$0, $fff6e1c7, $3fffff5a, $0
	.dc.s	$ffcc0000, $ffe18000, $65fd56, $0
	.dc.s	$0, $fff6e1c7, $3fffff5a, $0
	.dc.s	$0, $ffdbc000, $65fc85, $0
	.dc.s	$0, $fff6e1c7, $3fffff5a, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ff820000, $ffe08000, $ff9a0000, $0
	.dc.s	$52a3c91, $3f878293, $2951e49, $0
	.dc.s	$ff820000, $ffe08000, $63db8c, $0
	.dc.s	$2951e49, $3f833163, $fab2d4d5, $0
	.dc.s	$ffd40000, $ffd68000, $140000, $0
	.dc.s	$3dfad6d, $3fa4037c, $fe030fd0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ff820000, $ffe08000, $ff9a0000, $0
	.dc.s	$52a3c91, $3f878293, $2951e49, $0
	.dc.s	$ffd40000, $ffd68000, $140000, $0
	.dc.s	$3dfad6d, $3fa4037c, $fe030fd0, $0
	.dc.s	$ffd40000, $ffd68000, $ffec0000, $0
	.dc.s	$18cabc5, $3fb7b4bf, $319578a, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ff820000, $ffe08000, $63db8c, $0
	.dc.s	$230dd9e6, $ca74239a, $0, $0
	.dc.s	$ff820000, $ffe08000, $ff9a0000, $0
	.dc.s	$baf48a2, $ca74239a, $175e9144, $0
	.dc.s	$ff840000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$1186ecf3, $c7d71ab3, $8c37679, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ff820000, $ffe08000, $63db8c, $0
	.dc.s	$230dd9e6, $ca74239a, $0, $0
	.dc.s	$ff840000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$1186ecf3, $c7d71ab3, $8c37679, $0
	.dc.s	$ff840000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$baf48a2, $c37c0bde, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ff820000, $ffe08000, $63db8c, $0
	.dc.s	$2951e49, $3f833163, $fab2d4d5, $0
	.dc.s	$7e0000, $ffe08000, $63db8c, $0
	.dc.s	$fad5c36f, $3f8559fb, $fd596a6b, $0
	.dc.s	$2c0000, $ffd68000, $140000, $0
	.dc.s	$fe73543b, $3fb51da2, $fcd1b2e6, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ff820000, $ffe08000, $63db8c, $0
	.dc.s	$2951e49, $3f833163, $fab2d4d5, $0
	.dc.s	$2c0000, $ffd68000, $140000, $0
	.dc.s	$fe73543b, $3fb51da2, $fcd1b2e6, $0
	.dc.s	$ffd40000, $ffd68000, $140000, $0
	.dc.s	$3dfad6d, $3fa4037c, $fe030fd0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7e0000, $ffe08000, $63db8c, $0
	.dc.s	$0, $fe24af5b, $c006e568, $0
	.dc.s	$ff820000, $ffe08000, $63db8c, $0
	.dc.s	$0, $fe24af5b, $c006e568, $0
	.dc.s	$ff840000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$0, $fe24af5b, $c006e568, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7e0000, $ffe08000, $63db8c, $0
	.dc.s	$0, $fe24af5b, $c006e568, $0
	.dc.s	$ff840000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$0, $fe24af5b, $c006e568, $0
	.dc.s	$7c0000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$0, $fe24af5b, $c006e568, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7e0000, $ffe08000, $63db8c, $0
	.dc.s	$fad5c36f, $3f8559fb, $fd596a6b, $0
	.dc.s	$7e0000, $ffe08000, $ff9a0000, $0
	.dc.s	$fd6ae1b7, $3f878293, $52a3c91, $0
	.dc.s	$2c0000, $ffd68000, $ffec0000, $0
	.dc.s	$fc205293, $3fa5a1ee, $1efd6b6, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7e0000, $ffe08000, $63db8c, $0
	.dc.s	$fad5c36f, $3f8559fb, $fd596a6b, $0
	.dc.s	$2c0000, $ffd68000, $ffec0000, $0
	.dc.s	$fc205293, $3fa5a1ee, $1efd6b6, $0
	.dc.s	$2c0000, $ffd68000, $140000, $0
	.dc.s	$fe73543b, $3fb51da2, $fcd1b2e6, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7e0000, $ffe08000, $ff9a0000, $0
	.dc.s	$e8a16ebc, $ca74239a, $baf48a2, $0
	.dc.s	$7e0000, $ffe08000, $63db8c, $0
	.dc.s	$dcf2261a, $ca74239a, $0, $0
	.dc.s	$7c0000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$e8a16ebc, $c6f817bc, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7e0000, $ffe08000, $ff9a0000, $0
	.dc.s	$e8a16ebc, $ca74239a, $baf48a2, $0
	.dc.s	$7c0000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$e8a16ebc, $c6f817bc, $0, $0
	.dc.s	$7c0000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$f8fd3ad2, $c645aef6, $e058a5c, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7e0000, $ffe08000, $ff9a0000, $0
	.dc.s	$fd6ae1b7, $3f878293, $52a3c91, $0
	.dc.s	$ff820000, $ffe08000, $ff9a0000, $0
	.dc.s	$52a3c91, $3f878293, $2951e49, $0
	.dc.s	$ffd40000, $ffd68000, $ffec0000, $0
	.dc.s	$18cabc5, $3fb7b4bf, $319578a, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7e0000, $ffe08000, $ff9a0000, $0
	.dc.s	$fd6ae1b7, $3f878293, $52a3c91, $0
	.dc.s	$ffd40000, $ffd68000, $ffec0000, $0
	.dc.s	$18cabc5, $3fb7b4bf, $319578a, $0
	.dc.s	$2c0000, $ffd68000, $ffec0000, $0
	.dc.s	$fc205293, $3fa5a1ee, $1efd6b6, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ff820000, $ffe08000, $ff9a0000, $0
	.dc.s	$baf48a2, $ca74239a, $175e9144, $0
	.dc.s	$7e0000, $ffe08000, $ff9a0000, $0
	.dc.s	$e8a16ebc, $ca74239a, $baf48a2, $0
	.dc.s	$7c0000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$f8fd3ad2, $c645aef6, $e058a5c, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ff820000, $ffe08000, $ff9a0000, $0
	.dc.s	$baf48a2, $ca74239a, $175e9144, $0
	.dc.s	$7c0000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$f8fd3ad2, $c645aef6, $e058a5c, $0
	.dc.s	$ff840000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$1186ecf3, $c7d71ab3, $8c37679, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7c0000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$f8fd3ad2, $c645aef6, $e058a5c, $0
	.dc.s	$7c0000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$e8a16ebc, $c6f817bc, $0, $0
	.dc.s	$ff840000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$baf48a2, $c37c0bde, $0, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$7c0000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$f8fd3ad2, $c645aef6, $e058a5c, $0
	.dc.s	$ff840000, $ffe1cf2e, $63d1d1, $0
	.dc.s	$baf48a2, $c37c0bde, $0, $0
	.dc.s	$ff840000, $ffe1cf2e, $ff9c0000, $0
	.dc.s	$1186ecf3, $c7d71ab3, $8c37679, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ffd40000, $ffd68000, $ffec0000, $0
	.dc.s	$18cabc5, $3fb7b4bf, $319578a, $0
	.dc.s	$ffd40000, $ffd68000, $140000, $0
	.dc.s	$3dfad6d, $3fa4037c, $fe030fd0, $0
	.dc.s	$2c0000, $ffd68000, $140000, $0
	.dc.s	$fe73543b, $3fb51da2, $fcd1b2e6, $0
	.dc.s	3,_material_0x6e0501,0,1
	.dc.s	$ffd40000, $ffd68000, $ffec0000, $0
	.dc.s	$18cabc5, $3fb7b4bf, $319578a, $0
	.dc.s	$2c0000, $ffd68000, $140000, $0
	.dc.s	$fe73543b, $3fb51da2, $fcd1b2e6, $0
	.dc.s	$2c0000, $ffd68000, $ffec0000, $0
	.dc.s	$fc205293, $3fa5a1ee, $1efd6b6, $0
	.dc.s	3,_material_0xffffff,0,1
	.dc.s	$364178d, $fb686354, $eceb428f, $0
	.dc.s	$18c86b62, $1185fc8b, $c7a7b97b, $0
	.dc.s	$35110e5, $fb834bc7, $eceb428f, $0
	.dc.s	$18c86b62, $1185fc8b, $c7a7b97b, $0
	.dc.s	$36c45a2, $fb87f852, $ecf8ae14, $0
	.dc.s	$18c86b62, $1185fc8b, $c7a7b97b, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $fffb8000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffb8000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffb0000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $fffb8000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffb0000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $fffb0000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $fffb8000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $fffb8000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $fffb0000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $fffb8000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $fffb0000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffcc0000, $fffb0000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $fffb8000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffb8000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffb0000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $fffb8000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffb0000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $fffb0000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $fffb8000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $fffb8000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $fffb0000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $fffb8000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $fffb0000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$340000, $fffb0000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $fffb8000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$340000, $fffb8000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $fffb8000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $fffb8000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $fffb8000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $fffb8000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $fffb0000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffcc0000, $fffb0000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffb0000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $fffb0000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffb0000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $fffb0000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $0, $ff9e1405, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff860000, $0, $61ebfb, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff860000, $ffff0000, $61ebfb, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $0, $ff9e1405, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff860000, $ffff0000, $61ebfb, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff860000, $ffff0000, $ff9e1405, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $0, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$7a0000, $0, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$7a0000, $ffff0000, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $0, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$7a0000, $ffff0000, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff860000, $ffff0000, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $0, $61ebfb, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$7a0000, $0, $ff9e1405, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$7a0000, $ffff0000, $ff9e1405, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $0, $61ebfb, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$7a0000, $ffff0000, $ff9e1405, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$7a0000, $ffff0000, $61ebfb, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $0, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff860000, $0, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff860000, $ffff0000, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $0, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff860000, $ffff0000, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$7a0000, $ffff0000, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $0, $ff9e1405, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$7a0000, $0, $61ebfb, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ff860000, $0, $61ebfb, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $0, $ff9e1405, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ff860000, $0, $61ebfb, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ff860000, $0, $ff9e1405, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $ffff0000, $ff9e1405, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ff860000, $ffff0000, $61ebfb, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$7a0000, $ffff0000, $61ebfb, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $ffff0000, $ff9e1405, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$7a0000, $ffff0000, $61ebfb, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$7a0000, $ffff0000, $ff9e1405, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe80000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $ffe80000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $ffe78000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe80000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $ffe78000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $ffe78000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe80000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $ffe80000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $ffe78000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe80000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $ffe78000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffcc0000, $ffe78000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe80000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $ffe80000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $ffe78000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe80000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $ffe78000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $ffe78000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe80000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $ffe80000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $ffe78000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe80000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $ffe78000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$340000, $ffe78000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe80000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$340000, $ffe80000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $ffe80000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe80000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $ffe80000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $ffe80000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe78000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffcc0000, $ffe78000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $ffe78000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe78000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $ffe78000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $ffe78000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe18000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $ffe18000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $ffe10000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe18000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $ffe10000, $661893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffcc0000, $ffe10000, $601893, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe18000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $ffe18000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $ffe10000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe18000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$340000, $ffe10000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffcc0000, $ffe10000, $661893, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe18000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $ffe18000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $ffe10000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe18000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $ffe10000, $601893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$340000, $ffe10000, $661893, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe18000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $ffe18000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $ffe10000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe18000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffcc0000, $ffe10000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$340000, $ffe10000, $601893, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe18000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$340000, $ffe18000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $ffe18000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$340000, $ffe18000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $ffe18000, $661893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ffcc0000, $ffe18000, $601893, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe10000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffcc0000, $ffe10000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $ffe10000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ffcc0000, $ffe10000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $ffe10000, $661893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$340000, $ffe10000, $601893, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $fffc00ef, $ff9e1405, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff860000, $fffc00ef, $61ebfb, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff860000, $fffb00ef, $61ebfb, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $fffc00ef, $ff9e1405, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff860000, $fffb00ef, $61ebfb, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ff860000, $fffb00ef, $ff9e1405, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $fffc00ef, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$7a0000, $fffc00ef, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$7a0000, $fffb00ef, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $fffc00ef, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$7a0000, $fffb00ef, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ff860000, $fffb00ef, $61ebfb, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $fffc00ef, $61ebfb, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$7a0000, $fffc00ef, $ff9e1405, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$7a0000, $fffb00ef, $ff9e1405, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $fffc00ef, $61ebfb, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$7a0000, $fffb00ef, $ff9e1405, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$7a0000, $fffb00ef, $61ebfb, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $fffc00ef, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff860000, $fffc00ef, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff860000, $fffb00ef, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $fffc00ef, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ff860000, $fffb00ef, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$7a0000, $fffb00ef, $ff9e1405, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $fffc00ef, $ff9e1405, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$7a0000, $fffc00ef, $61ebfb, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ff860000, $fffc00ef, $61ebfb, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$7a0000, $fffc00ef, $ff9e1405, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ff860000, $fffc00ef, $61ebfb, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	$ff860000, $fffc00ef, $ff9e1405, $0
	.dc.s	$0, $c0000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $fffb00ef, $ff9e1405, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ff860000, $fffb00ef, $61ebfb, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$7a0000, $fffb00ef, $61ebfb, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x1d231d,0,1
	.dc.s	$ff860000, $fffb00ef, $ff9e1405, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$7a0000, $fffb00ef, $61ebfb, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$7a0000, $fffb00ef, $ff9e1405, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$3391c5, $ffe06ccd, $94ceb6, $0
	.dc.s	$c1c22fdc, $faa4a9ea, $3a76e5a, $0
	.dc.s	$376b56, $ffd29b7f, $96d7d3, $0
	.dc.s	$c276488d, $ee8b8768, $fde6c070, $0
	.dc.s	$33f4c5, $ffde97b5, $98b55a, $0
	.dc.s	$c13a0fa9, $fde473cd, $2db8b3a, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$34f3ff, $ffee6fc9, $94065e, $0
	.dc.s	$c0ca8ba5, $7be7ee5, $3abf309, $0
	.dc.s	$3391c5, $ffe06ccd, $94ceb6, $0
	.dc.s	$c1c22fdc, $faa4a9ea, $3a76e5a, $0
	.dc.s	$33f4c5, $ffde97b5, $98b55a, $0
	.dc.s	$c13a0fa9, $fde473cd, $2db8b3a, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$34f3ff, $ffee6fc9, $94065e, $0
	.dc.s	$c0ca8ba5, $7be7ee5, $3abf309, $0
	.dc.s	$33f4c5, $ffde97b5, $98b55a, $0
	.dc.s	$c13a0fa9, $fde473cd, $2db8b3a, $0
	.dc.s	$351bfe, $ffef16a4, $99a601, $0
	.dc.s	$c0c83109, $9283757, $ff7cde11, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$36df77, $fff85580, $969dad, $0
	.dc.s	$c0d0d071, $9506820, $fe01504f, $0
	.dc.s	$34f3ff, $ffee6fc9, $94065e, $0
	.dc.s	$c0ca8ba5, $7be7ee5, $3abf309, $0
	.dc.s	$351bfe, $ffef16a4, $99a601, $0
	.dc.s	$c0c83109, $9283757, $ff7cde11, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$36df77, $fff85580, $969dad, $0
	.dc.s	$c0d0d071, $9506820, $fe01504f, $0
	.dc.s	$351bfe, $ffef16a4, $99a601, $0
	.dc.s	$c0c83109, $9283757, $ff7cde11, $0
	.dc.s	$36d834, $fff85580, $972f18, $0
	.dc.s	$c0a55a68, $7ebc7d8, $fcd5fc89, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$376b56, $ffffa53c, $96d7d3, $0
	.dc.s	$c043ad7a, $4dc99ec, $fcd11bb4, $0
	.dc.s	$36df77, $fff85580, $969dad, $0
	.dc.s	$c0d0d071, $9506820, $fe01504f, $0
	.dc.s	$36d834, $fff85580, $972f18, $0
	.dc.s	$c0a55a68, $7ebc7d8, $fcd5fc89, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$33f4c5, $ffde97b5, $98b55a, $0
	.dc.s	$f4e24dd9, $f81e9b8c, $3e52f8ad, $0
	.dc.s	$376b56, $ffd29b7f, $96d7d3, $0
	.dc.s	$f47b61dc, $f3150a64, $3d9d8ed3, $0
	.dc.s	$3953ca, $ffde09fc, $9998ad, $0
	.dc.s	$fa9a634d, $fb2e0243, $3ec876ad, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$351bfe, $ffef16a4, $99a601, $0
	.dc.s	$16628bf, $468556d, $3eca6d08, $0
	.dc.s	$33f4c5, $ffde97b5, $98b55a, $0
	.dc.s	$f4e24dd9, $f81e9b8c, $3e52f8ad, $0
	.dc.s	$3953ca, $ffde09fc, $9998ad, $0
	.dc.s	$fa9a634d, $fb2e0243, $3ec876ad, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$351bfe, $ffef16a4, $99a601, $0
	.dc.s	$16628bf, $468556d, $3eca6d08, $0
	.dc.s	$3953ca, $ffde09fc, $9998ad, $0
	.dc.s	$fa9a634d, $fb2e0243, $3ec876ad, $0
	.dc.s	$39e698, $ffee0404, $993748, $0
	.dc.s	$a2ad81d, $ad3020c, $3dbc0cb4, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$3953ca, $ffde09fc, $9998ad, $0
	.dc.s	$36f569ab, $f7a37e48, $1e7a46c7, $0
	.dc.s	$376b56, $ffd29b7f, $96d7d3, $0
	.dc.s	$386dfffa, $f05c56d4, $19d40d85, $0
	.dc.s	$3b6a29, $ffe071aa, $967dfa, $0
	.dc.s	$36f569ab, $f7a37e48, $1e7a46c7, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$3953ca, $ffde09fc, $9998ad, $0
	.dc.s	$36f569ab, $f7a37e48, $1e7a46c7, $0
	.dc.s	$3b6a29, $ffe071aa, $967dfa, $0
	.dc.s	$36f569ab, $f7a37e48, $1e7a46c7, $0
	.dc.s	$39e698, $ffee0404, $993748, $0
	.dc.s	$357cd35b, $feeaa5bc, $23208008, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$3b6a29, $ffe071aa, $967dfa, $0
	.dc.s	$31017b4b, $ff31052a, $d957fc7e, $0
	.dc.s	$376b56, $ffd29b7f, $96d7d3, $0
	.dc.s	$2f09656c, $f161a174, $d722e2d2, $0
	.dc.s	$38e011, $ffe152d7, $93411f, $0
	.dc.s	$357fdeb1, $ffeec525, $e1a4531b, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$39e698, $ffee0404, $993748, $0
	.dc.s	$3a5fac12, $7f4a998, $ea7e2491, $0
	.dc.s	$3b6a29, $ffe071aa, $967dfa, $0
	.dc.s	$31017b4b, $ff31052a, $d957fc7e, $0
	.dc.s	$38e011, $ffe152d7, $93411f, $0
	.dc.s	$357fdeb1, $ffeec525, $e1a4531b, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$39e698, $ffee0404, $993748, $0
	.dc.s	$3a5fac12, $7f4a998, $ea7e2491, $0
	.dc.s	$38e011, $ffe152d7, $93411f, $0
	.dc.s	$357fdeb1, $ffeec525, $e1a4531b, $0
	.dc.s	$38aaf0, $ffed8093, $93907b, $0
	.dc.s	$3e6aa7fa, $61d9e33, $f41ac5f3, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$37ca5d, $fff85580, $96f007, $0
	.dc.s	$3ebf6aa9, $6af95df, $f62fb546, $0
	.dc.s	$39e698, $ffee0404, $993748, $0
	.dc.s	$3a5fac12, $7f4a998, $ea7e2491, $0
	.dc.s	$38aaf0, $ffed8093, $93907b, $0
	.dc.s	$3e6aa7fa, $61d9e33, $f41ac5f3, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$37ca5d, $fff85580, $96f007, $0
	.dc.s	$3ebf6aa9, $6af95df, $f62fb546, $0
	.dc.s	$38aaf0, $ffed8093, $93907b, $0
	.dc.s	$3e6aa7fa, $61d9e33, $f41ac5f3, $0
	.dc.s	$37b867, $fff85086, $965642, $0
	.dc.s	$3f4ab935, $54db968, $f86f644e, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$376b56, $ffffa53c, $96d7d3, $0
	.dc.s	$3f7aed8a, $3202c21, $f87bce4e, $0
	.dc.s	$37ca5d, $fff85580, $96f007, $0
	.dc.s	$3ebf6aa9, $6af95df, $f62fb546, $0
	.dc.s	$37b867, $fff85086, $965642, $0
	.dc.s	$3f4ab935, $54db968, $f86f644e, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$38e011, $ffe152d7, $93411f, $0
	.dc.s	$ef28cc00, $f9ff3c5e, $c2fe40b6, $0
	.dc.s	$376b56, $ffd29b7f, $96d7d3, $0
	.dc.s	$f07d530d, $f2bdf5a3, $c3570152, $0
	.dc.s	$3391c5, $ffe06ccd, $94ceb6, $0
	.dc.s	$f1ed94a6, $fb1961d7, $c2348186, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$38aaf0, $ffed8093, $93907b, $0
	.dc.s	$f5d79b55, $4b47896, $c1c52097, $0
	.dc.s	$38e011, $ffe152d7, $93411f, $0
	.dc.s	$ef28cc00, $f9ff3c5e, $c2fe40b6, $0
	.dc.s	$3391c5, $ffe06ccd, $94ceb6, $0
	.dc.s	$f1ed94a6, $fb1961d7, $c2348186, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$38aaf0, $ffed8093, $93907b, $0
	.dc.s	$f5d79b55, $4b47896, $c1c52097, $0
	.dc.s	$3391c5, $ffe06ccd, $94ceb6, $0
	.dc.s	$f1ed94a6, $fb1961d7, $c2348186, $0
	.dc.s	$34f3ff, $ffee6fc9, $94065e, $0
	.dc.s	$f5a7b9f6, $a942cef, $c2d101c4, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$37b867, $fff85086, $965642, $0
	.dc.s	$f1dc928f, $c9a4580, $c3b279b0, $0
	.dc.s	$38aaf0, $ffed8093, $93907b, $0
	.dc.s	$f5d79b55, $4b47896, $c1c52097, $0
	.dc.s	$34f3ff, $ffee6fc9, $94065e, $0
	.dc.s	$f5a7b9f6, $a942cef, $c2d101c4, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$37b867, $fff85086, $965642, $0
	.dc.s	$f1dc928f, $c9a4580, $c3b279b0, $0
	.dc.s	$34f3ff, $ffee6fc9, $94065e, $0
	.dc.s	$f5a7b9f6, $a942cef, $c2d101c4, $0
	.dc.s	$36df77, $fff85580, $969dad, $0
	.dc.s	$ecad2849, $b1fcb4f, $c4874746, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$39e698, $ffee0404, $993748, $0
	.dc.s	$a2ad81d, $ad3020c, $3dbc0cb4, $0
	.dc.s	$37ca5d, $fff85580, $96f007, $0
	.dc.s	$fdb9e08, $9035bfa, $3ce3a553, $0
	.dc.s	$36d834, $fff85580, $972f18, $0
	.dc.s	$d874f6a, $aee3e9d, $3d23942e, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$39e698, $ffee0404, $993748, $0
	.dc.s	$a2ad81d, $ad3020c, $3dbc0cb4, $0
	.dc.s	$36d834, $fff85580, $972f18, $0
	.dc.s	$d874f6a, $aee3e9d, $3d23942e, $0
	.dc.s	$351bfe, $ffef16a4, $99a601, $0
	.dc.s	$16628bf, $468556d, $3eca6d08, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$37ca5d, $fff85580, $96f007, $0
	.dc.s	$fdb9e08, $9035bfa, $3ce3a553, $0
	.dc.s	$376b56, $ffffa53c, $96d7d3, $0
	.dc.s	$101ff420, $19e8562, $3dea091b, $0
	.dc.s	$36d834, $fff85580, $972f18, $0
	.dc.s	$d874f6a, $aee3e9d, $3d23942e, $0
	.dc.s	3,_material_0x122813,0,1
	.dc.s	$36df77, $fff85580, $969dad, $0
	.dc.s	$ecad2849, $b1fcb4f, $c4874746, $0
	.dc.s	$376b56, $ffffa53c, $96d7d3, $0
	.dc.s	$ec15afbc, $35ff679, $c3456aea, $0
	.dc.s	$37b867, $fff85086, $965642, $0
	.dc.s	$f1dc928f, $c9a4580, $c3b279b0, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$171ee532, $ff46ca58, $ffffefb7, $0
	.dc.s	$38d9290e, $f357f3a0, $e873ea79, $0
	.dc.s	$10594679, $ff46ca58, $efa698ad, $0
	.dc.s	$2e783d9e, $e8ed6657, $e1ddda9f, $0
	.dc.s	$10660e28, $3d3dbf, $ef99d0ff, $0
	.dc.s	$2f7955d1, $fbacbed7, $dc0b92bb, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$171ee532, $ff46ca58, $ffffefb7, $0
	.dc.s	$38d9290e, $f357f3a0, $e873ea79, $0
	.dc.s	$10660e28, $3d3dbf, $ef99d0ff, $0
	.dc.s	$2f7955d1, $fbacbed7, $dc0b92bb, $0
	.dc.s	$1730f48e, $3d3dbf, $ffffefb7, $0
	.dc.s	$3afe4544, $fbad05d0, $8252d32, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$16775af4, $fe1a7611, $ffffefb7, $0
	.dc.s	$342a63e5, $e1e205a3, $fff22608, $0
	.dc.s	$fe2cb98, $fe1a7611, $f01d138e, $0
	.dc.s	$24d925a4, $e1e1f016, $db133750, $0
	.dc.s	$10594679, $ff46ca58, $efa698ad, $0
	.dc.s	$2e783d9e, $e8ed6657, $e1ddda9f, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$16775af4, $fe1a7611, $ffffefb7, $0
	.dc.s	$342a63e5, $e1e205a3, $fff22608, $0
	.dc.s	$10594679, $ff46ca58, $efa698ad, $0
	.dc.s	$2e783d9e, $e8ed6657, $e1ddda9f, $0
	.dc.s	$171ee532, $ff46ca58, $ffffefb7, $0
	.dc.s	$38d9290e, $f357f3a0, $e873ea79, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$157622a2, $fc6bad5d, $ffffefb7, $0
	.dc.s	$319b7be1, $dd8fc5de, $f407a915, $0
	.dc.s	$f2cea50, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$1de79272, $dcae2f5f, $d883c731, $0
	.dc.s	$fe2cb98, $fe1a7611, $f01d138e, $0
	.dc.s	$24d925a4, $e1e1f016, $db133750, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$157622a2, $fc6bad5d, $ffffefb7, $0
	.dc.s	$319b7be1, $dd8fc5de, $f407a915, $0
	.dc.s	$fe2cb98, $fe1a7611, $f01d138e, $0
	.dc.s	$24d925a4, $e1e1f016, $db133750, $0
	.dc.s	$16775af4, $fe1a7611, $ffffefb7, $0
	.dc.s	$342a63e5, $e1e205a3, $fff22608, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$d361346, $f92dd1b7, $f2c9cbe0, $0
	.dc.s	$254e80b6, $d8463573, $e3bed483, $0
	.dc.s	$f2cea50, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$1de79272, $dcae2f5f, $d883c731, $0
	.dc.s	$157622a2, $fc6bad5d, $ffffefb7, $0
	.dc.s	$319b7be1, $dd8fc5de, $f407a915, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$d361346, $f92dd1b7, $f2c9cbe0, $0
	.dc.s	$254e80b6, $d8463573, $e3bed483, $0
	.dc.s	$157622a2, $fc6bad5d, $ffffefb7, $0
	.dc.s	$319b7be1, $dd8fc5de, $f407a915, $0
	.dc.s	$12af03ea, $f92dd1b7, $ffffefb7, $0
	.dc.s	$2e5bd778, $d8463c8d, $eccc2348, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$10594679, $ff46ca58, $efa698ad, $0
	.dc.s	$186f84f9, $fbace27d, $c501bdaf, $0
	.dc.s	$ffffef6f, $ff46ca58, $e8e0f9f5, $0
	.dc.s	$b8d2ccf, $e8edc0a0, $c9d54779, $0
	.dc.s	$ffffef6f, $3d3dbf, $e8ceea98, $0
	.dc.s	$8252d32, $fbad05d0, $c501babc, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$10594679, $ff46ca58, $efa698ad, $0
	.dc.s	$186f84f9, $fbace27d, $c501bdaf, $0
	.dc.s	$ffffef6f, $3d3dbf, $e8ceea98, $0
	.dc.s	$8252d32, $fbad05d0, $c501babc, $0
	.dc.s	$10660e28, $3d3dbf, $ef99d0ff, $0
	.dc.s	$2f7955d1, $fbacbed7, $dc0b92bb, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$fe2cb98, $fe1a7611, $f01d138e, $0
	.dc.s	$24d925a4, $e1e1f016, $db133750, $0
	.dc.s	$ffffef6f, $fe1a7611, $e9888432, $0
	.dc.s	$fff22608, $e1e205a3, $cbd59c1b, $0
	.dc.s	$ffffef6f, $ff46ca58, $e8e0f9f5, $0
	.dc.s	$b8d2ccf, $e8edc0a0, $c9d54779, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$fe2cb98, $fe1a7611, $f01d138e, $0
	.dc.s	$24d925a4, $e1e1f016, $db133750, $0
	.dc.s	$ffffef6f, $ff46ca58, $e8e0f9f5, $0
	.dc.s	$b8d2ccf, $e8edc0a0, $c9d54779, $0
	.dc.s	$10594679, $ff46ca58, $efa698ad, $0
	.dc.s	$2e783d9e, $e8ed6657, $e1ddda9f, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f2cea50, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$1de79272, $dcae2f5f, $d883c731, $0
	.dc.s	$ffffef6f, $fc6bad5d, $ea89bc84, $0
	.dc.s	$f939b11c, $dcae2edd, $ceef1f62, $0
	.dc.s	$ffffef6f, $fe1a7611, $e9888432, $0
	.dc.s	$fff22608, $e1e205a3, $cbd59c1b, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f2cea50, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$1de79272, $dcae2f5f, $d883c731, $0
	.dc.s	$ffffef6f, $fe1a7611, $e9888432, $0
	.dc.s	$fff22608, $e1e205a3, $cbd59c1b, $0
	.dc.s	$fe2cb98, $fe1a7611, $f01d138e, $0
	.dc.s	$24d925a4, $e1e1f016, $db133750, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $f92dd1b7, $ed50db3c, $0
	.dc.s	$6669ca2, $d84638a5, $d1a42af0, $0
	.dc.s	$ffffef6f, $fc6bad5d, $ea89bc84, $0
	.dc.s	$f939b11c, $dcae2edd, $ceef1f62, $0
	.dc.s	$f2cea50, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$1de79272, $dcae2f5f, $d883c731, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $f92dd1b7, $ed50db3c, $0
	.dc.s	$6669ca2, $d84638a5, $d1a42af0, $0
	.dc.s	$f2cea50, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$1de79272, $dcae2f5f, $d883c731, $0
	.dc.s	$d361346, $f92dd1b7, $f2c9cbe0, $0
	.dc.s	$254e80b6, $d8463573, $e3bed483, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $ff46ca58, $e8e0f9f5, $0
	.dc.s	$e7907b09, $fbace22a, $c501bdb4, $0
	.dc.s	$efa69865, $ff46ca58, $efa698ad, $0
	.dc.s	$e1ddda9f, $e8ed6657, $d187c262, $0
	.dc.s	$ef99d0b7, $3d3dbf, $ef99d0ff, $0
	.dc.s	$dc0b92bb, $fbacbed7, $d086aa2f, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $ff46ca58, $e8e0f9f5, $0
	.dc.s	$e7907b09, $fbace22a, $c501bdb4, $0
	.dc.s	$ef99d0b7, $3d3dbf, $ef99d0ff, $0
	.dc.s	$dc0b92bb, $fbacbed7, $d086aa2f, $0
	.dc.s	$ffffef6f, $3d3dbf, $e8ceea98, $0
	.dc.s	$8252d32, $fbad05d0, $c501babc, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $fe1a7611, $e9888432, $0
	.dc.s	$fff22608, $e1e205a3, $cbd59c1b, $0
	.dc.s	$f01d1346, $fe1a7611, $f01d138e, $0
	.dc.s	$db133750, $e1e1f016, $db26da5c, $0
	.dc.s	$efa69865, $ff46ca58, $efa698ad, $0
	.dc.s	$e1ddda9f, $e8ed6657, $d187c262, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $fe1a7611, $e9888432, $0
	.dc.s	$fff22608, $e1e205a3, $cbd59c1b, $0
	.dc.s	$efa69865, $ff46ca58, $efa698ad, $0
	.dc.s	$e1ddda9f, $e8ed6657, $d187c262, $0
	.dc.s	$ffffef6f, $ff46ca58, $e8e0f9f5, $0
	.dc.s	$b8d2ccf, $e8edc0a0, $c9d54779, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $fc6bad5d, $ea89bc84, $0
	.dc.s	$f939b11c, $dcae2edd, $ceef1f62, $0
	.dc.s	$f0d2f48e, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$d883c731, $dcae2f5f, $e2186d8e, $0
	.dc.s	$f01d1346, $fe1a7611, $f01d138e, $0
	.dc.s	$db133750, $e1e1f016, $db26da5c, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $fc6bad5d, $ea89bc84, $0
	.dc.s	$f939b11c, $dcae2edd, $ceef1f62, $0
	.dc.s	$f01d1346, $fe1a7611, $f01d138e, $0
	.dc.s	$db133750, $e1e1f016, $db26da5c, $0
	.dc.s	$ffffef6f, $fe1a7611, $e9888432, $0
	.dc.s	$fff22608, $e1e205a3, $cbd59c1b, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f2c9cb98, $f92dd1b7, $f2c9cbe0, $0
	.dc.s	$e3bed483, $d8463573, $dab17f4a, $0
	.dc.s	$f0d2f48e, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$d883c731, $dcae2f5f, $e2186d8e, $0
	.dc.s	$ffffef6f, $fc6bad5d, $ea89bc84, $0
	.dc.s	$f939b11c, $dcae2edd, $ceef1f62, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f2c9cb98, $f92dd1b7, $f2c9cbe0, $0
	.dc.s	$e3bed483, $d8463573, $dab17f4a, $0
	.dc.s	$ffffef6f, $fc6bad5d, $ea89bc84, $0
	.dc.s	$f939b11c, $dcae2edd, $ceef1f62, $0
	.dc.s	$ffffef6f, $f92dd1b7, $ed50db3c, $0
	.dc.s	$6669ca2, $d84638a5, $d1a42af0, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$efa69865, $ff46ca58, $efa698ad, $0
	.dc.s	$c501bdaf, $fbace27d, $e7907b07, $0
	.dc.s	$e8e0f9ad, $ff46ca58, $ffffefb7, $0
	.dc.s	$c9d54779, $e8edc0a0, $f472d331, $0
	.dc.s	$e8ceea50, $3d3dbf, $ffffefb7, $0
	.dc.s	$c501babc, $fbad05d0, $f7dad2ce, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$efa69865, $ff46ca58, $efa698ad, $0
	.dc.s	$c501bdaf, $fbace27d, $e7907b07, $0
	.dc.s	$e8ceea50, $3d3dbf, $ffffefb7, $0
	.dc.s	$c501babc, $fbad05d0, $f7dad2ce, $0
	.dc.s	$ef99d0b7, $3d3dbf, $ef99d0ff, $0
	.dc.s	$dc0b92bb, $fbacbed7, $d086aa2f, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f01d1346, $fe1a7611, $f01d138e, $0
	.dc.s	$db133750, $e1e1f016, $db26da5c, $0
	.dc.s	$e98883ea, $fe1a7611, $ffffefb7, $0
	.dc.s	$cbd59c1b, $e1e205a3, $dd9f8, $0
	.dc.s	$e8e0f9ad, $ff46ca58, $ffffefb7, $0
	.dc.s	$c9d54779, $e8edc0a0, $f472d331, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f01d1346, $fe1a7611, $f01d138e, $0
	.dc.s	$db133750, $e1e1f016, $db26da5c, $0
	.dc.s	$e8e0f9ad, $ff46ca58, $ffffefb7, $0
	.dc.s	$c9d54779, $e8edc0a0, $f472d331, $0
	.dc.s	$efa69865, $ff46ca58, $efa698ad, $0
	.dc.s	$e1ddda9f, $e8ed6657, $d187c262, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f0d2f48e, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$d883c731, $dcae2f5f, $e2186d8e, $0
	.dc.s	$ea89bc3c, $fc6bad5d, $ffffefb7, $0
	.dc.s	$ceef1f62, $dcae2edd, $6c64ee4, $0
	.dc.s	$e98883ea, $fe1a7611, $ffffefb7, $0
	.dc.s	$cbd59c1b, $e1e205a3, $dd9f8, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f0d2f48e, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$d883c731, $dcae2f5f, $e2186d8e, $0
	.dc.s	$e98883ea, $fe1a7611, $ffffefb7, $0
	.dc.s	$cbd59c1b, $e1e205a3, $dd9f8, $0
	.dc.s	$f01d1346, $fe1a7611, $f01d138e, $0
	.dc.s	$db133750, $e1e1f016, $db26da5c, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ed50daf4, $f92dd1b7, $ffffefb7, $0
	.dc.s	$d1a42af0, $d84638a5, $f999635e, $0
	.dc.s	$ea89bc3c, $fc6bad5d, $ffffefb7, $0
	.dc.s	$ceef1f62, $dcae2edd, $6c64ee4, $0
	.dc.s	$f0d2f48e, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$d883c731, $dcae2f5f, $e2186d8e, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ed50daf4, $f92dd1b7, $ffffefb7, $0
	.dc.s	$d1a42af0, $d84638a5, $f999635e, $0
	.dc.s	$f0d2f48e, $fc6bad5d, $f0d2f4d6, $0
	.dc.s	$d883c731, $dcae2f5f, $e2186d8e, $0
	.dc.s	$f2c9cb98, $f92dd1b7, $f2c9cbe0, $0
	.dc.s	$e3bed483, $d8463573, $dab17f4a, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$e8e0f9ad, $ff46ca58, $ffffefb7, $0
	.dc.s	$c501bdb4, $fbace22a, $186f84f7, $0
	.dc.s	$efa69865, $ff46ca58, $105946c1, $0
	.dc.s	$d187c262, $e8ed6657, $1e222561, $0
	.dc.s	$ef99d0b7, $3d3dbf, $10660e70, $0
	.dc.s	$d086aa2f, $fbacbed7, $23f46d45, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$e8e0f9ad, $ff46ca58, $ffffefb7, $0
	.dc.s	$c501bdb4, $fbace22a, $186f84f7, $0
	.dc.s	$ef99d0b7, $3d3dbf, $10660e70, $0
	.dc.s	$d086aa2f, $fbacbed7, $23f46d45, $0
	.dc.s	$e8ceea50, $3d3dbf, $ffffefb7, $0
	.dc.s	$c501babc, $fbad05d0, $f7dad2ce, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$e98883ea, $fe1a7611, $ffffefb7, $0
	.dc.s	$cbd59c1b, $e1e205a3, $dd9f8, $0
	.dc.s	$f01d1346, $fe1a7611, $fe2cbe0, $0
	.dc.s	$db26da5c, $e1e1f016, $24ecc8b0, $0
	.dc.s	$efa69865, $ff46ca58, $105946c1, $0
	.dc.s	$d187c262, $e8ed6657, $1e222561, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$e98883ea, $fe1a7611, $ffffefb7, $0
	.dc.s	$cbd59c1b, $e1e205a3, $dd9f8, $0
	.dc.s	$efa69865, $ff46ca58, $105946c1, $0
	.dc.s	$d187c262, $e8ed6657, $1e222561, $0
	.dc.s	$e8e0f9ad, $ff46ca58, $ffffefb7, $0
	.dc.s	$c9d54779, $e8edc0a0, $f472d331, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ea89bc3c, $fc6bad5d, $ffffefb7, $0
	.dc.s	$ceef1f62, $dcae2edd, $6c64ee4, $0
	.dc.s	$f0d2f48e, $fc6bad5d, $f2cea98, $0
	.dc.s	$e2186d8e, $dcae2f5f, $277c38cf, $0
	.dc.s	$f01d1346, $fe1a7611, $fe2cbe0, $0
	.dc.s	$db26da5c, $e1e1f016, $24ecc8b0, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ea89bc3c, $fc6bad5d, $ffffefb7, $0
	.dc.s	$ceef1f62, $dcae2edd, $6c64ee4, $0
	.dc.s	$f01d1346, $fe1a7611, $fe2cbe0, $0
	.dc.s	$db26da5c, $e1e1f016, $24ecc8b0, $0
	.dc.s	$e98883ea, $fe1a7611, $ffffefb7, $0
	.dc.s	$cbd59c1b, $e1e205a3, $dd9f8, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f2c9cb98, $f92dd1b7, $d36138e, $0
	.dc.s	$dab17f4a, $d8463573, $1c412b7d, $0
	.dc.s	$f0d2f48e, $fc6bad5d, $f2cea98, $0
	.dc.s	$e2186d8e, $dcae2f5f, $277c38cf, $0
	.dc.s	$ea89bc3c, $fc6bad5d, $ffffefb7, $0
	.dc.s	$ceef1f62, $dcae2edd, $6c64ee4, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f2c9cb98, $f92dd1b7, $d36138e, $0
	.dc.s	$dab17f4a, $d8463573, $1c412b7d, $0
	.dc.s	$ea89bc3c, $fc6bad5d, $ffffefb7, $0
	.dc.s	$ceef1f62, $dcae2edd, $6c64ee4, $0
	.dc.s	$ed50daf4, $f92dd1b7, $ffffefb7, $0
	.dc.s	$d1a42af0, $d84638a5, $f999635e, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$efa69865, $ff46ca58, $105946c1, $0
	.dc.s	$e7907b07, $fbace27d, $3afe4251, $0
	.dc.s	$ffffef6f, $ff46ca58, $171ee57a, $0
	.dc.s	$f472d331, $e8edc0a0, $362ab887, $0
	.dc.s	$ffffef6f, $3d3dbf, $1730f4d6, $0
	.dc.s	$f7dad2ce, $fbad05d0, $3afe4544, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$efa69865, $ff46ca58, $105946c1, $0
	.dc.s	$e7907b07, $fbace27d, $3afe4251, $0
	.dc.s	$ffffef6f, $3d3dbf, $1730f4d6, $0
	.dc.s	$f7dad2ce, $fbad05d0, $3afe4544, $0
	.dc.s	$ef99d0b7, $3d3dbf, $10660e70, $0
	.dc.s	$d086aa2f, $fbacbed7, $23f46d45, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f01d1346, $fe1a7611, $fe2cbe0, $0
	.dc.s	$db26da5c, $e1e1f016, $24ecc8b0, $0
	.dc.s	$ffffef6f, $fe1a7611, $16775b3c, $0
	.dc.s	$dd9f8, $e1e205a3, $342a63e5, $0
	.dc.s	$ffffef6f, $ff46ca58, $171ee57a, $0
	.dc.s	$f472d331, $e8edc0a0, $362ab887, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f01d1346, $fe1a7611, $fe2cbe0, $0
	.dc.s	$db26da5c, $e1e1f016, $24ecc8b0, $0
	.dc.s	$ffffef6f, $ff46ca58, $171ee57a, $0
	.dc.s	$f472d331, $e8edc0a0, $362ab887, $0
	.dc.s	$efa69865, $ff46ca58, $105946c1, $0
	.dc.s	$d187c262, $e8ed6657, $1e222561, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f0d2f48e, $fc6bad5d, $f2cea98, $0
	.dc.s	$e2186d8e, $dcae2f5f, $277c38cf, $0
	.dc.s	$ffffef6f, $fc6bad5d, $157622ea, $0
	.dc.s	$6c64ee4, $dcae2edd, $3110e09e, $0
	.dc.s	$ffffef6f, $fe1a7611, $16775b3c, $0
	.dc.s	$dd9f8, $e1e205a3, $342a63e5, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f0d2f48e, $fc6bad5d, $f2cea98, $0
	.dc.s	$e2186d8e, $dcae2f5f, $277c38cf, $0
	.dc.s	$ffffef6f, $fe1a7611, $16775b3c, $0
	.dc.s	$dd9f8, $e1e205a3, $342a63e5, $0
	.dc.s	$f01d1346, $fe1a7611, $fe2cbe0, $0
	.dc.s	$db26da5c, $e1e1f016, $24ecc8b0, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $f92dd1b7, $12af0432, $0
	.dc.s	$f999635e, $d84638a5, $2e5bd510, $0
	.dc.s	$ffffef6f, $fc6bad5d, $157622ea, $0
	.dc.s	$6c64ee4, $dcae2edd, $3110e09e, $0
	.dc.s	$f0d2f48e, $fc6bad5d, $f2cea98, $0
	.dc.s	$e2186d8e, $dcae2f5f, $277c38cf, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $f92dd1b7, $12af0432, $0
	.dc.s	$f999635e, $d84638a5, $2e5bd510, $0
	.dc.s	$f0d2f48e, $fc6bad5d, $f2cea98, $0
	.dc.s	$e2186d8e, $dcae2f5f, $277c38cf, $0
	.dc.s	$f2c9cb98, $f92dd1b7, $d36138e, $0
	.dc.s	$dab17f4a, $d8463573, $1c412b7d, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $ff46ca58, $171ee57a, $0
	.dc.s	$186f84f7, $fbace22a, $3afe424c, $0
	.dc.s	$10594679, $ff46ca58, $105946c1, $0
	.dc.s	$1e222561, $e8ed6657, $2e783d9e, $0
	.dc.s	$10660e28, $3d3dbf, $10660e70, $0
	.dc.s	$23f46d45, $fbacbed7, $2f7955d1, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $ff46ca58, $171ee57a, $0
	.dc.s	$186f84f7, $fbace22a, $3afe424c, $0
	.dc.s	$10660e28, $3d3dbf, $10660e70, $0
	.dc.s	$23f46d45, $fbacbed7, $2f7955d1, $0
	.dc.s	$ffffef6f, $3d3dbf, $1730f4d6, $0
	.dc.s	$f7dad2ce, $fbad05d0, $3afe4544, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $fe1a7611, $16775b3c, $0
	.dc.s	$dd9f8, $e1e205a3, $342a63e5, $0
	.dc.s	$fe2cb98, $fe1a7611, $fe2cbe0, $0
	.dc.s	$24ecc8b0, $e1e1f016, $24d925a4, $0
	.dc.s	$10594679, $ff46ca58, $105946c1, $0
	.dc.s	$1e222561, $e8ed6657, $2e783d9e, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $fe1a7611, $16775b3c, $0
	.dc.s	$dd9f8, $e1e205a3, $342a63e5, $0
	.dc.s	$10594679, $ff46ca58, $105946c1, $0
	.dc.s	$1e222561, $e8ed6657, $2e783d9e, $0
	.dc.s	$ffffef6f, $ff46ca58, $171ee57a, $0
	.dc.s	$f472d331, $e8edc0a0, $362ab887, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $fc6bad5d, $157622ea, $0
	.dc.s	$6c64ee4, $dcae2edd, $3110e09e, $0
	.dc.s	$f2cea50, $fc6bad5d, $f2cea98, $0
	.dc.s	$240c6b49, $dee22bb6, $23416f03, $0
	.dc.s	$fe2cb98, $fe1a7611, $fe2cbe0, $0
	.dc.s	$24ecc8b0, $e1e1f016, $24d925a4, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$ffffef6f, $fc6bad5d, $157622ea, $0
	.dc.s	$6c64ee4, $dcae2edd, $3110e09e, $0
	.dc.s	$fe2cb98, $fe1a7611, $fe2cbe0, $0
	.dc.s	$24ecc8b0, $e1e1f016, $24d925a4, $0
	.dc.s	$ffffef6f, $fe1a7611, $16775b3c, $0
	.dc.s	$dd9f8, $e1e205a3, $342a63e5, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$d361346, $f92dd1b7, $d36138e, $0
	.dc.s	$1333d986, $d8463767, $2e5bd461, $0
	.dc.s	$f2cea50, $fc6bad5d, $f2cea98, $0
	.dc.s	$240c6b49, $dee22bb6, $23416f03, $0
	.dc.s	$ffffef6f, $fc6bad5d, $157622ea, $0
	.dc.s	$6c64ee4, $dcae2edd, $3110e09e, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$d361346, $f92dd1b7, $d36138e, $0
	.dc.s	$1333d986, $d8463767, $2e5bd461, $0
	.dc.s	$ffffef6f, $fc6bad5d, $157622ea, $0
	.dc.s	$6c64ee4, $dcae2edd, $3110e09e, $0
	.dc.s	$ffffef6f, $f92dd1b7, $12af0432, $0
	.dc.s	$f999635e, $d84638a5, $2e5bd510, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$10594679, $ff46ca58, $105946c1, $0
	.dc.s	$3afe4251, $fbace27d, $186f84f9, $0
	.dc.s	$171ee532, $ff46ca58, $ffffefb7, $0
	.dc.s	$36b3f92f, $eb02f952, $16a8a34b, $0
	.dc.s	$1730f48e, $3d3dbf, $ffffefb7, $0
	.dc.s	$3afe4544, $fbad05d0, $8252d32, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$10594679, $ff46ca58, $105946c1, $0
	.dc.s	$3afe4251, $fbace27d, $186f84f9, $0
	.dc.s	$1730f48e, $3d3dbf, $ffffefb7, $0
	.dc.s	$3afe4544, $fbad05d0, $8252d32, $0
	.dc.s	$10660e28, $3d3dbf, $10660e70, $0
	.dc.s	$23f46d45, $fbacbed7, $2f7955d1, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$fe2cb98, $fe1a7611, $fe2cbe0, $0
	.dc.s	$24ecc8b0, $e1e1f016, $24d925a4, $0
	.dc.s	$16775af4, $fe1a7611, $ffffefb7, $0
	.dc.s	$342a63e5, $e1e205a3, $fff22608, $0
	.dc.s	$171ee532, $ff46ca58, $ffffefb7, $0
	.dc.s	$36b3f92f, $eb02f952, $16a8a34b, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$fe2cb98, $fe1a7611, $fe2cbe0, $0
	.dc.s	$24ecc8b0, $e1e1f016, $24d925a4, $0
	.dc.s	$171ee532, $ff46ca58, $ffffefb7, $0
	.dc.s	$36b3f92f, $eb02f952, $16a8a34b, $0
	.dc.s	$10594679, $ff46ca58, $105946c1, $0
	.dc.s	$1e222561, $e8ed6657, $2e783d9e, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f2cea50, $fc6bad5d, $f2cea98, $0
	.dc.s	$240c6b49, $dee22bb6, $23416f03, $0
	.dc.s	$157622a2, $fc6bad5d, $ffffefb7, $0
	.dc.s	$319b7be1, $dd8fc5de, $f407a915, $0
	.dc.s	$16775af4, $fe1a7611, $ffffefb7, $0
	.dc.s	$342a63e5, $e1e205a3, $fff22608, $0
	.dc.s	3,_material_0x725d5f,0,1
	.dc.s	$f2cea50, $fc6bad5d, $f2cea98, $0
	.dc.s	$240c6b49, $dee22bb6, $23416f03, $0
	.dc.s	$16775af4, $fe1a7611, $ffffefb7, $0
	.dc.s	$342a63e5, $e1e205a3, $fff22608, $0
	.dc.s	$fe2cb98, $fe1a7611, $fe2cbe0, $0
	.dc.s	$24ecc8b0, $e1e1f016, $24d925a4, $0
	.dc.s	3,_material_0x946530,0,1
	.dc.s	$ff640f42, $ffff9a60, $7fdefa, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$9bf0be, $ffff9a60, $7fdefa, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$9bf0be, $ffff9a60, $ff802106, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x946530,0,1
	.dc.s	$9bf0be, $ffff9a60, $ff802106, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ff640f42, $ffff9a60, $ff802106, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ff640f42, $ffff9a60, $7fdefa, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffde2910, $fffc5e91, $14c5b23, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffde2910, $1209, $14c5b23, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffde2910, $1209, $18ff021, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffde2910, $fffc5e91, $14c5b23, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffde2910, $1209, $18ff021, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$ffde2910, $fffc5e91, $18ff021, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe08817, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde2910, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde2910, $fffc5e91, $18ff021, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe08817, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde2910, $fffc5e91, $18ff021, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffe08817, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe08817, $844f7, $14eb9db, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffe08817, $fffc5e91, $14eb9db, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffe08817, $fffc5e91, $18d90e5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe08817, $844f7, $14eb9db, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffe08817, $fffc5e91, $18d90e5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$ffe08817, $844f7, $18d90e5, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffde2910, $fffc5e91, $18ff021, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffde2910, $1209, $18ff021, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$21be1b, $1209, $18ff021, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffde2910, $fffc5e91, $18ff021, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$21be1b, $1209, $18ff021, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$21be1b, $fffc5e91, $18ff021, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe08817, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde2910, $fffc5e91, $18ff021, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21be1b, $fffc5e91, $18ff021, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe08817, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21be1b, $fffc5e91, $18ff021, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1f5f07, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe08817, $844f7, $18d90e5, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffe08817, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$1f5f07, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe08817, $844f7, $18d90e5, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$1f5f07, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$1f5f07, $844f7, $18d90e5, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$21be1b, $fffc5e91, $18ff021, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$21be1b, $1209, $18ff021, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$21be1b, $1209, $14c5b23, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$21be1b, $fffc5e91, $18ff021, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$21be1b, $1209, $14c5b23, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	$21be1b, $fffc5e91, $14c5b23, $0
	.dc.s	$c0000000, $0, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f5f07, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21be1b, $fffc5e91, $18ff021, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21be1b, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f5f07, $fffc5e91, $18d90e5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21be1b, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1f5f07, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f5f07, $844f7, $18d90e5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$1f5f07, $fffc5e91, $18d90e5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$1f5f07, $fffc5e91, $14eb9db, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f5f07, $844f7, $18d90e5, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$1f5f07, $fffc5e91, $14eb9db, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	$1f5f07, $844f7, $14eb9db, $0
	.dc.s	$40000000, $0, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$21be1b, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$21be1b, $1209, $14c5b23, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffde2910, $1209, $14c5b23, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$21be1b, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffde2910, $1209, $14c5b23, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	$ffde2910, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f5f07, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21be1b, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde2910, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f5f07, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde2910, $fffc5e91, $14c5b23, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffe08817, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f5f07, $844f7, $14eb9db, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$1f5f07, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe08817, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f5f07, $844f7, $14eb9db, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe08817, $fffc5e91, $14eb9db, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	$ffe08817, $844f7, $14eb9db, $0
	.dc.s	$0, $0, $c0000000, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$1fffa4, $fffeded6, $14e0831, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffdfe6f7, $fffeded6, $14e0831, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffdfe704, $fffeded6, $18e20c5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$1fffa4, $fffeded6, $14e0831, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffdfe704, $fffeded6, $18e20c5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1fffa4, $fffeded6, $18e20c5, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$1fffa4, $fffeded6, $14e0831, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	$1fffa4, $fffeded6, $18e20c5, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	$1fffa4, $fffeded6, $14e0831, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb3a4dd, $fffc5e91, $ffde290d, $0
	.dc.s	$ffffff81, $0, $40000000, $0
	.dc.s	$feb3a4dd, $1209, $ffde290d, $0
	.dc.s	$ffffff81, $0, $40000000, $0
	.dc.s	$fe700fdf, $1209, $ffde290d, $0
	.dc.s	$ffffff81, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb3a4dd, $fffc5e91, $ffde290d, $0
	.dc.s	$ffffff81, $0, $40000000, $0
	.dc.s	$fe700fdf, $1209, $ffde290d, $0
	.dc.s	$ffffff81, $0, $40000000, $0
	.dc.s	$fe700fdf, $fffc5e91, $ffde290d, $0
	.dc.s	$ffffff81, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb14625, $fffc5e91, $ffe08814, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb3a4dd, $fffc5e91, $ffde290d, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe700fdf, $fffc5e91, $ffde290d, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb14625, $fffc5e91, $ffe08814, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe700fdf, $fffc5e91, $ffde290d, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe726f1b, $fffc5e91, $ffe08814, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb14625, $844f7, $ffe08814, $0
	.dc.s	$7e, $0, $c0000000, $0
	.dc.s	$feb14625, $fffc5e91, $ffe08814, $0
	.dc.s	$7e, $0, $c0000000, $0
	.dc.s	$fe726f1b, $fffc5e91, $ffe08814, $0
	.dc.s	$7e, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb14625, $844f7, $ffe08814, $0
	.dc.s	$7e, $0, $c0000000, $0
	.dc.s	$fe726f1b, $fffc5e91, $ffe08814, $0
	.dc.s	$7e, $0, $c0000000, $0
	.dc.s	$fe726f1b, $844f7, $ffe08814, $0
	.dc.s	$7e, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe700fdf, $fffc5e91, $ffde290d, $0
	.dc.s	$40000000, $0, $7f, $0
	.dc.s	$fe700fdf, $1209, $ffde290d, $0
	.dc.s	$40000000, $0, $7f, $0
	.dc.s	$fe700fdf, $1209, $21be18, $0
	.dc.s	$40000000, $0, $7f, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe700fdf, $fffc5e91, $ffde290d, $0
	.dc.s	$40000000, $0, $7f, $0
	.dc.s	$fe700fdf, $1209, $21be18, $0
	.dc.s	$40000000, $0, $7f, $0
	.dc.s	$fe700fdf, $fffc5e91, $21be18, $0
	.dc.s	$40000000, $0, $7f, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe726f1b, $fffc5e91, $ffe08814, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe700fdf, $fffc5e91, $ffde290d, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe700fdf, $fffc5e91, $21be18, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe726f1b, $fffc5e91, $ffe08814, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe700fdf, $fffc5e91, $21be18, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe726f1a, $fffc5e91, $1f5f04, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe726f1b, $844f7, $ffe08814, $0
	.dc.s	$c0000000, $0, $ffffff7e, $0
	.dc.s	$fe726f1b, $fffc5e91, $ffe08814, $0
	.dc.s	$c0000000, $0, $ffffff7e, $0
	.dc.s	$fe726f1a, $fffc5e91, $1f5f04, $0
	.dc.s	$c0000000, $0, $ffffff7e, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe726f1b, $844f7, $ffe08814, $0
	.dc.s	$c0000000, $0, $ffffff7e, $0
	.dc.s	$fe726f1a, $fffc5e91, $1f5f04, $0
	.dc.s	$c0000000, $0, $ffffff7e, $0
	.dc.s	$fe726f1a, $844f7, $1f5f04, $0
	.dc.s	$c0000000, $0, $ffffff7e, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe700fdf, $fffc5e91, $21be18, $0
	.dc.s	$7f, $0, $c0000000, $0
	.dc.s	$fe700fdf, $1209, $21be18, $0
	.dc.s	$7f, $0, $c0000000, $0
	.dc.s	$feb3a4dd, $1209, $21be18, $0
	.dc.s	$7f, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe700fdf, $fffc5e91, $21be18, $0
	.dc.s	$7f, $0, $c0000000, $0
	.dc.s	$feb3a4dd, $1209, $21be18, $0
	.dc.s	$7f, $0, $c0000000, $0
	.dc.s	$feb3a4dd, $fffc5e91, $21be18, $0
	.dc.s	$7f, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe726f1a, $fffc5e91, $1f5f04, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe700fdf, $fffc5e91, $21be18, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb3a4dd, $fffc5e91, $21be18, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe726f1a, $fffc5e91, $1f5f04, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb3a4dd, $fffc5e91, $21be18, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb14625, $fffc5e91, $1f5f04, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe726f1a, $844f7, $1f5f04, $0
	.dc.s	$ffffff82, $0, $40000000, $0
	.dc.s	$fe726f1a, $fffc5e91, $1f5f04, $0
	.dc.s	$ffffff82, $0, $40000000, $0
	.dc.s	$feb14625, $fffc5e91, $1f5f04, $0
	.dc.s	$ffffff82, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$fe726f1a, $844f7, $1f5f04, $0
	.dc.s	$ffffff82, $0, $40000000, $0
	.dc.s	$feb14625, $fffc5e91, $1f5f04, $0
	.dc.s	$ffffff82, $0, $40000000, $0
	.dc.s	$feb14625, $844f7, $1f5f04, $0
	.dc.s	$ffffff82, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb3a4dd, $fffc5e91, $21be18, $0
	.dc.s	$c0000000, $0, $ffffff81, $0
	.dc.s	$feb3a4dd, $1209, $21be18, $0
	.dc.s	$c0000000, $0, $ffffff81, $0
	.dc.s	$feb3a4dd, $1209, $ffde290d, $0
	.dc.s	$c0000000, $0, $ffffff81, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb3a4dd, $fffc5e91, $21be18, $0
	.dc.s	$c0000000, $0, $ffffff81, $0
	.dc.s	$feb3a4dd, $1209, $ffde290d, $0
	.dc.s	$c0000000, $0, $ffffff81, $0
	.dc.s	$feb3a4dd, $fffc5e91, $ffde290d, $0
	.dc.s	$c0000000, $0, $ffffff81, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb14625, $fffc5e91, $1f5f04, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb3a4dd, $fffc5e91, $21be18, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb3a4dd, $fffc5e91, $ffde290d, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb14625, $fffc5e91, $1f5f04, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb3a4dd, $fffc5e91, $ffde290d, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb14625, $fffc5e91, $ffe08814, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb14625, $844f7, $1f5f04, $0
	.dc.s	$40000000, $0, $82, $0
	.dc.s	$feb14625, $fffc5e91, $1f5f04, $0
	.dc.s	$40000000, $0, $82, $0
	.dc.s	$feb14625, $fffc5e91, $ffe08814, $0
	.dc.s	$40000000, $0, $82, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$feb14625, $844f7, $1f5f04, $0
	.dc.s	$40000000, $0, $82, $0
	.dc.s	$feb14625, $fffc5e91, $ffe08814, $0
	.dc.s	$40000000, $0, $82, $0
	.dc.s	$feb14625, $844f7, $ffe08814, $0
	.dc.s	$40000000, $0, $82, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$feb1f7cf, $fffeded6, $1fffa2, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$feb1f7cf, $fffeded6, $ffdfe6f4, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe71df3c, $fffeded6, $ffdfe701, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$feb1f7cf, $fffeded6, $1fffa2, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe71df3c, $fffeded6, $ffdfe701, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$fe71df3b, $fffeded6, $1fffa1, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$feb1f7cf, $fffeded6, $1fffa2, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	$fe71df3b, $fffeded6, $1fffa1, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	$feb1f7cf, $fffeded6, $1fffa2, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	3,_material_0x946530,0,1
	.dc.s	$ffefcf30, $ffff9e1c, $179d0659, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1030d0, $ffff9e1c, $179d0659, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1030d0, $ffff9e1c, $e862f9a7, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x946530,0,1
	.dc.s	$1030d0, $ffff9e1c, $e862f9a7, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffefcf30, $ffff9e1c, $e862f9a7, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffefcf30, $ffff9e1c, $179d0659, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$21d6ee, $fffc5e91, $feb3a4dd, $0
	.dc.s	$c0000000, $0, $5f, $0
	.dc.s	$21d6ee, $1209, $feb3a4dd, $0
	.dc.s	$c0000000, $0, $5f, $0
	.dc.s	$21d6ee, $1209, $fe700fdf, $0
	.dc.s	$c0000000, $0, $5f, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$21d6ee, $fffc5e91, $feb3a4dd, $0
	.dc.s	$c0000000, $0, $5f, $0
	.dc.s	$21d6ee, $1209, $fe700fdf, $0
	.dc.s	$c0000000, $0, $5f, $0
	.dc.s	$21d6ee, $fffc5e91, $fe700fdf, $0
	.dc.s	$c0000000, $0, $5f, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f77e7, $fffc5e91, $feb14625, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21d6ee, $fffc5e91, $feb3a4dd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21d6ee, $fffc5e91, $fe700fdf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f77e7, $fffc5e91, $feb14625, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21d6ee, $fffc5e91, $fe700fdf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1f77e7, $fffc5e91, $fe726f1a, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f77e7, $844f7, $feb14625, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$1f77e7, $fffc5e91, $feb14625, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$1f77e7, $fffc5e91, $fe726f1a, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f77e7, $844f7, $feb14625, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$1f77e7, $fffc5e91, $fe726f1a, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	$1f77e7, $844f7, $fe726f1a, $0
	.dc.s	$40000000, $0, $ffffffa0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$21d6ee, $fffc5e91, $fe700fdf, $0
	.dc.s	$5f, $0, $40000000, $0
	.dc.s	$21d6ee, $1209, $fe700fdf, $0
	.dc.s	$5f, $0, $40000000, $0
	.dc.s	$ffde41e3, $1209, $fe700fdf, $0
	.dc.s	$5f, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$21d6ee, $fffc5e91, $fe700fdf, $0
	.dc.s	$5f, $0, $40000000, $0
	.dc.s	$ffde41e3, $1209, $fe700fdf, $0
	.dc.s	$5f, $0, $40000000, $0
	.dc.s	$ffde41e3, $fffc5e91, $fe700fdf, $0
	.dc.s	$5f, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f77e7, $fffc5e91, $fe726f1a, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21d6ee, $fffc5e91, $fe700fdf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde41e3, $fffc5e91, $fe700fdf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f77e7, $fffc5e91, $fe726f1a, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde41e3, $fffc5e91, $fe700fdf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffe0a0f7, $fffc5e91, $fe726f1b, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f77e7, $844f7, $fe726f1a, $0
	.dc.s	$ffffffa0, $0, $c0000000, $0
	.dc.s	$1f77e7, $fffc5e91, $fe726f1a, $0
	.dc.s	$ffffffa0, $0, $c0000000, $0
	.dc.s	$ffe0a0f7, $fffc5e91, $fe726f1b, $0
	.dc.s	$ffffffa0, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$1f77e7, $844f7, $fe726f1a, $0
	.dc.s	$ffffffa0, $0, $c0000000, $0
	.dc.s	$ffe0a0f7, $fffc5e91, $fe726f1b, $0
	.dc.s	$ffffffa0, $0, $c0000000, $0
	.dc.s	$ffe0a0f7, $844f7, $fe726f1b, $0
	.dc.s	$ffffffa0, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffde41e3, $fffc5e91, $fe700fdf, $0
	.dc.s	$40000000, $0, $ffffffa1, $0
	.dc.s	$ffde41e3, $1209, $fe700fdf, $0
	.dc.s	$40000000, $0, $ffffffa1, $0
	.dc.s	$ffde41e3, $1209, $feb3a4dd, $0
	.dc.s	$40000000, $0, $ffffffa1, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffde41e3, $fffc5e91, $fe700fdf, $0
	.dc.s	$40000000, $0, $ffffffa1, $0
	.dc.s	$ffde41e3, $1209, $feb3a4dd, $0
	.dc.s	$40000000, $0, $ffffffa1, $0
	.dc.s	$ffde41e3, $fffc5e91, $feb3a4dd, $0
	.dc.s	$40000000, $0, $ffffffa1, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe0a0f7, $fffc5e91, $fe726f1b, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde41e3, $fffc5e91, $fe700fdf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde41e3, $fffc5e91, $feb3a4dd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe0a0f7, $fffc5e91, $fe726f1b, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde41e3, $fffc5e91, $feb3a4dd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffe0a0f7, $fffc5e91, $feb14625, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe0a0f7, $844f7, $fe726f1b, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$ffe0a0f7, $fffc5e91, $fe726f1b, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$ffe0a0f7, $fffc5e91, $feb14625, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe0a0f7, $844f7, $fe726f1b, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$ffe0a0f7, $fffc5e91, $feb14625, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	$ffe0a0f7, $844f7, $feb14625, $0
	.dc.s	$c0000000, $0, $60, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffde41e3, $fffc5e91, $feb3a4dd, $0
	.dc.s	$ffffffa1, $0, $c0000000, $0
	.dc.s	$ffde41e3, $1209, $feb3a4dd, $0
	.dc.s	$ffffffa1, $0, $c0000000, $0
	.dc.s	$21d6ee, $1209, $feb3a4dd, $0
	.dc.s	$ffffffa1, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffde41e3, $fffc5e91, $feb3a4dd, $0
	.dc.s	$ffffffa1, $0, $c0000000, $0
	.dc.s	$21d6ee, $1209, $feb3a4dd, $0
	.dc.s	$ffffffa1, $0, $c0000000, $0
	.dc.s	$21d6ee, $fffc5e91, $feb3a4dd, $0
	.dc.s	$ffffffa1, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe0a0f7, $fffc5e91, $feb14625, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffde41e3, $fffc5e91, $feb3a4dd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21d6ee, $fffc5e91, $feb3a4dd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe0a0f7, $fffc5e91, $feb14625, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$21d6ee, $fffc5e91, $feb3a4dd, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1f77e7, $fffc5e91, $feb14625, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe0a0f7, $844f7, $feb14625, $0
	.dc.s	$60, $0, $40000000, $0
	.dc.s	$ffe0a0f7, $fffc5e91, $feb14625, $0
	.dc.s	$60, $0, $40000000, $0
	.dc.s	$1f77e7, $fffc5e91, $feb14625, $0
	.dc.s	$60, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$ffe0a0f7, $844f7, $feb14625, $0
	.dc.s	$60, $0, $40000000, $0
	.dc.s	$1f77e7, $fffc5e91, $feb14625, $0
	.dc.s	$60, $0, $40000000, $0
	.dc.s	$1f77e7, $844f7, $feb14625, $0
	.dc.s	$60, $0, $40000000, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$ffe0005a, $fffeded6, $feb1f7cf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$201908, $fffeded6, $feb1f7cf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$2018fa, $fffeded6, $fe71df3b, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$ffe0005a, $fffeded6, $feb1f7cf, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$2018fa, $fffeded6, $fe71df3b, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffe00059, $fffeded6, $fe71df3c, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$ffe0005a, $fffeded6, $feb1f7cf, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	$ffe00059, $fffeded6, $fe71df3c, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	$ffe0005a, $fffeded6, $feb1f7cf, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	3,_material_0x946530,0,1
	.dc.s	$e7f82eb2, $ffff9e1c, $123658, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1807d14e, $ffff9e1c, $123658, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$1807d14e, $ffff9e1c, $ffedc9a8, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x946530,0,1
	.dc.s	$1807d14e, $ffff9e1c, $ffedc9a8, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$e7f82eb2, $ffff9e1c, $ffedc9a8, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$e7f82eb2, $ffff9e1c, $123658, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14c5b23, $fffc5e91, $21d6ed, $0
	.dc.s	$ffffff81, $0, $c0000000, $0
	.dc.s	$14c5b23, $1209, $21d6ed, $0
	.dc.s	$ffffff81, $0, $c0000000, $0
	.dc.s	$18ff021, $1209, $21d6ed, $0
	.dc.s	$ffffff81, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14c5b23, $fffc5e91, $21d6ed, $0
	.dc.s	$ffffff81, $0, $c0000000, $0
	.dc.s	$18ff021, $1209, $21d6ed, $0
	.dc.s	$ffffff81, $0, $c0000000, $0
	.dc.s	$18ff021, $fffc5e91, $21d6ed, $0
	.dc.s	$ffffff81, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14eb9db, $fffc5e91, $1f77e6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14c5b23, $fffc5e91, $21d6ed, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18ff021, $fffc5e91, $21d6ed, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14eb9db, $fffc5e91, $1f77e6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18ff021, $fffc5e91, $21d6ed, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18d90e6, $fffc5e91, $1f77e6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14eb9db, $844f7, $1f77e6, $0
	.dc.s	$7e, $0, $40000000, $0
	.dc.s	$14eb9db, $fffc5e91, $1f77e6, $0
	.dc.s	$7e, $0, $40000000, $0
	.dc.s	$18d90e6, $fffc5e91, $1f77e6, $0
	.dc.s	$7e, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14eb9db, $844f7, $1f77e6, $0
	.dc.s	$7e, $0, $40000000, $0
	.dc.s	$18d90e6, $fffc5e91, $1f77e6, $0
	.dc.s	$7e, $0, $40000000, $0
	.dc.s	$18d90e6, $844f7, $1f77e6, $0
	.dc.s	$7e, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18ff021, $fffc5e91, $21d6ed, $0
	.dc.s	$c0000000, $0, $7f, $0
	.dc.s	$18ff021, $1209, $21d6ed, $0
	.dc.s	$c0000000, $0, $7f, $0
	.dc.s	$18ff021, $1209, $ffde41e2, $0
	.dc.s	$c0000000, $0, $7f, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18ff021, $fffc5e91, $21d6ed, $0
	.dc.s	$c0000000, $0, $7f, $0
	.dc.s	$18ff021, $1209, $ffde41e2, $0
	.dc.s	$c0000000, $0, $7f, $0
	.dc.s	$18ff021, $fffc5e91, $ffde41e2, $0
	.dc.s	$c0000000, $0, $7f, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18d90e6, $fffc5e91, $1f77e6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18ff021, $fffc5e91, $21d6ed, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18ff021, $fffc5e91, $ffde41e2, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18d90e6, $fffc5e91, $1f77e6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18ff021, $fffc5e91, $ffde41e2, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18d90e5, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18d90e6, $844f7, $1f77e6, $0
	.dc.s	$40000000, $0, $ffffff7e, $0
	.dc.s	$18d90e6, $fffc5e91, $1f77e6, $0
	.dc.s	$40000000, $0, $ffffff7e, $0
	.dc.s	$18d90e5, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$40000000, $0, $ffffff7e, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18d90e6, $844f7, $1f77e6, $0
	.dc.s	$40000000, $0, $ffffff7e, $0
	.dc.s	$18d90e5, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$40000000, $0, $ffffff7e, $0
	.dc.s	$18d90e5, $844f7, $ffe0a0f6, $0
	.dc.s	$40000000, $0, $ffffff7e, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18ff021, $fffc5e91, $ffde41e2, $0
	.dc.s	$7f, $0, $40000000, $0
	.dc.s	$18ff021, $1209, $ffde41e2, $0
	.dc.s	$7f, $0, $40000000, $0
	.dc.s	$14c5b23, $1209, $ffde41e2, $0
	.dc.s	$7f, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18ff021, $fffc5e91, $ffde41e2, $0
	.dc.s	$7f, $0, $40000000, $0
	.dc.s	$14c5b23, $1209, $ffde41e2, $0
	.dc.s	$7f, $0, $40000000, $0
	.dc.s	$14c5b23, $fffc5e91, $ffde41e2, $0
	.dc.s	$7f, $0, $40000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18d90e5, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18ff021, $fffc5e91, $ffde41e2, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14c5b23, $fffc5e91, $ffde41e2, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18d90e5, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14c5b23, $fffc5e91, $ffde41e2, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14eb9db, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18d90e5, $844f7, $ffe0a0f6, $0
	.dc.s	$ffffff82, $0, $c0000000, $0
	.dc.s	$18d90e5, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$ffffff82, $0, $c0000000, $0
	.dc.s	$14eb9db, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$ffffff82, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$18d90e5, $844f7, $ffe0a0f6, $0
	.dc.s	$ffffff82, $0, $c0000000, $0
	.dc.s	$14eb9db, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$ffffff82, $0, $c0000000, $0
	.dc.s	$14eb9db, $844f7, $ffe0a0f6, $0
	.dc.s	$ffffff82, $0, $c0000000, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14c5b23, $fffc5e91, $ffde41e2, $0
	.dc.s	$40000000, $0, $ffffff81, $0
	.dc.s	$14c5b23, $1209, $ffde41e2, $0
	.dc.s	$40000000, $0, $ffffff81, $0
	.dc.s	$14c5b23, $1209, $21d6ed, $0
	.dc.s	$40000000, $0, $ffffff81, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14c5b23, $fffc5e91, $ffde41e2, $0
	.dc.s	$40000000, $0, $ffffff81, $0
	.dc.s	$14c5b23, $1209, $21d6ed, $0
	.dc.s	$40000000, $0, $ffffff81, $0
	.dc.s	$14c5b23, $fffc5e91, $21d6ed, $0
	.dc.s	$40000000, $0, $ffffff81, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14eb9db, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14c5b23, $fffc5e91, $ffde41e2, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14c5b23, $fffc5e91, $21d6ed, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14eb9db, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14c5b23, $fffc5e91, $21d6ed, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14eb9db, $fffc5e91, $1f77e6, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14eb9db, $844f7, $ffe0a0f6, $0
	.dc.s	$c0000000, $0, $82, $0
	.dc.s	$14eb9db, $fffc5e91, $ffe0a0f6, $0
	.dc.s	$c0000000, $0, $82, $0
	.dc.s	$14eb9db, $fffc5e91, $1f77e6, $0
	.dc.s	$c0000000, $0, $82, $0
	.dc.s	3,_material_0x57412e,0,1
	.dc.s	$14eb9db, $844f7, $ffe0a0f6, $0
	.dc.s	$c0000000, $0, $82, $0
	.dc.s	$14eb9db, $fffc5e91, $1f77e6, $0
	.dc.s	$c0000000, $0, $82, $0
	.dc.s	$14eb9db, $844f7, $1f77e6, $0
	.dc.s	$c0000000, $0, $82, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$14e0831, $fffeded6, $ffe00059, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$14e0831, $fffeded6, $201907, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18e20c5, $fffeded6, $2018f9, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$14e0831, $fffeded6, $ffe00059, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18e20c5, $fffeded6, $2018f9, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$18e20c4, $fffeded6, $ffe00059, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x163172,0,1
	.dc.s	$14e0831, $fffeded6, $ffe00059, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	$18e20c4, $fffeded6, $ffe00059, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	$14e0831, $fffeded6, $ffe00059, $0
	.dc.s	$80000000, $80000000, $80000000, $0
	.dc.s	3,_material_0x946530,0,1
	.dc.s	$ffd96a39, $ffff96ce, $193d1b0, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$262f86, $ffff96ce, $193d1b0, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$262f86, $ffff96ce, $1485f77, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	3,_material_0x946530,0,1
	.dc.s	$262f86, $ffff96ce, $1485f77, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffd96a39, $ffff96ce, $1485f77, $0
	.dc.s	$0, $40000000, $0, $0
	.dc.s	$ffd96a39, $ffff96ce, $193d1b0, $0
	.dc.s	$0, $40000000, $0, $0
