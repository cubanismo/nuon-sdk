@echo off

REM Find the SDK absolute path
set NUONSDK=%~d0%~p0
REM Remove trailing backslash
set NUONSDK=%NUONSDK:~0,-1%

REM Add the win32 binaries to the search path
set Path=%Path%;%NUONSDK%\vmlabs\bin\win32

REM Set the VMLABS variable to point at the VMLABS SDK Root
set VMLABS=%NUONSDK%\vmlabs
set BUILDHOST=WINDOWS_NT
