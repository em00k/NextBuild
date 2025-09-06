;
;		Simple DMA block transfer example
;		Data sheet can be found on my blog
;
;		Timers
;		http://www.zilog.com/docs/z80/ps0181.pdf
;
;		DMA
;		https://dailly.blogspot.co.uk/2017/07/z8410-dma-chip-for-zx-spectrum-next.html
;
	OPT	ZXNEXT


;port 107=datagear / port 11=MB02+
Z80DMAPORT	equ 107
SPECDRUM	equ $ffdf
CH0		equ $183b              ; ctc channel #0


	org	$8000
StartAddress:
  
	di
	ld	a,$0
	out	($fe),a

	NextReg 7,3

	ld	a,$c0
	call	ReadNextReg
	and	8				; remember NMI "stackless" mode
	or	%10100001			; CTC timers have priority
	nextreg $c0,a				; base vector = 0xa0, im2 hardware mode
   	
	nextreg $c4,2				; disable interrupt generation for all interrupters
	nextreg $c5,0
	nextreg $c6,0
	nextreg $c7,0

	nextreg $c8,$03
	nextreg $c9,$ff
	nextreg $ca,$ff
	nextreg $cb,$ff

	nextreg $cc,2
	nextreg $cd,1				; enable the special "IRQ interrupt DMA" mode for timer 0
	nextreg $ce,0
	nextreg $cf,0

	nextreg $23,$80
	nextreg $22,$06

	ld	a,VectorTable>>8
	ld	i,a						; im2 table will be at address 0xa000
	im	2
	ei
   
	;  value=(28000000/16)/freq  or  value=(28000000/256)/freq.
	; set up timer 0
	ld	bc,CH0					; Bit0(1) = control word, Bit1(1)= Soft reset (constant must follow), B3(0)=start immediately after constant loaded
	ld	a,%10100011				; Bit7(1)= enable interrupts, Bit6(1)=timer mode, Bit5(0)= prescaler of *256
	out	(c),a   
	; Time constant   
	ld	a,14
	out (c),a					; time constant = 256 (0).  Interval = 14*256/28MHz = 0.128 ms (7850Hz) = about every 2 scan lines
	; timer has started   


	; ******************************************************************************************************************************
	; 	Do DMA loop
	; ******************************************************************************************************************************
Loop:
@lp1	

	; wait for scanlline $40
@wait:
	ld	bc,$243B
	ld	a,$1e
	out	(c),a
	ld	bc,$253B
	in	a,(c)
	and	1
	cp	0
	jr	nz,@wait

	ld	bc,$243B
	ld	a,$1f
	out	(c),a
	ld	bc,$253B
	in	a,(c)
	cp	$30
	jr	nz,@wait

	ld	hl,border
	inc	(hl)
	ld	a,(hl)
	out	($fe),a

	; scroll screen a bit (for animation sake)
	ld	a,(DestAdd)
	inc	a
	and	$1f
	ld	(DestAdd),a

	; transfer the DMA "program" and start
	ld	hl,DMA 
	ld	b,LEN
	ld	c,Z80DMAPORT
	otir

	; clear timing bar
	ld	hl,border
	dec	(hl)
	ld	a,(hl)
	out	($fe),a

	jp	@lp1

; Simple "memcpy" DMA program
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
		  
	db $AD 			;R4-Continuous mode  (use this for block tansfer)
DestAdd:
	dw $4000		;R4-Dest address					(destination address)
		  
	db $82			;R5-Restart on end of block, RDY active LOW
	 
	db $CF			;R6-Load
	db $B3			;R6-Force Ready
	db $87			;R6-Enable DMA
		  
LEN      equ *-DMA		

ScreenDump:
	incbin	"pyj.scr"


; ******************************************************************************
;	Read a next register
; ******************************************************************************
ReadNextReg:
	ld 	bc,$243b
	out 	(c),a
	inc 	b
	in	a,(c)
	ret



	ds	255
STACKSTART
	db	0

Toggle	db	1

border	db	1

; *************************************************************************************
;	Timer IRQ
; *************************************************************************************
ctc_irq:
	nextreg $c9,255
	push	af
	push	bc
	ld		a,(Toggle)
	neg	
	ld		(Toggle),a
	ld		b,a
	ld		a,(border)
	add		a,b
	and		7
	ld		(border),a
	out		($fe),a

	pop	bc
	pop	af
	ei
	reti
	


                org     $d2d2
IM2Routine:     jp		ctc_irq

                org     $d000
VectorTable:            
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine,IM2Routine
                dw      IM2Routine


		org $ffff
		ds	32768
		ds	32768
		ds	32768

                savenex "timer.nex",StartAddress,StackStart        



