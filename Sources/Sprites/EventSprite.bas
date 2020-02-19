' Quick Sprite Example 2
' NextBuild (ZXB/CSpect)
' emook2018 - use keys 1 and 2 to mess with the sine wav (dirty!)
#include <nextlib.bas>
dim vecX,vecY,dir,interia,movecar as ubyte 
vecX=80:vecY=0: dir = 4 : d = 4
declare FUNCTION fSin(num as ubyte) as byte
declare FUNCTION fCos(num as ubyte) as byte
 
paper 0: border 0 : bright 0: ink 7 : cls 

dim frame,mx,my,yy,xx,count,f,x,y as ubyte 
dim offset as fixed 
DIM add as fixed=2.799
dim cevent,scount as ubyte 
cevent = 0 		
a= cast(uinteger,vecX): if vecX>250-10 : vecX = 249-10 : endif : if vecX<10 : vecX = 10 : endif 
b= cast(uinteger,vecY) : if vecY<3 : vecY = 3 : endif : if vecY>185 : vecY = 184 : endif 
poke 23607,60					' for cspect to set the font correctly

InitSprites(1,@Sprites)

' Reg $15 Bit	Function
' 7	Enable Lores Layer
' 6-5	Reserved
' 3-4	If %00, ULA is drawn under Layer 2 and Sprites; if %01, it is drawn between them, if %10 it is drawn over both
' 2	If 1, Layer 2 is drawn over Sprites, else sprites drawn over layer 2
' 1	Enable sprites over border
' 0	Enable sprite visibility

NextReg($15,%00001001)  	' Enable sprite visibility & Sprite ULA L2 order 
ShowLayer2(1)
UpdateSprite(120,120,0,0,0,0)		' show our sprite we init'd
'pause 0
x= 160
y = 160 
do  

	' input 
	
	' process 
		ReadEvents()
	
	
	' output 
		'UpdateBaddie()
		UpdateSprite(32+x,32+y,0,0,0,0)
	pause 1 
	
loop  


sub ReadEvents()

	' event can be 4 byte packets.
	' 0	 control 
	'   - 0 no movement 
	' 	- 1 right 
	' 	- 2 up
	'   - 3 left 
	'   - 4 down 
	'   
	' 1	 amount 
	'		- how many times to loop 0-255 
	'
	' 2  speed 
	'		- delay before next evet 
	'
	' 3  wait 
	' 	- wait before running next event 0 - 255 
	' 
	' current event counter, will be in sprite array 
	' cevent = 0 		
	
	
	
	if peek(@eventarray+1) = 0
		' first get the offset start 
		
		eventoffset = @eventarray+4+(cast(uinteger,cevent) *4)
		control = peek(eventoffset)
		amount  = peek(eventoffset+1)
		speed	  = peek(eventoffset+2)
		wait 	  = peek(eventoffset+3)
		
		' make a copy of our event bar wait 
		poke @eventarray+1,control 
		poke @eventarray+2,amount 
		poke @eventarray+3,speed
		
		
	else 
			control = peek(@eventarray+1)
			amount = peek(@eventarray+2)		' repeats 
			speed = peek(@eventarray+3)			' delay 
			
			if amount = 0 
				' set control to wait 
				'poke @eventarray+1,0
				if control = 5
					border 1
					cevent = cevent + 1 
					if cevent > peek(@eventarray)
						cevent = 0 
						scount=0
					endif 
					poke @eventarray+1,0
					print cevent
				else 
					border 2
					poke @eventarray+1,5
					poke @eventarray+2,speed
				endif 
			else 
				if control band 16 = 16
					x=x+fSin(scount)
					y=y+fCos(scount)
					scount=scount+1
				else 	
					if control band %1 = 1 ' right 
						x=x+1 
						 'vectMove(vecX,vecY,1)
						 'x=x+vecX
					endif 
					if control BAND 2 = 2 ' up 
						y=y-1
					endif 
					if control BAND 4 = 4 ' left 
						x=x-1

					endif
					if control BAND 8 = 8 ' diwb
						y=y+1 
					endif 
				endif 
				if x<16
					poke @eventarray+1,0
					amount = 1 
				elseif x>240
					poke @eventarray+1,0
					amount = 1 
				endif 	
				poke @eventarray+2,amount-1
			endif 

	endif 	
	print at 0,0;eventoffset 
	print at 2,0;x;" ";y
	

end sub 

eventarray:
asm 
RT	EQU 1
UP	EQU 2
LT	EQU 4 
DN	EQU 8
SI	EQU 16

	;  C A S W 
	DB 4,0,0,0 							;' nuimber of events , event active , blank , blank 
	DB LT,5,5,13			;' right for 10 loops delay 3, at end wait 20 
	DB SI,200,50,30
	DB DN+LT,5,20,1
	DB RT,5,20,1
	DB UP+LT,5,20,1
	
end asm 
FUNCTION fSin(num as ubyte) as byte


return PEEK (@sinetable+num)


sinetable:
asm
DB -2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
DB -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
DB -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1
DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
DB 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
DB 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DB 0,0,0,0,0,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
DB -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
DB -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2

end asm
END FUNCTION

FUNCTION fCos(num as ubyte) as byte
    return fSin(90-num) 
END FUNCTION

sub fastcall vectMove(vecX as ubyte, vecY as ubyte, vecDir as ubyte)
	' Requires dim vecX,vecY as ubyte 
	asm 
	;move sprite in direction defined in a
		
		
		;BREAK 
		; Vec movement by Allan Turvey, adapted by David Saphier
		;' ret address and load regs with arguments 
		;
		pop bc : ld d,a : pop af  :	ld e,a : 	pop af 
movdir	
		and 15 : ld hl,vectab : add a,l	: ld l,a : ld a,(hl) : add a,d : ld (._vecX),a 
		ld a,l : add a,4 : ld l,a : ld a,(hl) : add a,e : ld (._vecY),a : push bc
		ret 
		;20 byte lookup table for 16 directions + 4 for 90 degree rotation (for y axis)
vectab 
		defb 254,254,254,255,0,1,2,2,2,2,2,1,0,255,254,254,254,254,254,255

	;this table would allow 32 directions, change code to AND 31 and add 8 instead of 4 to l.
	;vectab 
	;defb 0,255,254,253,252,251,251,250,250,250,251,251,252,253,254,255,0,1,2,3,4,5,5,6,6,6,5,5,4,3,2,1,0,255,254,253,252,251,251,250	
	end asm 
end sub        

Sprites:
ASM 
Sprite1:
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $0F, $13, $13, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $0F, $0F, $0F, $0F, $13, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $60, $A0, $C0, $C0, $A0, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $60, $A0, $C0, $C0, $C0, $C0, $A0, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $60, $A0, $C0, $C0, $C0, $C0, $C0, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $60, $A0, $C0, $C0, $C0, $C0, $C0, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $60, $A0, $C0, $C0, $C0, $C0, $C0, $A0, $60, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $60, $60, $A0, $C0, $C0, $A0, $60, $60, $60, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $92, $EC, $CC, $EC, $EC, $A8, $A8, $A8, $92, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $88, $88, $EC, $EC, $EC, $EC, $EC, $EC, $A8, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $6D, $92, $88, $88, $EC, $EC, $EC, $EC, $A8, $6D, $92, $E3, $E3;
	db  $E3, $E3, $E3, $6D, $92, $88, $88, $88, $EC, $A8, $A8, $A8, $6D, $92, $E3, $E3;
	db  $E3, $E3, $E3, $6D, $92, $88, $88, $88, $88, $88, $A8, $A8, $6D, $92, $E3, $E3;
	db  $E3, $E3, $E3, $6D, $6D, $E3, $88, $88, $88, $A8, $A8, $E3, $6D, $6D, $E3, $E3;

end asm          