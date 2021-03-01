'!ORG=24576
' FPlotL2 Example 
' em00k dec20

asm 
	  di 					;' I recommend ALWAYS disabling interrupts 
end asm 
#define NEX 				' This tells nextbuild we are making a final NEX and do not Load from SD 
							' with out you would need eachfile that is used with LoadSDBank
							' and must be before include <nextlib.bas>
#include <nextlib.bas>

border 0 

nextrega($7,3)					'; 28mhz 
nextrega($14,0)					'; black transparency 
nextrega($70,%00010000)			'; enable 320x256 256col L2 
nextrega($69,%10000000)			' enables L2 
ClipLayer2(0,255,0,255)			'; make all of L2 visible 

LoadSDBank("font1.spr",0,0,0,40) 	' load the first font to bank 40 

FL2Text(0,0,"THIS EXAMPLE SHOWS THE FL2TEXT COMMAND",40)
FL2Text(0,1,"THAT DRAWS TEXT WITH A FONT ON 320X256",40)
FL2Text(0,5,"PRESS SPACE TO SEE A PLOT EXAMPLE",40)

pause 0 

dim px as uinteger 
dim py, pcol as ubyte 

do 
	for py = 0 to 254 step 2 
		for px = 0 to 319 step 2 
			FPlotL2(py,px,50) 
		next px 
	next py 
loop 
