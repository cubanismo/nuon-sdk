:: From https://www.robvanderwoude.com/batexamples.php?fc=M#MakeTemp
@ECHO OFF
:: Not for Windows 9* or MS-DOS
IF NOT "%OS%"=="Windows_NT" GOTO Syntax
:: Only one argument allowed
IF NOT "%~2"=="" GOTO Syntax
:: Check if FINDSTR is available
FINDSTR /? >NUL 2>&1 || GOTO Syntax
:: Allowed argument is a variable name, check for invalid characters
ECHO.%1| FINDSTR /R /I /C:"[^0-9a-z\._-]" >NUL && GOTO Syntax

:: Use local variable
SETLOCAL ENABLEDELAYEDEXPANSION

:: Use the default if no variable name was specified
IF NOT "%~1"=="" (SET VarName=%~1) ELSE (SET VarName=TempFile)

:Again

:: Use creation time as prefix
:: Note: spaces are replaced by zeroes, a bugfix by Michael Krailo
SET TempFile=~~%Time: =0%
:: Remove time delimiters
SET TempFile=%TempFile::=%
SET TempFile=%TempFile:.=%
SET TempFile=%TempFile:,=%

:: Create a really large random number and append it to the prefix
FOR /L %%A IN (0,1,9) DO SET TempFile=!TempFile!!Random!

:: Append .tmp extension
SET TempFile=%TempFile%.tmp

:: If temp file with this name already exists, try again, otherwise create it now
IF EXIST "%Temp%.\%TempFile%" (
	GOTO Again
) ELSE (
	TYPE NUL > "%Temp%.\%TempFile%" || SET TempFile=
)

:: Retrieve the fully qualified path of the new temp file
FOR %%A IN ("%Temp%.\%TempFile%") DO SET TempFile=%%~fA

:: Display the fully qualified path of the new temp file
:: Edit: Don't want this for Nuon SDK usage
:: SET TempFile

:: Return the fully qualified path of the new temp file
ENDLOCAL & SET %VarName%=%TempFile%

:: Done
GOTO:EOF


:Syntax
ECHO.
ECHO MakeTemp.bat,  Version 2.10 for Windows 2000 and later
ECHO Create a new temporary file with a unique name, and return
ECHO its fully qualified path in an environment variable
ECHO.
ECHO Usage:  MAKETEMP  [ variable_name ]
ECHO.
ECHO Where:  variable_name  is the optional name of the environment
ECHO                        variable that will contain the returned
ECHO                        path (default: "TempFile")
ECHO.
ECHO Notes:  The fully qualified path of the temporary file will be
ECHO         stored in an environment variable named as specified on
ECHO         the command line, or named "TempFile" if not specified.
ECHO         If a temporary file could not be created, the variable
ECHO         will be empty (undefined).
ECHO         This batch file has been tested in Windows XP only; it
ECHO         will probably work in Windows 2000 too; to make it work
ECHO         in Windows NT 4, the Resource Kit utility FINDSTR must
ECHO         be installed and in the PATH.
ECHO.
ECHO Written by Rob van der Woude
ECHO http://www.robvanderwoude.com

IF "%OS%"=="Windows_NT" ENDLOCAL
IF "%OS%"=="Windows_NT" COLOR 00
