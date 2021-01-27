'!ORG=24576
' em00k 2021 part of Nextbuild 
' Interrupt Example Music + SFX 
'#!copy=h:\im2.nex

asm : di : end asm 
									' These must be set before including the nextlib
#define NEX 						' If we want to produce a file NEX, LoadSDBank commands will be disabled and all data included
#define IM2							' This is required if you want to use IM2 and v7 Layer2 commnds, comment out to find out why

#include <nextlib.bas>				' now include the nextlib library
#include <keys.bas>					' we are using GetKeyScanCode, inkey$ is not recommened when using our own IM routine
									' (infact any ROM routine that may requires sysvars etc should be avoided)



' border black of course 

border 0 : paper 0 : ink 0 : cls 

' LoadSDBank ( filename$ , dest address, size, offset, 8k start bank )
' dest address 0 - 16384, this would be an offset into the bank 
' if you do not know the filesize set size to 0. If the file > 8192 the data
' is loaded into the next consecutive bank. Very handy 
' offset is start from an offset in the source, vars will not be capture into a NEX
 
LoadSDBank("font15.spr",0,0,0,38) 				' load a bitmap font into bank 38
LoadSDBank("font14.spr",0,0,0,39) 				' load a bitmap font into bank 39
LoadSDBank("game.afb",0,0,0,36) 				' load an ayfx afb bank into bank 36
LoadSDBank("music.pt3",0,0,0,34) 				' load music.pt3 into bank 34
LoadSDBank("four_elements.pt3",0,0,0,35) 	' load another pt3 into bank 34 at offset 4096
LoadSDBank("vt24000.bin",0,0,0,33) 				' load the music replayer into bank 33
LoadSDBank("nb32.nxt",0,0,0,40) 				' 16kb spr for the tiles in banks 40/41


asm 
    NextReg $12,9					; ensure L2 bank starts at 16kb bank 12 (so bank 24 in 8kb) 
    NextReg $13,12					; ensure L2 bank starts at 16kb bank 12 (so bank 24 in 8kb) 
    NextReg $14,0					; black transparency 
    nextreg $69,%10000000			; enables L2 
    NextReg $15,%00000000					; Display Layer Order, ULA SPRITES LAYER 2 
    NextReg $7,3 					; 28mhz 
end asm 


const fntbank1 as ubyte = 38		' for readability 
const fntbank2 as ubyte = 39		' for readability 
dim ci,keydown,music,timer,tt,flip,lastfx as ubyte 		' dim some global bytes 

keydown = music						' var music would be omitted if using compiler optimisations, so we can fool the compiler not to do this
x=1 : y = 1 : tt=0
InitSFX(36)							' init the SFX engine, sfx are in bank 36
InitMusic(33,34,0000)				' init the music engine 33 has the player, 34 the pt3, 0000 the offset in bank 34
SetUpIM()							' init the IM2 code 
EnableSFX							' Enables the AYFX


ClipLayer2(0,255,0,255)				'; make all of L2 visible 
CLS256(0)							' clear layer 2

ShowMessages()

do 

	WaitRetrace2(1)								' use instead of pause 1 '
    
	if GetKeyScanCode()=KEYSPACE and keydown = 0 

      	PlaySFX(lastfx)				' PlaySFX 22
		lastfx = lastfx + 1 : if lastfx > 32 : lastfx = 0 : endif 
	  	keydown=1
	  	L2Text(0,5,"BOING ",fntbank2,255)
	elseif GetKeyScanCode()=KEY1 and keydown = 0 
		InitMusic(33,34,0)			' init the music player with tune in bank 34 offset 0
		EnableMusic
		keydown=1
		L2Text(10,5,"PLAYING TUNE 1",fntbank2,255)
	elseif GetKeyScanCode()=KEY3 and keydown = 0 
		DisableMusic
		L2Text(10,5,"MUSIC PAUSED  ",fntbank2,255)
	elseif GetKeyScanCode()=KEY2 and keydown = 0 
		InitMusic(33,35,0)		' init the music player with tune in bank 34 offset 4096 
		EnableMusic
		keydown=1
		L2Text(10,5,"PLAYING TUNE 2",fntbank2,255)
	elseif GetKeyScanCode()=KEY4 and keydown = 0 
		EnableMusic
		keydown=1
		L2Text(10,5,"CONT MUSIC    ",fntbank2,255)
	elseif GetKeyScanCode()=KEY5 and keydown = 0 
        ' for testing into ram wgile ints are on ' 
		LoadSD("screen.scr",$4000,6912,0)
		keydown=1
	elseif GetKeyScanCode()=KEY6 and keydown = 0 
		LoadSD("screen2.scr",$4000,6912,0)
		keydown=1

	elseif GetKeyScanCode()=0 and keydown = 1 
		L2Text(0,5,"      ",fntbank1,255)
	  	keydown=0 
    endif 

	if timer = 5
		' in a real world situation you would not normall draw these tiles so often
		' but it's something to do while the interrupt is running. 
		' '
		for y = 4 to 8
			for x = 0 to 15 
				DoTileBank16(x,y,tt,40)			' draw tile = 0 to 256, bank 40 is the base bank
				tt=tt+1 						' increase tile number
			next x				
		next y 		
		tt = tt - 64
		timer = 0 
	else 
		timer = timer + 1
	endif 

loop 


CallbackSFX()

Sub ShowMessages()

	restore Messages

	read y,message$
	while message$<>"*"
		L2Text(0,y,message$,fntbank1,0)
		read y,message$
	wend 

	Messages:
	Data 0,"INTERRUPT EXAMPLE"
	Data 1,"1-TUNE 1       2-TUNE 2"
	Data 3,"3-PAUSE MUSIC  4-CONT-MUSIC"
	Data 4,"SPACE PLAY SFX"
''	Data 20,"LINE BELOW SHOWS TIME TAKEN"
''	Data 21,"FOR THE INTERRUPT ROUTINE"
	Data 0,"*"

end sub 

Sub fastcall CopyToBanks(startb as ubyte, destb as ubyte, nrbanks as ubyte)
 	asm 
		exx : pop hl : exx 
		;ld a,40
		;dw $92ed : DB $57			; sample 1 in bank 40
		; a = start bank 			

		call _checkints
		di 
		ld c,a 						; store start bank in c 
		pop de 						; dest bank in e 
		ld e,c 						; d = source e = dest 
		pop af 
		ld b,a 						; number of loops 

		copybankloop:	
		push bc : push de 
		ld a,e : nextreg $50,a : ld a,d : nextreg $51,a 
		ld hl,$0000
		ld de,$2000
		ld bc,$2000
		ldir 
		pop de : pop bc
		inc d : inc e
		djnz copybankloop
		
		nextreg $50,$ff : nextreg $51,$ff
		ReenableInts
		exx : push hl : exx : ret 

 	end asm  
end sub  
