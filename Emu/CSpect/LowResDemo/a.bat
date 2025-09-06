del lowresdemo.nex
del lowresdemo.nex.map
..\snasm -map lowresdemo.asm lowresdemo.dat
if ERRORLEVEL 1 goto doexit

rem simple 48k model
if exist lowresdemo.nex (
    rem E:\Dropbox\Backups\Source\Emulation\CSpect2\Game1\bin\Release\CSpect.exe -60 -vsync -tv -sound -s14 -map=lowresdemo.sna.map -zxnext -mmc=.\ lowresdemo.sna
    ..\CSpect.exe -fullscreen -60 -vsync -w3 -sound -map=lowresdemo.nexa.map lowresdemo.nex
) else (
	@echo Competed with Errors
)
:doexit