'!org=24576
'!bmp=data/13.bmp

' NextBuild Layer2 Template 

#define NEX 
#define IM2 

#include <nextlib.bas>

asm 
    ; setting registers in an asm block means you can use the global equs for register names 
    ; 28mhz, black transparency,sprites on over border,256x192/320x256
    nextreg TURBO_CONTROL_NR_07,%11         ; 28 mhz 
    nextreg GLOBAL_TRANSPARENCY_NR_14,$0    ; black 
    nextreg SPRITE_CONTROL_NR_15,%00000011  ; %000    S L U, %11 sprites on over border
    nextreg LAYER2_CONTROL_NR_70,%00000000  ; 5-4 %00 = 256x192x8bpp, 5-4 %01 320x256x8bpp
end asm 

do 
    border 2
    pause 0
    border 1
    pause 0
loop 