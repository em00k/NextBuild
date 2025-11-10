'!ORG=49152
'#!noemu
' newyear demo 2020 by em00k 
' 

#define NEX
#include <nextlib.bas>
asm 
	di 
	nextreg 8,$fe								; no contention 
	nextreg $12,60									; 14mhz
	nextreg 7,3									; 14mhz
	nextreg $40,0   								; palette index 0 
	nextreg $41,$0  								;	set black  
	nextreg $4A,0								; Transparency 0 
	nextreg $70,%00010000							; enable 320x256 256col L2 
	nextreg $69,%00000000
end asm 
dim x,timer1,timer2 as ubyte

LoadSDBank("mod_volume.dat.zx7",0,0,0,15)			' required for SetupMODPlayer
LoadSDBank("modplay.bin.zx7",0,0,0,31)				' required for SetupMODPlayer
LoadSDBank("newyear.mod",0,0,0,32)					' mod in bank 32 onwards  

LoadSDBank("tiles.til",0,0,0,24)			
LoadSDBank("block0.bin",0,0,0,42)			
LoadSDBank("block1.bin",0,0,0,43)			
LoadSDBank("block2.bin",0,0,0,44)			
LoadSDBank("block3.bin",0,0,0,45)			
LoadSDBank("block4.bin",0,0,0,46)			
LoadSDBank("block5.bin",0,0,0,47)			
LoadSDBank("block6.bin",0,0,0,48)			
LoadSDBank("block7.bin",0,0,0,49)			
LoadSDBank("block8.bin",0,0,0,50)			
LoadSDBank("pix16red1.nxt",0,0,0,51)			
ClipLayer2(0,255,0,255)							'; make all of L2 visible 
SetupMODPlayer(31)								' set up the mod player in bank 31

TileHW($40,$60,24)
NextReg($6B,%10100001)							' Tilemap Control on & on top of ULA,  80x32 

Reload:
border 0 : paper 0 : ink 0: cls 

'LoadSD("1.bin",$4000,1000,0)
SetCopper(0)
dim scene as ubyte 
clearbigl2()

showmessage("HAVE A HAPPY", 4, 1)
showmessage("NEW YEAR! ", 6, 2)
showmessage("    ALL THE", 3, 13)
showmessage(" BEST FOR 2021", 3, 14)
sc=0
do 
	WaitRetrace(1)
	
	asm 
		call ModTick
		nextreg $52,$0a 
		nextreg $53,$0b
	end asm 
	
	if timer1>1				' how fast the tiles reduce 
			
		FetchScene(scene BAND 7,42+(scene/8))
		scene=scene+1 : if scene > 67 : scene = 0 : endif 
		timer1=0

	else
		timer1=timer1+1 	
	endif
	if timer2=1
		timer2=0
		SetCopper(sc)
		sc=sc+1
	else 
		timer2=timer2+1
	endif 

loop 

sub showmessage(mtxt$ as string, x as ubyte, y as ubyte)

	dim l,xa,ya as ubyte 
	l = len(mtxt$)
	
	for t=0 to l-1 
			ch=code (mtxt$(t))
			FDoTile16(ch-32,x+xa,y,51)
			xa=xa+1
	next 
	

end sub 

sub clearbigl2()

	for y = 0 to 15
		for x = 0 to 19
			FDoTile16(0,x,y,51)
		next 
	next 
	
end sub 
sub fastcall FetchScene(scene as ubyte,bank as ubyte)

	asm 
		exx 	
		pop hl 					; save our return addrsss
		exx 
		
		; a = scene 
		ld l,a 
		pop af 
		nextreg $51,a			; scene bank 
		
		; l = scene 
		; 
		; 16*8   de = 16  l = 8
		; out hl 
		
		ld de,1000
		
	    ld h,e                      ; h = yl
	    ld e,l                      ; e = x

	    mul d,e                      ; x * yh
	    ex de,hl
	    mul d,e                      ; x * yl

	    ld a,l                      ; cross product lsb
	    add a,d                     ; add to msb final
	    ld h,a
	    ld l,e                      ; hl = final

		; hl now =scene*1000 
		ld de,$2000
		add hl,de 

		ld de,$4000+(40*4)			; buffer 
		ld bc,1000
		
		ldir 					; copy from scenes to buffer 
		
		nextreg $51,$ff			; replace bank 
		
		exx 						;4
		push hl 					;11
		exx 


	    ; 44 cycles, 11 bytes
	end asm 

end sub 

sub TileHW(tileaddr as ubyte, tiledata as ubyte, bank as ubyte )
	'LoadSD("snow1.nxp",@palbuff,511,0)		 this is include at palbuff now 
	
	NextReg($43,%00110000)	' Tilemap first palette
	NextRegA($40,0) ' reset pal index
	for xp = 0 to 16 step 2
		
		v=peek(@palbuff+xp)
		NextRegA($44,v)			' read first pal byte
		v=peek(@palbuff+xp+1)
		NextRegA($44,v)		
	next 
	
	' tilemap 40x32 no attribute 256 mode 

	NextRegA($6E,tileaddr)				' tilemap data
	NextRegA($6F,tiledata)				' tilemap blocks 4 bit 
	
	ClipTile(0,160,0,255)					' set tilemap to max size 

	NextRegA($50,bank)					' move bank from args into slot 0 
	
	asm 
		; we will do this via asm nextreg to keep size down 
		nextreg $6C,%00000000				;'Default Tilemap Attribute on & on top of ULA,  80x32 
		nextreg $68,%10000000				;'ULA CONTROL REGISTER
		nextreg $43,%00110000				;'Tilemap first palette
		nextreg $14,0					;'Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
		nextreg $4C,$0					;'Transparency index for the tilemapp
		
		nextreg $52,$a 					;' make sure bank $a is in slot 2 (61kb bank 5)
		ld hl,0							;' stard address in slot 0 
		ld de,$6000						;' destination slot 2 - 16kb bank 5
		ld bc,5120						;' amount to copy 
		ldir 							;' copy 
		nextreg $50,$ff 					;' put back ROM in slot 0 

		ld hl,$4000						;' clear the actual tilemap 
		ld de,$4001
		ld (hl),$64
		ld bc,80*40
		ldir 
	end asm 
end sub 

palbuff:
asm 
palbuff:
	incbin ".\data\tiles.nxp"
end asm 

sub fastcall UpdateMap(xx as ubyte, yy as ubyte, vv as ubyte)
	asm 
		pop hl : exx 
		ld hl,$4000
		add hl,a 	; add x 
		; hl = $4000+x
		pop de
		ld a,e
		ld e,40
		mul d,e 
		add hl,de
		pop af
		ld (hl),a
		exx 
		push hl 
	end asm 
end sub  


sub SetupMODPlayer(b as ubyte)

	NextRegA($52,b)							' extract volume table 

	zx7Unpack($4000,$8000)					' unpack from $4000 to $8000
											'
	asm                                     
		nextreg $54,16						; extract mod player to banks 16 / 17 
		nextreg $55,17
		nextreg $52,15
	end asm 

	zx7Unpack($4000,$8000)

	asm 
		
		push ix 
		; set up the mod engine and mods 
		nextreg $54,4						; replace slot 4/5 
		nextreg $55,5
		nextreg $52,$a						; and slot 2 
		
		ModInit			equ 32908
		ModLoad			equ 33051
		ModPlay			equ 33592
		ModTick			equ 33784
		ModVolBank		equ 16
		ModBank			equ 64	

		call ModInit

		ld a,32								; last mod set up 
		ld b,1			
		call ModLoad			
		call ModPlay							; init the mod for playback 
		nextreg $52,$0a 						; pop back default banks incase any of the next lines of code 
		nextreg $53,$0b						; require rom / sysvars being present
		pop ix 
	end asm 
end sub 

  
sub SetCopper(offset as byte)
' WAIT	 %1hhhhhhv %vvvvvvvv	Wait for raster line v (0-311) and horizontal position h*8 (h is 0-55)
' MOVE	 %0rrrrrrr %vvvvvvvv	Write value v to Next register r
' https://wiki.specnext.dev/Copper
' 0x60   DDDDDDDD   BYTE data to write to COPPER program RAM
' 0x61   IIIIIIII   Program RAM index 7..0
' 0x62   CC000III   Program RAM index 10..8 and control bits

' 	D    8 bit data
' 	I   11 bit index 
' 	C    2 bit control


	NextReg($61,0)			' set index 0
	NextReg($62,%00000000)	' set 

	asm 
	
	; a = offset 
	
	ld hl,palette
	add a,a 
	add hl,a 							; add offset 
	ld de,coldata
	inc de 				
	ld b,6 
uploadloop:
	ld a,(hl)
	ld (de),a 
	inc hl : inc hl
	add de,4 
	djnz uploadloop
	
	
	ld hl,copperdata						; ' coppper data address 
	ld b,endcopperdata-copperdata 			;' length of data to upload

copperupload:
	ld a,(hl)							; put first byte of copper buffer in to a 
	dw $92ED								; nextreg a, sends a to 
rval:	
	DB $60								; this register, $60 = copper data 
	inc hl								; and loop 
	djnz copperupload
	jp endcopperdata
	
copperdata:

	; 	NAME   15     8 7      0           CLOCKS
	; 	-----------------------------------------
	; 	NOOP   00000000 00000000             1
	; 	MOVE   0RRRRRRR DDDDDDDD             2
	; 	WAIT   1HHHHHHV VVVVVVVV             1
	; 	
	
	db %10000000,0						; 1HHHHHHV VVVVVVVV
	db $43,%10110001
	db %11001000,1
	
	db $40,4								; this is the second bar 
coldata:	
	db $41,129
	
	db %11001000,16
	db $41,65
	db %11001000,64
	db $41,33
	db %11001000,96
	db $41,1
	db %11001000,128
	db $41,1
	
	db %11001001,128+32
	db $41,33
	
	db %11001001,204
	db $40,4 		; this is top of the border 
	db $41,161
	db $ff,$ff

palette:
	db $00, $00, $ff, $00, $df, $00, $db, $00, $da, $00, $b6, $00, $b6, $00, $92, $00
	db $92, $00, $6d, $00, $6d, $00, $49, $00, $49, $00, $25, $00, $24, $00, $24, $00
	db $20, $00, $60, $00, $80, $00, $a0, $00, $c0, $00, $e0, $00, $e5, $00, $ed, $00
	db $f2, $00, $f2, $00, $fa, $00, $20, $00, $44, $00, $64, $00, $84, $00, $a8, $00
	db $e8, $00, $ed, $00, $f1, $00, $f6, $00, $f6, $00, $fa, $00, $24, $00, $48, $00
	db $68, $00, $8c, $00, $ac, $00, $d0, $00, $f0, $00, $f5, $00, $f5, $00, $fa, $00
	db $fa, $00, $24, $00, $48, $00, $6c, $00, $90, $00, $b4, $00, $d8, $00, $f8, $00
	db $fd, $00, $fd, $00, $fe, $00, $fe, $00, $fe, $00, $24, $00, $6c, $00, $70, $00
	db $94, $00, $b8, $00, $dc, $00, $dd, $00, $dd, $00, $de, $00, $de, $00, $fe, $00
	db $24, $00, $28, $00, $4c, $00, $50, $00, $74, $00, $7c, $00, $9d, $00, $bd, $00
	db $be, $00, $de, $00, $de, $00, $04, $00, $08, $00, $2c, $00, $30, $00, $34, $00
	db $38, $00, $3c, $00, $5d, $00, $7d, $00, $be, $00, $de, $00, $04, $00, $08, $00
	db $0c, $00, $10, $00, $14, $00, $18, $00, $1d, $00, $3d, $00, $7d, $00, $9e, $00
	db $be, $00, $de, $00, $04, $00, $0d, $00, $11, $00, $15, $00, $19, $00, $1d, $00
	db $3e, $00, $7e, $00, $9e, $00, $be, $00, $df, $00, $04, $00, $09, $00, $0d, $00
	db $11, $00, $16, $00, $1e, $00, $3e, $00, $7e, $00, $9f, $00, $bf, $00, $df, $00
	db $05, $00, $09, $00, $0d, $00, $12, $00, $16, $00, $1b, $00, $1f, $00, $3f, $00
	db $7f, $00, $bf, $00, $df, $00, $05, $00, $05, $00, $09, $00, $0e, $00, $0e, $00
	db $13, $00, $17, $00, $37, $00, $77, $00, $9b, $00, $bb, $00, $df, $00, $05, $00
	db $05, $00, $05, $00, $06, $00, $0a, $00, $0b, $00, $0b, $00, $2f, $00, $73, $00
	db $97, $00, $b7, $00, $db, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00
	db $03, $00, $03, $00, $27, $00, $6f, $00, $93, $00, $b7, $00, $db, $00, $01, $00
	db $21, $00, $21, $00, $22, $00, $42, $00, $43, $00, $43, $00, $67, $00, $8f, $00
	db $b3, $00, $db, $00, $21, $00, $21, $00, $41, $00, $62, $00, $62, $00, $83, $00
	db $83, $00, $a7, $00, $af, $00, $d3, $00, $d3, $00, $db, $00, $21, $00, $61, $00
	db $82, $00, $a2, $00, $c3, $00, $c3, $00, $c7, $00, $cf, $00, $f3, $00, $f3, $00
	db $fb, $00, $21, $00, $41, $00, $61, $00, $81, $00, $a2, $00, $e2, $00, $e6, $00
	db $ef, $00, $f3, $00, $f3, $00, $fb, $00, $20, $00, $41, $00, $61, $00, $81, $00
	db $a1, $00, $c1, $00, $e2, $00, $e6, $00, $ee, $00, $f2, $00, $fb, $00, $20, $00
	db $40, $00, $60, $00, $80, $00, $a0, $00, $c0, $00, $e1, $00, $e5, $00, $ed, $00
	db $f2, $00, $f2, $00, $fa, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

	
endcopperdata:
	
end asm							

	NextReg($62,%11000000)

end sub 
                 