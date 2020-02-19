'#!sna "h:\plotl2.sna" -a
#include <nextlib.bas>

paper 0: border 0 : bright 0: ink 7 : cls 

NextReg($14,$0)  					' glbal transparency 
NextReg($40,$18)    			' Black paper transparency 
NextReg($41,$0)  					' paletting index 0 
NextReg($7,$2)  					' go 7mhz 

NextReg($15,%00100001)   ' Sprites, ULA SPR L2 	
NextReg($8,%00100000)   ' Sprites, ULA SPR L2 	

dim b,c,yy as ubyte

b=0 : c=0

for x=0 to 192 
	yy=0
	for y=0 to 511 step 2 
		c=255-yy/yy>>x*y>>x/32
		PlotL2(x,yy,c)
		yy=yy+1	
	next 
Next 

x=0

do
 x=x+1
 y=y+1
 ScrollLayer(x,y)
 if y>191
	y=0
	endif 
 pause 1
loop 

sindata:
asm 
	db 3,0,1,4,5,3
end asm 

 