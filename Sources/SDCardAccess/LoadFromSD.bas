' NextBuild simple load from SD card
' emook 2018
' loads two screens from SD, this folder is setup locally as \data in the project folder
#define DEBUG 
#include <nextlib.bas>

border 2: paper 0 : ink 0 : cls

' LoadSD(filename,address,size,offset)
ShowLayer2(0)

do 
	LoadSD("screen2.scr",16384,6912,0)
	border 0
	pause 100
	
	' this will show the debug error as the file does not exist
	LoadSD("escreen.scr",16384,6912,0)
	pause 100
	border 2
	cls 

loop 

       