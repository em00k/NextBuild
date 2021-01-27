#include <nextlib.bas>
' Memory bank example using 8kb banks
' This program pokes the bank number into slot 7 @ $e000 with the current bank number then reads them back 
' 
' Area       16k 8k def 
' $0000-$1fff	1	 0	ROM		ROM (255)	Normally ROM. Writes mappable by layer 2. IRQ and NMI routines here.
' $2000-$3fff		 1				ROM (255)	Normally ROM. Writes mapped by Layer 2.
' $4000-$5fff	2	 2	5			10				Normally used for normal/shadow ULA screen.
' $6000-$7fff		 3				11				Timex ULA extended attribute/graphics area.
' $8000-$9fff	3	 4	2			4					Free RAM.
' $a000-$bfff		 5				5					Free RAM.
' $c000-$dfff	4	 6	0			0					Free RAM. Only this area is remappable by 128 memory management.
' $e000-$ffff		 7	1								Free RAM. Only this area is remappable by 128 memory management.
'
' 16kb  	8kb 
' 8-15		16-31		$060000-$07ffff	128K	Extra RAM
' 16-47		32-95		$080000-$0fffff	512K	1st extra IC RAM (available on unexpanded Next)
' 48-79		96-159	$100000-$17ffff	512K	2nd extra IC RAM (only available on expanded Next)
' 80-111	160-223	$180000-$1fffff	512K	3rd extra IC RAM (only available on expanded Next)

ink 7 : paper 0 

' MMU8 (8kb slot number 0-7, memory bank 16-223)

for x = 0 to 7
print "slot "+str(x)+" is bank : "+str(GetMMU(x))
next 

MMU8(6,32)		' set slot 6 = 32

' Read the current slot with GetMMU(slot)
PRINT 
print ink 4;"slot 6 is now bank : "+str(GetMMU(6))
pause 25

' Write to banks 16-95 slot 7, $e000 with bank number 
for x=16 to 95
	MMU8(7,x)
	POKE $e000,x
	print at 10,0;ink 6;"slot 7 ($e000) write : "+str(x)
	pause 1
next x 

' Read back value at $e000 for banks 16-95
for x=16 to 95
	MMU8(7,x)
	print at 11,0;ink 5;"slot 7 ($e000) read : "+str(peek $e000)
	pause 1 
next x 

DO : LOOP 



  