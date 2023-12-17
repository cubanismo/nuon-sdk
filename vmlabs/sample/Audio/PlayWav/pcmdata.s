; Place PCM data into the "pcmdata" segment so we have the option of
; telling the linker where it should go into memory.
	
	.segment pcmdata

	.export	_Sample1
	.export	_Sample2
	.export	_Sample3
	.export	_Sample4
	
	.align.v
_Sample1:
	.binclude "bassscale.wav"
	
	.align.v
_Sample2:
	.binclude "organscale.wav"

	.align.v
_Sample3:
	.binclude "whyscale.aif"
	
	.align.v
_Sample4:
	.binclude "brassstringsscale.aif"



