#include <stRING.bas>
#include <asc.bas>
' fish sheep cat wheat
paper 0: ink 7: border 3 : cls
dim seg,slice,l,timer,char,abyte,bbyte,achar,bchar,mask as ubyte
dim textpos,segment,i as ubyte
dim col as ubyte
dim m$,msg$ as string
slice=0 : i = 1
textpos=0

buffer = 49152

sub printchar16(slice)
	

		forcol:
		
		for col = 0 to 7
			
			addr = @font+(cast (uinteger, char)<<5)+cast (uinteger, col)+(cast (uinteger, segment)<<4)
			
			abyte = peek(addr) << slice  band %10000000
			bbyte = peek(addr+8) << slice BAND %10000000
		
			coladd = cast(uinteger, col) << 5
			
			if abyte > 0 then 
			' print at col,31;paper 0;" "
			 poke buffer+coladd,0
			else
			
			poke buffer+coladd,i*8
			
			 'print at col,31;paper i;" "
			end if 
			coladd = cast(uinteger, col+7) << 5
			
			if bbyte > 0 then 
			 poke buffer+coladd,0
			' print at col+7,31;paper 0;" "
			else
			poke buffer+coladd,i << 4
			'print at col+7,31;paper i;" "
			end if
			
			'i = i + 1
			'if i>7
			'	i=1
			'end if
			
		next 

						
			asm 
			;di
			halt
			ld b,16
			ld de,49152
			ld hl,49153
			attrleft:
			;push bc
			;ld bc,31
			ld a,(de)
			;ldir
			ldi  
			ldi 			
			ldi 			
			ldi 			
			ldi 			
			ldi 			
			ldi 			
			ldi 			
			ldi 
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi
			ldi 
			ld (de),a
			inc de
			inc hl
			djnz attrleft
			ld hl,49152
			ld de,22528
			ld bc,512
			ldir
			
		end asm

	return

	
	
end sub

sub updatescroller16()

	printchar16(slice)

	slice=slice+1
		
	if slice>7
		slice=0
		segment=segment+1
		
		if segment>1
			 
			ca$=mid$(msg$,textpos,1)
			
			char = asc(ucase(msg$),textpos) : char=char-65
			if char<0 then
				char = 28
			end if 
			if ca$=" " THEN 
				char = 28
			end if 
			textpos=textpos+1
			if textpos>l-1
				textpos=1
			end if
			segment=0
		end if 
		
	end if
	return 
end sub 

sub setscroller16(m$)

	l = len(m$)
	msg$ = m$ 
	textpos=1
	slice=0
	ca$=mid$(msg$,textpos,1)
	char = asc(ucase(msg$),textpos) : char=char-65
	if char<0 then
		char =28
	end if 
	char = 28 
	
end sub 

setscroller16(" why hello there    this is a quick test of a large scrolly             ")

do

mainloop:

	'if usr @waitframec=0
		updatescroller16()
  'end if 

loop   
end


End 

font:
asm

	incbin "font2.bin"
end asm 

waitframec:

	asm 
	wait:		ld bc,0
				 ld hl,pbuff        
				 ld a,(23672)        
				 sub (hl)            
				 cp 1                
				 jr nc,wait0         

				 
	 ww:  ld c,55
	 xor a
				 djnz ww
				 
				 
				 ld bc,1

				 ;jp waitend
				 ;db $ED,$5F
				 ;cp 2
			  ;jr nc,wait0
				 ret 
				 
	wait0:
				 ld a,(23672)        
				 ld (hl),a           
 	  ww2:  ld c,55
				 xor a
				 djnz ww2

				 ld bc,0
				 ret
				 ;jp waitend
	pbuff:
				defb 0
	waitend:
			;	ret 
	end asm 


			               