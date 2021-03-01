' small example to print a bitmap text to layer2  
'
'Set the start address  
'!org=32768                 


#define NEX                                 	' Include data in NEX
#include <nextlib.bas>

LoadSDBank("font3.spr",0,0,0,34)				' load font to bank 34
L2Text(0,0,"HELLO THERE",34,0)  				' print bitmap text 
ShowLayer2(1)   								' ensure layer2 is on

do
    
loop  
