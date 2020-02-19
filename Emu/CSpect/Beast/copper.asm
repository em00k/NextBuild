;
; Copper stuff
;
; ZX Spectrum Next Framework V0.1 by Mike Dailly, 2018
;
COP_NOP                 equ     0
COP_PER_1               equ     5
COP_PER_2               equ     6
COP_TURBO               equ     7        
COP_PER_3               equ     8
COP_LAYER2_BANK         equ     18      ; layer 2 bank
COP_LAYER2_SBANK        equ     19      ; layer 2 shadow bank
COP_TRANSPARENT         equ     20      ; Global transparency color
COP_SPRITE              equ     21      ; Sprite and Layers system
COP_LAYER2_XOFF         equ     22
COP_LAYER2_YOFF         equ     23
COP_LAYER2_CLIP         equ     24
COP_SPRITE_CLIP         equ     25
COP_ULA_CLIP            equ     26
COP_CLIP_CNT            equ     28
COP_IRQ                 equ     34
COP_IRQ_RAST_LO         equ     35
COP_TILEMAP_X_MSB       equ     47
COP_TILEMAP_X_LSB       equ     48
COP_TILEMAP_Y_OFF       equ     49
COP_LOWRES_XOFF         equ     50
COP_LOWRES_YOFF         equ     51
COP_PALETTE_INDEX       equ     64
COP_PALETTE_COLOUR      equ     65      ; 8 bit palette colour
COP_PALETTE_FORMAT      equ     66      
COP_PALETTE_CONTROL     equ     67       
COP_PALETTE_COLOUR_9    equ     68      ; 9 bit palette colour
COP_MMU0                equ     80
COP_MMU1                equ     81
COP_MMU2                equ     82
COP_MMU3                equ     83
COP_MMU4                equ     84
COP_MMU5                equ     85
COP_MMU6                equ     86
COP_MMU7                equ     87
COP_DATA                equ     96
COP_CONTROL_LO          equ     97
COP_CONTROL_HI          equ     98
COP_FALLBACK_COLOUR     equ     $4a

PAPER_INDEX     equ     16

; 1K copper
GameCopper:     
		WAIT    12,0					; Cloud strip 2
Cloud1:		MOVE    COP_TILEMAP_X_LSB,0        
Cloud1_MSB:	MOVE    COP_TILEMAP_X_MSB,0        
		WAIT    48,128
		MOVE	COP_PALETTE_COLOUR,$92	;ff
		WAIT    52,128					; Cloud strip 2
Cloud2:		MOVE    COP_TILEMAP_X_LSB,0        
Cloud2_MSB:	MOVE    COP_TILEMAP_X_MSB,0        
		WAIT    72,128					; Cloud strip 2
Cloud3:		MOVE    COP_TILEMAP_X_LSB,0        
Cloud3_MSB:	MOVE    COP_TILEMAP_X_MSB,0        
		WAIT    75,128
		MOVE	COP_PALETTE_COLOUR,$b2	;ff
		WAIT    80,128					; Cloud strip 2
Cloud4:		MOVE    COP_TILEMAP_X_LSB,0        
Cloud4_MSB:	MOVE    COP_TILEMAP_X_MSB,0        
		WAIT    86,128					; Cloud strip 2
Hills:		MOVE    COP_TILEMAP_X_LSB,0        
Hills_MSB:	MOVE    COP_TILEMAP_X_MSB,0        
		WAIT    95,128
		MOVE	COP_PALETTE_COLOUR,$d2	;ff

		WAIT    118,128
		MOVE	COP_PALETTE_COLOUR,$f2	;ff

      		WAIT    163,0
Grass1          MOVE	COP_LAYER2_XOFF,0
		WAIT    164,0					; Cloud strip 2
		;MOVE	COP_SPRITE,%10001000
Wall:		MOVE    COP_TILEMAP_X_LSB,0        

		WAIT    165,0
Grass2:		MOVE	COP_LAYER2_XOFF,0
		WAIT    169,0
Grass3:		MOVE	COP_LAYER2_XOFF,0
		WAIT    173,0
Grass4:		MOVE	COP_LAYER2_XOFF,0
		WAIT    179,0
Grass5:		MOVE	COP_LAYER2_XOFF,0


		; set the top scroll for the main area
                WAIT    220,0
Cloud0:		MOVE	COP_TILEMAP_X_LSB,0
Cloud0_MSB:	MOVE	COP_TILEMAP_X_MSB,0
Trees0:         MOVE	COP_LAYER2_XOFF,0


		MOVE	$43,%10000000
		MOVE	COP_PALETTE_INDEX,$13
		MOVE	COP_PALETTE_COLOUR,$72	;ff
		;MOVE	COP_FALLBACK_COLOUR,%00000011

                WAIT    400,0					; infinite wait


; 72
; 92
; 92
; b2
; b2
; d2
; f2s


CopperEnd:
CopperSize      equ     CopperEnd-GameCopper


