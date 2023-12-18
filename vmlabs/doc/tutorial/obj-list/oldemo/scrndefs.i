;;	dmaScreenWidth = 720
;;	dmaScreenHeight = 480
        dmaScreenWidth = 360
	dmaScreenHeight = 240

        dmaScreenSize = (dmaScreenWidth * dmaScreenHeight * 4)

        dmaScreen1 = (external_ram_base+$18000)
        dmaScreen2 = (dmaScreen1 + dmaScreenSize)
        dmaScreen3 = (dmaScreen2 + dmaScreenSize)
        external_sprites = ((dmaScreen3+dmaScreenSize)+$20000)&$fffffe00

        dmaScreen = dmaScreen2
        TOGGLE = (dmaScreen1 ^ dmaScreen2)

SCRNWIDTH = 360
SCRNHEIGHT = 240
;;SCRNWIDTH = 180
;;SCRNHEIGHT = 120

	dmaPixelType = 4	; 32 bit pixel
	dmaPixelSize = 1	; 32 bit pixel

        dmaPixelWrite = 6

	CLUSTER=(1<<11)
	dmaFlags = (dmaPixelWrite<<13)|((dmaScreenWidth/8)<<16)|(dmaPixelType<<4)|CLUSTER
	
