@echo off

REM Find the SDK absolute path
set NUONSDK=%~d0%~p0
REM Remove trailing backslash
set NUONSDK=%NUONSDK:~0,-1%
REM Convert to short path because spaces trip up GNUmake
REM for %T IN ("%NUONSDK%") DO set NUONSDK=%~sT
call :makeshort NUONSDK "%NUONSDK%"
@echo Set up Nuon SDK at: %NUONSDK%

REM Add the win32 binaries to the search path
set Path=%Path%;%NUONSDK%\bin\win32;%NUONSDK%\vmlabs\bin\win32

REM Set the VMLABS variable to point at the VMLABS SDK Root
set VMLABS=%NUONSDK%\vmlabs
set VMBLESSDIR=%NUONSDK%\bless
set BUILDHOST=WINDOWS_NT
exit /b

:makeshort
set %1=%~s2
exit /b
