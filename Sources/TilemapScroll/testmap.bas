'#!v
'#!sna "H:\tilemap\test.snx" -a
'#!noemu
paper 0 : cls 
#include <nextlib.bas>
#include <memcopy.bas>

'conversion of https://github.com/em00k/TileMap-Example
'needs org of 32768 to work

ShowLayer2(1) : CLS256(0) :
ClipULA(0,0,1,1)
NextReg($15,%00010011)
';bit 7 = 1 to enable tilemap
';bit 6 =0 for 40x32, 1 for 80x32
';bit 5 = palette select
';bits 3-0 = transparent index
NextReg($4c,%10000000)
'28 mhz
NextReg(7,3)	

' $6b
' 7	1 to enable the tilemap
' 6	0 for 40x32, 1 for 80x32
' 5	1 to eliminate the attribute entry in the tilemap
' 4	palette select (0 = first Tilemap palette, 1 = second)
' 3	enable "text mode"
' 2	Reserved, must be 0
' 1	1 to activate 512 tile mode (bit 0 of tile attribute is ninth bit of tile-id)
' 0 to use bit 0 of tile attribute as "ULA over tilemap" per-tile-selector
' 
' 0	1 to enforce "tilemap over ULA" layer priority
NextReg($6b,%10100001)
' Default Tilemap Attribute Register			$6C Default tile attribute for 8-bit only maps.
NextReg($6c,0)
' Tilemap Base Address Register						$6E	Base address of the 40x32 or 80x32 tile map (similar to text-mode of other computers).
NextReg($6e,$40)	'map data
' Tile Definitions Base Address Register	$6F	Base address of the tiles' graphics.
NextReg($6f,$60)	'tile graphics data  
NextReg($68,%10000000)

'Set up palette, choose layer 3 palette 
';(R/W) 0x43 (67) => Palette Control
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
NextReg($43,%00110000)
LoadSD("MM.PAL",$b000,32,0)
PalUpload($b000,16,0)

LoadSD("mm.til",$6000,2048,0)
LoadSD("lev1part1.map",$b000,6144,0)

dim x as ubyte
dim y as ubyte
dim tile as ubyte
dim tilStart as uinteger = $b000 'where map file has been loaded
dim tilDest as uinteger = $4000 'where the tilemap is in memory

' ;Tiles defined at 0x6000 (32 bytes each).  Tilemap starts at 0x4000.  The tilemap is stored in Y major order.  Ie x=0,y=0, x=0,y=1, ..., x=0,y=31, x=1,y=0, ....
' ;Tilemap entry is two bytes:
' ;bits 15-12 : palette offset
' ;bit     11 : x mirror
' ;bit     10 : y mirror
' ;bit      9 : rotate
' ;bit      8 : ula over tilemap
' ;bits   7-0 : tile id

dim a$ as string
dim xs as byte = 0
dim scrollRightStart as ubyte = 40
dim REGACTIVEVIDEOLINEL as ubyte = 31
dim videoLine as ubyte

'clip tile map
ClipTileMap(4,155,0,255)

'draw intial map
for y = 1 to 25
	for x = 1 to 40
		tile = peek(tilStart)
	
		poke (tilDest,tile)

		tilStart = tilStart + 1
		tilDest = tilDest + 1

	next x
	tilStart = tilStart + 256-40

next y

tilStart = $b000 	'where we loaded our map
tilDest = $4000		'where tiles are in memory

do
	
	do
		videoLine = GetReg(REGACTIVEVIDEOLINEL)
	loop until videoLine = 190
	
	'scroll right up to 8 pixels
	xs = xs + 1

	if (xs = 9) then
		scrollRightStart = scrollRightStart + 1
		if scrollRightStart = 216 then
			'wrap back to start
			scrollRightStart = 40
		end if
		ScrollRight()
		xs=0
	end if

	';nextreg 0x30
	' ;x scroll bits 7-0 LSB
	' ;nextreg 0x2f
	' ;x scroll bits 0-1 MSB
	' ;x scroll bits 0-1 MSB
	NextRegA($30,xs)

	a$=inkey$

loop until a$="s"

';nextreg 0x1b:
';clip window for tilemap; the x coords are multiplied by 2 to cover 320 pixel width.
Sub ClipTileMap( byval x1 as ubyte, byval x2 as ubyte, byval y1 as ubyte, byval y2 as ubyte ) 

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

sub ScrollRight()

dim mapStart as uinteger
dim y as ubyte
dim mapLoaded as uinteger

mapStart = tilDest
mapLoaded = tilStart + scrollRightStart 

'drag whole map back one byte
memcopy (mapStart+1, mapStart, 968)

for y = 1 to 25

	'do right hand column update
	mapStart = mapStart + 39

	tile = peek(mapLoaded)

	poke (mapStart, tile)

	mapStart = mapStart + 1
	mapLoaded = mapLoaded + 256

next y

end sub
  