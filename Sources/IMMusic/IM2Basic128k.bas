border 0
' This is for FUSE only in 128/48kmode !!

'SUB InitMusic(Address as uinteger)


asm 
	IJUMP 					EQU $bE00				;'we will have a byte at $AE00 and $AF00 the byte will be the h for ISR
	ISR 						EQU $bFbF				;'This is the location where we put a jump to our routine 3 bytes needed
	PLAYERLOCATION  EQU $c000				;'to move you need to re-assemble the vt2 routine to a new address
	di
	; setup
	; copy playroutine
	ld hl,vt2player
	ld de,PLAYERLOCATION
	ld bc,vt2playerend-vt2player		;' length of playrotine to copy 
	call bank4											;' copy the play routine to bank4
	ldir	
	ld hl,music
	ld de,51303
	ld bc,musicend-music 
	ldir 
	ld hl,51303
	call PLAYERLOCATION+3
	ld hl,Ints
	ld a,$C3					; we need to store "jp Ints" for the ISR
	ld de,ISR
	ld (de),a					; jp 
	ld a,l
	inc de 						; next byte 
	ld (de),a					; h *  256 + ISR/256
	ld a,h
	inc de 						; next byte 
	ld (de),a					; ISR/256 
	ld hl,ISR
	ld a,h						; our jump jump vector needs to be filled $BFBF etc
	ld hl,IJUMP				; for cspect ISR JUMP starts
	inc hl
	ld (hl),a
	ld hl,IJUMP
	inc h 						; IJUMP+256 for fuse/Next ISR JUMP starts
	ld (hl),a
	jp intend

bank4:	; swap to bank 4 @ 49152 - 16k
	;di														;' no need for di.ei as we're calling with DI 
	ld a,(23388)   								;' Get current ram page @ $c000
	ld (bankst),a									;' save it for later 
	and 248												;' 
	or 4													;' swap to bank 4
	ld bc,32765										;' paging port 32765
	ld (23388),a									;' store a in basics 23388
	out (c),a											;' out the new bank
	ret 													;' done 
bankorig:
	ld a,(23388)   								;' Get current ram page @ $c000
	ld a,(bankst)									;' save it for later 
	ld bc,32765										;' paging port 32765
	ld (23388),a									;' store a in basics 23388
	out (c),a											;' out the new bank
	ret
bankst:
	DB 0													;' this is the bank we saved 
	
Ints:	
	di                  					;' disable interrupts
	push af             
	push bc
	push de
	push hl
	push ix             
	push iy
	ex af, af'
	push af             
	call bank4										;' jump to bank 4
	call PLAYERLOCATION+5     		;' play the current tune
	call bankorig									;' back to original bank 
	pop af 
	ex af, af'
	pop iy
	pop ix              
	pop hl
	pop de
	pop bc
	pop af              
	ei             
	jp 56				
intsend:

intend:
	ld hl,IJUMP
	ld a,h
	ld i,a
	IM 2
end asm

end 				

asm 
vt2player:
	incbin "vt49152.bin"
vt2playerend:
end asm 

asm 
music:
	incbin "TITLE135.pt3"
musicend:
end asm                