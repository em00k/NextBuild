#include <nextlib.bas>
#include <keys.bas>

paper 7: border 6 : bright 0: ink 0 : cls 

dim x as integer
dim y as integer


NextReg($7,$1)

NextReg($15,%00000001)  	  		
ShowLayer2(1)

'Cargamos en memoria 2 imaágenes de sprite desde @Sprites, donde están definidos
InitSprites(2,@Sprites)

espejox=0
espejoy=0
frameNum=0
retFrame=0

x=152
y=128
vel=3

do
	if MultiKeys(KEYQ)
		y=y-vel
		espejoy=0
	else
		if MultiKeys(KEYA)
			y=y+vel
			espejoy=4
		end if
	end if
		
	if MultiKeys(KEYO)
		x=x-vel
		espejox=8
	else
		if MultiKeys(KEYP) 
			x=x+vel
			espejox=0
		end if
	end if

	retFrame=retFrame+1
	if retFrame>4
		retFrame=0
		frameNum=frameNum+1
		if frameNum>1 then frameNum=0
	endif

	UpdateSprite(x,y,0,frameNum,espejox+espejoy,0)

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



Sprite2:
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
	db  $E3, $E3, $E3, $E3, $00, $18, $00, $E3, $E3, $00, $E0, $00, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $00, $18, $00, $E3, $E3, $00, $E0, $00, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $00, $E3, $E3, $E3, $E3, $00, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;
	db  $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3, $E3;

end asm       
               