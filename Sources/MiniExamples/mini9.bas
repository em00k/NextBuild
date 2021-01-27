#include <nextlib.bas>
#include <keys.bas>

paper 7: border 6 : bright 0: ink 0 : cls 

dim x1 as integer
dim y1 as integer
dim x2 as integer
dim y2 as integer
dim ancho1 as integer
dim ancho2 as integer
dim alto1 as integer
dim alto2 as integer


NextReg($7,$1)

NextReg($15,%00000001)  	  		
ShowLayer2(1)

'Cargamos en memoria 1 imagen de sprite desde @Sprites, donde están definidos
InitSprites(1,@Sprites)

x1=152
y1=128
ancho1=16
alto1=16

x2=190
y2=128
ancho2=16
alto2=16
vel=3

do
	if MultiKeys(KEYQ)
		y1=y1-vel
	else
		if MultiKeys(KEYA)
			y1=y1+vel
		end if
	end if
		
	if MultiKeys(KEYO)
		x1=x1-vel
	else
		if MultiKeys(KEYP) 
			x1=x1+vel
		end if
	end if

	UpdateSprite(x1,y1,0,0,0,0)
	UpdateSprite(x2,y2,1,0,0,0)
	
	if (x1 < (x2 + ancho2)) and ((x1 + ancho1) > x2) and (y1 < (y2 + alto2)) and ((alto1 + y1) > y2)
		x1=32: y1=32
	endif	
	

	pause 1

loop

end

Sprites:
ASM 

Sprite1:
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $00, $E3, $E3, $E3, $E3, $E3, $E3, $00, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $00, $18, $00, $E3, $E3, $E3, $E3, $00, $E0, $00, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $00, $18, $00, $00, $00, $00, $E0, $00, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $00, $18, $18, $18, $18, $E0, $E0, $E0, $E0, $00, $E3, $E3, $E3;
	db  $E3, $E3, $00, $18, $18, $18, $18, $18, $E0, $E0, $E0, $E0, $E0, $00, $E3, $E3;
	db  $E3, $00, $18, $18, $18, $FC, $18, $18, $E0, $E0, $FC, $E0, $E0, $E0, $00, $E3;
	db  $E3, $00, $18, $00, $18, $18, $18, $18, $E0, $E0, $E0, $E0, $00, $E0, $00, $E3;
	db  $E3, $00, $18, $00, $18, $18, $18, $18, $E0, $E0, $E0, $E0, $00, $E0, $00, $E3;
	db  $E3, $00, $18, $00, $18, $00, $00, $00, $00, $00, $00, $E0, $00, $E0, $00, $E3;
	db  $E3, $E3, $00, $E3, $00, $18, $18, $00, $00, $E0, $E0, $00, $E3, $00, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $00, $00, $E3, $E3, $00, $00, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;

end asm       
              