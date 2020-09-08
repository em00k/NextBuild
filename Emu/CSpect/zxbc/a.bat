@echo off
rem simple 48k model
cd

..\CSpect.exe -w3 -16bit -brk -tv -map=%1memory.txt -zxnext -mmc=%1data\ temp.sna
:: ..\CSpect.exe -brk -map=%1memory.txt -zxnext -mmc=%1data\ temp.sna


exit
