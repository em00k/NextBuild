'!org=33000


#include <nextlib.bas>
#include <print42.bas>

NextReg(8,$fe)								' no contention 
'NextReg($43,$1)								' ULANext enabled 
NextReg(7,3)									' 14mhz
'NextReg($43,$0)								' ULA palette 
NextReg($14,$0)  							' Global transparency bits 7-0 = Transparency color value (0xE3 after a reset)
'NextReg($40,0)   						' 16 = paper 0 on L2 palette index 
'NextReg($41,$0)  							'	Palette Value 
 
NextReg($12,12)  							' layer2 rams   16kb banks 
NextReg($13,15)  							' layer2 shadow
NextReg($15,%00001011)
NextReg($42,7)							' ULANext number of inks : 255 127 63 31 15 7 
NextReg($4A,$0)							' Fallback trans

paper 1 : ink 7: border 0 : cls

POKE UINTEGER 23675,@guiblocks

MMU8(7,34)
'LoadSD("sprites.spr",49152,8192,0)
zx7Unpack(@mousecur,$c000)
InitSprites(4,49152)
MMU8(7,1)
dim x,y,mbutt,oldmox, oldmoy, mousemapid, menu,rx,ry, click  as ubyte
dim b,p,i,xx,yy as ubyte
dim mapaddr,off,my,mx,addr,moy,mox as uinteger
dim s$ as string 
menu = 0 
DO 													' next loop

 newmouse() : oldmox=mox : oldmoy=moy : 
 mox=peek(@Mouse+1) :  moy=peek(@Mouse+2) :  mbutt=peek(@Mouse)
 rx = mox / 6 : ry = moy / 8
 'readmapaddr=peek(@ScreenData+(ry<<5)+rx)
 'addr=cast(uinteger,ry)*42+rx
 mousemapid=peek(@ScreenData+cast(uinteger,ry)*42+rx)
 'print at 1,0;mousemapid
 'print at 0,0;rx,ry
 sprx=(32+cast(uinteger,mox)) : spry=(32+moy)
 UpdateSprite(sprx,spry,0,3,0,0)
 
 if mbutt band 15=13 and menu=1						' left mb
		if mousemapid = 1
			b = b + 1 band 7 : border b
		elseif mousemapid = 2
			p = p + 1 band 7 : paper p
		elseif mousemapid = 3
			i = i + 1 band 7 : if i = p : i = i + 1 : ink i : endif 
		elseif mousemapid = 4
			beep .001,3 
		elseif mousemapid = 5
		'	drawallchars()
			ex = 5 
		endif 
		menu = 0 
		cls 
	elseif mbutt band 15=14	and click=0						' right mb
		RightClickTwo()
		click=1
	'elseif mbutt band %11111000<>ombutt  ' mouse wheel 
	ELSEIF mbutt band 15 = 15						' no mouse, used for button debounce
		click=0
 endif
 
loop until ex=5

GOTO ENDOFPROG


sub drawallchars()
	s$=""
	
	for my=0 to 23
	for mx=0 to 41 
		printat42(my,mx)
		p=peek(ubyte,@ScreenData+off)
		s$=str$(p)
		print42(s$)
		off=off+1
		next mx 
	next my 

	off=0
end sub 

Sub RightClick()
	menu = 1
	DrawPanel(0,9,20,6,0)
	beep .001,3
	AddMenuOption(1,2,10,"1 = HELLO")
	AddMenuOption(2,2,11,"2 = Menu Options")
	AddMenuOption(3,2,12,"3 = Another Option")
	AddMenuOption(4,2,13,"4 = Testing")
	AddMenuOption(5,2,14,"5 = I can't code")
end sub 

Sub RightClickTwo()
	asm 
		;BREAK 
		ld hl,.LABEL._ScreenData
		ld (hl),0
		ld de,.LABEL._ScreenData+1
		ld bc,42*24
		ldir 
	end asm 
	cls 
	menu = 1

	xx=mox/8 : yy = moy/8
	w=13 : h=6
	if xx+w>30 : xx = 30-w : endif 
	if yy+h>23 : yy = 23-h : endif 
	'DrawPanel(0,9,20,6,0)
	'DrawPanel(xx,yy,w,h,0)
	xx=xx*8/6
	xx=xx+2 : yy = yy + 1
	AddMenuOption(1,xx,yy,"Change Border")
	AddMenuOption(2,xx,yy+1,"Change Paper")
	AddMenuOption(3,xx,yy+2,"Change Ink")
	AddMenuOption(4,xx,yy+3,"Beep")
	AddMenuOption(5,xx,yy+4,"Reset")
end sub 

Sub DrawPanel(x as ubyte, y as ubyte, w as ubyte, h as ubyte, e as ubyte)

 	print at y,x;"\a"
' 	for c=x+1 to x+w+1
' 		print at y,c;"\b"
' 		print at y+h,c;"\h"
' 	next 
' 	print at y,c-1;"\c"
' 	for d=y+1 to y+h-1
' 		print at d,c-1;"\f"
' 		print at d,x;"\d"
' 	next 
' 	print at d,x;"\g"
' 	print at d,c-1;"\i"
end sub 

sub AddMenuOption(id as ubyte, tx as ubyte, ty as ubyte, m$ as string)
	
	'strlen = len(m$)		' length of msg
	printat42(ty,tx)
	print42(chr(17)+chr(6)+m$)
	addr=cast(uinteger,ty)*42+tx
	mapaddr=@ScreenData+addr
	poke ubyte mapaddr,id
	asm 	

		ld b,0
		ld l,(IX+10)
		ld h,(IX+11)
		ld a,(hl) ; length 
		dec a 
		ld hl,(._mapaddr)
		ld c,a
		ld d,h
		ld e,l
		inc de 
		ldir
	end asm 
end sub 

ScreenData:
	ASM 
		DEFS 1048,0
	end asm 

sub newmouse()
	asm 
	; Jim bagley mouse routines, clamps mouse and dampens x & y 
	ld	de,(nmousex)
	ld (omousex),de
	ld	a,(mouseb)
	ld (omouseb),a
	
	call getmouse
	ld (mouseb),a
	ld (nmousex),hl

	ld a,l
	sub e
	ld e,a
	ld a,h
	sub d
	ld d,a
	ld (dmousex),de	;delta mouse
	
	ld d,0
	bit 7,e
	jr z,bl
	dec d
bl: 
	ld hl,(rmousex)
	add hl,de
	ld bc,4*256
	call rangehl
	ld (rmousex),hl
	sra  h
	rr l
	sra h
	rr l
	ld a,l
	ld (mousex),a
	ld de,(dmousey)
	ld d,0
	bit 7,e
	jr z,bd
	dec d
bd: 
	ld hl,(rmousey)
	add hl,de
	ld bc,4*192+64
	call rangehl
	ld (rmousey),hl
	sra  h
	rr l
	sra h
	rr l
	ld a,l
	ld (mousey),a

	jp mouseend
	
getmouse:
	ld	bc,64479
	in a,(c)
	ld l,a
	ld	bc,65503
	in a,(c)
	cpl
	ld h,a
	ld (nmousex),hl
	ld	bc,64223
	in a,(c)
	ld (mouseb),a
	ret
rangehl:
	bit 7,h
	jr nz,mi
	or a
	push hl
	sbc hl,bc
	pop hl
	ret c
	ld	h,b
	ld l,c
	dec hl
	ret
mi:
	ld hl,0
	ret

mousex:
	db	0
mousey:
	db	0
omousex:
	db	0
omousey:
	db	0
nmousex:
	db	0
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
	ld a,(mouseb)
	ld (Mouse),a
	ld a,(mousex)
	ld (Mouse+1),a
	ld a,(mousey)
	ld (Mouse+2),a
	
	end asm 
end sub 

Mouse:
ASM
Mouse:
			db	0
			db	0
			db	0
end asm 

guiblocks: 
asm 
	; ASM data file from a ZX-Paintbrush picture with 24 x 24 pixels (= 3 x 3 characters)

	; block based output of pixel data - each block contains 8 x 8 pixels

	; blocks at pixel positionn (y=0):

	db	$00, $00, $00, $00, $00, $00, $01, $03
	db	$00, $00, $00, $00, $00, $00, $FF, $00
	db	$00, $00, $00, $00, $00, $00, $80, $C0

	; blocks at pixel positionn (y=8):

	db	$02, $02, $02, $02, $02, $02, $02, $02
	db	$00, $00, $00, $00, $00, $00, $00, $00
	db	$40, $40, $40, $40, $40, $40, $40, $40

	; blocks at pixel positionn (y=16):

	db	$03, $01, $00, $00, $00, $00, $00, $00
	db	$00, $FF, $00, $00, $00, $00, $00, $00
	db	$C0, $80, $00, $00, $00, $00, $00, $00
end asm   

mousecur:
asm 
	incbin "data/sprites.spr.zx7"
	dw 00,00
end asm 

ENDOFPROG:
END 
   