border 0

'SUB InitMusic(Address as uinteger)

asm 
	IJUMP EQU $AE00				;' this is where will have a repeated byte over over = ISR
	ISR EQU $BFBF					;'This is the location where we put a jump to our routine
	PLAYERLOCATION EQU $c000
	
	;  setup
	; copy playroutine
	ld hl,vt2player
	ld de,PLAYERLOCATION
	ld bc,1617
	ldir
	ld hl,music
	call PLAYERLOCATION+3
	ld hl,Ints
	ld a,$C3					; we need to store "jp Ints" for the ISR
	ld de,ISR
	ld (de),a				; jp 
	ld a,l
	inc de 					; next byte 
	ld (de),a				; h *  256 + ISR/256
	ld a,h
	inc de 					; next byte 
	ld (de),a				; ISR/256 
	ld hl,ISR
	ld a,h					; our jump jump vector needs to be filled $BFBF etc
	
	ld hl,IJUMP				; for cspect ISR JUMP starts
	inc hl
	ld (hl),a
	ld hl,IJUMP
	inc h 
	;ld hl,$AF00				; for fuse/Next ISR JUMP starts
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
	jp 56				; uncomment for use in basic, load in 48k mode thought and with fuse  
	;reti 			; comment out for normal zxb use 
	
	
tempa:
	db 0
tempb:
	db 0
intend:
	ld a,$AE
	ld i,a
	IM 2
end asm
	
text$="                                           THIS IS A SIMPLE SCROLLER RUNNING WHILE INTERRUPT MUSIC IS PLAYING....    " 

'; end 					;'uncomment for basic, Fuse real Next only and in 48k mode 

do

	text$=text$(1 to len text$)+text$(1)
	print at 23,0; text$( to 31)
	pause 4

LOOP 	

vt2:
asm 
vt2player:
	incbin "vt49152.bin"
end asm 

asm 
music:
	incbin "round1.pt3"
musicend:
end asm          