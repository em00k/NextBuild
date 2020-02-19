;
; Created on Sunday, 11 of June 2017 at 09:43 AM
;
; ZX Spectrum Next Framework V0.1 by Mike Dailly, 2017
;
; 
                opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                                             ; Set z80 mode

                include "includes.asm"


                ; IRQ is at $5c5c to 5e01
                include "irq.asm"       
               
StackEnd:
                ds      127
StackStart:     db      0

                org     $8000


StartAddress:
                di                
                ld      a,VectorTable>>8
                ld      i,a                     
                im      2                       ; Setup IM2 mode
                ei
                ld      a,0
                out     ($fe),a

                call    InitFilesystem                
                call    BitmapOn
                call    InitSprites

                call    InitMap

                ;nextreg 21,128+1                  ; Radajim on
;                ld      a,128+1
;                NREG    21
                ld      a,0                     ; black boarder
                out     ($fe),a

;                ld      b,16
;                ld      de,$c000
;                ld      a,4
;@lp:            ld      (de),a
;                inc     de
;                inc     a
;                djnz    @lp

                ;ld      hl,name
                ;ld      ix,$c000
                ;ld      bc,16
                ;call    Save

;
;               Main loop
;               
MainLoop:
                halt                            ; wait for vblanks (need to do Raster IRQs at some point)

                
                ; timing bar
                ld      a,0
                out     ($fe),a

                call    ReadKeyboard
                call    SetPlayer


                ld  a,(which)
                and a
                jp  nz,@Xenon2
@MarioScroll:

                ld      a,(ForeX)
                inc     a
@Skipx:         ld      (ForeX),a
                ;NextReg 23,a
                NREG    22

                ld      hl,(BackX)
                inc     hl
                ld      (BackX),hl
                srl     h
                rr      l
                ld      a,l   
                ;NextReg 51,a
                NREG    50
                jp      @SkipXenon


@Xenon2:
                ld      a,(ForeY)
                dec     a
                cp      $ff
                jr      nz,@Skip
                ld      a,191
@Skip:          ld      (ForeY),a
                ;NextReg 23,a
                NREG    23

                ld      hl,(BackY)
                dec     hl
                ld      a,h
                cp      $ff
                jr      nz,@Skip2
                ld      a,l
                cp      $ff
                jr      nz,@Skip2
                ld      hl,191*2
@Skip2:         ld      (BackY),hl
                srl     h
                rr      l
                ld      a,l   
                ;NextReg 51,a
                NREG    51
@skipper:
                ;
                ; Change sprite priorities
                ;
                ld      a,(Keys+VK_Q)
                and     $ff
                jr      z,@notpressed1
                ld      a,(PlayerY)
                sub     2
                ld      (PlayerY),a         
@notpressed1
                ld      a,(Keys+VK_A)
                and     $ff
                jr      z,@notpressed2
                ld      a,(PlayerY)
                add     2
                ld      (PlayerY),a         
@notpressed2
                ld      a,(Keys+VK_O)
                and     $ff
                jr      z,@notpressed3
                ld      hl,(PlayerX)
                ld      bc,2
                sbc     hl,bc
                ld      (PlayerX),hl
@notpressed3
                ld      a,(Keys+VK_P)           ; 3 = L u s
                and     $ff
                jr      z,@notpressed4
                ld      hl,(PlayerX)
                ld      bc,2
                add     hl,bc
                ld      (PlayerX),hl
@notpressed4
@SkipXenon

                ld      a,(Keys+VK_1)           ; Set Mario
                and     $ff
                jr      z,@notpressed5
                xor     a
                ld      (Keys+VK_1),a
                ld      a,0
                ld      (which),a
                call    InitMap
                jp      @SkipXenon
@notpressed5
                ld      a,(Keys+VK_2)           ; Set Xenon 2
                and     $ff
                jr      z,@notpressed6
                xor     a
                ld      (Keys+VK_2),a
                ld      a,1
                ld      (which),a
                call    InitMap
                jp      @SkipXenon
@notpressed6
;                jp      MainLoop                ; infinite loop


@notpressed:
                ; timing bar off
                ld      a,0
                out     ($fe),a

                jp      MainLoop                ; infinite loop


ForeY           dw      0
BackY           dw      0       ; background
ForeX           dw      0
BackX           dw      0
which           db      0       ; 0 for Mario, 1 for Xenon 2

spSize  equ     4;

                ds      64*spSize
                
name:           db      "game/test.raw",0
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
Background      File    "game/128x96.256"
Foreground      File    "game/256x192.256"
MBackground     File    "game/m128.256"
MForeground     File    "game/m256.256"
ShipSprite      File    "game/ship.256"



                ; wheres our end address?
                message "End of code =",PC
        



