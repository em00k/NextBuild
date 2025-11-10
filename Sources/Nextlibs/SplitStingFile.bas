#include <nextlib.bas>

declare function SplitString(s$ as string,split$ as string,index as ubyte) as string
declare function PeekString(byval Memory as uinteger) as string 
declare Function Trim(s$ as STRING,trimstr$ as string) as string 
dim nlength as ubyte
dim tcar as ubyte 
dim outtext as string 
dim tindex,alltext,tcount,peekstringcount,Memory as uinteger
dim nbrsplits as ubyte 
dim text$ as string ="              "
'LoadSD("list.txt",$a000,1024,0)

do
cls 
text$=PeekString($a000)
'test$="////HELLO,GOODBYE,WHAT,DO,YOU,WANT,END////"
'Print at 0,0;"Original String : "
'Print test$
'Print at 4,0;"Trimmed / : "
'trimmed$=Trim(test$,"/")
'Print trimmed$
text2$=text$
'pause 0 
print text2$
'pause 0 
cls 
Print at 0,0;"Split by , : ",
nbrsplits=1
DO 
	splitted$=SplitString(text2$,chr$ 13,nbrsplits)
	outtext$=splitted$
		'print splitted$
'		type$=SplitString(splitted$,".",2)
		nbrsplits=nbrsplits+1
		if outtext$(0)=chr$ $0a
			outtext$=outtext$ (1 to )
 	  endif 
	'print @splitted$
	'BBREAK 
	'type$=SplitString(tx$,".",2)
	print outtext$
	'x=x+1
'	pause 0 
loop until nbrsplits=12
nbrsplits=1
loop 

function PeekString(Memory as uinteger) as string 
	peekstringcount=0
	do  
		tcar=peek(Memory+peekstringcount)
		tcar=tcar BAND %01111111
		if tcar<>$0a or tcar<>$0d
			tempcar$=tempcar$+chr$(tcar)
		endif 
		peekstringcount=peekstringcount+1
	loop until peek(Memory+peekstringcount)=255 or peek(Memory+peekstringcount)=0 
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
	totlen=len(s$) : spos = 0 :  tcount=0 : tindex = 0 : outstring$=""
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
 
asm 
	org $a000
	incbin "list.txt"
end asm  