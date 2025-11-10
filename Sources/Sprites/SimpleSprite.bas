' Quick Sprite Example 2
' NextBuild (ZXB/CSpect)
' emook2018 - use keys 1 and 2 to mess with the sine wav (dirty!)
#include <nextlib.bas>

paper 0: border 0 : bright 0: ink 7 : cls 

dim frame,mx,my,yy,xx,count,f as ubyte 
dim offset as fixed 
DIM add as fixed=2.799
 
poke 23607,60					' for cspect to set the font correctly

InitSprites(1,@Sprites)

' Reg $15 Bit	Function
' 7	Enable Lores Layer
' 6-5	Reserved
' 3-4	If %00, ULA is drawn under Layer 2 and Sprites; if %01, it is drawn between them, if %10 it is drawn over both
' 2	If 1, Layer 2 is drawn over Sprites, else sprites drawn over layer 2
' 1	Enable sprites over border
' 0	Enable sprite visibility

NextReg($15,%00001001)  	' Enable sprite visibility & Sprite ULA L2 order 
ShowLayer2(1)
UpdateSprite(32,32,0,0,0,0)		' show our sprite we init'd

pause 0

Sprites:
ASM 
Ball1:
		db  $E3, $E3, $E3, $E3, $E3, $F5, $F5, $F4, $F4, $F5, $F5, $E3, $E3, $E3, $E3, $E3;
		db  $E3, $E3, $E3, $FA, $F4, $F4, $F4, $F4, $F4, $F4, $F0, $ED, $F6, $E3, $E3, $E3;
		db  $E3, $E3, $F9, $F8, $F4, $F4, $F4, $F4, $F4, $F4, $F4, $ED, $E9, $F2, $E3, $E3;
		db  $E3, $FA, $F8, $F8, $F8, $F8, $F4, $F4, $F4, $F4, $F4, $EC, $E9, $E9, $F6, $E3;
		db  $E3, $F8, $F8, $F8, $F8, $F8, $F8, $F4, $F4, $F4, $F4, $ED, $E9, $E9, $ED, $E3;
		db  $F9, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F4, $F4, $F0, $ED, $E9, $E9, $E9, $F2;
		db  $F9, $F8, $F8, $D8, $B8, $B8, $D8, $F8, $F4, $F0, $ED, $E9, $E9, $E9, $E9, $ED;
		db  $F8, $D8, $98, $78, $58, $78, $78, $B4, $F0, $ED, $E9, $E9, $E9, $E9, $E9, $CE;
		db  $D8, $98, $58, $58, $59, $58, $55, $52, $CE, $E9, $E9, $E9, $E9, $E9, $CE, $AE;
		db  $B9, $58, $59, $58, $58, $55, $37, $53, $AF, $CE, $CE, $CE, $CE, $AE, $AE, $AF;
		db  $99, $58, $58, $58, $59, $36, $33, $33, $AF, $AE, $AE, $AE, $AE, $AE, $AE, $D3;
		db  $E3, $79, $58, $58, $55, $37, $33, $37, $6F, $AE, $AE, $AE, $AE, $AE, $AE, $E3;
		db  $E3, $9A, $58, $58, $55, $37, $33, $33, $33, $8F, $AF, $AE, $AE, $AE, $D7, $E3;
		db  $E3, $E3, $99, $58, $55, $37, $33, $33, $33, $37, $53, $8F, $8F, $B3, $E3, $E3;
		db  $E3, $E3, $E3, $99, $79, $36, $33, $33, $33, $33, $33, $37, $77, $E3, $E3, $E3;
		db  $E3, $E3, $E3, $E3, $E3, $7A, $37, $33, $33, $37, $77, $E3, $E3, $E3, $E3, $E3;
end asm        