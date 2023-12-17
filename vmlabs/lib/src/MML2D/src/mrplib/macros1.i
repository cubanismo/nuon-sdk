
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

;===================================
;	Macros
;===================================
	.macro	setParamAddr	offset, ptrAddr
		add		#offset, r1, r4	
		mv_s	#ptrAddr, r5 
		st_s	r4, (r5)
	.mend


	.macro	storeIndirectDtram	storeInstr, ptrAddr, value, toReg
		mv_s		#ptrAddr, toReg		//STOREIndirectDtram
		ld_s		(toReg), toReg
		nop
		storeInstr	value, (toReg)
	.mend


	.macro	storeSysram		storeInstr, Addr, value, toReg
		mv_s		#Addr, toReg		//STORESysram
		storeInstr	value, (toReg)
	.mend


	.macro	loadIndirectDtram	loadInstr, ptrAddr, fromReg, toReg
		mv_s		#ptrAddr, fromReg	//LOADIndirectDtram
		ld_s		(fromReg), fromReg
		nop
		.nooptimize
		loadInstr	(fromReg), toReg
		nop
		.optimize
	.mend


	.macro	loadSysram		loadInstr, Addr, fromReg, toReg
		mv_s		#Addr, fromReg		//LOADSysram
		loadInstr	(fromReg), toReg
		nop
	.mend


	.macro	STORE	IsGlobal, storeInstr, ptrAddr, value, toReg
		.if (IsGlobal == _FALSE)
			storeIndirectDtram storeInstr, ptrAddr, value, toReg
		.else
			storeSysram storeInstr, ptrAddr, value, toReg
		.endif
	.mend


	.macro LOAD		IsGlobal, loadInstr, ptrAddr, fromReg, toReg
		.if (IsGlobal == _FALSE)
			loadIndirectDtram	loadInstr, ptrAddr, fromReg, toReg
		.else
			loadSysram		loadInstr, ptrAddr, fromReg, toReg
		.endif
	.mend
