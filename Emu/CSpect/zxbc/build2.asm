; Build asm for NextBuild, based on asm by Mike Dailly
;
; 
			opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
			opt             Z80                                                     ; Set z80 mode
			opt             ZXNEXT 
			org 	23552 
			incbin "sysvars.bin" 
			org     33000-1 				
StackStart:	db		0 
StartAddress:	org 33000 
			incbin "temp.bin" 
			ret 
