;
; ZX Spectrum Next issue 1 - 3 AYs sound test
; 3xAY demo author (Purple Motion) 
; authors of these 3xAY cover: Factor6 and TDM from AY-Riders. http://ay-riders.speccy.cz/006.htm
; Thanks to Velesoft for the music.
;
; 
                ;opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                     ; Set z80 mode
                opt             ZXNEXTREG
                
				;seg     CODE_SEG, 10:$0000,$6000

				;seg     CODE_SEG
                org     $6000      
StackEnd:
                ds      127
StackStart:     db      0

                org     $7000
                call    65000           ; init player
StartAddress:
MainLoop:
                halt
@wait:                
				call	ReadRaster
				ld		a,l
				cp		$50
				jp		nz,@wait

                ld	a,3
                out     ($fe),a
                call    65003           ; call player
                xor     a
                out     ($fe),a         ; black border again

                jp      MainLoop

; ******************************************************************************
; 
; Function:	Read the current Raster into HL
; Out:		hl = address
;
; ******************************************************************************
ReadRaster:
		; read MSB of raster first
		ld	a,$1e
		ld	bc,$243b	; select NEXT register
		out	(c),a
		inc	b		; $253b to access (read or write) value
		in	a,(c)	
		and	1	
		ld	h,a

		; now read LSB of raster
		ld	a,$1f
		dec	b
		out	(c),a
		inc	b
		in	a,(c)		
		ld	l,a
		ret

                ; its actually a TAP file, but I don't support them so, make it an SNA
                org     $8000-312
                incbin  "3xay.dat"              	; DAT is cropped by a few bytes
                
		; include tape file to push into 128K region - bug in SNasm
		incbin  "3xay.TAP"              	
                //savebin "3xay.dat",$8000-312,33079


	savenex "3xay.nex",StartAddress,StackStart        



