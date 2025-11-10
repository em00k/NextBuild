border 0 : paper 0 : ink 7: cls 
' This is for FUSE load only in 48kmode !!!! It will crash in 128k mode
' you must use a start addres of above 29000!  -->>>
' wont work in cspect as we cannot read the ports!

'SUB InitMusic(Address as uinteger)

asm 
	IJUMP 					EQU $AE00				;'we will have a byte at $AE00 and $AF00 the byte will be the h for ISR
	ISR 						EQU $BFBF				;'This is the location where we put a jump to our routine 3 bytes needed
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

Ints:	
	di                  
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

PRINT AT 23,0;"Grace "
c$=" ####################"
PRINT AT 0,0;"Channel A";AT 3,0;"Channel B";AT 6,0;"Channel C"
FOR n=1 TO 9 STEP 3
PRINT AT n,0; INK 4;"     "; INK 6;"         "; INK 2;"  "
NEXT n
PRINT AT 15,0;"Original by Kate Havnevik"
PRINT AT 16,0;"Covered  by emook 2018"
INK 8
dim a as ubyte 
DO 
	pause 1
	OUT 65533,8 : a=IN 65533 BAND %00001111
	PRINT AT 1,0;c$(1 TO a);"               "
	OUT 65533,9 : a=IN 65533
	PRINT AT 4,0;c$(1 TO a);"               "
	OUT 65533,10 : a=IN 65533
	PRINT AT 7,0;c$(1 TO a);"               "
LOOP 

end

asm 
vt2player:
	incbin "vt49152.bin"
vt2playerend:

music:
	incbin "level1.pt3"
musicend:
end asm 



             