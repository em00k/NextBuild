
'IJUMP = $BFBF				' memory location of interrupt routine jump put a jmp to our routine

'SUB InitMusic(Address as uinteger)

asm 
	push ix 
	; setup
	; copy playroutine
	ld hl,vt2player		; player code
	ld de,49152				; when player needs to be
	ld bc,1617				; length of player 
	ldir							; move it to 49152
	ld hl,51310				; load lh with music address

	call 49152+3			; init the music with hl set 
	ld hl,Ints				; point to our ISR
	ld a,$C3					; we need to store "jp Ints" for the ISR
	ld ($BFBF),a			; jp 
	ld a,l
	ld ($BFC0),a			; h *  256 + ISR/256
	ld a,h
	ld ($BFC1),a			; ISR/256 
	
	ld a,$BF					; our jump jump vector needs to be filled $BFBF etc
	
	ld hl,$BE00				; for cspect ISR JUMP starts  (tee hee hee i still only use 1 byte jump!)
	inc hl
	ld (hl),a
	ld hl,$BF00				; for fuse/Next ISR JUMP starts
	ld (hl),a

	jp intend

Ints:	
	di                  ; disable interrupts
	push af             ; save all std regs
	push bc
	push de
	push hl
	push ix             
	push iy
	ex af, af'
	push af             ; save all std regs
	
	;	NextRegExB($56,$37)					' slect bank $26 	
	;	NextRegExB($57,$38)					' slect bank $26 	
	
	call 49157       ; play the current tune

	;NextRegExB($56,$37)					' slect bank $26 	
	;NextRegExB($57,$38)					' slect bank $26 	

	pop af 
	ex af, af'
	pop iy
	pop ix              
	pop hl
	pop de
	pop bc
	pop af              
	ei             
	;jp 56		; found most stable 
	reti 
	
tempa:
	db 0
tempb:
	db 0
intend:
	ld a,$BE
	ld i,a
	IM 2
	pop ix 
end asm

goto includeexit

vt2:
asm 
vt2player:
	incbin "./data/vt49152.bin"
end asm 

asm 
;music:
;	incbin "music2.pt3"
;musicend:
end asm      

includeexit:
'  pause 0 