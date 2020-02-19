' palette upload and cycling example 0.2
' NextBuild emook2018

#include <nextlib.bas>

NextReg($43,$1)						' ULANext control reg
NextReg($42,255)						' ULANext number of inks : 255 127 63 41 15 7 
NextReg($14,$0)  					' black global transparency value 
NextReg($40,$0)    				' $40 Palette Index Register  I assume that colours 0-7 ink 8-15 bright ink 16+ paper in ULA mode
NextReg($41,$0)  					' value of index position 
NextReg($15,%00001011)  
paper 0 : ink 7 : BRIGHT 0:  border 5 : cls

' PalUpload(paletter data address eg @Label,Number of colours to upload)
 PalUpload(@NewPall,64,0) ' load entire 512 bytes for 9bit 256x2 colours entries

' lets do a loop to upload the palette data from an offset to make the colours cycle a bit 
LoadBMP("geo2.bmp")

dim t as fixed 
dim frame,mx,my,yy,xx,count,f,p,madd as ubyte 
dim offset as fixed 
DIM add as fixed=1.799
c=0 : p = 0 
'inverse 1
OVER 1 

	LoadSD("nextbld.scr",16384,6912,0)

	
	for y =0 to 23 step 2
		for x=0 to 30 step 2			
			print at y,x;"  ";
			print at y+1,x;"  ";
			if c>29 : c = 0 :endif 
			poke 22528+(cast(uinteger,y)*32)+x,c
			poke 22529+(cast(uinteger,y)*32)+x,c
			poke 22528+((cast(uinteger,y+1)*32))+x,c
			poke 22529+((cast(uinteger,y+1)*32))+x,c
			c=c+1
		next x
		'c=c+3		
	next y
	ShowLayer2(1)			' ON 	
do 	
	DO 
		' do a loop with a for next loop, read the palette data and upload it from an offset

			pause 1
			
			if p>1
				if x<64 : x=x+2 : else : x=0 : endif 
				p=0
				PalUpload(@NewPall+x,128,x)
			endif 

			p=p+1			' just a simple timer to make palette upload happen every second frame			
			
			' scroll layer 2 with sin data in memory 
			
			yy=peek(@sinpos+cast(uinteger,offset))
			xx=peek(@sinposb+cast(uinteger,offset))<<1
			ScrollLayer(xx,yy)
			if offset+add<254 : offset=offset+add : else : offset=0 : endif 

	loop until ex=5							' loop for ever as ex isnt being inc'd


loop 

PAUSE 0

' This is the palette data in 9 bit format
' So DEFB LSB,MSB - the MSB will be either 0 or 1, LSB will be 0-255
' We dont use all these colours but kept so we can set all the colours

' 	DEFB	255,000,255,000,218,000,218,000
' 	DEFB	182,000,182,000,146,000,146,000
' 	DEFB	109,000,109,000,073,000,073,000
' 	DEFB	037,000,037,000,011,000,011,000
Palette:
ASM


	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	224,000,196,000,168,000,136,000
	DEFB	044,000,012,000,013,000,014,000
	DEFB	043,000,135,000,167,000,199,000
	DEFB	230,000,197,000,229,000,229,000	

	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000	
	DEFB	255,000,255,000,218,000,218,000
	DEFB	182,000,182,000,146,000,146,000
	DEFB	109,000,109,000,073,000,073,000
	DEFB	037,000,037,000,000,000,000,000

end asm 

sinpos:
	asm
db 50,48,47,46,45,43,42,41,40,39,37,36,35,34,33,31
db 30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15
db 14,13,12,12,11,10,9,9,8,7,7,6,5,5,4,4
db 3,3,2,2,2,1,1,1,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,1,1,1,1,2,2,3,3
db 3,4,4,5,6,6,7,7,8,9,10,10,11,12,13,14
db 14,15,16,17,18,19,20,21,22,23,24,25,26,27,29,30
db 31,32,33,34,36,37,38,39,40,42,43,44,45,46,48,49
db 50,51,53,54,55,56,57,59,60,61,62,63,65,66,67,68
db 69,70,72,73,74,75,76,77,78,79,80,81,82,83,84,85
db 85,86,87,88,89,89,90,91,92,92,93,93,94,95,95,96
db 96,96,97,97,98,98,98,98,99,99,99,99,99,99,99,99
db 99,99,99,99,99,99,99,99,98,98,98,97,97,97,96,96
db 95,95,94,94,93,92,92,91,90,90,89,88,87,87,86,85
db 84,83,82,81,80,79,78,77,76,75,74,73,72,71,70,69
db 68,66,65,64,63,62,60,59,58,57,56,54,53,52,51,50

	end asm
	
sinposb:
	asm
db 0,0,0,0,0,0,0,0,0,1,1,1,2,2,2,3
db 3,4,4,5,5,6,7,7,8,9,9,10,11,12,13,13
db 14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29
db 31,32,33,34,35,36,38,39,40,41,42,44,45,46,47,49
db 50,51,52,53,55,56,57,58,60,61,62,63,64,66,67,68
db 69,70,71,72,73,74,76,77,78,79,80,81,82,82,83,84
db 85,86,87,88,88,89,90,91,91,92,93,93,94,94,95,95
db 96,96,97,97,98,98,98,98,99,99,99,99,99,99,99,99
db 99,99,99,99,99,99,99,99,98,98,98,98,97,97,96,96
db 95,95,94,94,93,93,92,91,91,90,89,88,88,87,86,85
db 84,83,82,82,81,80,79,78,77,76,75,73,72,71,70,69
db 68,67,66,64,63,62,61,60,58,57,56,55,53,52,51,50
db 49,47,46,45,44,42,41,40,39,38,36,35,34,33,32,31
db 29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14
db 13,13,12,11,10,9,9,8,7,7,6,5,5,4,4,3
db 3,2,2,2,1,1,1,0,0,0,0,0,0,0,0,0

	end asm
NewPall:
asm 
	DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
		DEFB	029,000,025,000,021,000,017,000
	DEFB	013,000,009,000,004,000,004,000
	DEFB	040,000,044,000,080,000,084,000
	DEFB	120,000,124,000,124,000,124,000
end asm        