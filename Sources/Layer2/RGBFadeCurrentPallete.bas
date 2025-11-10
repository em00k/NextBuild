'!bin "h:\temp.bin" -a 
'!#noemu
#include <nextlib.bas>
NextReg(8,$fe)								' no contention 
NextReg($43,$1)								' ULANext enabled 
NextReg(7,2)									' 14mhz
NextReg($14,$0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
NextReg($40,0)   						' 16 = paper 0 on L2 palette index 
NextReg($41,$0)  							'	Palette Value 
NextReg($15,%00001011)
NextReg($42,255)							' ULANext number of inks : 255 127 63 31 15 7 
NextReg($4A,0)							' Trasnparent Fallback


CLS256(255)
paper 0 : ink 6: border 0 : cls
ShowLayer2(1)
dim LUT2BITTO8BIT(3) as ubyte => {0,$55,$AA,$FF}
dim LUT3BITTO8BIT(7) as ubyte => {0,$24,$49,$6D,$92,$B6,$DB,$FF}
dim LUT4BITTO8BIT($F) as ubyte => {0,$11,$22,$33,$44,$55,$66,$77,$88,$99,$AA,$BB,$CC,$DD,$EE,$FF}
GetReg(0)
'dim a,b,c,d as uinteger

dim r,g,b,fc,color as ubyte
dim r9,g9,b9 as uinteger
dim result as uinteger

NextReg($43,%00010001)  	' Select Layer 2 palette (0 = first palette, 1 = second palette) & Select Layer 2 palette (0 = first palette, 1 = second palette)

'LoadBMP("car.bmp")
ShowLayer2(1)
'LoadSD("car.bmp",@palette,1024,54)
'Remap9bit()
showpallete()

do 
	for x = 0 to 256
	NextRegA($40,x) ' reset pal index
	a=GetReg($41)			' read first pal byte
	b=GetReg($44)		
	
  c=b bor a<<1
	
	
	'CLS256(a)
	rgb92rgb24(c)
	poke 23693,x
	print a;" ";b;" ";c;" = ";
	pause 0
	if inkey$="c"
	for cc=5 to 10
		Remap2(cc)
	next  
	endif 	
	next 
loop 
 
function rgb92rgb24(rgb9 as uinteger)

 r = LUT3BITTO8BIT(cast(Ubyte,rgb9 >> 6 Band 7))
 g = LUT3BITTO8BIT(cast(Ubyte,rgb9 >> 3 Band 7))
 b = LUT3BITTO8BIT(cast(Ubyte,rgb9 Band 7))
 
 print r;" ";g;" ";b
 
end function

SUB Remap2(a as uinteger )
	dim LUT3BITTO8BIT(7) as ubyte => {0,$24,$49,$6D,$92,$B6,$DB,$FF}
	NextReg($43,%00010001) 	' l2 pal 1
	'NextReg($40,0) ' reset pal index
	for c=0 to 254
	NextRegA($40,c) ' reset pal index
		a=GetReg($41)			' read first pal byte
		b=GetReg($44)		
		d=b bor a<<1
		r = LUT3BITTO8BIT(cast(Ubyte,d >> 6 Band 7))
		g = LUT3BITTO8BIT(cast(Ubyte,d >> 3 Band 7))
		b = LUT3BITTO8BIT(cast(Ubyte,d Band 7))
		'b=peek(@palette+cast(uinteger,c))
		'g=peek(@palette+cast(uinteger,c+1))
		'r=peek(@palette+cast(uinteger,c+2))
		'result = (r>>a) << 5 BOR (g >> a) << 2 BOR (b>>(a+1))
		result = (r>>a) << 6 BOR (g >> a) << 3 BOR (b>>(a+1))
		NextRegA($40,c) ' reset pal index
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

palette:
	asm 
		palette:
		defs 1024,0
	end asm    
	
sub showpallete()
col=0 : py = 0 : px = 0 
' if importpal=1 
' 	col = peek (ubyte,16384)
' 	palloff2=0 
' 	
' '	MemSwap(49152, 0, 4096, 22, 24)	' save top of screen 
' '	MemSwap(0, 49152, 4096, 23, 24)	 ' bring back palette
' 
' endif 
do
	'do
	'for py=0 to 15 step 4
	
	do 
	color=col	
	plotline(px,py,px+3,py)
 	plotline(px,py+1,px+3,py+1)
 	plotline(px,py+2,px+3,py+2)
 	plotline(px,py+3,px+3,py+3)	

	col=col+1

	px=px+4
	loop until px=0
	py=py+4
	px=0
loop until py>=16
	palloff2=0 
	
end sub 

sub plotlinelow(xa as integer,ya as integer,w as integer,y as integer )

	dx=w-xa
	dy=y-ya
	yi=1
	if dy<0
		yi=-1
		dy=-dy
	endif 
	D=(dy<<1)-dx
	yb=ya
	lw = dy / 8 
	for x = xa to w
		'print x/lw
		'if colcycle = 10
		'cyclecol=x/lw band 7 
		'color=peek(@paletteindex+cast(uinteger,cyclecol))
		'endif 
		
		
		PlotL2(x,yb,color)
		'PlotL2(x+1,yb+1,color)
		if D > 0
		 yb = yb + yi
		 D = D - (dx<<1)
		 endif
		 D=D+(dy<<1)
	next 
end sub

sub plotlinehigh(xa as integer,ya as integer,w as integer,y as integer )

	dx=w-xa
	dy=y-ya
	xi=1
	if dx<0
		xi=-1
		dx=-dx
	endif 
	D=(dx<<1)-dy
	xb=xa
	lw = dy / 8
	' sponge 
	for yb = ya to y
	'BBREAK
		'if colcycle = 255
		'cyclecol=yb/lw band 7 
		'color=peek(@paletteindex+cast(uinteger,cyclecol))
		'endif 
		PlotL2(xb,yb,color)
		'PlotL2(xb+1,yb+1,color)
		if D > 0
		 xb = xb + xi
		 D = D - (dy<<1)
		 endif
		 D=D+(dx<<1)
	next 
end sub

sub plotline(xa as integer,ya as integer,w as integer,y as integer )
	 
	if abs(y - ya) < abs(w - xa)
    if xa > w
      plotlinelow(w, y, xa, ya)
    else
      plotlinelow(xa, ya, w, y)
    end if
  else
    if ya > y
      plotlinehigh(w, y, xa, ya)
    else
      plotlinehigh(xa, ya, w, y)
    end if
  end if


end sub   