'!vb
'!sna "h:\fx.sna" -a

#DEFINE BREAK \
	DB $DD\
	DB $01		


#DEFINE NextReg(REG,VAL) \
	ASM\
	DW $91ED\
	DB REG\
	DB VAL\
	END ASM 
	
' ; Multi AY ayFX and VTii playback on interrupt 
' ; em00k for NextBuild 19/08/18
	
' ; -Minimal ayFX player v0.15 06/05/06 ---------------------------;
' ; Original by Shiru, adapted for ZXBasic by em00k for NextBuild 19/08/18
' ; ;
' ; The simplest effects player. Plays effects on one AY,;
' ; without music on the background. Priority of channel selection: if available;
' ; free channels, one of them is selected. If free;

NextReg($8,%11111010)	
SFXInit(@gamesfx)								' init the sfx with memory of sfx bank
InitCallback(@music,@vt2,4)
SFXCallback(1,4)										' Enables Interrupt playback of PlayFrame()

'PlayFrame()											' needs to be called every 50th, not needed here as we're using interrupts 

do 

	a=(code inkey)									' read some keys
	if a>0 and a<121 
		if p=0												' simple debounce 
			PlaySFX(a-48)							' play selected sound 
			print a
			p=1
			if a = 45
				SFXCallback(0,0)						'		press - to turn off IM2 yafx
				SFXInit(@gamesfx)				' 	reinit to mute channels
			elseif a = 61								' 	press + to turn on IM2 ayfx
				SFXCallback(1,4)
			endif 
		endif 		
	else 
		p=0
	endif 
	
	pause 1
	poke 49157,$c7
loop 


gamesfx:

asm 	
	; this is an ay fx bank from ayFXedit by Shiru 
	incbin "game.afb"
end asm 


ASM 
	afxChDesc:
			DefS 3*4
	afxBankAd:
			DS 42
END ASM 

SUB InitCallback(byval musicadd as uinteger,byval vt2address as uinteger,byval bank as ubyte)
	ASM 
		di
		push hl 
		push ix 
		ld a,4
		ld hl,23388								; paging fix 
		ld (hl),16
		
		
		call bank4

		ld hl,vt2player
		ld de,PLAYERLOCATION
		ld bc,1617
		ldir
		ld l,(IX+4)
		ld h,(IX+5)								;' music address 
		ld de,51310
		ld bc,2500
		ldir 
		ld hl,51310

		call PLAYERLOCATION+3			;' init music 
		call bankorig
		;ei 
		ld hl,Ints
		ld a,$C3									; we need to store "jp Ints" for the ISR
		ld de,ISR
		ld (de),a									; jp 
		ld a,l
		inc de 										; next byte 
		ld (de),a									; h *  256 + ISR/256
		ld a,h
		inc de 										; next byte 
		ld (de),a									; ISR/256 
		ld hl,ISR
		ld a,h										; our jump jump vector needs to be filled $BFBF etc


		ld hl,IJUMP				; for cspect ISR JUMP starts
		ld (hl),a
		inc hl
		ld (hl),a
		
		ld hl,IJUMP
		dec hl 
		inc h 
		;ld hl,$AF00				; for fuse/Next ISR JUMP starts
		ld (hl),a

		inc hl 
		ld (hl),a
		
		pop ix 
		pop hl 
		ei 

	END ASM 
end sub 

sub SFXCallback(byval switch as ubyte,byval bank as ubyte)

asm 
		di
		push hl 
		push ix 
		ld a,(IX+5)
		
		cp 1
		jp nz,sfxoff

		ld a,(IX+7)
		ld (storedbank),a
	jp intend

storedbank:
		db 0 

	AFXFRAME:
		push hl 
		push ix 
		
		ld bc,$03fd
		ld ix,afxChDesc

	afxFrame0:
		push bc
		
		ld a,11
		ld h,(ix+1)					;comparing the highest byte of the address to <11
		cp h
		jr nc,afxFrame7			; the channel does not play, we skip
		ld l,(ix+0)
		
		ld e,(hl)						; take the value of the information byte
		inc hl
				
		sub b								;select the volume register:
		ld d,b							;(11-3=8, 11-2=9, 11-1=10)

		ld b,$ff						; output the volume value
		out (c),a
		ld b,$bf
		ld a,e
		and $0f
		out (c),a
		
		bit 5,e							;will the tone change?
		jr z,afxFrame1			; the tone does not change
		
		ld a,3							;select the tone registers:
		sub d								;3-3=0, 3-2=1, 3-1=2
		add a,a							;0*2=0, 1*2=2, 2*2=4
		
		ld b,$ff						; output the tone values
		out (c),a
		ld b,$bf
		ld d,(hl)
		inc hl
		out (c),d
		ld b,$ff
		inc a
		out (c),a
		ld b,$bf
		ld d,(hl)
		inc hl
		out (c),d
		
	afxFrame1:
		bit 6,e							;is there a noise change?
		jr z,afxFrame3			;noise does not change
		
		ld a,(hl)						;read the value of noise
		sub $20
		jr c,afxFrame2			; less than # 20, play next
		ld h,a							; otherwise the end of the effect
		ld b,$ff
		ld b,c							;in BC we record the longest time
		jr afxFrame6
		
	afxFrame2:
		inc hl
		ld (afxNseMix+1),a	;keep the noise value
		
	afxFrame3:
		pop bc							;restore the value of the cycle in B
		push bc
		inc b								;the number of shifts for flags TN
		
		ld a,%01101111			;mask for flags TN
	afxFrame4:
		rrc e								;shift flags and mask
		rrca
		djnz afxFrame4
		ld d,a
		
		ld bc,afxNseMix+2		;we store the values ??of the flags
		ld a,(bc)
		xor e
		and d
		xor e								;E is masked with D
		ld (bc),a
		
	afxFrame5:
		ld c,(ix+2)					;increase the time counter
		ld b,(ix+3)
		inc bc
		
	afxFrame6:
		ld (ix+2),c
		ld (ix+3),b
		
		ld (ix+0),l					;save the changed address
		ld (ix+1),h
		
	afxFrame7:
		ld bc,4							;go to the next channel
		add ix,bc
		pop bc
		djnz afxFrame0

		ld hl,$ffbf					;output the noise and mixer values
	afxNseMix:
		ld de,0							;+1(E)=noise, +2(D)=mixer
		ld a,6
		ld b,h
		out (c),a
		ld b,l
		out (c),e
		inc a
		ld b,h
		out (c),a
		ld b,l
		out (c),d
		pop ix 
		pop hl 
		ret 

	Ints:	
	di                  							; disable interrupts
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
	ld a,(storedbank)
	call bank4
	ld bc,65533											;' we want 2nd AY
	ld a,254
	out (c),a												;' switch it
	call $c005											;' play music on this one
	ld a,255												;' flip to 1sy AY 
	out (c),a
	call AFXFRAME       						;' play the current sfx
	call bankorig 
	
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
	ld hl,IJUMP
	ld a,$AE
	ld i,a
	IM 2
	jp initintsend
	sfxoff:
	IM 1
	initintsend:
	ei 
	pop ix 
	pop hl 
end asm
end sub 

SUB SFXInit(byval address as uinteger)
	ASM 
	
	; ------------------------------------------------- -------------;
	; Initialize the effects player. ;
	; Turns off all channels, sets variables. ;
	; Input: HL = bank address with effects;
	; ------------------------------------------------- -------------;
	
	AFXINIT:
		ld l,(IX+4)
		ld h,(IX+5)
		inc hl
		ld (afxBnkAdr+1),hl				;save the address of the offset table
		
		ld hl,afxChDesc		;mark all channels as empty
		ld de,$00ff
		ld bc,$0cfd
	afxInit0:
		ld (hl),d
		inc hl
		ld (hl),d
		inc hl
		ld (hl),e
		inc hl
		ld (hl),e
		inc hl
		djnz afxInit0

		ld hl,$ffbf			; initialize AY
		ld e,$15
	afxInit1:
		dec e
		ld b,h
		out (c),e
		ld b,l
		out (c),d
		jr nz,afxInit1
		ld (afxNseMix+1),de				;reset the player variables
	END ASM 	
END SUB 

sub fastcall PlaySFX(byval fx as ubyte)

	ASM 
	; ------------------------------------------------- -------------;
	; Launch the effect on a free channel. Without ;
	; free channels is selected the longest sounding. ;
	; Input: A = number of the effect 0..255;
	; ------------------------------------------------- -------------;
	PROC 

	AFXPLAY:
		ld de,0				;in DE, the longest time in the search
		ld h,e
		ld l,a
		add hl,hl
	afxBnkAdr:
		ld bc,0				;the address of the offset table of effects
		add hl,bc
		ld c,(hl)
		inc hl
		ld b,(hl)
		add hl,bc			;the effect address is obtained in hl
		push hl				;save the effect address on the stack
		
		ld hl,afxChDesc		;search
		ld b,3
	afxPlay0:
		inc hl
		inc hl
		ld a,(hl)			;compare the channel time with the largest
		inc hl
		cp e
		jr c,afxPlay1
		ld c,a
		ld a,(hl)
		cp d
		jr c,afxPlay1
		ld e,c				;emember the longest time
		ld d,a
		push hl				;remember the channel address + 3 in IX
		pop ix
	afxPlay1:
		inc hl
		djnz afxPlay0

		pop de				;take the effect address from the stack
		ld (ix-3),e			;enter in the channel descriptor
		ld (ix-2),d
		ld (ix-1),b			;zero the playing time
		ld (ix-0),b
		ENDP
	end asm 
end sub 

vt2:
asm 
vt2player:
	incbin "vt49152.bin"
end asm 

music:
asm 
	incbin "ROUND1.pt3"
end asm

ASM 
	PLAYERLOCATION 	EQU $c000		;'
	IJUMP 					EQU $AE00		;' this is where will have a repeated byte over over = ISR
	ISR 						EQU $AFAF		;'This is the location where we put a jump to our routine
bank4:	; swap to bank 4 @ 49152 - 16k
	; requries a=16kb bank 

;	di														;' no need for di.ei as we're calling with DI 
	ld d,a												; save a 
	ld a,(23388)   								;' Get current ram page @ $c000
	ld (bankst),a									;' save it for later 
	and 248												;' 
	or d 												;' or d 
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
	db 0
END ASM       