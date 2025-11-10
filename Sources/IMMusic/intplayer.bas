border 0


dim t as ubyte
t = 0 : dummy = t

asm 
	; copy playroutine
	ld hl,vt2player
	ld de,49152
	ld bc,1617
	ldir
	ld hl,music	
	ld de,51310
	ld bc,3926
	ldir
	
	call 49152
	
	LD BC,$243B
	LD A,$51
	OUT (C),A
	LD BC,$253B
	IN A,(C)
	ld (._t),A

lp:
	call 49157
	halt
	jp lp
end asm
	
print at 0,0;t
pause 0 
end 
	
ASM 
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

	LD BC,$243B
	LD A,$56
	OUT (C),A
	IN A,(C)
	ld (tempa),A
	LD A,$57
	OUT (C),A
	IN A,(C)
	ld (tempb),A
	
;	NextRegExB($56,$37)					' slect bank $26 	
;	NextRegExB($57,$38)					' slect bank $26 	
	
	call 49157       ; play the current tune

	LD BC,$243B
	LD A,$56
	OUT (C),A
	LD BC,$253b
	LD A,(tempa)
	OUT (C),A
	LD BC,$243B
	LD A,$57
	OUT (C),A
	LD BC,$253b
	LD A,(tempb)
	OUT (C),A
	
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
	jp 56		; found most stable 
	;reti 	
tempa:
	db 0
tempb:
	db 0

END ASM 
ASM 
IMStart:
	ld a, $FB
	ld i, a
	im 2
END ASM 

vt2:
asm 
vt2player:
	incbin "vt49152.bin"
end asm 

asm 
music:
	incbin "round1.pt3"
end asm       