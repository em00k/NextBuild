
#include <nextlib.bas>

NextReg(8,$fe)								' no contention 
NextReg($43,$1)								' ULANext enabled 
NextReg(7,2)									' 14mhz
NextReg($14,$0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
NextReg($40,0)   						' 16 = paper 0 on L2 palette index 
NextReg($41,$0)  							'	Palette Value 
NextReg($15,%00001011)
NextReg($42,255)							' ULANext number of inks : 255 127 63 31 15 7 
NextReg($4A,0)							' ULANext number of inks : 255 127 63 31 15 7 
NextReg($22,0)							' ULANext number of inks : 255 127 63 31 15 7 
NextReg($4A,0)							' ULANext number of inks : 255 127 63 31 15 7 
CLS256(255)
paper 0 : ink 6: border 0 : cls
ShowLayer2(1)
dim LUT2BITTO8BIT(3) as ubyte => {0,$55,$AA,$FF}
dim LUT3BITTO8BIT(7) as ubyte => {0,$24,$49,$6D,$92,$B6,$DB,$FF}
dim LUT4BITTO8BIT($F) as ubyte => {0,$11,$22,$33,$44,$55,$66,$77,$88,$99,$AA,$BB,$CC,$DD,$EE,$FF}
GetReg(0)
dim a,b,c as uinteger
NextReg($43,%00010001)  	' l2 pal 1

for x = 0 to 256
	NextRegA($40,x) ' reset pal index
	a=GetReg($41)			' read first pal byte
	b=GetReg($44)		
	
	c=b bor a<<1
	
	print a;" ";b;" ";c;" = ";
	CLS256(a)
	rgb92rgb24(c)
	pause 0
next x



do 
loop 
 
function rgb92rgb24(rgb9 as uinteger)

 r = LUT3BITTO8BIT(cast(Ubyte,rgb9 >> 6 Band 7))
 g = LUT3BITTO8BIT(cast(Ubyte,rgb9 >> 3 Band 7))
 b = LUT3BITTO8BIT(cast(Ubyte,rgb9 Band 7))
 
 print r;" ";g;" ";b
 
end function
  