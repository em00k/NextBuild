;
;		Simple DMA block transfer example
;		Data sheet can be found on my blog
;
;		https://dailly.blogspot.co.uk/2017/07/z8410-dma-chip-for-zx-spectrum-next.html
;

	opt	sna=start:stackstart

	OPT	ZXNEXT
	opt	Z80


;port 107=datagear / port 11=MB02+
Z80DMAPORT	equ 107
SPECDRUM        equ 0ffdfh



	org	$7f00
StackEnd
	ds	128
StackStart

	org	$8000

start:
	ei
@lp1	
	halt
@wait:	ld	bc,$243B
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

	ld	a,$0
	out	($fe),a


	jp	@lp1

			
DMA	db $C3			;R6-RESET DMA
	db $C7			;R6-RESET PORT A Timing
        db $CB			;R6-SET PORT B Timing same as PORT A

        db $7D 			;R0-Transfer mode, A -> B
        dw ScreenDump		;R0-Port A, Start address				(source address)
        dw 6912			;R0-Block length					(length in bytes)

        db $54 			;R1-Port A address incrementing, variable timing
        db 2			;R1-Cycle length port A
		  
        db $50			;R2-Port B address fixed, variable timing
        db $02 			;R2-Cycle length port B
		  
        db $C0			;R3-DMA Enabled, Interrupt disabled

	db $AD 			;R4-Continuous mode  (use this for block tansfer)
        dw $4000		;R4-Dest address					(destination address)
		  
	db $82			;R5-Restart on end of block, RDY active LOW
	 
	db $CF			;R6-Load
	db $B3			;R6-Force Ready
	db $87			;R6-Enable DMA
		  
LEN      equ *-DMA		

ScreenDump:
	incbin	"pyj.scr"

