@echo off

SETLOCAL

REM mgcc uses TMP, but it doesn't tolerate paths with spaces.
REM Convert TMP to its shortname format

CALL :makeshort TMP "%TMP%"

REM Use the the modified specfile from the nuon SDK, prepending the
REM appropriate VMLABS dir varilable to it in a temporary file first.
CALL maketemp TMPSPECFILE
CALL :makeshort TMPSPECFILE "%TMPSPECFILE%"

SET "VMLABS_SLASH=%VMLABS:\=/%"
echo *vmlabsdir:> "%TMPSPECFILE%"
echo %VMLABS_SLASH%>> "%TMPSPECFILE%"
echo.>> "%TMPSPECFILE%"
type "%VMLABS%\lib\specs" >> "%TMPSPECFILE%"
SET VMLABS_SLASH=

mgcc-real -specs="%TMPSPECFILE%" %*
SET SAVEDERRORLEVEL=%ERRORLEVEL%

del "%TMPSPECFILE%"

exit /b %SAVEDERRORLEVEL%

:makeshort
SET %1=%~s2
exit /b
