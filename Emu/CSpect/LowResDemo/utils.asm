; ************************************************************************
;
; 	Utils file - keep all utils variables in this file
;
; ************************************************************************

; ************************************************************************
;
;	Function:	Set current bank - upto 1MB supported			
;	In:		A = bank to set, paged into $c000
;
;	$7FFD:		D0  |
;			D1  |-  bank (128k)
;			D2  |
;			D3  - ULA screen select
;			D4  - rom
;			D5  - disable paging
;			D6  - unused
;			D7  - unused
;
;	$DFFD:		D0  - 256k
;			D1  - 512k
;			D2  - 1024k
;			D3  - unused
;			D4  - unused
;			D5  - unused
;			D6  - unused
;			D7  - unused
;
;			128 Memory map uses 16K banks. 
;		  0xffff + -------- + -------- + -------- + -------- + -------- + -------- + -------- + -------- + -------- + -------- +
;			 |  Bank 0  |  Bank 1  |  Bank 2  |  Bank 3  |  Bank 4  |  Bank 5  |  Bank 6  |  Bank 7  |          |
;			 |          |          | (also at |          | (        | (also at |          |          |  NEXT RAM------->
;			 |          |          |  0x8000) |          |          |  0x4000) |          |          |          |
;			 |          |          |          |          |          |  screen  |          |  screen  |          |
;		  0xc000 + -------- + -------- + -------- + -------- + -------- + -------- + -------- + -------- + -------- + -------- +
;			 |  Bank 2  |            Any one of these pages may be switched in.
;			 |          |
;			 |          |
;			 |          |
;		  0x8000 + -------- +
;			 |  Bank 5  |
;			 |          |
;			 |          |
;			 |  screen  |
;		  0x4000 + -------- + -------- +
;		         |  ROM 0   |  ROM 1   | Either ROM may be switched in.
;		         |          |          |
;		         |          |          |
;		         |          |          |
;		  0x0000 + -------- + -------- +
;
;
;
; ************************************************************************
ResetBank:	xor	a			; bank 0 sits at $C000
;if	NextInstructions!=0
SetBank:	ld	(CurrentBank),a
		add	a,a
		mmu6
		inc 	a
		mmu7
		ld	a,(CurrentBank)
		ret
CurrentBank	db	0

	
; ************************************************************************
;
;	Function:	Clear the 256 colour screen to a set colour
;	In:		A = colour to clear to ($E3 makes it transparent)
;
; ************************************************************************
Cls256:
		push	bc
		push	de
		push	hl

		ld	d,a			; byte to clear to
                ld	e,3			; number of blocks
                ld	a,1			; first bank... (bank 0 with write enable bit set)
                
                ld      bc, $123b                
@LoadAll:	out	(c),a			; bank in first bank
                push	af
                
                                
                ; Fill lower 16K with the desired byte
                ld	hl,0
@ClearLoop:	ld	(hl),d
                inc	l
                jr	nz,@ClearLoop
                inc	h
                ld	a,h
                cp	$40
                jr	nz,@ClearLoop

                pop	af			; get block back
                add	a,$40
                dec	e			; loops 3 times
                jr	nz,@LoadAll

                ld      bc, $123b		; switch off background (should probably do an IN to get the original value)
                ld	a,0
                out	(c),a     

                pop	hl
                pop	de
                pop	bc
                ret                          


; ************************************************************************
;
;	Function:	Clear the spectrum attribute screen
;	In:		A = attribute
;
; ************************************************************************
ClsATTR:
		push	hl
		push	bc
		push	de

	        ;ld      a,7
                ld      ($5800),a
                ld      hl,$5800
                ld      de,$5801
                ld      bc,1000
                ldir

                pop	de
                pop	bc
                pop	hl
                ret


; ************************************************************************
;
;	Function:	clear the normal spectrum screen
;
; ************************************************************************
Cls:
		push	hl
		push	bc
		push	de

		xor	a
                ld      ($4000),a
                ld      hl,$4000
                ld      de,$4001
                ld      bc,6143
                ldir

                pop	de
                pop	bc
                pop	hl
                ret



; ************************************************************************
;
;	Function:	Enable the 256 colour Layer 2 bitmap
;
; ************************************************************************
BitmapOn:
                ld      bc, $123b
                ld	a,2
                out	(c),a     
                ret                          

               	
; ************************************************************************
;
;	Function:	Disable the 256 colour Layer 2 bitmap
;
; ************************************************************************
BitmapOff:
                ld      bc, $123b
                ld	a,0
                out	(c),a     
                ret          





; ******************************************************************************
;
;	A  = hex value tp print
;	DE= address to print to (normal specturm screen)
;
; ******************************************************************************
PrintHex:	
		push	bc
		push	hl
		push	af
		ld	bc,HexCharset

		srl	a
		srl	a
		srl	a
		srl	a	
		call	DrawHexCharacter

		pop	af
		and	$f	
		call	DrawHexCharacter
		pop	hl
		pop	bc
		ret


;
; A= hex value to print
;
DrawHexCharacter:	
		ld	h,0
		ld	l,a
		add	hl,hl	;*8
		add	hl,hl
		add	hl,hl
		add	hl,bc	; add on base of character wet

		push	de
		push	bc
		ld	b,8
@lp1:		ld	a,(hl)
		ld	(de),a
		inc	hl		; cab't be sure it's on a 256 byte boundary
		inc	d		; next line down
		djnz	@lp1
		pop	bc
		pop	de
		inc	e
		ret


HexCharset:
		db %00000000	;char30  '0'
		db %00111100
		db %01000110
		db %01001010
		db %01010010
		db %01100010
		db %00111100
		db %00000000
		db %00000000	;char31	'1'
		db %00011000
		db %00101000
		db %00001000
		db %00001000
		db %00001000
		db %00111110
		db %00000000
		db %00000000	;char32	'2'
		db %00111100
		db %01000010
		db %00000010
		db %00111100
		db %01000000
		db %01111110
		db %00000000
		db %00000000	;char33	'3'
		db %00111100
		db %01000010
		db %00001100
		db %00000010
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char34	'4'
		db %00001000
		db %00011000
		db %00101000
		db %01001000
		db %01111110
		db %00001000
		db %00000000
		db %00000000	;char35	'5'
		db %01111110
		db %01000000
		db %01111100
		db %00000010
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char36	'6'
		db %00111100
		db %01000000
		db %01111100
		db %01000010
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char37	'7'
		db %01111110
		db %00000010
		db %00000100
		db %00001000
		db %00010000
		db %00010000
		db %00000000
		db %00000000	;char38	'8'
		db %00111100
		db %01000010
		db %00111100
		db %01000010
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char39	'9'
		db %00111100
		db %01000010
		db %01000010
		db %00111110
		db %00000010
		db %00111100
		db %00000000
		db %00000000	;char41	'A'
		db %00111100
		db %01000010
		db %01000010
		db %01111110
		db %01000010
		db %01000010
		db %00000000
		db %00000000	;char42	'B'
		db %01111100
		db %01000010
		db %01111100
		db %01000010
		db %01000010
		db %01111100
		db %00000000
		db %00000000	;char43	'C'
		db %00111100
		db %01000010
		db %01000000
		db %01000000
		db %01000010
		db %00111100
		db %00000000
		db %00000000	;char44	'D'
		db %01111000
		db %01000100
		db %01000010
		db %01000010
		db %01000100
		db %01111000
		db %00000000
		db %00000000	;char45	'E'
		db %01111110
		db %01000000
		db %01111100
		db %01000000
		db %01000000
		db %01111110
		db %00000000
		db %00000000	;char46	'F'
		db %01111110
		db %01000000
		db %01111100
		db %01000000
		db %01000000
		db %01000000
		db %00000000






; ******************************************************************************
; 
; Function:	ReadMouse  ***** Not verified on real machine yet *****
;		This is probably wrong, but I'll need it on a real machine 
;		to test - along with a PS2 mouse....err...
;
;		uses bc,a
; ******************************************************************************
ReadMouse:
		ld	bc,Kempston_Mouse_Buttons
		in	a,(c)
		ld	(MouseButtons),a

		ld	bc,Kempston_Mouse_X
		in	a,(c)
		ld	(MouseX),a

		ld	bc,Kempston_Mouse_Y
		in	a,(c)
		ld	(MouseY),a

		ret

MouseButtons	db	0
MouseX		db	0
MouseY		db	0



; ******************************************************************************
; 
; Function:	Upload a set of sprites
; In:		E = sprite shape to start at
;		D = number of sprites
;		HL = shape data
;
; ******************************************************************************
UploadSprites
		; Upload sprite graphics
                ld      a,e		; get start shape
                ld	e,0		; each pattern is 256 bytes
@AllSprites:               
                ; select pattern 2
                ld      bc, $303B
                out     (c),a

                ; upload ALL sprite sprite image data
                ld      bc, SpriteShape
@UpLoadSprite:           
                ;outinb			; port=(hl), hl++
                outi

                dec     de
                ld      a,d
                or      e               
                jr      nz, @UpLoadSprite
                ret

; ******************************************************************************
; Function:	Scan the whole keyboard
; ******************************************************************************
ReadKeyboard:
		ld	b,39
		ld	hl,Keys
		xor	a
@lp1:		ld	(hl),a
		inc	hl
		djnz	@lp1

		ld	ix,Keys
		ld	bc,$fefe	;Caps,Z,X,C,V
		ld	hl,RawKeys
@ReadAllKeys:	in	a,(c)
		ld	(hl),a
		inc	hl		
		
		ld	d,5
		ld	e,$ff
@DoAll:		srl	a
		jr	c,@notset
		ld	(ix+0),e
@notset:	inc	ix
		dec	d
		jr	nz,@DoAll

		ld	a,b
		sla	a
		jr	nc,ExitKeyRead
		or	1
		ld	b,a
		jp	@ReadAllKeys
ExitKeyRead:
		ret


; half row 1
VK_CAPS		equ	0
VK_Z		equ	1
VK_X		equ	2
VK_C		equ	3
VK_V		equ	4
; half row 2
VK_A		equ	5
VK_S		equ	6
VK_D		equ	7
VK_F		equ	8
VK_G		equ	9
; half row 3
VK_Q		equ	10
VK_W		equ	11
VK_E		equ	12
VK_R		equ	13
VK_T		equ	14
; half row 4
VK_1		equ	15
VK_2		equ	16
VK_3		equ	17
VK_4		equ	18
VK_5		equ	19

; half row 5
VK_0		equ	20
VK_9		equ	21
VK_8		equ	22
VK_7		equ	23
VK_6		equ	24
; half row 6
VK_P		equ	25
VK_O		equ	26
VK_I		equ	27
VK_U		equ	28
VK_Y		equ	29

; half row 7
VK_ENTER	equ	30
VK_L		equ	31
VK_K		equ	32
VK_J		equ	33
VK_H		equ	34
; half row 8
VK_SPACE	equ	35
VK_SYM		equ	36
VK_M		equ	37
VK_N		equ	38
VK_B		equ	39

Keys:		ds	40
RawKeys		ds	8



