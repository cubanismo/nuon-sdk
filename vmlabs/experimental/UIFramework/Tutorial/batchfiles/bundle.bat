Mkdir compiled\fonts
copy ..\..\tools\system.ttf compiled\fonts\system.ttf
if exist images Mkdir compiled\images
if exist images copy images compiled\images
Mkdir compiled\scripts
copy ..\..\tools\snml.bbo compiled\scripts\snml.bbo
copy compiled\pages\%1.npg compiled\startup.npg
del compiled\pages\%1.npg
..\..\tools\ramload -z -o ui.dat compiled
..\..\tools\CreateNuiCD ui.dat
