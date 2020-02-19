'#!v
'#!sna "h:\mouse2.sna"
'!bin "h:\test.bin" -a
'#!noemu

#include <nextlib.bas>
NextReg(8,$fe)								' no contention 
NextReg(7,2)									' 14mhz
'NextReg($43,$0)							' ULA palette 
'NextReg($14,$0)  						' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
'NextReg($40,0)   						' 16 = paper 0 on L2 palette index 
'NextReg($41,$0)  						'	Palette Value 

' (R/W) 0x6B (107) => Tilemap Control
' bit 7 = 1 to enable the tilemap
' bit 6 = 0 for 40x32, 1 for 80x32
' bit 5 = 1 to eliminate the attribute entry in the tilemap 
' bit 4 = palette select
' bits 3-2 = Reserved set to 0
' bit 1 = 1 to activate  512 tile mode
' bit 0 = 1 to force tilemap on top of ULA
NextReg($6B,%10100001)				' tilemap on & on top of ULA,  80x32 

NextReg($6E,$40)							' (R/W) 0x6E (110) => Tilemap Base Address 0 = $4000
NextReg($6F,$60)							' (R/W) 0x6F (111) => Tile Definitions Base Address
NextReg($43,%00110000)	
NextReg($15,%00000001)	
NextReg($14,0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
dim vecX,vecY,dir as ubyte 
dim ftadd as float
dim r,g,b,fc,vecDir,sprupdate as ubyte
dim r9,g9,b9 as uinteger
dim result,keypress as ubyte
dim v,col as ubyte 
dim f,x as uinteger
dim yoff,p,c as ubyte
vecDir=1: vecX=2 : vecY=3
BORDER vecDir: border vecX : border vecY : border 0
paper 0 : ink 0 : cls 
' reeset tilemap clip 
NextReg($1B,0)  	' x1
NextReg($1B,159) ' x2 
NextReg($1B,0)   ' y1 
NextReg($1B,255) ' y2 

LoadSD("growbox.pal",$9200,512,0)

v=0 :
for x = 0 to 511 step 2
	NextRegA($40,x/2) ' reset pal index
	v=peek($9200+x)
	NextRegA($41,v)			' read first pal byte
	v=peek($9200+x+1)
	NextRegA($44,v)		
next 
'; 0 
'

MMU8(7,32)
LoadSD("arrows.spr",$e000,2048,0)	' tiles 
MMU8(7,33)
LoadSD("growbox2.spr",$e000,2048,0)	' tiles 
MMU8(7,1)
LoadSD("export.bin",$b400,768,0)

LoadSD("emook.spr",$c000,16384,0)
'LoadSD("main.spr",$c000,16384,0)
InitSprites(64,$c000)

dim xr,xy,vv,xx,yy,k,imgfrm,car,st,subcar,cc,cof,tma,sprwob as ubyte 
asm 
	ld hl,$4000
	ld de,$4001
	ld (hl),$40
	ld bc,80*40
	ldir 
end asm 
tma=1
border 0
c=0
for y= 0 to 3
for x = 0 to 15
UpdateSprite(32+(x<<4),32+(y<<4),c,c,0,0)
c=c+1 : 
next x
next y 
c=vecY
xr=0 : yr = 0
car=0 : st=2 ' 10 
' 1e moving right
' 20 still 
' 22 moving left 
sprwob=1
do 

' for f=0 to 767
' 	car=peek($b400+cast(uinteger,f	))
' 	'col=peek($b400+cast(uinteger,f	)+1000)
' 	updatemap(xr,yr,car,col+st)
' 	xr=xr+1
' 	if xr > 39 'or k=13
' 		yr=yr+1
' 		xr=0
' 	endif  
' 	if yr=24 then f=2561
' next 

' 			 next 
	if wallupdate=2
		for y=0 to 30 step 2
			'for x=0 to 38 step 2 
			updatemap2(0,y,yr band 31,0)
			'yr = yr + 2 : if yr=$20 : yr = 0 : endif 
			'next x
			yr = yr + 2 ': if yr>=$20 : yr = 0 : endif 
		next y 
		wallupdate=0
		
		
		yr = yr + st ': if yr>=$20 : yr = 0 : endif 
	endif 
	
	
	
	key$=inkey$ 
	if key$="p" and keypress=0
		st=st+2 'band 31
		yr = st ': if yr=$20 : yr = 0 : endif 
		keypress=1
	elseif key$="o" and keypress=0
		st=st-2 'band 31
		yr = st ': if yr>$20 : yr = $1e : endif 
		keypress=1
	elseif key$="e" and keypress=0
		ftadd=ftadd+0.5
		keypress=1
	elseif key$="w" and keypress=0
		sprwob=sprwob+1
		keypress=1
	elseif key$=" " and keypress=0
	
		if tileon=1
		'	NextReg($6B,%00100001)				' tilemap on & on top of ULA,  80x32 
			tileon=0
			MMU8(7,33)
 			asm 
 				;BREAK 
				push hl
 				ld hl,$e000
 				ld de,$6000
 				ld bc,2047
 				ldir
				pop hl 
 			end asm 
 		else
		'	NextReg($6B,%10100001)	
			tileon=1
 			MMU8(7,32)
 			asm 
				push bc 
 				ld hl,$e000
 				ld de,$6000
 				ld bc,2047
 				ldir
				pop bc 
 			end asm 
 			MMU8(7,1)
		endif 
		keypress=1
	else ' if key$="" and  =1
		keypress=0
	endif 

'	NextRegA($31,yoff)
	yoff=yoff+p>>4 : c=0 : i = 2
	
	if sprupdate>1
		for y= 0 to 3
			for x = 0 to 15
			vecDir=p
			vectMove(x<<3,y<<3,vecDir) 'band 15
			'UpdateSprite(32+(vecX),32+(vecY),c,c,0,0)
			UpdateSprite(64+(cast(ubyte,x)<<2)+cast(ubyte,vecX),64+(y<<2)+vecY,c,c,0,0)
			' p=p+2 band 31 : c=c+1 :
			 p=p+sprwob : c=c+1 :' imgfrm=imgfrm+1
			' if imgfrm>6 : imgfrm = 2 : endif 
			
			next x
			
			fp=fp+ftadd : p = int fp>>2
			
		next y 
		: fp=fp+ftadd : p = int fp>>2
	sprupdate=0
	'fw=fw+1.3 : st = (int fw)>>4
	endif 
	sprupdate=sprupdate+1 : wallupdate=wallupdate+1
	pause 1 : NextReg(7,2)									' 14mhz
loop 
 
sub fastcall vectMove(byval vecX as ubyte,byval vecY as ubyte,byval vecDir as ubyte)
	' Requires dim vecX,vecY as ubyte 
	asm 
	;move sprite in direction defined in a
		;BREAK 
		; Vec movement by Allan Turvey, adapted by David Saphier
		;' ret address and load regs with arguments 
		;
		pop ix : ld d,a : pop af  :	ld e,a : 	pop af 
movdir	
		and 31 : ld hl,vectab : add a,l	: ld l,a : ld a,(hl) : add a,d : ld (._vecX),a 
		ld a,l : add a,8 : ld l,a : ld a,(hl) : add a,e : ld (._vecY),a : push ix 
		ret 
		;20 byte lookup table for 16 directions + 4 for 90 degree rotation (for y axis)
;vectab 
	;	defb 254,254,254,255,0,1,2,2,2,2,2,1,0,255,254,254,254,254,254,255

	;this table would allow 32 directions, change code to AND 31 and add 8 instead of 4 to l.
	vectab 
	defb 0,255,254,253,252,251,251,250,250,250,251,251,252,253,254,255,0,1,2,3,4,5,5,6,6,6,5,5,4,3,2,1,0,255,254,253,252,251,251,250	
	end asm 
end sub     

sub fastcall updatemap(xx as ubyte, yy as ubyte, vv as ubyte, col as ubyte)
	asm 
		
		pop ix	; return address 
		ld hl,$4000+160*2

		add a,a 
		ADD_HL_A	; add x 
		; hl = $4000+x
		pop de
		ld a,e
		ld e,80
		MUL_DE
		add hl,de
		pop af
		;cp 95
		;jr c,skipme
		;BREAK
		ld (hl),a
		inc hl 
		pop af
		SWAPNIB
		and %11110000
		ld (hl),a
		push ix 
		end asm 	
end sub   

sub fastcall updatemap2(xx as ubyte, yy as ubyte, vv as ubyte, col as ubyte)
	asm 
		;BREAK 
		pop bc 										; return address 
		ld hl,$4000  				; start tilemap address 

		;add a,a 									; double x?
		ADD_HL_A									; add x 
															; hl = $4000+x
		pop de										; get y
		ld e,40
		MUL_DE										; mul x*y
		add hl,de									; 
		pop af			; get block from vv
		;cp 95
		;jr c,skipme
		;BREAK
		push bc			; save bc to stack 
		ld b,39		; b counter
skipme:
		ld (hl),a   ; X-
		push af			; save block 
		inc hl			; next address 
		inc a 
		ld (hl),a   ; -X
		dec hl 			 
		ld a,40
		ADD_HL_A
		pop af 
		add a,$20
		ld (hl),a 
		inc hl 
		inc a 
		ld (hl),a   ; -X
		ld de,40
		sbc hl,de 	; --X
		sub $20
		cp $20
		jr z,reseta 
		jr noreseta
reseta:
	  xor a
noreseta:		
		djnz skipme
		pop bc 
		pop af
		;SWAPNIB
		;and %11110000
		;ld (hl),a
		push bc 

		end asm 	
end sub  

tilemaptest:
	asm 
		DB $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F 
		DB $20,$21,$22,$23,$24,$25,$26,$27,$28,$29,$2A,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$3A,$3B,$3C,$3D,$3E,$3F
  end asm           