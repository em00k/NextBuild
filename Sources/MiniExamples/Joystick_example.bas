#include <nextlib.bas>
#include <keys.bas>

paper 7: border 6 : bright 0: ink 0 : cls 

dim x as integer
dim y as integer
dim joy as ubyte

NextReg($7,$1)

NextReg($15,%00000001)  	  		
ShowLayer2(1)

'We load 1 sprite image from @Sprites, where they are defined.
InitSprites(1,@Sprites)


x=152
y=128
vel=3

do
	WaitRetrace(1)
	joy =IN(31)

	if MultiKeys(KEYQ) or joy=8
		y=y-vel
	else
		if MultiKeys(KEYA) or joy=4
			y=y+vel
		end if
	end if
		
	if MultiKeys(KEYO) or joy=2
		x=x-vel
	else
		if MultiKeys(KEYP) or joy=1
			x=x+vel
		end if
	end if

	'The user can move the sprite diagonally with only up, down , left and right keys defined
	'but that doesn't also work for joystick input. The ZX Next uses 8 direction joysticks and so you
	'have to scan for the diagonal inputs when required.

	'Joystick is moved down and right'
	if joy=5
	   x=x+vel
	   y=y+vel
	end if

	'Joystick is moved down and left'
	if joy=6
	   x=x-vel
	   y=y+vel
	end if

	'Joystick is moved up and right'
	if joy=9
	   x=x+vel
	   y=y-vel
	end if

	'Joystick is moved up and left'
	if joy=10
	   x=x-vel
	   y=y-vel
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
