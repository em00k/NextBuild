..\snasm -map dma.asm dma.sna
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -map=dma.sna.map -zxnext -mmc=.\ dma.sna

:doexit
