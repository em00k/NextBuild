;
;		Simple DMA block transfer example
;		Data sheet can be found on my blog
;
;		https://dailly.blogspot.co.uk/2017/07/z8410-dma-chip-for-zx-spectrum-next.html
;
	OPT	ZXNEXT


;port 107=datagear / port 11=MB02+
Z80DMAPORT	equ 107
SPECDRUM        equ $ffdf



	org	$7f00
StackEnd
	ds	127
StackStart:	db	0

	org	$8000
StartAddress:
	ei
	NextReg	$08,%11010000

MainLoop:	
	halt
@wait:	
	ld	bc,$243B
	ld	a,$1f
	out	(c),a
	ld	bc,$253B
	in	a,(c)
	cp	$40
	jr	nz,@wait

	ld	a,$2		; set timing bar
	out	($fe),a

	; transfer the DMA "program"
	ld	hl,DMA 
	ld	b,LEN
	ld	c,Z80DMAPORT
	otir


	call	ReadKeyboard

	ld	a,(Keys+VK_1)
	and	a
	jr	z,@NotPressed1
	xor	a
	ld	(Keys+VK_1),a
	NextReg	7,0
@NotPressed1:

	ld	a,(Keys+VK_2)
	and	a
	jr	z,@NotPressed2
	xor	a
	ld	(Keys+VK_2),a
	NextReg	7,1
@NotPressed2:

	ld	a,(Keys+VK_3)
	and	a
	jr	z,@NotPressed3
	xor	a
	ld	(Keys+VK_3),a
	NextReg	7,2
@NotPressed3:

	ld	a,(Keys+VK_4)
	and	a
	jr	z,@NotPressed4
	xor	a
	ld	(Keys+VK_4),a
	NextReg	7,3
@NotPressed4:


	ld	a,$0
	out	($fe),a

	jp	MainLoop



			
DMA	db $C3			;R6-RESET DMA
	db $C7			;R6-RESET PORT A Timing
        db $CB			;R6-SET PORT B Timing same as PORT A

        db $7D 			;R0-Transfer mode, A -> B
        dw ScreenDump		;R0-Port A, Start address				(source address)
        dw 6912			;R0-Block length					(length in bytes)

        db $54 			;R1-Port A address incrementing, variable timing
        db $02			;R1-Cycle length port A
		  
        db $50			;R2-Port B address fixed, variable timing
        db $02			;R2-Cycle length port B
		  
	db $AD 			;R4-Continuous mode  (use this for block tansfer)
        dw $4000		;R4-Dest address					(destination address)
		  
	db $82			;R5-Restart on end of block, RDY active LOW
	 
	db $CF			;R6-Load
	db $B3			;R6-Force Ready
	db $87			;R6-Enable DMA
		  
LEN      equ *-DMA		

	include	"utils.asm"

ScreenDump:
	incbin	"pyj.scr"

	savenex	"dmademo.nex",StartAddress,StackStart




