..\snasm -map layer2.asm layer2.sna
if ERRORLEVEL 1 goto doexit

rem simple 48k model
E:\Dropbox\Backups\Source\Emulation\CSpect2\Game1\bin\Release\CSpect.exe -s14 -map=layer2.sna.map -zxnext -mmc=.\ layer2.sna
REM ..\CSpect.exe -s14 -map=layer2.sna.map -zxnext -mmc=.\ layer2.sna

:doexit