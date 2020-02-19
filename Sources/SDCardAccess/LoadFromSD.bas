' NextBuild simple load from SD card
' emook 2018
' loads two screens from SD, this folder is setup locally as \data in the project folder

#include <nextlib.bas>

border 2: paper 0 : ink 0 : cls

' LoadSD(filename,address,size,offset)

do 
	LoadSD("lovers2.bin",16384,6912,0)
	border 0
	pause 100
	
	LoadSD("screen.scr",16384,6912,0)
	pause 100
	border 2
	cls 

loop 

       