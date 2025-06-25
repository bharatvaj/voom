@echo off
setlocal enabledelayedexpansion

rem TODO Follow the official path preference of airblade/voom
set VIM_PLUGIN_PATH=%USERPROFILE%\.local\share\vim\pack\voom\start
if NOT EXIST %VIM_PLUGIN_PATH% (
    mkdir %VIM_PLUGIN_PATH%
)

cd %VIM_PLUGIN_PATH%

set found=0
set gpath=""
set fpath=""
for /f "tokens=*" %%i in ('dir /b') do (
    REM TODO Add support for repo names in the future
    set fpath=%%i

    for /f "tokens=*" %%j in ('type %USERPROFILE%\.local\share\vim\plugins ^| findstr /v "^#"') do (
        for /f "delims=/ tokens=2" %%a in ("%%j") do set gpath=%%a
            if "!gpath!" EQU "!fpath!" (
                set found=1
            )
    )

    if not !found! EQU 1 (
        echo Removing "!fpath!"
        rmdir /s/q "!fpath!"
    )
    set found=0
)

for /f "tokens=*" %%i in ('type %USERPROFILE%\.local\share\vim\plugins ^| findstr /v "^#"') do (
    for /f "delims=/ tokens=2" %%a in ("%%i") do set gpath=%%a
    if not exist !gpath!/.git (
        git clone https://github.com/%%i
    )
)

vim -c "helptags ALL" -c quit >nul 2>&1

endlocal
