' vim:ts=4:et:
' ---------------------------------------------------------
' NextLib v7.0 - David Saphier / em00k 2020
' Help and thanks Boriel, Flash, Baggers, Britlion, Shiru, Mike Daily 
' Matt Davies for help on the fastPLotL2 
' ---------------------------------------------------------

#ifndef __NEXTLIB__
#define __NEXTLIB__

#pragma push(case_insensitive)
#pragma case_insensitive = TRUE
#pragma zxnext = TRUE


#DEFINE NextReg(REG,VAL) \
	ASM\
	DW $91ED\
	DB REG\
	DB VAL\
	END ASM 
	
#DEFINE OUTINB \
	Dw $90ED

#define BREAK \
	DB $c5,$DD,$01,$0,$0,$c1 \
	
#define BBREAK \
	ASM\
	BREAK\
	END ASM 
	
#DEFINE MUL_DE \
	DB $ED,$30\

#DEFINE SWAPNIB \
	DB $ED,$23

#DEFINE ADD_HL_A \
		DB $ED,$31\

#DEFINE PIXELADD \
		DB $ED,$94\

#DEFINE SETAE \
		DB $ED,$95\

#DEFINE PIXELDN \
		DB $ED,$93\


#DEFINE TEST val \
		DB $ED,$27\
		DB val

#DEFINE ADDBC value \
		DB $ED,$36\
		DW value

#DEFINE ADDHLA \
		DB $ED,$31\

#DEFINE ADDDEA \
		DB $ED,$32\

#DEFINE ADDBCA \
		DB $ED,$33\

#DEFINE PUSHD value \
		DB $ED,$8A\
		DW value 
		
#DEFINE DIHALT \
		ASM\
		di\
		halt\
		end asm 

#DEFINE nextregnn reg value \
		dw $91ed \
		db reg \
		db value 

#DEFINE nextregna reg \
		dw $92ed \
		db reg 

#DEFINE ESXDOS \
		rst 8 	

#DEFINE getreg(REG)\
	db $3e,REG,$01,$3b,$24,$ed,$79,$04,$ed,$78	
		
asm 
	M_GETSETDRV	equ $89
	F_OPEN     	equ $9a
	F_CLOSE    	equ $9b
	F_READ     	equ $9d
	F_WRITE    	equ $9e
	F_SEEK     	equ $9f
	F_STAT		equ $a1 
	FA_READ     	equ $01
	FA_APPEND   	equ $06
	FA_OVERWRITE	equ $0C
	LAYER2_ACCESS_PORT EQU $123B
end asm 

'border 0 : paper 0: ink 7 : cls 
 
Sub MMU8(byval nn as ubyte, byval na as ubyte)
	asm 	
		PROC 
		LOCAL NREG
		LD a,(IX+5)		; slot
		add a,$50			; NextREG $50 - $57 for slot 
		ld (NREG),a		; store at NREG 
		LD a,(IX+7)		; get memory bank selected
		DW $92ED			; lets select correctly slot 
		NREG: DB 0		; 
		ENDP 
	end asm 
end sub 

Sub fastcall MMU8new(byval slot as ubyte, byval memorybank as ubyte)
	' changes 8kb  slots valid slots 0-7 mapped as below 
	' banks 16 - 223
	' Area       16k 8k def 
	' $0000-$1fff	1	 0	ROM		ROM (255)	Normally ROM. Writes mappable by layer 2. IRQ and NMI routines here.
	' $2000-$3fff		 1				ROM (255)	Normally ROM. Writes mapped by Layer 2.
	' $4000-$5fff	2	 2	5			10				Normally used for normal/shadow ULA screen.
	' $6000-$7fff		 3				11				Timex ULA extended attribute/graphics area.
	' $8000-$9fff	3	 4	2			4					Free RAM.
	' $a000-$bfff		 5				5					Free RAM.
	' $c000-$dfff	4	 6	0			0					Free RAM. Only this area is remappable by 128 memory management.
	' $e000-$ffff		 7	1								Free RAM. Only this area is remappable by 128 memory management.
	'
	' 16kb  	8kb 
	' 8-15		16-31		$060000-$07ffff	128K	Extra RAM
	' 16-47		32-95		$080000-$0fffff	512K	1st extra IC RAM (available on unexpanded Next)
	' 48-79		96-159	$100000-$17ffff	512K	2nd extra IC RAM (only available on expanded Next)
	' 80-111	160-223	$180000-$1fffff	512K	3rd extra IC RAM (only available on expanded Next)'
	' Fastcall a is first param, next on stack 
	asm 	
		;BREAK 
			PROC 
			LOCAL NREG
			add a,$50			; A= 1st param so add $50 for MMU $50-$57
			ld (NREG),a		; store at NREG 
			pop de				; dont need this but need off the stack 
			pop af 				; get second param in af, this will be the bank
			DW $92ED			; lets select correctly slot 
			NREG: DB 0		; 
			push de 			; fix stack before leaving
		ENDP 
	end asm 
end sub 

Sub fastcall MMU16(byval memorybank as ubyte)
	' changes 16kb 128k style bank @ $c000, supports full ram
	' now works slots 6 and 7 will be changed 
		' asm 
		' ; bank 16-31 32-95 96-159 169-223 
		' ;BREAK 	

		' ld d,a				; 4
		' AND %00000111 ; 4
		' ld bc,$7ffd		; 10 
		' out (c),a			; 12 
		' ;and 248
		' ;ld (23388),a 
		' ld a,d				; 4 
		' AND %11110000 ; 4
		' SWAPNIB				; 16
		' ld b,$df		 	; 7
		' out (c),a			; 12 = 73 t states								
		
		' end asm 
' old routine before optimization 
' 		; bank 16-31 32-95 96-159 169-223 
asm 
		ld a,(IX+5)		; 19 ts
		;BREAK 	
		AND %00000111 ; 4
		ld bc,$7ffd		; 10 
		out (c),a			; 12 
		ld a,(IX+5)		; 19 
		AND %11110000 ; 4
		srl a 				; 8 
		srl a					; 8
		srl a					; 8 
		srl a					; 8 
		ld bc,$dffd 	; 10 
		out (c),a			; 12 = 122
		end asm 
end sub  

Function fastcall GetMMU(byval slot as ubyte) as ubyte 
	asm 
		ld bc,$243B			; Register Select 
		add a,$50			; a = slot already so add $50 for slot regs 
		out(c),a			; 
		ld bc,$253B			; reg access 
		in a,(c)
	end asm 
END function 	

Function GetReg(byval slot as ubyte) as ubyte 
	asm 	
		push bc 
		ld bc,$243B			; Register Select 
		out(c),a			; 
		ld bc,$253B			; reg access 
		in a,(c)
		pop bc 
	end asm 
END function  

sub Debug(BYVAL x as UBYTE,byval y as ubyte, s as string)
	' fast print, doesnt need the print library '
	asm 
	PROC 
		;BREAK 
		ld l,(IX+8)  					; address string start containing string size  
		ld h,(IX+9)
		push hl  							; save this 
		ld b,0 								; flatten b 
		ld c,(hl)							; first byte is length of strin
		push bc 							; save it 
		CHAN_OPEN		EQU 5633
		ld a,2								; upper screen
		call CHAN_OPEN				; get the channel sorted
		ld a,22								; AT 
		rst 16								; print 
		ld a,(IX+5)						; x
		rst 16
		ld a,(IX+7)						; y 
		rst 16
		pop bc								; pop back length 
		pop de 								; pop back start 
		inc de 
		inc de 
		call 8252							; use rom print 
	ENDP 
	end asm 
end sub  
	
sub fastcall ShowLayer2(byval switch as ubyte)
	asm 
		cp 1
		jr z,enable 
		cp 2
		jr z,shadowenable 
		;ld a,%00001010
		jr showlayer 
shadowenable:
		ld a,3
		jr showlayer
	enable:
		ld a,2
		;or %00010010
	showlayer:
		ld bc,$123b
		out (c),a
	end asm 


end sub 

Sub fastcall ScrollLayer(byval x as ubyte,byval y as ubyte)
	asm 
		PROC 
		 pop hl 					; store ret address 
	;	BREAK 
	;	ld a,(IX+5)				; load x with x 
	;	ld a,e					; load x with x 
		DW $92ED 				; nextreg A 
		DB $16					; a is put in to x scroll
	;	pop de 
	;	ld a,(IX+7)
	;	ld a,d
		pop af 
		DW $92ED 
		DB $17					; a is put into y scroll 
		 push hl 
		ENDP
	end asm
end sub 

SUB fastcall PlotL2(byVal X as ubyte, byval Y as ubyte, byval T as ubyte)

ASM 
	; PlotL2 (c) 2020 David Saphier / em00k 
	;BREAK
	;ld (outplot+1),bc 
	
	pop  hl      ; save return address off stack 
    ld   e,a     ; put a into e
	ld   bc,LAYER2_ACCESS_PORT
    pop  af      ; pop stack into a = Y 
    ld   d,a     ; put into d
    and  $c0     ; yy00 0000
	cp $c0
	jr z,.skip_wrap1
	jr .no_wrap
	xor a
skip_wrap1:
	pop af : jr skip_wrap2
.no_wrap:
end asm 
LayerShadow:
asm 
    or   3       ; yy00 0011
    out  (c),a   ; select 8k-bank    
	ld   a,d     ; yyyy yyyy
    and  63      ; 00yy yyyy	
    ld   d,a
	pop  af      ; get colour/map value off stack 
    ld  (de),a   ; set pixel value

skip_wrap2:	

    ld   a,2     ; 0000 0010
   ; out  (c),a   ; Layer2 writes off 
    push hl      ; restore return address
	

	
outplot:
	;ld bc,0
; 6-7	Video RAM bank select
; 3		Shadow Layer 2 RAM select
; 1		Layer 2 visible
; 0		Enable Layer 2 write paging
	
  END ASM 
end sub    


SUB fastcall PlotL2Shadow(byVal X as ubyte, byval Y as ubyte, byval T as ubyte)

ASM 
	;BREAK
    ld   bc,LAYER2_ACCESS_PORT
    pop  hl      ; save return address 
    ld   e,a     ; put a into e
    pop  af      ; pop stack into a 
    ld   d,a     ; put into d
    and  192     ; yy00 0000
    or   1       ; yy00 0011
    out  (c),a   ; select 8k-bank    
    ld   a,d     ; yyyy yyyy
    and  63      ; 00yy yyyy
    ld   d,a
    pop  af      ; get colour/map value 
    ld  (de),a   ; set pixel value
    ld   a,0     ; 0000 0010
    out  (c),a   ; select ROM?
    push hl      ; restore return address
  END ASM 
end sub   

SUB fastcall CIRCLEL2(byval x as ubyte, byval y as ubyte, byval radius as ubyte, byval col as ubyte)

ASM
		;BREAK 
		PROC
		LOCAL __CIRCLEL2_LOOP
		LOCAL __CIRCLEL2_NEXT
		LOCAL __circle_col
		LOCAL circdone
		pop ix 		; return address off stack 
		ld e,a 		; x 
		pop af 
		ld d,a 
		pop af
		ld h,a
		pop af 
		ld (__circle_col+1),a
		
CIRCLEL2:
; __FASTCALL__ Entry: D, E = Y, X point of the center
; A = Radious
__CIRCLEL2:
		push de	
		;ld h,a
		ld a, h
		exx
		pop de		; D'E' = x0, y0
		ld h, a		; H' = r

		ld c, e
		ld a, h
		add a, d
		ld b, a
		call __CIRCLEL2_PLOT	; PLOT (x0, y0 + r)

		ld b, d
		ld a, h
		add a, e
		ld c, a
		call __CIRCLEL2_PLOT	; PLOT (x0 + r, y0)

		ld c, e
		ld a, d
		sub h
		ld b, a
		call __CIRCLEL2_PLOT ; PLOT (x0, y0 - r)

		ld b, d
		ld a, e
		sub h
		ld c, a
		call __CIRCLEL2_PLOT ; PLOT (x0 - r, y0)

		exx
		ld b, 0		; B = x = 0
		ld c, h		; C = y = Radius
		ld hl, 1
		or a
		sbc hl, bc	; HL = f = 1 - radius

		ex de, hl
		ld hl, 0
		or a
		sbc hl, bc  ; HL = -radius
		add hl, hl	; HL = -2 * radius
		ex de, hl	; DE = -2 * radius = ddF_y, HL = f

		xor a		; A = ddF_x = 0
		ex af, af'	; Saves it

__CIRCLEL2_LOOP:
		ld a, b
		cp c
		jp nc,circdone		; Returns when x >= y

		bit 7, h	; HL >= 0? : if (f >= 0)...
		jp nz, __CIRCLEL2_NEXT

		dec c		; y--
		inc de
		inc de		; ddF_y += 2

		add hl, de	; f += ddF_y

__CIRCLEL2_NEXT:
		inc b		; x++
		ex af, af'
		add a, 2	; 1 Cycle faster than inc a, inc a

		inc hl		; f++
		push af
		add a, l
		ld l, a
		ld a, h
		adc a, 0	; f = f + ddF_x
		ld h, a
		pop af
		ex af, af'

		push bc	
		exx
		pop hl		; H'L' = Y, X
		
		ld a, d
		add a, h
		ld b, a		; B = y0 + y
		ld a, e
		add a, l
		ld c, a		; C = x0 + x
		call __CIRCLEL2_PLOT ; plot(x0 + x, y0 + y)

		ld a, d
		add a, h
		ld b, a		; B = y0 + y
		ld a, e
		sub l
		ld c, a		; C = x0 - x
		call __CIRCLEL2_PLOT ; plot(x0 - x, y0 + y)

		ld a, d
		sub h
		ld b, a		; B = y0 - y
		ld a, e
		add a, l
		ld c, a		; C = x0 + x
		call __CIRCLEL2_PLOT ; plot(x0 + x, y0 - y)

		ld a, d
		sub h
		ld b, a		; B = y0 - y
		ld a, e
		sub l
		ld c, a		; C = x0 - x
		call __CIRCLEL2_PLOT ; plot(x0 - x, y0 - y)
		
		ld a, d
		add a, l
		ld b, a		; B = y0 + x
		ld a, e	
		add a, h
		ld c, a		; C = x0 + y
		call __CIRCLEL2_PLOT ; plot(x0 + y, y0 + x)
		
		ld a, d
		add a, l
		ld b, a		; B = y0 + x
		ld a, e	
		sub h
		ld c, a		; C = x0 - y
		call __CIRCLEL2_PLOT ; plot(x0 - y, y0 + x)

		ld a, d
		sub l
		ld b, a		; B = y0 - x
		ld a, e	
		add a, h
		ld c, a		; C = x0 + y
		call __CIRCLEL2_PLOT ; plot(x0 + y, y0 - x)

		ld a, d
		sub l
		ld b, a		; B = y0 - x
		ld a, e	
		sub h
		ld c, a		; C = x0 + y
		call __CIRCLEL2_PLOT ; plot(x0 - y, y0 - x)

		exx
		jp __CIRCLEL2_LOOP

__CIRCLEL2_PLOT:
		
		push de
		push af
		ld  e,c     ; put b into e x
		ld  d,b     ; put c into d y
		ld a,d
		ld  bc,$123B
		and 192     ; yy00 0000
		or  3       ; yy00 0011
		out (c),a   ; select 8k-bank    
		ld  a,d     ; yyyy yyyy
		and 63      ; 00yy yyyy
		ld  d,a
__circle_col:
		ld 	a,255
		ld  (de),a   ; set pixel value
		ld  a,2     ; 0000 0010
		out (c),a   ; select ROM?
		
		pop af 
		pop de
		ret 
circdone:
		push ix 
	;	BREAK 		
		ENDP
END ASM 
end sub 

Sub fastcall NextRegA(reg as ubyte,value as ubyte)
	asm 
		PROC
		LOCAL reg
		;ld a,(IX+5) ; 19
		ld (reg),a			; 17 
		;ld a,(IX+7) ; 19
		pop hl 				; 10 
		pop af				; 10 
		DW $92ED 			; 20
	reg:	
		db 0
		push hl 				; 11 		68 T (old 75t)
		ENDP 
	end asm
end sub 

sub fastcall swapbank(byVal bank as ubyte)
	asm
		di					; disable ints
		ld e,a
		lD a,(23388)
		AND 248
		OR e ; select bank e
		LD BC,32765 
		LD (23388),A
		OUT (C),A
		EI
	END ASM 
end sub 

SUB zx7Unpack(source as uinteger, dest AS uinteger)
	' dzx7 by einar saukas et al '
	ASM 
	;	push hl
	;	push ix
	;	LD L, (IX+4)
	;	LD H, (IX+5)
		LD E, (IX+6)
		LD D, (IX+7)	
		call dzx7_turbo

		jp zx7end
				
		dzx7_turbo:
		ld      a, $80
		dzx7s_copy_byte_loop:
		ldi                             ; copy literal byte
		dzx7s_main_loop:
		call    dzx7s_next_bit
		jr      nc, dzx7s_copy_byte_loop ; next bit indicates either literal or sequence

		; determine number of bits used for length (Elias gamma coding)
		push    de
		ld      bc, 0
		ld      d, b
		dzx7s_len_size_loop:
		inc     d
		call    dzx7s_next_bit
		jr      nc, dzx7s_len_size_loop

		; determine length
		dzx7s_len_value_loop:
		call    nc, dzx7s_next_bit
		rl      c
		rl      b
		jr      c, dzx7s_exit           ; check end marker
		dec     d
		jr      nz, dzx7s_len_value_loop
		inc     bc                      ; adjust length

		; determine offset
		ld      e, (hl)                 ; load offset flag (1 bit) + offset value (7 bits)
		inc     hl
		defb    $cb, $33                ; opcode for undocumented instruction "SLL E" aka "SLS E"
		jr      nc, dzx7s_offset_end    ; if offset flag is set, load 4 extra bits
		ld      d, $10                  ; bit marker to load 4 bits
		dzx7s_rld_next_bit:
		call    dzx7s_next_bit
		rl      d                       ; insert next bit into D
		jr      nc, dzx7s_rld_next_bit  ; repeat 4 times, until bit marker is out
		inc     d                       ; add 128 to DE
		srl	d			; retrieve fourth bit from D
		dzx7s_offset_end:
		rr      e                       ; insert fourth bit into E

		; copy previous sequence
		ex      (sp), hl                ; store source, restore destination
		push    hl                      ; store destination
		sbc     hl, de                  ; HL = destination - offset - 1
		pop     de                      ; DE = destination
		ldir
		dzx7s_exit:
		pop     hl                      ; restore source address (compressed data)
		jr      nc, dzx7s_main_loop
		dzx7s_next_bit:
		add     a, a                    ; check next bit
		ret     nz                      ; no more bits left?
		ld      a, (hl)                 ; load another group of 8 bits
		inc     hl
		rla
		ret
		zx7end:
	;	pop ix
	;	pop hl
	END ASM 
	
end sub

Sub InitSprites(byVal Total as ubyte, spraddress as uinteger)
		' REM 16x16px ''
	ASM 
		ld a,(IX+5)
		ld d,a
		;Select slot #0
		ld a, 0
		ld bc, $303b
		out (c), a

		ld b,d								; we set up a loop for 16x16 sprites 		

		ld l, (IX+6)
		ld h, (IX+7)
sploop:
		push bc
		ld bc,$005b					
		otir
		pop bc 
		djnz sploop
	end asm 
end sub 

sub RemoveSprite(spriteid AS UBYTE, visible as ubyte)
	ASM 
		push bc 
		ld a,(IX+5)					; get ID spriteid
		ld bc, $303b				; selct sprite  
		out (c), a
		ld bc, $57					; sprite port  

		; REM now send 4 bytes 

		ld a,0						; get x and send byte 1
		out (c), a          		;   X POS 
		ld a,0						; get y and send byte 2
		out (c), a          		;   X POS
		ld a,0						; no palette offset and no rotate and mirrors flags send  byte 3
		out (c), a 
		ld a,(IX+7)					; Sprite visible and show pattern #0 byte 4
		out (c), a
		pop bc 
	END ASM 

end sub 	      

sub UpdateSprite(ByVal x AS uinteger,ByVal y AS UBYTE,ByVal spriteid AS UBYTE,ByVal pattern AS UBYTE,ByVal mflip as ubyte,ByVal anchor as ubyte)
	'                  5            7          9                  11              13
	'  http://devnext.referata.com/wiki/Sprite_Attribute_Upload
	'  Uploads attributes of the sprite slot selected by Sprite Status/Slot Select ($303B). 
	' Attributes are in 4 byte blocks sent in the following order; after sending 4 bytes the address auto-increments to the next sprite. 
	' This auto-increment is independent of other sprite ports. The 4 bytes are as follows:

	' Byte 1 is the low bits of the X position. Legal X positions are 0-319 if sprites are allowed over the border or 32-287 if not. The MSB is in byte 3.
	' Byte 2 is the Y position. Legal Y positions are 0-255 if sprites are allowed over the border or 32-223 if not.
	' Byte 3 is bitmapped:

	' Bit	Description
	' 4-7	Palette offset, added to each palette index from pattern before drawing
	' 3	Enable X mirror
	' 2	Enable Y mirror
	' 1	Enable rotation
	' 0	MSB of X coordinate
	' Byte 4 is also bitmapped:
	' 
	' Bit	Description
	' 7	Enable visibility
	' 6	Reserved
	' 5-0	Pattern index ("Name")

	ASM 		
		ld a,(IX+9)			;19					; get ID spriteid
		ld bc, $303b			;10					; selct sprite slot 
		; sprite 
		out (c), a			;12
		ld bc, $57			;10					; sprite control port 
		ld a,(IX+4) 			;19					; now send 4 bytes get x and send byte 1
		out (c), a          	;12			
		ld a,(IX+7)			;19					; get y and send byte 2
		out (c), a 			;12
		ld d,(IX+13)			;19					; now palette offset and no rotate and mirrors flags send  byte 3 and the MSB of X 
		ld a,(IX+5)			;19
		and 1				;7
		or d 				;4
		out (c), a 			;12	
		ld a,(IX+11)			;19					; Sprite visible and show pattern #0 byte 4
		or 192 				;7
		out (c), a			;12
		ld a,(IX+15)			;19
		out (c), a			;12 
		; 243 T 	
	END ASM 
end sub

sub LoadBMP(byval fname as STRING)

		dim pos as ulong
		
		pos = 1024+54+16384*2

		asm 
				ld a,1
				ld (loadbank),a
				DW $91ed,$2456
				DW $91ed,$2557
		keeploading:

		end asm 
		'
		
		'LoadSD(fname, $c000, $4000, pos)                 'dump its contents to the screen
		pos=pos-16384
	
		asm 
				
				ld bc, $123b
				ld a,(loadbank)
				or %00000001
				out (c),a
				ld	bc,$4000		;we need to copy it backwards
				ld	hl,$FFFF		;start at $ffff
				ld c,64 			; 64 lines per third 
				ld de,255			; start top right 
		ownlddr:
				ld b,0				; b=256 loops 
		innderlddr:
				
				ld a,(hl)			
				ld (de),a 			; put a in (de)
				;and %00000101		; for border effect 
				;out ($fe),a
				
				dec hl 				; dec hl and de 
				dec de 					
				djnz innderlddr		; has b=0 again?
				inc d 				; else inc d 256*2
				inc d 			
				dec bc				; dec bc b=0 if we're here 
				ld a,b				; a into b 
				or c				; or outer loop c with a
				jp nz,ownlddr		; both a and c are not zero 

				ld a, 0				; enable write  
				ld bc, $123b 		; set port for writing	
				out (c), a
				
				ld a,(loadbank)
				add a,$40
				ld (loadbank),a
				cp $c1
				jp nz,keeploading
				
				jp endingn
		loadbank:
				db 0
		endingn:
				ld a,0
				ld (loadbank),a 
				Dw $91ed,$0056
				Dw $91ed,$0157
		end asm
		
end sub 

Function ReserveBank() as ubyte 
	' This routine requests a free memory bank from NextZXOS APU
	' If NextZXOS is not running it will send back 223
	asm 
reservebank:
					ld hl,$0001  	; H=banktype (ZX=0, 1=MMC); L=reason (1=allocate)
					exx
					ld c,7 			; RAM 7 required for most IDEDOS calls
					ld de,$01bd 	; IDE_BANK
					rst $8:defb $94 ; M_P3DOS
					jp nc,failed
					ld a,e 
					jr notfailed
bank:
					db 223
failed:				; added this for when working in CSpect in
					ld a,255

notfailed:					
	end asm 				
end function				
				

sub FreeBank(bank as ubyte)
	' marks a memory bank as freed that was reserved with ReserveBank()
	asm 		
freebank:	
					ld hl,$0003  	; H=banktype (ZX=0, 1=MMC); L=reason (3=release)
					ld e,a
					exx
					ld c,7 			; RAM 7 required for most IDEDOS calls
					ld de,$01bd 	; IDE_BANK
					rst $8:defb $94 ; M_P3DOS
					jr notfailed
	end asm 
end sub  

Sub LoadSDBank(byval filen as String,ByVal address as uinteger,ByVal length as uinteger,ByVal offset as ulong, bank as ubyte)
	'filen = "myfile.bin"
	'address = address to load to must be $0  
	'length to load, set to 0 to autodetect 
	'offset into file 
	'bank
	'; current slots 2 is stored 
	'; bank is paged into slot 2
	'; will continue to loop and increase bank every 8kb 
	'; uses string in ram passed so doesnt need to copy the fname 
	#ifndef NEX
		asm 		;en00k 2020 / David Saphier	
		PROC
		LOCAL initdrive, filehandle, error, mloop, fileseek
		LOCAL loadsdout, loadsdout, filesize, printrst, failed, slot6
		LOCAL fixstring, offset
		ld d,(IX+5) : ld e,(IX+4) : ex de,hl		; this gets the string sent
		ld a,(hl) : ld b,a : add hl,2 
		ld (nameaddress),hl 
		
		push hl 									; start of dtring in memory 
		add hl,a : ld a,(hl) : ld (hl),0 			; ensures end is zero 
		ld (fixstring+1),hl : ld (fixstring+4),a 
		pop hl 
		
		push ix									; filename in hl / ix 
		push hl
		ld (endofloadsdbank+1),sp 				; move stack to temp
		ld sp,endfilename-2						; because we're paging $4000-$5fff
		
		; get current regs from $52
		ld a,$52 								; mmu slot 6 
		ld bc,$243B								; Register Select 
		out(c),a									; read reg 
		inc b 		
		in a,(c)		
		ld (slot6+1),a 							; store bank
		 
		; store the address, len, offset values in ram with smc 
ldadd:	ld c,(ix+6) : ld b,(ix+7) 				; address 
		ld a,b : and 127 : or $40 : ld b,a : ld (address+2),bc
		
		ld c,(ix+8) : ld b,(ix+9) 				; size 
		ld (loadsize+1),bc 						; if size is 0 then we will detect
		ld a,b : add a,c : ld (changesize+1),a 
		
		ld l,(ix+10) : ld h,(ix+11) 		
		ld (offset+1),hl							; offset DE 	

		ld l,(ix+12) : ld h,(ix+13)						
		ld (offset+4),hl 							; offset BE 

		ld l,(ix-4) : ld h,(ix-3)					; filespec 
		
		ld a,(ix+15)								; get our custom bank 
		ld (curbank),a 
		nextreg $52,a
		
		push hl : pop ix 
		ld (nameaddressfname+2),hl 
		
initdrive:
		ld a, '*' 	
		ld b, FA_READ
		; ix = filespec 
		ESXDOS : db F_OPEN
		ld (filehandle),a			; store file handle 

		; this is where we should handle an error 
		jp c,error 					; c flag had an error.  

fstat:	ld ix, fileinfobuffer
		ESXDOS : db F_STAT
		jp c,error 					; c flag had an error.  
		
changesize:
		ld a,0 : or a : call z,filesize0
		
		ld a,(filehandle) 
fileseek:
		ld ixl,0						; start  
		ld l,0						; cspect bug?
offset: 	ld de,0000					; filled in at start ldadd
		ld bc,0000
		ESXDOS : db F_SEEK			; seek 
		jp c,error 					; c flag had an error.  
		
address: 
		ld ix,0000		
loadsize:		
		ld bc,0000 				; length to load from BC in stack 
loadagain:
		ld a,(filehandle) 			; read to address 
		ESXDOS : db $9d

		jp c,error 					; c flag had an error. 
		ld (filesize),bc 			; bc read bytes 
		
		ld a,$20 : cp b : jr nz,loadsdout
		ld a,(curbank) : inc a : ld (curbank),a  : nextreg $52,a 
		jr loadagain
		
filesize0:
		ld bc,(fileinfobuffer+7)
		ld a,b
		ld (filesize),a
		ld a,c
		ld (filesize+1),a
		ld bc,$2000 
		ld (loadsize+1),bc 
		ret 
		
fileinfobuffer:
		ds 11,0			; this will contain the file info
filehandle:
		db 0 
curbank:
		db 0 
end asm 
filesize2:
asm 
filesize:
		dw 00,00,$FF
nameaddress: 
		dw 0000 
	error:
		nextreg $69,0					; turn off layer 2 
		ld a,(slot6+1) : nextreg $52,a 	; bring back slot 2 
		ld b,60
		ld ix,failed : call printrst
nameaddressfname:		
		ld ix,__LABEL__filename : call printrst
	mloop:
		ld a,0 : out (254),a : ld a,2 : out (254),a  : djnz mloop : jp mloop
printrst:
		ld a,(ix+0) : or a : ret z : rst 16 : inc ix : jp printrst
failed: 
		db 16,2,17,6
		db "Failed to open : ",13,0	 	
		
loadsdout:
		ld a,(filehandle)
		ESXDOS : db F_CLOSE		; done, close file 
	
slot6:	ld a,0 : nextreg $52,a
fixstring:
		ld hl,0000				; smc from above 
		ld (hl),0	
endofloadsdbank:
		ld sp,0000
		pop hl
		pop ix 					; restore stack n stuff
		ENDP
	end asm 
	#ENDIF
end sub 

Sub LoadSD(byval filen as String,ByVal address as uinteger,ByVal length as uinteger,ByVal offset as ulong)

		asm 			
		PROC
		LOCAL fnloop
		 ld h,(IX+5) : ld l,(IX+4)
		 ld de,__LABEL__filename
		 ld a,(hl) : ld b,a : add hl,2 
 fnloop:		
		 ldi 
		 djnz fnloop
		 ldi
		 xor a 
		 ld (de),a
		 ENDP
	 end asm 
	asm 
		PROC
		LOCAL initdrive
		LOCAL filehandle
		LOCAL error
		LOCAL fileopen
		LOCAL mloop
		LOCAL divfix
		LOCAL fileseek
		LOCAL fileread
		LOCAL loadsdout

		push ix	
		push hl
		ld e,(ix+6)				; address 
		ld d,(ix+7)
		ld c,(ix+8)				; size 
		ld b,(ix+9)
		ld l,(ix+10)
		ld h,(ix+11)			; offset 
		push bc 				; store size 
		push de 				; srote address 
		push hl 				; offset 32bit 1111xxxx
		ld l,(ix+12)
		ld h,(ix+13)			; offset xxxx1111
		push hl 				; offset 		
		
	initdrive:
		xor a		
		rst $08
		db $89					; M_GETSETDRV equ $89
		ld (filehandle),a

		ld ix,.__LABEL__filename 
		call fileopen
		ld a,(filehandle) 
		or a
		; bug in divmmc requries us to read a byte first 
		; at thie point stack = offset 
		; stack +2 = address 
		; stack +4 = length to load 
		
		
divfix:	
		ld bc,1
		ld ix,0					
		rst $08					; read a byte 
		db $9d					; read bytes 
	
		ld a,(filehandle) 

fileseek:
	
		ld l,0					; start  
		;ld bc,0					; highword
		pop bc 
		pop de					; offset into de 

		rst $08				
		db $9f					; seek 
		pop ix 					; address to load from DE in stack 
		pop bc 					; length to load from BC in stack 
		call fileread
		jp loadsdout
		
	fileread:

		;push ix					; save ix 
		;pop hl					; pop into hl

		;rst $08	
		db 62					; read 
		
	filehandle:
		db 0 						
		;or a 						
		;jp z,error
		jp c,error 
		rst $08
		db $9d					; read bytes 
		; bc read bytes 
		ld (filesize),bc 
		ret 
		
		jp loadsdout
end asm 
filesize:
asm 
filesize:
		dw 0000

	error:
		nextreg $69,0
		ld b,60
		ld ix,failed
		call printrst
		ld ix,__LABEL__filename
		call printrst
	mloop:
		ld a,0
		out (254),a
		ld a,2
		out (254),a 
		;halt 
		djnz mloop
		jp mloop
printrst:
		ld a,(ix+0) : or a : ret z : rst 16 : inc ix : jp printrst
failed: 
		db 16,2,17,6
		db "Failed to open : ",13,0	 	
		
	fileopen:		
		
		ld b,$01				; mode 1 read 
		;db 33						; open 
		;ld	b,$0c
		push ix
		pop hl
	;	ld a,42
		rst $08
		db $9a
		ld (filehandle),a
		ret
	
	loadsdout:
		
		ld a,(filehandle)
		or a
		rst $08
		db $9b				; done, close file 
	loadsdout2:	
		pop hl
		pop ix 				; restore stack n stuff
		ENDP
	end asm 

end sub 

Sub SaveSD(byval filen as String,ByVal address as uinteger,ByVal length as uinteger)
	
	' 
	' saves to SD filen=filename address=start address to save lenght=number of bytes to save  
	'
	
	filen = filen + chr(0)
	tlen=len(filen)+1
	'dim cco as ubyte=0
	for nbx=0 to tlen
		'if code(filen(cco))>32
		poke @filename+nbx,code (filen(nbx))
		'cco=cco+1
		'endif 
	next 
	poke @filename+nbx+1,0

	asm 
		PROC
		LOCAL initdrive
		LOCAL filehandle
		LOCAL error
		LOCAL fileopen
		LOCAL mloop
		push ix						; both needed for returning nicely 
		push hl
		ld e,(ix+6)					; address in to de 
		ld d,(ix+7)
		ld c,(ix+8)					; size in to bc 
		ld b,(ix+9)
		;ld l,(ix+10)				; for offset but not used here
		;ld h,(ix+11)				; offset 
		push bc 					; store size 
		push de 					; srote address 
	;	push hl 					; offset 
		
	initdrive:
		xor a		
		rst $08
		db $89						; M_GETSETDRV = $89
		ld (filehandle),a			; store filehandle from a to filehandle buffer 

		ld ix,.__LABEL__filename 	; load ix with filename buffer address 
		call fileopen				; open 
		ld a,(filehandle) 			; make sure a had filehandel again 
		;or a
		
		; not needed here but may add back in to save on an offset ....
		; bug in divmmc requries us to read a byte first 
		; at thie point stack = offset 
		; stack +2 = address 
		; stack +4 = length to SAVE 
		
		;divfix:	
		;	ld bc,1
		;	ld ix,0					
		;	rst $08					; read a byte 
		;	db $9d					; read bytes 

		;ld a,(filehandle) 
		
	;fileseek:
	
		;ld l,0						; start  
		;ld bc,0					; highword
		
		;pop de						; offset into de 

		;rst $08				
		;db $9f						; seek 
		pop ix 						; address to Save from DE in stack 
		pop bc 						; length to SAVE from BC in stack 
		call filewrite
		jp savesdout
		
	filewrite:

		db 62						; read 
		
	filehandle:
		db 0 						
		or a 						
		jp z,error
		rst $08
		db $9e						; write bytes 
		ret 
		
		jp savesdout

	error:
		ld b,5
	mloop:
		ld a,2
		out (254),a
		ld a,7
		out (254),a
		djnz mloop
		jp savesdout

	fileopen:		
		
		ld b,$e					; mode write added via issue 
		;db 33						; open 
		;ld	b,$0c
		push ix
		pop hl
	;	ld a,42
		rst $08
		db $9a						; F_OPEN 
		ld (filehandle),a
		ret
	
	savesdout:
		
		ld a,(filehandle)
		or a
		rst $08
		db $9b					; done, close file 
		
		pop hl
		pop ix 					; restore stack n stuff
	ENDP 
	
	end asm 

end sub 

SUB DoTileBank16(byVal X as ubyte, byval Y as ubyte, byval T as ubyte, byval B as ubyte)
	' X 0 -15 Y 0 -11 T tile 0 - 255 B = bank tiles are loaded in  
	ASM 
		;PUSH IX 
		; Grab xyt		
	    ;BREAK 
		di 
		ld a,$52 : ld bc,$243B : out(c),a : inc b : in a,(c)	
		ld (tbanks+3),a 
;		ld (outstack+1),sp 							; save stack 
; 		ld sp,nbtempstackstart-2						; set stack to nb temp stack 
		
		ld h,(IX+11) 			; bank 
		ld a,(IX+9)				; tile 
		; 0010 0000
		swapnib 
		; 0000 0010
		rrca : and %111 
		add a,h 

		nextreg $52,a 
		ld a,(IX+9)		; tile 
		;and 63
		ld b,(IX+7)		; y 
		ld c,(IX+5)		; x 
    ; tile data @ $e000
		;----------------
		; Original code by Michael Ware adjusted to work with ZXB
		; Plot tile to layer 2
		; in - bc = y/x tile coordinate (0-11, 0-15)
		; in - a = number of tile to display
		;---------------- 
	PlotTile16:
		ex af,af'
		ld a,b   		; put y into a 
		SWAPNIB			; * 16 
		ld d,a			; put new y into d 
		ld a,c			; get x into a 
		SWAPNIB			; * 16
		ld e,a			; now put new x into e 
		ld a,d			; bring bank d 
		and 192			; we start at $4000
		or 3				; 
		ld bc,LAYER2_ACCESS_PORT
		out (c),a 				; select bank
		ex af, af'
		and 31 					
		or $40 					; tiles start from $4000
		
		ld h,a 
		ld l,0					; put tile number * 256 into hl.
		ld a,d 
		and 63 
		ld d,a
		ld a,16
		ld b,0
	plotTilesLoop:
		ld c, 16					; t 7
		push de
		ldir
		;DB $ED,$B4
		pop de					
		inc d
		dec a
		jr nz,plotTilesLoop
tbanks:		
		nextreg $52,0
;outstack:
		;ld sp,00 
		ei 
		;ret
		;POP IX 
	END ASM 
end sub

SUB DoTile8(byVal X as ubyte, byval Y as ubyte, byval T as ubyte)

	ASM 
		;BREAK 
		PUSH de 
		push hl
		; Grab xyt
		ld l,(IX+5)
		
		ld h,(IX+7)

		ld a,(IX+9)

		;----------------
		; Original code by Michael Ware adjustd to work with ZXB
		; Plot tile to layer 2 (needs to accept > 256 tiles)
		; in - hl = y/x tile coordinate (0-17, 0-31)
		; in - a = number of tile to display
		;----------------
PlotTile8:
		ld d,64
		ld e,a					; 11
		MUL_DE					; ?

		ld a,%11000000
		or d		 				; 8
		ex de,hl					; 4			; cannot avoid an ex (de now = yx)
		ld h,a					; 4
		ld a,e
		rlca
		rlca
		rlca
		ld e,a					; 4+4+4+4+4 = 20	; mul x,8
		ld a,d
		rlca
		rlca
		rlca
		ld d,a					; 4+4+4+4+4 = 20	; mul y,8
		and 192
		or 3						; or 3 to keep layer on				; 8
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      			; 21			; select bank

		ld a,d
		and 63
		ld d,a					; clear top bits of y (dest) (4+4+4 = 12)
		; T96 here
		ld a,8					; 7
plotTilesLoop2:
		push de					; 11
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi		; 8 * 16 = 128
		
		pop de					; 11
		inc d					; 4 add 256 for next line down
		dec a					; 4
		jr nz,plotTilesLoop2			; 12/7
		;ret  
		ld a,2
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      ; 21			; select bank
	END ASM 
end sub

sub fastcall FDoTile16(tile as ubyte, x as ubyte ,y as ubyte, bank as ubyte)
	' y 0  to 15
	' x 0  to 19
	' 
	' draws tile on layer 2 320x240, fast call so optimized 
	asm 
	; draw 16x16 tile on Layer2 @ 320x256
	; bank is start bank, bank will automatically increase depending on tile number 
	; stack is moved due to $4000 - $5FFF being used. All input values are pushed to the 
	; stack on entry, so we must pop them off, YY00 0X00 Ti00 bk00	
	; en00k 2020 / David Saphier
	PROC 
	LOCAL notbank67,bigtiles, tbanks, smctilnum, outstack, l2320on, l2on
		di 
		exx 						;4 					; swap regs 
		pop hl 					;10					; save ret address
		exx						;4					; back to data  

		pop de 					;10 					; get d<-y off stack yy00
		pop hl					;10					; get h<-x off stack xx00 
		ld l,d					;4 					; now make hl x/y 
		
		; we can use de here 
		pop de 										; start bank in de 
;		ld (outstack+1),sp 							; save stack 
;		ld sp,nbtempstackstart-2						; set stack to nb temp stack 
		ld (smctilnum+1),a							; store tile for below 
		swapnib										; tile / 32 
		rrca											; rotate right 
		and %0111										; and with %111
		add a,d 										; add to start bank 
		ld d,a   									; save a into d
		
		ld a,$52 : ld bc,$243B : out(c),a : inc b : in a,(c)	

		ld (tbanks+3),a 								; store current slot 2 bank
		ld a,d										; get bank to page in from d 
		nextreg $52,a 
		ld bc,LAYER2_ACCESS_PORT
		
smctilnum:		
		ld a,0 					;7					; set from above 
		and 31					; 
		ld d,a					; get offset into tiles from 0000 
		ld e,0

		ld a,%01000000			;7 					; this is $4000
		or d 					;4					; 

		; de tile offset / hl = y/x 
		ex de,hl 				;4					; swap de / hl  
													; and get x/y
		ld h,a 					;4					; now put $cx00 with a into h 
													; hl is source 
		push hl 					;11
		; de y/x 			
		; y first 
		ld a,d 					;4					;  y * 16
		rlca 					;4
		rlca 					;4
		rlca 					;4
		rlca 					;4 
		ld d,a 					;4					; save back in d 
	
		; x 
		ld l,e					;4					; treat x as word 
		ld h,0 					;7					; to catch bit 0 
		add hl, hl				;11					; of h 
		add hl, hl				;11
		add hl, hl				;11					; 
		add hl, hl				;11					; if h bit 0 then banks 6-7
		push hl 					;11					; store hl for the mo 
		bit 0,h : jr z,notbank67  ;7 + 12/22
		ld h,4 					;7					; bit 3 for bank mask 
notbank67:
		ld a,l 					;4					; now get msb of xx 
		swapnib 					;8					; swap the nibbles 
		rrca						;4					; right 2 times 
		rrca						;4
		and 3					;7					; now bits 7/8 in position 1/0
		or h 					;4					; was hl>65535, then or bit 2
		; bank bitmask 
		ld h,a 					;4					; save in h, h has the banks 
	
l2on:
		ld a,%00000011			;7					; l2 enable, writes enable 
		out (c),a 				;12					; out to port 
		ld a,h					;4					; get back bit 4 mode banks from h 
		add a,%00010000			;7					; set bit 4 
l2320on:	
		out (c),a 				;12					; out to port 
		pop hl 					;10					; get hl of stack 
		
		ld a,l 					;4					; store l in a 
		ld l,d					;4					; d/y into l 
		and 63					;7					; and 63 to a 
		ld h,a 					;4					; put in h/x 
	
		ex de,hl 				;4
		pop hl 					;11					; source address 

		ld a,16 					;7
		; uses ldws which is 
		; ld a,(hl)
		; ld (de),a 
		; inc hl : inc d 
		;
		; 314 T so far 
bigtiles:
		push de 					;11
		ldws 					;14
		ldws						;14 
		ldws						;14
		ldws						;14
		ldws						;14
		ldws						;14
		ldws 					;14
		ldws 					;14 
		ldws 					;14
		ldws						;14 
		ldws						;14
		ldws						;14
		ldws						;14
		ldws						;14
		ldws 					;14
		ldws 					;14 
		
		pop de					;10
		inc de					;6
		dec a					;4
		jr nz,bigtiles			;12/22
		; 142 T *2
tbanks:		
		nextreg $52,0	
outstack:
;		ld sp,0 
		exx 						;4
		push hl 					;11
		exx 						;4 
		ei 						;
		
	ENDP 
	end asm 

end sub 

	
sub fastcall FDoTile8(tile as ubyte, x as ubyte ,y as ubyte, bank as ubyte)
	' y 0  to 31
	' x 0  to 39
	' bank as start bank 
	' now we dont care about x being a word haha 
	' draws tile on layer 2 320x240. tile data at $c000 
	asm 
	; a = y 
	; on entry stack YY00 0Xxx cc00	
	; en00k 2020 / David Saphier
	PROC 
	LOCAL notbank67,drawtiles, smctilnum, outstack,tbanks
		di 
		exx 						;4 					; swap regs 
		pop hl 					;10					; save ret address
		exx						;4					; back to data  
		

		pop de 					;10 					; get d<-y off stack yy00
		pop hl					;10					; get h<-x off stack xx00 
		ld l,d					;4 					; now make hl x/y 
		
		; we can use de here 
		; move stack and set up banks 
		pop de 										; start bank in de  
;		ld (outstack+1),sp 							; save stack 
;		ld sp,nbtempstackstart-2						; set stack to nb temp stack 
		ld (smctilnum+1),a							; store tile for below 
		swapnib										; tile / 32 
	 	rrca											; rotate right 
		rrca											; rotate right 
		rrca											; rotate right 
		and %1										; and with %1
		add a,d 										; add to start bank 
		ld d,a   									; save a into d
		
		ld a,$52 : ld bc,$243B : out(c),a : inc b : in a,(c)	
		
		ld (tbanks+3),a 								; store current slot 2 bank
		ld a,d										; get bank to page in from d 
		nextreg $52,a 

smctilnum: 
		ld a,0 
		and $7f										; this is so we wrap around out 8kb bank 
		ld d,64					;7					; each 8x8 tile is 64 bytes 
		ld e,a 					;4					; tile x bytes 
		mul d,e 					;8					; get offset into tiles from 0000 
							
		ld a,%01000000			;7					; add $4000 to the offset 
		or d 					;4					; 
													; a = lsb in an offset from $c0xx

		; de tile offset / hl = y/x 
		ex de,hl 				;4					; swap de / hl  
													; and get x/y
		ld h,a 					;4					; now put $cx00 with a into h 
													; hl is source 
		push hl 					;11
		; de y/x 			
		; y first 
		ld a,d 					;4					;  y * 8
		rlca 					;4
		rlca 					;4
		rlca 					;4 
		ld d,a 					;4					; save back in d 
	
		; x 
		ld l,e					;4					; treat x as word 
		ld h,0 					;7					; to catch bit 0 
		add hl, hl				;11					; of h 
		add hl, hl				;11
		add hl, hl				;11					; if h bit 0 then banks 6-7
		push hl 					;11					; store hl for the mo 
		bit 0,h : jr z,notbank67  ;7 + 12/22
		ld h,4 					;7					; bit 3 for bank mask 
		
notbank67:
		ld a,l 					;4					; now get msb of xx 
		swapnib 					;8					; swap the nibbles 
		rrca						;4					; right 2 times 
		rrca						;4
		and 3					;7					; now bits 7/8 in position 1/0
		or h 					;4					; was de>65535, then or bit 2
		; bank bitmask 
		ld h,a 					;4					; save in h, h has the banks 
		ld bc,LAYER2_ACCESS_PORT	;7 					;
l2on:
		ld a,%00000011			;7					; l2 enable, writes enable 
		out (c),a 				;12					; out to port 
		ld a,h					;4					; get back bit 4 mode banks from h 
		add a,%00010000			;7					; set bit 4 
l2320on:	
		out (c),a 				;12					; out to port 
		pop hl 					;10					; get hl of stack 
		
		ld a,l 					;4					; store l in a 
		ld l,d					;4					; d/y into l 
		and 63					;7					; and 63 to a 
		ld h,a 					;4					; put in h/x 
	
		ex de,hl 				;4
		pop hl 					;11					; source address 

		ld a,8 					;7
		; uses ldws which is 
		; ld a,(hl)
		; ld (de),a 
		; inc hl : inc d 
		;
		; 314 T so far 
drawtiles:
		push de 					;11
		ldws 					;14
		ldws						;14 
		ldws						;14
		ldws						;14
		ldws						;14
		ldws						;14
		ldws 					;14
		ldws 					;14 
		pop de					;10
		inc de					;6
		dec a					;4
		jr nz,drawtiles			;12/22
		; 142 T
tbanks:		
		nextreg $52,0	
outstack:
;		ld sp,0 
		exx 						;4
		push hl 					;11
		exx 						;4 
		ei 						;
		
	ENDP 
	end asm 

end sub 



Sub L2Text(byval x as ubyte,byval y as ubyte ,byval m$ as string, fntbnk as ubyte)
	
	asm 
		PROC
		;BREAK 
		LOCAL plotTilesLoop2, printloop, inloop, addspace, addspace2 
		; x and y is char blocks, fntbnk is a bank which contains 8x8L2 font 
		; need to get m$ address, x , y and maybe fnt bank?
		; pages into $4000 and back to $0a when done
		di 
;		ld (endofl2text+1),sp 
;		ld sp,endfilename-2
		ld a,$52
		ld bc,$243B			; Register Select 
		out(c),a				; 
		inc b 
		in a,(c)
		ld (textfontdone+1),a 

		ld e,(IX+5) : ld d,(IX+7)	
		ld l,(IX+8) : ld h,(IX+9)
		ld a,(hl) : ld b,a 
		inc hl : inc hl 
		ld a,(IX+11) : nextreg $52,a 
	 
printloop:
		push bc 
		ld a,(hl)
		cp 32 : jp z,addspace
		cp 33 : jp z,addspace2
		sub 34 	
inloop:	
		push hl : push de 
		ex de,hl 
		call PlotTextTile
		pop de : pop hl 
		inc hl  
		inc e   
		pop bc
		djnz printloop
		jp textfontdone
addspace:
		ld a,57
		jp inloop 
addspace2:
		ld a,0
		jp inloop 

PlotTextTile:
		ld d,64 : ld e,a			
		MUL_DE					
		ld a,%01000000 : or d		; $4000
		ex de,hl	 : ld h,a : ld a,e
		rlca : rlca : rlca
		ld e,a : ld a,d
		rlca : rlca : rlca
		ld d,a : and 192 : or 3
		ld bc,LAYER2_ACCESS_PORT
		out (c),a : ld a,d : and 63
		ld d,a : ld bc,$800 
		push de 
		ld a,0
plotTilesLoop2:
		
		push bc
		ld bc,8
		push de 
		; : ldi : ldi : ldi : ldi : ldi : ldi : ldi : ldi : pop de				
		ldirx
		pop de 
		inc d 
		pop bc 
		
		djnz plotTilesLoop2
		pop de 
		ret 
textfontdone:
		ld a,$0a : nextreg $52,a 
endofl2text:
;		ld sp,0000
		ei 
	ENDP 

	end asm 
	
end sub 


Sub FL2Text(byval x as ubyte,byval y as ubyte ,byval m$ as string, fntbnk as ubyte)
	
	asm 
	PROC
	LOCAL plotTilesLoop2, printloop, inloop, addspace, addspace2,outstack,slot2out
	; x and y is char blocks, fntbnk is a bank which contains 8x8L2 font 
	; need to get m$ address, x , y and maybe fnt bank?
	; pages into $4000 and back to $0a when done 
		di  
;		ld (outstack+1),sp 							; save stack 
;		ld sp,nbtempstackstart-2						; set stack to nb temp stack 
		getreg($52) : ld (slot2out+3),a 
		ld d,(IX+7) : ld e,(IX+5)	
		ld a,(hl) : ld b,a 
		inc hl : inc hl  
		ld a,(IX+11) : nextreg $52,a 
	 
printloop:
		push bc 
		ld a,(hl)
		cp 32 : jp z,addspace
		cp 33 : jp z,addspace2
		sub 34 	
inloop:	
		; hl string de yx 
		ex de,hl
		; de string hl yx 
		push hl : push de 
		; hl = y/x de string adderess 
		call PlotTextTile
		pop hl : pop de
		inc hl	; string address 
		inc e   ; inc x 
		pop bc
		djnz printloop
		jp textfontdone
	
addspace:
		ld a,57
		jp inloop 
addspace2:
		ld a,0
		jp inloop 

PlotTextTile:
		ld d,64 : ld e,a				 ; d = 64 : a = tile 
		MUL_DE						; 64 * A = TILE DATA OFFSET 
		ld a,%01000000 : or d			; make sure its in $4000 range
		
		
		ex de,hl	 : ld h,a 											; hl is source 
		push hl 					;11
		; de y/x 			
		; y first 
		ld a,d 					;4					;  y * 8
		rlca 					;4
		rlca 					;4
		rlca 					;4 
		ld d,a 					;4					; save back in d 
	
		; x 
		ld l,e					;4					; treat x as word 
		ld h,0 					;7					; to catch bit 0 
		add hl, hl				;11					; of h 
		add hl, hl				;11
		add hl, hl				;11					; if h bit 0 then banks 6-7
		push hl 					;11					; store hl for the mo 
		bit 0,h : jr z,notbank67  ;7 + 12/22
		ld h,4 					;7					; bit 3 for bank mask 
		
notbank67:
		ld a,l 					;4					; now get msb of xx 
		swapnib 					;8					; swap the nibbles 
		rrca						;4					; right 2 times 
		rrca						;4
		and 3					;7					; now bits 7/8 in position 1/0
		or h 					;4					; was de>65535, then or bit 2
		; bank bitmask 
		ld h,a 					;4					; save in h, h has the banks 
		ld bc,LAYER2_ACCESS_PORT	;7 					;
l2on:
		ld a,%00000011			;7					; l2 enable, writes enable 
		out (c),a 				;12					; out to port 
		ld a,h					;4					; get back bit 4 mode banks from h 
		add a,%00010000			;7					; set bit 4 
l2320on:	
		out (c),a 				;12					; out to port 
		pop hl 					;10					; get hl of stack 
		
		ld a,l 					;4					; store l in a 
		ld l,d					;4					; d/y into l 
		and 63					;7					; and 63 to a 
		ld h,a 					;4					; put in h/x 
	
		ex de,hl 				;4
		pop hl 					;11					; source address 

		ld a,8 					;7
plotTilesLoop2:
		push de 
		push af 
		ldws 

		ldws
		
		ldws 
		
		ldws 
		
		ldws 
		
		ldws 
		
		ldws 
		
		ldws
		
		pop af 
		pop de				
		inc de
		dec a
		jr nz,plotTilesLoop2
		ret 
textfontdone:
		;ld a,$0a : nextreg $52,a 
		;ld bc,LAYER2_ACCESS_PORT		
		;ld a, 1
		;out (c),a :	
slot2out:
		nextreg $52,0
outstack:
;		ld sp,00
		ei 
	ENDP 
 
	end asm 
	
end sub 


sub fastcall FPlotL2(y as ubyte ,x as uinteger ,c as ubyte)
	
	asm 
	; a = y 
	; on entry stack YY00 0Xxx cc00	
	;en00k 2020 / David Saphier	
	di 
	exx 						;4 					; swap regs 
	pop hl 					;10					; save ret address
	exx						;4					; back to data  
	ld bc,LAYER2_ACCESS_PORT	;7 					; check if bit 0 of h is set if so >255
	
	push af 					;11					; save y to stack 
	ex de,hl 				;4 					; de = xx hl = 00 
	
	bit 0, d 				; 7 				; is bit 0 of de set ?
	jr z,nobanks6and7		; 12/7				; no de value <256 so banks 0 - 5
	ld d,4				 	; 7 				; de >255 high bank %100 so banks 6-7
						
nobanks6and7: 					
	ld a,e 					;4					; now get msb of xx from e into a 
	swapnib 					;8					; swap the nibbles 0000xxxx
	srl a					;8					; right 2 times 
	srl a					;8
	and 3					;7					; first two bits 
	or d 					;4					; or with highbank d 
	ld e,a 					;4					; save in e 
					
	ld a,%00000011			;7					; intial write to l2 port 
	out (c),a 				;12					; enable writes and showlayer 
						
	ld a,e					;4					; retrieve e containing banks 
						
	add a,%00010000			;7					; bit 4 extended L2 writes enable 
	out (c),a 				;12					; out to port 
						
	pop af 					;10					; get back y 
	pop hl 					;10 					; get back hl for l 
	ld h,l 					;4					; put l into h 
	ld l,a					;4					; now put y into l 
	ld a,h 					;4					; x into a 
	and 63					;7					; columns wrap at 64 bytes
	ld h,a  					;4 					; put back into h, hl now complete 

	pop af					;10					; get the colour specified 
	ld (hl),a 				;7					; make the write 
	
	exx 						;4
	push hl 					;11
	exx 						;4 
	ei 						; 196 Ts per pixel 
	end asm 

end sub


SUB PalUpload(ByVal address as uinteger, byval colours as ubyte,byval offset as ubyte)
	' sends palette to registers address @label, num of cols 0 = 256, offset default 0
	asm 
		;BREAK 
		ld l,(IX+4)
		ld h,(IX+5)
		ld b,(IX+7)
		ld e,(IX+9)
		ld a,e
		
	loadpal:
		
		;ld b,0							; this will make 256 loops 0, then b is dec'd and starts again from 255
		;ld a,2
		DW $92ED						; NextReg $40,0
		DB $40
		;xor a							; clear A
		;ld hl,palette					; start of palette data
		ld c,0
	palloop:
		ld a,(hl)						; load first value, send to NextReg
		
		DW $92ED						; NextRegA $44 with A
		DB $44
		inc hl							; next byte 
		ld a,(hl)						; read into a 
		;ld a,1
		DW $92ED						; NextRegA so send A to reg $44
		DB $44
		inc hl 							; incy dinky doo hl
		 
		djnz palloop					; did b do 256 loops? no? then loop to palloop
		ld a,128
		DW $92ED
		DB 40
		xor a 
		DW $92ED						; NextRegA so send A to reg $44
		DB $44
		DW $92ED						; NextRegA so send A to reg $44
		DB $44
		pop de
		pop hl 
	end asm 		
end sub 
 
Sub CLS256(byval colour as ubyte)

	' Original code Mike Dailly
	' and adjusted to work with ZXB
	
	ASM 
		

	Cls256:
		push	bc
		push	de
		push	hl
		
		ld bc,$123b				; L2 port 
		in a,(c)				; read value 
		push af 				; store it 
		xor a 
		out	(c),a 

		
		ld a,(IX+5)				; get colour 
		
		ld	d,a					; byte to clear to
		ld	e,3					; number of blocks
		ld	a,1					; first bank... (bank 0 with write enable bit set)

		ld      bc, $123b                
	LoadAll:	
		out	(c),a				; bank in first bank
		push	af       
                ; Fill lower 16K with the desired byte
		ld	hl,0
	ClearLoop:		
		ld	(hl),d
		inc	l
		jr	nz,ClearLoop
		inc	h
		ld	a,h
		cp	$40
		jr	nz,ClearLoop

		pop	af					; get block back
		add	a,$40
		dec	e					; loops 3 times
		jr	nz,LoadAll

		ld  bc, $123b			; switch off background (should probably do an IN to get the original value)
		ld	a,0
		pop af 
		out	(c),a     

		pop	hl
		pop	de
		pop	bc

	end asm 
end sub 

Sub ClipLayer2( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

	'; clips the layer2 defaults are : x1=0,x2=255,y1=0,y1=191
	'; $92ED = NextReg A, Clipping Register is 24
	
	asm 
		ld a,(IX+5)    
		DW $92ED : DB 24 			
		ld a,(IX+7)	  
		DW $92ED : DB 24
		ld a,(IX+9)		 
		DW $92ED : DB 24 
		ld a,(IX+11)	
		DW $92ED : DB 24		  
	end asm 
end sub 

Sub ClipULA( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

	'; clips the ULA defaults are : x1=0,x2=255,y1=0,y1=191
	'; $92ED = NextReg A, ULA Clipping Register is 26
	asm 
		ld a,(IX+5)    
		DW $92ED : DB 26 			
		ld a,(IX+7)	  
		DW $92ED : DB 26
		ld a,(IX+9)		 
		DW $92ED : DB 26 
		ld a,(IX+11)	
		DW $92ED : DB 26		  
	end asm 
end sub

Sub ClipTile( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

	'; clips the ULA defaults are : x1=0,x2=255,y1=0,y1=191
	'; $92ED = NextReg A, ULA Clipping Register is 26
	asm 
		ld a,(IX+5)    
		DW $92ED : DB 27 			
		ld a,(IX+7)	  
		DW $92ED : DB 27
		ld a,(IX+9)		 
		DW $92ED : DB 27 
		ld a,(IX+11)	
		DW $92ED : DB 27		  
	end asm 
end sub

Sub ClipSprite( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

	'; clips the ULA defaults are : x1=0,x2=255,y1=0,y1=191
	'; $92ED = NextReg A, ULA Clipping Register is 26
	asm 
		ld a,(IX+5)    
		DW $92ED : DB $19			
		ld a,(IX+7)	  
		DW $92ED : DB $19
		ld a,(IX+9)		 
		DW $92ED : DB $19
		ld a,(IX+11)	
		DW $92ED : DB $19		  
	end asm 
end sub

sub TileMap(byval address as uinteger, byval blkoff as ubyte, byval numberoftiles as uinteger,byval x as ubyte,byval y as ubyte, byval width as ubyte, byval mapwidth as uinteger)
		' this point to a memory location containing a map width is viewable screen 
		' mapwidth is the length of the whole map eg fro scrolling 
		' this is a L2 command and not L3 TileMap HW 
		
		asm 
		
		ld bc,$123b				; L2 port 
		in a,(c)				; read value 
		push af 				; store it
		;xor a 
		;out (c),a
		
		ld a,(IX+7)
		ld (offset),a
		;ld a,(IX+15)				; width 
		;ld (width_tm),a

		; do tile map @ address 
		;BREAK
		;;ld l,(IX+4)					; put address into hl 
		;;ld h,(IX+5)

		
		; inner x loop 

		ld c,(IX+8)					; 	loop number of loops from numberoftiles
		ld b,(IX+9)					; 
		
		ld d,(IX+11)					; 	x
		ld e,(IX+13)					;   y
		
		;ld de,0						; x 
		;ld e,0						; y 
		ld a,(IX+15)				; if x>0 we need to add it to our width value 
		add a,d 					; 
		ld (IX+15),a 				; store back in IX+15
		
	forx:	
	;BREAK 
		push bc 					; save loop counter 
		push de 					; save de (xy)
		push hl 					; save the address (hl)
		
		ld b,(hl)					; get tile number from map address 
		ld a,(offset)
		add a,b
		;ld a,b
		;ld a,(hl)
		ld l,d						; put x into c
		ld h,e						; put y into b 

		call PlotTile82				; draw the tile 

		pop hl 						; bring back til map address 
		
		;ld de,32
		ld e,(IX+16)					; 	x
		ld d,(IX+17)					;   y
		
		add hl,de 
		
		pop de 						; bring back de (xy)
		inc d						; increase x so , d+1
								; increase x so , d+1
		ld a,d 						; a=d 
		;cp 32						; compare to 31?
		
		cp (IX+15)
		call z,resetx				; if d=32 then resetx 
		
		pop bc 
		dec bc 
		ld a,b
		or c 
		jp nz,forx 
		
		jp tileend					; we're done jump to end 
	
	resetx:
		inc e						; lets to y first, so y+1
		ld a,e						; a=e  a=y
		cp 24						; if a=24  y=24?
		jp z,timetoexit				; jp tileened			; yes we reached the bottom line so exit 
		;ld d,0						; else let x=0
		ld d,(IX+11)				; else let x = startx 
		ret 						; jump back to forx loop 

	timetoexit:
		pop bc						; dump bc off stack 						
		jp tileend					; we're done jump to end  

	PlotTile82:
		ld d,64
		
		ld e,a						; 11
		MUL_DE						; ?
		;BREAK 
		;ld a,%11000000
		ld a,%00000000
		or d		 				; 8
		ex de,hl					; 4			; cannot avoid an ex (de now = yx)
		ld h,a						; 4
		ld a,e
		rlca
		rlca
		rlca
		ld e,a						; 4+4+4+4+4 = 20	; mul x,8
		ld a,d
		rlca
		rlca
		rlca
		ld d,a						; 4+4+4+4+4 = 20	; mul y,8
		and 192
		or 1						; 8
		
		ld bc,LAYER2_ACCESS_PORT
		out (c),a      				; 21			; select bank

		ld a,d
		and 63
		ld d,a						; clear top 2 bits of y (dest) (4+4+4 = 12)
		; T96 here
		ld a,8						; 7
	plotTilesLoopA:
		push de						; 11
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi
		ldi							; 8 * 16 = 128
		
		pop de						; 11
		inc d						; 4 add 256 for next line down
		dec a						; 4
		jr nz,plotTilesLoopA		; 12/7
		ret  
	offset:
		db 0
	width_tm:
		db 31
	tileend:
		ld  bc, LAYER2_ACCESS_PORT 	; switch off background (should probably do an IN to get the original value)
		pop af 					; restore layer2 on or off 
	;	out	(c),a     
		
	end asm 
		NextReg($50,$ff)
END SUB 

SUB InitVT2(byval vt2address as uinteger,byval bank as ubyte)
	ASM 	
		;BREAK
		call getbank
		ld a,(IX+7)								; ' this is the bank we want to use 
		di 
		ld hl,23388								; paging fix 
		ld (hl),16
		
		call bank4								; ' switch banks
	
		ld hl,vt2player						; ' move the player into position
		ld l,(IX+4)								; ' move the player into position
		ld h,(IX+5)								; ' move the player into position
		ld de,PLAYERLOCATION					; ' bank x @ 49152
		;ld bc,1618								; ' length of player 
		ld bc,$6d3								; ' length of player 
		ldir	
		call bankorig 						;' back to bank 0
		ei 
	END ASM 
END SUB 

SUB InitCallback(byval musicadd as uinteger,byval length as uinteger,byval bank as ubyte, byval IMJump as uinteger)
	ASM 
		;' part of NextBuild em00k 2018
		
		push hl 									; ' save return address
		push ix 									; ' IX for good measure 

		
		ld a,(IX+9)								; ' this is the bank we want to use 
		
		call bank4								; ' switch banks

		; ld hl,vt2player						; ' move the player into position
		; ld de,PLAYERLOCATION			; ' bank x @ 49152
		; ld bc,1617								; ' length of player 
		; ldir											; ' copy bytes

 		ld l,(IX+4)
		ld h,(IX+5)								;' music address 
		;;ld de, 51310							; first music 
		ld de,$c700				; aky 
		ld bc,.__LABEL__musicend-.__LABEL__music
		ldir 
		
		ld c,(IX+6)
		ld b,(IX+7)
		
		ld hl,$c700 
		ld a,1 			; first song 
		
		call PLAYERLOCATION; +3			;' init music 
		
		call bankorig 						;' back to bank 0

		ld hl,Ints								;' point to IM routine 
		ld a,$C3									;' we need to store "jp Ints" for the ISR
		pop ix 										;' bring back IX 
		ld d,(IX+11)							;' get low byte eg AE

		ld e,d										;' make e same as d so de = AFAF
		
		ld (de),a									;' jp 
		ld a,l
		inc de 										;' next byte 
		ld (de),a									;' h *  256 + ISR/256
		ld a,h
		inc de 										;' next byte 
		ld (de),a									;' ISR/256 

		
		ld l,(IX+10)							; ' bring back low byte of ijump
		ld a,l										;' stick in a 
		ld (IJUMP),a							;' store at IJUMP
		ld h,(IX+11)							;
		ld a,h										;' same with low byte 
		ld (IJUMP+1),a
		
		ld (hl),a									;' store low byte 
		inc hl
		ld (hl),a									;' repeat low byte
		;BREAK
		ld l,(IX+10)							;' get back iJumpaddress
		ld h,(IX+11)							;
		dec hl 										;' dec 1 byte
		inc h 										;' +256
		
		ld (hl),a									;' it needs to be at the end of the vector
		inc hl 
		ld (hl),a
		pop hl 

		ei 
	END ASM 
end sub 

sub SFXCallback(byval switch as ubyte,byval bank as ubyte)

asm 
	PROC 
	LOCAL sfxoff 
		di
		push hl 
		push ix 
		ld a,(IX+5)
		cp 1
		jp nz,sfxoff

		ld a,(IX+7)
		ld (storedbank),a
		jp intend

storedbank:
		db 0,0,0

	AFXFRAME:
		;' AYFX by Shiru
		push hl 
		push ix 
		
		ld bc,$03fd
		ld ix,afxChDesc

	afxFrame0:
		push bc
		
		ld a,11
		ld h,(ix+1)					;comparing the highest byte of the address to <11
		cp h
		jr nc,afxFrame7			; the channel does not play, we skip
		ld l,(ix+0)
		
		ld e,(hl)						; take the value of the information byte
		inc hl
				
		sub b								;select the volume register:
		ld d,b							;(11-3=8, 11-2=9, 11-1=10)

		ld b,$ff						; output the volume value
		out (c),a
		ld b,$bf
		ld a,e
		and $0f
		out (c),a
		
		bit 5,e							;will the tone change?
		jr z,afxFrame1			; the tone does not change
		
		ld a,3							;select the tone registers:
		sub d								;3-3=0, 3-2=1, 3-1=2
		add a,a							;0*2=0, 1*2=2, 2*2=4
		
		ld b,$ff						; output the tone values
		out (c),a
		ld b,$bf
		ld d,(hl)
		inc hl
		out (c),d
		ld b,$ff
		inc a
		out (c),a
		ld b,$bf
		ld d,(hl)
		inc hl
		out (c),d
		
	afxFrame1:
		bit 6,e							;is there a noise change?
		jr z,afxFrame3			;noise does not change
		
		ld a,(hl)						;read the value of noise
		sub $20
		jr c,afxFrame2			; less than # 20, play next
		ld h,a							; otherwise the end of the effect
		ld b,$ff
		ld b,c							;in BC we record the longest time
		jr afxFrame6
		
	afxFrame2:
		inc hl
		ld (afxNseMix+1),a	;keep the noise value
		
	afxFrame3:
		pop bc							;restore the value of the cycle in B
		push bc
		inc b								;the number of shifts for flags TN
		
		ld a,%01101111			;mask for flags TN
	afxFrame4:
		rrc e								;shift flags and mask
		rrca
		djnz afxFrame4
		ld d,a
		
		ld bc,afxNseMix+2		;we store the values ??of the flags
		ld a,(bc)
		xor e
		and d
		xor e								;E is masked with D
		ld (bc),a
		
	afxFrame5:
		ld c,(ix+2)					;increase the time counter
		ld b,(ix+3)
		inc bc
		
	afxFrame6:
		ld (ix+2),c
		ld (ix+3),b
		
		ld (ix+0),l					;save the changed address
		ld (ix+1),h
		
	afxFrame7:
		ld bc,4							;go to the next channel
		add ix,bc
		pop bc
		djnz afxFrame0

		ld hl,$ffbf					;output the noise and mixer values
	afxNseMix:
		ld de,0							;+1(E)=noise, +2(D)=mixer
		ld a,6
		ld b,h
		out (c),a
		ld b,l
		out (c),e
		inc a
		ld b,h
		out (c),a
		ld b,l
		out (c),d
		pop ix 
		pop hl 
		ret 

	Ints:	
		;di                  							; disable interrupts
		push af             
		push bc
		push de
		push hl
		push ix             
		push iy
		ex af, af'
		push af     
		 
		call getbank
		ld a,(storedbank)
		call bank4
		ld bc,65533											; we want 2nd AY
		ld a,255
		out (c),a												;' switch it
		call $c003											;' play music on this one
		ld a,254
		ld bc,65533
		;' flip to 1sy AY 
		out (c),a
		call AFXFRAME       						;' play the current sfx
		call bankorig 

		pop af 
		ex af, af'
		pop iy
		pop ix              
		pop hl
		pop de
		pop bc
		pop af              
		ei             
;		jp 56				; uncomment for use in basic, load in 48k mode thought and with fuse  
		reti 			; comment out for normal zxb use 

getbank:
		ld hl,storedbank+1
		ld bc,$243B			; Register Select 
		ld a,$56			; a = slot already so add $50 for slot regs 
		out(c),a			; 
		ld bc,$253B			; reg access 
		in a,(c)
		ld (hl),a
		inc hl 
		ld bc,$243B			; Register Select 
		ld a,$57			; a = slot already so add $50 for slot regs 
		out(c),a			; 
		ld bc,$253B			; reg access 
		in a,(c)
		ld (hl),a 		
		ret 

tempa:
		db 0
tempb:
		db 0
	
intend:
	  ;BREAK
		ld a,(IJUMP+1)
		ld a,$AE
		ld i,a
		IM 2
		jp initintsend
		
		PLAYERLOCATION 	EQU $c000			;'
		IJUMP: 					DEFW $0000		;' this is where will have a repeated byte over over = ISR
		;'	ISR NOTEUSED '  $AFAF			;'This is the location where we put a jump to our routine
		
bank4:														; '  swap to bank 4 @ 49152 - 16k
																	; ' requries a=16kb bank 
		di													;' no need for di.ei as were calling with DI '
		
		ld d,a												; save a 
		ld a,(23388)   								;' Get current ram page @ $c000
		ld (bankst),a									;' save it for later 
		and 248												;' 
		or d													;' or d 
		ld bc,32765										;' paging port 32765
		ld (23388),a									;' store a in basics 23388
		out (c),a											;' out the new bank
		
		ret 													;' done 
		
bankorig:
		ld a,(23388)   								;' Get current ram page @ $c000
		ld a,(bankst)									;' save it for later 
		ld bc,32765										;' paging port 32765;
		ld (23388),a									;' store a in basics 23388
		out (c),a											;' out the new bank

		ld hl,storedbank+1
		ld a,(hl)
		DW $92ED : DB $56
		inc hl 
		ld a,(hl)
		DW $92ED : DB $57
		ret
		
bankst:
		db 0
		
sfxoff:
		IM 1
		jp initintsend
		
	afxChDesc:
			DefS 3*6
	afxBankAd:
			DW 0000
	
initintsend:
		
		pop ix 
		pop hl 
		ei
		ENDP
end asm
end sub 

SUB SFXInit(byval address as uinteger)
	ASM 
	
	; ------------------------------------------------- -------------;
	; Initialize the effects player. ;
	; Turns off all channels, sets variables. ;
	; Input: HL = bank address with effects;
	; ------------------------------------------------- -------------;
	
	AFXINIT:
		ld l,(IX+4)
		ld h,(IX+5)
		inc hl
		ld (afxBnkAdr+1),hl				;save the address of the offset table
		
		ld hl,afxChDesc		;mark all channels as empty
		ld de,$00ff
		ld bc,$03fd
	afxInit0:
		ld (hl),d
		inc hl
		ld (hl),d
		inc hl
		ld (hl),e
		inc hl
		ld (hl),e
		inc hl
		djnz afxInit0

		ld hl,$ffbf			; initialize AY
		ld e,$15
	afxInit1:
		dec e
		ld b,h
		out (c),e
		ld b,l
		out (c),d
		jr nz,afxInit1
		ld (afxNseMix+1),de				;reset the player variables
	END ASM 	
END SUB 

sub PlaySFX(byval fx as ubyte)

	ASM 
	; ------------------------------------------------- -------------;
	; Launch the effect on a free channel. Without ;
	; free channels is selected the longest sounding. ;
	; Input: A = number of the effect 0..255;
	; ------------------------------------------------- -------------;
	;BREAK 
		push hl 
		push ix 
		call AFXPLAY
		jp AYFXDONE
	PROC 
	;	ld a,(IX+5)
	AFXPLAY:
		ld de,0				;in DE, the longest time in the search
		ld h,e
		ld l,a
		add hl,hl
	afxBnkAdr:
	
		ld bc,0				;the address of the offset table of effects
		add hl,bc
		ld c,(hl)
		inc hl
		ld b,(hl)
		add hl,bc			;the effect address is obtained in hl
		push hl				;save the effect address on the stack
		
		ld hl,afxChDesc		;search
		ld b,3
	afxPlay0:
		inc hl
		inc hl
		ld a,(hl)			;compare the channel time with the largest
		inc hl
		cp e
		jr c,afxPlay1
		ld c,a
		ld a,(hl)
		cp d
		jr c,afxPlay1
		ld e,c				;remember the longest time
		ld d,a
		push hl				;remember the channel address + 3 in IX
		pop ix
	afxPlay1:
		inc hl
		djnz afxPlay0

		pop de				;take the effect address from the stack
		ld (ix-3),e			;enter in the channel descriptor
		ld (ix-2),d
		ld (ix-1),b			;zero the playing time
		ld (ix-0),b
		ret 
		ENDP
	AYFXDONE:
		pop ix
		pop hl
	end asm 
end sub 

sub WaitRetrace(byval repeats as uinteger)
	asm 
	PROC 
	LOCAL readline
		di
	readline:	
		ld a,$1f : ld bc,$243b : out (c),a : inc b : in a,(c) : cp 192
		jr nz,readline
		dec hl 
		ld a,h
		or l 
		jr nz,readline 
	ENDP 		
	end asm 
end sub  

asm  
 jp nbtempstackstart
end asm 
filename:
asm 		
filename:
	DEFS 255,0
endfilename:	
end asm 

asm 
nbtempstackstart:
	ld sp,nbtempstackstart
end asm 

	
#pragma pop(case_insensitive)

#endif
