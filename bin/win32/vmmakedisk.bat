@echo OFF

set APPTYPE=0
set KEYTYPE="Application"

IF EXIST "%~1.blessings" (
  del "%~1.blessings" 
)
 
IF EXIST "%~1.bless"  (
  del "%~1.bless" 
)
IF EXIST "%~1.bless.sig" (
  del "%~1.bless.sig"
)

IF "%~1"=="" GOTO NONE
IF "%~2"=="" GOTO RUN
IF "%~3"=="" GOTO SETAPPTYPE
IF "%~4"=="" GOTO SETKEYTYPE
GOTO NONE

:NONE
echo usage: makedisk.bat APP_NAME.cof [APP-TYPE] [KEY-TYPE]
echo ie: makedisk.bat APP_NAME.cof 
GOTO END


:SETAPPTYPE
%APPTYPE%=%~2
GOTO RUN


:SETKEYTYPE
%APPTYPE%=%~2
%KEYTYPE%=%~3
GOTO RUN

:RUN
IF EXIST "%~1" (
  echo Blessing "%~1" 
  %VMBLESSDIR%\win32\blessdisk %~1 %APPTYPE%
) ELSE (
  echo ERROR: file "%~1" was not found!
  echo exiting.
  GOTO END
)

echo Signing blessings

%VMBLESSDIR%\win32\gpg -b  --homedir %VMBLESSDIR%\gnupghome  --digest-algo md5 --default-key %KEYTYPE% "%~1.bless"

IF NOT EXIST "%~1.bless" (
  echo ERROR: Signing failed. Exiting!
  GOTO END    
)

IF NOT EXIST "%~1.bless.sig" (
  echo ERROR: Signing failed. Exiting!
  GOTO END    
)

%VMBLESSDIR%\win32\cat "%~1.bless" "%~1.bless.sig" > "%~1.blessings"

%VMBLESSDIR%\win32\cat "%~1.blessings" %~1 > "%~1.app"

IF EXIST "%~1.app" (
  echo ----- authinfo -------
  authinfo -v "%~1.app" 
  echo ----- authinfo -------
  echo Fnished correctly
  echo Created app file: %~1.app
  echo.
) ELSE (
  echo ERROR: file "%~1.app" was not found!
    
)

GOTO END
 
 
:END

IF EXIST "%~1.blessings" (
  del "%~1.blessings" 
)
 
IF EXIST "%~1.bless"  (
  del "%~1.bless" 
)
IF EXIST "%~1.bless.sig" (
  del "%~1.bless.sig"
)
