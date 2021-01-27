'#!sna "h:\starspri.sna" -a 
' Quick Sprite Example
' NextBuild (ZXB/CSpect)
' emook2018 - use keys 1 and 2 to mess with the sine wav (dirty!)

paper 0: border 1 : bright 0: ink 7 : cls 

dim mx,my,count,f as ubyte 
dim yy,xx as ubyte 
dim offset,frame,offset2 as fixed 
DIM add as fixed=1
DIM add2 as fixed=1
 
poke 23607,60					' for cspect to set the font correctly

#include <nextlib.bas>

'Initalize the sprite to sprite ram

' InitSprites(number of sprites to load,addressto upload from)

InitSprites(16,@Sprites)

' http://devnext.referata.com/wiki/Board_feature_control
asm 
	NextReg $14,$e3  					;' glbal transparency 
	NextReg $40,$18    					;' $40 Palette Index Register  I assume that colours 0-7 ink 8-15 bright ink 16+ paper etc? 	' 24 = paper bright 0 
	NextReg $41,$e3  					;' $41
	NextReg $7,$1   					;' go 7mhz 
end asm 

' Bit	Function
' 7	Enable Lores Layer
' 6-5	Reserved
' 3-4	If %00, ULA is drawn under Layer 2 and Sprites; if %01, it is drawn between them, if %10 it is drawn over both
' 2	If 1, Layer 2 is drawn over Sprites, else sprites drawn over layer 2
' 1	Enable sprites over border
' 0	Enable sprite visibility

NextReg($15,%00001001)  	

' to draw a sprite on screen
' UpdateSprite(x AS UBYTE,y AS UBYTE, spriteid AS UBYTE, pattern AS UBYTE, mflip as ubyte)

mx = 64
my = 80
id = 0 
offset=0
offset2=32

' lets do a loop and move some stuff around 

do

	for id = 11 to 21
		yy=peek(@sinpos+cast(uinteger,offset))>>2
		xx=peek(@sinpos+cast(uinteger,offset2))>>3
		UpdateSprite(mx+xx,my+yy,id,frame,0,0)
		if mx <64+16*11 : mx=mx+16 : else : mx=64 : endif 
		if offset+add<255 : offset=offset+add : else : offset=0 : endif 
		if offset2<255 : offset2=offset2+1 : else : offset2=0 : endif 
	next id 

	if frame+0.2<3 : frame=frame+0.2 : else : frame=0 : endif 

	pause 1

	if inkey="2"
		add=add+0.1
		print at 0,0;add;"  "
		'pause 10
	endif 
	if inkey="1"
		add=add-0.1
		print at 0,0;add;"  "
		'pause 10
	endif 
	
	if inkey="4"
		add2=add2+0.1
		print at 1,0;add2;"  "
		'pause 10
	endif 
	if inkey="3"
		add2=add2-1.1
		print at 0,0;add2;"  "
		'pause 10
	endif 
	count=count+1
loop

sinpos:
asm
db 64,62,60,59,57,56,54,53,51,49,48,46,45,43,42,40
db 39,37,36,35,33,32,30,29,28,27,25,24,23,22,20,19
db 18,17,16,15,14,13,12,11,10,9,8,8,7,6,6,5
db 4,4,3,3,2,2,1,1,1,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,1,1,1,2,2,2,3,3,4
db 5,5,6,7,7,8,9,10,11,11,12,13,14,15,16,18
db 19,20,21,22,23,25,26,27,28,30,31,33,34,35,37,38
db 40,41,43,44,46,47,49,50,52,53,55,56,58,60,61,63
db 64,66,67,69,71,72,74,75,77,78,80,81,83,84,86,87
db 89,90,92,93,94,96,97,99,100,101,102,104,105,106,107,108
db 109,111,112,113,114,115,116,116,117,118,119,120,120,121,122,122
db 123,124,124,125,125,125,126,126,126,127,127,127,127,127,127,127
db 127,127,127,127,127,127,127,126,126,126,125,125,124,124,123,123
db 122,121,121,120,119,119,118,117,116,115,114,113,112,111,110,109
db 108,107,105,104,103,102,100,99,98,97,95,94,92,91,90,88
db 87,85,84,82,81,79,78,76,74,73,71,70,68,67,65,64




end asm
	
sinposb:
asm
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
end asm

Sprites:
ASM 
Ball1:
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $25, $25, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $25, $9D, $BD, $25, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $25, $9D, $BD, $25, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $25, $7D, $9D, $BD, $DD, $25, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $25, $25, $25, $25, $25, $7D, $7D, $BD, $DD, $25, $25, $25, $25, $25, $E3;
	db  $25, $7A, $7A, $7A, $7A, $7A, $7D, $7D, $BD, $FD, $F9, $F5, $F5, $F1, $F1, $25;
	db  $25, $7A, $7A, $7A, $7A, $7A, $25, $7D, $BD, $25, $F5, $F1, $F1, $ED, $ED, $25;
	db  $E3, $25, $7A, $7A, $7A, $7A, $00, $7A, $ED, $25, $ED, $ED, $ED, $ED, $25, $E3;
	db  $E3, $E3, $25, $76, $77, $77, $77, $6F, $8F, $CE, $CE, $EE, $ED, $25, $E3, $E3;
	db  $E3, $E3, $E3, $25, $77, $73, $25, $6F, $8F, $00, $CE, $CE, $25, $E3, $E3, $E3;
	db  $E3, $E3, $25, $73, $73, $6F, $6F, $25, $00, $AF, $CE, $CE, $CE, $25, $E3, $E3;
	db  $E3, $E3, $25, $73, $6F, $6F, $6F, $6F, $8F, $AF, $AE, $CE, $CE, $25, $E3, $E3;
	db  $E3, $25, $73, $6F, $6F, $6F, $6F, $25, $25, $AF, $AF, $AE, $CE, $CE, $25, $E3;
	db  $E3, $25, $6F, $6F, $6F, $25, $25, $E3, $E3, $25, $25, $AE, $CE, $CE, $25, $E3;
	db  $E3, $E3, $25, $25, $25, $E3, $E3, $E3, $E3, $E3, $E3, $25, $25, $25, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;



Ball2:
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $25, $25, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $25, $ED, $ED, $25, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $25, $ED, $ED, $25, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $25, $F5, $F1, $ED, $ED, $25, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $25, $25, $25, $25, $25, $F5, $F1, $ED, $ED, $25, $25, $25, $25, $25, $E3;
	db  $25, $DD, $DD, $DD, $FD, $FD, $F9, $F5, $ED, $CE, $CE, $CE, $AE, $AF, $AF, $25;
	db  $25, $BD, $DD, $DD, $DD, $DD, $25, $F9, $ED, $25, $AE, $AF, $AF, $AF, $AF, $25;
	db  $E3, $25, $BD, $BD, $BD, $BD, $25, $BD, $8F, $25, $8F, $8F, $8F, $8F, $25, $E3;
	db  $E3, $E3, $25, $9D, $9D, $7D, $7D, $7D, $7A, $6F, $6F, $6F, $6F, $25, $E3, $E3;
	db  $E3, $E3, $E3, $25, $7D, $7D, $00, $7A, $7A, $00, $6F, $6F, $25, $E3, $E3, $E3;
	db  $E3, $E3, $25, $7D, $7D, $7D, $7A, $00, $00, $77, $73, $6F, $6F, $25, $E3, $E3;
	db  $E3, $E3, $25, $7D, $7D, $7A, $7A, $7A, $7A, $77, $77, $73, $6F, $25, $E3, $E3;
	db  $E3, $25, $7D, $7D, $7A, $7A, $7A, $25, $25, $77, $77, $73, $73, $6F, $25, $E3;
	db  $E3, $25, $7D, $7A, $7A, $25, $25, $E3, $E3, $25, $25, $77, $73, $73, $25, $E3;
	db  $E3, $E3, $25, $25, $25, $E3, $E3, $E3, $E3, $E3, $E3, $25, $25, $25, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;



Ball3:
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $25, $25, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $25, $AF, $8F, $25, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $25, $AF, $8F, $25, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $25, $AE, $AF, $8F, $6F, $25, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $25, $25, $25, $25, $25, $CE, $AF, $8F, $6F, $25, $25, $25, $25, $25, $E3;
	db  $25, $ED, $EE, $EE, $CE, $CE, $CE, $AE, $8F, $6F, $6F, $73, $77, $77, $77, $25;
	db  $25, $ED, $ED, $ED, $ED, $EE, $00, $CE, $8F, $25, $77, $77, $77, $76, $76, $25;
	db  $E3, $25, $ED, $ED, $ED, $ED, $25, $ED, $7A, $25, $7A, $7A, $7A, $7A, $25, $E3;
	db  $E3, $E3, $25, $ED, $F1, $F1, $F5, $F9, $BD, $7D, $7A, $7A, $7A, $25, $E3, $E3;
	db  $E3, $E3, $E3, $25, $F5, $F5, $25, $FD, $BD, $25, $7D, $7A, $25, $E3, $E3, $E3;
	db  $E3, $E3, $25, $F5, $F9, $F9, $FD, $25, $25, $7D, $7D, $7D, $7E, $25, $E3, $E3;
	db  $E3, $E3, $25, $F9, $F9, $FD, $FD, $DD, $BD, $9D, $7D, $7D, $7D, $25, $E3, $E3;
	db  $E3, $25, $F9, $F9, $FD, $FD, $DD, $25, $25, $9D, $7D, $7D, $7D, $7D, $25, $E3;
	db  $E3, $25, $F9, $FD, $FD, $25, $25, $E3, $E3, $25, $25, $7D, $7D, $7D, $25, $E3;
	db  $E3, $E3, $25, $25, $25, $E3, $E3, $E3, $E3, $E3, $E3, $25, $25, $25, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;



Ball4:
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $25, $25, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $25, $76, $7A, $25, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $25, $76, $7A, $25, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $25, $77, $77, $7A, $7A, $25, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $25, $25, $25, $25, $25, $73, $77, $7A, $7A, $25, $25, $25, $25, $25, $E3;
	db  $25, $6F, $6F, $6F, $6F, $6F, $6F, $77, $7A, $7A, $7D, $7D, $7D, $7D, $7D, $25;
	db  $25, $8F, $6F, $6F, $6F, $6F, $25, $6F, $7A, $00, $7D, $7D, $9D, $9D, $9D, $25;
	db  $E3, $25, $8F, $8F, $8F, $8F, $00, $8F, $BD, $25, $BD, $BD, $BD, $BD, $25, $E3;
	db  $E3, $E3, $25, $AF, $AF, $AF, $AE, $CE, $ED, $F9, $FD, $DD, $DD, $25, $E3, $E3;
	db  $E3, $E3, $E3, $25, $AE, $CE, $00, $CE, $ED, $25, $F9, $FD, $25, $E3, $E3, $E3;
	db  $E3, $E3, $25, $AE, $CE, $CE, $CE, $00, $25, $F1, $F5, $F9, $FD, $25, $E3, $E3;
	db  $E3, $E3, $25, $CE, $CE, $CE, $CE, $ED, $ED, $F1, $F5, $F9, $F9, $25, $E3, $E3;
	db  $E3, $25, $CE, $CE, $CE, $CE, $EE, $25, $25, $F1, $F1, $F5, $F9, $F9, $25, $E3;
	db  $E3, $25, $CE, $CE, $CE, $25, $25, $E3, $E3, $25, $25, $F5, $F9, $F9, $25, $E3;
	db  $E3, $E3, $25, $25, $25, $E3, $E3, $E3, $E3, $E3, $E3, $25, $25, $25, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
sprexit:
end asm        