

	.start	goat
	.include	"merlin.i"
    .include    "ol_demo.i"

; The following stuff may be twiddled to configure
; the code for the various examples.

; A lot of this is very preliminary.  Collisions and event-handling in
; particular are being evolved much further over in the Tempest code.

    drawloop =  drawframe_hl      ;use this for all high-level object demos
;    drawloop =  drawframe_olr
;    drawloop =  drawframe_olr2
;    initlist = basic_initlist
;    initlist = multi_initlist
;    initlist = asteroid_initlist
;    initlist = ships_initlist
;    initlist = dwarp_initlist
;    initlist = swarp_initlist
;    initlist = smplsrce_initlist
;    initlist = breakout_initlist    ;early test of some collision detect code
    initlist = feed3_initlist       ;this is similar to the "feed3" demo
;    initlist = bubblewarp_initlist  ;this is similar to the background of "theweb"
;    initlist = 0

    
        .segment    external_ram
        .align.v
_status:
    .dc.s   0,0,0,0         ;status
    .dc.s   0,0,0,0                             

_routines:

; external copy of the Routines table

    .ds.s   256

recips:
     .include    "_reciplut.i"
sines:
     .include    "_sinelut.i"
sqrts:
     .include    "_rsqrtlut.i"

; some useful constants for the object definitions
                        
    UseSine = $200000
    UseRecip = $100000
    UseSqrt = $400000
    IgnoreSplit = $10000
    dma16x16 = $2c840
    dmaread = $2000

; collision mode bit names

COCA = 1
COPOINT = 0
COBOX = 2
COCIRC = 4
CODBEN = 8
CODB = $10
COLEN = $20
COLA = $40

COINF0 = $100
_COINF0 = 8
COINF1 = $200
_COINF1 = 9
COINF2 = $400
_COINF2 = 10
COINF3 = $800
_COINF3 = 11
    

; define th number of rendering MPEs and the screen split height
    
    slice_height = 16
    n_mpes = 3
    base_mpe = 1

; default environment, to be placed on rendering MPEs

init_state:

    .dc.s   0,0,0,$ff00             ;mem status, clock etc

; now the screen state

	.dc.s	dmaFlags				;DMA mode
	.dc.s	dmaScreen2			;Address
	.dc.s	$01660002			;X hi:lo clip
	.dc.s	$00ee0002			;Y hi:lo clip

; render zone info - set up according to the definitions above

	.dc.s	0
	.dc.s	slice_height					;Size of render zones
	.dc.s	n_mpes					;Total number of MPEs
	.dc.s	base_mpe					;to keep vect align



    .align 512

tile_img:

; space for a 16x16 source tile

;    .ds.s   256
;    .include    "flip1.hex"    

    .include    "solidcol.s"
    
tile_img2:

; space for a second 16x16 source tile

;    .ds.s   256
    .include    "solidcol.s"
;    .include    "llama.hex"    
;    .include    "flip1.hex"    
;    .binclude   "flips.ycb"

; now, here are mono 16x16 masks and lists used by
; the sourcetile-generator.

cloud_masks:

    .dc.l   r1_mask,r2_mask,r3_mask,r4_mask

thingy_masks:

    .dc.l   spot_mask,ring1_mask,ring2_mask,ring3_mask,llama_mask     

flipper_masks:

    .dc.l   f1_mask,f2_mask,f3_mask,f4_mask
           

full_mask:

    .include    "full.msk"

f1_mask:

    .include    "f1.msk"

f2_mask:

    .include    "f2.msk"
f3_mask:

    .include    "f3.msk"
f4_mask:

    .include    "f4.msk"


r1_mask:

    .include    "r1.msk"
    
r2_mask:

    .include    "r2.msk"

r3_mask:

    .include    "r3.msk"
    
r4_mask:

    .include    "r4.msk"
    
spot_mask:

    .include    "spot.msk"
    
ring1_mask:

    .include    "ring1.msk"

ring2_mask:

    .include    "ring2.msk"
    
ring3_mask:

    .include    "ring3.msk"

llama_mask:

    .include    "llama.msk"                       

; function numbers
;

    warps = 0   
    line = 1
    hl_obj = 2
    sourcetile = 3
    sprite = 4
    circle = 5
    test = 6
    olr = 6
    lister = 7      ;now all I need are routines called Rimmer, Cat and Kryten
    kryten = 8      ;here's Kryten now
    particle = 9

binaries:     

; here are the binary images of the available object routines.

    .include    "ol_warps.hex"     ;various useful warps
    .include    "ol_line.hex"       ;line/polyline
    .include    "moo_cow.hex"       ;high level OL code
    .include    "sourcetile.hex"    ;sourcetile pattern generator
    .include    "ol_sprite.hex"     ;OL sprites
    .include    "ol_circle.hex"     ;OL circles
    .include    "test_ob.hex"       ;the OLR test object
    .include    "olrlister.hex"     ;HL object that uses a charmapped screen to show the OL
    .include    "kryten.hex"        ;looks after Lists.
;    .include    "ol_particle.hex"   ;for the Particle objects.
        
    .dc.s   $f00baaaa               ;function list terminator    
    .align.v



particleobj:

; Object proto for p-system FX.

	.dc.s	$00000000			;packed 16bit x:y destination position
	.dc.s	$016800f0	 
	.dc.s	$f0808000			;colour of particles
	.dc.s	$f0808000	

    .dc.s   0                   ;X centre deflection (tile mode)
    .dc.s   0                   ;Y centre deflection (tile mode)
    .dc.s   0                   ;Rotate-angle
    .dc.s   $1fff0000           ;Blend intensity
    
    .dc.s   1024                  ;No. of particles
    .dc.s   $10000              ;X-scale                 
    .dc.s   $10000              ;Y-scale
    .dc.s   0
    
    .dc.s   tile_img
    .dc.s   0
    .dc.s   0
    .dc.s   (IgnoreSplit|particle|$00)        ;default subtype 0.


  
clsobj:

; here is a simple object that clears the screen

	.dc.s	$00000000			;packed 16bit x:y destination position
	.dc.s	$016800f0			;size X:Y 
;	.dc.s	$306ef000			;colour to clear screen to
    .dc.s   $10808000
	.dc.s	$f0808000	

    .dc.s   0                   ;if nonzero, external address of a rectangle list
    .dc.s   0,0,0
    
    .dc.s   0,0,0,0
    
    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   (warps|$300)        ;subtype 3 of Warp is plain fill.

chscreenobj:

; here is a charmap-screen object

	.dc.s	$00000030			;packed 16bit x:y destination position
	.dc.s	$016800a8			;size X:Y
	.dc.s	$10808000			;default BG colour
	.dc.s	$f0808000	        ;default FG colour

    .dc.s   48,0,charmap,charset    ;pitch, char map address, char definitions address

   
    .dc.s   0,0        
    .dc.s   0,0
    
    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   (warps|$400)        ;subtype 4 of Warp is charmode 0.

chscreenobj2:

; here is a charmap-screen object

	.dc.s	$00300020			;packed 16bit x:y destination position
	.dc.s	$00380018			;size X:Y 
	.dc.s	$10808000			;default BG colour
	.dc.s	$f0808000	        ;default FG colour

    .dc.s   8,0,charmap2,charset    ;pitch, char map address, char definitions address
    
    .dc.s   0,0,0,0
    
    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   (warps|$400)        ;subtype 4 of Warp is charmode 0.


warpobj:

; here is a Warp object.

	.dc.s	$00400040			;packed 16bit x:y destination position
	.dc.s	$00400040			;size X:Y 
	.dc.s	$0000000			;base page offset (16:16, x)
	.dc.s	$0000000			;base page offset (16:16, y)

	.dc.s	$00010000			;X perturbation magnitude (Doublewarp)
	.dc.s	$00010000			;Y perturbation magnitude (Doublewarp)
	.dc.s	$0001				;Rotate angle
	.dc.s	$0cff0003			;Layer blend/IL mode (Doublewarp)

    .dc.s   (dmaFlags|$2000)
	.dc.s	external_ram_base			;base page address
	.dc.s	0			    ;sourcetile 1 address
	.dc.s	0			    ;sourcetile 2 address

    .dc.s   0               ;Load address of param block
    .dc.s   2               ;Warp innerloop type
    .dc.s   0
    .dc.s   (UseRecip|warps)

lineobj:

; Object List linedraw object

	.dc.s	$00b40078			;x1:y1 (or centre position, for polyline) 
	.dc.s	$00     			;x2:y2
	.dc.s	$ba9b3000			;packed colour 1
	.dc.s	$ba9b3000			;packed colour 2

	.dc.s	$00080008			;packed scales x:y (polyline)
	.dc.s	$cff00002			;Translucency/endpoint radius (radius in low 8 bits)
	.dc.s	$0				;Rotate angle (polyline)
	.dc.s 	playership			;Address of polyline list in external RAM (0 if not a polyline)

    .dc.s   0,0,0,0

    .dc.s	0					;unused (at the moment, future line modes may use)
	.dc.s	0
	.dc.s	0
    .dc.s   (UseRecip|UseSine|UseSqrt|IgnoreSplit|line)

spriteobj:

; here is a Sprite object.

	.dc.s	$00b40078			;packed 16bit x:y destination position
	.dc.s	$016800f0			;size X:Y 
	.dc.s	$00000000			;base page offset (16:16, x)
	.dc.s	$00000000			;base page offset (16:16, y)

	.dc.s	$00010a80			;X scale
	.dc.s	$00010a80			;Y scale
	.dc.s	$0041				;Rotate angle
	.dc.s	$3f000003			;Translucency/Mix  (2:30)

    .dc.s   (dmaFlags|$2000)
	.dc.s	external_ram_base			;base page address
	.dc.s	$00808000			;transparent pixel value
	.dc.s	$40c08000			;target value for tint

    .dc.s   0
    .dc.s   0
    .dc.s   0
	.dc.s	(UseSine|UseRecip|sprite)
    
; now here are some definitions of the HL object types.

    source_tile1 = 0
    quick_warp = 1
    cursor_1 = 2
    cursor_2 = 3
    ship_1 = 4
    ship_2 = 5
    ship_3 = 6
    ship_4 = 7
    ship_5 = 8
    ship_6 = 9
    aster_1 = 10
    blur_field = 11
    clear_block = 12
    llama_1 = 13
    olr_show = 14
    double_warp = 15
    source_tile2 = 16
    single_warp1 = 17
    fullscreen_feedback = 18
    show_sourcetile = 19
    source_tile0 = 20
    bouncy_llama = 21
    show_joystat = 22
    analog_joysim = 23
    breakout_brick = 24
    breakout_bat = 25
    breakout_ball = 26
    breakout_border = 27
    warp_tile = 28
    feedback2 = 29
    source_tile4 = 30

MooProtos:

; here are the addresses of the HL object prototypes.

    .dc.s   stile       ;source tile
    .dc.s   qwarp       ;quick-warp
    .dc.s   curs_1    ;cursor
    .dc.s   curs_2    ;cursor
    .dc.s   sh_1        ;ship
    .dc.s   sh_2        ;ship
    .dc.s   sh_3        ;ship
    .dc.s   sh_4        ;ship
    .dc.s   sh_5        ;ship
    .dc.s   sh_6        ;ship
    .dc.s   aster       ;asteroid
    .dc.s   blurf       ;blur field
    .dc.s   clear       ;clear block
    .dc.s   llam        ;llama
    .dc.s   olrll       ;OLR lister
    .dc.s   doublwrp    ;double-warp
    .dc.s   stile2      ;source tile
    .dc.s   swarp1      ;single warp
    .dc.s   fsfeed      ;full-screen feedback
    .dc.s   shsrc       ;show sourcetile
    .dc.s   stile0      ;source tile
    .dc.s   bllama      ;bouncy llama
    .dc.s   showjoy     ;charmap to show joy-stat
    .dc.s   joy_sim     ;simulate analog stick
    .dc.s   break_brick ;a Breakout brick based on Quick Warp.
    .dc.s   break_bat ;a Breakout bat
    .dc.s   break_ball ;a Breakout ball
    .dc.s   break_bord ;a Breakout border
    .dc.s   warptile   ;PS object for test
    .dc.s   feed2       ;feedback variant
    .dc.s   stile4      ;sourcetile variant
    
; Now, here are the actual HL object prototypes.

stile:
    .include    "sourcetile.moo"
qwarp:
    .include    "qwarp.moo"
curs_1:
    .include    "cursor1.moo"    
curs_2:
    .include    "cursor2.moo"
sh_1:
    .include    "ship1.moo"
sh_2:
    .include    "ship2.moo"
sh_3:
    .include    "ship3.moo" 
sh_4:
    .include    "ship4.moo"  
sh_5:
    .include    "ship5.moo"  
sh_6:
    .include    "ship7.moo"    
aster:
    .include    "asteroid.moo"
blurf:
    .include    "blurfield.moo"   
clear:
    .include    "cls.moo" 
llam:
    .include    "llama.moo"
olrll:
    .include    "olrlister.moo"     
doublwrp:
    .include    "dblwarp.moo"    
stile2:
    .include    "sourcetile2.moo"
swarp1:
    .include    "snglwarp.moo"    
fsfeed:
    .include    "feedback.moo"    
shsrc:
    .include    "shsrce.moo"
stile0:
    .include    "sourcetile3.moo"
bllama:
    .include    "llama5.moo"    
showjoy:
    .include    "joydat.moo"    
joy_sim:
    .include    "joysim.moo"    
break_brick:
    .include    "bobrick1.moo"
break_bat:
    .include    "bobat.moo"
break_ball:
    .include    "boball.moo"
break_bord:
    .include    "bobord1.moo"
warptile:
    .include    "warp_tile.moo"
feed2:
    .include    "feedback2.moo"    
stile4:
    .include    "sourcetile4.moo"
    
    
; Here are the external parts of the Asteroid definition.

null_ranges:
ast_ranges:

	.dc.s	-$20
	.dc.s	$188	
	.dc.s	$f0
	.dc.s	$ffff
	.dc.s	$1680000
	.dc.s	$f00000
	.dc.s	0
	.dc.s	-$20
	.dc.s	$20
	.dc.s	$80,0,0,0,0,0,0

ast_command:

    .ascii  "D1=h"          ;set polyline address in object
    .ascii  "E1=e"          ;set scales in object
    .ascii  "A0!=a<"        ;set XY position
    .ascii  "B0!=a>"
	.ascii	"C[63]=g"       ;set rotate angle
	.ascii	"D[82]=c0"      ;generate Y
	.ascii	"E[92]=c1"      ;generate Cr
	.ascii	"F[92]=c2"      ;generate Cb
	.ascii	"c=d:"          ;copy colour 1 to colour 2

    .align 4
    
null_command:

    .ascii  "a=a:"

	.align.v
    

list_array:

; the OL setup builds a series of linked lists and puts
; their current pointers here in the order they are
; created.

    .dc.s   0,0,0,0,0,0,0,0

feed3_initlist:

; sets up objects to look like the old "feed3" demo

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (source_tile4<<16)|1    ;source tile manipulation
    .dc.l   (feedback2<<16)|1       ;a tile of warp-stuff
    .dc.l   (warp_tile<<16)|1       ;a tile of warp-stuff
    .dc.l   -1

bubblewarp_initlist:

; sets up objects to look like the old background from "theweb"

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (source_tile4<<16)|1    ;one instance of sourcetile #4
    .dc.l   (source_tile2<<16)|1    ;one instance of sourcetile #2
    .dc.l   (double_warp<<16)|1     ;one instance of the Doublewarp 
    .dc.l   -1

breakout_initlist:

; this initlist will set up Breakout, where the first
; collision-detect will happen.

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
;    .dc.l   (analog_joysim<<16)|1   ;Analog Joystick simulation
    .dc.l   (clear_block<<16)|1      ;one instance of clear block
    .dc.l   (breakout_border<<16)|1  ;the border
    .dc.l   (breakout_ball<<16)|1  ;the ball (goes into COCA)
   .dc.l   (breakout_brick<<16)|128  ;the bricks
    .dc.l   (breakout_bat<<16)|1  ;the bat
    .dc.l   -1


dwarp_initlist:

; this initlist demonstrates the Double-Warp.

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (source_tile1<<16)|1    ;one instance of sourcetile #1
    .dc.l   (source_tile2<<16)|1    ;one instance of sourcetile #2
    .dc.l   (double_warp<<16)|1     ;one instance of the Doublewarp 
;    .dc.l   (fullscreen_feedback<<16)|1 ;enable this for a groOvy display...
    .dc.l   (bouncy_llama<<16)|1         ;one instance of a llama
    .dc.l   -1

swarp_initlist:

; this initlist demonstrates the Translucent Single-Warp.

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (bouncy_llama<<16)|1         ;one instance of a llama
    .dc.l   (source_tile2<<16)|1    ;one instance of sourcetile #2
    .dc.l   (single_warp1<<16)|1     ;one instance of the transparent warp 
    .dc.l   (fullscreen_feedback<<16)|1 ;enable this for a groOvy display...
    .dc.l   -1

smplsrce_initlist:

; this initlist shows a simple source-tile.

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (clear_block<<16)|1      ;one instance of clear block
    .dc.l   (source_tile0<<16)|1    ;one instance of sourcetile #0
    .dc.l   (show_sourcetile<<16)|1 ;a Show Sourcetile object
    .dc.l   -1


ships_initlist:

; this initlist sets up a cloud background and puts various
; spaceships on top of it.

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (analog_joysim<<16)|1   ;Analog Joystick simulation
    .dc.l   (source_tile1<<16)|1    ;one instance of sourcetile #1
    .dc.l   (quick_warp<<16)|1      ;one instance of quickwarp
    .dc.l   (cursor_1<<16)|1        ;a cursor...
    .dc.l   (cursor_2<<16)|1        ;another cursor...
    .dc.l   (ship_1<<16)|1          ;a ship...
    .dc.l   (ship_2<<16)|1          ;another ship...
    .dc.l   (ship_3<<16)|1          ;another ship...
    .dc.l   (ship_4<<16)|1          ;another ship...
    .dc.l   (ship_5<<16)|1          ;another ship...
    .dc.l   (ship_6<<16)|1          ;another ship...
    .dc.l   (show_joystat<<16)|1    ;small screen showing joy status
    
    .dc.l   -1                      ;init list terminator

asteroid_initlist:

; this initlist sets up a screenclear, some asteroids, and a
; spaceship.

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (clear_block<<16)|1      ;one instance of clear block
    .dc.l   (aster_1<<16)|20        ;20x asteroids
    .dc.l   (ship_1<<16)|1          ;a ship...
    .dc.l   -1

basic_initlist:

; real simple init-list.

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (clear_block<<16)|1     ;one instance of clear block
    .dc.l   (olr_show<<16)|1        ;one instance of OLR-show. Comment this out to disable the OLR display.
    .dc.l   (llama_1<<16)|1         ;one instance of a llama
    .dc.l   -1

multi_initlist:

; real simple multi-instance init-list.

    .dc.l   MooProtos               ;pointer to a list of prototypes
    .dc.l   list_array              ;pointer to a list of linked lists
    .dc.l   (clear_block<<16)|1      ;one instance of clear block
;    .dc.l   (olr_show<<16)|1        ;one instance of OLR-show
;    .dc.l   (llama_1<<16)|20         ;20 instances of a llama
    .dc.l   -1


; here are some polyline definitions, which are used to
; make the little ships..

asteroid:

    .dc.s   $ff400020
    .dc.s   $ffa0ff40
    .dc.s   $0020ff60
    .dc.s   $0080ff40
    .dc.s   $00e0ffa0
    .dc.s   $00600020
    .dc.s   $006000c0
    .dc.s   $ff8000a0
    .dc.s   $ff400020
    .dc.s   $80000001

playership:

    .dc.s   $ff400000
    .dc.s   $00c0ff80
    .dc.s   $0080ffe0
    .dc.s   $00800020
    .dc.s   $00c00080
    .dc.s   $ff400000
    .dc.s   $80000001

cursor1:

    .dc.s   $ff20ff60
    .dc.s   $ff60ff60
    .dc.s   $ff60ff20
    .dc.s   $ffc0ffc0
    .dc.s   $ff20ff60
    .dc.s   $80000002
    .dc.s   $00e0ff60
    .dc.s   $00a0ff60
    .dc.s   $00a0ff20
    .dc.s   $0040ffc0
    .dc.s   $00e0ff60
    .dc.s   $80000002
    .dc.s   $ff2000a0
    .dc.s   $ff6000a0
    .dc.s   $ff6000e0
    .dc.s   $ffc00040
    .dc.s   $ff2000a0
    .dc.s   $80000002
    .dc.s   $00e000a0
    .dc.s   $00a000a0
    .dc.s   $00a000e0
    .dc.s   $00400040
    .dc.s   $00e000a0
    .dc.s   $80000001
    
plship2:

    .dc.s   $ff200000
    .dc.s   $0000ffc0
    .dc.s   $ffa0ff80
    .dc.s   $00e0ff20
    .dc.s   $0040ff80
    .dc.s   $00800000
    .dc.s   $00400080
    .dc.s   $00e000e0
    .dc.s   $ffa00080
    .dc.s   $00000040
    .dc.s   $ff200000
    .dc.s   $80000001    

plship3:

    .dc.s   $ff200000
    .dc.s   $0000ffc0
    .dc.s   $00e0ff20
    .dc.s   $ffe00000
    .dc.s   $00e000e0
    .dc.s   $00000040
    .dc.s   $ff200000
    .dc.s   $80000001
    
lland:

    .dc.s   $00e0ff20
    .dc.s   $00e0ff40
    .dc.s   $0040ff40
    .dc.s   $0000ffa0
    .dc.s   $ffc0ff60
    .dc.s   $ff80ff60
    .dc.s   $ff40ffa0
    .dc.s   $ff400060
    .dc.s   $ff8000a0
    .dc.s   $ffc000a0
    .dc.s   $00000060
    .dc.s   $0000ffa0
    .dc.s   $0080ffa0
    .dc.s   $0080ffe0
    .dc.s   $00a0ffc0
    .dc.s   $00a00040
    .dc.s   $00800020
    .dc.s   $00800060
    .dc.s   $00000060
    .dc.s   $004000c0
    .dc.s   $00e000c0
    .dc.s   $00e000e0
    .dc.s   $80000002
    .dc.s   $00e0ff40
    .dc.s   $00e0ff60
    .dc.s   $80000002
    .dc.s   $0080ffe0
    .dc.s   $00800020
    .dc.s   $80000002
    .dc.s   $00e000a0
    .dc.s   $00e000c0
lland_xtra:    .dc.s   $80000001    
    .dc.s   $00a0ffe0
lland_tail:    .dc.s   $00f00000
    .dc.s   $00a00020
    .dc.s   $80000001

bat:
    .dc.s   $ffe0ff80
    .dc.s   $ffe00080
    .dc.s   $00200080
    .dc.s   $0020ff80
    .dc.s   $ffe0ff80
    .dc.s   $80000001
    

llama:

	.dc.s	$ffc6ffd9,$ffd0ffe0,$fff0ffe3,$fff3fff0			;a llovely llovely llama
	.dc.s	$fff3002a,$fff00030,$fff20035,$fff70037
	.dc.s	$fff50034,$fff30030,$fff6002a,$0035002a
	.dc.s	$00350020,$00300026,$00130025,$000e0018
	.dc.s	$0010fff9,$0014fff0,$0035fff0,$0035ffe4
	.dc.s	$0030ffe9,$0010ffe8,$000affe0,$0000ffd9
	.dc.s	$ffdcffd7,$ffd9ffce,$ffd4ffce,$ffd0ffdb
	.dc.s	$ffc6ffd9,$80000001

; Here is a "raw" OLR list.

raw_olrlist:

;
; VERY simple object to test the OL renderer

testobj:

	.dc.s	$51f05a00	;red
	.dc.s	$91223600	;green
	.dc.s	$306ef000	;blue
	.dc.s	$71deca00	;pink

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	0

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	0

	.dc.s	0
	.dc.s	0
	.dc.s	0
	.dc.s	test		;object type

; here is a Circle OLR object structure.

	.dc.s	$00c00050			;packed 16bit x1:y1
	.dc.s	$00406000			;size X:Y (sprite or p-txture) 
								;radius/linewidth (circle)
								;x2:y2	(line)
	.dc.s	$f0808001			;packed colour 1/type
	.dc.s	$f3393100			;packed colour 2/type

	.dc.s	$01000100			;packed scales x:y (sprite, circle)
	.dc.s	$f1002000			;Translucency/border thickness (line)
	.dc.s	0					;0 = Open 1 = Filled
	.dc.s	0					;unused

	.dc.s	0					;unused
	.dc.s	0
	.dc.s	0
	.dc.s	0

	.dc.s	0					;unused
	.dc.s	0
	.dc.s	0
	.dc.s	(UseRecip|UseSqrt|circle)

; here is a Circle OLR object structure.

fcircobj:

	.dc.s	$005000a0			;packed 16bit x1:y1
	.dc.s	$0060e000			;size X:Y (sprite or p-txture) 
								;radius/linewidth (circle)
								;x2:y2	(line)
	.dc.s	$d7538f01			;packed colour 1/type
	.dc.s	$f3393100			;packed colour 2/type

	.dc.s	$01000080			;packed scales x:y (sprite, circle)
	.dc.s	$f1002000			;Translucency/border thickness (line)
	.dc.s	1					;0 = Open 1 = Filled
	.dc.s	0					;unused

	.dc.s	0					;unused
	.dc.s	0
	.dc.s	0
	.dc.s	0

	.dc.s	0					;unused
	.dc.s	0
	.dc.s	0
	.dc.s	(UseRecip|UseSqrt|circle)


; here is a Sprite OLR object.

	.dc.s	$011000a0			;packed 16bit x:y destination position
	.dc.s	$00100010			;size X:Y 
	.dc.s	$00000000			;base page offset (16:16, x)
	.dc.s	$00000000			;base page offset (16:16, y)

	.dc.s	$00060000			;X scale
	.dc.s	$00070000			;Y scale
	.dc.s	$0c01				;Rotate angle
	.dc.s	$2cff0002			;Translucency/Type  (2:30)

    .dc.s   (dma16x16|dmaread)
	.dc.s	tile_img			    ;base page address
	.dc.s	$00808000			;transparent pixel value
	.dc.s	$40c08000			;target value for tint

    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   (UseRecip|UseSine|UseSqrt|sprite) 

; Object List linedraw OLR object

	.dc.s	$00b40078			;x1:y1 (or centre position, for polyline) 
	.dc.s	$00b40078			;x2:y2
	.dc.s	$ba9b3000			;packed colour 1
	.dc.s	$ba9b3000			;packed colour 2

	.dc.s	$01800180			;packed scales x:y (polyline)
	.dc.s	$cff00008			;Translucency/endpoint radius (radius in low 8 bits)
	.dc.s	$500				;Rotate angle (polyline)
	.dc.s 	llama			    ;Address of polyline list in external RAM (0 if not a polyline)

    .dc.s   0,0,0,0

    .dc.s	0					;unused (at the moment, future line modes may use)
	.dc.s	0
	.dc.s	0
    .dc.s   (UseRecip|UseSine|UseSqrt|IgnoreSplit|line)

msprite:

; here is a Sprite OLR object.

	.dc.s	$00400040			;packed 16bit x:y destination position
	.dc.s	$00100010			;size X:Y 
	.dc.s	$00000000			;base page offset (16:16, x)
	.dc.s	$00000000			;base page offset (16:16, y)

	.dc.s	$00050000			;X scale
	.dc.s	$00040000			;Y scale
	.dc.s	-$0c01				;Rotate angle
	.dc.s	$2cff0003			;Translucency/Type  (2:30)

    .dc.s   (dma16x16|dmaread)
	.dc.s	tile_img			    ;base page address
	.dc.s	$00808000			;transparent pixel value
	.dc.s	$40c08000			;target value for tint

    .dc.s   0
    .dc.s   0
    .dc.s   0
    .dc.s   (UseRecip|UseSine|UseSqrt|sprite) 


; OLR End object

    .dc.s   0,0,0,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,0
    .dc.s   0,0,0,$800000ff   ;OL terminator   

    .align.v

charmap:

    .include    "test.chm"

charmap2:

    .include    "joylook.chm"    


    
charset:

    .include    "charset.ch8"


	.segment	local_ram

; here are some variables for the main loop    

    .align.v
    
ctr:    .dc.s   10
param0: .dc.s   0
dest:   .dc.s   dmaScreen2                      
last:   .dc.s   0
olbase: .dc.s   0
joy_xcen:   .dc.s   0
joy_ycen:   .dc.s   0
cframe:  .dc.s   0
    .align.v
buffer: .ds.s   64
routines:   .ds.s   256                 ;up to 64 routines    
dma__cmd:   .dc.s   0,0,0,0,0,0,0,0
object: .ds.s   16
lllama:
    .include    "llama.hex"

	ranmsk = r28	;mask for pseudo random seq gen
	ranseed = r29	;seed for above


	.segment	instruction_ram

goat:


	st_s	#(local_ram_base+4096),sp
    st_s    #$aa,intctl           ;turn off any existing video

    jsr InitBinaries,nop        ;set up the Routines table    


; write local copy of llama sprite to external ran

;    mv_s    #dma16x16,r0
;    mv_s    #tile_img,r1
;    mv_s    #$100000,r2
;    mv_s    r2,r3
;    st_v    v0,dma__cmd
;    mv_s    #lllama,r4
;    jsr dma_finished
;    st_s    r4,dma__cmd+16
;    st_s    #dma__cmd,mdmacptr
    
; set up the OLR environment

    jsr InitOLREnv,nop    

    jsr SetUpVideo,nop         ;initialise video


    mv_s    #initlist,r6  ;pass in address of init-list
    sub r4,r4                   ;zero in r4 means run init-mode
    cmp #0,r6                   ;zero initlist means not using HL objects at all.
    bra eq,loop                 ;so skip this bit
    mv_s    #OLRam,r5           ;spare RAM to build an OL at
    jsr run1                    ;run on one MPE
;    mv_s    #hl_obj,r0          ;run HL object handler
    mv_s    #kryten,r0          ;run HL object handler
    mv_s    #base_mpe,r1        ;do it on the base MPE
    jsr WaitMPEs,nop            ;wait for MPE3 to complete.


    jsr calibrate,nop           ;set up joystick


                                ;kate barridge

; now a valid OL should be set up at <OLRam>.

loop:

; here is the main loop that draws the screen

    ld_s    ctr,r0          ;run a framecounter
    nop
    add #1,r0
    st_s    r0,ctr

    mv_s    #dmaScreenSize,r0       ;this lot selects one of
    mv_s    #dmaScreen3,r3          ;three drawscreen buffers
    ld_s    dest,r1                 ;this should be inited to a
                                    ;valid screen buffer address
    nop
    cmp     r3,r1
    bra     ne,updatedraw
{
    mv_s    r1,r2                   ;save prevFrame (feedback
    add     r0,r1                   ;effects can use it)
}
    st_s    r2,last                 ;save prev frame
    mv_s    #dmaScreen1,r1          ;reset buffer base
updatedraw:
    st_s    r1,dest                 ;set current drawframe address

    ld_s    __fieldcount,r0
    nop
    st_s    r0,cframe                ;set current frame #

    jsr drawloop,nop

    ld_s    dest,r0         ;get address we just wrote to...
    jsr SetVidBase,nop


oneframe:

; wait until at least one frame is passed

    ld_s    __fieldcount,r0
    ld_s    cframe,r1
    nop
    cmp r1,r0
    bra eq,oneframe,nop


    bra loop,nop



drawframe_olr:

; draw a raw OLR list.

    st_s    #0,param0       ;zero means list mode
    mv_s    #raw_olrlist,r0 ;list to draw
    st_s    r0,olbase       ;base of the OL
    push    v0,rz
    jsr LoadRunOLR,nop         
    jsr WaitMPEs,nop
    pop v0,rz
    nop
    rts t,nop

drawframe_olr2:

; use Oneshot mode to draw multiple sprites.

    push    v0,rz
    mv_s    #testobj,r0
    st_s    r0,olbase       ;object to draw 
    jsr LoadRunOLR_Oneshot,nop         
    jsr WaitMPEs,nop

; load a copy of the Sprite object to local RAM

    mv_s    #16,r0
    jsr dma_read
    mv_s    #msprite,r1
    mv_s    #object,r2
    jsr dma_finished

; loop and draw a bunch of sprites

    mv_s    #$a3000000,ranmsk   ;set up params for a random sequence generator
    mv_s    #$31415926,ranseed
    mv_s    #40,r31             ;# of sprites to draw

sprloop:

; generate a position based on pseudo-random sequence and framecount    
; also generate a rotation.  Update the values in the local
; copy of sprite object, write it to external RAM, and call the object renderer.

    jsr rsg,nop
    asr #14,ranseed,r0
    jsr rsg,nop
    asr #14,ranseed,r1      ;pseudorandom numbers...
    jsr rsg,nop
    asr #14,ranseed,r3
    ld_s    ctr,r2          ;framecount
    nop
    mul r2,r0,>>#16,r0
    mul r2,r1,>>#16,r1      ;position...
    mul r2,r3,>>#8,r3       ;rotation...
    bits    #8,>>#0,r0
    bits    #8,>>#0,r1     ;range to 0..512
    sub #$4c,r0
    sub #$78,r1             ;centre up...
    add r0,r1,r2
    bits    #15,>>#0,r0
    bits    #15,>>#0,r1
    lsl #16,r0
    or  r0,r1               ;pack together X and Y
    st_s    r1,object       ;store XY in local copy of sprite
    st_s    r3,object+24    ;store angle in local copy of sprite

    mv_s    #16,r0
    jsr dma_write           ;write sprite object to external
    mv_s    #msprite,r1
    mv_s    #object,r2
    jsr dma_finished,nop 
    
    mv_s    #msprite,r0
    st_s    r0,olbase       ;object to draw 
    jsr     RunOLR_Oneshot,nop         
    jsr WaitMPEs,nop
    sub #1,r31          ;count off sprites
    bra ne,sprloop,nop

    pop v0,rz
    nop
    rts t,nop    

rsg:

; run the random sequence generator out of Graphics Gems 1

	btst	#0,ranseed
	rts	ne
	rts
	lsr	#1,ranseed
	eor	ranmsk,ranseed


drawframe_hl:

; drawframe using HL object list system

    push    v0,rz
    st_s    #0,param0       ;zero means OLR runs in list mode

    jsr read_analog,nop     ;pass joy stuff to everyone
    lsl #24,r1,r4
    lsl #24,r2,r5
    copy    r0,r6
    neg r5
    jsr get_stat,nop
    copy    r4,r0
    copy    r5,r1
    copy    r6,r3
    jsr put_stat,nop        ;set status in external RAM

    mv_s    #1,r0
    jsr dma_read
    mv_s    #buffer,r2
    mv_s    #list_array,r1
    jsr dma_finished,nop        ;get list address from list_array
    ld_s    buffer,r7
    nop



    mv_s    #ROLRam,r6      ;where to build render object list
    st_s    r6,olbase
    ld_s    last,r4         ;params to pass to moo
    ld_s    dest,r5
    jsr run1         
    mv_s    #hl_obj,r0    ;moo the cow
    mv_s    #base_mpe,r1
    jsr WaitMPEs,nop



    mv_s    #warps,r0    ;run the OL renderer
    jsr LoadRunOLR,nop         
    jsr WaitMPEs,nop

    pop v0,rz
    nop
    rts t,nop
    
read_analog:

; read analog joystick

    ld_s    __joydata,r0

    ld_s    joy_xcen,r3         ;centre X read on startup
    copy    r0,r1
    bits    #7,>>#8,r1          ;extract X
    sub r3,r1                   ;should be centered value

    ld_s    joy_ycen,r3         ;centre X read on startup
    copy    r0,r2
    bits    #7,>>#0,r2          ;extract X
    sub r3,r2                   ;should be centered value

    asr #2,r1                
    asr #2,r2
    rts
    lsl #2,r1
    lsl #2,r2
    
calibrate:

; set up reference values for the joystick

    sub r0,r0
;    st_s    r0,__joydata         ;set invalid
jwait:
    ld_s    __joydata,r0        ;get strig info
    nop
    cmp #0,r0
;    bra eq,jwait,nop            ;wait for valid joydata to appear
    copy    r0,r1
    bits    #7,>>#8,r1          ;extract X
    st_s    r1,joy_xcen            ;set as centre
    bits    #7,>>#0,r0          ;extract Y
    rts
    st_s    r0,joy_ycen
    nop
              
 

    


; here are the includes for the main    
    
    .include    "video.def"
    .include    "olr.s"
    .include    "video.s"
;    .include    "runpipe.s"
    .include    "comms.s"
    .include    "dma.s"       