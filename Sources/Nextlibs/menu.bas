Sub fastcall LoadMenu()
	CLS
	asm 
	;ld hl,.LABEL._ScreenData
	;ld de,.LABEL._ScreenData+1
	;ld bc,1048 
	;ld (hl),0
	;ldir	
	ld hl,$e000
	ld de,$e001
	ld bc,1048 
	ld (hl),0
	ldir 
	end asm 
	ClipLayer2(0,255,0,191-(4*8)+6)
	menu = 2
	'DrawPanel(0,9,20,6,0)
	beep .001,3
	plot 0,3*8:Draw 255,0
	AddMenuOption(1,4,21,"Load BMP    ")
	AddMenuOption(2,4,22,"Load NXI    ")
	AddMenuOption(3,4,23,"Load Palette")
	AddMenuOption(4,24,21,"Load Ranges ")
	AddMenuOption(5,24,22,"Load Sprites")
		asm 
		ld hl,22528+20*32
		ld de,22529+20*32
		ld (hl),255
		ld bc,32*4-1
		ldir
	end asm 
end sub 
Sub fastcall SaveMenu()
	CLS
	asm 
		ld hl,$e000
		ld de,$e000+1
		ld bc,1048 
		ld (hl),0
		ldir 
	end asm 
	ClipLayer2(0,255,0,191-(4*8)+6)
	menu = 4
	'DrawPanel(0,9,20,6,0)
	beep .001,3
	plot 0,3*8:Draw 255,0
	AddMenuOption(1,4,21,"Save BMP    ")
	AddMenuOption(2,4,22,"Save NXI    ")
	AddMenuOption(3,4,23,"Save Palette")
	AddMenuOption(4,24,21,"Save Ranges ")
	AddMenuOption(5,24,22,"Save Brush")
' 		asm 
' 			ld hl,23168			; y = 20
' 			ld de,23168+1
' 			ld (hl),252
' 			ld bc,31
' 			ldir 
' 			ld hl,23168+32			; y = 20
' 			;ld de,23168+1
' 			ld (hl),156
' 			ld bc,31
' 			ldir 
' 			
' 			ld hl,23168+32+32			; y = 20
' 			;ld de,23168+1
' 			ld (hl),30
' 			ld bc,31
' 			ldir 
' 			
' 			ld hl,23168+32+32+32			; y = 20
' 			;ld de,23168+1
' 			ld (hl),31
' 			ld bc,31
' 			ldir 
' 			jp colout
' 			
' menucols:
' 		db 252,156,30,31
' 		colout:
' 		end asm 
		asm 
		ld hl,22528+20*32
		ld de,22529+20*32
		ld (hl),255
		ld bc,32*4-1
		ldir
	end asm 
end sub 
Sub DrawPanel(x as ubyte, y as ubyte, w as ubyte, h as ubyte, e as ubyte)
	
' 	print at y,x;"\a"
' 	for c=x+1 to x+w+1
' 		print at y,c;"\b"
' 		print at y+h,c;"\h"
' 	next 
' 	print at y,c-1;"\c"
' 	for d=y+1 to y+h-1
' 		print at d,c-1;"\f"
' 		print at d,x;"\d"
' 	next 
' 	print at d,x;"\g"
' 	print at d,c-1;"\i"
end sub 

sub AddMenuOption(id as ubyte, tx as ubyte, ty as ubyte, m$ as string)
	
	'strlen = len(m$)		' length of ms
	'ink 2 : paper 6
	printat42(ty,tx)
	print42(chr(17)+chr(6)+m$)
	addr=cast(uinteger,ty)*42+tx
	mapaddr=$e000+addr
	poke ubyte mapaddr,id
	asm 	
		ld l,(IX+10)
		ld h,(IX+11)
		ld a,(hl) ; length 
		dec a 
		ld hl,(._mapaddr)
		ld c,a
		ld d,h
		ld e,l
		inc de 
		ldir
	end asm 
end sub 

sub FastKey(byval fext$ as string)
	asm 
		;BREAK 
		inc hl 
		inc hl 
		push hl 		 
		call set2by2
		ld b,8
dounderscore:
		ld a,'_'
		rst 16
		djnz dounderscore
		call set2by2
		ld a,'_'
		rst 16 
		call set2by2
		xor a
		ld (23560),a			; clear last key
		
		ld b,9
		ld hl,.LABEL._namebuff
checkkey:		
		;halt 
		ld a,(23560)			; last key
		or a					; is it a 
		jr z,checkkey

keydetected:
	push ix 
	push bc
	push de 
	push hl
	push af 
sound_setup:
	ld de, 5
	ld b,3
	ld hl, 938 	; pitch
sound_loop:
	dec h
	push bc
	push de
	push hl
	call 949 	; call ROM beeper routine
	pop hl
	pop de
	pop bc
	djnz sound_loop
	pop af
	pop hl
	pop de
	pop bc
	pop ix
	
		cp '.'
		jr z,checkkey2
		cp 12 					; backspace 
		jp z,backspace 
		cp 13							; ret 
		
		jr z,enterpress	
		cp 32 
		jr c,checkkey2
		cp 123 
		jr nc,checkkey2
		ld d,a 		; save d
		
		;BREAK 
		ld a,b
		dec a
		or a
		
		jr z,dontprint
		
		
		ld a,d
		ld (hl),a	
		rst 16
		inc hl 
dontprint:
		xor a
		ld (23560),a			; clear last key
		djnz checkkey
		ld b,1
		jp checkkey
		
		
backspace:
		;BREAK 
		ld a,b
		sub 9
		jp nc,checkkey2
		dec hl
		
		ld a,8
		sub b
		add a,2
		ld d,a			; save a 
		ld e,b 			; save b
		ld b,1
delchar:

		ld a,22
		rst 16
		ld a,2
		rst 16
		ld a,d
		rst 16
		djnz delchar 
		ld a,'_'
		rst 16
		ld a,22
		rst 16
		ld a,2
		rst 16
		ld a,d
		rst 16
		
		ld b,e
		;ld a,b
		inc b 
		;ld b,a
checkkey2:
		xor a 
		ld (23560),a	
		jp checkkey	
	
set2by2:
		ld a,22		; at 
		rst 16
		ld a,2		; y 
		rst 16
		ld a,2		; x
		rst 16 
		ret 
		
enterpress:
		pop de 
		ld b,4
extloop:
		ld a,(de)
		ld (hl),a
		inc hl 
		inc de 
		djnz extloop
		ld (hl),0
		
checkkeyout:

	end asm 
end sub 

namebuff:
asm
		defm "filename.ext"
		db 0
end asm 

SUB Remap9bit()
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	dim res2 as uinteger
	dim r9,g9,b9 as uinteger
	dim o as uinteger 
	'for l=0 to 1
	o=0
	for c=0 to 255*4 step 4	
		b9=peek($c400+cast(uinteger,c))
		g9=peek($c400+cast(uinteger,c+1))
		r9=peek($c400+cast(uinteger,c+2))
		res2 = ((r9>>5) << 6) BOR ((g9 >> 5) << 3) BOR (b9>>5)
		'res3=res2 >>1 : sb=res2 band 1
		NextRegA($44,cast(ubyte,res2>>1))
		NextRegA($44,cast(ubyte,res2 band 1))
		'MMU8(6,130)
		poke ubyte 49152+o,cast(ubyte,res2>>1)
		poke ubyte 49152+o+1,cast(ubyte,res2 band 1)
		'MMU8(6,0)
		o=o+2
	next c 
	'NextReg($43,%01000001) 	' l2 pal 1
	'NextReg($40,0) ' reset pal index
	'next l 
	remapped=1
end sub 

ScreenData:
	ASM 
	;	DEFS 1048,0
	end asm 
guiblocks: 
asm 
	; ASM data file from a ZX-Paintbrush picture with 24 x 24 pixels (= 3 x 3 characters)

	; block based output of pixel data - each block contains 8 x 8 pixels

	; blocks at pixel positionn (y=0):

	db	$00, $00, $00, $00, $00, $00, $01, $03
	db	$00, $00, $00, $00, $00, $00, $FF, $00
	db	$00, $00, $00, $00, $00, $00, $80, $C0

	; blocks at pixel positionn (y=8):

	db	$02, $02, $02, $02, $02, $02, $02, $02
	db	$00, $00, $00, $00, $00, $00, $00, $00
	db	$40, $40, $40, $40, $40, $40, $40, $40

	; blocks at pixel positionn (y=16):

	db	$03, $01, $00, $00, $00, $00, $00, $00
	db	$00, $FF, $00, $00, $00, $00, $00, $00
	db	$C0, $80, $00, $00, $00, $00, $00, $00
end asm            