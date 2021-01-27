
'#!HEAP=1024

'#! "assets\gfx2next.exe -tile-repeat -tile-size=8x8 -colors-4bit -block-size=4x4 assets\basicshapes.bmp data\basicsh"


#define NEX 
#include <nextlib.bas>
#include <keys.bas>
PAPER 0 : BORDER 7 : ink 7 : CLS 

asm 
	nextreg $15,%00010001
	nextreg $14,0
	nextreg $7,3
	di 
end asm 

' set up the sprites 
LoadSDBank("sprites.spr",0,0,0,32)						' sprites bank 32
asm : nextreg $50,32 : nextreg $51,33 : end asm 
InitSprites(64,$0000)									' init all sprites 
asm : nextreg $50,$ff : nextreg $51,$ff : end asm   	' pop back default banks 

'


dim plx as ubyte 
dim ply as ubyte 
dim pldx as ubyte 
dim pldy as ubyte 
dim plch as ubyte 
dim plsp as ubyte = 2 
dim oldpx as ubyte 
dim oldpy as ubyte
dim mapbuffer as uinteger
const MLEFT  as ubyte = 0 
const MRIGHT as ubyte = 1 
const MUP	as ubyte = 2 
const MDOWN	as ubyte = 3 
const MSTILL	as ubyte = 4
	
plx = 6<<3 : ply = 6<<3
' draw map 
drawmap()


do 

	WaitRetrace(1)
	ReadKeys()
	CheckCollision()
	UpdatePlayer()
	
	
loop 

Sub CheckCollision()

	border 4 
	dim sp as uinteger
	dim plxc,plyc,tilehit as ubyte 
	
	mapbuffer = @map			' point to the map 	
	
	oldpx = plx 
	oldpy = ply-1

	if pldx = MLEFT 
		plx = plx - 1 
	elseif pldx = MRIGHT
		plx = plx + 1
	endif 
	if pldy = MUP
		ply = ply - 1 
	elseif pldy = MDOWN
		ply = ply + 1
	endif 

	plxc = (plx)+8
	plyc = (ply)-16
	
	lefttile = (plxc-8) >> 4 
	righttile = (plxc+8) >> 4 
	toptile = (plyc-16) >> 4 
	bottile = (plyc) >> 4
	
	if lefttile>16 : lefttile = 0 : endif 
	if righttile>16 : righttile = 15 : endif 
	if toptile>12 : toptile = 0 : endif 
	if bottile>12 : bottile = 12 : endif 
	
	tile = 0 
	
	for yy= toptile to bottile
		for xx = lefttile to righttile
			tile = tile + peek(mapbuffer+(cast(uinteger,yy)<<4)+cast(uinteger,xx))
			if tile > 0 
				print at 4,0;"hit"
				plsp = 3
			else 
				print at 4,0;"   "
				plsp = 2
			endif 
		next 
	next 
	

	if tile > 0 
		if pldx <>MSTILL
			plx = oldpx
		endif 
		if pldy <> MSTILL
			ply = oldpy
			pldy = MSTILL
		endif 
	else 			
		
	endif 

	
	' tileleft  	= peek(mapbuffer+(cast(uinteger,plyc)<<4)+cast(uinteger,lefttile))
	' colright		= peek(mapbuffer+(cast(uinteger,plyc)<<4)+cast(uinteger,leftright))
	' tileup		= peek(mapbuffer+(cast(uinteger,toptile)<<4)+cast(uinteger,plxc))
	' tiledown		= peek(mapbuffer+(cast(uinteger,bottile)<<4)+cast(uinteger,plxc))

	
	' tile = peek(mapbuffer+(cast(uinteger,plyc)<<4)+cast(uinteger,plxc))
	
	' x1 = plx
	' y1 = ply 
	' x2 = plxc
	' xy = plyc
	' size = 16
	
	' if (x1+size<x2+4) BOR (x1+4>=x2+size) Bor (y1+size<y2+4) BOR (y1+4>=y2+size)=0
	 	' tilehit = 1 
		' print at 1,0;"hit"
	' else 
		' print at 2,0;"   "
	' endif 
		
	'tilehit = peek(mapbuffer+(cast(uinteger,plyc)<<4)+cast(uinteger,plxc))
	border 0 
	print at 0,0;plxc;"   ";plyc ;"   ";tile ;"   "
	print at 1,0;lefttile;"   ";righttile ;"   ";toptile ;"   ";bottile ;"   "
	print at 2,0;tileleft;"   ";colright ;"   ";tileup ;"   ";tiledown ;"   "
	
end sub 

sub ReadKeys()

	pldx = MSTILL 
	pldy = MDOWN

	if MultiKeys(KEYD)
		pldx = MRIGHT 
	elseif MultiKeys(KEYA)
		pldx = MLEFT 
	endif 
	if MultiKeys(KEYW)
		pldy = MUP
	elseif MultiKeys(KEYS)
		pldy = MDOWN
	endif 
	
end sub 

sub UpdatePlayer()

	

	UpdateSprite(cast(uinteger,plx)+32,ply,0,plsp,0,0)
	
end sub 


sub drawmap()

	dim sp as uinteger
	dim p as ubyte 
	
	mapbuffer = @map
		
	print mapbuffer
	
	for y = 0 to 11 
		for x = 0 to 15
			p = peek(mapbuffer+sp)
			FDoTile16(p,y,x,32)
			sp = sp + 1 
		next x 
	next y
	
end sub 

map:
asm
	; 16 x 12 map 
	; 0 empty space 
	; 1 block 
	; 2 pl start 
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0
	db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,1,0,0,0,1,1,1,0,0,0,0,0
	db 0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0
	db 0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0
	db 0,0,0,0,1,0,0,0,1,1,1,0,0,0,0,0
	db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	
end asm 