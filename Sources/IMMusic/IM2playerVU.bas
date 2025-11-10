border 0

'SUB InitMusic(Address as uinteger)

asm 
	IJUMP EQU $AE00				;' this is where will have a repeated byte over over = ISR
	ISR EQU $BFBF					;'This is the location where we put a jump to our routine
	PLAYERLOCATION EQU $c000
	
	;  setup
	; copy playroutine
	ld hl,vt2player
	ld de,PLAYERLOCATION
	ld bc,1617
	ldir
	ld hl,music
	call PLAYERLOCATION+3
	ld hl,Ints
	ld a,$C3					; we need to store "jp Ints" for the ISR
	ld de,ISR
	ld (de),a				; jp 
	ld a,l
	inc de 					; next byte 
	ld (de),a				; h *  256 + ISR/256
	ld a,h
	inc de 					; next byte 
	ld (de),a				; ISR/256 
	ld hl,ISR
	ld a,h					; our jump jump vector needs to be filled $BFBF etc
	
	ld hl,IJUMP				; for cspect ISR JUMP starts
	inc hl
	ld (hl),a
	ld hl,IJUMP
	inc h 
	;ld hl,$AF00				; for fuse/Next ISR JUMP starts
	ld (hl),a

	jp intend

Ints:	
	di                  ; disable interrupts
	push af             
	push bc
	push de
	push hl
	push ix             
	push iy
	ex af, af'
	push af            
	
	;	NextRegExB($56,$37)					' slect bank $26 	
	;	NextRegExB($57,$38)					' slect bank $26 	
	
	call 49157       ; play the current tune
	call vumeter
	;NextRegExB($56,$37)					' slect bank $26 	
	;NextRegExB($57,$38)					' slect bank $26 	

	pop af 
	ex af, af'
	pop iy
	pop ix              
	pop hl
	pop de
	pop bc
	pop af              
	ei             
	jp 56				; uncomment for use in basic, load in 48k mode thought and with fuse  
	;reti 			; comment out for normal zxb use 
	
	
tempa:
	db 0
tempb:
	db 0
intend:
	ld a,$AE
	ld i,a
	IM 2
end asm
	
text$="                                           THIS IS A SIMPLE SCROLLER RUNNING WHILE INTERRUPT MUSIC IS PLAYING....    " 

'; end 					;'uncomment for basic, Fuse real Next only and in 48k mode 

do

	'text$=text$(1 to len text$)+text$(1)
	'print at 23,0; text$( to 31)
	'pause 4
	'vumeter()
LOOP 	

vt2:
asm 
vt2player:
	incbin "vt49152.bin"
end asm 

asm 
music:
	incbin "level1.pt3"
musicend:
end asm          

'sub vumeter()

asm 
; ---------------------------------------------------------------------------
word_B63A:      dw 0FFE7h               ; DATA XREF: sub_B5C0↑w
                                        ; sub_B5C0+1E↑r
byte_B63C:      db 5                    ; DATA XREF: sub_B5FB+E↑w
                                        ; sub_B5FB+20↑r ...

; =============== S U B R O U T I N E =======================================

							;	pop iy
vumeter:                                ; CODE XREF: RAM:B468↑p
                ld      hl, unk_B732
                rlc     (hl)
                call    nc, sub_B71E
                ld      de, 108h
                call    getpitch
                ld      de, 309h
                call    getpitch
                ld      de, 50Ah
                call    getpitch
                ld      de, unk_B733
                ld      b, 20h ; ' '
                ld      hl, 5AFFh

loc_B65F:                               ; CODE XREF: vumeter+48↓j
                push    bc
                push    hl
                ld      b, 8
                ld      a, (de)
                inc     de
                ld      (byte_B688), a

loc_B668:                               ; CODE XREF: vumeter+43↓j
                ld      a, (byte_B688)
                cp      0E0h
                jp      z, loc_B682
                add     a, 20h ; ' '
                ld      (byte_B688), a
                rra
                rra
                and     38h ; '8'
                or      47h ; 'G'
                ld      (hl), a
                ld      a, l
                sbc     a, 20h ; ' '
                ld      l, a
                djnz    loc_B668

loc_B682:                               ; CODE XREF: vumeter+30↑j
                pop     hl
                dec     hl
                pop     bc
                djnz    loc_B65F
                ret
; End of function vumeter

; ---------------------------------------------------------------------------
byte_B688:      db 0E0h                 ; DATA XREF: vumeter+28↑w
                                        ; vumeter:loc_B668↑r ...

; =============== S U B R O U T I N E =======================================


getpitch:                               ; CODE XREF: vumeter+B↑p
                                        ; vumeter+11↑p ...
                ld      bc, 0FFFDh
                out     (c), e
                in      a, (c)
                cp      0
                ret     z
                dec     a
                cp      0
                ret     z
                ld      (byte_B731), a
                out     (c), d
                in      e, (c)
                ld      a, e
                and     0Fh
                cp      0
                jp      z, loc_B6C0
                cp      1
                jp      z, loc_B6D5
                cp      2
                jp      z, loc_B6E9
                cp      3
                jp      z, loc_B6FC
                cp      4
                jp      z, loc_B70E
                ld      hl, unk_B752
                jp      loc_B711
; ---------------------------------------------------------------------------

loc_B6C0:                               ; CODE XREF: getpitch+1A↑j
                dec     d
                out     (c), d
                in      a, (c)
                ld      b, 0
                rlca
                and     0Fh
								add a,6
                ld      c, a
                ld      hl, unk_B733
                add     hl, bc
                jp      loc_B711
; ---------------------------------------------------------------------------

loc_B6D5:                               ; CODE XREF: getpitch+1F↑j
                dec     d
                out     (c), d
                in      a, (c)
                rlca
                rlca
                rlca
                and     7
                ld      b, 0
                ld      c, a
                ld      hl, unk_B743
                add     hl, bc
                jp      loc_B711
; ---------------------------------------------------------------------------

loc_B6E9:                               ; CODE XREF: getpitch+24↑j
                dec     d
                out     (c), d
                in      a, (c)
                rlca
                rlca
                and     7
							 ; add a,a
                ld      a, c
                ld      b, 0
                ld      hl, unk_B74B
                add     hl, bc
                jp      loc_B711
; ---------------------------------------------------------------------------

loc_B6FC:                               ; CODE XREF: getpitch+29↑j
                dec     d
                out     (c), d
                in      a, (c)
                rlca
								rlca
                
                and     0fh
                ld      b, 0
                ld      c, a
                ld      hl, unk_B74F
                add     hl, bc
                jp      loc_B711
; ---------------------------------------------------------------------------

loc_B70E:                               ; CODE XREF: getpitch+2E↑j
                ld      hl, unk_B751

loc_B711:                               ; CODE XREF: getpitch+34↑j
                                        ; getpitch+49↑j ...
                ld      a, (byte_B731)
                xor     0FFh
                rla
                rla
                rla
                rla
                and     0E0h
                ld      (hl), a
                ret
; End of function getpitch


; =============== S U B R O U T I N E =======================================


sub_B71E:                               ; CODE XREF: vumeter+5↑p
                ld      hl, unk_B733
                ld      b, 20h ; ' '
                ld      c, 20h ; ' '

loc_B725:                               ; CODE XREF: sub_B71E+10↓j
                ld      a, (hl)
                cp      0E0h
                jp      z, loc_B72D
                add     a, c
                ld      (hl), a

loc_B72D:                               ; CODE XREF: sub_B71E+A↑j
                inc     hl
                djnz    loc_B725
                ret
; End of function sub_B71E

; ---------------------------------------------------------------------------
byte_B731:      db 0Ah                  ; DATA XREF: getpitch+E↑w
                                        ; getpitch:loc_B711↑r
unk_B732:       db 0FBh                 ; DATA XREF: vumeter↑o
unk_B733:       db 0E0h                 ; DATA XREF: vumeter+1A↑o
                                        ; getpitch+45↑o ...
                db 0E0h
                db 0E0h
                db 0E0h
                db  40h ; @
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
unk_B743:       db 0E0h                 ; DATA XREF: getpitch+59↑o
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
                db 0E0h
unk_B74B:       db 0E0h                 ; DATA XREF: getpitch+6C↑o
                db 0E0h
                db 0E0h
                db 0E0h
unk_B74F:       db    0                 ; DATA XREF: getpitch+7E↑o
                db 0C0h
unk_B751:       db  40h ; @             ; DATA XREF: getpitch:loc_B70E↑o
unk_B752:       db  20h                 ; DATA XREF: getpitch+31↑o
end asm 
'#end sub   