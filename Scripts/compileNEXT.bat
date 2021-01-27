@echo off
set tmppath=%~dpn0
rem echo %tmppath%
FOR /F "usebackq" %%i IN (`%~dp0path.bat`) DO SET ZXBC=%%i
SET ZXB="%ZXBC%\zxbasic\zxb.exe"
SET EMU="%ZXBC%Emu\Fuse\fuse.exe"
SET FILE=%1

IF %1 == "" (
	exit 1
	)
	
for %%I in (%FILE%) do set fname=%%~nI
for %%I in (%FILE%) do set pname=%%~dpI
for %%I in (%FILE%) do set drive=%%~d

:: PARAMS SENT : %1 full path of basic.bas, %2 -S, %3 Start address

if "%6"  == "--debug-array" goto dofuse
if "%7"  == "--debug-array" goto dofuse
if "%8"  == "--debug-array" goto dofuse
if "%6"  == "--emmit-backend" goto emit
if "%7"  == "--emmit-backend" goto emit
if "%8"  == "--emmit-backend" goto emit

	%ZXBC%zxbasic\python\python.exe %ZXBC%Scripts\nextbuild.py %pname%%fname%.bas

if ERRORLEVEL 1 goto pgend

if ERRORLEVEL 1 goto endnow
		
::	copy %ZXBC%Emu\cspect\zxbc\temp.sna %pname%compiled.sna >>NUL
	
	cd %pname%
	
if ERRORLEVEL 10 goto endnow

	::cd %ZXBC%Emu\cspect\zxbc\ 
	start %ZXBC%Emu\cspect\cspect.exe -w3 -16bit -brk -tv -vsync -nextrom -map=%pname%memory.txt -zxnext -fill=00 -mmc=%pname%data\ %pname%%fname%.NEX
	color 06
	exgo 0
:endnow
	
	
exit 0


:pgend
	REM Dont ask why but we need to send the error line twice for BorIDE to recognise it. 
	%ZXBC%Scripts\errorline.exe %ZXBC%logs\COMPILE.txt /q
	exit %ERRORLEVEL%
	goto eoscript
:dofuse
	%ZXB% %1 -t -B %2 %3 -o %pname%%fname%.tap -a -M %fname%.map
	if ERRORLEVEL 1 goto pgend
	%EMU% %pname%%fname%.tap
	exit 0
:eoscript	

