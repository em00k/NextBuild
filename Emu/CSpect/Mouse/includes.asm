; ************************************************************************
;
;	General equates and macros
;
; ************************************************************************
NextInstructions        equ     0


if	NextInstructions==1
		opt	ZXNEXTREG
endif

if	NextInstructions==0
NextReg		macro
		push	af
		push	bc
		ld	bc,$243b
		ld	a,\0
		out	(c),a
		inc	b
		ld	a,\1
		out	(c),a
		pop	bc
		pop	af
		endm
NextRegA	macro
		push	bc
		push	af
		ld	bc,$243b
		ld	a,\0
		out	(c),a
		inc	b
		pop	af
		out	(c),a
		pop	bc
		endm
else
NextRegA	macro
		NextReg	\0,a
		endm	
endif





; Hardware
Kempston_Mouse_Buttons	equ	$FADF
Kempston_Mouse_X	equ	$FBDF
Kempston_Mouse_Y	equ	$FFDF
Mouse_LB		equ	1			; 0 = pressed
Mouse_RB		equ	2
Mouse_MB		equ	4
Mouse_Wheel		equ	$f0

SpriteReg		equ	$57
SpriteShape		equ	$5b



; memory locations
SpriteData	equ	$8000



LoadFile	macro
		ld	hl,\0
		ld	ix,\1
		call	Load
		endm
		
File		macro
		dw	Filesize(\0)
		db	\0
		db	0
		Message "file='",\0,"'  size=",Filesize(\0)
		endm






;
; Emulator old MMU instructions
;
if	NextInstructions==1
MMU0		macro		
		NextReg	$50,a
		endm
MMU1		macro		
		NextReg	$51,a
		endm
MMU2		macro		
		NextReg	$52,a
		endm
MMU3		macro		
		NextReg	$53,a
		endm
MMU4		macro		
		NextReg	$54,a
		endm
MMU5		macro		
		NextReg	$55,a
		endm
MMU6		macro		
		NextReg	$56,a
		endm
MMU7		macro		
		NextReg	$57,a
		endm
else
MMU0		macro		
		NextRegA	$50,a
		endm
MMU1		macro		
		NextRegA	$51,a
		endm
MMU2		macro		
		NextRegA	$52,a
		endm
MMU3		macro		
		NextRegA	$53,a
		endm
MMU4		macro		
		NextRegA	$54,a
		endm
MMU5		macro		
		NextRegA	$55,a
		endm
MMU6		macro		
		NextRegA	$56,a
		endm
MMU7		macro		
		NextRegA	$57,a
		endm
endif



		// copper WAIT  VPOS,HPOS
WAIT		macro
		db	HI($8000+(\0&$1ff)+((\1&$3f)<<9))
		db	LO($8000+(\0&$1ff)+(( (\1>>3) &$3f)<<9))
		endm
		// copper MOVE reg,val
MOVE		macro
		db	HI($0000+((\0&$ff)<<8)+(\1&$ff))
		db	LO($0000+((\0&$ff)<<8)+(\1&$ff))
		endm
CNOP		macro
		db	0,0
		endm




