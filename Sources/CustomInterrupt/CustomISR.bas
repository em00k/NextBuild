'!ORG=24576
'
'em00k 2021 part of Nextbuild 
' Custom ISR

asm : di : end asm 
									' These must be set before including the nextlib
#define NEX 						' If we want to produce a NEX, LoadSDBank commands will be disabled and all data included
#define CUSTOMISR					' This to call your custome isr 
#define NOAYFX						' We wont be using MUSIC/AYFX in the ISR 
#define IM2							' Still required

#include <nextlib.bas>				' now include the nextlib library
                                  
asm  
    NextReg TURBO_CONTROL_NR_07,3 					; 28mhz 
end asm 

border 2 : paper 0 : ink 7: cls 

dim ci,tt as ubyte 		            ' define some global bytes 

SetUpIM()                           ' Call the interrupt setup, which will call MyCustomISR()
ISR()                               ' Call the ISR once 

Print at 0,0;"The following var is incremented" : print "with the custom ISR"

do 

	WaitRetrace(1)								' use instead of pause 1 
    Print at 4,0;tt;"   "                       ' add space to clear chars 

loop 

sub MyCustomISR()

    ' this is called every 50th on interrupt. 
    if  ci =  10
        ' timer triggered 
         ci = 0
         tt = tt +1
    else 
         ci =  ci + 1 
         border 0
    endif 
    
end sub 
