
; ************************************************************************
;
;	Function:	Init the map. Load files and reset the scroll
;
; ************************************************************************
InitMap:
            NextReg 23,0            ; layer 2 x scroll
            NextReg 22,0            ; layer 2 y scroll
            ld      a,(reg_15)
            NextReg $15,a           ; Enable sprites, and layer order S-L2-T/U


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


            ld      a,(reg_68)
            NextReg $68,a
            
            ; enable tilemap
            ld      a,(reg_6b)
            NextReg $6b,a
            ld      a,(reg_6c)
            NextReg $6c,a
            NextReg $6e,$36
            NextReg $6f,$40
            NextReg $4c,$05        

            NextReg  $1a,0
            NextReg  $1a,255
            NextReg  $1a,0
            NextReg  $1a,255

            NextReg  $18,0
            NextReg  $18,255
            NextReg  $18,0
            NextReg  $18,255

            ; tilemap window
            ;NextReg $1b,16
            ;NextReg $1b,143
            ;NextReg $1b,0
            ;NextReg $1b,194

            ; set border to black.
            NextReg 64,128         ; write to the ULA palette
            NextReg 65,0

            call    CopyTiles
            call    DrawULA
            call    DrawTileMap
            ret




DrawULA:
        ; ULA goes in primary screen
;        ld        a,(reg_15)
;        and       %01111111
;        or        %00000000        ; disable lores
;        ld        (reg_15),a
;        NextReg    $15,a
;        ld        a,%10000000
;        NextReg $69,a
;        NextReg $43,%00110000     ; Tilemap palette 0


        NextReg    $56,14
        NextReg    $57,24
    


        ld    hl,$e000
        ld    de,$c000
        ld    b,128

@lp2:
        push  bc
        push  de
        ld    b,8
@lp1:
        ld    a,(hl)
        ld    (de),a
        inc    hl
        inc    d
        djnz   @lp1

        pop    de
        pop    bc
        inc    de
        djnz  @lp2

        ld    a,%01010111
        ld    hl,$d800
        ld    de,$d801
        ld    bc,128
        ld    (hl),a
        ldir    

        ld    a,%01011011
        ld    hl,$d800+(128)
        ld    de,$d801+128
        ld    bc,768-128
        ld    (hl),a
        ldir    



        ; bottom line is white
        ld    a,%01010111
        ld    hl,$d800+(768-32)
        ld    de,$d801+(768-32)
        ld    bc,64
        ld    (hl),a
        ldir   
        
        ld    a,1
        out    ($fe),a
        ret



ToggleTilePri:
        ld    hl,$7601
        ld    bc,40*16        ;1280

        ld    a,(toggle)
        xor   1
        ld    (toggle),a
        ld    d,a

@loop:
        ld    a,(hl)
        xor   1
        ld    (hl),a
        inc   hl
        inc   hl

        dec   bc
        ld    a,b
        or    c
        and   a
        jr    nz,@loop
        ret

toggle  db    0



DrawTileMap:
        ld    ix,$7608    ; start of screen
        ld    de,80*2

        ld    b,4
@lp1:
        push  ix
        ld    a,(ix+1)
        or    1
        ld    (ix+1),a
        ld    a,(ix+3)
        or    1
        ld    (ix+3),a


        ld    a,(ix+5)
        or    1
        ld    (ix+5),a
        ld    a,(ix+7)
        or    1
        ld    (ix+7),a

        ld    a,(ix+85)
        or    1
        ld    (ix+85),a
        ld    a,(ix+87)
        or    1
        ld    (ix+87),a

        add   ix,de

        ld    a,(ix+1)
        or    1
        ld    (ix+1),a
        ld    a,(ix+3)
        or    1
        ld    (ix+3),a
        ld    a,(ix+81)
        or    1
        ld    (ix+81),a
        ld    a,(ix+83)
        or    1
        ld    (ix+83),a

@SKIP
        ld    a,(ix+5)
        or    1
        ld    (ix+5),a


        pop   ix           
        add   ix,de
        add   ix,de

        djnz  @lp1
        ret



CopyTiles:
        NextReg    $56,36
        NextReg    $57,37
        ld    hl,$c000
        ld    de,$4000
        ld    bc,$4000
        ldir
        ret
        ;jp    DrawTileMap


CopyLores:
        NextReg    $56,38
        NextReg    $57,39
        ld    hl,$d800
        ld    de,$4000+(128*3)
        ld    bc,$2000
        ldir
        ret



CopyL2Hires:
        NextReg $43,%01010100     ; L2 palette 2
        NextReg $40,0
        ld    hl,L2HiResPalette
        ld    b,15
@lp1:   ld    a,(hl)
        inc   hl
        NextReg $44,a
        ld    a,(hl)
        inc   hl
        xor    a
        NextReg $44,a
        djnz    @lp1

        ld    a,%00100000        ; 640 mode
        NextReg $70,a
        ld    a,20
        NextReg $12,a


        NextReg $18,8
        NextReg $18,152
        NextReg $18,8
        NextReg $18,248
        ret

; %100 101 100do 4
; 0x9CA096
; 0x12c

