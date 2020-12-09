@echo off
rem simple 48k model
cd

..\CSpect.exe -w3 -16bit -brk -tv -vsync -map=%1memory.txt -zxnext -fill=00 -mmc=%1data\ temp.sna
::..\CSpect.exe -brk -map=%1memory.txt -zxnext -mmc=%1data\ temp.sna


exit
