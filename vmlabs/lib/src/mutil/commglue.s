/*
 * Copyright (C) 1997-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

	.export _CommSend
_CommSend:
	jmp	__CommSend,nop

	.export _CommSendInfo
_CommSendInfo:
	jmp	__CommSendInfo,nop

	.export _CommRecvInfo
_CommRecvInfo:
	jmp	__CommRecvInfo,nop

	.export _CommRecvInfoQuery
_CommRecvInfoQuery:
	jmp	__CommRecvInfoQuery,nop

	.export _CommSendRecv
_CommSendRecv:
	jmp	__CommSendRecv,nop
	
	.if 0	// already in hooks.s	
	;;
	;; historical compatibility stuff
	;; This may have to be completely re-written some day to
	;; call CommSendInfo, CommRecvInfo, etc.
	;;

	.export __comm_send
__comm_send:
	jmp	_bios__comm_send,nop
	
	.export __comm_recv
__comm_recv:
	jmp	_bios__comm_recv,nop

	.endif
	