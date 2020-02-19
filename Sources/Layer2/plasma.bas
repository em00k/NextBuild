rem rotating cube - freebasic

'#!v
'#!bin "h:\test.bin" -a

#INCLUDE <nextlib.bas>
#INCLUDE <memcopy.bas>
NextReg(8,$fe)								' no contention 
NextReg(7,3)									' 14mhz
NextReg($14,$0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
NextReg($40,0)   							' 16 = paper 0 on L2 palette index 
NextReg($41,$0)  							'	Palette Value 
NextReg($15,%00001011)
NextReg($4A,0)								' Trasnparent Fallback
NextReg($12,9)  							' layer2 rams   16kb banks 
NextReg($13,12)  							' layer2 shadow
NextReg($43,%00010001	)  							' layer2 shadow
PalUpload(@rainbow, 0,16)
function dist(byval dista as integer,byval distb as integer,byval distc as integer,byval distd as integer) as ubyte
	C=(((dista - distc) * (dista - distc)) + ((distb - distd) * (distb - distd)))
	asm 
		;BREAK 
		; use John Metcalfs fast sqr 
		; http://www.retroprogramming.com/2017/07/a-fast-z80-integer-square-root.html
		fastsqr: ld a,h : 	ld de,0B0C0h : 	add a,e : jr c,sq7 : ld a,h : 	ld d,0F0h
		sq7: add a,d : jr nc,sq6 : res 5,d : db 254 
		sq6: sub d : sra d : set 2,d : add a,d : jr nc,sq5 : res 3,d : db 254 
		sq5: sub d : sra d : inc d : add a,d : jr nc,sq4 : res 1,d : db 254 
		sq4: sub d : sra d : ld h,a : add hl,de : jr nc,sq3 : ld e,040h : db 210
		sq3: sbc hl,de : sra d : ld a,e : rra : or 010h : ld e,a : add hl,de : jr nc,sq2 : and 0DFh : db 218 
		sq2: sbc hl,de : sra d : rra : or 04h : ld e,a : add hl,de : jr nc,sq1 : and 0F7h : db 218
		sq1: sbc hl,de : sra d : rra : inc a : ld e,a : add hl,de : jr nc,sq0 : and 0FDh
		sq0: sra d : rra : cpl : ld hl,0 : ADD_HL_A : ld (._C),a
	END ASM 
		Return C
end function

paper 0 : ink 6: border 0 : cls
CLS256(1) : ShowLayer2(1) 
'pause 0
dim co(255) as ubyte 
dim si(255) as ubyte 
Dim R, R2,  D2, XA, YA, YT,L as integer
dim C as uinteger
dim offset,kx as float 
dim Color, cc,nc, W,ca, H,rx,X, Y,value,XX,YY,u,v,o,p,a,b as ubyte 
nc = 0 : offset = 16
R = 127 : R2 = R * R : H = 192 : W = 255
for kx = 0 to 6.28 step 0.1

 co(rx) = int(offset*cos(kx))
 si(rx) = int(offset*sin(kx))
 
 rx = rx + 1
 
next kx
rx=0 
For X = 0 To 15
        
				For Y = 0 To 15
			
							ca=co(X)-si(Y)
							
							C=cast(uinteger,ca)
							                   ' = color RGB(0, C, C)
							
							FOR YY=0 to 191 step 15
								FOR XX=0 to 254 step 15
								'C = C + ( ( XX + (YY)) ) 
								
							Color = cast(ubyte,(C  ) )  
							PlotL2(X+XX,Y+YY,Color)
								NEXT 
							NEXT 
							R=R+1
							rx=rx+1
        Next
Next

do 
	pause 1 
	PalUpload(@rainbow, nc,b)
	'NextReg($40,1) : NextReg($44,0) : NextReg($44,0)
	'if b>2 : 
	b=b-2 ': else : b = 254 : endif 
	cc=cc+1 ': b=b-2 : if b = 0 : b = 254 : endif 
	if cc=255
		if nc = 16
		'	nc = 32
		elseif nc = 32
		'	nc = 16
		'elseif nc = 42
		'	nc = 16
		endif 
	endif 
loop 

End
rainbow: 
asm 
	incbin "rainbow.pal" 
	incbin "rainbow.pal" 
end asm      