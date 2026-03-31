REM SPDX-License-Identifier: MIT
REM Copyright (c) 2026 Bharatvaj Hemanth <bharatvaj@yahoo.com>

@echo off
setlocal EnableDelayedExpansion

if not defined VOOM_DEFAULT_PROVIDER set VOOM_DEFAULT_PROVIDER=https://github.com

if not defined XDG_CONFIG_HOME set XDG_CONFIG_HOME=%USERPROFILE%\.config
if not defined XDG_DATA_HOME set XDG_DATA_HOME=%USERPROFILE%\.local\share

if not defined VIM_DIR set VIM_DIR=%USERPROFILE%\.vim
if not defined VOOM_PLUGINS_DIR set VOOM_PLUGINS_DIR=%XDG_DATA_HOME%\vim\pack\voom\start

if not defined VOOM_MANIFEST (
	for /d %%d in ("%XDG_CONFIG_HOME%\vim" "%VIM_DIR%") do (
		if exist "%%~d\plugins" (
			set "VOOM_MANIFEST=%%~d\plugins"
		)
	)
)

if not exist "!VOOM_MANIFEST!" (
	echo Could not locate: '%VOOM_MANIFEST%'. >&2
	exit /b 1
)


if not exist %VOOM_PLUGINS_DIR% mkdir %VOOM_PLUGINS_DIR%

cd "%VOOM_PLUGINS_DIR%"
for /d %%d in (. "*") do set dirs=!dirs!^

%%d

for /f "tokens=*" %%j in ('type "%VOOM_MANIFEST%" ^| findstr /v "^#" ^| sort') do (
	for %%I in ("%%j") do set "reponame=%%~nxI"

	if "!reponame:~-4!"==".git" (
		echo x '.git' not allowed at end in entry: %%j
		exit /b 1
	)

	for /f "tokens=*" %%d in ("!dirs!") do (

		if "%%d"=="!reponame!" (
			set dirs=!dirs:^

%%d=!
		) else if not exist "!reponame!/.git" (
			set dirs=!dirs:^

%%d=!
			set jtmp=%%j
			echo v %%j
			if not "y!jtmp:://=!!jtmp:@=!"=="y!jtmp!!jtmp!" (
				git clone -q "%%j"
			) else (
				git clone -q "%VOOM_DEFAULT_PROVIDER%/%%j"
			)
			if ERRORLEVEL 1 (
				exit /b 1
			)
		)
	)
)

for /f "tokens=*" %%d in ("!dirs!") do (
	if not "%%d"=="." (
		echo Removing %%d
		rmdir /s/q "%%d"
	)
)

vim -c "helptags ALL" -c quit 2>&1 >nul

endlocal DisableDelayedExpansion
