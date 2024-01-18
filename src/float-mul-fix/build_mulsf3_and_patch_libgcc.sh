#!/bin/sh

set -e

llama -chip aries -fcoff -o _mulsf3.o _mulsf3.s
cp "${VMLABS}/lib/libgcc.a" .
vmar riav _muldi3.o libgcc.a _mulsf3.o
