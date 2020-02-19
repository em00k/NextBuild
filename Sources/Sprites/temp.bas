rem rotating cube - freebasic

'#!v
'!sna "h:\sphere3.snx" -a

#INCLUDE <nextlib.bas>
#INCLUDE <memcopy.bas>
NextReg(8,$fe)								' no contention 
NextReg(7,2)									' 14mhz
NextReg($14,$0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
NextReg($40,0)   							' 16 = paper 0 on L2 palette index 
NextReg($41,$0)  							'	Palette Value 
NextReg($15,%00001011)
NextReg($4A,0)								' Trasnparent Fallback
NextReg($12,9)  							' layer2 rams   16kb banks 
NextReg($13,12)  							' layer2 shadow
NextReg($43,%00010001	)  							' layer2 shadow
PalUpload(@rainbow, 0,0)

paper 0 : ink 6: border 0 : cls
CLS256(1) : ShowLayer2(1) 
'pause 0

Dim R, R2, X, Y, C, D2, XA, YA, YT,L as integer
dim Color, b,cc,nc as ubyte 
nc = 0
R = 110 : R2 = R * R : YA = 192 / 2 : XA = 256 / 2

For Y = -R To R                              ' for all the coordinates near the circle
	YT = (Y * Y )
	'L = L*YT
  For X = -R To R                            ' which is under the sphere
    
		'D2 = (X) * (X) + (YT) >>1
		D2 = (X) * (X) + (YT) 
    If D2 <= R2 Then                         ' coordinate is inside circle under sphere
                                             ' height of point on surface of sphere above X,Y
     ' C = Sqr(R2 - D2) - (( X + Y) / 2) + 130  ' color is proportional; offset X and Y, and
      'C =(R2 - D2)  ' color is proportional; offset X and Y, and
      C =((R2) - (D2))  ' color is proportional; offset X and Y, and
			asm 
			 
				; use John Metcalfs fast sqr 
				; http://www.retroprogramming.com/2017/07/a-fast-z80-integer-square-root.html
				
			  ld a,h : 	ld de,0B0C0h : 	add a,e : jr c,sq7
				ld a,h : 	ld d,0F0h
			sq7:
				add a,d : jr nc,sq6 : res 5,d : db 254
			sq6:
				sub d : sra d : set 2,d : add a,d : jr nc,sq5
				res 3,d : db 254
			sq5: sub d : sra d : inc d : add a,d : jr nc,sq4
				res 1,d : db 254 
			sq4: : sub d : sra d : ld h,a : add hl,de
				jr nc,sq3 : ld e,040h : db 210
			sq3:
				sbc hl,de : sra d : ld a,e : rra
				or 010h : ld e,a : add hl,de : jr nc,sq2
				and 0DFh : db 218 
			sq2:
				sbc hl,de : sra d : rra : or 04h : ld e,a
				add hl,de : jr nc,sq1 : and 0F7h : db 218
			sq1:
				sbc hl,de : sra d : rra : inc a : ld e,a : add hl,de
				jr nc,sq0 : and 0FDh
			sq0:
				sra d : rra : cpl : ld hl,0 : 
				ADD_HL_A
				ld (._C),a
			END ASM 
			C = C + ( ( X + (Y)) / 2) + 100 
      Color = cast(ubyte,(C  ) )                     ' = color RGB(0, C, C)
				
			PlotL2(X+XA,Y+YA,Color)
    End If
  Next 
Next 

'Print at 23,0;"hit any key to end program"

do 
	pause 1 
	PalUpload(@rainbow, nc,b)
	NextReg($40,1) : NextReg($44,0) : NextReg($44,0)
	'if b>2 : 
	b=b-2 ': else : b = 254 : endif 
	cc=cc+1 ': b=b-2 : if b = 0 : b = 254 : endif 
	if cc=255
		if nc = 0
			nc = 32
		elseif nc = 32  
			nc = 16
		elseif nc = 16 
			nc = 0
		endif 
	endif 
loop 

End
rainbow: 
asm 
	incbin "rainbow.pal" 
	incbin "rainbow.pal" 
end asm       