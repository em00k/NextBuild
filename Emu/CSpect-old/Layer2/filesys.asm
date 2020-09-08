; 
; Publicly available stuff..........
;
; esxDOS
;       setdrv  xor a
;		rst $08
;		db $89
;		a = drive
;		ret
;
;       fopen   ld      b,$01:db 33
;       fcreate ld      b,$0c:push ix:pop hl:ld a,42:rst $08:db $9a:ld (handle),a:ret
;       fread   push ix:pop hl:db 62
;       handle  db 0:or a:ret z:rst $08:db $9d:ret
;       fwrite  push ix:pop hl:ld a,(handle):or a:ret z:rst $08:db $9e:ret
;       fclose  ld      a,(handle):or a:ret z:rst $08:db $9b:ret
;       fseek   ld a,(handle):or a:ret z:rst $08:db $9f:ret
;       // Seek BCDE bytes. A=handle
;       //      L=mode:         0-from start of file
;       //                      1-forward from current position
;       //                      2-back from current position
;       // On return BCDE=current file pointer.
;       // Does not currently return bytes
; 
; 

M_GETSETDRV  equ $89
F_OPEN       equ $9a
F_CLOSE      equ $9b
F_READ       equ $9d
F_WRITE      equ $9e
F_SEEK       equ $9f

FA_READ      equ $01
FA_APPEND    equ $06
FA_OVERWRITE equ $0C

; *******************************************************************************************************
;
;	Get/Set the drive (get default drive)
;
; *******************************************************************************************************
GetSetDrive:	
		push	af	; no idea what it uses....
		push	bc
		push	de
		push	hl
		push	ix

		xor	a	; set drive. 0 is default
		rst	$08
		db	$89
		ld	(DefaultDrive),a

		pop	ix
		pop	hl
		pop	de
		pop	bc
		pop	af
		ret
DefaultDrive:	db	0

; *******************************************************************************************************
;	Function:	Open a file read for reading/writing
;	In:		ix = filename
;			b  = Open filemode
;	ret		a  = handle, 0 on error
; *******************************************************************************************************
fopen:		push	hl
		push	ix
		pop	hl
		ld	a,(DefaultDrive)
		rst	$08
		db	F_OPEN
		pop	hl
		ret


; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		ix  = address to read into
;			bc  = amount to read
;	ret:		carry set = error
; *******************************************************************************************************
fread:
		or   	a             ; is it zero?
		ret  	z             ; if so return		

        	push	hl

        	push	ix
		pop	hl
		rst	$08
		db	F_READ

		pop	hl
		ret

; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		ix  = address to read into
;			bc  = amount to read
;	ret:		carry set = error
; *******************************************************************************************************
fwrite:
		or   	a             ; is it zero?
		ret  	z             ; if so return		

        	push	hl

        	push	ix
		pop	hl
		rst	$08
		db	F_WRITE

		pop	hl
		ret

; *******************************************************************************************************
;	Function:	Close open file
;	In:		a  = handle
;	ret		a  = handle, 0 on error
; *******************************************************************************************************
fclose:		
		or   	a             ; is it zero?
             	ret  	z             ; if so return		
		rst	$08
		db	F_CLOSE
		ret



; *******************************************************************************************************
;	Function	Read bytes from the open file
;	In:		a   = file handle
;			L   = Seek mode (0=start, 1=rel, 2=-rel)
;			BCDE = bytes to seek
;	ret:		BCDE = file pos from start
; *******************************************************************************************************
fseek:
		push	ix
		push	hl
		rst	$08
		db	F_SEEK
		pop	hl
		pop	ix
		ret

; *******************************************************************************************************
; Init the file system
; *******************************************************************************************************
InitFileSystem:
		call    GetSetDrive
		ret


; *******************************************************************************************************
; Function:	Load a whole file into memory	(confirmed working on real machine)
; In:		hl = file data pointer
;		ix = address to load to
; *******************************************************************************************************
Load:		call    GetSetDrive		; need to do this each time?!?!?

		push	bc
		push	de
		push	af


		; get file size
		ld	c,(hl)
		inc	l
		ld	b,(hl)
		inc	l

		push	bc			; store size
		push	ix			; store load address


		push	hl			; get name into ix
                pop	ix
                ld      b,FA_READ		; mode open for reading
                call    fOpen
                jr	c,@error_opening	; carry set? so there was an error opening and A=error code
                cp	0			; was file handle 0?
                jr	z,@error_opening	; of so there was an error opening.

                pop	ix			; get load address back
                pop	bc			; get size back

                push	af			; remember handle
                call	fread			; read data from A to address IX of length BC                
		jr	c,@error_reading

                pop	af			; get handle back
                call	fClose			; close file
                jr	c,@error_closing

        	pop	af			; normal exit
		pop	de
		pop	bc
		ret

;
; On error, display error code an lock up so we can see it
;
@error_opening:
		pop	ix
@error_reading:		
		pop	bc	; don't pop a, need error code

@error_closing:
@NormalError:  	pop	bc	; don't pop into A, return with error code
		pop	de
		pop	bc
		ret



; *******************************************************************************************************
; Function:	Load a whole file into memory	(confirmed working on real machine)
; In:		hl = file data pointer
;		ix = address to save from
;		bc = size
; *******************************************************************************************************
Save:		call    GetSetDrive		; need to do this each time?!?!?

		push	bc			; store size
		push	ix			; store save address


		push	hl			; get name into ix
                pop	ix
                ld      b,FA_OVERWRITE		; mode open for writing
                call    fOpen
                jr	c,@error_opening	; carry set? so there was an error opening and A=error code
                cp	0			; was file handle 0?
                jr	z,@error_opening	; of so there was an error opening.

                pop	ix			; get save address back
                pop	bc			; get size back

                push	af			; remember handle
                call	fwrite			; read data from A to address IX of length BC                
		jr	c,@error

                pop	af			; get handle back
                call	fClose			; close file
@error:
		ret

;
; On error, display error code an lock up so we can see it
;
@error_opening:
		pop	ix
		pop	bc	; don't pop a, need error code
		ret


; ******************************************************************************
; Function:	Load a 256 colour bitmap directly into the screen
;		Once loaded, enable and display it
; In:		hl = file data pointer
; ******************************************************************************
Load256Screen:
		push	bc
		push	de
		push	ix
		push	af

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
@LoadAll:
                ld      bc, $123b
                out	(c),a			; bank in first bank
                
                push	af

                ld	a,(LoadHandle)
                ld	bc,64*256
                ld	ix,0
                call	fread

                pop	af
                add	a,$40
                dec	e
                jr	nz,@LoadAll

                ld	a,(LoadHandle)
                call	fClose

                ld      bc, $123b
                ld	a,2
                out	(c),a                               
               	jr	@SkipError 
@error_opening:
		ld      a,5
        	out     ($fe),a
@SkipError
        	pop	af
		pop	ix
		pop	de
		pop	bc
		ret
LoadHandle	db	0







; *******************************************************************************************************
; Test seeking
; *******************************************************************************************************
TestFiles:

		ld	b,0
		ld	iy,$c000
		xor	a
@wipe		ld	(iy+0),a
		inc	iy
		djnz	@wipe

		call    GetSetDrive		; need to do this each time?!?!?

		ld	hl,TestTxt+3
		ld	ix,$c000

		push	ix
		push	hl
		pop	ix
                ld      b,FA_READ
                call    fOpen
                jr	c,@Error
		ld	(FileHandle),a
		pop	ix

                ld	b,10
@readall        push	bc

		ld	a,(FileHandle)              
                ld	bc,2
                call	fread
                ld	bc,2
                add	ix,bc

                ld	bc,0
                ld	de,2
                ld	a,(FileHandle)
                ld	l,1
                call	fseek

                pop	bc
                djnz	@readall

                ld	a,(FileHandle)
                call	fclose
                ret

@Error:		pop	ix
                ret
FileHandle	db	0

