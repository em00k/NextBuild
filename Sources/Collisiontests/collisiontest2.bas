'!ORG=24576
'!HEAP=1024
'#!COPY=h:\myfile.nex
'#! "assets\gfx2next.exe -tile-repeat -tile-size=8x8 -colors-4bit -block-size=4x4 assets\basicshapes.bmp data\basicsh"


#define NEX = 1 
#include <nextlib.bas>
#include <keys.bas>
PAPER 0 : BORDER 7 : ink 7 : CLS 

asm 
	nextreg $15,%00010001
	nextreg $14,0
	nextreg $7,3
	nextreg $8,254
	di 
end asm 

' set up the sprites 
LoadSDBank("sprites.spr",0,0,0,32)						' sprites bank 32
asm : nextreg $50,32 : nextreg $51,33 : end asm 
InitSprites(64,$0000)									' init all sprites 
asm : nextreg $50,$ff : nextreg $51,$ff : end asm   	' pop back default banks 

'

' draw map 

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

drawmap()
WaitKey()

do 

	WaitRetrace(1)
	
	ReadKeys()
	CheckCollision()
	UpdatePlayer()
	
	
loop 

Sub CheckCollision()

	border 1 
	dim sp as uinteger
	dim plxc,plyc,tilehit as ubyte 
	
	mapbuffer = @map			' point to the map 	
	

	oldpx = plx 
	oldpy = ply

	if pldx = MLEFT 
		plx = plx - 1 
	elseif pldx = MRIGHT
		plx = plx + 1
	endif 
 	
	' if pldy = MUP
	' 	ply = ply - 1 
	' else 
	' 	pldy = MDOWN
	' 	ply = ply + 1
	' endif 

    plxc = (plx)                            ' take a copy of plx ply 
    plyc = (ply)
    	
	lefttile = (plxc+2) >> 4                ' / 16 to get current map co-ords
	righttile = (plxc+14) >> 4              ' +2 & +14 for soft edges 
	
	toptile = (plyc+2) >> 4
	bottile = (plyc+14) >> 4
	
	if lefttile>16 : lefttile = 0 : endif   ' make sure our tile positions dont overflow from whats on screen
	if righttile>16 : righttile = 15 : endif 
	if toptile>16 : toptile = 0 : endif 
	if bottile>16 : bottile = 16 : endif 

	tile = 0 
	
	if pldx = MLEFT 
		for yy= toptile to bottile
				tile = tile + peek(mapbuffer+(cast(uinteger,yy)<<4)+cast(uinteger,lefttile))
				if tile > 0 
					print at 4,0;"bop"
					plsp = 3
					plx = oldpx
					pldx = MSTILL
				else 
					print at 4,0;"   "
					plsp = 2
				endif 
		next	
	elseif pldx = MRIGHT
			for yy= toptile to bottile
				tile = tile + peek(mapbuffer+(cast(uinteger,yy)<<4)+cast(uinteger,righttile))
				if tile > 0 
					print at 4,0;"hit"
					plsp = 3
					plx = oldpx
					pldx = MSTILL
				else 
					print at 4,0;"   "
					plsp = 2
				endif 
		next	
	endif 

	if pldy = MUP
		ply = ply - 1 
	else 
		pldy = MDOWN
		ply = ply + 1
	endif 

    plxc = (plx)                            ' take a copy of plx ply 
    plyc = (ply)
    	
	lefttile = (plxc+2) >> 4                ' / 16 to get current map co-ords
	righttile = (plxc+14) >> 4              ' +2 & +14 for soft edges 
	
	toptile = (plyc+2) >> 4
	bottile = (plyc+14) >> 4
	
	if lefttile>16 : lefttile = 0 : endif 
	if righttile>16 : righttile = 15 : endif 
	if toptile>12 : toptile = 0 : endif 
	if bottile>12 : bottile = 12 : endif 
	
	tile = 0 

	if pldy = MUP 
		for xx= lefttile to righttile
				tile = tile + peek(mapbuffer+(cast(uinteger,toptile)<<4)+cast(uinteger,xx))
				if tile > 0 
						print at 4,0;"hit"
						plsp = 3
						ply=oldpy
						pldy = MSTILL
				else 
					print at 4,0;"   "
					plsp = 2
				endif 
		next	
		endif
	'elseif pldy = MDOWN
		for xx= lefttile to righttile
				tile = tile + peek(mapbuffer+(cast(uinteger,bottile)<<4)+cast(uinteger,xx))
				if tile > 0 
				'	while peek(mapbuffer+(cast(uinteger,(ply-16))+cast(uinteger,xx)))>0		
						print at 4,0;"hit"
						plsp = 3
						ply=oldpy
						'pldy = MUP
				'	wend 
				else 
					print at 4,0;"   "
					plsp = 2
					'pldy = MDOWN
					endif 
		next	
	'endif 
	
	oldpx = plx 
	oldpy = ply	

	border 0 
	print at 0,0;plxc;"   ";plyc ;"   ";tile ;"   "
	print at 1,0;lefttile;"   ";righttile ;"   ";toptile ;"   ";bottile ;"   "
	print at 2,0;tileleft;"   ";colright ;"   ";tileup ;"   ";tiledown ;"   "
	
end sub 


asm
	nextreg SPRITE_CONTROL_NR_15,%00000000
end asm


sub ReadKeys()

	pldx = MSTILL 
	pldy = MSTILL 

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

	

	UpdateSprite(cast(uinteger,plx)+32,32+ply,0,plsp,0,0)
	
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
	db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	
end asm 