'#!v
'!bin "h:\wav20.bin" -a
'#!noemu
#include <nextlib.bas>
dim scaler,dmaloop,x  as ubyte
scaler = 52
NextReg(7,3)
NextReg(8,254)
NextReg(2,128)
NextReg($82,255)       ' INTERNAL PORT DECODING B0-7 REGISTER
NextReg($83,255)       ' NTERNAL PORT DECODING B8-15 REGISTER
NextReg($84,255)       ' NTERNAL PORT DECODING B8-15 REGISTER
NextReg($85,$8f)       ' NTERNAL PORT DECODING B8-15 REGISTER
NextReg($03,%10110011)       ' MACHINE TYPE REGISTER


' lets load a sample in at $e000 from bank 35+ (why not)
dim startbank as ubyte = 35
dim samplesize as ulong = 527606			' remember of the 64 byte WAV header
dim remainder,laddress as uinteger
dim sosffet as ulong
dim tb,a,b as ubyte			' temp bank holder
MMU8(5,startbank)													' put bank in place 
chunks = samplesize / 8192 								' how many banks do we need?
remainder = samplesize mod chunks 					' and what will be the remainder 
sosffet = 64															' skip WAV header 
laddress=$a000
for x=0 to chunks			
	MMU8(5,startbank+x)
	LoadSD("gallery.wav",laddress,8192,sosffet)
	sosffet = sosffet + 8192
next 
 
if remainder>0
	chunks=chunks+1
 	MMU8(5,startbank+chunks)
 	LoadSD("gallery.wav",laddress,cast(ulong,remainder),sosffet)
endif 
dmaloop=0

' set up the dma play, start = @ sample+64 (+WAV header),length,scaler and repeat flag

DMAPlay(laddress,8192,scaler,1)

MMU8(5,startbank)

'SetUpIM()				' call the setup routine 

do
	print at 0,0;"Sample postision : "; sampposition ; "      "
	print at 1,0;"Bank  " ; startbank+tb 
	print at 2,0;"Chunk " ; tb ; "  "
	print at 3,0;"Memory address " ; 57344+((b*256)+a)
	MyCustomIM()
	'pause 1
loop 
stop 

sub MyCustomIM()
	out $6b,$BB : Out $6b,%10 : a=in($6b)
	out $6b,$BB : Out $6b,%100 : b=in($6b)
	if b=32
		tb = tb + 1 : if tb = chunks : tb = 0 : endif 
		MMU8(5,startbank+tb)
		DMAUpdate(scaler)
	endif 
	sampposition = cast(ulong,tb) *8192+((b*256)+a)
	if sampposition>=samplesize-128
		tb = 0 : MMU8(5,startbank+tb) : DMAUpdate(scaler)
	endif 	
end sub 

SetUpIM()				' call the setup routine 


SUB DMAUpdate(byval scaler as ubyte)
	asm 
		; quick sets DMA 
		ld e,a : ld bc,$6b : ld a,$68 : out (c),a : ld a,$22 : out (c),a
		ld a,e			; new scaler value 
		out (c),a : ld a,$cf : out (c),a : ld a,$87 : out (c),a
	end asm 
end sub 

SUB DMALoop(byval dmsloopv as ubyte)
	asm 
		; quick sets DMA 
		ld e,a
		ld bc,$6b
		ld a,e				; new scaler value 
		cp 1 : jr z,dmalooprepeat
		ld a,$82 : jr dmalooprepeat+2
dmalooprepeat:
		ld a,$b2 
		out (c),a
	end asm 
	
end sub 

Sub fastcall DMAPlay(byval address as uinteger,dmalen as uinteger, byval scaler as ubyte,byval repeat as ubyte)

	asm  
	Z80DMAPORT EQU 107
	SPECDRUM EQU $FFDF
	BUFFER_SIZE	EQU 8192
PLAY:
	ld (dmaaddress), HL 
	pop hl 
	EXX 
	pop hl : ld (dmadlength), hl 
	pop af : ld (dmascaler),a
	pop af : ; repeat flag 
	; deal with setting repeat flag
	cp 1 : jr z,setrepeaton
	ld a,$82 : jr setrepeaton+2
setrepeaton:
	ld a,$b2

	ld (dmarepeat),a
	
	; LOAD DMA 

	LD HL,DMA
	LD B,DMAEND-DMA
	LD C,Z80DMAPORT
	OTIR
	
LOOPA:
	JP DMAEND
	
DMA:

	DEFB $C3			;R6-RESET DMA
	DEFB $C7			;R6-RESET PORT A TIMING
	DEFB $CA			;R6-SET PORT B TIMING SAME AS PORT A

	DEFB $7D 			;R0-TRANSFER MODE, A -> B
dmaaddress:
	DEFW $C000		;R0-PORT A, START ADDRESS
dmadlength:
	DEFW 8192			;R0-BLOCK LENGTH

	DEFB $54 			;R1-PORT A ADDRESS INCREMENTING, VARIABLE TIMING
	DEFB $2				;R1-CYCLE LENGTH PORT B

	DEFB $68			;R2-PORT B ADDRESS FIXED, VARIABLE TIMING
	DEFB $22			;R2-CYCLE LENGTH PORT B 2T WITH PRE-ESCALER
dmascaler:
	DEFB 100			;R2-PORT B PRE-ESCALER
	;		  DEFB 255			;R2-PORT B PRE-ESCALER

	;		  DEFB $AD 		;R4-CONTINUOUS MODE
	DEFB $CD 			;R4-BURST MODE
	DEFW SPECDRUM		;R4-PORT B, START ADDRESS

	;DEFB $B2			;R5-RESTART ON END OF BLOCK, /CE + /WAIT, RDY ACTIVE LOW
	;DEFB $A2			;R5-RESTART ON END OF BLOCK, RDY ACTIVE LOW
dmarepeat:			; $B2 for short burst $82 for one shot 
	DEFB $82			;R5-STOP ON END OF BLOCK, RDY ACTIVE LOW
	;
	DEFB $BB			;READ MASK FOLLOWS
	DEFB $10			;MASK - ONLY PORT A HI BYTE - where does the mask come from? WR6

	DEFB $CF			;R6-LOAD
	DEFB $B3			;R6-FORCE READY
	DEFB $87			;R6-ENABLE DMA
		  
DMAEND:
	exx 
	push hl
	
	end asm 

end sub 


Sub SetUpIM()
	' this routine will set up the IM vector and set up the relevan jp 
	' note I store the jp in the middle of the vector as in reality 
	' xxFF is all that is needed, you can change this to something else
	' if you wish 
asm 
	di 
	ld hl,IMvect
	ld de,IMvect+1
	ld bc,257
	ld a,h 
	ld i,a 
	ld (hl),a 
	ldir 
	ld h,a : ld l, a : ld a,$c3 : ld (hl),a : inc hl
	ld de,._ISR : ld (hl),e : inc hl : ld (hl),d 
	IM 2 
	ei  
end asm 
end sub 


Sub fastcall ISR()
	' fast call as we will habdle the stack / regs etc 
	
	asm 
		;BREAK 
		push af : push bc : push hl : push de : push ix : push iy 
		ex af,af'
		push af : exx 
		push bc : push hl : push de
		exx 
	end asm 
	
	' routine to be called 
	
	'MyCustomIM()
	out $6b,$BB : Out $6b,%10 : a=in($6b)
	out $6b,$BB : Out $6b,%100 : b=in($6b)
	if b=32
		tb = tb + 1 : if tb = chunks : tb = 0 : endif 
		MMU8(5,startbank+tb)
		DMAUpdate(scaler)
	endif 
	sampposition = cast(ulong,tb) *8192+((b*256)+a)
	if sampposition>=samplesize-128
		tb = 0 : MMU8(5,startbank+tb) : DMAUpdate(scaler)
	endif 
	
	asm 
		exx 
		pop de : pop hl : pop bc
		exx : pop af 
		ex af,af'
		pop iy : pop ix : pop de : pop hl : pop bc : pop af 
		ei
		
		;rst $38
		;BREAK
		;jp 56
	end asm 

end sub 

' do this call to prevent optimizations from removing ISR() - it doesnt actually get run 

ISR() 

Imtable:
ASM
	ALIGN 256
	IMvect:
	defs 257,0
end asm  