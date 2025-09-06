..\snasm -map timer.asm timer.dat
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -map=timer.dat.map -zxnext -mmc=.\ timer.nex

:doexit
