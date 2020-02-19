#include <nextlib.bas>

#DEFINE SetSprite256 \
	DB 01\
	DW $0057\
	DW $ED59\
	DW $ED51\
	DW $ED41\
	DW $CBFF\
	DW $ED79

dim sx, sy, p, down as ubyte 


LoadSD("baddie.spr",$c000,16384,0)
InitSprites(16,$c000)
'DoTile32(1,1,2,0)
UpdateSprite(32,32,0,2,0)
NextReg($7,0)
bx=0 : NextReg($15,1)
do 
do 
for by = 0 to 0 step 64
sy=0
'border 0 
pause 1
border 2

	FastSprite(110+by,110,0,0,p)
	FastSprite(110+16+by,110,1,1,p)
	FastSprite(110+32+by,110,2,2,p)
	FastSprite(110+by,110+16,3,3,p)
	FastSprite(110+16+by,110+16,4,4,p)
	FastSprite(110+32+by,110+16,5,5,p)
	FastSprite(110+by,110+32,6,6,p)
	FastSprite(110+16+by,110+32,7,7,p)
	FastSprite(110+32+by,110+32,8,8,p)
border 0 
' if inkey=" " and down=0
	if down>5
	p=(p+2) band 15
	down=0
	else 
	down=down+1
	endif
' 	'pause 10
' 	print at 0,0;p
' 	down=1
' 	elseif inkey=""
' 	down=0
' endif 

next 
loop 
for by = 0 to 64 step 2
sy=0

pause 1
border 0
border 2
	UpdateSprite(174-by,110,0,0,0)
	UpdateSprite(174+16-by,110,1,1,0)
	UpdateSprite(174+32-by,110,2,2,0)
	UpdateSprite(174-by,110+16,3,3,0)
	UpdateSprite(174+16-by,110+16,4,4,0)
	UpdateSprite(174+32-by,110+16,5,5,0)
	UpdateSprite(174-by,110+32,6,8,8)
	UpdateSprite(174+16-by,110+32,7,7,8)
	UpdateSprite(174+32-by,110+32,8,6,8)
	
	' 
' for x=0 to 8
' 	'UpdateSprite(140+sx,174+sy-by,8-x,8-x,8)
' 	FastSprite(140+sx,174+sy-by,x,x)
' 	if sx<32 : sx=sx+16 : ELSE sx = 0 : sy=sy+16 : endif 
' next 
	
	border 0


next 
loop 
pause 0 

SUB FastSprite(byval x as uinteger,byval y as ubyte,byval slot as ubyte,byval image as ubyte, byval poff as ubyte)
	ASM 
	;BREAK 
	SPRITE_STATUS_SLOT_SELECT		equ $303B
	ld a,(IX+11)
	ld bc,SPRITE_STATUS_SLOT_SELECT
	out (c),a
	ld e,(IX+4)
	ld d,(IX+5)
	ld l,(IX+7)
	ld c,(IX+9)
	ld a,(IX+13)
	SWAPNIB
	ld b,a
	push bc
	ld bc,$0057
	out  (c),e	; Xpos
	out  (c),l	; Ypos
	pop  hl
	ld   a,d
	or   h
	out  (c),a
	ld a,l
	or $80
	out  (c),a
	END ASM 
end sub 


sub DoTile32 (byval x as ubyte ,byval y as ubyte ,byval tile as ubyte ,byval bank as ubyte )

ASM 
	PROC 
	local PlotTile32
	local plotTilesLoop
;	BREAK 
	ld c,(IX+5)
	ld b,(IX+7)
	ld a,(IX+9)
;----------------
; Plot tile to layer 2
; in - bc = y/x tile coordinate (y = 0- 5 x = 0-7)
; in - a = number of tile to display (0-63)
; in - h = base bank
; 1024 bytes per char (first 16 are in h, next 16 in h=1, (bank is 16k at c000))
;----------------
PlotTile32:
	ld l,a
	;ld l,(IX+9)
	ld a,c
	;ld a,(IX+5)
	
	SWAPNIB
	rlca
	ld e,a					; convert coords
	ld a,b
	SWAPNIB
	rlca
	ld d,a
	and 192
	or 3
	ld bc,LAYER2_ACCESS_PORT
	out (c),a			; select bank for l2
	ld a,l
	SWAPNIB
	and 15
	add a,h
	;SetBankC000			; set tile bank based on char number
	ld a,l
	rlca
	rlca
	or 192						; mul 1024 (store to hi)
	ld h,a
	ld l,0
	ld a,d
	and 63
	ld d,a
	ld b,36								; 36 to account for the 4 decs of BC caused by ldi (32 + 4)
plotTilesLoop:
	push de
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	pop de
	inc d
 	djnz plotTilesLoop
	ENDP 
;	ret
end asm 
end sub      