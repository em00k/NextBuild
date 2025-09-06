..\snasm.exe -map TileTest.asm TileTest_tmp.nex
if ERRORLEVEL 1 goto doexit

rem simple 48k model
..\CSpect.exe -debug -sound -60 -w3 -vsync -s28 -map=TileTest_tmp.nex.map -zxnext -mmc=.\ TileTest.nex
rem ..\CSpect.exe -w3 -60 -vsync -s14 -map=beast.sna.map -zxnext -mmc=.\ beast.sna

:doexit