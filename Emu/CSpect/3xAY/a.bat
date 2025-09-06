..\snasm -map 3xay.asm 3xay.dummy
rem if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe  -debug -map=3xay.nex.map -zxnext -mmc=.\ 3xay.nex

:doexit
