#include <nextlib.bas>


dim xr,xy,vv,xx,yy,k,car,st,subcar,cc,cof,tma,paloff,palcols,prg,pcount as ubyte 

paloff=0 : pcount = 0

bord=3
pape=5

'NextRegA($40,paloff)	
	borderindex=peek(@Palette+2+(cast(uinteger,bord)*4)+pcount)
	paperindex=peek(@Palette+2+(cast(uinteger,pape)*4)+pcount)
	
	Print paperindex
	
for paltot=0 to 7

	';Print @Palette+cast(uinteger,borderindex+pcount);" ";peek(@Palette+cast(uinteger,borderindex+pcount))
	';Print @Palette+cast(uinteger,paperindex+pcount);" ";peek(@Palette+cast(uinteger,paperindex+pcount))
	Print borderindex;
	print " 0"
	'for palcols=2 to 3 
		
		prg=peek(@Palette+cast(uinteger,palcols+pcount)+2)
		prg2=peek(@Palette+cast(uinteger,palcols+pcount)+3)
		print @Palette+cast(uinteger,palcols+pcount);" ";prg;" ";prg2
	'next 
	pcount=pcount+4
	paloff=paloff+16
	print 
	PAUSE 0
	'NextRegA($40,paloff)	
next 

DO  
PAUSE 0 
LOOP 

Palette:
asm 
	db 0,0,0,0
	db 0,0,255,1
	db 0,0,137,0
	db 0,0,150,0
	db 0,0,138,0
	db 0,0,117,0
	db 0,0,74,0
	db 0,0,217,0
	db 0,0,141,0
	db 0,0,104,0
	db 0,0,177,0
	db 0,0,109,0
	db 0,0,146,0
	db 0,0,186,0
	db 0,0,143,1
	db 0,0,182,1
end asm    