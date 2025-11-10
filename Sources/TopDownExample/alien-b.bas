'!ORG=24576
'!HEAP=512
' over top game engine for NextBuild by em00k 
' Uses banked tiles, ayfx music interrupts
' v1 

const spleft as ubyte = %1010					' thare constants required for sprite mirror + flipping 
const spright as ubyte = %0010
const spup  as ubyte = %0000
const spdown   as ubyte = %0100

#define NEX										' we want to disable all LOADSD commands and include all data files in our NEX
#define IM2										' we're using out own IM routine for AY FX + MUSIC 
#include <nextlib.bas>							' inlcude the nextlibs 
#include <keys.bas>

PAPER 0 : BORDER 0 : ink 7 : CLS 				' paint it all black

asm 
	nextreg SPRITE_CONTROL_NR_15,%00010001		; Sprites on, bits 4-2  %100 ULA on top of Sprites on top of Layer2
	nextreg GLOBAL_TRANSPARENCY_NR_14,0			; set global transparency to black 
	nextreg TURBO_CONTROL_NR_07,3				; turbo mode 28mhz 
	nextreg PERIPHERAL_3_NR_08,254				; disable contention 
	di 
end asm 


' -- Load block is where we load all out data files 
LoadSDBank("tiles.spr",0,0,0,32)				' sprites bank 32
LoadSDBank("player.spr",0,0,0,34)				' sprites bank 32
LoadSDBank("game.afb",0,0,0,36) 				' load game.afb into bank 36
LoadSDBank("vt24000.bin",0,0,0,38) 				' load the music replayer into bank 38
LoadSDBank("thunder.pt3",0,0,0,39) 				' load music.pt3 into bank 39
LoadSDBank("font4.spr",0,0,0,40)				' load font into bank 40
' -- 

asm : nextreg $50,34 : nextreg $51,35 : end asm 		
InitSprites(64,$0000)									' init all sprites 
asm : nextreg $50,$ff : nextreg $51,$ff : end asm   	' pop back default banks 

InitSFX(36)							            ' init the SFX engine, sfx are in bank 36
InitMusic(38,39,0000)				            ' init the music engine 38 has the player, 39 the pt3, 0000 the offset in bank 34
SetUpIM()							            ' init the IM2 code 

' DEFINE variables 
dim plx as ubyte 
dim ply as ubyte 
dim pldx as ubyte 
dim pldy as ubyte 
dim plch as ubyte 
dim worldpoint as ubyte 
dim playerframe as ubyte
dim playerattrib3 as ubyte = 2 
dim oldpx as ubyte 
dim oldpy as ubyte
dim attr3 as ubyte
Dim firepressed as ubyte
Dim firetimer as ubyte
dim playerframetimer as ubyte
dim playerframbase  as ubyte
dim mapbuffer as uinteger
dim worldoffset as uinteger
const MLEFT  as ubyte = 0 
const MRIGHT as ubyte = 1 
const MUP	as ubyte = 2 
const MDOWN	as ubyte = 3 
const MSTILL	as ubyte = 4

intro()											' show intro screen 

plx = 6<<3 : ply = 6<<3 : playerattrib3 = 0		' set some variables 
worldpoint=37 : playerframbase = 0 

drawmap()										' draw inital map 

' main game loop 

do 
    WaitRetrace2(1)		
    border 2
    ReadKeys()
	CheckCollision()
    UpdatePlayer()
    border 0
loop 


' -- subs 

Sub CheckCollision()
	
	' a robust collision routine for our player against the tilemap

	dim sp as uinteger
	dim plxc,plyc,tilehit as ubyte 
	
	mapbuffer = @map1+worldoffset			' point to the map 	

	oldpx = plx                             ' store current player x and y 
	oldpy = ply

	if pldx = MLEFT                         ' is player x direction LEFT?
		plx = plx - 1                       ' then plx - 1
	elseif pldx = MRIGHT                    ' is player x direction RIGHT?
		plx = plx + 1                       ' then plx + 1 
	endif 

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
	
	tile = 0                                ' tile flag 

	if pldx = MLEFT                         ' were we moving left? 
		for yy= toptile to bottile
				tile = tile + peek(mapbuffer+(cast(uinteger,yy)<<4)+cast(uinteger,lefttile))
				if tile > 0                 ' we hit a tile that wasnt 0 
					plx = oldpx             ' put plx back 
					pldx = MSTILL           ' change plx direction to STILL 
				endif 
		next	
	elseif pldx = MRIGHT                    ' repeat for right 
			for yy= toptile to bottile
				tile = tile + peek(mapbuffer+(cast(uinteger,yy)<<4)+cast(uinteger,righttile))
				if tile > 0 
					plx = oldpx
					pldx = MSTILL
				endif 
		next	
	endif 

    ' same as above but for up and down 

	if pldy = MUP
		ply = ply - 1 
	elseif pldy = MDOWN
		ply = ply + 1
	endif 

	plxc = (plx) : plyc = (ply)
	
	lefttile = (plxc+2) >> 4                    ' 2 & 14 for soft edge blocks 
	righttile = (plxc+14) >> 4 
	
	toptile = (plyc+2) >> 4
	bottile = (plyc+14) >> 4
	
	if lefttile>16 : lefttile = 0 : endif 
	'if righttile>17 : righttile = 17 : endif 
	if toptile>16 : toptile = 0 : endif 
	if bottile>16 : bottile = 16 : endif 
	
	tile = 0 

	if pldy = MUP 
		add = (mapbuffer+(cast(uinteger,toptile)<<4))
		for xx= lefttile to righttile
				tile = tile + peek(add +cast(uinteger,xx))
				if tile > 0 
						ply=oldpy
						pldy = MSTILL
				endif 
		next	
	elseif pldy = MDOWN
		add = (mapbuffer+(cast(uinteger,bottile)<<4))
		for xx= lefttile to righttile
				tile = tile + peek(add+cast(uinteger,xx))
				if tile > 0 
						ply=oldpy
				endif 
		next	
	endif 
    
    ' detects if we hit left right top of bottom edges to draw a new map
    ' 
    if plx = 255-14
        worldpoint=worldpoint+1 : plx = 2 : drawmap()
    elseif plx = 0 
        worldpoint=worldpoint-1 : plx = 254-14 : drawmap()
    elseif ply>192
        worldpoint=worldpoint+8 : ply = 2 : drawmap()
    elseif ply=0
        worldpoint=worldpoint-8 : ply = 191 : drawmap()
    endif 

	oldpx = plx : oldpy = ply	

end sub 


sub ReadKeys()

	pldx = MSTILL : pldy = MSTILL 

	if MultiKeys(KEYD)
        pldx = MRIGHT 
        attr3 = spright
        keypressed = 1 
	elseif MultiKeys(KEYA)
        pldx = MLEFT 
        attr3 = spleft
        keypressed = 1 
	endif 
	if MultiKeys(KEYW)
        pldy = MUP
        attr3 = spup
        keypressed = 1 
	elseif MultiKeys(KEYS)
        pldy = MDOWN
        attr3 = spdown
        keypressed = 1 
    endif 
    if MultiKeys(KEYSPACE) and firepressed = 0 
        PlaySFX(5)
        firepressed = 1 
        firetimer = 5
        playerframbase = 6 
    endif 
    if GetKeyScanCode()=KEYR
        LoadSDBank("tiles.spr",0,0,0,32)            ' so we can change the tiles on the fly and reload to test 
        drawmap()
        
    endif 

    if  firetimer > 1
        ' firetimer triggered 
         firetimer = firetimer - 1
    elseif firetimer = 1
         firetimer = 0 
         firepressed = 0
         playerframbase = 0 
    endif 
    
    
    if keypressed = 1   
        if  playerframetimer =  3
            ' timer triggered for updating player waddle
             playerframetimer = 0
             playerframe = (1 - playerframe) 
        else 
             playerframetimer =  playerframetimer + 1 
        endif 
    end if     

end sub 

sub UpdatePlayer()

    ' attr3 = x mirror, y mirror, rotate
    ' left  %1010	
    ' right %0010
    ' up    %0000
	' down  %0100

	UpdateSprite(cast(uinteger,plx)+32,ply+32,0,playerframe+playerframbase,attr3,0)

end sub 


sub drawmap()

	dim sp,worldmap as uinteger
	dim p as ubyte 
    
    worldmap = peek(@world+worldpoint-1)-1              ' get the current map from the worldmap table -1 

    worldoffset = worldmap * 192                        ' each screen is 192 in size 

    mapbuffer = @map1+worldoffset                       ' set the offset 

    ClipLayer2(0,0,0,0)									' hide everything so we dont see the screen
    ClipSprite(0,0,0,0)									' updating
	for y = 0 to 11 
		for x = 0 to 15
			p = peek(mapbuffer+sp)
			DoTileBank16(x,y,p,32)
			sp = sp + 1 
		next x 
    next y
    ClipLayer2(0,255,0,191)								' unlclip Sprites and Layer 2 
    ClipSprite(0,255,0,191) 
    L2Text(0,0,str(worldmap),40,0)
    
end sub 

sub intro()
    'WaitKey()       
    EnableSFX							            ' Enables the AYFX, use DisableSFX to top
    EnableMusic 						            ' Enables Music, use DisableMusic to stop 
    PlaySFX(0)                                      ' Plays SFX 
    CLS256(0)   
    L2Text(0,0,"THIS IS A QUICK DEMO WRITTEN",40,0)
    L2Text(0,1,"USING NEXTBUILD AND BORIELS ",40,0)
    L2Text(0,2,"ZXBASIC COMPILER",40,0)
    L2Text(0,3,"USE WASD TO MOVE, SPACE FIRE",40,0)
    L2Text(0,5,"ANY KEY TO CONTINUE",40,0)
    WaitRetrace2(10)
    WaitKey()  
end sub

world:
asm
    db 00,00,00,00,00,00,00,00 ; 
    db 00,00,00,00,00,00,00,00 ; 8
    db 00,00,00,00,00,00,00,00 ; 16
    db 00,00,00,00,00,00,00,00 ; 24
    db 00,00,00,00,01,02,03,00 ; 32
    db 00,00,00,00,00,06,04,04 ; 40
    db 00,00,00,00,00,00,05,00 ; 48
    db 00,00,00,00,00,00,00,00 ; 56
    db 00,00,00,00,00,00,00,00 ; 64
end asm

map1:
asm
	; 16 x 12 map 
	; 0 empty space 
	; 1 block 
    ; 2 pl start 
map1:    
	db 4,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	db 5,1,0,0,1,0,0,0,0,0,0,0,0,0,0,1
	db 4,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1
	db 5,1,0,0,1,1,1,1,0,0,0,0,0,0,0,1
	db 4,1,0,0,0,0,0,0,0,8,0,0,0,0,0,1
	db 5,1,1,0,0,0,0,0,1,1,1,0,0,0,0,1
	db 4,5,1,0,0,0,0,0,1,0,0,0,0,0,0,1
	db 5,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1
	db 4,1,0,0,1,0,0,0,1,1,1,0,0,0,0,1
	db 5,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0
	db 4,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0
	db 5,4,1,1,1,1,1,1,1,1,1,1,1,1,1,1

map2:

	db 4,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	db 5,4,5,4,1,1,1,1,1,1,1,1,1,4,5,1
	db 4,5,4,1,0,0,0,0,0,0,0,0,1,5,4,1
	db 5,4,5,4,1,0,0,0,0,0,0,0,1,1,1,1
	db 4,5,4,5,4,5,1,1,0,0,0,0,0,0,0,0
	db 5,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0
	db 4,5,1,0,0,0,0,0,0,0,1,1,1,1,1,1
	db 5,1,0,0,0,0,0,0,0,1,5,4,5,4,5,4
	db 1,1,0,0,0,1,1,1,1,1,4,5,4,5,4,5
	db 0,0,0,0,1,4,5,4,5,4,5,4,5,4,5,4
	db 0,0,0,1,4,5,4,5,4,5,4,5,4,5,4,5
	db 1,1,1,1,5,4,5,4,5,4,5,4,5,4,5,4

map3:    
	db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
	db 1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1
	db 1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,1
	db 5,4,5,4,5,4,5,4,5,4,5,4,1,0,0,1
	db 5,4,5,4,5,4,5,4,5,4,5,4,1,0,0,1
	db 5,4,5,4,5,4,5,4,5,4,5,4,1,0,0,1
	db 5,4,5,4,5,4,5,4,5,4,5,4,1,0,0,1
	db 5,4,5,4,5,4,5,4,5,4,5,4,1,0,0,1
map4:    
	db 4,5,4,5,4,5,4,5,1,1,1,1,1,0,0,1
	db 1,4,5,4,5,4,5,4,5,1,1,1,1,0,0,1
	db 1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1
	db 0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1
	db 0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1
	db 1,1,1,1,1,1,0,0,0,1,1,1,1,1,4,5
	db 1,1,5,4,5,1,0,0,0,1,5,4,5,4,5,4
	db 4,5,4,5,4,1,0,0,0,1,4,5,4,5,4,5
	db 5,4,5,4,5,1,0,0,0,1,5,4,5,4,5,4
	db 4,5,4,5,4,1,0,0,0,1,4,5,4,5,4,5
    db 5,4,5,4,5,1,0,0,0,1,5,4,5,4,5,4	
map5:    
	db 5,4,5,4,5,4,0,0,0,1,4,5,4,1,1,1
	db 1,5,4,5,5,4,0,0,0,1,5,4,1,1,1,1
	db 1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1
	db 1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0
	db 4,5,4,1,0,0,0,0,0,0,0,0,0,0,0,0
	db 5,4,5,4,1,0,0,0,0,0,0,0,0,0,0,0
	db 4,5,4,5,1,1,1,1,1,1,1,1,1,1,1,1
	db 5,4,5,4,5,4,5,4,5,4,5,4,4,4,5,4
	db 5,4,5,4,5,4,5,4,5,4,5,4,4,5,4,5
	db 5,4,5,4,5,4,5,4,5,4,5,4,4,4,5,4
	db 5,4,5,4,5,4,5,4,5,4,5,4,4,5,4,5
    db 5,4,5,4,5,4,5,4,5,4,5,4,4,4,5,4	 
map6:    
	db 4,5,4,5,4,5,4,5,4,5,4,5,4,5,4,5
	db 5,4,5,4,1,1,1,1,1,1,1,1,1,4,5,4
	db 4,5,4,1,0,0,0,0,0,0,0,0,0,1,4,5
	db 5,4,1,0,0,2,3,0,0,0,0,0,0,0,1,1
	db 4,5,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 5,4,1,0,0,0,0,0,0,0,0,0,0,0,0,0
	db 4,5,1,0,0,0,0,0,0,0,0,0,0,0,1,1
	db 5,4,1,0,0,0,0,0,0,0,0,0,0,1,5,4
	db 4,5,1,0,0,2,3,0,0,0,2,3,0,1,4,5
	db 5,4,1,0,0,0,0,0,0,0,0,0,0,1,5,4
	db 4,5,4,1,1,1,1,1,1,1,1,1,1,5,4,5
	db 5,4,5,4,5,4,5,4,5,4,5,4,4,4,5,4	   
end asm 