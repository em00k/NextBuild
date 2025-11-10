'#!v
'#!sna "h:\mouse2.sn" -a
'#!bin "h:\nextscii\test.bin" -a
'#!noemu
' nextscii viwer by David Saphier / emook2019
' http://zxbasic.uk/nextbuild/netscii/

#include <nextlib.bas>
NextReg(8,$fe)								' no contention 
NextReg(7,2)									' 14mhz
NextReg($40,0)   						' palette index 0 
NextReg($41,$0)  						'	set black  
NextReg($4A,0)								' Transparency 0 
NextReg($1B,0)  							' x1			tilemap clip
NextReg($1B,159) 						' x2 
NextReg($1B,0)   						' y1 
NextReg($1B,255) 						' y2 

' (R/W) 0x6B (107) => Tilemap Control
' bit 7 = 1 to enable the tilemap
' bit 6 = 0 for 40x32, 1 for 80x32
' bit 5 = 1 to eliminate the attribute entry in the tilemap
' bit 4 = palette select
' bits 3-2 = Reserved set to 0
' bit 1 = 1 to activate 512 tile mode
' bit 0 = 1 to force tilemap on top of ULA
						' 76543210 
NextReg($6B,%10000001)				' tilemap on & on top of ULA,  80x32 
NextReg($6E,$40)							' (R/W) 0x6E (110) => Tilemap Base Address 0 = $4000
NextReg($6F,$60)							' (R/W) 0x6F (111) => Tile Definitions Base Address
NextReg($43,%00110000)	

dim r,g,b,fc as ubyte
dim r9,g9,b9 as uinteger
dim result as ubyte
dim v as ubyte 
dim f,x,pcount as uinteger
dim tindex,alltext,tcount,peekstringcount,Memory as uinteger
dim temp$,ext$,tx$ as string 
dim xr,xy,vv,xx,yy,k,car,st,subcar,cc,cof,tma,paloff,palcols,prg,col,yr,offsetload,size,prg2,nbrsplits as ubyte 
dim count,c as ubyte 
dim splitted$ as string ="              "
dim z$ as string ="              "
dim text$ as string ="              "
dim type$ as string ="              "
dim fname$ as string ="              "
paloff=0 : pcount = 0

declare function SplitString(byval s$ as string,byval split$ as string,byval index as ubyte) as string
declare function PeekString(Memory as uinteger) as string 

LoadSD("UC.spr",$6000,8192,0)     ' our tile map bitmap 4bit 512 blocks 
Zx7Unpack(@infoscreen,$b400)
Reload:

tma=1
border 0 : paper 0 : ink 0: cls 
DoScreen()
SetPalette(1)
pause 0
nbrsplits=1

LoadSD("list.txt",$b000,1024,0)

if peek($b000)<>0
	' rolling 
	text$=PeekString($b000)
	do 	
		DO 
			splitted$=SplitString(text$,chr($0a),nbrsplits)
			type$=SplitString(splitted$,".",2)
			NextReg($6B,%00000000)				' tilemap off
			type2$=type$
			nbrsplits=nbrsplits+1
			
			if splitted$(0)=chr $0a
				splitted$=splitted$ (1 to )
			endif 
			if type2$( to 2)="PRG"
				fname$=splitted$
				BBREAK
					LoadSD(fname$( to ),$b400,1,$19)
					LoadSD(fname$( to ),$b401,1,$1E)
					LoadSD(fname$( to ),$b402,2002,98)
					'BBREAK
				elseif type2$( to 2)="PSC" 
					fname$=splitted$
					LoadSD(fname$( to ),$b400,2002,0)
					border 1
			endif 

			CLS : border 0
			NextReg($6B,%00000000)				' tilemap off 
			DoScreen()
			SetPalette(palette)
			NextReg($6B,%10000001)				' tilemap on 
			
			do 
				key$=inkey$ 
				if key$="p" 
					palette=palette+1 Band 7
					SetPalette(palette)
					updatemap(0,0,48+palette,2)
				elseif key$="o"
					palette=palette-1 BAND 7
					SetPalette(palette)
					updatemap(0,0,48+palette,2)
				elseif key$="e"
				 NextReg($6B,%00000000)
				 goto finish
				elseif key$="b"
				 NextReg($6B,%00000000)
				 exittobrowser=1
				 exit DO
				elseif key$<>""
					exitloop=1
				endif 
				pause 5
			loop until exitloop=1	
			exitloop=0		
			if exittobrowser=1 : exit do : endif 	
		loop until splitted$(to 2)="END"
		nbrsplits=1
		if exittobrowser=1 : exit do : endif 	
	loop 
	
endif 

do 
	
	pause 1
	key$=inkey$ 
	if key$="p"
		palette=palette+1 Band 7
		SetPalette(palette)
		updatemap(0,0,48+palette,2)
	elseif key$="o"
		palette=palette-1 BAND 7
		SetPalette(palette)
		updatemap(0,0,48+palette,2)
	elseif key$="e"
		NextReg($6B,%00000000)
		Goto finish
	elseif key$<>""
		cls 
		Browser("Choose a .PRG or .PSC from PetMate","PRG")
		s$=""
		for x=0 to 13 
			c=peek (@filebuffer+x) : 	if c=255 :  size=x-1 : x = 13 :ELSE s$=s$+chr c :  endif :
		next
		if peek(@filebuffer+size)=code "G"
			LoadSD(s$,$b400,1,$19)
			LoadSD(s$,$b401,1,$1E)		
			LoadSD(s$,$b402,2002,98)
			else 
			LoadSD(s$,$b400,2002,0)
		endif 
		CLS : border 0 
		DoScreen()
		SetPalette(palette)
		NextReg($6B,%10000001)				' tilemap on 
	elseif key$="m"									' flips tilemap not used 
	 if tma=0
		NextReg($6F,$60)
	  tma =1
	 else 
		NextReg($6F,$90)
		tma=0
		endif 
	endif 
	
	while inkey$<>""
		pause 1
	wend 
loop 


SUB SetPalette(palette as ubyte)
	pcount=cast(uinteger,palette)*64
	bordercol=peek($b400)
	papercol=peek($b401)
	borderindex=@Palette+2+(cast(uinteger,bordercol)*4)
	paperindex=@Palette+2+(cast(uinteger,papercol)*4)
	NextRegA($40,0)	
	NextRegA($44,peek(paperindex))
	NextRegA($44,0)
	NextRegA($44,0)
	NextRegA($44,0)
	NextRegA($40,paloff+4)	
	for paltot=0 to 15
		NextRegA($44,peek(paperindex))
		NextRegA($44,0)
		prg=peek(@Palette+cast(uinteger,palcols+2)+pcount)
		prg2=peek(@Palette+cast(uinteger,palcols+3)+pcount)
		NextRegA($44,prg) 
		NextRegA($44,prg2) 
		pcount=pcount+4
		paloff=paloff+16
		NextRegA($40,paloff)	
	next 
end sub 

sub DoScreen()
	asm 
		ld hl,$4000
		ld de,$4001
		ld (hl),32
		ld bc,3999
		ldir 
	end asm 
	xr=0 : yr = 0 : car=0
	for f=0 to 2000  
		car=peek($b402+cast(uinteger,f	))
		col=peek($b402+cast(uinteger,f	)+1000)
		updatemap(xr,yr,car,col)
		xr=xr+1
		if xr > 39 'or k=13
			yr=yr+1 : xr=0
		endif  
		if yr=25 then f=2000
	next 
end sub 

sub fastcall updatemap(xx as ubyte, yy as ubyte, vv as ubyte, col as ubyte)
	asm 
		;BREAK 
		pop bc	; return address 
		ld hl,$4000+160*2 : add a,a : ADD_HL_A	; add x 
		; hl = $4000+x
		pop de : ld a,e : ld e,80 : MUL_DE
		add hl,de : pop af
		;cp 95
		;jr c,skipme
		;BREAK
skipme:
		ld (hl),a : inc hl : 	pop af
		SWAPNIB : and %11110000
		ld (hl),a 
		push bc
		;BREAK 
		end asm 	
end sub   

sub Browser(byval temp$ as string,byval ext$ as string)

	NextReg($6B,%00000000)				' tilemap on & on top of ULA,  80x32 
	'for p=0 to 2 : poke @extname+p, code(ext$(p)) : next 
	for p=0 to len(temp$)-1 : poke @testtext+cast(uinteger,p), code(temp$(p)) : next 
	poke @testtext+cast(uinteger,p),255
	asm  
	    ; bits of code by Garry Lancaster from .browser sources  
			;DW $01DD
			IDEBROWSER						equ	$01ba 
			LAYER									equ $9c
			IDEBASIC 							equ $1c0
			; Next Registers
			nextregselect         equ     $243b
			nextregaccess         equ     $253b
			nxrturbo              equ     $07
			turbomax              equ     2
			nxrmmu6               equ     $56
			nxrmmu7               equ     $57
			tstack								equ 	$bf00
			ld (stackstore),sp 
			ld sp,tstack
browser2:
			BREAK
			ld a,$7f						; 	all capabilities
			ld hl,ftbuff				; 	hl = filetypes 
			ld de,testtext 			; 	de info at bottom of screen +$FF 
			exx
pressesq:
			ld c,7 							; 	RAM 7 required for most IDEDOS calls
			ld de,$01ba 				; 	IDEBROWSER 
			;ld a,$7f						; 	all capabilities
			rst $8
			defb $94 						;	MP3DOS
			
			jp nc,FILERROR
			jp z,FILEOK
			jp nz,browser2
			
			
FILEOK:
			;pop de ; get off stack 
			ld a,4
			out (254),a
			ld de,filebuffer
			jp copyRAM7tode
			ret 
		
FILERROR:

			ret 

copyRAM7tode:
			push    hl                      ; save source address
			ld      bc,nextregselect
			ld      a,nxrmmu6
			out     (c),a
			inc     b
			in      l,(c)                   ; L=current MMU6 binding
			ld      a,7*2+0
			out     (c),a                   ; rebind to RAM 7 low
			dec     b
			ld      a,nxrmmu7
			out     (c),a
			inc     b
			in      h,(c)                   ; H=current MMU7 binding
			ld      a,7*2+1
			out     (c),a                   ; rebind to RAM 7 high
			ex      (sp),hl                 ; save MMU6/7 bindings, refetch source
			ld      bc,$ffff                ; string len, -1 to exclude terminator
cr7tomainloop:
			ld      a,(hl)                  ; copy a byte
			inc     hl
			ld      (de),a
			inc     de
			inc     bc                      ; increment string length
			inc     a
			jr      nz,cr7tomainloop       ; back unless $ff-terminator copied
			pop     hl
			ld      a,l
			defb    $ed,$92,nxrmmu6                ; restore MMU6 binding
			ld      a,h
			defb    $ed,$92,nxrmmu7                ; restore MMU7 binding
			ld hl,filebuffer
			add hl,bc 
			ld a,$ff
			ld (hl),a
			jp endout
ftbuff:   	
			defb	4
end asm 
extname:
asm 
			defb	"PRG:"
			defb	4
			defb	"PSC:"
			defb	$ff	; all files 
end asm 
testtext:
asm 
testtext:
			Defs 64,32
			DB 255
stackstore:		
			dw 0
endout:
rom3page0: 
			
			di
			ld   bc,32765       ;I/O address of horizontal ROM/RAM switch
			ld   a,(23388)      ;get current switch state
			set  4,a            ;move left to right (ROM 2 to ROM 3)
			and  $F8           ;also want RAM page 0
			;or 0
			;ld a,$10
			ld   (23388),a      ;update the system variable (very important)
			out  (c),a          ;make the switch
			rst $20
			ld sp,(stackstore)
			ei 
			
end asm 
	
end sub 

filebuffer:
asm 
filebuffer:
	db "filename.ext"
	db 255
end asm   

function PeekString(byval Memory as uinteger) as string 
	dim tempcar$ as string 
	peekstringcount=0 :tempcar$=""
	while peek(ubyte,Memory+peekstringcount)<>0
		tcar=peek(ubyte,Memory+peekstringcount)
		'tcar=tcar BAND %01111111
		
		if tcar<>$0a or tcar<>$0d0
			tempcar$=tempcar$+chr$(tcar)
		endif 
		peekstringcount=peekstringcount+1	
	wend 
  return tempcar$

end function

Function SplitString(s$ as string,split$ as string,byval index as ubyte) as string
	'dim outstring$ as string
	totlen=len(s$) : spos = 0 :  tcount=0 : tindex = 0 : outstring$=""
	s$=s$+split$
	for alltext=0 to totlen+1
		curcar$=s$(alltext)
		if curcar$=split$
				if tindex+1=index
					if spos>0
						tcount=spos+1
					endif 
					do 
					 outstring$=outstring$+s$(tcount)
					 tcount=tcount+1 : 
					loop until s$(tcount)=split$ 
					alltext=totlen
				else 
					spos=alltext 
					tindex=tindex+1
			endif 
		endif 	
	next alltext
	return outstring$
end function


Palette:
ASM 
	; my original 
		db 0,0,0,0				; 0   black 
		db 0,0,255,1			; 1 	white 
		db 0,0,137,0			; 2		dark red 
		db 0,0,150,0			; 3		light blue 
		db 0,0,138,0			; 4 	magenta 
		db 0,0,117,0			; 5 	dark green 
		db 0,0,74,0				; 6 	dark purple 
		db 0,0,217,0			; 7 	yello 
		db 0,0,141,0			; 8 	light brown
		db 0,0,104,0			; 9 	dark brown 
		db 0,0,210,0			; 10 	beige / pink 
		db 0,0,73,0			  ; 11	dark grey 
		db 0,0,146,0			; 12	medium grey 
		db 0,0,186,0			; 13 	light green 
		db 0,0,143,1			; 14	light purple 
		db 0,0,182,1			; 15	light grey 

	; VICE PALETTE 
		DB 0,0,0,0
		DB 0,0,255,1
		DB 0,0,160,1
		DB 0,0,63,0
		DB 0,0,163,1
		DB 0,0,24,0
		DB 0,0,34,1
		DB 0,0,220,0
		DB 0,0,100,0
		DB 0,0,168,0
		DB 0,0,233,0
		DB 0,0,73,0
		DB 0,0,109,1
		DB 0,0,93,0
		DB 0,0,75,1
		DB 0,0,182,1
	
	; Community colors 
		DB 0,0,0,0
		DB 0,0,255,1
		DB 0,0,164,1
		DB 0,0,123,0
		DB 0,0,166,1
		DB 0,0,89,0
		DB 0,0,39,0
		DB 0,0,253,0
		DB 0,0,100,0
		DB 0,0,168,0
		DB 0,0,237,1
		DB 0,0,73,0
		DB 0,0,146,0
		DB 0,0,190,0
		DB 0,0,111,1
		DB 0,0,182,1


	; colordore 
		DB 0,0,0,0
		DB 0,0,255,1
		DB 0,0,132,1
		DB 0,0,123,0
		DB 0,0,134,0
		DB 0,0,85,0
		DB 0,0,38,0
		DB 0,0,253,1
		DB 0,0,68,0
		DB 0,0,136,1
		DB 0,0,205,1
		DB 0,0,73,0
		DB 0,0,109,1
		DB 0,0,190,0
		DB 0,0,111,1
		DB 0,0,182,1
 ; rgb 
 incbin ".\data\rgb.bin"
 ; c64 hq 
 incbin ".\data\c64hq.bin"
 ; pepto
 incbin ".\data\pepto.bin" 
 ; pepto
 incbin ".\data\godot.bin"
end asm 
infoscreen:
asm 
 incbin ".\data\info.psc.zx7"
end asm    

finish:
asm 
 rst 56
end asm 
                   