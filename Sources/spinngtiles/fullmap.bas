'#!v
'#!sna "h:\arrows.sna"
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
NextReg($14,0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)


dim r,g,b,fc as ubyte
dim r9,g9,b9 as uinteger
dim result as ubyte
dim v,col as ubyte 
dim f,x as uinteger

' reeset tilemap clip 
NextReg($1B,0)  	' x1
NextReg($1B,159) ' x2 
NextReg($1B,0)   ' y1 
NextReg($1B,255) ' y2 

'LoadSD("arrows.pal",$9200,512,0)
zx7Unpack(@arrows, $9200)

v=0 :
for x = 0 to 511 step 2
	NextRegA($40,x/2) ' reset pal index
	v=peek($9200+x)
	NextRegA($41,v)			' read first pal byte
	v=peek($9200+x+1)
	NextRegA($44,v)		
next 

'LoadSD("arrowst.spr",$6000,2048,0)	' tiles 
zx7Unpack(@arrowst, $6000)

'LoadSD("export.bin",$b400,768,0)
zx7Unpack(@export, $b400)

dim xr,xy,vv,xx,yy,k,car,st,subcar,cc,cof,tma as ubyte 
asm 
	ld hl,$4000
	ld de,$4001
	ld (hl),$40
	ld bc,80*40
	ldir 
end asm 
tma=1
border 0



xr=0 : yr = 0
car=0 : st=2
MMU8($3,44)
for x = 0 to 8192 : poke $6000+x,x : next 

pause 0
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
pause 1
border 0 
border 2 
for y=0 to 30 step 2
'for x=0 to 38 step 2 
updatemap2(0,y,yr,0)
'yr = yr + 2 : if yr=$20 : yr = 0 : endif 
'next x
yr = yr + 2 : if yr=$20 : yr = 0 : endif 
next y 
yr = yr + st : if yr=$20 : yr = 0 : endif 
	'pause 0
		key$=inkey$ 
	if key$="p"
		st=st+2 band 31
		yr = st : if yr=$20 : yr = 0 : endif 
		
	elseif key$="o"
		st=st-2 band 31
		yr = st : if yr>$20 : yr = $1e : endif 
	endif 
border 0
loop 
 

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
skipme:
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
	
arrows:
	ASM 
		incbin "arrows.pal.zx7"
		db 00,00,00,00
	end asm 
arrowst:
	ASM 
		incbin "arrowst.spr.zx7"
		db 00,00,00,00
	end asm 
export:
	asm 
		incbin "export.bin.zx7"
			db 00,00,00,00
	end asm 
	    