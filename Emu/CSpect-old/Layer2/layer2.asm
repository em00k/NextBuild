;
; Created on Sunday, 11 of June 2017 at 09:43 AM
;
; ZX Spectrum Next Framework V0.1 by Mike Dailly, 2017
;
; 
                opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                     ; Set z80 mode
                opt             ZXNEXT                                                  ; enable zx next opcodes
		opt             ZXNEXTREG

                include "includes.asm"


                ; IRQ is at $5c5c to 5e01
                include "irq.asm"       
               
StackEnd:
                ds      127
StackStart:     db      0

                org     $6100


StartAddress:
                di
                ld      a,$ff
                ld      ($8000),a
                ld      a,$ee
                ld      ($c000),a
                
                ld      a,VectorTable>>8
                ld      i,a                     
                im      2                       ; Setup IM2 mode
                ei
                ld      a,0
                out     ($fe),a

                ; enable turbo mode  (not sure what 14Mhz is yet)
                ;ld      bc, $243B
                ;ld      a,7                     ; select reg 6
                ;out     (c),a
                ;ld      bc, $253B
                ;ld      a,1                     ; set 7Mhz turbo mode
                ;out     (c),a

                ld      a,7
                call    ClsATTR

                call    InitFilesystem

                ld      a,$e3                    ; Clear screen to transparent
                call    Cls256
                
                call    BitmapOn

                ld      a,$ff
                ld      ($8000),a
                ld      a,$ee
                ld      ($c000),a

                call    InitSprites
                ld      a,$ff
                ld      ($8000),a
                ld      a,$ee
                ld      ($c000),a

                call    InitMap


                ; Test SAVE
                ld      b,16
                ld      de,$c000
                ld      a,16
@lp:            ld      (de),a
                inc     de
                inc     a
                djnz    @lp

                ld      hl,savename
                ld      ix,$c000
                ld      bc,16
                call    Save

                ld      a,0                     ; black boarder
                out     ($fe),a


                LoadFile        TestFile,$4000   ; load Pyjamarama loading screen (test)


                NextReg 20,$e3                  ; set global transparancy value
                ;NextReg 64,$88                  ; set "bright+black" ULA colour
                ;NextReg 65,$e3                  ; set BRIGHT+BLACK to transparent
                NextReg 64,$18                  ; set BRIGHT BLACK to transparent
                NextReg 65,$e3
                NextReg $15,1+16                ; enable sprites and put them under the border (U S L)
;
;               Main loop
;               
MainLoop:
                halt                            ; wait for vblanks (need to do Raster IRQs at some point)

                
                ; timing bar
                ld      a,1
                out     ($fe),a

                call    ScrollMap
                call    BounceSprites
                call    ReadKeyboard


                ;
                ; Change sprite priorities
                ;
                ld      a,(Keys+VK_1)           ; 0 = S L U
                and     $ff
                jr      z,@notpressed1
                ld      a,1+$00             
                jr      @SetLayerOrder
@notpressed1
                ld      a,(Keys+VK_2)           ; 1 = L s u
                and     $ff
                jr      z,@notpressed2
                ld      a,1+4
                jr      @SetLayerOrder
@notpressed2
                ld      a,(Keys+VK_3)           ; 2 = s u L
                and     $ff
                jr      z,@notpressed3
                ld      a,1+8
                jr      @SetLayerOrder
@notpressed3
                ld      a,(Keys+VK_4)           ; 3 = L u s
                and     $ff
                jr      z,@notpressed4
                ld      a,1+8+4
                jr      @SetLayerOrder
@notpressed4
                ld      a,(Keys+VK_5)           ; 4 = u s L
                and     $ff
                jr      z,@notpressed5
                ld      a,1+16
                jr      @SetLayerOrder                
@notpressed5
                ld      a,(Keys+VK_6)           ; 5 = u L s
                and     $ff
                jr      z,@notpressed
                ld      a,1+16+4
@SetLayerOrder:
                NextReg $15,a

                jp      MainLoop                ; infinite loop



@notpressed:
                ; timing bar off
                ld      a,0
                out     ($fe),a

                jp      MainLoop                ; infinite loop


; *****************************************************************************************************************************
; includes modules
; *****************************************************************************************************************************
                include "Scroll.asm"
                include "Utils.asm"
                include "SpriteBouncing.asm"
                include "filesys.asm"


; *****************************************************************************************************************************
; File directory.....
; *****************************************************************************************************************************
LemDemoFile     File    "game/lem.256"
XeO3TitleFile   File    "game/xeo3tit.256"
Level1File      File    "game/xeo3.map"
LevelCharsFile  File    "game/xeo3ch.256"
SpriteFile      File    "game/minecraf.spr"
TestFile        File    "game/test.scr"
TestTxt         File    "game/test.txt"

savename:       db      "game/test.raw",0


                ; wheres our end address?
                message "End of code =",PC
        



