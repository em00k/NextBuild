; ************************************************************************
;
;	Init sprite shapes, and locations
;
; ************************************************************************
InitSprites:
		
		NextReg $19,0
		NextReg $19,255
		NextReg $19,0
		NextReg $19,191

        NextReg	$56,16
        NextReg	$57,17
		call	CreateSprites
		
		; load sprite image data (we overwrite it later)
		NextReg	$56,16
		NextReg	$57,17
		ld	e,0
		ld	d,32
		ld	hl,$c000
		call	UploadSprites


SetUpSprites:
		; Create a small strip of sprites at the top of the screen for us to experiment with
		ld	hl,SprData
		ld	de,$80		; shape + sprite enable
		ld	bc,8		; X coord
		exx
		ld	b,32
@lp1:
		exx
		ld	a,c
		ld	(hl),a		; x
		inc	hl

		ld	a,(SpriteYCoord)		; y
		ld	(hl),a
		inc	hl

		ld	a,b
		ld	(hl),a		; msb
		inc	hl

		ld	a,e
		and	$c7
		ld	(hl),a		; shape
		inc	hl

		inc	e			; next shape
		add	bc,$10		; 16 pixels on

		exx
		djnz	@lp1



		; Now copy the sprites up
CopySpriteData:
		; select sprite
        ld	bc,$303B
        xor	a
        out	(c),a

        ld	hl,SprData
        ld	c,$57
        ld	b,128
        otir
        
        ret
SprData		ds	4*64

SpriteYCoord	db	32
; ------------------------------------------------------------------------
;	Create sprite shapes and give them colours
; ------------------------------------------------------------------------
SprColours:
		db	$ff,%11100000,%00011100,%00000011,%11100111,%00011111,%11111100,0
		db	$ff,%11100000,%00011100,%00000011,%11100111,%00011111,%11111100,0
		db	$ff,%11100000,%00011100,%00000011,%11100111,%00011111,%11111100,0
		db	$ff,%11100000,%00011100,%00000011,%11100111,%00011111,%11111100,0
		db	$ff,%11100000,%00011100,%00000011,%11100111,%00011111,%11111100,0
		db	$ff,%11100000,%00011100,%00000011,%11100111,%00011111,%11111100,0
		db	$ff,%11100000,%00011100,%00000011,%11100111,%00011111,%11111100,0
		db	$ff,%11100000,%00011100,%00000011,%11100111,%00011111,%11111100,0
CreateSprites:
		ld		b,32
		ld		de,SprColours
		ld		hl,$c000

@lp2:
		push 	bc
		ld		a,(de)
		ld		b,128
	
@lp1:
		ld		(hl),a
		inc		hl
		ld		(hl),$e3		; stripy sprites so we can make sure we can see through them
		inc		hl
		djnz	@lp1

		inc		de
		pop		bc
		djnz	@lp2
		ret




