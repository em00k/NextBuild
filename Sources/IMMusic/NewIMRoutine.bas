'!vb
'!sna "h:\fx.sna" -a


#include <nextlib.bas>

NextReg($7,2)							' 14mhz lets not muck around 
NextReg($8,%11111010)			' All the features and no contenion 
'NextReg(08,%10001010)
'NextReg($43,$1)						' ULANext control reg
'NextReg($42,15)						' ULANext number of inks : 255 127 63 41 15 7 
NextReg($14,$0)  					' black global transparency value 
NextReg($40,$b)    				' $40 Palette Index Register  I assume that colours 0-7 ink 8-15 bright ink 16+ paper in ULA mode
NextReg($41,$1)  					' value of index position 

paper 0: ink 7 : border 1 : cls 	

'CLS256(0)
 
SFXInit(@gamesfx)										' init the sfx with memory of sfx bank

InitVT2(@vt2,4)											' sets up the vt2 player to bank x

InitCallback(@music,@musicend-@music,4,$AE00)	' 

' @music is the location of a pt3 file in memory
' @vt2 is the location of the playroutine that needs to be copied
' 4 = bank - vt2 and music will be to bank 4 
' $AE00 is the interrupt vector.
' if $AE00, then a jump to the int ROUTINE will be placed at $AEAE
' and a vector byte of $AE is stored at $AE00+1 and $AF00+1, so keep this in mind
' so bytes fron AE00 to AF01 are used
' eg: $9E00, jump will be placed at $9E9E, vector byte stored at $9E00+1 and $9F00+1

SFXCallback(1,4)										' Enables Interrupt playback of PlayFrame()
PlaySFX(0)													' send sfx 0 

do

	pause rnd*100
	s=int(rnd*32)
	PlaySFX(s)
	
LOOP 

gamesfx:
asm 	
	; this is an ay fx bank from ayFXedit by Shiru 
	incbin "game.afb"
end asm 

vt2:
asm 
vt2player:
	incbin "vt49152.bin"
end asm 

music:
asm 
	incbin "airmant.pt3"
end asm
musicend:
                