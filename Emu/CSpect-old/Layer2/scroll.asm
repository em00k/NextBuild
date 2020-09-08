
; ************************************************************************
;
;	Function:	Init the map. Load files and reset the scroll
;
; ************************************************************************
InitMap:
		; load data first...
		LoadFile	Level1File, MapData			; map data
		LoadFile	LevelCharsFile, CharData	; tile (character set) data


		; quick hack - swap all "black" for transparent so we can see the screen below...
		ld	bc,16384
		ld	hl,CharData
@DoAllChars:	ld	a,(hl)
		and	a
		jr	nz,@skipTrans
		ld	a,$e3
		ld	(hl),a

@skipTrans:	inc	hl
		dec	bc
		ld	a,b
		or	c
		jr	nz,@DoAllChars



		call	ResetScroll
		ret

; ************************************************************************
;
;	Function:	Reset the scroll back to the start
;
; ************************************************************************
ResetScroll:
		; reset map scroll...
		xor	a
		ld	(ScrollIndex),a
		ld	hl,MapData
		ld	(MapAddress),hl

		call	SetUpNextColumn
		ret		


; ************************************************************************
;
;	Function:	Setup the next column of tiles
;
; ************************************************************************
SetUpNextColumn:
		ld	hl,(MapAddress)

		; do all 21 characters
		ld	de,TileAddresses
		ld	c,21
@DoAllChars:	
		ld	a,(hl)			; get character - and lower index into character table
		inc	h			; each line of map is 512 byte wide
		inc	h
		ld	(de),a
		ld	a,CharData>>8		; get high byte of character data
		inc	de
		ld	(de),a
		inc	de
		dec	c
		jr	nz,@DoAllChars

		; move map on by 1....
		ld	hl,(MapAddress)
		inc	hl
		ld	(MapAddress),hl

		ret


; ************************************************************************
;
;	Function:	Scroll the screen+map by 1 pixel
;
; ************************************************************************
ScrollMap:
                ld      bc, $243B		; select the scroll register
                ld      a,22
                out     (c),a			; select layer 2 "X" scroll

		ld	a,(ScrollIndex)
		inc	a
		ld	(ScrollIndex),a
		dec	a					; move back 1 so we draw at the RIGHT of the screen
		ld	(@ScrollStore+1),a	; self modify "ld de,$0000"

		ld 	a,(ScrollIndex)
                ld      bc, $253B
                out     (c),a			; set the scroll register

		and	7
		jr	nz,@KeepScrolling	; wrapped to 0?

		call	SetUpNextColumn		; after 8 pixels, setup the NEXT column

@KeepScrolling:
		; do all 21 characters
		ld	hl,TileAddresses	; base of the 21 character indexes
		ld	b,21			; 21 characters to do
		ld	a,3			; banking register
@DoNextBank:
                push	af
                push	bc	                
                ld      bc, $123b		; Layer 2 register
                out	(c),a			; bank in first bank
                pop	bc

		ld	c,8			; each bank has 8 rows
@ScrollStore	ld	de,$0000		; get bank base address + scroll offset
@DoAllChars:	
		push	bc

		ld	c,(hl)			; get graphic "current" address from tile table
		inc	hl
		ld	b,(hl)
		
		
		ld	a,(bc)			; copy the 8 bytes of the column
		ld	(de),a
		inc	b			; each pixel of the graphic is 256 bytes on from the current one
		inc	d

		ld	a,(bc)			
		ld	(de),a
		inc	b
		inc	d

		ld	a,(bc)			
		ld	(de),a
		inc	b
		inc	d

		ld	a,(bc)			
		ld	(de),a
		inc	b
		inc	d

		ld	a,(bc)			
		ld	(de),a
		inc	b
		inc	d

		ld	a,(bc)			
		ld	(de),a
		inc	b
		inc	d

		ld	a,(bc)			
		ld	(de),a
		inc	b
		inc	d

		ld	a,(bc)			
		ld	(de),a
		inc	b
		inc	d

		; Store new column graphic address - last column ends at the start of the next
		ld	(hl),b
		dec	hl
		ld	(hl),c
		inc	hl
		inc	hl

		pop	bc	
		dec	b
		jr	z,@DONE			; run out of characters?

		dec	c			; do all rows in this bank
		jr	nz,@DoAllChars

		pop	af
		add	a,$40			; swap to next bank
		jp	@DoNextBank		; loop until run out of chars above
@DONE:
		pop	af			; balance stack

		ld      bc, $123b		; page out bitmap - but leave it on
		ld	a,$2
		out	(c),a
		ret


; Tile scrolling on counter
MapAddress	dw	0
ScrollIndex:	db	0


TileAddresses	dw	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0	;21 characters....



