'#!v
'#!sna "H:\tilemap\test.snx" -a
'#!noemu
paper 0 : cls 
#include <nextlib.bas>
asm 
	DI 
end asm 
';bit 7 = 1 to enable tilemap
';bit 6 =0 for 40x32, 1 for 80x32
';bit 5 = palette select
';bits 3-0 = transparent index
ShowLayer2(1) : CLS256(0) :
ClipULA(0,0,1,1)
NextReg($15,%00010011)
NextReg($4c,%10000000)
' $6b,%10000001
' 7	1 to enable the tilemap
' 6	0 for 40x32, 1 for 80x32
' 5	1 to eliminate the attribute entry in the tilemap
' 4	palette select (0 = first Tilemap palette, 1 = second)
' 3	enable "text mode"
' 2	Reserved, must be 0
' 1	1 to activate 512 tile mode (bit 0 of tile attribute is ninth bit of tile-id)
'   0 to use bit 0 of tile attribute as "ULA over tilemap" per-tile-selector
' 
' 0	1 to enforce "tilemap over ULA" layer priority
NextReg($6b,%10100001)
NextReg($6e,$6c)
NextReg($6f,$60)

' Default Tilemap Attribute Register			$6C Default tile attribute for 8-bit only maps.
' Tilemap Base Address Register						$6E	Base address of the 40x32 or 80x32 tile map (similar to text-mode of other computers).
' Tile Definitions Base Address Register	$6F	Base address of the tiles' graphics.

';nextreg 0x1b:
';clip window for tilemap; the x coords are multiplied by 2 to cover 320 pixel width.

';(R/W) 0x43 (67) => Palette Control
'NextReg($43,%
' ;  bit 7 = '1' to disable palette write auto-increment.
' ;  bits 6-4 = Select palette for reading or writing:
' ;     000 = ULA first palette
' ;     100 = ULA secondary palette
' ;     001 = Layer 2 first palette
' ;     101 = Layer 2 secondary palette
' ;     010 = Sprites first palette 
' ;     110 = Sprites secondary palette
' ;     011 = tilemap first palette
' ;     111 = tilemap second palette
' ;  bit 3 = Select Sprites palette (0 = first palette, 1 = secondary palette)
' ;  bit 2 = Select Layer 2 palette (0 = first palette, 1 = secondary palette)
' ;  bit 1 = Select ULA palette (0 = first palette, 1 = secondary palette)
' ;  bit 0 = Disable the standard Spectrum flash feature to enable the extra 
' ;          colours. (0 after a reset)
' 
';nextreg 0x31
';y scroll
';
';nextreg 0x30
' ';x scroll bits 7-0 LSB
' ;nextreg 0x2f
' ;x scroll bits 0-1 MSB
' ;x scroll bits 0-1 MSB

' ;Tiles defined at 0x4c00 (32 bytes each).  Tilemap starts at 0x6c00.  The tilemap is stored in Y major order.  Ie x=0,y=0, x=0,y=1, ..., x=0,y=31, x=1,y=0, ....
' ;Tilemap entry is two bytes:
' ;bits 15-12 : palette offset
' ;bit     11 : x mirror
' ;bit     10 : y mirror
' ;bit      9 : rotate
' ;bit      8 : ula over tilemap
' ;bits   7-0 : tile id
	NextReg($40,0)
		
	
	NextReg($43,%00110000)
	'LoadSD("TEST.PAL",$b000,32,0)
	PalUpload(@palette,16,0)
	LoadSD("TEST.CHR",$6000,6528,0)
	LoadSD("MAP.MAP",$b000,768*2,0)

asm 
	ld hl,$b000
	ld b,0
	ld de,$4000
mloopo:
	inc hl
	ld a,(hl)
	ld (de),a
	inc hl 
	inc de 
	djnz mloopo
end asm 
	
	
' 	asm 
' 		ld hl,22528
' 		ld de,22529
' 		ld (hl),0
' 		ld bc,767
' 		ldir
' 	end asm 
	
	do 
		a=in $7ffe
		if a band %00000001 = 0
			NextReg($4c,%00000000)
			ShowLayer2(0)
			ClipULA(0,255,0,191)
			'stop 
		endif 
	LOOP 

palette:
asm 
	db	$00,$00	; 0 (NOT USED)
	db	$08,$00
	db	$10,$00
	db	$48,$00
	db	$88,$00
	db	$90,$00
	db	$F0,$00
	db	$5C,$00
	db	$13,$01
	db	$FE,$00
	db	$50,$00
	db	$40,$00
	db	$00,$00
	db	$02,$00
	db	$FF,$FF	; 14 (NOT USED)
	db	$FF,$FF	; 15 (NOT USED)
end asm      