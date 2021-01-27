'!ORG=32768
' Just a little play around, requries mouse
' 

#include <nextlib.bas>

NextReg(8,$fe)								' no contention 
'NextReg($43,$1)								' ULANext enabled 
NextReg(7,3)									' 14mhz
NextReg($43,$0)								' ULA palette 
NextReg($14,0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
NextReg($40,0)   						' 16 = paper 0 on L2 palette index 
NextReg($41,$0)  							'	Palette Value 
 
NextReg($12,12)  							' layer2 rams   16kb banks 
NextReg($13,15)  							' layer2 shadow

NextReg($42,7)							' ULANext number of inks : 255 127 63 31 15 7 
'NextReg($4A,$0)							' Fallback trans

paper 7 : ink 0: border 7 : cls

'POKE UINTEGER 23675,@guiblocks

'MMU8(7,34)
LoadSDBank("egg.SPR",0,0,0,32)
'zx7Unpack(@mousecur,$c000)
asm : nextreg $56,32 :  nextreg $57,33 : end asm 
InitSprites(15,49152)
asm : nextreg $56,00 :  nextreg $57,01 : end asm 
LoadSDBank("clock.wav",0,0,0,40)
LoadSDBank("minig.wav",0,0,0,41)
'MMU8(7,1)
CLS256(255) : ShowLayer2(1)
NextReg($15,%00000001)
dim x,y,mbutt,oldmox, oldmoy, mousemapid, menu,rx,ry, click, bclick  as ubyte
dim firspr,eggstate,crackone,cracktwo,eggdead,eggpower,frdelay,fr,eggframe,flip as ubyte 
dim scaler,dmaloop,bx,by,bt,samplebank  as ubyte
dim off as uinteger
dim tlen as uinteger

tlen = 1024
dmaloop=1 : eggsprite = 2 : crackone = 6 : cracktwo = 7 : eggdead = 8 : eggpower = 2
eggframe = eggsprite : samplebank = 0 


MMU8(7,40)
DMAPlay($e000,1024,100,0)

UpdateSprite(100,100,1,eggframe,0,0)

firspr=1 : bclick = 0 
newbaddie()
DO 													' next loop

 newmouse() : oldmox=mox : oldmoy=moy : 
 mox=peek(@Mouse+1) :  moy=peek(@Mouse+2) :  mbutt=peek(@Mouse)
 'rx = mox / 6 : ry = moy / 8
 'readmapaddr=peek(@ScreenData+(ry<<5)+rx)
 'addr=cast(uinteger,ry)*42+rx
 'mousemapid=peek(@ScreenData+cast(uinteger,ry)*42+rx)
 'print at 1,0;mousemapid
 'print at 0,0;mox,moy
 'print at 1,0;bx,by
 sprx=(cast(uinteger,mox)) : spry=(moy)
 UpdateSprite(32+sprx,32+spry,63,firspr,0,0)
 if firspr=1 : firspr = 0 : endif 
 if (mbutt band 15=13) and bclick<1						' left mb
		border 1
		firspr=1
		if samplebank=0
		bclick=2
		endif 
		DMAUpdate(100)
		PlotL2(mox+6,moy+7,32)
	elseif mbutt band 15=14	and bclick=0						' right mb
		'RightClickTwo()
		bclick=1
	'elseif mbutt band %11111000<>ombutt  ' mouse wheel 
	ELSEIF mbutt band 15 = 15 		'mbutt band 15 = 15						' no mouse, used for button debounce
		bclick=0
		firspr=0
		border 0 
 endif
 
 ik = inkey
 if ik = "t" and keybut = 0 
		if samplebank = 1 
			samplebank =  0
			border 2
			keybut = 1
		else 
			border 7
			samplebank = 1
			keybut = 1
		endif 
		MMU8(7,40+samplebank)
	elseif ik = ""
		keybut = 0 
	endif 
 updatebaddies()
 
 pause 1 
loop until ex=5

sub newbaddie()
	paper 6 : cls 
	bx = rnd *220 : by = rnd *180 : bt = int(rnd*3)
	if bt = 0 
		eggframe = eggsprite : flip = 0 
	elseif bt=1 
		eggframe = 4 : flip = %00001000 : bx  = 0
	elseif bt=2 
		eggframe = 4 : flip = 0 : bx = 255
	endif 
	UpdateSprite(cast(uinteger,bx)+32,by+32,1,eggframe,flip,0)
	eggstate = 0 : eggpower = 2
	paper 7 : cls 
end sub 

Sub updatebaddies()
	
	UpdateSprite(cast(uinteger,bx)+32,by+32,1,eggframe+fr,flip,0)
	
	if frdelay=0 
		fr = 1 - fr 
		frdelay = 10
	else 
		frdelay = frdelay - 1 
	endif 
	if bt>0
		if eggstate<2 
		if bt = 1
			bx = bx - 2 
		elseif bt = 2
			bx = bx + 2
		endif 	
		endif 
		if eggstate>0 
		UpdateSprite(cast(uinteger,bx)+32,by+32,62,crackone+eggstate,0,0)
		endif 
	endif 
	
	'print at 3,0;bx-8
	if mox>(bx-4) and mox<bx+8
		if moy>by-4 and moy<by+4
		border 6
		if firspr=1
		for sp= 0 to 30
			px = bx + rnd*16 : py = by + rnd*(sp>>1)
			PlotL2((px),(py),224+fr)
			';'PlotL2((px+1),(py+1),223+fr)
		next sp 

			if bt = 1
				bx = bx + 4
			elseif bt=2
				bx = bx - 4
			endif 
			eggpower=eggpower-1
			if eggpower = 0 
			UpdateSprite(cast(uinteger,bx)+32,by+32,62,crackone+eggstate,0,0)
			
			print at 5,0;eggstate
			eggstate=eggstate + 1 
			eggpower = 2 
			if eggstate=3 : RemoveSprite(1,1) : eggstate= 2 : eggpower = 0 : newbaddie() : endif 
			endif 
		endif 
			
			
		endif
	endif 
end sub 



sub newmouse()
	asm 
	; Jim bagley mouse routines, clamps mouse and dampens x & y 
	ld	de,(nmousex) : ld (omousex),de : ld	a,(mouseb)
	ld (omouseb),a
	
	call getmouse : ld (mouseb),a : ld (nmousex),hl

	ld a,l : sub e : ld e,a : ld a,h : sub d : ld d,a
	ld (dmousex),de			;delta mouse
	
	ld d,0 : bit 7,e : jr z,bl : dec d
bl: 
	ld hl,(rmousex) : add hl,de : ld bc,4*256
	call rangehl : ld (rmousex),hl : sra  h : rr l
	sra h : rr l : ld a,l : ld (mousex),a : ld de,(dmousey)
	ld d,0 : bit 7,e : jr z,bd : dec d
bd: 
	ld hl,(rmousey) : add hl,de : ld bc,4*192+64
	call rangehl : ld (rmousey),hl : sra  h : rr l
	sra h : rr l : ld a,l : ld (mousey),a

	jp mouseend
	
getmouse:
	ld	bc,64479 : in a,(c) : ld l,a 
	ld	bc,65503 : in a,(c) : cpl
	ld h,a : ld (nmousex),hl : ld	bc,64223
	in a,(c) : ld (mouseb),a : ret
rangehl:
	bit 7,h : jr nz,mi : or a : push hl
	sbc hl,bc : pop hl : ret c : ld	h,b
	ld l,c : dec hl : ret
mi:
	ld hl,0 : ret
mousex:
	dW	0
mousey:
	db	0
omousex:
	dW	0
omousey:
	db	0
nmousex:
	dW	0
nmousey:
	db	0
mouseb:
	db	0
omouseb:
	db	0
rmousex:
	dw	0
rmousey:
	dw	0
dmousex:
	db	0
dmousey:
	db	0

mouseend:
	ld a,(mouseb) : ld (Mouse),a : ld a,(mousex) : ld (Mouse+1),a
	ld a,(mousey) : ld (Mouse+2),a
	end asm 
end sub 

Mouse:
ASM
Mouse:
			db	0
			db	0
			db	0
end asm 

SUB DMAUpdate(byval scaler as ubyte)
	'
	asm 
		; quick sets DMA 
		;	BREAK 
		;'ld e,a						; 4
		ld bc,$6b					; 10					
		;'ld a,$68					; 7
		ld hl,$6822				; 10					
		out (c),h					; 12
		;'ld a,$22					; 7
		out (c),l					; 12
		;'ld a,e			; new scaler value 		7
		ld hl,$cf87				; 10
		out (c),a					; 12
		;'ld a,$cf					; 7
		out (c),h					; 12
		;'ld a,$87					; 7
		out (c),l					; 12				; 122			; 90-
	end asm 
	
end sub 
SUB DMALoop(byval dmsloopv as ubyte)
	asm 
		; quick sets DMA 
		;ld e,a
		ld bc,$6b
		;ld a,e			; new scaler value 
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
	DEFW $e000	;R0-PORT A, START ADDRESS
dmadlength:
	DEFW 8192	;R0-BLOCK LENGTH

	DEFB $54 			; 01010100 ;R1-PORT A ADDRESS INCREMENTING, VARIABLE TIMING
	DEFB $2			;R1-CYCLE LENGTH PORT B

	DEFB $68			; 01101000 R2-PORT B ADDRESS FIXED, VARIABLE TIMING
	DEFB $22			;R2-CYCLE LENGTH PORT B 2T WITH PRE-ESCALER
	;DEFB 27			;R2-PORT B PRE-ESCALER
dmascaler:
	DEFB 100			;R2-PORT B PRE-ESCALER
	;		  DEFB 255			;R2-PORT B PRE-ESCALER

	;		  DEFB $AD 		; 10101101 R4-CONTINUOUS MODE
	DEFB $CD 					; 11001101 R4-BURST MODE
	DEFW SPECDRUM		;R4-PORT B, START ADDRESS

	;DEFB $B2			;R5-RESTART ON END OF BLOCK, /CE + /WAIT, RDY ACTIVE LOW
	;DEFB $A2			;R5-RESTART ON END OF BLOCK, RDY ACTIVE LOW
dmarepeat:			; $B2 for short burst $82 for one shot 
	DEFB $82			;R5-STOP ON END OF BLOCK, RDY ACTIVE LOW
	;
	DEFB $BB			; 10111011 READ MASK FOLLOWS
	DEFB %00001000			;MASK - ONLY PORT A HI BYTE

	DEFB $CF			;R6-LOAD
	DEFB $B3			;R6-FORCE READY
	DEFB $87			;R6-ENABLE DMA
		  
DMAEND:
	exx 
	push hl
	
	end asm 

end sub 
    