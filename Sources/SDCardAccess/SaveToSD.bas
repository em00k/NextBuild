#include <nextlib.bas>

dim n as ubyte 

paper 7: ink 0: border 7: cls 

print ink 1;"Lets print some text.." : pause 50 : cls 

for n = 0 to 22
	print "HELLO THERE WORLD ! ! ! ! ! !"
	ink rnd*7
next 

' SaveSD(filename,address,number of bytes)
' lets save the screen 
SaveSD("output.scr",16384,6912)

pause 100 : cls
print ink 1;"Screen saved to SD.."
print ink 1;"Lets load it back.."
pause 100

' LoadSD(filename,address,number of bytes,offset)
LoadSD("output.scr",16384,6912,0)

border 1 : pause 0 

do 

loop 
    