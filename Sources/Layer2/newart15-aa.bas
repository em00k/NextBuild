rem rotating cube - freebasic

'#!v
'!bin "h:\test.bin" -a

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
CLS256(0) : ShowLayer2(1) 
'pause 0
dim co(255) as byte 
dim si(255) as byte 
'Dim R, R2,  D2, XA, YA, YT,L as integer
dim C as uinteger
dim offset,kx as float 
dim ca as byte 
dim Color, cc,nc, W, H,rx,X, Y,value,XX,YY,u,v,o,p,a,b,XO,YO,t,r as ubyte 
nc = 0 : offset = 64
R = 127 : R2 = R * R : H = 192 : W = 255
ClipLayer2(00,254,0,191)
for kx = 0 to 6.28*5 step 0.05

 co(rx) = int(offset*cos(kx))
 si(rx) = int(offset*sin(kx))>>2
 'print co(rx),si(rx)   ',ZA	
 rx = rx + 1
 if rx=0 : kx = 6.28*5 : endif 
next kx
rx=2 : XO =0 

For X = 0 To W-1 
        
				For Y = 0 To H-1 
					ca=(co(X)+si(Y)) : 
					C=cast(uinteger,ca)*2 : 
					C = C - ( cast(uinteger,( (X) + (YO/8))) ) : 
					Color = cast(ubyte,(C  ) )  
					
					PlotL2(cast(ubyte,(X)),cast(ubyte,(Y)),Color)
					'PlotL2(cast(ubyte,(X)),127-cast(ubyte,(Y)),Color)
					'PlotL2(cast(ubyte,(X)),128+cast(ubyte,(Y)),Color)
					YO=YO+1' : if YO>191 : YO = 0 : ENDIF 
        Next
				'XO=XO+1 ': if XO>126 : XO = 0 : ENDIF 		
Next

do 
	pause 1 
	PalUpload(@rainbow, nc,b)
	'NextReg($40,0) : NextReg($44,0) : NextReg($44,0)
	'if b>2 : 
	b=b-2 ': else : b = 254 : endif 
	cc=cc+2 ': b=b-2 : if b = 0 : b = 254 : endif 
' 	if cc=255
' 		if nc = 16
' 			nc = 32
' 		elseif nc = 32
' 			nc = 0
' 		elseif nc = 0
' 			nc = 16
' 		endif 
' 	endif 
loop 

End
rainbow: 
asm 
	incbin "rainbow.pal" 
	incbin "rainbow.pal" 
end asm          