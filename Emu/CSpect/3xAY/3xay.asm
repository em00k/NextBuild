;
; ZX Spectrum Next issue 1 - 3 AYs sound test
; 3xAY demo author (Purple Motion) 
; authors of these 3xAY cover: Factor6 and TDM from AY-Riders. http://ay-riders.speccy.cz/006.htm
; Thanks to Velesoft for the music.
;
; 
                opt             sna=StartAddress:StackStart                             ; save SNA,Set PC = run point in SNA file and TOP of stack
                opt             Z80                                                     ; Set z80 mode
                opt             ZXNEXT
                
                org     $6000      
StackEnd:
                ds      127
StackStart:     db      0

                org     $7000
                call    65000           ; init player
StartAddress:
                halt
@wait:                
                ld      bc,$243B        ; wait for scanline  $50
                ld      a,31
                out     (c),a
                ld      bc,$253B 
                in      a,(c)
                cp      $50
                jr      nz,@wait

                ld	a,3
                out     ($fe),a
                call    65003           ; call player
                xor     a
                out     ($fe),a         ; black border again

                jp      StartAddress


                ; its actually a TAP file, but I don't support them so, make it an SNA
                org     $8000-312
                incbin  "3xay.dat"              	; DAT is cropped by a few bytes
                //incbin  "3xay.TAP"              	; TAP overruns into 128K 
                //savebin "3xay.dat",$8000-312,33079



