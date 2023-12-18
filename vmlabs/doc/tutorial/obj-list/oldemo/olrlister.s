
; olrlister.s
;
; show the contents of the first 5 OLR objects
;
; or
;
; show the joystat


	.include	"merlin.i"
    .include    "ol_demo.i"



    .segment    local_ram
    
_base = init_env

ctr = _base
mpenum = ctr+4
logical_mpenum = mpenum+4
memstat = logical_mpenum+4
dest_screen = _base+16
dest = dest_screen+4
rzinf = dest_screen+16
object = rzinf+16

RecipLUT = object+64
SineLUT = RecipLUT+512
RSqrtLUT = SineLUT+1024

dma__cmd = RSqrtLUT+768

line_buffer = dma__cmd+32

    .origin line_buffer+128

membuf: .ds.s   80

inspect = r20
screenpos = r21
obnum = r22

    .segment instruction_ram
    .origin $20300000


    st_s    #($20100000+4*1024),sp
    copy    r2,screenpos
    mv_s    #status+12,r0
    cmp r0,r3               ;quick & dirty check for function
    bra ne,do_olrlist       ;if status+12, doing joydata.
    copy    r3,r1           ;subtype 1 is display the joydata.
    jsr dma_read
    mv_s    #membuf,r2
    mv_s    #1,r0
    jsr dma_finished,nop    ;load joydata
    
    add #64,screenpos       ;skip palette
    copy    screenpos,r1
    jsr dma_read
    mv_s    #6,r0
    mv_s    #line_buffer,r2 ;snarf up all of this tiny screen
    jsr dma_finished,nop

    ld_s    membuf,inspect  ;get the value to show...
    nop
    mv_s    #line_buffer+4,r1
    jsr heXer
    lsl #16,inspect,r2
    mv_s    #2,r3       ;show X     

    mv_s    #line_buffer+12,r1
    jsr heXer
    lsl #24,inspect,r2
    mv_s    #2,r3       ;show Y      

    mv_s    #line_buffer+20,r1
    jsr heXer
    copy inspect,r2
    mv_s    #4,r3       ;show buttons
      
    copy    screenpos,r1
    jsr dma_write
    mv_s    #6,r0
    mv_s    #line_buffer,r2 ;write out modded charmap
    jsr dma_finished,nop
    bra goaty,nop           ;finished


do_olrlist:
    jsr dma_read
    mv_s    #membuf,r2
    mv_s    #80,r0
    jsr dma_finished,nop
    mv_s    #membuf,inspect    

; get a line from the screen

    add #112,screenpos
    st_s    #20,rc0         ;number of lines
    sub obnum,obnum
    
nuline:
    
    copy    screenpos,r1
    jsr dma_read
    mv_s    #12,r0
    mv_s    #line_buffer,r2
    jsr dma_finished,nop
    
; write the object number

    mv_s    #line_buffer+5,r1
    asr #2,obnum,r2
    jsr heXer
    lsl #24,r2
    mv_s    #2,r3            
    
; write 4 hex numbers on this line

    mv_s    #4,r0
    mv_s    #line_buffer+9,r1
hexl:
    mv_s    #8,r3           ;no. of digits
    ld_s    (inspect),r2    ;value to display
    jsr heXer
    add #4,inspect
    nop
    sub #1,r0
    bra ne,hexl,nop

; write out done line
        
    copy    screenpos,r1
{
    jsr dma_write
    add #48,screenpos
}    
    mv_s    #12,r0
    mv_s    #line_buffer,r2
    jsr dma_finished,nop

    add #1,obnum            ;use this linecount to make the object-number    
    dec rc0
    bra c0ne,nuline,nop

goaty:

; get MPE-number

    ld_s    configa,r0
    nop
    bits    #4,>>#8,r0

; flag completion externally (single MPE process)

fin:

    copy    r0,r4
    sub r6,r6

    st_s    r6,object
    lsl #2,r4
    mv_s    #status+16,r1
    add r4,r1
    jsr dma_write
    mv_s    #object,r2
    mv_s    #1,r0
    jsr dma_finished,nop

HaltMPE:

	halt
	nop
	nop

heXer:

; used to write out hex-numbers

    push    v2,rz
heX:    
{
    jsr wriB    
    rot #28,r2,r12
}    
    lsl #4,r2
    bits    #3,>>#0,r12    
    sub #1,r3
    bra ne,heX
    add #1,r1
    nop
    add #1,r1
    pop v2,rz
    nop
    rts

wriB:

; write byte r12 to the address at r1

{
    lsr #2,r1,r8
    mv_s    r1,r9
}                
    lsl #2,r8
{
    ld_s    (r8),r10
}
    bits    #1,>>#0,r9      ;offset...
{
    mv_s    #$ffffff,r11
    lsl #24,r12
}
    lsl #3,r9               ;offset*8
    rot  r9,r11
    ls  r9,r12
    and r11,r10
    rts
    or  r12,r10
    st_s    r10,(r8)
                                 


    .include "dma.s"
