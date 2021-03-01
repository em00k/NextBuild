'!ORG=32768
' quick example for parallax scrolling using the copper 
' emk20

border 0 		
#include <nextlib.bas>
		
asm 
	nextreg $7,3							; 28mhz 
	nextreg $14,0						; trans black 
	nextreg $4A,0						; trans black 
	nextreg $68,%10010000					; ULA CONTROL REGISTER disable ula 
	NextReg $15,%00010011					; sprites on border, SUL 
	nextreg $08,%01001010   ; $50			; disable ram contention, enable specdrum, turbosound
	nextreg $12,16

end asm        

paper 0 : ink 7 : flash 0 : border 0 : cls 

ShowLayer2(1)
LoadBMP2("para.bmp")						

dim a,b as ubyte 
dim add as uinteger 
a = 0
b=0

SetCopper()								' ini copper 

do 
	WaitRetrace(10)

	b=16							
	add=@firstindex+1						' point to the bit in the copper data we want to adjust 
	for l = 0 to 10
		poke (add),a*(12-l>>1)			' this sets the scroll offset 
		poke (add+2),(b+(l<<3))			' for this particular line 
		add=add+4
	next l 
	b=9
	for l = 11 to 22						' then for the bottom 
		poke (add),a*(251+(l>>1))			' scroll offset 
		poke (add+2),(b+(l<<3))			' on line 
		add=add+4						' size of the copper data blobs 
	next l 
	SetCopper()							' rerun the copper 
	a=a+1  								' general x offset 
loop 

sub SetCopper()

' WAIT	 %1hhhhhhv %vvvvvvvv	Wait for raster line v (0-311) and horizontal position h*8 (h is 0-55)
' MOVE	 %0rrrrrrr %vvvvvvvv	Write value v to Next register r
' https://wiki.specnext.dev/Copper

	NextReg($61,0)	' set index 0
	NextReg($62,0)	' set index 0

	asm 
	
	ld hl,copperdata						; ' coppper data address 
	ld b,endcopperdata-copperdata ;' length of data to upload

copperupload:
	ld a,(hl)										; put first byte of copper buffer in to a 
	dw $92ED										; nextreg a, sends a to 
rval:	
	DB $60										  ; this register, $60 = copper data 
	inc hl											; and loop 
	djnz copperupload

end asm							
	
	'NextReg($61,%00000000)
	NextReg($62,%11000000)


end sub 
 
asm: 	
copperdata:
	; ' T+V h  v  r  pal val 
	; ' h = horizontal line, v vertical , r = reg , pal = 
	;%1hhhhhhv 
	
	; WAIT 0,0 
	index equ 0
	regcop equ $16
	
	db %10000000,0						; 1HHHHHHV VVVVVVVV
	db 0,0
	
	db %11001000,0

end asm 
firstindex: 
asm 
	db regcop,129
	db %11001000,16
	db regcop,65
	db %11001000,32
	db regcop,33
	db %11001000,48
	db regcop,1
	db %11001000,64
	db regcop,1
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,140
	db regcop,0
	db %11001000,254
	db regcop,161
	db $ff,$ff

endcopperdata:	
end asm 

Sub ConvertRGB(byval bank as ubyte)

	asm 
		PROC 
		LOCAL tstack, outstack , outbank, convertout, nbpalhl
			di 
			ld (outstack+1),sp
			ld sp,tstack
			push ix 
			push af  
			getreg($52)						; a = current $4000 bank 
			ld (outbank+3),a 					; 
			pop af 
			nextreg $52,a 
		
remapcolours:
			nextreg $43,%00010001
			nextreg $40,0
			; ld (palfade),a 							; number of shifts for fade def = 5
			ld c,a 									; store this in c  
			ld hl,$4000								; get hl = start of palette, RGB format. 
			;ld de,palettenext 						; where to put our next palette 
			ld b,0									; number of entries to walk through
			
indexloop:
			push bc 								; save our loop counter on stack 
			push de 								; save our next palette addres 

			ld a,(hl)
			; ' BLUE 
			; b9>>5
			
			ld d,0 : ld e,a : ld b,5 : bsrl de,b 	; b9>>5
			ld a,e : ld (tempbytes+2),a 			; store at tempbytes+2
			
			inc hl : ld a,(hl)						; more to green byte put in a 
		
			; ' GREEN 
			; ((g9 >> 5) << 3)
			
			ld d,0 : ld e,a : ld b,5 : bsrl de,b 	; g9>>5
			ld b,3 : bsla de,b : ld a,e 			; << 3
			ld (tempbytes+1),a 						; store at tempbytes+1
		
			inc hl 									; move to next bit 

			; ' RED 
			; ((r9>>5) << 6)
			
			ld d,0 									; make sure d = 0 
			ld e,(hl)								; get red in to hl 
			ld b,5									; shift right c times 
			bsrl de,b  								; r9>>5
			ld b,6									; and right 
			bsla de,b 								; << 6
			push de 								; result will be 16bit, store on stack 
		
			inc hl : inc hl 						; move to next rgb block 
			
			; now OR r16 g8 b8, hl = red16, de points to green/blue bytes 
			exx  									; use shadow regs 
			pop hl 									; pop back red from stack into hl  
			ld de,(tempbytes+1)						; point de to green and blue 
			ld a,l	
			or d 									; or e & l into a 
			or e									; or d & a into a 
			ld l,a 									; put result in a 
			ld (nbpalhl+1),hl						; store at nb_pal_hl 
		
			exx										; back to normal regs 
			pop de 									; pop back palette address 
			push hl 								; save hl as its the offset into rgb palette 
			
nbpalhl:
			ld hl,0000								; smc from above 
			ld b,l 
			srl h 									; shift hl right 
			rr l 
			ld a,l 									; result in a 
			 
			nextreg $44,a
			ld (de),a 								; store first byte into or nextpalette ram 
			inc de 								; us commented out but could be used 
			; next byte 						 	; 
			ld a,b   
			and 1								; and 1 and store blue bit 
			ld (de),a 
			inc de 								; move de to next byte in memory 
			nextreg $44,a 
			 
			pop hl 									; get back the rgb palette address 
			pop bc									; get loop counter back 
		
			djnz indexloop		

outbank:
			nextreg $52,0
			pop ix 
outstack: 
			ld sp,0
			
			jp convertout		
tempbytes:
			dw 0,0
space:
			ds 8
tstack: 	db 0 		
convertout:
		
		ENDP 
	
	end asm 

end sub 

sub LoadBMP2(byval fname as STRING)

	'dim pos as ulong
	
	'pos = 1024+54+16384*2

	asm 
		PROC 
		LOCAL outstack, eosadd, outbank, loadbmploop, flip_layer2lines, copyloop, decd
		LOCAL startoffset, L2offsetpos, thandle, offset, loadbmpend
			di 
			push ix  
			getreg($52)						; a = current $4000 bank 
			ld (outbank+3),a 					; 
			ld a,(IX+7)
			ld (flip),a 
			;
			; hl address 
			ld a,(hl)
			add hl,2 
			push hl		
			add hl,a 
			ld (eosadd+1),hl
			ld a,(hl)
			ld (eosadd+4),a  
			ld (hl),0 
			pop ix 
		
			ld a, '*' 						; use current drive
			ld b, FA_READ 					; set mode
			ESXDOS : db F_OPEN 	
			; a = handle 	
			ld (thandle),a 	
			getreg($12) 						; get L2 start 
			add a,a 	
			ld (startbank),a 					; start bank of L2 
			ld b,7							; loops 8 times 
			ld c,a 
		
loadbmploop:
			ld a,c							; get the bank in c and put in a 
			nextreg $52,a					; set mmu slot 2 to bank L2bank ($4000-5fff)
			inc c	
			push bc 
			
			; now seek 
			ld a,(thandle)
			ld ixl,0 
			ld l,0 
			ld bc,0
			ld de,(L2offsetpos)
			ESXDOS : db F_SEEK
			
			; now read 
			ld a,(thandle)
			ld ix,$4000
			ld bc,$2000
			ESXDOS : db F_READ 
			
			;ld a,(flip)
			;or a 
			call flip_layer2lines
			
			ld hl,(L2offsetpos)
			ld de,$2000	
			sbc hl,de
			ld (L2offsetpos),hl
			
			pop bc 
			djnz loadbmploop 
			
			ld a,(thandle)
			ESXDOS : db F_CLOSE
			
			ld hl,startoffset
			ld (L2offsetpos),hl 
			
outbank:
			nextreg $52,0
eosadd:
			ld hl,000
			ld (hl),0 
			pop ix 
outstack: 
		;	ld sp,0
			
			jp loadbmpend

flip_layer2lines:
	
			; $4000 - $5fff Layer2 BMP data loaded 
			; the data is upside down so we need to flip line 0 - 32
			; hl = top line first left pixel, de = bottom line, first left pixel 
			ld hl,$4000 : ld de,$5f00 : ld bc,$1000
	
copyloop:	
			ld a,(hl)						; hl is the top lines, get the value into a
			ex af,af'						; swap to shadow a reg 
			ld a,(de)						; de is bottom lines, get value in a 
			ld (hl),a						; put this value into hl 
			ex af,af'						; swap back shadow reg 
			ld (de),a 						; put the value into de 
			inc hl							; inc hl to next byte 
			inc e							; only inc e as we have to go left to right then up with d 
			ld a,e							; check e has >255
			or a							
			call z,decd					; it did do we need to dec d 
			dec bc							; dec bc for our loop 
			ld a,b							; has bc = 0 ?
			or c
			jp nz,copyloop					; no carry on until it does 
			ret 
decd:
			dec d 							; this decreases d to move a line up 
			ret					

startoffset equ 1078+16384+16384+8192		
		
L2offsetpos:
			dw startoffset
	
startbank:
			db 32
			db 0 
flip: 		db 0 
			
thandle:
			db 0 
offset:	
			dw 0 
loadbmpend:
		ENDP 
	end asm 
			
end sub  