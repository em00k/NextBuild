'!bin"h:\getmmu.bin" -a

#include <nextlib.bas>
NextReg($8,%11111010)			' All the features and no contenion 
dim a,b as ubyte 
'BBREAK
ASM
 ;DI 
 ;BREAK 
END ASM 

MMU16(31)

MMU16(0)
print at 0,0;a,b

DO 
	pause 0
loop


 