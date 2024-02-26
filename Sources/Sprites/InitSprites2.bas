
'!org=24576
'!copy=h:\sptest.nex
' NextBuild - InitSprites2 example - Uploading with an offset 

#define NEX 
#define IM2 

#include <nextlib.bas>

asm 
    nextreg TURBO_CONTROL_NR_07,%11         ; 28 mhz 
    nextreg GLOBAL_TRANSPARENCY_NR_14,$0    ; black 
    nextreg SPRITE_CONTROL_NR_15,%00000011  ; %000    S L U, %11 sprites on over border
    nextreg LAYER2_CONTROL_NR_70,%00000000  ; 5-4 %01 = 320x256x8bpp
end asm 


LoadSDBank("test.spr",0,0,0,34)

InitSprites2(16,0,34,0)

dim x as uinteger

for x = 0 to 15
    UpdateSprite(32+x<<4,32,x,x,0,0)                        ' show initial uploaded sprites 0 - 15
next 

WaitKey()

do 

    InitSprites2(4,256,34,4)                                    ' Now lets upload from sprite 4, images 0-3 again to repeat 0-3,0-3
                                                                ' offset 256 is 1 sprite in
    WaitKey()

    InitSprites2(4,0,34,4)                                       ' Now lets put back the original 

    WaitKey()

loop 