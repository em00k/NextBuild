#include <nextlib.bas>

' #DEFINE SWAPNIB\
' 		DB $ED,$23\
' 		
' #DEFINE MUL_DE\
' 		DB $ED,$30\
		
#DEFINE NextRegEx(reg,val)\
		ASM\
		DB $ED,$91\
		DB reg,val\
		end asm \

#define slot0 $50
#define slot1 $51
#define slot2 $52
#define slot3 $53
#define slot4 $64
#define slot5 $65
#define slot6 $66
#define slot7 $67
NextRegEx($7,$2)  					' go 7mhz 
dim b,ofx  as ubyte 
' REM Small example :
	' 
' REM Load tile data to 49152
NextRegEx($56,$35)					' slect bank $26 
LoadSD("font2.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$36)					' slect bank $26 
LoadSD("font3.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$37)					' slect bank $26 
LoadSD("font4.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$38)					' slect bank $26 
LoadSD("font5.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$39)					' slect bank $26 
LoadSD("font6.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$3a)					' slect bank $26 
LoadSD("font7.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$3b)					' slect bank $26 
LoadSD("font8.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$3c)					' slect bank $26 
LoadSD("font9.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$3d)					' slect bank $26 
LoadSD("font10.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$3e)					' slect bank $26 
LoadSD("font11.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$3f)					' slect bank $26 
LoadSD("font12.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$40)					' slect bank $26 
LoadSD("font13.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$41)					' slect bank $26 
LoadSD("font14.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$42)					' slect bank $26 
LoadSD("font15.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$43)					' slect bank $26 
LoadSD("font16.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$44)					' slect bank $26 
LoadSD("font17.spr",49152,4096,0)  ' load font data to bank $25 
NextRegEx($56,$45)					' slect bank $26 
LoadSD("font18.spr",49152,4096,0)  ' load font data to bank $25 

NextRegEx($14,$e3)  				' glbal transparency 
NextRegEx($40,$18)    			' $40 Palette Index Register  I assume that colours 0-7 ink 8-15 bright ink 16+ paper etc? 	' 24 = paper bright 0 
NextRegEx($41,$e3)  				'$41

NextRegEx($15,%00010001)  	' enable layer 2 and set U SPRITE LAYER2 order 
' back to first font 
NextRegEx($56,$24)
NextRegEx($7,2)

' init
' note BRIGHT 1 PAPER 0 is transparent 
paper 0: border 0 : bright 1: ink 7 : cls 
print at 19,31;bright 0;" "
'InitSprites()  					' send sprite data starting 49152 to SPRAM
CLS256(0)
' Main 
dim d as ubyte 
d=1
pause 20

setcopper(reg)
for t=0 to 16
	b=t 
	NextRegF($56,$35+b)
	TextFont(0,t+4,str(b)+" WKAKAAKAKAK!",0,0)
next 
NextRegEx($56,$37)
text$=" WELL THIS IS NICE, A COOL TEXT SCROLLER IN GLORIOUS COLOUR. ABOUT TIME TOO    REPEATSVILLE     "
offset=0


do

 

	for p=0 to len(text$)

		tile=code text(p)
		
		if tile = 32 
			tile = 57		
		elseif tile=33
 		 tile=0
		else
			tile = tile - 34
		endif 

		if offset=32
		 offset=0
		endif 
		
		DoTile8(abs(offset+31),19,tile)
		offset=offset+1

' 			 for c=0 to 7 
' 							NextRegEx($61,0)	' set index 0
' 							NextRegEx($62,0)	' set index 0
' 							NextRegEx($60,$80)
' 							NextRegEx($60,$98)		' wait for $16
' 							NextRegEx($60,$16)		' reg $16 layer 2 x offset 
' 							NextRegF($60,ofx)		' set to 0
' 
' 							NextRegEx($60,$af)		' reg $16 layer 2 x offset 
' 							NextRegEx($60,$16)		' reg $16 layer 2 x offset 
' 							NextRegEx($60,$0)		' reg $16 layer 2 x offset 
' 							NextRegEx($60,$81)		
' 							NextRegEx($60,$ff)									
' 							NextRegEx($61,%10000000)
' 							NextRegEx($62,%11000000)
' 							ofx=ofx+1
' 							pause 1
' 			 next 
		t=t+d
		v=peek(@sinedata+t)
		
		if t>50
			d=-1
		else 
			d=1
		endif 

	next 
	WaitRetrace(1)
	
loop 


sub setcopper(reg)

							NextRegEx($61,0)	' set index 0
							NextRegEx($62,0)	' set index 0
							NextRegEx($60,$80)
							NextRegEx($60,$98)		' wait for $16
							NextRegEx($60,$16)		' reg $16 layer 2 x offset 
							NextRegF($60,0)		' set to 0

							NextRegEx($60,$af)		' reg $16 layer 2 x offset 
							NextRegEx($60,$16)		' reg $16 layer 2 x offset 
							NextRegEx($60,$0)		' reg $16 layer 2 x offset 
							NextRegEx($60,$81)		
							NextRegEx($60,$ff)									
							NextRegEx($61,%00000000)
							NextRegEx($62,%11000000)
end sub


Function NextRegF(byVal reg as ubyte, byval value as ubyte)
	
	'NextRegEx(._reg,._value)
 	asm 
 		ld e,(IX+7)
 		ld a,(IX+5)
 		ld	bc,$243B
 		out	(c),a
 		ld a,e
 		ld	bc,$253B
 		out	(c),a
 	end asm
end function

 

Sub TextFont(x,y,m$,delay,wait)

	for pos = 0 to len(m$)-1
		tile=code m$(pos)
		if tile = 32 
			tile = 57
		elseif tile=33
 		 tile=0
		else
			tile = tile - 34
		endif 
		
		if x+pos>255
			x=0 : y=y+1
		endif 
		DoTile8(x+pos,y,tile)
		if delay>0
		 pause delay
		endif 
	next 
	
	if wait>0
		pause wait 
	endif 
	
end sub 

Sub BigFont(x,y,m$,delay,wait)

	for pos = 0 to len(m$)-1
	
'		print code m$(pos)-36
		tile=code m$(pos)
		if tile = 32 
			tile = 55
		else
			tile = tile - 36
		endif 
		
		if x+pos>255
			x=0 : y=y+1
		endif 
		'DoTile(x+pos,y,tile)
		if delay>0
		 pause delay
		endif 
	next 
	
	if wait>0
		pause wait 
	endif 
	
end sub 


sinedata:
ASM 
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,1,1,1,1,1,1,1,1,1,2,2
db 2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4
db 4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7
db 8,8,8,8,8,9,9,9,9,9,9,10,10,10,10,10
db 11,11,11,11,11,11,12,12,12,12,12,12,13,13,13,13
db 13,13,13,14,14,14,14,14,14,14,14,15,15,15,15,15
db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
db 15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
db 15,15,15,15,15,14,14,14,14,14,14,14,14,13,13,13
db 13,13,13,13,12,12,12,12,12,12,12,11,11,11,11,11
db 10,10,10,10,10,9,9,9,9,9,9,8,8,8,8,8
db 7,7,7,7,7,6,6,6,6,6,5,5,5,5,5,4
db 4,4,4,4,4,3,3,3,3,3,3,2,2,2,2,2
db 2,2,1,1,1,1,1,1,1,1,1,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
END ASM        