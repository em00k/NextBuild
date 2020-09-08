; ************************************************************************
;
;	Init sprite shapes, and locations
;
; ************************************************************************
InitSprites:

		; load sprite image data (we overwrite it later)
                LoadFile        ShipSprite,$c000
                ld	e,0
                ld	d,4
                ld	hl,$c000
                call	UploadSprites

                ;
                ; Called here from main loop to update sprites
                ;
SetPlayer:
		ld	hl,(PlayerX)
		ld	a,l		
		ld	(SpriteData0),a
		ld	(SpriteData1),a
		ld	a,h
		ld	(SpriteData0+2),a	; msb
		ld	(SpriteData1+2),a	; msb

		ld	bc,16
		add	hl,bc
		ld	a,l
		ld	(SpriteData2),a
		ld	(SpriteData3),a
		ld	a,h
		ld	(SpriteData2+2),a	; msb
		ld	(SpriteData3+2),a	;msb

		ld	a,(PlayerY)
		ld	(SpriteData0+1),a
		ld	(SpriteData2+1),a
		add	$10
		ld	(SpriteData1+1),a
		ld	(SpriteData3+1),a

		; select sprite
                ld	bc,$303B
                xor	a
                out	(c),a

                ld	hl,SpriteData0
                ld	c,$57
                ld	b,$10
                otir
                
                ret


PlayerX		dw	140
PlayerY		db	160


SpriteData0	db	0		; x
		db	0		; y
		db	0		; MSB
		db	$80
SpriteData1	db	0		; x
		db	0		; y
		db	0		; MSB
		db	$81

SpriteData2	db	0		; x
		db	0		; y
		db	0		; MSB
		db	$82
SpriteData3	db	0		; x
		db	0		; y
		db	0		; MSB
		db	$83
