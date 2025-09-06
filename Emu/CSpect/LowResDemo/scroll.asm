
; ************************************************************************
;
;	Function:	Init the map. Load files and reset the scroll
;
; ************************************************************************
InitMap:

        ld      a,0
        nextreg 67,a              ; write to the ULA palette
        ld      a,0
        nextreg 64,a              ; write to the ULA palette
@SetAll:
        nextreg 65,a
        inc     a
        cp      0
        jr      nz,@SetAll

        ld      a,1
        nextreg 67,a              ; write to the ULA palette


        ld      a,128
        nextreg 64,a              ; write to the ULA palette
        ld      a,0
        nextreg 65,a


        

        ld  hl,0
        ld  (ForeX),hl
        ld  (BackX),hl
        ld  (ForeY),hl
        ld  (BackY),hl

        xor a
        nextreg    23,a
        nextreg    22,a
        nextreg    50,a
        nextreg    51,a


		; load data first...
        ld  a,(which)
        and a
        jr  nz,@Xenon2

        ld      a,128
        nextreg    21,a

        LoadFile    MBackground,$c000        ; get the background in first
        ld  hl,$c000
        ld  de,$4000
        ld  bc,$1800
        ldir    
        ld  hl,$d800        ; second half of screen
        ld  de,$6000
        ld  bc,$1800
        ldir    

        ld     hl,MForeground
        jp     Load256


@Xenon2:
        ld      a,128+1
        nextreg    21,a

		LoadFile	Background,$c000		; get the background in first
		ld	hl,$c000
		ld	de,$4000
		ld	bc,$1800
		ldir	
		ld	hl,$d800		; second half of screen
		ld	de,$6000
		ld	bc,$1800
		ldir	

		ld	   hl,Foreground
        call    Load256


		ret



; ******************************************************************************
; Function:	Load a 256 colour bitmap directly into the screen
;		Once loaded, enable and display it
; In:		hl = file data pointer
; ******************************************************************************
Load256:
		; ignore file length... it's set for this (should be 256*192)
		inc	hl
		inc	hl

		push	hl
                pop	ix
                ld      b,FA_READ
                call    fOpen
                jr	c,@error_opening	; error opening?
                cp	0
                jr	z,@error_opening	; error opening?
                ld	(LoadHandle),a		; store handle


                ld	e,3			; number of blocks
                ld	a,1			; first bank...
                ld	(Loadbank),a
@LoadAll:                
                ld	a,(LoadHandle)		; load block into $c000
                ld	bc,64*256
                ld	ix,$c000
                call	fread

                ld      bc, $123b		; enable $0000 write
                ld	a,(Loadbank)
                out	(c),a			; bank in first bank


                ld	bc,$4000
                ld	hl,$c000
                ld	de,0
                ldir	

                ld      bc, $123b		; disable RAM in lower $0000
                ld	a,0
                out	(c),a			; bank in first bank

                ld	a,(Loadbank)
                add	a,$40
                ld	(Loadbank),a
                cp	$c1
                jr	nz,@LoadAll


                ld	a,(LoadHandle)
                call	fClose

                ld      bc, $123b		; enable screen
                ld	a,2
                out	(c),a                               
               	ret
@error_opening:
		ld      a,5
        	out     ($fe),a
@SkipError
		ret

Loadbank	db	0



