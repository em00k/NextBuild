; ************************************************************************
;
;	Init sprite shapes, and locations
;
; ************************************************************************
InitSprites:
		
		; load sprite image data (we overwrite it later)
                NextReg	$56,16
                NextReg	$57,17
                ld	e,0
                ld	d,64
                ld	hl,$c000
                call	UploadSprites


;
;		Build 1st row of wall
;
		ld	hl,SprData
		ld	de,$80		; shape + sprite enable
		ld	bc,32		; X coord
		exx
		ld	b,16
@lp1:
		exx
		ld	a,c
		ld	(hl),a		; x
		inc	hl

		ld	a,192		; y
		ld	(hl),a
		inc	hl

		ld	a,b
		ld	(hl),a		; msb
		inc	hl

		ld	a,e
		ld	(hl),a		; shape
		inc	hl

		inc	e		; next shape
		add	bc,$10		; 16 pixels on

		exx
		djnz	@lp1




		ld	hl,SprData+(4*16)
		ld	de,$90		; shape + sprite enable
		ld	bc,32		; xcoord
		exx
		ld	b,16
@lp2:
		exx
		ld	a,c
		ld	(hl),a		; x
		inc	hl

		ld	a,208		; y
		ld	(hl),a
		inc	hl

		ld	a,b
		ld	(hl),a		; msb
		inc	hl

		ld	a,e
		ld	(hl),a		; shape
		inc	hl

		inc	e		; next shape
		add	bc,$10		; 16 pixels on

		exx
		djnz	@lp2



CopySpriteData:
		; select sprite
                ld	bc,$303B
                xor	a
                out	(c),a

                ld	hl,SprData
                ld	c,$57
                ld	b,40*4
                otir
                
                ret
SprData		ds	4*32

BeastY		equ	140
Beast		db	$90
		db	BeastY
		db	0
		db	$a0

		db	$a0
		db	BeastY
		db	0
		db	$a1

		db	$90
		db	BeastY+16
		db	0
		db	$a2

		db	$a0
		db	BeastY+16
		db	0
		db	$a3

		; lower half
		db	$90
		db	BeastY+32
		db	0
		db	$a4

		db	$a0
		db	BeastY+32
		db	0
		db	$a5

		db	$90
		db	BeastY+48
		db	0
		db	$a6

		db	$a0
		db	BeastY+48
		db	0
		db	$a7		


; ------------------------------------------------------------------------
;	Scroll the wall
; ------------------------------------------------------------------------
ScrollSprites	
		ld	ix,SprData
		ld	b,32
@lp1:
		ld	e,(ix+0)
		ld	d,(ix+2)
		add	de,-8
		ld	a,e
		or	d
		jr	nz,@Next		
		ld	de,256+16+16
@Next:
		ld	(ix+0),e
		ld	(ix+2),d
		ld	de,4
		add	ix,de
		djnz	@lp1
		jp	CopySpriteData




; Anim
AnimateBeast:
		ld	a,(BeastDelay)
		dec	a
		and	a
		jr	z,@Animate
		ld	(BeastDelay),a
		ret
@Animate:	ld	a,3
		ld	(BeastDelay),a

		ld	a,(BeastFrame)
		inc	a
		cp	11
		jr	nz,@NotMax
		ld	a,0
@NotMax		ld	(BeastFrame),a

		add	a,a
		add	a,a
		ld	hl,BeastFrames
		add	hl,a

		ld	b,(hl)
		inc	hl
		ld	c,(hl)
		inc	hl
		ld	e,(hl)
		inc	hl
		ld	d,(hl)

		ex	de,hl
		ld	a,b
		NextReg	$56,a
		ld	a,c
		NextReg	$57,a



		; load sprite image data (we overwrite it later)
                ld	e,32
                ld	d,8
                jp	DMASprites	;UploadSprites

BeastFrame	db	0
BeastDelay	db	1


; 11 frames
BeastFrames	
		; frame 0
                db	24,25		; banks
                dw	$c000		; anim base address
		; frame 1
                db	24,25
                dw	$c800
		; frame 2
                db	24,25
                dw	$d000
		; frame 3
                db	24,25
                dw	$d800
		; frame 4
                db	24,25
                dw	$e000
		; frame 5
                db	24,25
                dw	$e800
		; frame 6
                db	24,25
                dw	$f000
		; frame 7
                db	24,25
                dw	$f800
		; frame 8
                db	26,27
                dw	$c000
		; frame 9
                db	26,27
                dw	$c800
		; frame 10
                db	26,27
                dw	$d000



