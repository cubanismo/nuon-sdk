@echo off

SETLOCAL

REM mg++ uses TMP, but it doesn't tolerate paths with spaces.
REM Convert TMP to its shortname format

CALL :makeshort TMP "%TMP%"

REM Use the the modified specfile from the nuon SDK, substituting the
REM appropriate VMLABS dir into it in a temporary file first.
CALL maketemp TMPSPECFILE
CALL :makeshort TMPSPECFILE "%TMPSPECFILE%"

SET "VMLABS_SLASH=%VMLABS:\=/%"
@powershell -Command "(Get-Content '%VMLABS%\lib\specs') -replace '%%%%VMLABSDIR%%%%','%VMLABS_SLASH%' | Out-File -encoding ASCII '%TMPSPECFILE%'"
SET VMLABS_SLASH=

mg++-real -specs="%TMPSPECFILE%" %*
SET MYERRORLEVEL=%ERRORLEVEL%

del "%TMPSPECFILE%"

ENDLOCAL & SET MYERR=%MYERRORLEVEL%
exit /b %MYERR%

:makeshort
SET %1=%~s2
exit /b
