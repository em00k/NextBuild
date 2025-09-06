;
; Created on Sunday, 11 of June 2017 at 09:43 AM
;
; ZX Spectrum Next Framework V0.1 by Mike Dailly, 2017
;
; 
                opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                     ; Set z80 mode
                opt             ZXNEXT
                

                include "includes.asm"

                ; IRQ is at $5c5c to 5e01
                include "irq.asm"       


               
StackEnd:
                ds      127
StackStart:     db      0

                org     $8100


StartAddress:
                di
				ld		a,(ix-2)
                ld      a,VectorTable>>8
                ld      i,a                     
                ; enable IRQs and disable VBlank
                NextReg         $22,2           ; LINE IRQ on
                NextReg         $23,64          ; first line...
                im      2                       ; Setup IM2 mode
                ei
                ld      a,0
                out     ($fe),a

                call    Cls
                ld      a,7
                call    ClsATTR

                call    InitFilesystem
                
 



;
;       Main loop
;               
MainLoop:
                halt                            ; wait for vblanks (need to do Raster IRQs at some point)

                call    ReadMouse
                ld      a,(MouseX)
                ld      de,$4000
                call    PrintHex
                ld      a,(MouseY)
                ld      de,$4003
                call    PrintHex
                ld      a,(MouseButtons)
                ld      de,$4006
                call    PrintHex


                xor     a
                in      a,($1f)
                push    af
                ld      de,$4020
                call    PrintHex
                pop     af
                and     a
                jr      z,@SkipDelay

@lp2            ld      b,$ff
@lp1            djnz    @lp1
                dec     a
                jr      nz,@lp2
@SkipDelay:

                ; get active video line....
                ld      bc,$243B
                ld      a,$1f
                out     (c),a
                //inc     b
                ld      a,$25
                in      a,($3B)

                ld      de,$4023
                call    PrintHex


                ; read reg 0
                ld      bc,$243B
                ld      a,0
                out     (c),a
                inc     b
                in      a,(c)
                ld      de,$4040
                call    PrintHex

                ; read reg 1
                ld      bc,$243B
                ld      a,1
                out     (c),a
                inc     b
                in      a,(c)
                ld      de,$4043
                call    PrintHex

                ; Paint!
                ld      de,(MouseX)             ; reads X and Y
                ld      a,d
                cp      191
                jr      c,@okay
                ld      d,191
@okay:          pixelad
                setae
                or      (hl)
                ld      (hl),a



                call    ReadKeyboard
                ld      a,(Keys+VK_E)
                and     a
                jr      z,@notpressed

                db      $dd,$00                 ; EXIT opcode
@notpressed:
                ld      a,(Keys+VK_B)
                and     a
                jr      z,@notpressed2

                db      $fd,$01                 ; BREAK opcode
@notpressed2:
                ld      a,(Keys+VK_SPACE)
                and     a
                jr      z,@notpressed3

                call    Cls
                ld      a,7
                call    ClsATTR                
@notpressed3:

                ; timing bar off
                ;ld      a,0
                ;out     ($fe),a

                jp      MainLoop                ; infinite loop

col             db      0


; *****************************************************************************************************************************
; includes modules
; *****************************************************************************************************************************
                include "Utils.asm"
                include "filesys.asm"


; *****************************************************************************************************************************
; File directory.....
; *****************************************************************************************************************************
SpriteFile      ;File    "game/minecraf.spr"


                ; wheres our end address?
                message "End of code =",PC
        



