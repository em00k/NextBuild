..\snasm.exe -map layer2.asm layer2.dat
rem if ERRORLEVEL 1 goto doexit

..\CSpect.exe -w3 -zxnext -map=layer2.dat.map layer2.nex

rem :doexit