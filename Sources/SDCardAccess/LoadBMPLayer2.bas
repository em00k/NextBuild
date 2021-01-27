'#!v
'!sna "h:\image.sna" -a 

#include <nextlib.bas>
asm 
 ei 
end asm 
border 0
'NextReg($15,%00100001)		' Sprites, ULA SPR L2 	

LoadBMP("13.bmp")
ShowLayer2(1)			' ON 

dim x as ubyte = 0 
' lets scroll layer2
pause 0 

for y=0 to 192
	ScrollLayer(0,y)
	pause 1
next y 

pause 50

LoadBMP("1.bmp")
ShowLayer2(1)			' ON 

for x=0 to 254
	pause 1
	ScrollLayer(x+2,0)
next x 



pause 0

end             