#DEFINE BREAK \
	DB $DD\
	DB $01		
	
' ; -Minimal ayFX player v0.15 06/05/06 ---------------------------;
' ; Original by Shiru, adapted for ZXBasic by em00k for NextBuild 19/08/18
' ; ;
' ; The simplest effects player. Plays effects on one AY,;
' ; without music on the background. Priority of channel selection: if available;
' ; free channels, one of them is selected. If free;
' ; there are no channels, the longest sounding is selected. Procedure;
' ; plays registers AF, BC, DE, HL, IX. ;
' ; ;
' ; Initialization:;
' ; ld hl, the address of the effects bank;
' ; call AFXINIT;
' ; ;
' ; Start the effect:;
' ; ld a, the number of the effect (0..255);
' ; call AFXPLAY;
' ; ;
' ; In the interrupt handler:;
' ; call AFXFRAME;
' ; ;
' ; ------------------------------------------------- -------------;
' 
' 
' ; channel descriptors, 4 bytes per channel:
' ; +0 (2) current address (channel is free, if high byte = # 00)
' ; +2 (2) sound effect time
' ; ...;
' 
' 

SFXInit(@gamesfx)								' init the sfx with memory of sfx bank

PlayFX(2)													' play intial sound 

do 

	PlayFrame()										' needs to be called every 50th, see interrupt version to avoid this. 

	a=(code inkey)-65								' read some keys
	if a>0 and a<121-65 
		if p=0												' simple debounce 
			PlayFX(a)										' play selected sound 
			print a
			p=1
		endif 
	else 
		p=0
	endif 
	
	pause 1

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
			DB 0 
END ASM 

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

SUB fastcall PlayFrame()
asm 
	; ------------------------------------------------- -------------;
	; Play the current frame. ;
	; Parameters does not. ;
	; ------------------------------------------------- -------------;
	push ix 
	push hl
	AFXFRAME:
		ld bc,$03fd
		ld ix,afxChDesc

	afxFrame0:
		push bc
		
		ld a,11
		ld h,(ix+1)			;comparing the highest byte of the address to <11
		cp h
		jr nc,afxFrame7		; the channel does not play, we skip
		ld l,(ix+0)
		
		ld e,(hl)			; take the value of the information byte
		inc hl
				
		sub b				;select the volume register:
		ld d,b				;(11-3=8, 11-2=9, 11-1=10)

		ld b,$ff			; output the volume value
		out (c),a
		ld b,$bf
		ld a,e
		and $0f
		out (c),a
		
		bit 5,e				;will the tone change?
		jr z,afxFrame1		; the tone does not change
		
		ld a,3				;select the tone registers:
		sub d				;3-3=0, 3-2=1, 3-1=2
		add a,a				;0*2=0, 1*2=2, 2*2=4
		
		ld b,$ff			; output the tone values
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
		bit 6,e				;is there a noise change?
		jr z,afxFrame3		;noise does not change
		
		ld a,(hl)			;read the value of noise
		sub $20
		jr c,afxFrame2		; less than # 20, play next
		ld h,a				; otherwise the end of the effect
		ld b,$ff
		ld b,c				;in BC we record the longest time
		jr afxFrame6
		
	afxFrame2:
		inc hl
		ld (afxNseMix+1),a	;keep the noise value
		
	afxFrame3:
		pop bc				;restore the value of the cycle in B
		push bc
		inc b				;the number of shifts for flags TN
		
		ld a,%01101111		;mask for flags TN
	afxFrame4:
		rrc e				;shift flags and mask
		rrca
		djnz afxFrame4
		ld d,a
		
		ld bc,afxNseMix+2	;we store the values ??of the flags
		ld a,(bc)
		xor e
		and d
		xor e				;E is masked with D
		ld (bc),a
		
	afxFrame5:
		ld c,(ix+2)			;increase the time counter
		ld b,(ix+3)
		inc bc
		
	afxFrame6:
		ld (ix+2),c
		ld (ix+3),b
		
		ld (ix+0),l			;save the changed address
		ld (ix+1),h
		
	afxFrame7:
		ld bc,4				;go to the next channel
		add ix,bc
		pop bc
		djnz afxFrame0

		ld hl,$ffbf			;output the noise and mixer values
	afxNseMix:
		ld de,0				;+1(E)=noise, +2(D)=mixer
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
		pop hl 
		pop ix 				;' for safe return for ZXB 
	
	END ASM 
END SUB 


sub fastcall PlayFX(byval fx as ubyte)

	ASM 
	; ------------------------------------------------- -------------;
	; Launch the effect on a free channel. Without ;
	; free channels is selected the longest sounding. ;
	; Input: A = number of the effect 0..255;
	; ------------------------------------------------- -------------;


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
	end asm 
end sub 

 