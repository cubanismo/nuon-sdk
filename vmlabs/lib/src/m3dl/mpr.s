/*
 * Title	 	MPR
 * Desciption		Merlin Primitive Renderer
 * Version		1.0
 * Start Date		09/16/1998
 * Last Update		03/20/2000
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

	.module mpr

;*
;* Include
;*

	.include "nuon/nuon.i"
	.include "M3DL/dma.i"
	.include "M3DL/pixel.i"
	.include "M3DL/m3dl.i"
	.include "M3DL/mpr.i"

;*
;* Constant Declarations
;*

mdmaprior = 1 			;Main Bus DMA Priority (1,2 or 3)
odmaprior = 1 			;Other Bus DMA Priority (1 or 2)

;*
;* Register Declarations
;*

;*
;* Code Overlay
;*
	.overlay	mprc
	.origin 	instruction_ram_base
;*
;* Import
;*

	.import	MPR_INTable

;*
;* Export
;*

	.export	_MPR_CodeBase
	.export	_MPR_Start
	.export	MPR_Start
	.export	MPR_Recip
	.export	MPR_NextCommand
	.export MPR_WaitMDMAThenNextCommand
	.export	MPR_Waitallbuses
	.export	MPR_FetchInnerCode
	.export	MPR_FetchMainCode
	.export	MPR_FetchTexInfo
	.export	MPR_FetchBmInfo
	.export	MPR_FetchBitmapandClut
	.export	MPR_DoDMA,MPR_DoDMAScramblev1

;*
;* Actual Code
;*
_MPR_CodeBase:

MPR_WaitMDMAThenNextCommand:
	ld_s	(mdmactl),r0		;Read MDMA Control Flags
	nop
	bits	#4,>>#0,r0		;All MDMA Finished ?
	bra	ne,MPR_WaitMDMAThenNextCommand,nop  ;Nope, Wait

MPR_NextCommand:

MPR_UpdateCmdPtr:
;Update Cmd Read Ptr
;Also enables incoming packets because the gpu_recv interrupt may
;have disabled incoming packets due to cache full
	st_s	#1<<7,(intctl)		;Set SW2 Mask
	ld_s	(MPR_PacketReadPtr),r1	;fetch ReadPtr
	nop
	ld_v	(r1),v1			;Read Packet Type
	nop
	bits	#3-1,>>#16,v1[0]	;Extract Packet length
	add	v1[0],>>#-4,r1       	;new ReadPtr
	and	#pbufwrap,r1 		;Wrap around
	st_s	r1,(MPR_PacketReadPtr)	;store new ReadPtr
	st_s	#1<<6,(intctl)		;Clear SW2 Mask

MPR_AwaitCommand:
	ld_s	(MPR_CmdRead),v1[0]	;#of Commands Read
	ld_s	(MPR_CmdWritten),v1[1]	;#of Commands Written
	ld_s	(MPR_PacketReadPtr),v1[2];Ptr Packets
	cmp	v1[0],v1[1]		;Command available ?
       {
	bra	eq,MPR_AwaitCommand,nop	;Nope, Wait
	ld_v	(v1[2]),v0 		;Read Packet 1st Vector
	add	#1,v1[0]		;Increase #of Commands
       }
       ;--------------------------------;bra eq,MPR_AwaitCommand,nop
       {
	st_s	v1[0],(MPR_CmdRead)	;Store new #of Commands read
	add	#0x10,v1[2],v7[1]	;Next Packet Ptr
       }
       {
	mv_s	v1[2],v7[0]		;Current Packet Ptr
	add	#0x10,v7[1],v7[2]	;Next Packet Ptr
       }
       {
	mv_s	#pbufwrap,v1[1]		;Mask Value
	add	#0x10,v7[2],v7[3]	;Next Packet Ptr
       }
       {
	mv_s	#MPR_StartTab,v1[3]	;Ptr Table Main Code
	bits	#4-1,>>#16+3,v0[0]	;Extract Packet Type
       }
       {
	add	v0[0],>>#-3,v1[3]	;Ptr Packet Main Code
       }
       {
	ld_s	(v1[3]),r1		;Read Packet Main Code Start
	add	#4,v1[3]		;Increase Ptr
       }
       {
	bra	MPR_FetchMainCode
	ld_s	(v1[3]),r0		;Read Packet Main Code Size
	and	v1[1],v7[1]		;Wrap around
       }
       {
	and	v1[1],v7[2]		;Wrap around
       }
       {
	st_s	#mprmainbase,(rz)	;Set Entry Address
	and	v1[1],v7[3]		;Wrap around
       }
       ;--------------------------------;bra MPR_FetchMainCode

;* Input:
;*  None
;* Scrambles
;*  r0,r1
MPR_Waitallbuses:
	ld_s	(mdmactl),r0		;Read MDMA Control Flags
	ld_s	(odmactl),r1		;Read ODMA Control Flags
	bits	#4,>>#0,r0		;All MDMA Finished ?
       {
	bra	ne,MPR_Waitallbuses	;Nope, Wait
	bits	#4,>>#0,r1		;All ODMA Finished ?
       }
	bra	ne,MPR_Waitallbuses,nop	;Nope, Wait
       ;--------------------------------;bra ne,MPR_Waitallbuses
	rts	nop			;Done
       ;--------------------------------;rts nop


;* Input:
;*  r0 TexInfo addr to fetch
;* Scrambles
;*  v0
MPR_FetchTexInfo:
       {
	ld_s	(MPR_TexInfoCTag),r3	;TexInfo Cache Tag
	copy	r0,r1			;Source Address
       }
	st_s	r1,(MPR_TexInfoCTag)	;Set new TexInfo Cache Tag
	cmp	r1,r3			;Already in Cache ?
	rts	eq			;Yap, Done
       {
	bra	MPR_DoDMA      		;Fetch phrase
	mv_s	#0x1F,r3		;wait all
       }
	mv_s	#MPR_TexInfoC,r2	;obus Destination addr
       ;--------------------------------;rts eq
	mv_s	#8,r0			;#of bytes to fetch
       ;--------------------------------;bra MPR_DoDMA


;* Input:
;* r0 BmInfo addr to fetch
;*  Scrambles
;*  v0

MPR_FetchBmInfo:
       {
	ld_s	(MPR_BmInfoCTag),r3	;BmInfo Cache Tag
	copy	r0,r1			;Source Address
       }
	st_s	r1,(MPR_BmInfoCTag)	;Set new BmInfo Cache Tag
	cmp	r1,r3			;Already in Cache ?
	rts	eq			;Yap, Done
       {
	bra	MPR_DoDMA      		;Fetch phrase
	mv_s	#0x1F,r3		;wait all
       }
	mv_s	#MPR_BmInfoC,r2		;obus Destination addr
       ;--------------------------------;rts eq
	mv_s	#8,r0			;#of bytes to fetch
       ;--------------------------------;bra MPR_DoDMA


;* Input:
;* r0 Length in bytes
;* r1 Source Address in Sysram
;*  Scrambles
;*  r0,r3 + Dump0
MPR_FetchMainCode:
       {
	ld_s	(MPR_MainT),r3		;Fetch Main Code Tag
	add	#7,r0			;phrase align
       }
       {
	st_s	r1,(MPR_MainT)		;Set New Code Tag
	and	#0xFFFFFFF8,r0		;phrase align
       }
	cmp	r3,r1			;Code in Cache ?
       {
	rts	eq,nop			;Yap, Quit
	mv_s	#mprmainbase,r2		;Main Base Code address
       }
       ;--------------------------------;rts eq
       {
	mv_s	#0x1F,r3		;Wait ODMA (Wait for all)
	bra	MPR_DoDMA,nop		;Nope, Fetch it
       }
       ;--------------------------------;bra MPR_DoDMA

;* Input:
;* r0 Source Address in Sysram
;* r1 Length in bytes
MPR_FetchOuterCode:

;* Input:
;* r0 Inner Loop Code Entry in MPR_INTable
;*  Scrambles
;*  r0,r1,r2,r3,r4
;*  Uses:
;*  Dump0 contents (to backup v1[123])
MPR_FetchInnerCode:
       {
	ld_s	(MPR_InnerT),r3		;Fetch Main Code Tag
	copy	r0,r1			;Set Source address
       }
	st_s	r1,(MPR_InnerT)		;Set New Code Tag
       {
	ld_s	(rz),r4			;Fetch return address
	cmp	r3,r1			;Code in Cache ?
       }
	rts	eq,nop			;Yap, Quit
       ;--------------------------------;rts eq
       {
	mv_s	#MPR_PIXtemp,r2		;Temporary Table Entry
	jsr	MPR_DoDMA		;Fetch Entry
       }
	mv_s	#8,r0			;8 bytes/entry
	mv_s	#0x1F,r3		;Wait ODMA (Wait for all)
       ;--------------------------------;jsr MPR_DoDMA

	;Entry is Fetched, now fetch actual code
       {
	ld_s	(MPR_PIXtemp+4),r0	;Fetch Size
	subm	r3,r3			;Clear r3
       }
       {
	ld_s	(MPR_PIXtemp),r1	;Fetch Start Address
	jsr	MPR_DoDMA		;Fetch Inner Code
	add	#0x10,r3		;DMA Wait Flag (Pending only)
       }
	add	#7,r0			;phrase align
       {
	mv_s	#mprinnerbase,r2	;Destination Address
	and	#0xFFFFFFF8,r0		;phrase align
       }
       ;--------------------------------;jsr MPR_DoDMA
	st_s	r4,(rz)			;Restore return address
	rts	nop			;Done
       ;--------------------------------;rts

;* Input:
;*  r0 Length in bytes (will be rounded up to next multiple of 4)
;*  r1 Source Address in SDRAM/SYSRAM
;*  r2 Destination Address in MPE
;*  r3 Wait MDMA Finished flag 	(0x1F = nothing waiting, nothing pending)
;*				(0x10 = nothing pending)
;*  Output:
;*  r2 Destination address + #of bytes read
;*  Scrambles
;*  r0,r1,r3
;*  Uses:
;*  Dump0 contents (to backup v1)

;*  Note: This code will NOT generate reads crossing page boundaries

MPR_DoDMA:
	st_v	v1,(MPR_Dump+0*16)	;Backup v1
MPR_DoDMAScramblev1:
       {
	st_s	r3,(MPR_DMAwaitflag)	;store wait flag
	asr	#2,r1,r4		;src address in long offsets
       }
       {
	bra    	pl,MPR_DMAmbus		;use main bus (n set by asr)
	mv_s	#addrof(mdmacptr),r7	;dma command ptr
	add	#3,r0			;round length up
       }
       {
	mv_s	#MPR_MDMA1,r3		;dma buffer
	lsr	#2,r0,r5		;#of longs to transfer
       }
       {
	mv_s	#mbusmax,r6		;set (busmax)
	and	#(mbusmax)-1,r4 	;#of longs before read boundary
       }
       ;--------------------------------;bra eq,MPR_dmambus
	mv_s	#MPR_ODMA,r3 		;dma buffer
	mv_s	#addrof(odmacptr),r7	;dma command ptr
       {
	mv_s	#obusmax,r6		;set (busmax)
	and	#(obusmax)-1,r4		;#of longs before read boundary
       }
MPR_DMAmbus:
	;r0 free
	;r1 source
	;r2 destination (on MPE)
	;r3 dma buffer
	;r4 #of longs before read boundary
	;r5 #of longs to transfer
	;r6 busmax (in scalars)
	;r7 addrof(dmacptr)

	sub	r4,r6,r4		;#of longs to read 1st pass
`DMAloop:
	cmp	r4,r5			;currentxsize < totalxsize
       {
	bra	gt,`DMAxsizeok,nop	;size is ok
	sub	#0x10,r7		;set ptr dmactl
       }
       ;--------------------------------;bra gt,`DMAxsizeok
	mv_s	r5,r4			;currentxsize = totalxsize
`DMAxsizeok:
`DMAwpending:
	ld_s	(r7),r0				;read dma control
	nop
       {
	btst	#4,r0				;DMA pending ?
	mv_s	#CONTIGUOUS|LINEAR|READ,r0	;dmaflags
       }
       {
	bra 	ne,`DMAwpending,nop	;Yes,wait for pending to complete
	or	r4,>>#-16,r0		;Insert #of longs to transfer in dmaflags
       }
       ;--------------------------------;bra ne,`DMAwpending,nop
	sub	r4,r5			;totalxsize - currentxsize
       {
	bra	gt,`DMAloop		;loop
	st_v	v0,(r3)			;set dmacommand
	add	#0x10,r7		;ptr dmacptr
       }
       {
	st_s	r3,(r7)			;launch dma
	add	r4,>>#-2,r1		;increase src
       }
       {
	add	r4,>>#-2,r2		;increase dst
	mv_s	r6,r4			;use busmax for next currentxsize
       }
       ;--------------------------------;bra gt,`DMAloop
       {
	ld_s	(MPR_DMAwaitflag),r3	;restore Wait flag
	sub	#0x10,r7,r1		;dmactl & set NE condition
       }
`DMAwait:
       {
	bra	ne,`DMAwait		;wait
	ld_s	(r1),r0			;read dmactl
       }
       {
	rts				;done
	ld_v	(MPR_Dump+0*16),v1	;Restore v1
       }
	and	r3,r0			;wait flag test
       ;--------------------------------;bra ne,`DMAwait
	nop				;rts delay slot
       ;--------------------------------;rts


;* Input:
;* r0 Bitmap Width
;* r1 Bitmap Height
;* (Bitmap & Clut information/ptrs are taken directly from BmInfoC)
;* (Pixmode is taken directly from TexInfoC)
;* Output:
;* None
;* Scrambles:
;* None

MPR_FetchBitmapandClut:
	;Fetch Clut
	ld_s	(MPR_TexInfoC),r2	;Read Texture Information
	st_v	v1,(MPR_Dump+0*16)	;Backup v1
       {
	ld_s	(rz),r3			;Fetch return address
	bits	#4-1,>>#24,r2		;Extract Pixel type (and Ycc bit)
       }
	ld_s	(MPR_BmInfoC+4),v1[0]	;Read Clut Info
	ld_s	(MPR_ClutCTag),v1[3]	;Clut Cache Tag
       {
	st_v	v0,(MPR_Dump+1*16)	;Backup v0
	and	#0xC1FFFFF8,v1[0],r1	;Clut Source address
       }
       {
	bra	eq,FBCnoclut,nop	;Null Ptr, No Clut!
	mv_s	v1[0],v1[1]		;Clut Info
	cmp	v1[0],v1[3]		;Clut already in Cache ?
       }
       {
	bra	eq,FBCclutcached	;Yap, don't re-read
	st_s	v1[0],(MPR_ClutCTag)	;Set new Clut CTag
	and	#0x7,v1[0],r0  		;Extract low 3bits #colors
       }
       {
	mv_s	#MPR_ClutC,r2		;Destination
	bits	#4-1,>>#25,v1[1]	;Extract high 4 bits #colors
       }
       {
	jsr	MPR_DoDMAScramblev1	;Read
	mv_s	#0x10,r3		;DMA Wait (pending only)
       }
       {
	or	v1[1],>>#-3,r0		;Insert high 4 bits #colors
	st_s	#MPR_ClutC<<1,(clutbase)
       }
       {
	st_s	#PIX_16B<<20,(linpixctl);Delay slot 2nd jsr
	lsl	#3,r0			;1 Word/Clut Color
       }

FBCclutcached:
FBCnoclut:
FBCclutdone:
	;Fetch Bitmap
       {
	ld_v	(MPR_Dump+1*16),v0	;Restore v0
	sub	v1[2],v1[2]		;Clear v1
       }
       {
	ld_s	(MPR_BmInfoC),v1[1]	;Read Bitmap Info
	add	#17,v1[2]		;value for utile
       }
       {
 	ld_s	(MPR_BitmapCTag),v1[3]	;Bitmap Cache Tag
	msb	r0,r0			;msb (width)
       }
       {
	subm	r0,v1[2],v1[0]		;utile
	msb	r1,r1			;msb (height)
       }
       {
	subm	r1,v1[2]		;vtile
	bits	#3-1,>>#0,r2  		;Extract Merlin Pixel type
       }
       {
	or	r2,>>#-4,v1[0]		;pixtype | utile
	ld_v	(MPR_Dump+1*16),v0	;Restore v0
       }
       {
	st_s	v1[1],(MPR_BitmapCTag)	;Set new Bitmap CTag
	cmp	v1[1],v1[3]		;Bitmap already in Cache ?
       }
       {
	bra	eq,FBCbmcached		;Yap, don't re-read
	mv_s	r0,v1[0]		;width
	or	v1[0],>>#-4,v1[2]	;pixtype | utile | vtile
       }
       {
	st_s	#MPR_BitmapC,(uvbase)	;Set uvbase
	or	v1[2],>>#-12,v1[0]	;pixtype | utile | vtile | uvwidth
       }
       {
	st_s	v1[0],(uvctl)		;Set uvctl
	ftst	#0xA,<>#4,v1[1]		;Linear Bit Set or Other Bus ?
       }
       ;--------------------------------;bra FBCbmcached
       {
	bra	ne,FBClinearbm		;Yap, use linear transfer code
	and	#0xDFFFFFFF,v1[1]	;Extract Source address
       }
       {
	lsl	#16,r0,v1[2]		;Xpointer & length
	mul	r1,r0,>>#1,r0		;Size in bytes 4bit Width*Height
       }
       {
	mv_s	#HORIZONTAL|PIXEL|READ,v1[0]	;Pixel DMA Flags
	cmp	#PIX_4B,r2		;4Bit transfer ?
       }
       ;--------------------------------;bra FBClinearbm
	;Transfer Bitmap with Bilinear Main Bus DMA

`WMDMA:{
	ld_s	(mdmactl),r3		;Read MDMA Control Flags
	bits	#3-1,>>#0,r2		;Extract Merlin Pixel Type
       }
	or	v1[2],>>#3,v1[0]	;Insert Length
	btst	#4,r3  			;MDMA Pending ?
       {
	bra	ne,`WMDMA,nop		;Yes, Wait
	mv_s	#MPR_MDMA2,r3		;ptr DMA Command+16
	or	r2,>>#-4,v1[0]		;Insert Pixel Type
       }
       {
	st_s	#MPR_BitmapC,(MPR_MDMA2+0x10)	;store Destination addr
	bra	FBCbmdone		;Finished
	lsl	#16,r1,v1[3]		;Ypointer & length
       }
	st_v	v1,(r3)			;store DMA Command
	st_s	r3,(mdmacptr)		;Launch DMA!

FBClinearbm:
	;Transfer Bitmap with Linear Main/Other Bus DMA
       {
	bra	eq,FBCxsizeok,nop	;4Bit, r0 size in bytes ok
	mv_s	v1[1],r1		;Source address
	cmp	#PIX_8B,r2		;8Bit Pixels ?
       }
       {
	bra	eq,FBCxsizeok,nop	;Yap, only double once
	add	r0,r0			;double size (8Bit)
       }
	add	r0,r0			;double size (16Bit)
FBCxsizeok:
	jsr	MPR_DoDMAScramblev1	;Read
	mv_s	#MPR_BitmapC,r2		;Destination address
	mv_s	#0x10,r3		;DMA Wait Flag
FBCbmcached:
FBCbmdone:
	ld_v	(MPR_Dump+1*16),v0	;Restore v0
	ld_s	(uvctl),v1[0]		;Get UVCtl
       {
	st_s	r3,(rz)			;Set return address
	btst	#BMYCCBIT,r2		;YCC bitmap ?
       }
       {
	rts	eq			;Done!
	copy	v1[0],r2		;UVCtl
       }
	ld_v	(MPR_Dump+0*16),v1	;Restore v1
       {
	rts				;Done!
	bset	#28,r2			;Set CHNorm
       }
       ;--------------------------------;rts eq
	st_s	#(1<<28)|(PIX_16B<<20),(linpixctl)	;Set Clut 16B + CHNORM
	st_s	r2,(uvctl)		;Set CHNORM in UVCtl as well
       ;--------------------------------;rts

;* Communication Packet Receive Interrupt
;* Optimal 20 cycles - Worst Case 24 cycles

MPR_CommReceive:
	push	v2			;Backup v2
	ld_v	(MPR_CmdInfo),v2	;Fetch CmdInfo
       	push	r0,cc,rzi2,rz          	;Backup cc
	add	#0x10,v2[1],r0		;Increase Packet Write Ptr
	and	#pbufwrap,r0  		;Wrap around
	cmp	v2[0],r0		;CmdBuffer Full ?
	bra	ne,MPR_CRbufok		;Nope, its ok
	push	v1			;Backup v1
	cmp	#0,v2[2]		;Any Packets Pending ?
       ;--------------------------------;bra ne,MPR_CRbufok
;* Buffer Full, so disable packet reception (st_s does not modify cc)
	st_s	#1<<7,(intctl)		;Set SW2 Mask
MPR_CRbufok:
       {
	bra	ne,MPR_CRnotlastpacket	;Yap, Command not finished
	st_s	#(1<<4),intclr		;Clear Level 2 Interrupt
       }
	ld_v	(commrecv),v1		;Read Incoming Packet
	sub	#1,v2[2]		;Decrease #of Packets Pending
       ;--------------------------------;bra ne,MPR_CRnotlastpacket
;* New Command coming in, decode length
	mv_s	v1[0],v2[2]		;Command 1st Long
	bits	#3-1,>>#16,v2[2]	;Get Command Length
	sub	#1,v2[2] 	 	;Decrease #of Packets Pending
`hang:	bra	mi,`hang,nop		;Loop `hang
MPR_CRnotlastpacket:
       {
	bra 	ne,MPR_CRcmdnotdone	;Branch if Command NOT finished
	st_v	v1,(v2[1])		;Store Packet
       }
       {
	pop	v1			;Restore v1
	add	#0x10,v2[1]		;Increase Packet Write Ptr
       }
	and	#pbufwrap,v2[1]		;Wrap around
       ;--------------------------------;bra ne,MPR_CRcmdnotdone
	add	#1,v2[3]		;Increase #of Commands Written
MPR_CRcmdnotdone:
	pop	r0,cc,rzi2,rz		;Restore cc
	st_v	v2,(MPR_CmdInfo)	;Store CmdInfo
	pop	v2			;Restore v2
	rti	(rzi2),nop		;Return
       ;--------------------------------;rti,nop

;* MPR Recip Subroutine
;* Input:
;*  r0 Value
;*  r1 Fracbits

MPR_Recip:
	.include	"reciphi.s"

.align.v

_MPR_Start:
MPR_Start:
;* PLEASE NOTE:
;* Startup code will be (partially) overwritten by main code!

	;Clear Exception Source
	st_s	#1,(excepclr)			;Clear Halt

	;Set Halt Enable
	st_s	#0xFFFFFFFF,(excephalten)	;Set Halt Enables

	;Mask Interrupts
	st_s	#$aa,(intctl)			;Mask interrupts

	;Set Bus priority
	st_s	#mdmaprior<<5,(mdmactl)		;Set Main Bus priority
	st_s	#odmaprior<<5,(odmactl)		;Set Other Bus priority

	;Enable Level 2 (Communication bus Receive buffer full) Interrupt
	st_s	#0,(commctl)			;Enable Incoming Packets!
	ld_v	(commrecv),v0			;Clear Receive Full

	;Setup Stack
	st_s	#MPR_Stacktop,(sp) 		;Set SP

	;Setup Level 2 Interrupt Address
	st_s	#MPR_CommReceive,(intvec2)	;Set Level 2 Receive Interrupt
	st_s	#4,(inten2sel)			;Enable Level 2 Interrupt

	;Invalidate MPR Cache Tags
	sub_sv	v0,v0				;Clear v0
	st_v	v0,(MPR_CTags)			;Clear Cache Tags
	st_v	v0,(MPR_CTags2)			;Clear Cache Tags

	mv_s	#MPR_CmdBuffer,r0               ;Ptr
       {
	copy	r0,r1				;Ptr
	st_s	r2,(MPR_CmdRead)		;Clear #of Commands Read
       }
	st_v	v0,(MPR_CmdInfo)		;Clear CmdInfo

	;Set CHNORM16bit
	mv_s	#1<<29,v0[1]			;v0[1] 0.5 in 2.30
       {
	copy	v0[1],v0[2]			;v0[2] 0.5 in 2.30
	st_s	#(1<<28)|PIX_16B_WITHZ,(linpixctl)
	subm	v0[0],v0[0]			;Clear v0
       }
	st_p	v0,(MPR_CHNORM16b)		;Store CHNORM vector

	;Main Core
	bra	MPR_AwaitCommand		;Setup Finished

	;Clear Interrupt Sources
	st_s	#1<<4,(intclr)			;Clear Interrupt Source

	;Clear Interrupt 2 Mask (Enable Interrupt)
	st_s	#0x5a,(intctl)			;Clear HW2&SW2
       ;----------------------------------------;bra MPR_AwaitCommand


;*
;* Data Overlay
;*
	.overlay	mprd
	.origin		local_ram_base

;*
;* Export
;*
	.export		_MPR_Data
	.export		MPR_Data
	.export		MPR_PixBuf1, MPR_PixBuf2
	.export		MPR_PixBufeor
	.export		MPR_RecipLUT

	.export		MPR_MDMA1, MPR_MDMA2
	.export		MPR_ODMA
	.export		DMAFL1, SDRAM1, XPLEN1, YPLEN1, MPEAD1
	.export		DMAFL2, SDRAM2, XPLEN2, YPLEN2, MPEAD2
	.export		MPR_MDMAeor

	.export		MPR_CTags
	.export		MPR_BitmapC, MPR_BmC1, MPR_BmC2
	.export		MPR_BmCeor
	.export		MPR_ClutC,MPR_ClutCTag
	.export		MPR_TexInfoC
	.export		MPR_BmInfoC,MPR_BmInfoCTag

	.export		MPR_BitmapCTag

	.export		MPR_PIXtemp
	.export		MPR_GRB32Ycc
	.export		MPR_Dump

	.export		MPR_sbFlags
	.export		MPR_sbSDRAM, MPR_sbDMAF, MPR_sbWINxw, MPR_sbWINyh

	.export		MPR_CHNORM16b
	.export		MPR_TransPix
	.export		MPR_AlphaBackup
	.export		MPR_ExtraColor
	.export		MPR_DLGRBA, MPR_LGRBA, MPR_DGRBA
	.export		MPR_DLUVZ, MPR_LUVZ, MPR_DUVZ
	.export		MPR_PMXWXTPBF, MPR_WXCLXHYCTY

	.export		MPR_P0, MPR_P1, MPR_P2, MPR_P3
	.export		MPR_U0, MPR_U1, MPR_U2, MPR_U3
	.export		MPR_V0, MPR_V1, MPR_V2, MPR_V3
	.export		MPR_iZ0, MPR_iZ1, MPR_iZ2, MPR_iZ3
	.export		MPR_Z0, MPR_Z1, MPR_Z2, MPR_Z3
	.export		MPR_G0, MPR_G1, MPR_G2, MPR_G3
	.export		MPR_R0, MPR_R1, MPR_R2, MPR_R3
	.export		MPR_B0, MPR_B1, MPR_B2, MPR_B3
	.export		MPR_A0, MPR_A1, MPR_A2, MPR_A3
	.export		MPR_X0, MPR_X1, MPR_X2, MPR_X3
	.export		MPR_Y0, MPR_Y1, MPR_Y2, MPR_Y3

	.export		MPR_DX_P
	.export		MPR_L1_P, MPR_L2_P
	.export		MPR_DL1_P, MPR_DL2_P
	.export		MPR_L1_LX, MPR_L1_RX
	.export		MPR_L2_LX, MPR_L2_RX
	.export		MPR_DL1_LX, MPR_DL1_RX
	.export		MPR_DL2_LX, MPR_DL2_RX

	.export		MPR_HGH1, MPR_HGH2
	.export		MPR_LongSide, MPR_QuadFlag, MPR_PolyType
	.export		MPR_YStart
	.export		MPR_Return
	.export		MPR_StartTab
	.export		MPR_BackGroundAlpha
	.export		MPR_InnerT

;*
;* Define
;*

MPR_MDMAeor	=	(MPR_MDMA1^MPR_MDMA2)
MPR_PixBufeor	=	(MPR_PixBuf1^MPR_PixBuf2)
MPR_BmCeor	=	(MPR_BmC1^MPR_BmC2)

;*
;* Actual Data
;*

.align.v
MPR_ClutC:
	.ds.s	(512/4)		;512 bytes

.align.v
MPR_CmdBuffer:
	.ds.v	(pbuflen)	;256 bytes

.align.v
MPR_PixBuf1:
	.ds.s	(pixbuflen/4)	;128 bytes
MPR_PixBuf2:
	.ds.s	(pixbuflen/4)	;128 bytes

.align.v
MPR_BitmapC:
MPR_BmC1:
	.ds.s	(1024/4)	;1024 bytes
MPR_BmC2:
	.ds.s	(1024/4)	;1024 bytes
MPR_TexInfoC:
	.ds.s	(8/4)		;8 bytes
MPR_BmInfoC:
	.ds.s	(8/4)		;8 bytes

.align.v
MPR_CTags:
MPR_BitmapCTag:
	.ds.s	1		;Bitmap Cache Tag
MPR_ClutCTag:
	.ds.s	1		;Clut Cache Tag
MPR_TexInfoCTag:
	.ds.s	1		;Texture Info Cache Tag
MPR_BmInfoCTag:
	.ds.s	1		;Bitmap Info Cache Tag

.align.v
MPR_CTags2:
MPR_MainT:
	.ds.s	1		;Main Code Tag
MPR_OuterT:
	.ds.s	1               ;Outer Code Tag
MPR_InnerT:
	.ds.s	1               ;Inner Code Tag
	.ds.s	1

.align.v
MPR_MDMA1:
DMAFL1:	.ds.s	1
SDRAM1:	.ds.s	1
XPLEN1:	.ds.s	1
YPLEN1:	.ds.s	1
MPEAD1:	.ds.s	1
MPR_CHNORM16b:
	.ds.s	1		;dummy
MPR_PIXtemp:
	.ds.s	1		;Temporary Pixel Buffer
	.ds.s	1		;Temporary Pixel Buffer

MPR_MDMA2:
DMAFL2:	.ds.s	1
SDRAM2:	.ds.s	1
XPLEN2:	.ds.s	1
YPLEN2:	.ds.s	1
MPEAD2:	.ds.s	1
MPR_TransPix:
	.ds.s	1		;#of Transparent Pixels in Inner loop
MPR_AlphaBackup:
	.ds.s	1		;Backup Alpha
MPR_ExtraColor:
	.ds.s	1		;Extra Additive Color

MPR_ODMA:
DMAFL3:	.ds.s	1
SDRAM3:	.ds.s	1
MPEAD3:	.ds.s	1
	.ds.s	1		;Do NOT use

.align.v
MPR_sbSDRAM:
	.ds.s	1		;SDRAM Address
MPR_sbDMAF:
	.ds.s	1		;DMA Flags
MPR_sbWINxw:
	.ds.s	1		;Window X, W
MPR_sbWINyh:
	.ds.s	1		;Window Y, H

.align.v
MPR_CmdInfo:
MPR_PacketReadPtr:
	.ds.s	1		;Read Ptr In CmdBuffer
MPR_PacketWritePtr:
	.ds.s	1		;Write Ptr In CmdBuffer
MPR_PacketsPending:
	.ds.s	1		;#of Incoming Packets Pending
MPR_CmdWritten:
	.ds.s	1		;#of Commands Written

.align.v
MPR_PMXWXTPBF:
	.ds.v	1		;Backup Outer
MPR_WXCLXHYCTY:
	.ds.v	1		;Backup Outer


.align	32
MPR_P0:				;1st Poly Point, Internal Format
MPR_U0:
	.ds.s	1
MPR_V0:
	.ds.s	1
MPR_iZ0:
	.ds.s	1
MPR_Z0:
	.ds.s	1

MPR_G0:
	.ds.w	1
MPR_R0:
	.ds.w	1
MPR_B0:
	.ds.w	1
MPR_A0:
	.ds.w	1
MPR_X0:
	.ds.s	1
MPR_Y0:
	.ds.s	1

MPR_P1:				;2nd Poly Point, Internal Format
MPR_U1:
	.ds.s	1
MPR_V1:
	.ds.s	1
MPR_iZ1:
	.ds.s	1
MPR_Z1:
	.ds.s	1

MPR_G1:
	.ds.w	1
MPR_R1:
	.ds.w	1
MPR_B1:
	.ds.w	1
MPR_A1:
	.ds.w	1
MPR_X1:
	.ds.s	1
MPR_Y1:
	.ds.s	1

MPR_P2:				;3rd Poly Point, Internal Format
MPR_U2:
	.ds.s	1
MPR_V2:
	.ds.s	1
MPR_iZ2:
	.ds.s	1
MPR_Z2:
	.ds.s	1

MPR_G2:
	.ds.w	1
MPR_R2:
	.ds.w	1
MPR_B2:
	.ds.w	1
MPR_A2:
	.ds.w	1
MPR_X2:
	.ds.s	1
MPR_Y2:
	.ds.s	1

MPR_P3:				;4th Poly Point, Internal Format
MPR_U3:
	.ds.s	1
MPR_V3:
	.ds.s	1
MPR_iZ3:
	.ds.s	1
MPR_Z3:
	.ds.s	1

MPR_G3:
	.ds.w	1
MPR_R3:
	.ds.w	1
MPR_B3:
	.ds.w	1
MPR_A3:
	.ds.w	1
MPR_X3:
	.ds.s	1
MPR_Y3:
	.ds.s	1

MPR_DX_P:  			;DX, Internal Format
MPR_DUVZ:
MPR_DX_U:
	.ds.s	1
MPR_DX_V:
	.ds.s	1
MPR_DX_iZ:
	.ds.s	1
MPR_DX_Z:
	.ds.s	1

MPR_DGRBA:
MPR_DX_G:
	.ds.w	1
MPR_DX_R:
	.ds.w	1
MPR_DX_B:
	.ds.w	1
MPR_DX_A:
	.ds.w	1
MPR_DX_X:
	.ds.s	1
MPR_Return:
	.ds.s	1		;Return Address

.align.v
MPR_L1_P:			;1st Left Values, Internal Format
MPR_LUVZ:
MPR_L1_U:
	.ds.s	1
MPR_L1_V:
	.ds.s	1
MPR_L1_iZ:
	.ds.s	1
MPR_L1_Z:
	.ds.s	1

MPR_LGRBA:
MPR_L1_G:
	.ds.w	1
MPR_L1_R:
	.ds.w	1
MPR_L1_B:
	.ds.w	1
MPR_L1_A:
	.ds.w	1
MPR_L1_LX:
	.ds.s	1
MPR_L1_RX:
	.ds.s	1

MPR_L2_P:			;2nd Left Values, Internal Format
MPR_L2_U:
	.ds.s	1
MPR_L2_V:
	.ds.s	1
MPR_L2_iZ:
	.ds.s	1
MPR_L2_Z:
	.ds.s	1

MPR_L2_G:
	.ds.w	1
MPR_L2_R:
	.ds.w	1
MPR_L2_B:
	.ds.w	1
MPR_L2_A:
	.ds.w	1
MPR_L2_LX:
	.ds.s	1
MPR_L2_RX:
	.ds.s	1

.align.v
MPR_DL1_P:			;1st Left Steppers, Internal Format
MPR_DLUVZ:
MPR_DL1_U:
	.ds.s	1
MPR_DL1_V:
	.ds.s	1
MPR_DL1_iZ:
	.ds.s	1
MPR_DL1_Z:
	.ds.s	1

MPR_DLGRBA:
MPR_DL1_G:
	.ds.w	1
MPR_DL1_R:
	.ds.w	1
MPR_DL1_B:
	.ds.w	1
MPR_DL1_A:
	.ds.w	1
MPR_DL1_LX:
	.ds.s	1
MPR_DL1_RX:
	.ds.s	1


MPR_DL2_P:			;2nd Left Steppers, Internal Format
MPR_DL2_U:
	.ds.s	1
MPR_DL2_V:
	.ds.s	1
MPR_DL2_iZ:
	.ds.s	1
MPR_DL2_Z:
	.ds.s	1

MPR_DL2_G:
	.ds.w	1
MPR_DL2_R:
	.ds.w	1
MPR_DL2_B:
	.ds.w	1
MPR_DL2_A:
	.ds.w	1
MPR_DL2_LX:
	.ds.s	1
MPR_DL2_RX:
	.ds.s	1

.align.v
MPR_CmdRead:
	.ds.s	1		;#of Commands Read
MPR_sbFlags:
	.ds.s	1		;Flags of Screen buffer
MPR_HGH1:
	.ds.s	1		;Height of Section 1
MPR_HGH2:
	.ds.s	1		;Height of Section 2


MPR_PolyType:
	.ds.s	1		;Polygon type
MPR_LongSide:
	.ds.s	1		;LongSide Left/Right
MPR_QuadFlag:
	.ds.s	1		;Quadrangle Yes/No
MPR_YStart:
	.ds.s	1		;Discrete Start Y

.align.v
;-------------------------------;Data Section by DMA
_MPR_Data:
MPR_Data:
MPR_RecipLUT:
	.ds.s	64		;256 bytes
MPR_StartTab:
	.ds.s	2			;Break Draw Packet
	.ds.s	2			;Screen Buffer Packet
	.ds.s	2			;Sync Draw Packet
	.ds.s	2			;Screen Conversion Packet
	.ds.s	2			;Blend Color Packet
	.ds.s	2			;Rectangle Packet
	.ds.s	2			;Sprite Packet
	.ds.s	2			;Polygon Packet
	.ds.s	2			;Transparency Mode
	.ds.s	2			;Image Packet
MPR_GRB32Ycc:
	.ds.w	4*3   			;24 bytes
;---------------------------------------;End of Data Section

MPR_BackGroundAlpha:
	.ds.s	1			;Background Alpha
MPR_DMAwaitflag:
	.ds.s	1			;Used in DMA wait routine

.align.v
MPR_Dump:
	.ds.v	4		;4 Vectors 'Dump Space'

.align.v
MPR_Stack:
	.ds.v	5		;80 bytes Stack
MPR_Stacktop:

