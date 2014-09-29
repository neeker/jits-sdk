@echo off
setlocal

set _WRAPPER_BASE=app
set _WRAPPER_CONF="../conf/run.conf"
set _PASS_THROUGH=true

if "%OS%"=="Windows_NT" goto nt
echo This script only works with NT-based versions of Windows.
goto :eof

:nt
rem Find the application home.
rem %~dp0 is location of current script under NT
set _REALPATH=%~dp0

set _WRAPPER_EXE=%_REALPATH%%_WRAPPER_BASE%.exe
if exist "%_WRAPPER_EXE%" goto conf
echo Unable to locate a Wrapper executable using any of the following names:
echo %_WRAPPER_L_EXE%
echo %_WRAPPER_EXE%
pause
goto :eof

:conf
if not [%_FIXED_COMMAND%]==[] (
    set _COMMAND=%_FIXED_COMMAND%
) else (
    set _COMMAND=%1
    shift
)

:parameters
set _PARAMETERS=%_PARAMETERS% %1
shift
if not [%1]==[] goto parameters

:callcommand
set _MATCHED=true
if [%_COMMAND%]==[console] (
    if [%_PASS_THROUGH%]==[] (
        "%_WRAPPER_EXE%" -c "%_WRAPPER_CONF%" %_PARAMETERS%
    ) else (
        "%_WRAPPER_EXE%" -c "%_WRAPPER_CONF%" -- %_PARAMETERS%
    )
) else if [%_COMMAND%]==[start] (
    call :start
) else if [%_COMMAND%]==[stop] (
    call :stop
) else if [%_COMMAND%]==[install] (
    if [%_PASS_THROUGH%]==[] (
        "%_WRAPPER_EXE%" -i "%_WRAPPER_CONF%" %_PARAMETERS%
    ) else (
        "%_WRAPPER_EXE%" -i "%_WRAPPER_CONF%" -- %_PARAMETERS%
    )
) else if [%_COMMAND%]==[status] (
    "%_WRAPPER_EXE%" -q "%_WRAPPER_CONF%"
) else if [%_COMMAND%]==[remove] (
    "%_WRAPPER_EXE%" -r "%_WRAPPER_CONF%"
) else if [%_COMMAND%]==[restart] (
   call :stop
   call :start
) else (
   set _MATCHED=
   goto showusage
)

if errorlevel 1 (
    if [%_MATCHED%]==[] goto showusage
)
goto :eof

:showusage
if not [%_COMMAND%]==[] (
    echo Unknown command: %_COMMAND%
    echo.
)
if [%_PASS_THROUGH%]==[] ( 
    echo Usage: %0 [ console : start : stop : restart : install : remove : status ]
) else (
    echo Usage: %0 [ console {JavaAppArgs} : start : pause : resume : stop : restart : install {JavaAppArgs} : remove : status ]
)
pause
goto :eof


:start
    "%_WRAPPER_EXE%" -t "%_WRAPPER_CONF%"
    goto :eof
:stop
    "%_WRAPPER_EXE%" -p "%_WRAPPER_CONF%"
    goto :eof
