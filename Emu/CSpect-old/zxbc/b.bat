set out=build2.asm
echo ;
echo ; Build asm for NextBuild, based on asm by Mike Dailly>%out%
echo ;>>%out%
echo ;>>%out% 
echo 			opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack>>%out%
echo 			opt             Z80                                                     ; Set z80 mode>>%out%
echo 			opt             ZXNEXT >>%out%
echo 			org 	23552 >>%out%
echo 			incbin "sysvars.bin" >>%out%
echo 			org     %2-1 >>%out%				
:: echo StackEnd:		ds      0 >>%out%
echo StackStart:	db		0 >>%out%
echo StartAddress:	org %2 >>%out%
echo 			incbin "temp.bin" >>%out%
echo 			ret >>%out%
cd

..\snasm build2.asm temp.sna

