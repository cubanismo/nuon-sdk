@echo OFF
 
IF EXIST "%~1.bless"  (
  del "%~1.bless" 
)

IF "%~1"=="" GOTO NONE
IF "%~2"=="" GOTO RUN
GOTO NONE

:NONE
echo usage: vmmakedisktemplate.bat APP_NAME.cof
echo ie: vmmakedisk.bat APP_NAME.cof 
GOTO END

:RUN
IF EXIST "%~1" (
  echo Blessing "%~1" 
  %VMBLESSDIR%\win32\blessdisk %~1 %APPTYPE%
) ELSE (
  echo ERROR: file "%~1" was not found!
  echo exiting.
  GOTO END
)

%VMBLESSDIR%\win32\cat "%~1.bless" %~1 > "%~1.template"

GOTO END
 
:END

IF EXIST "%~1.bless"  (
  del "%~1.bless" 
)
