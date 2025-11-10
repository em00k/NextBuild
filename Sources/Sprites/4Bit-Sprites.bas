'!ORG=24576
'!heap=2048
'!copy=h:4bit.nex
'!opt=5

' 4 bit sprites 
' When using 4bit sprites with UpdateSprite routine the last two bytes of the command 
' will instruct the code which sprite to use. As we can still only have "64" images 
' 4bit allows each image number to contain 2 sprites (because they have been halved being 4bit)
' and to address each sprite for example sprite image 1, will containt the first two sprites
' it is byte 4 that will control which one we are addressing 
' 
' UpdateSprite ( x, y , sprite, image, byte 3, byte 4)
' image = 1 
' byte 4 = %10000000        = first sprite 
' byte 4 = %11000000        = second sprite
'
' now to address the next two sprites 
' image = 2
' byte 4 = %10000000        = first sprite 
' byte 4 = %11000000        = second sprite
' so combined UpdateSprite(x, y, spriteslot, image >> 1, %10000000 ! ((im & 1 )<<6) )
' 
' so on. byte3 can be ( image >> 1 ) and to construct byte 4: 
' %10000000 ! ((im & 1 )<<6) 
' Start with 128, take the imaage number, shift right, then shift left 6 times to 
' move the bit into the correct posisiton. 
'



asm : di : end asm 
									' These must be set before including the nextlib
#define NEX 						' If we want to produce a file NEX, LoadSDBank commands will be disabled and all data included

#include <nextlib.bas>				' now include the nextlib library
#include <keys.bas>					' we are using GetKeyScanCode, inkey$ is not recommened when using our own IM routine
									' (infact any ROM routine that may requires sysvars etc should be avoided)
#include <hex.bas>

LoadSDBank("128-demo.spr",0,0,0,34)                     ' load 128 4bit sprites to bank 34

declare function BinToString(num as ubyte) as String

asm 
    nextreg TURBO_CONTROL_NR_07,3                       ; 28mhz
    nextreg GLOBAL_TRANSPARENCY_NR_14,0                 ; black trasparency 
    nextreg SPRITE_TRANSPARENCY_I_NR_4B,0               ; sprite transparency
    nextreg PALETTE_CONTROL_NR_43,%00100000             ; select sprite palette 
    nextreg SPRITE_CONTROL_NR_15,%00010011              ; USL ordering, sprites over border
end asm 

PalUpload(@spritepal,64,0)                              ' upload the palette 
InitSprites2(64,$0000,34)                               ' Init 64 sprites from bank 34, offset 0 

dim sprites(128,8)      as ubyte                        ' define an array 128 sprites with 8 elements

asm 
 ;   nextreg PERIPHERAL_4_NR_09,%1<<4                    ' Sprite id lockstep 
end asm 


dim y,spriteflag,im,flags as ubyte                      ' set up some vars for the example 
dim tmpspradd   as uinteger = 0 
dim x           as uinteger
dim p           as ubyte 
dim tx          as uinteger
dim ty          as ubyte 
dim sp          as ubyte 
dim id          as ubyte 
dim di          as ubyte 
dim dd          as ubyte 
dim ve          as ubyte 
dim spr          as ubyte 

' rough idead of content for the elements 
' 0                1       2  3       4   5     6 
' enable & x MSB,  x LSB,  y, sprite, id, dir, speed  

' set up random sprites 

for x = 0 to 127 
    
    sprites(x,0)     = 1<<7        ' bit 7 to enable sprite 
    sprites(x,1)     = int(rnd*230)
    sprites(x,2)     = int(rnd*191)
    sprites(x,3)     = x 
    sprites(x,4)     = x 
    sprites(x,5)     = 1+int(rnd*1)   ' 0 right 1 up 2 left 3 down 
    sprites(x,6)     = 1+int(rnd*4)   ' 
    sprites(x,7)     = 1+int(rnd*1)   ' 
next 

ink 7 : paper 0 : cls 

spriteflag = 128

print at 18,0;"128 SPRITES"

do 
    do 
        border 2 
        update_all_sprites()                                ' display boucing sprites 
        border 0 
        WaitRetrace2(200)

    loop while GetKeyScanCode()=0

    for y = 0 to 7                                          ' display full 128 sprites in a grid
        for x = 0 to 15 
            spriteflag = 128  bor ( ((im band 1)<<6))
            UpdateSprite(cast(uinteger,x<<4)+32,32+y<<4,sp,im>>1,p,spriteflag)
            sp = (sp + 1) band 127 
            im = (im + 1) band 127
            p =p band 7
        next x 
    next y 

    do                                                      ' slide each sprite off to the right
        
        Print at 12,0;"Moving Sprite ";sp;"  "
        Print at 13,0;"      Pattern ";im;"  "
        Print at 14,0;"ActualPattern ";im>>1;"  "
        Print at 15,0;"  Attribute 2 ";BinToString(p<<4);"  "
        Print at 16,0;"  Attribute 5 ";BinToString(spriteflag);"  "

        y = (rnd*16)*16

        for x = 0 to 255 step 10
            spriteflag = 128  bor ( ((im band 1)<<6) )      ' magic for picking sprite!
            UpdateSprite(cast(uinteger,x)+32,y,sp,im>>1,0,spriteflag BOR %01010)  ' BOR %01010 = X2 Y2
            WaitRetrace(1)
        next 
        p =p band 7
        sp = (sp + 1) band 127                              ' the sprite ID 
        im = (im + 1) band 127                              ' the sprite image, share between two sprites

    WaitKey(): while inkey$<>"" : wend 

    loop until im = 0
loop 

sub update_all_sprites()

    dim add         as uinteger
    
    add = @sprites                   ' point address to start of array 

    for spr = 0 to 127
        
        tx = peek(add)  
        
        if  cast(ubyte,tx) band 192 > 0                         ' is the sprite enable?

            tx = peek (add+1)                                   ' get the LSB for x 
            ty = peek(add+2)                                    ' get y 
            sp = peek(add+3)                                    ' get sprite 
            id = peek(add+4)                                    ' get the image id
            di = peek(add+5)                                    ' direction 
            ve = peek(add+6)                                    ' speed 
            dd = peek(add+7)                                    ' speed 

            if di = 0                                           ' going right
                tx = tx + ve
                if tx > 250 
                    di = 1
                    tx = tx - ve
                endif  
            elseif di = 1                                       ' goint left
                tx = tx - ve
                if tx >250                                      ' wrap below 0 so we can check if its rolled
                    di = 0
                    tx = tx + ve
                endif    
            endif            

            if dd = 0                                           ' going up 
                ty = ty - ve 
                if ty > 250 
                    dd = 1
                    ty = ty + ve 
                endif 
            elseif dd = 1                                       ' going down 
                ty = ty + ve
                if ty > 190
                    ty = ty - ve 
                    dd = 0
                endif 
            endif 

            spriteflag = 128  bor ( ((id band 1)<<6))        

            UpdateSprite(cast(uinteger,tx)+32,ty+32,spr,id>>1,0,spriteflag)
            
            poke add+1, tx                                  ' store new x
            poke add+2, ty                                  ' store new y
            poke add+5, di                                  ' store new direction  
            poke add+7, dd                                  ' store new direction  

        endif 
        
        add = add + 9

    next spr

end sub 

do 
    
    Print at 12,0;"Moving Sprite ";sp;"  "
    Print at 13,0;"      Pattern ";im;"  "
    Print at 14,0;"ActualPattern ";im>>1;"  "
    Print at 15,0;"  Attribute 2 ";BinToString(p<<4);"  "
    Print at 16,0;"  Attribute 5 ";BinToString(spriteflag);"  "

    y = (rnd*16)*16

    for x = 0 to 255 step 10
        spriteflag = 128 bor ( ((im band 1)<<6) bor %01010)               ' im = %1000000 BOR %00000000 or %01000000
        UpdateSprite(cast(uinteger,x)+32,y,sp,im>>1,p << 4,spriteflag)
        WaitRetrace(1)
    next 

    p = (p + 1 ) band 7

    sp = (sp + 1) band 127 
    im = (im + 1) band 127

   WaitKey(): while inkey$<>"" : wend 

loop 

' 16 colour palette to upload
spritepal:
asm 
  db $00, $00, $50, $01, $A4, $01, $D1, $00, $2E, $00, $BD, $01, $64, $01, $DB, $00 
  db $8C, $01, $7A, $00, $B6, $01, $69, $00, $72, $01, $F9, $01 ,$E9, $00, $FF ,$00 

  db $00, $00, $19, $01, $49, $00, $61, $01, $0E, $01, $65, $00, $81, $00, $9A, $00
  db $95, $00, $D0, $00, $09, $01, $9D, $01, $32, $00, $F8, $00, $E0, $00, $FF, $ff 
end asm 



function FASTCALL BinToString(num as ubyte) as String
	asm
	PROC
	push namespace core
	LOCAL END_CHAR
	LOCAL DIGIT
	LOCAL charloop
	LOCAL bitisset
	LOCAL nobitset
	push af   ; save ubyte 
	ld bc,10
	call __MEM_ALLOC
	ld a, h
	or l
	pop bc 
	ld c,b 
	ret z	; NO MEMORY
	
	push hl	; Saves String ptr
	ld (hl), 8
	inc hl
	ld (hl), 0
	inc hl  ; 8 chars string length

	; c holds out entry 8 bit value, b number of bits 

	ld b,8
charloop:
	call DIGIT
	djnz charloop 
	pop hl	; Recovers string ptr
	ret
	
DIGIT:
	ld a,c
	bit 7,a
	jr nz,bitisset 
	ld a,'0'
	jr nobitset
bitisset:
	ld a,'1'
nobitset:	
	
END_CHAR:
	ld (hl), a
	inc hl
	ld a,c 
	sla c 
	ret
	ENDP
	pop namespace
	end asm
end function