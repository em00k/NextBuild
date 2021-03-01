'!ORG=49152
'#!sna "h:\nbmodplay\LoadSDBank.snx"
'#!noemu 
'#copy=h:\xmas2020.nex
'!opt=4

#define NEX 1

' THIS REQUIRES THE LATEST BORIEL ZX COMPILER beta 2 ALONG WITH NEXTLIB v7
'


' xmas 2020 intro byte em00k, davidsaphier
' back ground image from google and tweaked / animated 

' mod engine by mike dailly https://github.com/mikedailly/mod_player

' music ESTRAKY, CRIMINAL, u4ia 

#include <nextlib.bas>

asm 
 ; we need to make sure stack is not set to below our code
 di 
 ld sp,$fffe
end asm 

dim sx, sy, p, down,chtoprt,toggle,togtop as ubyte 
dim ch,dir,curchar as uinteger
dim vecX,vecY,interia,refresh,rx,sly,spacetoggle,dtmp as ubyte 
dim sp,im,ctmp,atmp,ltmp,keydown,beat as ubyte 
dim kx,copoff as float
dim counter,x,bx as uinteger
dim tiley,scrolltileoff as ubyte 	
dim tilex as uinteger 
dim sctx as ubyte 

spacetoggle = 1     ' no beat detection on the scroller 

' you have from $c000 - $ffff 
' 24576 - 32767
' 32768 - 47000 is the mod player
' 
' There are two 256 byte buffers that NEED to stay in RAM for the DMA to plqy
' 
' 36608	MODSAMPLEPLAYBACK
' 36864	MODSAMPLEPLAYBACK2
'
' Might be able to move them in the future 

asm 
	nextreg $7,3							; 28mhz 
	nextreg $14,0						; trans black 
	nextreg $4A,0						; trans black 
	nextreg $4b,$e3						; sprite trans
	nextreg $68,%10010000					; ULA CONTROL REGISTER disable ula 
	NextReg $15,%00010011					; sprites on border, SUL 
	nextreg $08,%01001010   ; $50			; disable ram contention, enable specdrum, turbosound
	nextreg $12,18/2						; layer2 ram bank start (16kb banks)
	nextreg $70,%00010000					; 320x256x8bp
end asm        

SetCopper()

paper 0 : ink 7 : flash 0 : border 0 : cls 

' load the sprites for the scroller and snow and ensure Layer2 is max size 
ClipLayer2(0,255,0,255)
LoadSDBank("chars2.bin.spr",0,0,0,29)				' load in bank 29/30
asm : nextreg $52,29 : nextreg $53,30 : end asm 
InitSprites(63,$4000)								' init all sprites 
asm : nextreg $52,$0a : nextreg $52,$0b : end asm   ' pop back default banks 

' load the layer2 320*256 into ram - the bmp is rotated 
' 
LoadSDBank("bkrot4.raw",0,0,0,18)

' load mods into ram 
' 
LoadSDBank("mod_volume.dat.zx7",0,0,0,15)	' this is the volume table 
LoadSDBank("modplay.bin.zx7",0,0,0,31)		' this is the replayer 
LoadSDBank("pud.mod",0,0,0,65)				' 5 banks 
LoadSDBank("xmas4.mod",0,0,0,48)			' 3 banks 
LoadSDBank("xmas1.mod",0,0,0,32)			' 15 banks 
LoadSDBank("elf2.spr",0,0,0,95)			' 15 banks 
										'
NextReg($52,31)							' extract volume table 

zx7Unpack($4000,$8000)					' unpack from $4000 to $8000
										'
asm                                     
	nextreg $54,16						; extract mod player to banks 16 / 17 
	nextreg $55,17
	nextreg $52,15
end asm 

zx7Unpack($4000,$8000)

asm 
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
	
	ld a,65								; before a mod can be played the sample data must be 
	ld b,1								; converted to 8 bit unsigned. 
	call ModLoad							; bank 18 is first mod 
			
	ld a,48								; then the next mod 
	ld b,1
	call ModLoad

	ld a,32								; last mod set up 
	ld b,1			
	call ModLoad			
	call ModPlay							; init the mod for playback 
	nextreg $52,$0a 						; pop back default banks incase any of the next lines of code 
	nextreg $53,$0b						; require rom / sysvars being present
	
end asm 

' variables for the scroller 

bx = 32 
vecX=80:vecY=0: dir = 0 : d = 4 : refresh = 12 ' 255' 224
offset = 16 : toggle = 0 : togtop=0 : im = 2  

' set up some random snow positions 

for s = 0 to 80*6 step 6
	 
	poke uinteger @snowpos+cast(uinteger,s),int(rnd*310)   	' xx
	poke @snowpos+cast(uinteger,s)+2,int(rnd*255) 			' y
	poke @snowpos+cast(uinteger,s)+4,int(rnd*4)+1			' speed 

next s 	

' set up hw tilemap for the snow 

TileHW($40,$60,"snow12.til")

asm 

	ei 			; we ei just to ensure the code is stable 
	
end asm 

for s = 0 to 40*32 
	 
	poke uinteger $4000+cast(uinteger,s),int(rnd*8)   	' xx
	
next s 	

ShowLayer2(1)
NextReg($6B,%10100001)				' Tilemap Control on & on top of ULA,  80x32 

do 
	


	asm 
	;' this is the mode player tick, once per frame 
	di
	call ModTick
	nextreg $52,$0a 
	nextreg $53,$0b
	ei 
	end asm 
    
	' this detects the pattern beat 36257 is the pattern postion 
	atmp = ((peek(36257)) >>im) band 15
	if atmp<>ltmp
		ctmp = 7
		ltmp=atmp
		beat = 1 - beat 
		FDoTile16(12+(beat<<1),3,9,95)
		FDoTile16(13+(beat<<1),4,9,95)	
		
		FDoTile16(16+(beat<<2),16,11,95)	
		FDoTile16(17+(beat<<2),16,12,95)	
		FDoTile16(18+(beat<<2),17,11,95)	
		FDoTile16(19+(beat<<2),17,12,95)	
	endif 


	' decreases the palette on the beat 

	
	if beat=1
		FDoTile16(0,6,10,95)
		FDoTile16(1,7,10,95)
		FDoTile16(4,6,11,95)
		FDoTile16(5,7,11,95)
		FDoTile16(8,6,12,95)
		FDoTile16(9,7,12,95)
	elseif beat=0 
		FDoTile16(2+0,6,10,95)
		FDoTile16(2+1,7,10,95)
		FDoTile16(2+4,6,11,95)
		FDoTile16(2+5,7,11,95)
		FDoTile16(2+8,6,12,95)
		FDoTile16(2+9,7,12,95)
	endif	
	
	if ctmp>0
		ctmp=ctmp-1 
		out $0,ctmp
		asm 
			nextreg $43,%00010001
			nextreg $40,219
			swapnib 
			add a,%11111
			xor h 
			nextreg $44,a
			nextreg $44,0
		end asm 
	
	endif 
	' scroll tilemap 
	scrolltilemap()
	' call the scroller 
	Scroller()
	' update the snow 
	dosnow()

	ofx=ofx+1
    WaitRetrace(1)	
loop 

sub scrolltilemap()
	offval=Peek(@sinus+cast(uinteger,scrolltileoff))>>1
	scrolltileoff=scrolltileoff+1 : if scrolltileoff>512: scrolltileoff=0 : endif 
	tiley=tiley-1 
	if sctx = 1 
		tilex=tilex-cast(uinteger,offval)
	endif 
	sctx = 1 - sctx 
	asm 
	
		ld a,(._tiley)
		nextreg $31,a			; tilemap scroll y 
		ld a,(._tilex+1)
		nextreg $2f,a			; tilemap scroll x msb 
		ld a,(._tilex)
		nextreg $30,a			; tilemap scroll x lsb 
	end asm 

end sub 

sub Scroller()
	sp = 0 : curchar = 0 
	if spacetoggle=0 
		dtmp=ctmp 
	else
		dtmp=0
	endif 
	for x = 0 to 336+16 step 16
		vecY=Peek(@sinus+cast(uinteger,dir))>>(dtmp)			' this >>>(ctmp) is control by the beat, change to a const to stop
		chtoprt = peek(@message+cast(uinteger,ch+curchar))-32
		if chtoprt > 192 : ch = 0 : chtoprt = 0 : endif 
		UpdateSprite(x+(bx),212+vecY,sp,chtoprt,0,0)
		sp=sp+1 : curchar=curchar+1
		chp=Peek(@charpos+cast(uinteger,(x>>4)))
		dir = (dir+refresh ) band 255
		Poke(@charpos+cast(uinteger,(x>>4)),dir)
	next

	bx=bx-2 : if bx = -16 : bx = 0 :  ch = ch + 1 :  endif 
	a$=inkey 
	if keydown = 0 	
		if a$="1"
			ChangeMod(32)						' start at bank 72 for 15 banks
			keydown = 1
			im = 2 
		elseif a$="2"
			ChangeMod(48)						' start at bank 72 for 15 banks
			keydown = 1
			im = 3 
		elseif a$="3"
			ChangeMod(65)						' start at bank 72 for 15 banks
			keydown = 1
			im = 2 
		elseif a$="q"
			refresh = refresh + 1
			keydown = 1
		elseif a$="a"
			refresh = refresh -1
			keydown = 1
		elseif a$=" "
			spacetoggle = 1 - spacetoggle
			keydown = 1
		endif 	
	elseif a$="" and keydown = 1 
		keydown=0
	endif 

end sub 

sub ChangeMod(modbank as ubyte)

	asm 
		di 
		push ix 
		nextreg $54,4						; repalce slot 4/5 
		nextreg $55,5
		nextreg $52,$a						; and slot 2 
		ld b,0								; do no init samples again, reg A contains mod bank 
		call ModLoad
		call ModPlay							
		nextreg $52,$0a 
		nextreg $53,$0b
		pop ix 
		ei 
	end asm 

end sub 




sub TileHW(tileaddr as ubyte, tiledata as ubyte, tilefile$ as string)
	'LoadSD("snow1.nxp",@palbuff,511,0)		 this is include at palbuff now 
	
	NextReg($43,%00110000)	' Tilemap first palette
	for xp = 0 to 16 step 2
		NextRegA($40,xp/2) ' reset pal index
		v=peek(@palbuff+xp)
		NextRegA($41,v)			' read first pal byte
		v=peek(@palbuff+xp+1)
		NextRegA($44,v)		
	next 
	
		' tilemap 40x32 no attribute 256 mode 
	NextReg($6C,%00000000)				' Default Tilemap Attribute on & on top of ULA,  80x32 
	NextRegA($6E,tileaddr)				' tilemap data
	NextRegA($6F,tiledata)				' tilemap blocks 4 bit 
	NextRegA($68,%10000000)				' ULA CONTROL REGISTER
	NextReg($43,%00110000)				' Tilemap first palette
	NextReg($14,0)  						' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
	NextReg($4C,$0)						'  Transparency index for the tilemap
	ClipTile(0,160,0,255)				

	asm 
		nextreg $52,$a 
		ld hl,tiledata
		ld de,$6000
		ld bc,256
		ldir 
	end asm 
	
	asm 
		ld hl,$4000
		ld de,$4001
		ld (hl),0
		ld bc,80*40
		ldir 
	end asm 
end sub 

Sub DoTileHW(address as uinteger, xh as ubyte, yh as ubyte, wh as ubyte, hh as ubyte)
	' needs to be turned into asm 
	border 0 
	border 1
	for ah = 0 to hh 
	 for bh = 0 to wh 
		vv=peek(address+counter)
		updatemap(xh+bh,yh+ah,vv)
		counter=counter+1
	 next bh
	next ah
	border 0 
	counter=0
end sub 

sub fastcall updatemap(xx as ubyte, yy as ubyte, vv as ubyte)
	asm 
		pop hl : exx 
		;pop bc	; return address 
		ld hl,$4000
		
		ADD_HL_A	; add x 
 
		; hl = $4000+x
		pop de
		ld a,e
		ld e,40
		MUL_DE
		add hl,de
		pop af
		ld (hl),a
		;push bc 
		exx 
		push hl 
		end asm 
	'end asm 
	'y=y<<5
	'add=$4000+cast(uinteger,xx)+cast(uinteger,yy)*80
	'poke add,vv
end sub


sub SetCopper()
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
	db $43,%10010001
	db %11001000,1
	db $40,0								; this is the second bar 
	db $41,129
	
	db %11001000,16
	db $41,65
	db %11001000,32
	db $41,33
	db %11001000,48
	db $41,1
	db %11001000,64
	db $41,1
	
	db %11001000,140
	db $41,0
	
	db %11001000,254
	db $40,0			; this is top of the border 
	db $41,161
	db $ff,$ff
endcopperdata:

end asm							

	NextReg($62,%11000000)

end sub 
 
message:
asm 
	DB "                                   OK HELLO!   AND WELCOME TO MY ZX NEXT CHRISTMAS INTRO 2020!        IN THE BACKGROUND YOU WILL "
	DB "HEAR SOME AMIGA MODULES PLAYED BACK WITH MIKE DAILLYS EXCELLENT MOD ENGINE          YOU CAN PICK "
	DB "A DIFFERENT TUNE BY PRESSING KEYS 1 TO 3      THE MODS ARE   : 1  -  BY ESTRAKY / PARADOX     "
	DB "2 - XMAS BY CRIMINAL      3 - XMAS PUD BY U4IA         THE BACKGROUND WAS SOURCED FROM GOOGLE "
	DB "THEN TWEAK AND ANIMATED         THIS WAS ALL WRITTEN USING NEXTBUILD AND BORIELS ZX BASIC "
	DB "COMPILER AND FEATURES SOME OF THE NEW COMMANDS              A GOOD TEST I THINK!           "
	DB "  I AGAIN HAD GREAT INTENTIONS WITH THIS INTRO BUT ALAS IF I KEEP TWEAKING WHEN I HAVE TIME "
	DB "THEN THE NEW YEAR WILL BE WITH US ALREADY AND THIS WOULD END UP ON THE PILE OF I WILL DO THAT LATER               "
	DB " SO SORRY FOR ANY BUGS :)              "
	DB "HOPE YOU ALL HAVE A LOVELY CHRISTMAS AND FIND TIME TO BE WITH YOUR LOVED ONES AND HOPEFULLY 2021 WILL BRING "
	DB "US HAPPIER TIMES                 HELLO TO LUCY, LILY, LEON, ALEX AND SADIE AND P     LOTS OF LOVE      HELLO TO "
	DB " EVERYONE I KNOW INCLUDING YOU !            "
	DB " MERRY CHRISTMAS             EM00K 2020                          BYE!                                   " 			    
	DB 0 
end asm 

sub dosnow()
	asm 
		push ix 				; we are using IX and this needs to be preserved on exit
		ld ix,snowpos
		ld b,60
starloop:
		ld d,b 
		push bc 
		ld bc,$303B
		ld a,30
		add a,d 
		
		out (c),a 		; sp att 3  0-63 id 

		; sprite 
		;out (c), a			;12
		ld bc, $57			;10					; sprite control port 
		ld a,(IX+0) 			;19					; now send 4 bytes get x and send byte 1
		out (c), a          	;12					; att 0 
		ld a,(IX+2)			;19					; get y and send byte 2
		out (c), a 			;12					; att 1 
				
					; now palette offset and no rotate and mirrors flags send  byte 3 and the MSB of X 
		;ld a,(._ctmp) 
		;add a,d 
		;and %00001111
		;swapnib 
		;and (ix+2)
		;ld d,(ix+1)
		;and d 
		
		ld a,(IX+5)			;19
		and 1				;7
		or (ix+1) 				;4
		out (c), a 			;12					; att 2 
		ld a,59				;19					; Sprite visible and show pattern #0 byte 4
		or 192 				;7
		out (c), a			;12					; att 3 
		ld a,0				;19						; att 4 
		out (c), a			;12 

		ld de,6
		add ix,de 
		pop bc 
		djnz starloop 
		ld ix,snowpos
		ld b,60
moveloop:
		;BREAK 
		ld a,(._dir) 
		srl a 
		srl a 
		and %011
		ld d,a 
		ld a,(ix+0)					; msb of x  0x 
		add a,d 
	
		ld l,a						; get xx as word into hl 
		ld h,(ix+1)
		inc hl 						; inc 
		bit 0, h : jr nz,checkxoff 		; > 255
									; else ld a with h 
		
nabove320:										
		;ld a,(._ctmp)
		;add a,l 
		ld (ix+0),l 					; store lsb 
		ld (ix+1),h 					; store lsb 

		ld a,(ix+2)					; get y 
		add a,(ix+4)					; add y to speed 

		ld (ix+2),a 					; put back in array 
		ld de,6						; skip to next star block 
		add ix,de 
		djnz moveloop 
		jp endofstars
		
checkxoff:
		
		ld de,-100 : sbc hl,de : add hl,de 
		jr nc,resethl
		ld h,1
		jp nabove320
resethl:	ld h,0 : ld l,0 
		jp nabove320	
		
		
		
endofstars:
		pop ix 
		
	end asm 
end sub 	
	
snowpos:
asm 
snowpos:
	; xx, y, d, s
	ds 7*80,0
end asm 

charpos:
asm 
	ds 32,0
end asm 

sinus:
cosine:
asm 
;align 256
	cosine:
	DB  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB  0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2
	DB  2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4
	DB  4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7
	DB  8,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10
	DB  11,11,11,11,11,11,12,12,12,12,12,12,13,13,13,13
	DB  13,13,13,14,14,14,14,14,14,14,14,15,15,15,15,15
	DB  15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
	DB  15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
	DB  15,15,15,15,15,14,14,14,14,14,14,14,14,13,13,13
	DB  13,13,13,13,12,12,12,12,12,12,12,11,11,11,11,11
	DB  10,10,10,10,10,9,9,9,9,9,9,8,8,8,8,8
	DB  7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,4
	DB  4,4,4,4,4,3,3,3,3,3,3,2,2,2,2,2
	DB  2,2,1,1,1,1,1,1,1,1,1,0,0,0,0,0
	DB  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	DB  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	DB  0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2
	DB  2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4
	DB  4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7
	DB  8,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10
	DB  11,11,11,11,11,11,12,12,12,12,12,12,13,13,13,13
	DB  13,13,13,14,14,14,14,14,14,14,14,15,15,15,15,15
	DB  15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
	DB  15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
	DB  15,15,15,15,15,14,14,14,14,14,14,14,14,13,13,13
	DB  13,13,13,13,12,12,12,12,12,12,12,11,11,11,11,11
	DB  10,10,10,10,10,9,9,9,9,9,9,8,8,8,8,8
	DB  7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,4
	DB  4,4,4,4,4,3,3,3,3,3,3,2,2,2,2,2
	DB  2,2,1,1,1,1,1,1,1,1,1,0,0,0,0,0
	DB  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

end asm 
palbuff:
asm 
	;defs 512,0
	; palette for tilemap 
	db 00,$00,$BB,$01,$DB,$01,$FF,$01,$00,$00,$00,$00,$00,$00,$00,$00
end asm   

tiledata:
asm 
tiledata:
	; snow flakes for tilemap 
	db 00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$31,$30,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
end asm 