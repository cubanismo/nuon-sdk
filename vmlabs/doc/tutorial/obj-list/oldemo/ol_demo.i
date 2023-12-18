
status = external_ram_base
external_routines = status+32
external_recip = external_routines+1024
external_sine = external_recip+512
external_sqrt = external_sine+1024
external_math_end = external_sqrt+768
 
        dmaScreenWidth = 360
	    dmaScreenHeight = 240

        dmaScreenSize = (dmaScreenWidth * dmaScreenHeight * 4)

        dmaScreen1 = (external_ram_base+$18000)
        dmaScreen2 = (dmaScreen1 + dmaScreenSize)
        dmaScreen3 = (dmaScreen2 + dmaScreenSize)
        dmaScreen = dmaScreen2

        
	dmaPixelType = 4	; 32 bit pixel
	dmaPixelSize = 1	; 32 bit pixel
    dmaPixelWrite = 6

	CLUSTER=(1<<11)
	dmaFlags = (dmaPixelWrite<<13)|((dmaScreenWidth/8)<<16)|(dmaPixelType<<4)|CLUSTER

OLRam = (dmaScreen3 + dmaScreenSize)+$10000
ROLRam = OLRam+$10000


init_env = local_ram_base
