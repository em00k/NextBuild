#include <nextlib.bas>
' testing sting splitting

declare function SplitString(s$ as string,split$ as string,index as ubyte) as string
declare function PeekString(Memory as uinteger) as string 
declare Function Trim(s$ as STRING,trimstr$ as string) as string 

do
cls 
LoadSD("list.txt",$a000,1024,0)
text$=PeekString($a000)
test$="////HELLO,GOODBYE,WHAT,DO,YOU,WANT,END////"
Print at 0,0;"Original String : "
Print test$
Print at 4,0;"Trimmed / : "
trimmed$=Trim(test$,"/")
Print trimmed$

'pause 0 
'print text$
Print at 7,0;"Split by , : ",
x=0
DO 
	tx$=SplitString(trimmed$,",",x)
	'type$=SplitString(tx$,".",2)
	print tx$
	x=x+1
'	pause 0 
loop until tx$="END"

loop 

function PeekString(Memory as uinteger) as string 

	dim tcar,peekstringcount as ubyte 
	do  
		tcar=peek(Memory+peekstringcount)
		tcar=tcar BAND %01111111
		if tcar<>$0a or tcar<>$0d
			tempcar$=tempcar$+chr$(tcar)
		endif 
		peekstringcount=peekstringcount+1
	loop until peek(Memory+peekstringcount)=255 or peek(Memory+peekstringcount)=0  'or peek(Memory+peekstringcount)=13
  return tempcar$

end function

Function Trim(s$ as STRING,trimstr$ as string) as string 
	totlen=len(s$) : spos = 0 :  tcount=0 : outstring$="" : alltext=0 : epos = 0 : nlenght=0
		do
			curcar$=s$(alltext)
			if curcar$=trimstr$ : spos=spos+1 : else : tcount=1 : endif
			alltext=alltext+1
		loop until tcount=1
		epos=cast(ubyte,totlen-1)-spos : tcount=0 : s$=s$(spos to )
		do 
			curcar$=s$(nlength)
			if curcar$=trimstr$ : epos=epos-1 : else : tcount=1 : endif
		loop until tcount=1
		epos=epos-spos : s$=s$( to epos)
	return s$
end function 

Function SplitString(s$ as string,split$ as string,index as ubyte) as string
	totlen=len(s$) : spos = 0 :  tcount=0 : outstring$=""
	s$=s$+split$
	for alltext=0 to totlen 
		curcar$=s$(alltext)
		if curcar$=split$
				if tindex+1=index 
					if spos>0
						tcount=spos+1
					endif 
					do 
					 outstring$=outstring$+s$(tcount)
					 tcount=tcount+1 : 
					loop until s$(tcount)=split$ 
					alltext=totlen
			else 
				spos=alltext 
				tindex=tindex+1
			endif 
		endif 	
	next alltext
	return outstring$
end function
    