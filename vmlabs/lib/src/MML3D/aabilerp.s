/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */
;
	; 3D pipeline pixel drawing function
	; bilinear pixel version
	;

	// CACHESIZE = 8

	; mask for u and v
	//CACHE_UV_MASK = 0x7ffff
	//CACHE_LINE_MASK = 0xfff80000
;
; STACK USAGE:
;	20 long words
;	
;
; pixel generating functions
;
; All of these functions generate a strip of pixels at a time.
; Higher level functions take care of breaking scan lines into
; DMA sized strips, so you don't have to worry about that
; here.
;
; The generated pixels are placed into the space pointed
; to by (xy); the xy addressing registers come already set
; up for this. The uv addressing registers are mostly
; set up to point at the polygon's source texture, except
; that the ru and rv registers are not initialized. That's
; because the "source texture" may mean different things
; to different functions. For procedural texture maps,
; the "source texture" is not the texture itself but rather
; parameters for the texture.
;
; Note that Z buffering is turned on, so pixels should have
; 4 components: Y, Cr, Cb, and Z. The Z component will probably
; have to be copied into the shaded pixel "by hand" from _D_z;
; if you use _D_Vpix to hold the pixel, do a "copy _D_z, _D_Vpixz"
; or equivalent.
;
; Register usage:
; SEE THE FILE "drawregs.i" FOR REGISTER NAMING CONVENTIONS
;
; v0 and v1 (called _D_Vpix and _D_Vtemp) are free and can be
; messed with as you will. Other registers are used by
; higher level code, and must be either preserved unchanged
; or modified in the specific ways mentioned below:
;	_D_lx, _D_rx:		left and right X coordinates: leave unchanged
;	_D_u, _D_v:			texture U and V coordinates (in 16.16 form); update these
;						by adding _D_du and _D_dv to them each pixel
;	_D_i0:				diffuse shading factor (in 2.30 form): update by adding
;						_D_di0 to it on each pixel
;	_D_i1:				specular shading factor (in 2.30 form): update by adding
;						_D_di1 to it on each pixel
;	_D_i2:				misc. shading factor: not used except for phong shading
;	_D_z:				1/Z value (in 2.30 form): update by adding _D_dz to it on
;						each pixel.
;	_D_dlx, _D_drx:		preserve these
;	_D_du, _D_dv, _D_di0, _D_di1, _D_di2, _D_dz:
;						per pixel deltas: these must be preserved
; All other registers: not needed by pixel drawing, but must be preserved
;
; Tip: v2 and v3 are good candidates for scratch registers (if you push them
; first) since they don't contain any of the above values. v4 is used only
; for _D_u and _D_v ; if you put those into ru and rv respectively v4 will then
; be free for temporary use (make sure you preserve it, and update _D_u and _D_v
; back from ru and rv at the end of the strip generation).
;
;
	.module	aabilerp_s
	.include "pipeline.i"
	.include "drawregs.i"

	;
	; v3 is reserved for upper level stuff
	;
	_D_VTRI	=	v3	
	_D_A	=	r12
	_D_B	=	r13
	_D_C	=	r14
	_D_T	=	r15

	.export _aabilerp_init, _aabilerp_end

	u_offset = pixel_data + 0
	v_offset = pixel_data + 4
	u_mask = pixel_data + 8
	v_mask = pixel_data + 12

	u_size = pixel_data + 16
	v_size = pixel_data + 20
		
	_DS_curtexture = pixel_data + 24

;**********************************************
;* _bilerp_init
;* initialization function for pixel drawing
;**********************************************

	;
	; _bilerp_init is called once, at the beginning of
	; the run, with r0 pointing at itself.
	; It should return the address of the
	; per-polygon initialization routine
	;
	; perpoly_init is called once per polygon,
	; with r0 pointing at itself and with r1
	; pointing at the polygon. It should
	; return the actual pixel plotting routine
	; in r0
	;
	
	.align CODEALIGN
	
_aabilerp_init:
	sub	r3,r3
	rts
	st_s	r3,_DS_curtexture
	add	#perpoly_init - _aabilerp_init,r0

;**********************************************
;* perpoly_init
;* initialization function for pixel drawing
;* parameters:
;* r0 == pointer to perpoly_init
;* r1 == pointer to triangle
;**********************************************
perpoly_init:
	push	_D_VTRI
{	add	#8,r1,_D_A		; make r0 point to the texture field of the poly
	push	v0,rz
}

;
; initialize texture data
; all we really require is that the texture header be properly
; loaded; the cache miss routines will take care of the
; data itself
;
;

;
; set up texture access
;
{	ld_s	(_D_A),r1		; get pointer to polygon's texture
	add	#4,_D_A			; now _D_A points at number of points
}
	ld_s	_DS_curtexture,r0	; get what texture is currently in the cache
	cmp	#0,r1			; if the texture pointer is 0, we've
{	bra	eq,done_poly_init,nop	; already initialized for this poly
	ld_s	TEXTURE+4,_D_T		; get material flags 
}
	
	cmp	r0,r1			; if the poly texture is different from
{	bra	ne,force_load,nop	; the cached one, force a load
	btst	#0,_D_T			; check for solid color texture
}
{	bra	ne,solid_poly_init,nop
	bits	#3,>>#28,_D_T	        ; check M3D_MIPMAPLEVEL
} 
	;; if this texture is not a mip-map, and it matches
	;; the one already in the cache, then we don't need
	;; to re-initialize
	bra	eq,texture_in_cache,nop ; if level 0, then not a mip-map
	 
;
; load the texture header into local RAM
; parameters: r0 == address of texture buffer
;	      r1 == address of texture in external RAM
;	      _D_A == pointer into polygon data
;	      _D_T == number of mip-map levels
; 
; Mip-maps are handled as follows: the mip-map levels
; are stored as an array of textures, starting with the
; smallest level and working up to the largest. The M3D_MIPMAPLEVEL
; bits are set to 0 for the largest, 1 for the next largest,
; and so on. If we are at level 0, then we must use the
; current level. Otherwise, we look at the larger
; of abs(dU)*width and abs(dV)*height; if
; this is greater than 0.5, then we're at the right level, otherwise
; we move on to the next level.
; 
	
force_load:	
{	st_s	r1,_DS_curtexture
	
	; check for which bank of memory it's in
	btst	#31,r1
}
{	bra	ne,loadtexture,nop
	mv_s	#addrof(odmactl),r3
	copy	r1,r5			; address of external texture
}
	add	#addrof(mdmactl) - addrof(odmactl),r3

	;;
	;; load the next mip-map texture
	;; register _D_A must be left untouched (it holds a
	;; pointer into the polygon)
	;; register r3 holds the DMA control register address
	;; v1 is used to build the DMA command
	;;
	
loadtexture:

; wait for DMA to be finished
ltwait1:
	ld_s	(r3),r4
	nop
{       mv_s    #dmacmd,r7		; address of command block for transfers
        bits	#4,>>#0,r4
}
	bra	ne,ltwait1
; branch delay slots, always executed
	mv_s	#(4<<16)|(1<<13),r4	; transfer 4 long words in read mode
	mv_s	#TEXTURE,r6		; internal address


	; initiate load of texture header
	; this will be 4 words (so we can get the header and figure out what else to
	; load)
	
	
{       st_v    v1,(r7)
	add	#16,r3			; point to command pointer register
}
{	st_s	r7,(r3)			; start DMA
	add	#4*4,r5			; bump external address
}
	sub	#16,r3			; back to control register
	
	; wait for DMA to finish
ltwait2:
	ld_s	(r3),r0
	copy	_D_dv,r1
	bits	#4,>>#0,r0
{	bra	ne,ltwait2
	mv_s	_D_du,r0
}
	abs	r1
	abs	r0

	; get texture width, height
{	ld_w	(r6),_D_B	; get width as a 16.16 number
	add	#2,r6		; skip width
}
{	ld_w	(r6),_D_C	; get height as a 16.16 number
	add	#2,r6		; skip height
}
{	ld_s	(r6),_D_T	; get material flags
	add	#4,r6
	mul	r0,_D_B,>>#24,_D_B	; _D_B = width*abs(dU), as a 16.16 
}
{	ld_s	(r6),r2			; get DMA flags
	mul	r1,_D_C,>>#24,_D_C	; _D_C = width*abs(dV) as a 16.16
	add	#8,r6			; skip dma flags and address
}
	btst	#0,_D_T			; check flags for solid color texture
{	bra	ne,solid_poly_init,nop
	bits	#3,>>#28,_D_T		; get mip-map level
}
	bra	eq,use_this,nop		; if 0, use this level no matter what

	;; kludge: we should test both _D_B and _D_C, but we're
	;; only really interested in the larger of the two...
	or	_D_B,_D_C		; otherwise, set _D_C = max(_D_B, _D_C)
	cmp	#3,>>#-14,_D_C		// cmp	#fix(0.75,16),_D_C	; check dU and dV at this level 
	bra	lt,loadtexture,nop
	 
use_this:	
	;; use the current texture (or mip-map level)
	bits	#3,>>#4,r2			; extract pixel write mode (0 == 4bpp, 2 == 16bpp, 4 == 32bpp)
	asl	#20,r2			; put it in the uvctl place
	bset	#28,r2			; set chnorm bit 
	st_io	r2,uvctl		; save UVCTL flags for this pixel mode
	
donetexture:

texture_in_cache:
	mv_s	#TEXTURE,r0
{	ld_w	(r0),r2				; get texture width as 16.16
	add	#2,r0				; skip width
}
{	ld_w	(r0),r3				; get texture height as 16.16
	add	#14,r0				; skip height, DMA flags, and data pointer
}
{	st_s	r0,uvbase
	sub	_D_T,_D_T		; zero _D_T
}

	sub	#1,>>#-16,r2		; force coordinates to round down
	sub	#1,>>#-16,r3
{	mul	r2,_D_du,>>#24,_D_du
}
{	mul	r3,_D_dv,>>#24,_D_dv
	sub	#4,_D_A
}
	; now scale all the U,V coordinates so that they are 16.16
	; fixed point numbers in texture size units
	; (so for a 16x8 texture u is in [0,16) and v in [0,8))
	;

{	st_s	_D_T,(_D_A)	;mark polygon as having been processed
	add	#4,_D_A
}
{	ld_s	(_D_A),_D_T		; get number of points into _D_T
	add	#16,_D_A		; now _D_A points at U for first point
}
	
scalelp:
{	ld_s	(_D_A),r0			; get U 
	add	#16,_D_A
}
{	ld_s	(_D_A),r1			; get V
	sub	#16,_D_A
}
{	mul	r2,r0,>>#24,r0		; scale U	
}
{	mul	r3,r1,>>#24,r1		; scale V
}
	add	#1,>>#-15,r0		//add	#fix(0.5,16),r0
	add	#1,>>#-15,r1		//add	#fix(0.5,16),r1
	sub	#1,_D_T			; decrement count of points remaining
	bra	gt,scalelp
{	st_s	r0,(_D_A)			; store U
	add	#16,_D_A
}
{	st_s	r1,(_D_A)			; store V
	add	#16,_D_A			; point to next point's U value
}

done_poly_init:
	;; figure out the cache scaling appropriate for
	;; this polygon, given dU and dV
	;; assumption:	the cache holds 64 pixels at
	;; a time; this is a suboptimal assumption,
	;; since the actual size should depend on the
	;; pixel type

	ld_w	TEXTURE,r2
	ld_w	TEXTURE+2,r3
	lsr	#16,r2
	lsr	#16,r3
	

	;; figure out the U and V sizes based upon the
	;; dU and dV values. Default is to use an
	;; 8x8 square. If the image width*height is <= 64,
	;; then the image width and height are used
	;; note: right now, r2 and r3 hold the width and
	;; height as integers
	
	copy	r3,_D_T
{	msb	_D_du,r0
	mul	r2,_D_T,>>#0,_D_T	; set _D_T = r2 * r3 
}
	msb	_D_dv,r1
{	cmp	#64,_D_T	; is width*height < 64?
	subm	r1,r0		; now r0 contains a relative scaling factor
}
{	bra	le,`use_r2r3,nop
	add	#2,r0		; make 4 the default size
}
{	bra	ge,`bigger_than_0,nop
	msb	r2,r2		; get the MSB of the width
}
	mv_s	#0,r0
`bigger_than_0:
	cmp	#4,r0		; make sure cache width will be <= 16
{	bra	le,`smaller_than_4,nop
	sub	#1,r2		; normalize MSB of width
}
	mv_s	#4,r0
`smaller_than_4:	
	cmp	r2,r0		; if (cache_width - total_width) > 0
	bra	le,`size_ok,nop
	mv_s	r2,r0		; cache_width = total_width
`size_ok:
{	sub	#4,r0,r1	; set v_size = -(4 - u_size) = u_size - 4
	mv_s	#1,r2
}
	
{	neg	r0
	bra	`donecalcs
}
	ls	r0,r2,r0	; set r0 = (1<<r0); this is the u_size
	ls	r1,r2,r1	; set r1 = (1<<r1); this is the v_size

`use_r2r3:
{	mv_s	r2,r0
	copy	r3,r1
}
	
`donecalcs:
	

{	ld_io	uvctl,r2	; get uvctl
	copy	r1,r3
}
{	or	r0,>>#-16,r3
	st_s	r0,u_size
}
{	st_io	r3,uvrange
	and	#$fff00000,r2	; mask off width, and U and V tile bits
}
{	or	r0,>>#-1,r2	;  or in U width * 2
	st_s	r1,v_size
}
	msb	r0,r3		; calculate U tile
{	sub	r3,#16,r3	; U tile = 16 - (msb-1) = 17-msb; however, leave some room for slack
	mul	#1,r0,>>#-16,r0	; asl #16,r0
}

	or	r3,>>#-16,r2
{	msb	r1,r3
	mul	#1,r1,>>#-16,r1	; asl #16,r1
}
	sub	r3,#16,r3	; calculate V tile
	or	r3,>>#-12,r2
{	st_io	r2,uvctl
	sub	#1,r0
}
	sub	#1,r1
	not	r0
{	not	r1
	st_s	r0,u_mask
}
	st_s	r1,v_mask

	;
	; set up to force a cache miss
	; first time through
	;
	mv_s	#fix(4096,16),r0
	st_s	r0,u_offset
	st_s	r0,v_offset

	pop	v0,rz
	pop	_D_VTRI
{	rts	nop
	add	#aabilerppix - perpoly_init,r0
}

	;; special case solid color initialization code
solid_poly_init:
	st_io	#(1<<28)|(4<<20),linpixctl	; set up for pixel type 4
	pop	v0,rz
	pop	_D_VTRI
{	rts	nop
	add	#solidspecpix - perpoly_init,r0
}

;
; Gouraud shaded pixels, with specular highlights,
; bilinearly interpolated.
; 
; pixel color is calculated by:
; P := specular*(1,0,0) + (1-specular)*diffuse*P;

; new, improved code...
;
; Note: we aren't using the third register of
; _D_Vtemp for anything; nor are _D_u and _D_v 
; used once we're in the loop
;
	;; _D_i2 holds anti-aliasing flags, as follows:
	;; bits 21-26: shift value for _D_rx to go 16.16->alpha index
	;; bits 16-20:  shift value for _D_lx to go 16.16->alpha index
	;;		for example, this is 0 for top alpha, 4 for bottom alpha
	;;		use 16 to eliminate it entirely
	;; bits 12-15:	reserved for top alpha
	;; bits 8-11:	reserved for bottom alpha
	;; bits 4-7:	left side alpha
	;; bits 0-3:	right side alpha
	;; the left side alpha will only be needed for
	;; the first pixel, so we clear it out after
	;; that
	
	;; our caller sets up _D_lx, _D_rx, _D_dlx, _D_drx
	;; with additional anti-aliasing info, as follows:
	;; _D_lx == left side alpha blending value
	;; _D_dlx == delta for _D_lx
	;; _D_rx == right side alpha blending value
	;; _D_drx == delta for _D_rx
	
	;; 16 bits of antialiasing info are stored in
	;; the low bits of the Z value of each pixel
	;; (so we're in a 32 bit pixel + 32 bit Z mode)
	;; there are 4 bits each of top, bottom,
	;; left, and right, in that order

	shade = v1[3]

	zexp	= v2[3]
	speccolor=v3[3]
	vfrac = _D_v
	leftalpha = _D_u	; left side alpha value

	// free registers
	const_one = _D_di2
			
	.export aabilerppix
aabilerppix:
	ld_v	u_offset,v0		; sets r1 to v_offset, also
	push	v2
{	sub	r0,_D_u,r0
	push	v3
}
{	sub	r1,_D_v,r1
	mvr	r0,ru			; initialize U
	mv_s	#fix(1.0,30),const_one
}
{	st_io	r1,rv			; initialize V
	range	ru
	and	#$00f0,_D_i2,leftalpha	; initialize left alpha value
}
	
pixloop:
	;
	; check for a cache miss
	; we do this *in parallel* with pixel fetches,
	; which is safe because we've set up the u_tile and
	; v_tile bits to enable wrapping -- out of range
	; u and v will just get the wrong pixel
	;
	
cache_ok:	
{	ld_p	(uv),v0		;  get first pixel (p00)
	addr	#1<<16,ru
	bra	modmi,cache_miss_ru,nop
	msb	_D_z,zexp
}
{	ld_p	(uv),v1		; get second pixel (p01)
	bra	modge,cache_miss_ru,nop
	range	rv
	sub	_D_i1,const_one,shade
}
{	ld_io	rv,vfrac
	addr	#1<<16,rv
	bra	modmi,cache_miss_ru_rv,nop
	sub	#26,zexp,v0[3]
}
{	bra	modge,cache_miss_rv,nop
	ld_p	(uv),v3		; get third pixel (p11)
	addr	#-1<<16,ru
	sub_p	v0,v1		; v1 = p01 - p00
}
{	ld_p	(uv),v2		; get last pixel (p10)
	addr	#-1<<16,rv
	mul_p	ru,v1,>>#30,v1
	bits	#15,>>#0,vfrac	; now vfrac is a 0.16 fixed point number
}
{	ls	v0[3],_D_z,v0[3]
	mul	#1,zexp,>>#-26,zexp ; shift zexp left by 26 
}
{	sub_p	v2,v3
	mv_s	_D_i1,speccolor		; save current specular component
	mul	_D_i0,shade,>>#30,shade	; calculate (1-specular)*diffuse
}
{	mul_p	ru,v3,>>#30,v3
	add_p	v1,v0		; v0 = blend of top two pixels
}
{	sub_p	v0,v2		; v2 will be difference of top and bottom rows
	mul	shade,vfrac,>>#16,vfrac	; vfrac will be a 2.30 shading factor 
}
{	add_p	v3,v2		; v2 = blend of bottom two pixels
	mul_p	shade,v0,>>#30,v0;  shade top blend
}
{	mul_p	vfrac,v2,>>#30,v2
	or	zexp,v0[3]
}
{	addr	_D_du,ru	; update U
	dec	rc1		; count down pixels remaining
	and	#$ffff0000,v0[3]
}
	;; set up left and right side antialiasing stuff
	;; v1 and v3 are free from now until end of loop
	;; if left side alpha
{	sub	_D_lx,#fix(1.0,16),v1[1]
	mv_s	_D_i2,v1[0]
	addm	_D_di0,_D_i0	; update diffuse shading coefficient
}
{	bra	le,skip1
	or	leftalpha,v0[3]
	addm	_D_dlx,_D_lx
}
{	bits	#4,>>#16,v1[0]
	mv_s	#0,leftalpha	; clear leftalpha
}
	and	#$f,<>#-12,v1[1]	//and	#$0000f000,v1[1]

	or	v1[1],>>v1[0],v0[3]	// use lsalpha
	
skip1:
{	sub	_D_rx,#fix(1.0,16),v1[1]
	mv_s	_D_i2,v1[0]
}
{	bra	le,skip2
	sub	_D_drx,_D_rx
}
	bits	#4,>>#21,v1[0]
	and	#$f,<>#-12,v1[1]	//and	#$0000f000,v1[1]

	or	v1[1],>>v1[0],v0[3]	// use rsalpha

skip2:
{	bra	c1ne,pixloop
	addr	_D_dv,rv	; update hardware V
	add_p	v2,v0		; v0 == average of all pixels,already shaded
	addm	_D_di1,_D_i1	; update specular coefficient
}
{	range	ru		;  check U for next time around the loop
	addm	speccolor,v0[0]
}
{	add	_D_dz,_D_z	; update Z
	st_pz	v0,(xy)		; store the new pixel
	addr	#1<<16,rx
}

;* END OF LOOP
{	addr	#-1<<16,rx
	ld_io	ru,_D_u
}
;* apply right side antialiasing
{	ld_pz	(xy),v1
	and	#$f,_D_i2,r0	; isolate right side alpha value
}
	ld_io	rv,_D_v
{	or	r0,v1[3]	; merge right side alpha info
	ld_v	u_offset,v0	; sets r0 to u_offset, r1 to v_offset
}
{	pop	v3
	rts
}
{	pop	v2
	add	r0,_D_u
}
{	add	r1,_D_v
	st_pz	v1,(xy)		; store final pixel with its right side alpha info
}


	;
	; cache miss code
	; come here when ru and/or rv are no
	; longer in range for the cache
	;
	; when that happens, we have to calculate the
	; "real" u,v values and, based upon that, to
	; determine the cache line to load
	;
	
cache_miss_rv:
	bra	cache_miss
	nop
	;; pick up the "addr #-1,rv" from the next
	;; instruction (which is a delay slot)
cache_miss_ru_rv:
	addr	#-1<<16,rv
	;; fall through
	
cache_miss_ru:
	addr	#-1<<16,ru

cache_miss:
	push	v0
	push	v1

	new_u = r6
	new_v = r7
	
	ld_v	u_offset,v0	; sets r0 to u_offset, r1 to v_offset, r2 to u_mask, r3 to v_mask
	ld_io	ru,new_u
	ld_io	rv,new_v
	add	r0,new_u
	add	r1,new_v

	;
	; now new_u and new_v have the
	; "real" u and v values
	; find the texture cache block
	;
	and	new_u,r2
{	and	new_v,r3
	st_s	r2,u_offset
}
{	st_s	r3,v_offset
	sub	r2,new_u
}
{	sub	r3,new_v
	st_io	new_u,ru
}
{	st_io	new_v,rv
	lsr	#16,r2
}
{	lsr	#16,r3
	ld_s	u_size,r4
}
	ld_s	v_size,r5
	;
	; load a (2*u_size x (v_size+1) rectangle
	; from the current texture at coordinates
	; (r2,r3)
	;
	add	r4,r4	; multiply u_size by 2
	add	#1,r5	; add 1 to v_size
	
`ltloop:
{	ld_io	mdmactl,r6
	or	r4,>>#-16,r2	; set up X info
}
{	or	r5,>>#-16,r3	; set up Y info
	ld_s	TEXTURE+8,r0		; get dma flags
}
{	bits	#4,>>#0,r6
	ld_s	TEXTURE+12,r1		; SDRAM address of texture
}
	bra	ne,`ltloop,nop
	
	;
	; set up DMA
	;
	mv_s	#dmacmd+16,r7
	mv_s	#TEXTURE+16,r6		; internal address of texture
{	st_s	r6,(r7)
	sub	#16,r7
}
{	st_v	v0,(r7)
	asl	#16,r2			; get x coordinate in 16.16 form
}
{	st_s	r7,mdmacptr		; start DMA transfer
	asl	#16,r3			; get y coordinate in 16.16 form
}
	add	r4,>>#-16,r2		; now r2 == max. x coordinate read (16.16 form)
	add	r5,>>#-16,r3		; now r3 == max. y coordinate read (16.16 form)
	
`ltdone:
	ld_io	mdmactl,r0		; wait DMA to complete
	ld_w	TEXTURE,r6		; get width in 16.16 form
{	bits	#4,>>#0,r0
	ld_w	TEXTURE+2,r7		; get height in 16.16 form
}
{	bra	ne,`ltdone,nop
	cmp	r2,r6			; if width - max.x >= 0, no problem
}
{	bra	lt,`x_overflow,nop
	cmp	r3,r7
}
	bra	lt,`y_overflow,nop
`no_overflow:
	
{	pop	v1
	bra	cache_ok
}
	pop	v0
	range	rv

	;
	; come here if we read over the edge of the texture
	;
`x_overflow:
	ld_s	u_size,r6	; get max. u (as an integer)
{	ld_io	ru,r4		; save u
}
{	ld_io	rv,r5		; save v
	sub	#1,r6		; decrement 1 to get last valid row
}
{	st_io	#0,rv
	asl	#16,r6		; convert to 16.16 format
}
	st_io	r6,ru
`x_loop:
	ld_p	(uv),v0		; load the pixel on the left side
	addr	#1<<16,ru	; step to next u
{	st_p	v0,(uv)		; store the pixel
	addr	#1<<16,rv	; go to next line
}
	range	rv
{	bra	modlt,`x_loop,nop
	addr	#-1<<16,ru	; and step back to previous u value (left edge)
}

	; see if there was also y overflow
	; note: r3 and r7 were preserved in the code above,
	; so this comparison makes sense...
	
{	cmp	r3,r7
	st_io	r4,ru		; restore u
}
{	st_io	r5,rv		; restore v
	bra	ge,`no_overflow,nop
}

	; if overflow, fall through...

	
	; come here if we read past the end of texture in
	; the y direction
`y_overflow:
	ld_s	v_size,r6	; get max. v (as an integer)
{	ld_io	ru,r4		; save u
}
{	ld_io	rv,r5		; save v
	sub	#1,r6		; decrement v to go to bottom line
}
{	st_io	#0,ru
	asl	#16,r6		; convert to 16.16 format
}
	st_io	r6,rv
`y_loop:
	ld_p	(uv),v0		; load the pixel on the bottom
	addr	#1<<16,rv	; step to next v
{	st_p	v0,(uv)		; store the pixel
	addr	#-1<<16,rv	; and step back to previous u value (left edge)
}
	range	ru
{	addr	#1<<16,ru	; go to next line
	bra	modlt,`y_loop,nop
}

	
	bra	`no_overflow
	st_io	r4,ru		; restore ru
	st_io	r5,rv		; restore rv
	

	;
	; special case solid color specular pixel code
	;

	s_const_one = v2[0]
	s_zexp = v2[1]
	s_speccolor=v2[2]
	s_scratch = v3[3]
	
	s_shade = _D_Vtemp[3]
	
solidspecpix:
	ld_p	TEXTURE+12,_D_Vtemp		; get basic color	
	push	v2
	mv_s	#fix(1.0,30),s_const_one

{	and	#$00f0,_D_i2,leftalpha	; initialize left alpha value	
	subm	_D_i1,s_const_one,s_shade	; set shade = (1.0 - specular)
}
	
`solidloop:
{	mul	_D_i0,s_shade,>>#30,s_shade		; calculate (1-specular)*diffuse
	msb	_D_z,s_zexp
	mv_s	_D_i1,s_speccolor		; save current specular component
}
{	sub	#26,s_zexp,_D_Vpixz
	mul	#1,s_zexp,>>#-26,s_zexp	; shift zexp left by 26
}
{	ls	_D_Vpixz,_D_z,_D_Vpixz
	mul_p	s_shade,_D_Vtemp,>>#30,_D_Vpix	; calculate (1-specular)*diffuse*P
}

	or	s_zexp,_D_Vpixz
{	dec	rc1			; count down pixels remaining
	and	#$ffff0000,_D_Vpixz	; clear out antialiasing bits
}
	;; set up left and right side antialiasing stuff
	;; v1 is free temporarily
	
{	sub	_D_lx,#fix(1.0,16),v1[1]
	mv_s	_D_i2,v1[0]
}
{	bra	le,`skip1
	or	leftalpha,v0[3]
	addm	_D_dlx,_D_lx
}
{	bits	#4,>>#16,v1[0]
	mv_s	#0,leftalpha	; clear leftalpha
}
	and	#$f,<>#-12,v1[1]

	or	v1[1],>>v1[0],v0[3]	// use lsalpha
`skip1:
{	sub	_D_rx,#fix(1.0,16),v1[1]
	mv_s	_D_i2,v1[0]
}
{	bra	le,`skip2
	sub	_D_drx,_D_rx
}
	bits	#4,>>#21,v1[0]
	and	#$f,<>#-12,v1[1]	//and	#$0000f000,v1[1]

	or	v1[1],>>v1[0],v0[3]	// use rsalpha

`skip2:
			
{	bra	c1ne,`solidloop
	add	_D_di0,_D_i0		; update diffuse shade
	addm	s_speccolor,_D_Vpix[0]
}
{	add	_D_di1,_D_i1		; update specular shade
	ld_p	TEXTURE+12,_D_Vtemp	; get fixed color
}
{	st_pz	_D_Vpix,(xy)		; store the new pixel
	addr	#1<<16,rx
	subm	_D_i1,s_const_one,s_shade	; set shade = (1.0 - specular)
	add	_D_dz,_D_z		; update Z
}

;* END OF LOOP
;* apply right side antialiasing
	addr	#-1<<16,rx
	ld_pz	(xy),v1
{	and	#$f,_D_i2,r0	; isolate right side alpha value
	rts
}
{	or	r0,v1[3]	; merge right side alpha info
	pop	v2
}
	st_pz	v1,(xy)		; store final pixel with its right side alpha info
	
_aabilerp_end:
	
