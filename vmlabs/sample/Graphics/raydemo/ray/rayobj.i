
/* Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

; layout of object structures
;
;; the sphere object has the following memory layout:
;; +0       	== center of sphere (small vector of 8.8 numbers)
;; +8        	== kd = diffuse coefficient (2.14)
;; +10		== ks = specular coefficient (2.14)
;; +12          == kt = translucent coefficient (2.14)
;; +14          == kl = self-illumination factor
;; +16          == color1 (small vector)
;; +24          == color2 (small vector)
;; +32          == radius of sphere (8.24 number)
;; +36		== 1/radius (2.30 number)
;;

OFF_BASEPT = 0
OFF_LIGHTCOEFF = 8
OFF_COLOR1 = 16
OFF_COLOR2 = 24

OFF_SPH_CENTER = OFF_BASEPT
OFF_SPH_RADIUS = 32
OFF_SPH_INVRADIUS = 36

