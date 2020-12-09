'!ORG=24576
' LoadSDBank, 320*256BMP and FL2Text Example 
' em00k dec20

asm 
	  di 					;' I recommend ALWAYS disabling interrupts 
end asm 
		
#include <nextlib.bas>

border 0 

const fntbank1 = 36			' start at bank 36 as 320x256 L2 is 10 *8kb banks 
const fntbank2 = 37			' and starts at 24 : 24 + 10 = 34

' LoadSDBank ( filename$ , dest address, size, offset, 8k start bank )
' dest address always is 0 - 16384, this would be an offset into the banks 
' if you do not know the filesize set size to 0. If the file > 8192 the data
' is loaded into the next consecutive bank. Very handy 

LoadSDBank("font12.spr",0,0,0,fntbank1) 	' load the first font to bank fntbank1 
		
LoadSDBank("font3.spr",0,0,0,fntbank2) 		' load second font to fntbank2 
			
LoadSDBank("sega1.bmp",0,0,1078,24) 		' loads a rotated 320*256BMP to bank 24 onwards 

NextReg($12,12)					'; ensure L2 bank starts at 16kn bank 12 (so bank 24 in 8kb) 
NextReg($14,0)					'; black transparency 
NextReg($70,%00010000)			'; enable 320x256 256col L2 
NextReg($7,3)					' 28mhz 
ClipLayer2(0,255,0,255)			'; make all of L2 visible 

for x = 0 to 31
	FL2Text(0,x,"HELLO FROM NEXTBUILD",fntbank2)
	pause 5 
next x 

FL2Text(10,10,"AT 320x256 LAYER 2",fntbank1)
nextrega($69,%10000000)			' enables L2 

do 
	' loop for ever 
loop 
 