'#!bin "h:\temp.bin"
#include <nextlib.bas>
NextReg(8,$fe)								' no contention 
NextReg($43,$1)								' ULANext enabled 
NextReg(7,2)									' 14mhz
'NextReg($43,$0)								' ULA palette 
NextReg($14,$0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
NextReg($40,0)   						' 16 = paper 0 on L2 palette index 
NextReg($41,$0)  							'	Palette Value 
 
'NextReg($12,9)  							' layer2 rams   16kb banks 
'NextReg($13,12)  							' layer2 shadow
NextReg($15,%00001011)
NextReg($42,255)							' ULANext number of inks : 255 127 63 31 15 7 
NextReg($4A,0)							' ULANext number of inks : 255 127 63 31 15 7 
NextReg($22,0)							' ULANext number of inks : 255 127 63 31 15 7 
NextReg($4A,0)							' ULANext number of inks : 255 127 63 31 15 7 
CLS256(0)
paper 0 : ink 6: border 0 : cls


dim r,g,b,fc as ubyte
dim r9,g9,b9 as uinteger
dim result as ubyte
'CLS256(256)

' rgb to 9bit 

LoadBMP("car.bmp")
ShowLayer2(1)
' palette starts at 54 $36
LoadSD("car.bmp",@palette,1024,54)
'LoadSD("cond.pal",@palette,768,0)

Remap9bit()
'Remap()
PointL2(0,0)
PlotL2(10,10,result)
a=5
fc=5
do
	'Remap9bit()
	pause 1
	'Remap()
	keyin=peek(23560)
	if keyin = code "1"
		for a=5 to 10
		RemapR(a)
		pause 4
		next 
	elseif keyin = code "2"
		for a=5 to 10
		RemapG(a)
		pause 4	
		next 
	elseif keyin = code "3"
		for a=5 to 10
		RemapB(a)
		pause 4
		next 
	elseif keyin = code "5"
		fc=fc+1 : if fc = 9 : fc = 5: endif 
		Remap2(fc)
		pause 1	
		'print fc
	elseif keyin = code "7"
		for a=5 to 10
		Remap9bitFade(a)
		pause 4	
		next 
	elseif keyin = code "4"
		fc=fc-1 : if fc = 0 : fc = 253: endif 
		RemapB(fc)
		pause 1	
		print fc
	elseif keyin = code "6"
		Remap9bit()
	elseif keyin = code "z"
		RemapZX()
	endif 
	poke 23560,0
loop

update:
	'result = (r>>5) << 5 BOR (g >> 5) << 2 BOR (b>>6)
	'PlotL2(10,10,result)
	'CLS256(result)
	'print at 0,0;PointL2(10,10);" "
	print at 1,0;r
	return 

function fastcall PointL2(byVal PointL2x as ubyte, byval PointL2y as ubyte) as ubyte
		' Returns colour value from Layer2 at $c000
		' 192 / 3 = 64d 40h
		' 6 9kb banks are needed, 2 at a time paged in at c000 in pairs
		asm 
		pop hl 			; get return address in hl 
		;BREAK 
		pop de 			; get de off stack for y
		
		ld e,a			; a is X 
		
		;' d = PointL2y , e = PointL2x
		;' 
		ld c,0					; c is slice 0, 1, 2 		
		bit 7,d					; check for 128 bit , if true Z reset, false Z is set 
		jr nz,tebitset ; one Tweny Eight bit
		
		bit 6,d 
		jr nz,sfbitset		; Sixty Four
		jr bitsetdone
		
sfbitset:
		ld c,1 
		jr bitsetdone		
tebitset:
		ld c,2					; slice 2			
bitsetdone:
		ld a,c					; put slice in a 
		add a,a 				; slice * 2 as each bank is 8kb
		ld c,a					; put back in c, store on stack 
		push bc 				; store slice 
		ld a,d					; put d(y) into a		
		and %00111111		; mask off 64 / 128 
		ld d,a					; store back in d
		push hl 
		;' d = PointL2y , e = PointL2x
		ld b,e 				; store e for a moment in b (x)
		ld c,d				; copy of  d (y) in c 
		ld e,255				; mult d*e 
		MUL_DE 				; d*e = de (y*256)
		ld l,c				; we multi by 255 and add c
		ld h,0
		add hl,de 		; hl = offset of Y 0 - 16383
		ex de,hl			; swap de hl 
		ld hl,49152		; start of MMU6 for Layer2 direct 
		add hl,de 		; 49152+(cast(uinteger,PointL2y*256)
		ld e,b				; get e back
		ld d,0				; flatten 0 
		add hl,de 		; hl is now add 
		ex de,hl			; put hl into de 
		pop hl 
		pop bc 			; bring back slice 
end asm 
bankstart:
asm 
bankstart:
		ld a,18 		; start bank in 8kbs
		add a,c 			; 24 + slice 
		DW $92ED		;' MMU8(6,24+slice)
		DB $56				; MMU6
		inc a 			; next slice 
		DW $92ED		;'MMU8(7,25+slice)
		DB $57				; next bank 
		ex de, hl
		ld a,(hl)				; value to return 
		ld b,a
		xor a
		DW $92ED				;' original banks back 
		DB $56					; MMU8
		inc a 					; 
		DW $92ED				;
		DB $57					;
		ld a,b
		ex de, hl
		push hl 
		;BREAK
		end asm 

end function

Sub UpdatePalette(pal as ubyte)
		asm 
			LOCAL mulapalloop
			DW $92ED		
			DB $43
			xor a
			DW $92ED
			DB $40			; palette index 0
			ld b,255			; loop 256 times 
		mulapalloop:
			DW $92ED		; colour byte 1
			DB $44	
			inc a 
			DW $91ED		; colour byte 2
			DB $44,$0
			djnz mulapalloop
	end asm 
end sub 

SUB Remap()
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	for c=0 to 255*4 step 4	
		b=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		r=peek(@palette+cast(uinteger,c+2))
		result = (r>>5) << 5 BOR (g >> 5) << 2 BOR (b>>6)
		NextRegA($44,cast(ubyte,result))
		NextRegA($44,1)
		
	next c 
end sub 


SUB RemapPal()
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	for c=0 to 255*3 step 3	
		r=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		b=peek(@palette+cast(uinteger,c+2))
		result = (r>>5) << 5 BOR (g >> 5) << 2 BOR (b>>6)
		NextRegA($44,cast(ubyte,result))
		NextRegA($44,1)
		
	next c 
end sub 

SUB Remap9bit()
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	dim res2,sb,res3 as uinteger
	for c=0 to 255*4 step 4	
		b9=peek(@palette+cast(uinteger,c))
		g9=peek(@palette+cast(uinteger,c+1))
		r9=peek(@palette+cast(uinteger,c+2))
		res2 = ((r9>>5) << 6) BOR ((g9 >> 5) << 3) BOR (b9>>5)
		'res3=res2 >>1 : sb=res2 band 1
		NextRegA($44,cast(ubyte,res2>>1))
		NextRegA($44,cast(ubyte,res2 band 1))
		sb = 0
	next c 
end sub 
' SUB Remap9bit()
' 	NextReg($43,%00010001) 	' l2 pal 1
' 	NextReg($40,0) ' reset pal index
' 	dim res2,sb,res3 as uinteger
' 	for c=0 to 255*4 step 4	
' 		b9=peek(@palette+cast(uinteger,c))
' 		g9=peek(@palette+cast(uinteger,c+1))
' 		r9=peek(@palette+cast(uinteger,c+2))
' 		res2 = ((r9>>5) << 6) BOR ((g9 >> 5) << 3) BOR (b9>>5)
' 		'res3=res2 >>1 : sb=res2 band 1
' 		NextRegA($44,cast(ubyte,res2>>1))
' 		NextRegA($44,cast(ubyte,res2 band 1))
' 		sb = 0
' 	next c 
' end sub 

SUB Remap2(a as ubyte)
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	for c=0 to 255*4 step 4
		b=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		r=peek(@palette+cast(uinteger,c+2))
		'result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		NextRegA($44,cast(ubyte,result))
		NextRegA($44,1)
	next c		
end sub 

SUB Remap9bitFade(a)
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	dim res2,sb,res3 as uinteger
	for c=0 to 255*4 step 4	
		b=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		r=peek(@palette+cast(uinteger,c+2))
		res2 = ((r>>a) << 6) BOR ((g >> a) << 3) BOR (b>>a)
		'res3=res2 >>1 : sb=res2 band 1
		NextRegA($44,cast(ubyte,res2>>1))
		NextRegA($44,cast(ubyte,res2 band 1))
		sb = 0
	next c 
end sub 

SUB RemapR(a as ubyte)
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	for c=0 to 255*4 step 4
		b=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		r=peek(@palette+cast(uinteger,c+2))
		'result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		result = (r>>5) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		NextRegA($44,cast(ubyte,result))
		NextRegA($44,1)
	next c		
end sub 

SUB RemapG(a as ubyte)
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	for c=0 to 255*4 step 4
		b=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		r=peek(@palette+cast(uinteger,c+2))
		'result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		result = (r>>a) << 5 BOR (g >> 5) << 2 BOR (b>>(a+1))
		NextRegA($44,cast(ubyte,result))
		NextRegA($44,1)
	next c		
end sub 
SUB RemapB(a as ubyte)
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	for c=0 to 255*4 step 4
		b=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		r=peek(@palette+cast(uinteger,c+2))
		'result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(6))
		NextRegA($44,cast(ubyte,result))
		NextRegA($44,1)
	next c		
end sub 
SUB Remap3(a as ubyte)
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	for c=0 to 255*4 step 4	
		r=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		b=peek(@palette+cast(uinteger,c+2))
		'result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(6))
		NextRegA($44,cast(ubyte,result))
		NextRegA($44,1)
	
	next c		
end sub 

SUB RemapZX()
	NextReg($43,%00010001) 	' l2 pal 1
	NextReg($40,0) ' reset pal index
	for c=0 to 253*4 step 4	
		b=peek(@palette+cast(uinteger,c))
		g=peek(@palette+cast(uinteger,c+1))
		r=peek(@palette+cast(uinteger,c+2))
		'result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		'result = (r>>a) << 5 BOR (g >> 5) << 2 BOR (b>>(6))
		
		result = (r>>a) << 5 BOR (g >> 5) << 2 BOR (b>>(6))

		
		NextRegA($44,cast(ubyte,result))
		NextRegA($44,0)
	
	next c		
end sub 
palette:
	asm 
		palette:
		defs 1024,0
	end asm     