..\snasm -map dma.asm dma.dat
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -w3 -map=dma.dat.map -zxnext -mmc=.\ DMADemo.nex

:doexit
