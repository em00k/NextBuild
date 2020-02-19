border 0
' This is for FUSE only in 48kmode !!

'SUB InitMusic(Address as uinteger)

asm 
	IJUMP 					EQU $6000				;'we will have a byte at $AE00 and $AF00 the byte will be the h for ISR
	;'ISR 						EQU $AEAE				;'This is the location where we put a jump to our routine 3 bytes needed
	PLAYERLOCATION  EQU $c000				;'to move you need to re-assemble the vt2 routine to a new address
	
	; setup
	; copy playroutine
	ld hl,vt2player
	ld de,PLAYERLOCATION
	ld bc,vt2playerend-vt2player		; length of playrotine to copy 
	ldir
	ld hl,music
	call PLAYERLOCATION+3
	ld hl,Ints
	ld a,$C3					; we need to store "jp Ints" for the ISR
	ld de,IJUMP
	ld e,d
	ld (de),a					; jp 
	ld a,l
	inc de 						; next byte 
	ld (de),a					; h *  256 + ISR/256
	ld a,h
	inc de 						; next byte 
	ld (de),a					; ISR/256 
	ld hl,IJUMP					; BFBF eg 
	ld a,h						; ld a with BF our jump jump vector needs to be filled $BFBF etc
	;ld hl,IJUMP				; for cspect ISR JUMP starts
	ld (hl),a
	inc hl
	ld (hl),a
	ld hl,IJUMP
	dec hl 
	inc h 						; IJUMP+256 for fuse/Next ISR JUMP starts
	ld de,IJUMP
	ld a,d
	ld (hl),a
	ld a,d
	inc hl 
	ld (hl),a
	jp intend

Ints:	
	di                  ; disable interrupts
	push af             
	push bc
	push de
	push hl
	push ix             
	push iy
	ex af, af'
	push af             
	
	call PLAYERLOCATION+5     ; play the current tune

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
	
tempa:
	db 0
tempb:
	db 0
intend:
	ld hl,IJUMP
	ld a,h
	ld i,a
	IM 2
end asm
pause 0 
end 				

asm 
vt2player:
	incbin "vt49152.bin"
vt2playerend:
end asm 

asm 
music:
	incbin "round1.pt3"
musicend:
end asm            