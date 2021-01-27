'!ORG=24576
'!bmp=amiga3.bmp 
'

border 0 	
#define NEX 
#include <nextlib.bas>

asm 
	nextreg 7,3
	nextreg $22,0
	nextreg $14,0
end asm 

' LoadSDBank   =  filename, address (0 - 8192), lenght, offset in file, bank 
' if you leave length as 0 then length will automaticall be detected
' memory address $4000-$5FFF is used for loading into bank, if the file is 
' over 8kb, the next bank is paged in and loading continues, once completed
' the original bank is paged back.
' address is an offset into the bank 

' Using this command, you can set your code up for use with nexcreator, 
' all the LoadSDBanks can be disabled by issuing a #DEFINE NEX 

LoadSDBank("testsp1.spr",0,0,0,34) ' file is 16kb, so load into banks 34/35
LoadSDBank("testsp2.spr",0,0,0,36) ' banks 36/37
LoadSDBank("testsp3.spr",0,0,0,38) ' banks 38/39
LoadSDBank("font15.spr",0,0,0,40) ' load our font to bank 40 

' DoTileBank x , y , tilenumber 0- 255, start bank 
' This command will allow you to draw on Layer2 with 16x16 tiles
' and will automaticall page in the correct bank. If you load multiple
' tile banks like above (each file is 16kb) it will allow you to have
' more than 64 tiles

ShowLayer2(1)

dim runs as ulong 
do 

	CLS256(1)

	L2Text(0,0,"THE FOLLOWING SCREEN IS ",40,0)
	L2Text(0,1,"MADE UP OF 192 16X16",40,0)
	L2Text(0,2,"TILES LOADED CONSECUTIVELY",40,0)
	L2Text(0,3,"IN RAM",40,0)
	L2Text(0,7,"A DELAY IS ADDED FOR EFFECT",40,0)
	L2Text(0,8,"BETWEEN DRAWING TILES.",40,0)
	L2Text(0,10,"PRESS SPACE TO DRAW",40,0)

	WaitKey()

	L2Text(0,23,str(runs),40,0)
	x=1 : y = 1 : tt=0

	for y = 0 to 11
		for x = 0 to 15 
		DoTileBank16(x,y,tt,34)			' draw tile = 0 to 191
		tt=tt+1 						' increase tile number
		WaitRetrace(1)
		next x
	next y 

	runs = runs + 1 

	L2Text(13,4,"DEMO OVER",40,0)
	
	WaitKey()
	WaitRetrace(100)
	
loop 
