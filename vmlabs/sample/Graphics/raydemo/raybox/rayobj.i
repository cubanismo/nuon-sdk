	;;
	;; data structure for ray tracer
	;;
	;; Copyright (c) 1997-2001 VM Labs, Inc.
	;; All rights reserved.
	;; Confidential and Proprietary Information of VM Labs, Inc.
	;; 
 	;; NOTICE: VM Labs permits you to use, modify, and distribute this file
 	;; in accordance with the terms of the VM Labs license agreement
 	;; accompanying it. If you have received this file from a source other
	;; than VM Labs, then your use, modification, or distribution of it
 	;; requires the prior written permission of VM Labs.
;; layout of object structures
;; +0           == pointer to intersection function
;; +4           == pointer to normal function
;; +8           == pointer to move function
;; +12          == pointer to color function (or NULL for standard color)
;; +16        	== kd = diffuse coefficient (2.14)
;; +18		== ks = specular coefficient (2.14)
;; +20          == kt = translucent coefficient (2.14)
;; +22          == kl = self-illumination factor
;; +24          == color1 (long word)
;; +28          == radius of enclosing sphere (8.24 number)
;; +32          == object position (center of object) vector of 8.24 numbers
;; +48          == object velocity (vector of 8.24 numbers)
;; +64          == start of other stuff

;;
;; OBJECT SPECIFIC DEFINES:
;; SPHERE:
;; +64		== 1/radius (2.30 number)
;;
;; PLANE:
;; +64 		== plane normal
;;
;; POLYHEDRON:
;;

OFF_INTERSECT_FN = 0
OFF_NORMAL_FN = 4
OFF_MOVE_FN = 8
OFF_COLOR_FN = 12

OFF_LIGHTCOEFF = 16
OFF_COLOR1 = 24
OFF_RADIUS = 28

OFF_BASEPT = 32
OFF_VELOCITY = 48
OFF_END = 64

OFF_SPH_CENTER = OFF_BASEPT
OFF_SPH_RADIUS = OFF_RADIUS
OFF_SPH_INVRADIUS = OFF_END

OFF_PLANE_NORMAL = OFF_END

OFF_POLY_LASTNORM = OFF_END
OFF_POLY_NUMPLANES = OFF_END+8
OFF_POLY_RESERVED = OFF_END+12
OFF_POLY_PLANES = OFF_END+16
