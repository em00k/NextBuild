..\snasm -map mouse.asm mouse.sna
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -s14 -map=mouse.sna.map -zxnext -mmc=.\ mouse.sna

:doexit
