'!ORG=24576
' FDoTileBank16 & FL2Text example 
' em00k dec20

asm 
	  di 					;' I recommend ALWAYS disabling interrupts 
end asm 
#define NEX 		
#include <nextlib.bas>

border 0 

' LoadSDBank ( filename$ , dest address, size, offset, 8k start bank )
' dest address always is 0 - 16384, this would be an offset into the banks 
' if you do not know the filesize set size to 0. If the file > 8192 the data
' is loaded into the next consecutive bank. Very handy 

LoadSDBank("testsp1.spr",0,0,0,34) ' file is 16kb, so load into banks 34/35
LoadSDBank("testsp2.spr",0,0,0,36) ' banks 36/37
LoadSDBank("testsp3.spr",0,0,0,38) ' banks 38/39
LoadSDBank("font1.spr",0,0,0,40) 	' load the first font to bank 40 

nextrega($14,0)					'; black transparency 
nextrega($70,%00010000)			'; enable 320x256 256col L2 
ClipLayer2(0,255,0,255)			'; make all of L2 visible 
nextrega($69,%10000000)			' enables L2 
nextrega($7,3)					' 28mhz 

FL2Text(0,0,"THIS EXAMPLE SHOWS THE FDOTILE16 COMMAND",40)
FL2Text(0,1,"THE FOLLOWING IMAGE IS CREATED FROM ",40)
FL2Text(0,2,"192 16X16 TILES LOADED CONSECUTIVELY IN",40)
FL2Text(0,3,"RAM WITH LOADSDBANK",40)
FL2Text(0,4,"PRESS SPACE TO START",40)

WaitKey()


dim tx,ty,sx,sy, tile  as ubyte 

do 
	tile = 0 
	for ty = 0 to 11 
		for tx = 0 to 15
			FDoTile16(tile,sx+tx,sy+ty,34)
			tile=tile+1 
		next tx 
	next ty 

	while inkey$=""
	WaitRetrace(1)
	wend 
	
	if l = 0 	
		sx = 0 : sy = 0 : l=l+1 
	elseif l = 1 
		sx = 4 : sy = 0 : l=l+1 
	elseif l = 2
		sx = 4 : sy = 4 : l=l+1 
	elseif l = 3
		sx = 0 : sy = 4 : l=0 
	endif 

loop 
