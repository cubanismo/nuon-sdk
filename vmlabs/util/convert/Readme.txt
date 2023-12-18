Conversion utilities for libmml3d
Copyright (c) 1996-2001 VM Labs, Inc.
All rights reserved.
Confidential and Proprietary Information
of VM Labs, Inc.

Here are some simple conversion utilities that
take raw triangle data (.raw) or WTK-NFF
format triangle data (.nff) and convert them
into Merlin assembly language files which
contain corresponding draw buffers. These
utilities are not very useful as is, since
they do not convert texture coordinates.
Moreover, the utilities are almost certainly
buggy and produce poor normal vectors.

We're providing these utilities only
as a stop-gap measure until proper documentation
is available, and as a guide to help you
write your own converters. A future release
of the SDK will have "real" converters
that will be able to take popular 3D file
formats and texture data and produce
high quality mml3d buffer data.


Materials:

Materials aren't converted. raw2buf
assigns a material called "_default_material"
to all faces. nff2buf creates materials
called "_material_0xRRGGBB", where RRGGBB
is the RGB color of the face. You'll
have to create and initialize these
materials in your C code.
