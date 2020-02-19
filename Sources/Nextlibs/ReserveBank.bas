' reserver & free mmu bank
'!bin "h:\test.bin"

#include <nextlib.bas>

dim bnk as ubyte 

' call the reservebank function and get a free 8kb bank number 
' uses nextzxos api to allocate a bank

do

	bnk=ReserveBank()

	' show the bank we got 
	Print bnk
	pause 0 

	'now free it 
	FreeBank(bnk)
	pause 0

LOOP 

  