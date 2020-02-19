..\snasm -map 3xay.asm 3xay.sna
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -map=3xay.sna.map -zxnext -mmc=.\ 3xay.sna

:doexit
