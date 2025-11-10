'!ORG=24576
'!HEAP=1024
'#!copy=h:\alien.nex
' over top game engine for NextBuild by em00k 
' Uses banked tiles, ayfx music interrupts
' v2 - with level sliding 

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
;	nextreg PERIPHERAL_3_NR_08,254				; disable contention 
	di 
end asm 


' -- Load block is where we load all out data files 
LoadSDBank("tiles.spr",0,0,0,36)				' sprites bank 32
LoadSDBank("player.spr",0,0,0,34)				' sprites bank 32
'#oadSDBank("game.afb",0,0,0,36) 				' load game.afb into bank 36
'#oadSDBank("vt24000.bin",0,0,0,38) 				' load the music replayer into bank 38
'#oadSDBank("thunder.pt3",0,0,0,39) 				' load music.pt3 into bank 39
LoadSDBank("font4.spr",0,0,0,40)				' load font into bank 40
' -- 

asm : nextreg $50,34 : nextreg $51,35 : end asm 		
InitSprites(64,$0000)									' init all sprites 
asm : nextreg $50,$ff : nextreg $51,$ff : end asm   	' pop back default banks 
LoadSDBank("nextsid.bin",0,0,0,33)
LoadSDBank("chiptune2.pt3",0,0,0,44)

asm 
	nextsid_init EQU 0x0000E098

	nextsid_set_waveform_A EQU 0x0000E07A
	nextsid_set_waveform_B EQU 0x0000E081
	nextsid_set_waveform_C EQU 0x0000E088
	nextsid_set_detune_A EQU 0x0000E056
	nextsid_set_detune_B EQU 0x0000E05A
	nextsid_set_detune_C EQU 0x0000E05E

	nextsid_play EQU 0x0000E007
	nextsid_stop EQU 0x0000E011
	nextsid_mode EQU 0x0000E2D7
	nextsid_pause EQU 0x0000E000
	nextsid_set_pt3 EQU 0x0000E025
	init EQU 0x0000E3F9
	nextsid_set_psg_clock EQU 0x0000E04E
	nextsid_vsync EQU 0x0000E08F

	nextreg $57,33					; put nextsid in place
	irq_vector	equ	65022			;     2 BYTES Interrupt vector
	stack	equ	65021				;   252 BYTES System stack
	vector_table	equ	64512		;   257 BYTES Interrupt vector table	
	startup:	di					; Set stack and interrupts
	;ld	sp,stack					; System STACK

	nextreg	TURBO_CONTROL_NR_07,%00000011	; 28Mhz / 27Mhz

	ld	hl,vector_table	; 252 (FCh)
	ld	a,h
	ld	i,a
	im	2

	inc	a							; 253 (FDh)

	ld	b,l							; Build 257 BYTE INT table
.irq:	ld	(hl),a
	inc	hl
	djnz	.irq					; B = 0
	ld	(hl),a

	ld	a,$FB						; EI
	ld	hl,$4DED					; RETI
	ld	(irq_vector-1),a
	ld	(irq_vector),hl

	ld	bc,0xFFFD					; Turbosound PSG #1
	ld	a,%11111111
	out	(c),a


	nextreg VIDEO_INTERUPT_CONTROL_NR_22,%00000100
	nextreg VIDEO_INTERUPT_VALUE_NR_23,255

	;ld	sp,stack					; System STACK
	ei

; Init the NextSID sound engine, setup the variables and the timers.

	ld	de,0						; LINE (0 = use NextSID)
	ld	bc,192						; Vsync line
	call	nextsid_init			; Init sound engine

	; Setup a duty cycle and set a PT3.

	call	nextsid_stop	; Stop playback
	
	; channel b 
	ld	hl,test_waveformb
	ld	a,32-1		; 16 BYTE waveform
	call	nextsid_set_waveform_B

	ld	hl,16		; Slight detune
	call	nextsid_set_detune_B

	; channel a 
	ld	hl,test_waveforma
	ld	a,32-1		; 16 BYTE waveform
	call	nextsid_set_waveform_A

	ld	hl,3		; Slight detune
	call	nextsid_set_detune_A

	nextreg $50,44
	nextreg $51,45
	
	ld	hl,$0000 	; Init the PT3 player.
	ld	a,44		; Bank8k a 1st 8K
	ld	b,45		; Bank8k b 2nd 8K
	
	call	nextsid_set_pt3

	call	init		; VT1-MFX init as normal

	nextreg $50,$ff 
	nextreg $51,$ff 
	nextreg $57,33

	call	nextsid_play	; Start playback
	
	end asm 


'InitSFX(36)							            ' init the SFX engine, sfx are in bank 36
'InitMusic(38,39,0000)				            ' init the music engine 38 has the player, 39 the pt3, 0000 the offset in bank 34
'SetUpIM()							            ' init the IM2 code 

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

Dim bullets(16,5) as ubyte

const MLEFT  as ubyte = 0 
const MRIGHT as ubyte = 1 
const MUP	as ubyte = 2 
const MDOWN	as ubyte = 3 
const MSTILL	as ubyte = 4

'intro()											' show intro screen 

plx = 14<<4 : ply = 9<<4 : playerattrib3 = 0		' set some variables 
worldpoint=37 : playerframbase = 0 
asm 

call	nextsid_vsync
end asm 
DrawMap()										' draw inital map 

' main game loop 

do 
    asm 
    call	nextsid_vsync
    end asm 
'    WaitRetrace2(1)		
   '; border 2
    ReadKeys()
	CheckCollision()
    UpdatePlayer()
   '; border 0
loop 


' -- subs 

Sub CheckCollision()
	
	' a robust collision routine for our player against the tilemap

	dim sp,add as uinteger
	dim plxc,plyc,tilehit,bottile,toptile,righttile,lefttile,tile as ubyte 
	
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
        worldpoint=worldpoint+1 : plx = 2 : DrawMapSlide(0)
    elseif plx = 0 
        worldpoint=worldpoint-1 : plx = 254-14 : DrawMapSlide(1)
    elseif ply>192
        worldpoint=worldpoint+8 :  DrawMapSlide(2)
    elseif ply=0
        worldpoint=worldpoint-8 : DrawMapSlide(3)
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
    'PlaySFX(5)
        firepressed = 1 
        firetimer = 5
        playerframbase = 6 
    endif 
    if GetKeyScanCode()=KEYR
    '    #'oadSDBank("tiles.spr",0,0,0,32)            ' so we can change the tiles on the fly and reload to test 
        DrawMap()
        
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

sub DrawMapSlide(type as ubyte)

	dim sp,worldmap,add as uinteger
	dim p,scrl,x,y as ubyte 
    
    worldmap = peek(@world+worldpoint-1)-1              ' get the current map from the worldmap table -1 

    worldoffset = worldmap * 192                        ' each screen is 192 in size 

    mapbuffer = @map1+worldoffset                       ' set the offset 

    
    if type = 0                                         ' slide in from right 
        for x = 0 to 15
        '    WaitRetrace(1)
            sp = x : scrl=scrl+16 : ScrollLayer(scrl,0)         ' sp is the tile we start at, scrl = X scroll offset 
            for y = 0 to 11                                     ' we will draw a vertical line on the right
                p = peek(mapbuffer+sp)
                DoTileBank16(x,y,p,36)
                sp = sp + 16
            next y 
            plx = plx - 16 : UpdatePlayer()                     ' move player with screen scroll 
            'WaitRetrace(1)
        next x 
    elseif type = 1                 ' slide in from left 
        sp = 15 
        for x = 0 to 15
        '    WaitRetrace(1)
            sp = 15-x : scrl=scrl-16
            ScrollLayer(scrl,0)
            for y = 0 to 11                                     ' we will draw a vertical line on the right
                p = peek(mapbuffer+sp)
                DoTileBank16(15-x,y,p,36)
                sp = sp + 16
            next y 
            plx = plx + 16 : UpdatePlayer()
            'WaitRetrace(1)
        next x 
    elseif type = 2                 ' slide in from bottom 
        scrl = 0
        for y = 0 to 11 
        '    WaitRetrace(1)
            scrl=scrl+16
            ScrollLayer(0,scrl)
            for x = 0 to 15
                p = peek(mapbuffer+sp)
                DoTileBank16(x,y,p,36)
                sp = sp + 1
            next x 
            ply = ply - 16 : UpdatePlayer()
            'WaitRetrace(1)
        next y 
    elseif type = 3                 ' slide in from top 
        scrl = 192 : sp = 160+16
        for y = 0 to 11           
        '    WaitRetrace(1)
            scrl=scrl-16 : ScrollLayer(0,scrl)
            for x = 0 to 15
                p = peek(mapbuffer+sp)
                DoTileBank16(x,11-y,p,36)
                sp = sp + 1
                next x 
            ply = ply + 16 : UpdatePlayer()
            sp = sp - 32
        next y 
    endif 

    '    ClipLayer2(0,0,0,0)									' hide everything so we dont see the screen
'    ClipSprite(0,0,0,0)									' updating
	' for y = 0 to 11 
	' 	for x = 0 to 15
	' 		p = peek(mapbuffer+sp)
	' 		DoTileBank16(x,y,p,32)
	' 		sp = sp + 1 
      
	' 	next x 
    ' next y
'    ClipLayer2(0,255,0,191)								' unlclip Sprites and Layer 2 
'    ClipSprite(0,255,0,191) 

    L2Text(0,0,str(worldmap),40,0)
    
end sub 

sub DrawMap()

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
			DoTileBank16(x,y,p,36)
			sp = sp + 1 
		next x 
    next y
    ClipLayer2(0,255,0,191)								' unlclip Sprites and Layer 2 
    ClipSprite(0,255,0,191) 
    L2Text(0,0,str(worldmap),40,0)
    
end sub 

sub intro()
    'WaitKey()       
    'EnableSFX							            ' Enables the AYFX, use DisableSFX to top
    'EnableMusic 						            ' Enables Music, use DisableMusic to stop 
    'PlaySFX(0)                                      ' Plays SFX 
    CLS256(0)   
    L2Text(0,0,"THIS IS A QUICK DEMO WRITTEN",40,0)
    L2Text(0,1,"USING NEXTBUILD AND BORIELS ",40,0)
    L2Text(0,2,"ZXBASIC COMPILER",40,0)
    L2Text(0,3,"USE WASD TO MOVE, SPACE FIRE",40,0)
    L2Text(0,5,"ANY KEY TO CONTINUE",40,0)
    asm 
    nextsid_vsync EQU 0x0000E07E
    call	nextsid_vsync
    end asm 
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


asm 
test_waveforma:
 db 128,000,128,000,128,000,128,000
 db 128,000,128,000,128,000,128,000 
 db 128,000,128,000,128,000,128,000
 db 128,000,128,000,128,000,128,000
end asm 

asm 
test_waveformb:
 db 128,000,128,000,128,000,128,000
 db 128,000,128,000,128,000,128,000 
 db 128,000,128,000,128,000,128,000
 db 128,000,128,000,128,000,128,000
end asm 


asm 
test_waveformc:
 db 128,000,128,000,128,000,128,000
 db 128,000,128,000,128,000,128,000 
 db 128,000,128,000,128,000,128,000
 db 128,000,128,000,128,000,128,000
end asm 


asm 
noduty_waveform:
 db 128,128,128,128,128,128,128,128
 db 128,128,128,128,128,128,128,128 
 db 128,128,128,128,128,128,128,128
 db 128,128,128,128,128,128,128,128
end asm 
