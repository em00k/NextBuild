'!bin "h:\temp.bin" -a

#include <nextlib.bas>

dim bigsize as ulong 
dim CWD$ as string at @outbuffadd
bigsize = 0

'CWD$="HELLO"
'print CWD$
BBREAK
'GetPath() : 
'print CWD$t
t$="c:car.bmp"+chr(0)
GetFileSize(t$( to ))
print bigsize
GetFileSize("c:car.bmp"+chr(0))
print bigsize

'recieveruartmem($dead,$0011FFFF)

'LoadSD("sprites.spr",0,16384,0)
'print @bufferfs

asm
di 
halt
end asm 
DO 
pause 1 
LOOP 


sub GetFileSize(filestring as string)

' ; ***************************************************************************
' ; * F_STAT ($ac) *
' ; ***************************************************************************
' ; Get unopened file information/status.
' ; Entry:
' ; A=drive specifier (overridden if filespec includes a drive)
' ; IX [HL from dot command]=filespec, null-terminated
' ; DE=11-byte buffer address
' ; Exit (success):
' ; Fc=0
' ; Exit (failure):
' ; Fc=1
' ; A=error code
' ;
' ; NOTES:
' ; The following details are returned in the 11-byte buffer:
' ; +0(1) drive specifier
' ; +1(1) $81
' ; +2(1) file attributes (MS-DOS format)
' ; +3(2) timestamp (MS-DOS format)
' ; +5(2) datestamp (MS-DOS format)
' ; +7(4) file size in bytes


asm 
	;dw $01DD
	LOCAL filename 
	LOCAL buffer 

		;pop bc 			; ret address
		;push ix			; save ix 
nsetdrive:
		BREAK 
		inc hl : inc hl 
		ld a,0
		push ix  
		push hl 
		pop ix 
;		'ld ix,filenamefs
		ld de,bufferfs
		rst $08
		db $ac
		jr nc,successfs
		jr c,failopen
		;a = error code 
		jr donefsizefs
; data

bufferfs:
		defs 11,0
failopen: 
		ld a,2
		out ($fe),a
		jr donefsizefs
successfs:
		ld a,3
		out ($fe),a
		ld hl,bufferfs+7
		ld de,._bigsize
		ld bc,4
		ldir 
		
donefsizefs:
		pop ix
	;	push bc
	;	dw $01DD
end asm 


end sub

sub GetPath()
asm 
 ; ***************************************************************************
 ; * F_GETCWD ($a8) *
 ; ***************************************************************************
 ; Get current working directory (or working directory for any filespec)
 ; Entry:
 ; A=drive, to obtain current working directory for that drive
 ; or: A=$ff, to obtain working directory for a supplied filespec in DE
 ; DE=filespec (only if A=$ff)
 ; IX [HL from dot command]=buffer for null-terminated path
 ; Exit (success):
 ; Fc=0
 ; Exit (failure):
 ; Fc=1
 ; A=error code
 ;
 ; NOTE:
 ; If obtaining a path for a supplied filespec, the filename part (after the
 ; final /, \ or :) is ignored so need not be provided, or can be the name of a
 ; non-existent file/dir.
 ; NOTE:
 ; IX [HL from dot command] and DE may both address the same memory, if desired.
	push ix 
	ld a,$ff		; filespec in de 
	ld de,filespec
	ld ix,outbuffer 
	rst $08
	db $a8
	jr getpathdone
filespec:
	db "cpc.spr"
	db 0
	end asm 
outbuffer:
	asm 
outbuffer:
	DB 4,0
	db "THIS"
	defs 32,0
	end asm 
outbuffadd:
	asm
outbuffadd:
	dw outbuffer
getpathdone:
	
	ld hl,outbuffer
	ld b,32				; safterly loop 
	ld c,0
strngsize:
	ld a,(hl)		; get char 
	or a 				; is it zero though 
	
	jr z,eolpath
	inc hl
	inc c
	djnz strngsize 
	ld a,b
	or a
	jr nothingtodo
eolpath:
	BREAK
	dec c
	ld a,c
	ld b,0 
	push af
	ld hl,outbuffer
	ld de,outbuffer
	ADDHLA  ; end of outbuffer 
	add a,2 : inc c
	ADDDEA  ; end of outbuffer  
  lddr 
	xor a : ld (de),a : dec de 
	pop af : inc a
	ld (de),a
	ld hl,outbuffadd
	ld de,(outbuffer)
	ld (hl),e : inc hl : ld (hl),d
nothingtodo:
	pop ix 
end asm 
end sub 


do  
loop 



sub fastcall recieveruartmem(rxadd as uinteger,rxlength as ulong)
	asm 
	; > HL = Destination  all set 
	; > DE = Length stack + 2
		BREAK 
		TX 	EQU $133B
		RX 	EQU $143B
		pop ix 																		; strore return address
		pop de  																	;	fgget the length 
	timeout: 		
		db 0 
	in232:	
		ld a,(timeout) : cp 255 : jr z,timedout 
		inc a : ld (timeout),a 
		ld	bc,TX : in	a,(c) : and	1       			; RX busy?
		jr	z,in232
		ld	bc,RX : in	a,(c) : ld	(hl),a    		; Store to memory
		inc	hl
		out	(254),a   ; Set border color
		dec	de : ld	a,e : or	d : jr	nz,in232
	timedout:
		push ix 																	; put back the ret address 
		xor a : ld (timeout),a
		
	end asm 

end SUB  