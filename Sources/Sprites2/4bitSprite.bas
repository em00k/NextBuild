'!ORG=24576
' em00k 2021 part of Nextbuild 
' Interrupt Example Music + SFX 
'#!copy=h:\4bit.nex
'
asm : di : end asm 
									' These must be set before including the nextlib
#define NEX 						' If we want to produce a file NEX, LoadSDBank commands will be disabled and all data included
'#define IM2							' This is required if you want to use IM2 and v7 Layer2 commnds, comment out to find out why

#include <nextlib.bas>				' now include the nextlib library
#include <keys.bas>					' we are using GetKeyScanCode, inkey$ is not recommened when using our own IM routine
									' (infact any ROM routine that may requires sysvars etc should be avoided)
#include <hex.bas>

LoadSDBank("256x128a.spr",0,0,0,34)

asm 
    nextreg $56,34
    nextreg $57,35
    nextreg $43,%00100000
    nextreg $15,%00000011
end asm 

PalUpload(@spritepal,32,0)
InitSprites(64,$c000)

asm 
    nextreg $56,00
    nextreg $57,01
    nextreg $9,%1<<4
end asm 

dim sp,y,spriteflag,im,flags as ubyte

flags = 192
spriteflag = %10000000
for y = 0 to 15
for x = 0 to 15
   '' print at 11,0;
   '' print "sp      ";BinToString(sp)
   '' print "att 0   ";BinToString(x)
   '' print "att 1   ";BinToString(y)
   '' print "att 2   ";BinToString(0)
   '' print "att 3   ";BinToString(flags)
   '' print "att 4   ";BinToString(spriteflag)


    UpdateSprite(cast(uinteger,x<<4)+32,y<<4,sp,im,0,spriteflag)
    sp = sp + 1 
    spriteflag=spriteflag bxor 64
    if spriteflag =128
        im = im + 1 
    endif 
    WaitRetrace(1)

next x 
next y 

do 
    x = x + 1 
    UpdateSprite(cast(uinteger,x)+32,y<<4,0,im,0,spriteflag)
    WaitRetrace(1)
loop 

spritepal:
asm 
	db $00, $00, $b6, $01, $b6, $01, $49, $00, $24, $01, $a0, $00, $b2, $00, $fa, $00
	db $f5, $01, $fd, $01, $90, $00, $0e, $01, $09, $01, $06, $00, $f3, $01, $81, $01
end asm 