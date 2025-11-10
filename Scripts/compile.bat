@echo off
FOR /F "usebackq" %%i IN (`%~dp0path.bat`) DO SET ZXBC=%%i
cls


if %1 == --version (
	goto EOL
)

call "%ZXBC%Scripts\compileNEXT.bat" %1 %2 %3 %4 %5 %6 %7 %8 
rem 2>%ZXBC%logs\buildlog.txt


exit 1
:EOL
