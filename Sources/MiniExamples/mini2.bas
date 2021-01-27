#include <nextlib.bas>
#include <keys.bas>

paper 7: border 6 : bright 0: ink 0 : cls 

dim x as integer
dim y as integer


NextReg($7,$1)

NextReg($15,%00000001)  	  		
ShowLayer2(1)

'Cargamos en memoria 1 imagen de sprite desde @Sprites, donde están definidos
InitSprites(1,@Sprites)


x=152
y=128
vel=3

do
	WaitRetrace(1)

	if MultiKeys(KEYQ)
		y=y-vel
	else
		if MultiKeys(KEYA)
			y=y+vel
		end if
	end if
		
	if MultiKeys(KEYO)
		x=x-vel
	else
		if MultiKeys(KEYP) 
			x=x+vel
		end if
	end if

	UpdateSprite(x,y,0,0,0,0)



loop

end

Sprites:
ASM 

; lateral
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
               