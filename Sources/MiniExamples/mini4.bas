#include <nextlib.bas>
#include <keys.bas>

paper 7: border 6 : bright 0: ink 0 : cls 

dim x as integer
dim y as integer


NextReg($7,$1)

NextReg($15,%00000001)  	  		
ShowLayer2(1)

'============= tiles
LoadSD("tiles.til",$c000,512,0)
'TileMap(address,blkoff,numberoftiles,x,y,width,mapwidth)
TileMap($c000,0,2,0,0,16,2)


'Cargamos en memoria 1 imagen de sprite desde @Sprites, donde están definidos
InitSprites(1,@Sprites)

LoadBMP("spiral.bmp")
NextReg($15,%00000001)  	  		
ShowLayer2(1)

x=152
y=128
vel=3

for f=0 to 1
	for c=0 to 15
		DoTile(c,f,0)
		DoTile(c,f+10,0)
	next
next


do
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
                