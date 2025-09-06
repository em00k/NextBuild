;
; Shadow of the Beast - Tech demo V2.0
; Shadow of the Beast is Copyright Sony Interactive Entertainment 
;
; This code is free to use, rip apart, sell, marry, rub some cheese into...
;
                opt     ZXNEXTREG                               ; enable NextReg instruction


                seg     CODE_SEG, 4:$0000,$8000                 ; flat address
                seg     ULA_SEG, 10:$0000,$4000                 ; ULA "bank" (for Tilemaps)
                seg     ULA2_SEG, 14:$0000,$4000                ; ULA Shadow screen
                seg     SPRITE_SEG, 16:$0000,$c000              ; Sprite bank (with wall)
                seg     LAYER2_SEG, 18:$0000,$4000              ; Layer 2 start address (OS default starts at bank 18)
                seg     BEASTMAN_SEG, 24:$0000,$8000            ; Beast man sprites
                seg     TESTCOED_SEG, 50:$0000,$c000            ; Beast man sprites

                include "includes.asm"
  
  


                seg     CODE_SEG

;Starter			db	1


; 11 frames
;Starter2
		; frame 0
                db	24,25		; banks
                ;dw	$c000	
StackEnd:
                ds      127
StackStart:     db      0



; *****************************************************************************************************************************
; Start of game code
; *****************************************************************************************************************************
StartAddress:
                di

                ; because we don't kill the ROM or take over the interrupts, it modifies 
                ; FRAMES sys variable, so we'll just over write it each frame...what the hell.
                ld      a,($5c78)
                ld      (hack),a
                ld      a,($5c79)
                ld      (hack+1),a
                ld      a,($5c7a)
                ld      (hack+2),a

		;db	$ed,$01,$00,$00,$00,$1f,$00
		;nop
		;db	$ed,$02,$00,$00,$00,$1f,$00

                ;ei
                NextReg 128,0                   ; Make sure expansion bus is off.....
                NextReg $07,3                   ; 28Mhz
                NextReg $05,4			; 60Hz
		NextReg $64,21			; offset copper lines by -21 (top of 60hz screen)

                ld      a,0
                out     ($fe),a

                call    BitmapOn
                call    InitSprites

                ld      a,0                     ; black boarder
                out     ($fe),a


                ld      a,%001000
                ld      bc,$7ffd
                out     (c),a

                NextReg $14,$e7                 ; set transparent colour

                ; fill Shadow screen ULA attribute screen with ink 7, paper 3
                NextReg $57,14                  ; MMU7 to shadow screen
                ld      a,%00011111             ; paper 3, ink 7, bright
                ld      hl,$e000+6144
                ld      (hl),a
                ld      de,$e001+6144
                ld      bc,768

                ldir

                call    InitMap

;		NextReg $43,%10000000
;		ld	b,16
;@pallloop:
;		ld	a,b
;		NextReg $40,a
;		NextReg $41,255
;		djnz	@pallloop



         
; ----------------------------------------------------------------------------------------------------
;               Main loop
; ----------------------------------------------------------------------------------------------------
MainLoop:
                //halt
		ld	hl,0
		db	$ed,$00

                ld      a,(hack)                ; restore data over the top of FRAMES system variable
                ld      ($5c78),a
                ld      a,(hack+1)
                ld      ($5c79),a
                ld      a,(hack+2)
                ld      ($5c7a),a

                ld      a,0
                out     ($fe),a
                ;ld      bc,$fe
                ;in      a,(c)

                call    UpdateCopper                
                call    ScrollGrass

                call    ReadKeyboard
                call    ScrollSprites
                call    ScrollBackground

                call    AnimateBeast


                ; copy in scroll values to copper
                ld      a,(GrassScrolls)
                ld      (ForeX),a
                ld      (Trees0+1),a

                ld      a,(GrassScrolls+4)
                ld      (Grass1+1),a
                ld      a,(GrassScrolls+8)
                ld      (Grass2+1),a
                ld      a,(GrassScrolls+12)
                ld      (Grass3+1),a
                ld      a,(GrassScrolls+16)
                ld      (Grass4+1),a
                ld      a,(GrassScrolls+24)
                ld      (Grass5+1),a
                ld      a,(GrassScrolls+28)
                ld      (Wall+1),a

		NextReg	$56,50
		call	LongCall
		NextReg	$56,2


		;break
		;db $fd,$00

		; debug message print
		ld	a,(Keys+VK_D)
		and	a
		jr	z,@NotPressed
		ld	a,(PrintDebounce)
		and	a
		jr	nz,@Skip_Print
	
		ld	hl,TestString
		RST	$18

		ld	a,255
		jp	@SkipPrint
@NotPressed:
		xor	a
@SkipPrint:
		ld	(PrintDebounce),a
@Skip_Print:


		ld	a,$12
		ld	bc,$8765
		ld	de,$1001


		; Dump registers
		ld	a,(Keys+VK_R)
		and	a
		jr	z,@NotPressed2
		ld	a,(PrintDebounce2)
		and	a
		jr	nz,@Skip_Print2
	
		; Print debug string without corrupting HL
		RST	$18
		db	$ff		; <- flag address follows
		dw	RegString

		ld	a,255
		jp	@SkipPrint2
@NotPressed2:
		xor	a
@SkipPrint2:
		ld	(PrintDebounce2),a
@Skip_Print2:




;				ld		a,(Keys+VK_R)
;				and		a
;				jr		z,NotPressed
;
;HANG:			NextReg	2,2
;				xor		a
;				ld		(Keys+VK_R),a
;NotPressed:
                ;ld      a,0
                ;out     ($fe),a
                jp      MainLoop

PrintDebounce	db	0
PrintDebounce2	db	0
TestString	db	"Hello %s value is - 0x%X, %d, %8b %rpc %raf %rbc %rde",0
		dw	SubString
		db	$21,$43,$ba,$fd
		dw	12345,0
		db	%11110000,%10101010,%11001100,%10000001

SubString	db	"world",0



RegString	db	"AF=$%raf BC=$%rbc DE=$%rde HL=$%rhl SP=$%rsp PC=$%rpc 'AF=$%rAF 'BC=$%rBC 'DE=$%rDE 'HL=$%rHL IX=%rix IY=%riy I=$%rII IM=$%rIM",0


; *****************************************************************************************************************************
; includes modules
; *****************************************************************************************************************************
                include "scroll.asm"
                include "utils.asm"
                include "spritehandler.asm"
                include "copper.asm"


; *****************************************************************************************************************************
; Data
; *****************************************************************************************************************************
TilePalette:    ;incbin  "beast_back_full.pal"
                OCMD  'L"beast_back_full.pal",*'

                seg     ULA_SEG
Tiles:          incbin  "beast_back_full.tiles"
                org $7600
Tilemap:        incbin  "beast_back_full.tilemap"

                seg     LAYER2_SEG
                incbin  "beastf.256"

                seg     ULA2_SEG
                incbin  "beastm.scr"
                
                seg     SPRITE_SEG
                incbin  "sprites.spr"

                seg     BEASTMAN_SEG
                incbin  "BeastMan.spr"


				seg		TESTCOED_SEG
LongCall:
				ld		a,0
				ld		hl,$1234
				ret

                savenex "beast.nex",StartAddress,StackStart        





