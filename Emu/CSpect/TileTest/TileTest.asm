;
; Mode 6/7 test
;
; This code is free to use, rip apart, sell, marry, rub some cheese into...
;
                opt     Z80                                     ; Set Z80 mode
                opt     ZXNEXTREG                               ; enable NextReg instruction


                seg     CODE_SEG, 4:$0000,$8000                 ; flat address
                seg     LOWRES_SEG, 16:$0000,$4000              ; Layer 2 start address (OS default starts at bank 18)
                seg     LAYER2_SEG, 18:$0000,$4000              ; Layer 2 start address (OS default starts at bank 18)
                seg     CHARSET_SEG, 24:$0000,$8000             ; ZX Font
				seg		L2_320_SEG,	 26:$0000,$4000				; 320x256 L2 image
                seg     ULA_SEG, 	 36:$0000,$4000             ; ULA "bank" (for Tilemaps)
                seg     LORES_SEG, 	 38:$0000,$4000             ; Lowres image
                seg     L2Hires_SEG, 40:$0000,$4000             ; Layer 2 hires image
                seg     TESTCOED_SEG, 50:$0000,$c000            ; long call test
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

                ei
                NextReg 128,0                   ; Make sure expansion bus is off.....
                NextReg $07,3                   ; 3.5Mhz
                NextReg $05,4

                NextReg $52,2
                NextReg $53,3
                NextReg $54,4
                NextReg $55,5
                NextReg $56,0
                NextReg $57,1
				;NextReg $12,9

                ld      a,0
                out     ($fe),a

                call    BitmapOn
                call    InitSprites

                ld      a,0                     ; black boarder
                out     ($fe),a


                ;ld      a,%001000
                ;ld      bc,$7ffd
                ;out     (c),a

		ld	a,%11000000
		NextReg $69,a

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

         
; ----------------------------------------------------------------------------------------------------
;               Main loop
; ----------------------------------------------------------------------------------------------------
MainLoop:
                halt

                ld      a,(hack)                ; restore data over the top of FRAMES system variable
                ld      ($5c78),a
                ld      a,(hack+1)
                ld      ($5c79),a
                ld      a,(hack+2)
                ld      ($5c7a),a

                ;ld      a,7
                ;out     ($fe),a
                ;ld      bc,$fe
                ;in      a,(c)

                call    ReadKeyboard

                ; copy in scroll values to copper

				NextReg	$56,50
				call	LongCall
				NextReg	$56,2


				; ----------------------------------------------------- Layer mode select -------------------------------------------------
				; Pick mode 0
				ld		a,(Keys+VK_0)
				and		a
				jr		z,NotPressed0
				ld		a,(reg_15)
				and		%11100011
				or		%00000000
				ld		(reg_15),a
				NextReg	$15,a
				xor		a
				ld		(Keys+VK_0),a
NotPressed0:
				; Pick mode 1
				ld		a,(Keys+VK_1)
				and		a
				jr		z,NotPressed1
				ld		a,(reg_15)
				and		%11100011
				or		%00000100
				ld		(reg_15),a
				NextReg	$15,a
				xor		a
				ld		(Keys+VK_1),a
NotPressed1:
				; Pick mode 2
				ld		a,(Keys+VK_2)
				and		a
				jr		z,NotPressed2
				ld		a,(reg_15)
				and		%11100011
				or		%00001000
				ld		(reg_15),a
				NextReg	$15,a
				xor		a
				ld		(Keys+VK_2),a
NotPressed2:
				; Pick mode 3
				ld		a,(Keys+VK_3)
				and		a
				jr		z,NotPressed3
				ld		a,(reg_15)
				and		%11100011
				or		%00001100
				ld		(reg_15),a
				NextReg	$15,a
				xor		a
				ld		(Keys+VK_3),a
NotPressed3:
				; Pick mode 4
				ld		a,(Keys+VK_4)
				and		a
				jr		z,NotPressed4
				ld		a,(reg_15)
				and		%11100011
				or		%00010000
				ld		(reg_15),a
				NextReg	$15,a
				xor		a
				ld		(Keys+VK_4),a
NotPressed4:
				; Pick mode 5
				ld		a,(Keys+VK_5)
				and		a
				jr		z,NotPressed5
				ld		a,(reg_15)
				and		%11100011
				or		%00010100
				ld		(reg_15),a
				NextReg	$15,a
				xor		a
				ld		(Keys+VK_5),a
NotPressed5:
				; Pick mode 6
				ld		a,(Keys+VK_6)
				and		a
				jr		z,NotPressed6
				ld		a,(reg_15)
				and		%11100011
				or		%00011000
				ld		(reg_15),a
				NextReg	$15,a
				xor		a
				ld		(Keys+VK_6),a
NotPressed6:
				; Pick mode 7
				ld		a,(Keys+VK_7)
				and		a
				jr		z,NotPressed7
				ld		a,(reg_15)
				and		%11100011
				or		%00011100
				ld		(reg_15),a
				NextReg	$15,a
				xor		a
				ld		(Keys+VK_7),a
NotPressed7:


				; ----------------------------------------------------- ULA/Stencil control -------------------------------------------------
				; Toggle sprites ovver the border
				ld		a,(Keys+VK_Y)
				and		a
				jr		z,NotPressedY
				ld		a,(reg_15)
				xor		$22
				ld		(reg_15),a
				NextReg $15,a
				xor		a
				ld		(Keys+VK_Y),a
NotPressedY:


				; ----------------------------------------------------- ULA/Stencil control -------------------------------------------------
				; Toggle stencil mode
				ld		a,(Keys+VK_N)
				and		a
				jr		z,NotPressedN
				ld		a,(reg_68)
				xor		1
				ld		(reg_68),a
				xor		a
				ld		(Keys+VK_N),a
NotPressedN:
				; Toggle ULA output
				ld		a,(Keys+VK_M)
				and		a
				jr		z,NotPressedM
				ld		a,(reg_68)
				xor		$80
				ld		(reg_68),a
				xor		a
				ld		(Keys+VK_M),a
NotPressedM:




				; ----------------------------------------------------- Tilemap control -------------------------------------------------
				; Tiles always on top
				ld		a,(Keys+VK_R)
				and		a
				jr		z,NotPressedR
				ld		a,(reg_6b)
				xor		1
				ld		(reg_6b),a
				NextReg	$6b,a
				xor		a
				ld		(Keys+VK_R),a
NotPressedR:
				; Tile attribute priority toggle
				ld		a,(Keys+VK_T)
				and		a
				jr		z,NotPressedT
				ld		a,(reg_6c)
				xor		1
				ld		(reg_6c),a
				NextReg	$6c,a
				call	ToggleTilePri
				xor		a
				ld		(Keys+VK_T),a
NotPressedT:




				; SHIFT pressed, scroll L2
				ld		a,(Keys+VK_CAPS)
				and		a
				jr		z,DoTileScrolling
			
				; Scroll sprites up/down
				ld		a,(Keys+VK_A)
				and		a
				jr		z,@NotPressedA
				ld		a,(SpriteYCoord)
				inc		a
				ld		(SpriteYCoord),a
				call	SetUpSprites

				xor		a
				ld		(Keys+VK_A),a
@NotPressedA:
				ld		a,(Keys+VK_Q)
				and		a
				jr		z,@NotPressedQ
				ld		a,(SpriteYCoord)
				dec		a
				ld		(SpriteYCoord),a
				call	SetUpSprites
				xor		a
				ld		(Keys+VK_Q),a
@NotPressedQ:

				; ----------------------------------------------------- Tilemap Scrolling -------------------------------------------------
				; Scroll tiles left/right
DoTileScrolling:
				ld		a,(Keys+VK_P)
				and		a
				jr		z,NotPressedP
				ld		hl,(TilesX)
				dec		hl
				ld		a,h
				and		3
				ld		h,a				
				ld		(TilesX),hl
				xor		a
				ld		(Keys+VK_P),a
NotPressedP:
				ld		a,(Keys+VK_O)
				and		a
				jr		z,NotPressedO
				ld		hl,(TilesX)
				inc		hl
				ld		a,h
				and		3
				ld		h,a				
				ld		(TilesX),hl				
				xor		a
				ld		(Keys+VK_O),a
NotPressedO:
				ld		a,(TilesX)
				NextReg	$30,a
				ld		a,(TilesX+1)
				NextReg	$2f,a



				; Scroll tiles up/down
				ld		a,(Keys+VK_A)
				and		a
				jr		z,NotPressedA
				ld		a,(TilesY)
				dec		a
				ld		(TilesY),a
				xor		a
				ld		(Keys+VK_A),a
NotPressedA:
				ld		a,(Keys+VK_Q)
				and		a
				jr		z,NotPressedQ
				ld		a,(TilesY)
				inc		a
				ld		(TilesY),a
				xor		a
				ld		(Keys+VK_Q),a
NotPressedQ:
				ld		a,(TilesY)
				NextReg	$31,a


				; SHIFT pressed, scroll L2
				ld		a,(Keys+VK_CAPS)
				and		a
				jr		z,ULA_Scrolling
			

				; ----------------------------------------------------- L2 Scrolling -------------------------------------------------
				; Scroll Layer 2 left/right
				ld		a,(Keys+VK_I)
				and		a
				jr		z,@NotPressedI
				ld		hl,(L2X)
				dec		hl
				ld		a,h
				and		1
				ld		h,a				
				ld		(L2X),hl
				xor		a
				ld		(Keys+VK_I),a
@NotPressedI:
				ld		a,(Keys+VK_U)
				and		a
				jr		z,@NotPressedU
				ld		hl,(L2X)
				inc		hl
				ld		a,h
				and		1
				ld		h,a				
				ld		(L2X),hl				
				xor		a
				ld		(Keys+VK_U),a
@NotPressedU:
				; Scroll ULA up/down
				ld		a,(Keys+VK_S)
				and		a
				jr		z,@NotPressedS
				ld		a,(L2Y)
				dec		a
				ld		(L2Y),a
				xor		a
				ld		(Keys+VK_S),a
@NotPressedS:
				ld		a,(Keys+VK_W)
				and		a
				jr		z,@NotPressedW
				ld		a,(L2Y)
				inc		a
				ld		(L2Y),a
				xor		a
				ld		(Keys+VK_W),a
@NotPressedW:
				ld		a,(L2X)
				NextReg	$27,a


				; update ULA Control - every frame
				ld		a,(L2X)
				NextReg	$16,a
				ld		a,(L2X+1)
				NextReg	$71,a
				ld		a,(L2Y)
				NextReg	$17,a






ULA_Scrolling:
				; ----------------------------------------------------- ULA Scrolling -------------------------------------------------
				; Scroll tiles left/right
				ld		a,(Keys+VK_I)
				and		a
				jr		z,NotPressedI
				ld		hl,(ULAX)
				dec		hl
				ld		a,h
				and		1
				ld		h,a				
				ld		(ULAX),hl
				xor		a
				ld		(Keys+VK_I),a
NotPressedI:
				ld		a,(Keys+VK_U)
				and		a
				jr		z,NotPressedU
				ld		hl,(ULAX)
				inc		hl
				ld		a,h
				and		1
				ld		h,a				
				ld		(ULAX),hl				
				xor		a
				ld		(Keys+VK_U),a
NotPressedU:
				; update ULA Control - every frame
				ld		hl,(ULAX)
				ld		a,(reg_68)
				and		%11111011		; clear lowest bit (for 1/2 pixel scrolling)
				ld		c,a
				ld		a,l
				and		1				; get lowest bit
				add		a,a
				add		a,a				; move bit into position
				or		c
				NextReg	$68,a
				
				; shift HL down by 1, L then holds the MSB of the scrolling
				srl		h
				rr		l
				ld		a,l
				NextReg	$26,a			; MSB of ULA scrolling



				; Scroll ULA up/down
				ld		a,(Keys+VK_S)
				and		a
				jr		z,NotPressedS
				ld		a,(ULAY)
				dec		a
				ld		(ULAY),a
				xor		a
				ld		(Keys+VK_S),a
NotPressedS:
				ld		a,(Keys+VK_W)
				and		a
				jr		z,NotPressedW
				ld		a,(ULAY)
				inc		a
				ld		(ULAY),a
				xor		a
				ld		(Keys+VK_W),a
NotPressedW:
				ld		a,(ULAY)
				NextReg	$27,a


				; ----------------------------------------------------- Blend Modes -------------------------------------------------
				; Blend modes - Z,X,C,V
				ld		a,(Keys+VK_Z)
				and		a
				jr		z,NotPressedZ
				ld		a,(reg_68)
				and		%10011111
				or		%00000000
				ld		(reg_68),a
				NextReg	$68,a
				xor		a
				ld		(Keys+VK_Z),a
NotPressedZ:
				ld		a,(Keys+VK_X)
				and		a
				jr		z,NotPressedX
				ld		a,(reg_68)
				and		%10011111
				or		%01000000
				ld		(reg_68),a
				NextReg	$68,a
				xor		a
				ld		(Keys+VK_X),a
NotPressedX:
				ld		a,(Keys+VK_C)
				and		a
				jr		z,NotPressedC
				ld		a,(reg_68)
				and		%10011111
				or		%01100000
				ld		(reg_68),a
				NextReg	$68,a
				xor		a
				ld		(Keys+VK_V),a
NotPressedC:
				ld		a,(Keys+VK_V)
				and		a
				jr		z,NotPressedV
				ld		a,(reg_68)
				and		%10011111
				or		%00100000
				ld		(reg_68),a
				NextReg	$68,a
				xor		a
				ld		(Keys+VK_V),a
NotPressedV:





				; ----------------------------------------------------- Layer 2 Modes -------------------------------------------------
				; Layer 2 - 256x192x8
				ld		a,(Keys+VK_F)
				and		a
				jr		z,NotPressedF
				ld		a,%00000000				
				ld		(reg_70),a
				NextReg	$70,a
				NextReg	$18,0
				NextReg	$18,255
				NextReg	$18,0
				NextReg	$18,192
				ld		a,18/2
				ld		(reg_12),a
				NextReg	$12,a

				ld		a,1
				out		($fe),a
				Nextreg $14,$e7
				xor		a
				ld		(Keys+VK_F),a
NotPressedF:
				; Layer 2 - 320x256x8
				ld		a,(Keys+VK_G)
				and		a
				jr		z,NotPressedG
				ld		a,%00010000				; 320x256
				ld		(reg_70),a
				NextReg	$70,a
				ld		a,26/2
				ld		(reg_12),a
				NextReg	$12,a
				NextReg $43,%01010000 

		        NextReg $18,8
		        NextReg $18,152
		        NextReg $18,8
		        NextReg $18,248
				xor		a
				ld		(Keys+VK_G),a
NotPressedG:
				; Layer 2 - 640x256x4
				ld		a,(Keys+VK_H)
				and		a
				jr		z,NotPressedH
				call	CopyL2Hires
				;ld		a,%00100000
				;ld		(reg_70),a
				;NextReg	$70,a
				xor		a
				ld		(Keys+VK_H),a
NotPressedH:


				; ----------------------------------------------------- ULA -------------------------------------------------
				; Enable ULA screen
				ld		a,(Keys+VK_K)
				and		a
				jr		z,NotPressedK
				ld		a,(reg_15)
				and		%01111111
				or		%00000000
				ld		(reg_15),a
				NextReg	$15,a
				ld		a,%11000000
				NextReg $69,a
	            NextReg $43,%00110000     ; Tilemap palette 0
				xor		a
				ld		(ULAX),a
				ld		(ULAX+1),a
				ld		(ULAY),a
				ld		(Keys+VK_K),a
NotPressedK:
				; Enable Lores screen
				ld		a,(Keys+VK_L)
				and		a
				jr		z,NotPressedL
				ld		a,(reg_15)
				and		%01111111
				or		%10000000
				ld		(reg_15),a
				NextReg	$15,a
				ld		a,%10000000
				NextReg $69,a
	            NextReg $43,%00110000     ; Tilemap palette 0

				ld		a,1
				nextreg	$43,a
				xor		a
				nextreg	$40,a
@SetAll:
		        nextreg 65,a
		        inc     a
		        cp      0
		        jr      nz,@SetAll

				call	CopyLores
				xor		a
				ld		(ULAX),a
				ld		(ULAX+1),a
				ld		(ULAY),a
				ld		(Keys+VK_L),a
NotPressedL:
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



				; ----------------------------------------------------- BugTest -------------------------------------------------

				ld		a,(Keys+VK_D)
				and		a
				jr		z,NotPressedD


				; SHIFT+D = Set L2 left clip to be larger than L2 right clip			
				ld		a,(Keys+VK_CAPS)
				and		a
				jr		z,Skip_L2CLIPTest

				ld		a,190					; Left>Right
				NextReg	$18,a
				ld		a,100
				NextReg	$18,a
				ld		a,0
				NextReg	$18,a
				ld		a,192
				NextReg	$18,a

Skip_L2CLIPTest:
				ld		a,(Keys+VK_SYM)
				and		a
				jr		z,Skip_L2CLIPTest

				; Set global transparency as black (RGB:0)
				ld		a,(Keys+VK_D)
				and		a
				jr		z,NotPressedD

				ld		a,0
				out		($fe),a
				Nextreg $14,0
				Nextreg $4a,$e7
;8NotPressedD:

ClearD:
				xor		a
				ld		(Keys+VK_D),a
NotPressedD:


				; ----------------------------------------------------- Draw HEX values -------------------------------------------------
				NextReg	$56,14
				ld		a,(reg_6b)
				ld		de,$d800-(2048+32)
				call	PrintHex

				ld		a,(reg_6c)
				ld		de,$d800-(2048+29)
				call	PrintHex

				ld		a,(TilesX+1)
				ld		de,$d800-(2048+26)
				call	PrintHex

				ld		a,(TilesX)
				ld		de,$d800-(2048+24)
				call	PrintHex

				ld		a,(TilesY)
				ld		de,$d800-(2048+21)
				call	PrintHex

				ld		a,(ULAX)
				ld		de,$d800-(2048+18)
				call	PrintHex

				ld		a,(ULAY)
				ld		de,$d800-(2048+15)
				call	PrintHex

				; L2
				ld		a,(L2X+1)
				ld		de,$d800-(2048+12)
				call	PrintHex

				ld		a,(L2X)
				ld		de,$d800-(2048+10)
				call	PrintHex


				ld		a,(L2Y)
				ld		de,$d800-(2048+6)
				call	PrintHex
                jp      MainLoop

reg_15			db		%00011001	; Layer control
reg_68			db		%00100000	; ULA control
reg_6b			db		%10000000	; Tilemap Contro
reg_6c			db		0			; Default Tilemap Attribute
reg_70			db		0			; L2 mode
reg_12			db		0			; L2 bank
TilesX		    dw		0
TilesY		    db		0
ULAX		    dw		0
ULAY		    db		0
L2X		    	dw		0
L2Y		    	db		0
hack			db		0,0,0,0


; *****************************************************************************************************************************
; includes modules
; *****************************************************************************************************************************
                include "scroll.asm"
                include "utils.asm"
                
				nop
				include "spritehandler.asm"
				nop


; *****************************************************************************************************************************
; Data
; *****************************************************************************************************************************
TilePalette:    incbin  "tiles.pal"
L2HiResPalette:	incbin	"L2_640x256x16.pal"

                seg     ULA_SEG
Tiles:          incbin  "tiles.tiles"		
                org $7600
Tilemap:        incbin  "tiles.tilemap"		

                seg     LAYER2_SEG
                incbin  "beastf.256"		; use the beast L2 background for testing
                
                seg     CHARSET_SEG
                incbin  "charset.dat"		; ZX rom FONT, as the NEXT rom doesn't have the font available to us

				seg		L2_320_SEG
				incbin	"Monkey320.256"

				seg		LORES_SEG
				incbin	"LowRes.256"

				seg		L2Hires_SEG
				incbin	"L2_640x256x16.256"

				seg		TESTCOED_SEG
LongCall:
				ld		a,0
				ld		hl,$1234
				ret

                savenex "TileTest.nex",StartAddress,StackStart        





