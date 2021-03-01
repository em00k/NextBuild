'!ORG=24576
' FDoTile8 example, same as FDoTile16
' em00k dec20
'

#define NEX

asm 
	  di 					;' I recommend ALWAYS disabling interrupts 
end asm 
		
#include <nextlib.bas>

border 0 

nextrega($14,0)					'; black transparency 
nextrega($70,%00010000)			'; enable 320x256 256col L2 
ClipLayer2(0,255,0,255)			'; make all of L2 visible 
nextrega($69,%10000000)			' enables L2 
nextrega($7,3)					' 28mhz 

' LoadSDBank ( filename$ , dest address, size, offset, 8k start bank )
' dest address always is 0 - 16384, this would be an offset into the banks 
' if you do not know the filesize set size to 0. If the file > 8192 the data
' is loaded into the next consecutive bank. Very handy 

LoadSDBank("sonic.spr",0,0,0,34) 	' file is 16kb, so load into banks 34/35

dim tx,ty,sx,sy, tile  as ubyte 

	
	for ty = 0 to 31 
		for tx = 0 to 39
			' note order of arguments tile, x, y, bank 
			FDoTile8(66,tx,ty,34)
		next tx 
	next ty 

do 

	for it = 0 to 16 step 4 
	tile = 0 
	for ty = 0 to 7
		for tx = 0 to 31
			' note order of arguments tile, x, y, bank 
			FDoTile8(tile,tx,it+ty,34)
			tile=tile+1 
		next tx 
	next ty 

	WaitRetrace(100)

	next it

loop 
 