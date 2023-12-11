#include <nextlib.bas>

' From the Terminal Menu pick Run Build Task or CTRL+SHFT+B

' build address 
'!org=24576
' NextBuild Layer2 Template 

#define NEX 
#define IM2 

#include <nextlib.bas>

asm 
    ; setting registers in an asm block means you can use the global equs for register names 
    ; 28mhz, black transparency,sprites on over border,320x256
    nextreg TURBO_CONTROL_NR_07,%11         ; 28 mhz 
    nextreg GLOBAL_TRANSPARENCY_NR_14,$0    ; black 
    nextreg SPRITE_CONTROL_NR_15,%00000011  ; %000    S L U, %11 sprites on over border
    nextreg LAYER2_CONTROL_NR_70,%00000000  ; 5-4 %00 = 256x192
    nextreg CLIP_LAYER2_NR_18,0
    nextreg CLIP_LAYER2_NR_18,255
    nextreg CLIP_LAYER2_NR_18,0
    nextreg CLIP_LAYER2_NR_18,255


end asm 

ShowLayer2(1)

dim x,y,c     as ubyte

c = 0

do
    
    for y = 0 to 191 
        for x = 0 to 254
            PlotL2(x,y,c)
        next 
        c=c+1
    next 

loop 