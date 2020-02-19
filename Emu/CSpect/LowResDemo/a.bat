..\snasm -map lowresdemo.asm lowresdemo.sna
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -s14 -map=lowresdemo.sna.map -zxnext -mmc=.\ lowresdemo.sna

:doexit