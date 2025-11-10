'!ORG=24576
'#!v
'!sna "h:\wav20.snx" -a
'ww#!noemu
cls 
#include <nextlib.bas>
dim scaler,dmaloop  as ubyte
dim off as uinteger
dim tlen as uinteger

NextReg(7,3)
showwave($c000)
nib = 46
tlen = @sampleend-@sample-44
div = tlen / 32
dmaloop=1
' set up the dma play, start = @ sample+64 (+WAV header),length,scaler and repeat flag

DMAPlay(@sample+44,tlen,100,1)
print at 18,0;"Key 1-9 for keys O/P finetune"
Print at 1,0;"ftune  ";nib;"  "
print at 1,11;"Loop On  (l=on/off)"
print at 0,10;tlen 
DO : 

	k=inkey$ 
	print at 0,0;k
	if k="" and dbounce = 1
		dbounce = 0 
		Print at 0,3;"   "
	elseif k="p" and dbounce = 0 
		nib = nib + 1 
		DMAUpdate(scaler+nib)
		dbounce = 1
		Print at 1,0;"ftune  ";nib;"  "
	elseif k="o" and dbounce = 0 
		nib = nib - 1 
		DMAUpdate(scaler+nib)
		dbounce = 1
		Print at 1,0;"ftune  ";nib;"  "
	elseif k="l" and dbounce = 0 
		dmaloop=1 - dmaloop 
		l$="OffOn "
		print at 1,11;"Loop ";(l$( dmaloop*3 to dmaloop*3+2))
		DMALoop(dmaloop)
		dbounce = 1
	elseif k<>"" and dbounce = 0 
		scaler = peek(@table+cast(uinteger,val(k))) 
		DMAUpdate(scaler+nib)
		dbounce = 1
		Print at 0,3;"key"
		'print at 0,7;code k;" "
	endif 
	'pause 1 
	
	if dbounce = 1 
		playtrig=1
		poke 22912+bl,0+8*7
		bl = 0
		beak = 31
	endif 

	out $6b,$BB : Out $6b,%10 : a=in($6b)
	out $6b,$BB : Out $6b,%100 : b=in($6b)
	out $6b,$BB : Out $6b,%1 : c=in($6b)
	bl = cast(ubyte,(b*256+a)/div)
	if bl<32
		'if bl < 32 : bl = in ($6b) : else : playtrig = 0 : poke 22912+bl,0+8*7 : bl = 0 :  endif 
		poke 22912+cast(uinteger,bl)-1,0+8*7
		poke 22912+cast(uinteger,bl),2+8*1
	endif 
	

'	print at 0,10;" ";a;" " 
'	print at 0,14;" ";b;" " 
	print at 2,14;" ";c;" " 
	print at 0,24;b*256+a;" " 
	
LOOP 

table:
asm 
dSTEP EQU 12
	DB dSTEP,dSTEP*2,dSTEP*3,dSTEP*4,12+dSTEP*5,dSTEP*6,dSTEP*7,dSTEP*8,dSTEP*9,dSTEP*10,dSTEP*11,dSTEP*12
	DB dSTEP,dSTEP*2,dSTEP*3,dSTEP*4,dSTEP*5,dSTEP*6,dSTEP*7,dSTEP*8,dSTEP*9,dSTEP*10,dSTEP*11,dSTEP*12
end asm 

sub showwave(waveaddress as uinteger)

	tlen = @sampleend-@sample-44
	tlen = tlen /512 : off = 0 
	' rubbish waveform draw
	for x = 0 to 512
	
		yy=cast(byte,peek(@sample+44+cast(uinteger,off)))-80
		print at 2,0;@sample+44+cast(uinteger,off)
		plot x/2,80+(yy/8)
		draw 0,-(192+yy)
		off=off+tlen
	
	next x 
	
end sub 

SUB DMAUpdate(byval scaler as ubyte)
	'
	asm 
	
		; quick sets DMA 
		; a = new value on entry 
		ld e,a
		ld bc,$6b		; DMAPORT
		ld a,$68		; R2-PORT B ADDRESS
		out (c),a
		ld a,$22		; CYCLE LENGTH PORT
		out (c),a
		ld a,e			; new prescaler value 
		out (c),a
		ld a,$cf		; R6-LOAD we will now start from the begining 
		out (c),a
		ld a,$87		; R6-ENABLE DMA
		out (c),a
		
		
	end asm 
	print at 0,18;scaler 
end sub 
SUB DMALoop(byval dmsloopv as ubyte)
	asm 
		; quick sets DMA 
		ld e,a
		ld bc,$6b
		ld a,e			; new scaler value 
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
	BREAK
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
	
	LD C,Z80DMAPORT
WAITFBA:
	IN A,(C)
	BIT 2,A
	JR NZ,WAITFBA
	
DMA:

	DEFB $C3			;R6-RESET DMA
	DEFB $C7			;R6-RESET PORT A TIMING
	DEFB $CA			;R6-SET PORT B TIMING SAME AS PORT A

	DEFB $7D 			;R0-TRANSFER MODE, A -> B
dmaaddress:
	DEFW $C000	;R0-PORT A, START ADDRESS
dmadlength:
	DEFW 8192	;R0-BLOCK LENGTH

	DEFB $54 			;R1-PORT A ADDRESS INCREMENTING, VARIABLE TIMING
	DEFB $2			;R1-CYCLE LENGTH PORT B

	DEFB $68			;R2-PORT B ADDRESS FIXED, VARIABLE TIMING
	DEFB $22			;R2-CYCLE LENGTH PORT B 2T WITH PRE-ESCALER
	;DEFB 27			;R2-PORT B PRE-ESCALER
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
	DEFB $100			;MASK - ONLY PORT A HI BYTE

	DEFB $CF			;R6-LOAD
	DEFB $B3			;R6-FORCE READY
	DEFB $87			;R6-ENABLE DMA
		  
DMAEND:
	exx 
	push hl
	
	end asm 

end sub 

sample:
ASM 
sample:
	incbin "data/lab.wav"
	defs 10,$7f
end asm 
sampleend:
          