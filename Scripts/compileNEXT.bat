rem @echo off
set tmppath=%~dpn0
rem echo %tmppath%
FOR /F "usebackq" %%i IN (`%~dp0path.bat`) DO SET ZXBC=%%i
SET ZXB="%ZXBC%\zxbasic2\zxb.exe"
::SET ZXB="%ZXBC%\oldzxbs\zxbasic191\zxb.exe"
::SET ZXB="%ZXBC%ZXBCnew\zxb.exe"
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
	
::	%ZXB% %1 %2 %3 -o %pname%%fname%.bin -a -M Memory.txt -O3 --heap-size=4096 2>%pname%COMPILE.txt

	%ZXB% %1 %2 %3 -O3 -o %pname%%fname%.bin --arch zxnext --mmap %pname%Memory.txt --heap-size=2048 2>%pname%COMPILE.txt 

:: 	%ZXB% %1 %2 %3 -o %pname%%fname%.asm --heap-size=3124 -A

	::  -O3

	::  -O3 

if ERRORLEVEL 1 goto pgend
	
	copy %pname%temp.bin %ZXBC%Emu\cspect\zxbc\temp.bin >>NUL
	cd %ZXBC%Emu\cspect\zxbc\ 
::>>NUL
	:: %drive%
	:: assemble with snasm %pname% is the file, %3 is start address
	
	call %ZXBC%Emu\cspect\zxbc\b.bat %pname% %3

if ERRORLEVEL 1 goto endnow

		
	copy %ZXBC%Emu\cspect\zxbc\temp.sna %pname%compiled.sna >>NUL
		
	type %pname%\COMPILE.txt

	%ZXBC%Scripts\postcompile.exe %FILE% %3
::>>NUL

if ERRORLEVEL 10 goto endnow

	start /D %ZXBC%Emu\cspect\zxbc\ a.bat %pname% >>NUL

rem cd %tmppath%

:endnow
	
	
exit 0


:pgend
	REM Dont ask why but we need to send the error line twice for BorIDE to recognise it. 
	%ZXBC%Scripts\errorline.exe %ZXBC%logs\COMPILE.txt /q
	rem type %ZXBC%logs\buildlog.txt
	copy  %pname%\COMPILE.txt %ZXBC%logs\COMPILE.txt /y
	start notepad.exe %pname%\COMPILE.txt
	rem type %ZXBC%logs\buildlog.txt
	rem echo temp.bas:444: Syntax error. Unexpected token 'a' [LABEL]
	%ZXBC%Scripts\errorline.exe %pname%\COMPILE.txt
	exit 1
	goto eoscript



:dofuse
	%ZXB% %1 -t -B %2 %3 -o %pname%%fname%.tap -a -M %fname%.map
	if ERRORLEVEL 1 goto pgend
	%EMU% %pname%%fname%.tap
	exit 0
:eoscript	

