..\snasm.exe -map beast.asm beast_tmp.nex
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -debug -brk -sound -60 -w3 -vsync -s28 -map=beast_tmp.nex.map -zxnext -mmc=.\ beast.nex
rem ..\CSpect.exe -w3 -60 -vsync -s14 -map=beast.sna.map -zxnext -mmc=.\ beast.sna

:doexit