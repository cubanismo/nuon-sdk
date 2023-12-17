;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Copyright (c) 2000-2001, VM Labs, Inc., All rights reserved.
;
; NOTICE: VM Labs permits you to use, modify, and distribute this file
; in accordance with the terms of the VM Labs license agreement
; accompanying it. If you have received this file from a source other
; than VM Labs, then your use, modification, or distribution of it
; requires the prior written permission of VM Labs.
;
; Written by Mike Fulton, VM Labs, Inc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Source image data for sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	.data
	.export	_bg360_screen_jpeg, _sz_bg360_screen_jpeg
	.export	_bg720_screen_jpeg, _sz_bg720_screen_jpeg

	.align.v
_bg360_screen_jpeg:
	.binclude "bg360.jpg"
	
_end_bg360_screen_jpeg:
        _sz_bg360_screen_jpeg = _end_bg360_screen_jpeg - _bg360_screen_jpeg
	

	.align.v
_bg720_screen_jpeg:
	.binclude "bg720.jpg"
	
_end_bg720_screen_jpeg:
        _sz_bg720_screen_jpeg = _end_bg720_screen_jpeg - _bg720_screen_jpeg
