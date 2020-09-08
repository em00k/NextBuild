
; ************************************************************************
;
;	Function:	Init the map. Load files and reset the scroll
;
; ************************************************************************
InitMap:
            NextReg 23,0            ; layer 2 x scroll
            NextReg 22,0            ; layer 2 y scroll
            NextReg $15,1           ; Enable sprites, and layer order S-L2-T/U


            ; set tilemap palette (9 bit palette)
            NextReg $43,%00110000     ; Tilemap palette 0
            NextReg 64,0              ; start at index 0
            ld      hl,TilePalette
            ld      b,0
@SetAll2:
            ld      a,(hl)          ; RRRGGGBB
            inc     hl
            NextReg $44,a
            ld      a,(hl)          ; lower B
            inc     hl
            NextReg $44,a
            djnz    @SetAll2


            ; enable tilemap
            NextReg $6b,%10000011
            NextReg $6e,$76
            NextReg $6f,$40
            NextReg $4c,$00        

            ; tilemap window
            NextReg $1b,16
            NextReg $1b,143
            NextReg $1b,0
            NextReg $1b,194

            ; set border to black.
            NextReg 64,128         ; write to the ULA palette
            NextReg 65,0

            ; fall through

; ******************************************************************************
; Function: Update copper
; ******************************************************************************
UpdateCopper:
            ld      hl,GameCopper
            ld      de,CopperSize
            call    UploadCopper


            ; reset and start copper
            NextReg $61,0           ; Copper address LSB
            NextReg $62,%11000000   ; Copper control
            ret


; ******************************************************************************
; Function: Scroll layers
; ******************************************************************************
ScrollBackground:

                ld      a,(ForeX)
                inc     a
                inc     a
                ld      (ForeX),a

                ; Scroll clouds...

                ; ------------------------------------
                ; top row of clouds
                ; ------------------------------------
                ld      hl,(Cloud_0)
                inc     hl
                push    hl
                pop     de
                add     de,-(320*1)
                ld      a,d
                or      e
                and     a
                jr      nz,@SkipCheck
                ld      hl,0
@SkipCheck:                
                ld      (Cloud_0),hl
                ld      a,l   
                ld      (Cloud0+1),a
                ld      a,h
                and     1
                ld      (Cloud0_MSB+1),a



                ; ------------------------------------
                ; clouds 2 + hills
                ; ------------------------------------
                ld      hl,(Cloud_1)
                inc     hl
                push    hl
                pop     de
                add     de,-(320*2)
                ld      a,d
                or      e
                and     a
                jr      nz,@SkipCheck2
                ld      hl,0
@SkipCheck2:                
                ld      (Cloud_1),hl
                srl     h
                rr      l
                ld      a,l   
                ld      (Cloud1+1),a
                ld      (Hills+1),a
                ld      a,h
                and     1
                ld      (Cloud1_MSB+1),a
                ld      (Hills_MSB+1),a


                ; ------------------------------------
                ; clouds 3
                ; ------------------------------------
                ld      hl,(Cloud_2)
                inc     hl
                push    hl
                pop     de
                add     de,-(320*4)
                ld      a,d
                or      e
                and     a
                jr      nz,@SkipCheck3
                ld      hl,0
@SkipCheck3:                
                ld      (Cloud_2),hl
                srl     h
                rr      l
                srl     h
                rr      l
                ld      a,l   
                ld      (Cloud2+1),a
                ld      a,h
                and     1
                ld      (Cloud2_MSB+1),a


                ; ------------------------------------
                ; clouds 4
                ; ------------------------------------
                ld      hl,(Cloud_3)
                inc     hl
                push    hl
                pop     de
                add     de,-(320*8)
                ld      a,d
                or      e
                and     a
                jr      nz,@SkipCheck4
                ld      hl,0
@SkipCheck4:                
                ld      (Cloud_3),hl
                srl     h
                rr      l
                srl     h
                rr      l
                srl     h
                rr      l
                ld      a,l   
                ld      (Cloud3+1),a
                ld      a,h
                and     1
                ld      (Cloud3_MSB+1),a


                ; ------------------------------------
                ; clouds 4
                ; ------------------------------------
                ld      hl,(Cloud_4)
                inc     hl
                push    hl
                pop     de
                add     de,-(320*16)
                ld      a,d
                or      e
                and     a
                jr      nz,@SkipCheck5
                ld      hl,0
@SkipCheck5:                
                ld      (Cloud_4),hl
                srl     h
                rr      l
                srl     h
                rr      l
                srl     h
                rr      l
                srl     h
                rr      l
                ld      a,l   
                ld      (Cloud4+1),a
                ld      a,h
                and     1
                ld      (Cloud4_MSB+1),a

                ret

Cloud_0         dw      0
Cloud_1         dw      0
Cloud_2         dw      0
Cloud_3         dw      0
Cloud_4         dw      0
Hills_1         dw      0
ForeX           dw      0
hack            db      0,0,0

; ************************************************************
;
; Do the different scrolling grass levels
;
; ************************************************************
ScrollGrass:
                ld      ix,GrassScrolls
                ld      b,8
@doall:         inc     (ix+0)                ; move once
                ld      a,(ix+1)
                dec     a                
                and     a
                jr      nz,@StoreResult
                ld      a,(ix+0)
                adc     a,(ix+3)                ; add on speed
                ld      (ix+0),a
                ld      a,(ix+2)
@StoreResult:
                ld      (ix+1),a
                ld      de,4
                add     ix,de
                djnz    @doall
                ret



GrassScrolls    db      0,1,2,1           ; scroll, curr delay, master delay, speed
                db      0,1,1,1
                db      0,1,1,2
                db      0,1,1,3           
                db      0,1,1,4
                db      0,1,1,5
                db      0,1,1,6
                db      0,1,1,7



