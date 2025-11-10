'!ORG=24576
' LoadSDBank , 320*256BMP and FL2Text Example 
' em00k dec20
'

#define NEX = 1 

#include <nextlib.bas>

border 0 

const fntbank1 = 36			' start at bank 36 as 320x256 L2 is 10 *8kb banks 
const fntbank2 = 37			' and starts at 24 : 24 + 10 = 34

' LoadSDBank ( filename$ , dest address, size, offset, 8k start bank )
' dest address always is 0 - 16384, this would be an offset into the banks 
' if you do not know the filesize set size to 0. If the file > 8192 the data
' is loaded into the next consecutive bank. Very handy 

LoadSDBank("font12.spr",0,0,0,36) 	' load the first font to bank fntbank1 
		
LoadSDBank("font3.spr",0,0,0,37) 		' load second font to fntbank2 
			
LoadSDBank("amiga3.bmp",0,0,1078,38) 		' loads a rotated 320*256BMP to bank 24 onwards 

NextReg($12,12)					'; ensure L2 bank starts at 16kn bank 12 (so bank 24 in 8kb) 
NextReg($14,0)					'; black transparency 
NextReg($70,%00010000)			'; enable 320x256 256col L2 
NextReg($7,3)					' 28mhz 
ClipLayer2(0,255,0,255)			'; make all of L2 visible 
nextrega($69,%10000000)			' enables L2 

dim runs as ulong

do 



	CopyToBanks(38,24,10)

	FL2Text(0,31,str(runs),fntbank2)

	for y = 0 to 31
		FL2Text(12,y,"HELLO FROM NEXTBUILD",fntbank2)
		WaitRetrace(5)
	next y 

	FL2Text(10,10,"AT 320x256 LAYER 2",fntbank1)

	runs = runs + 1 
	WaitRetrace(200)
	' loop for ever 
loop 

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