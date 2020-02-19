; assume this is the proper dir
OpenConsole()
Global fullpath$=ProgramParameter(0)
Global startaddress$=ProgramParameter(1)
;'fullpath$="Z:\GoogleDrive\speccy\boriel\codes\nextlibs\dmatest6.bas"

Debug startaddress$
path$=GetPathPart(fullpath$)
file$=GetFilePart(fullpath$)
Global verb.b=0

PrintN(fullpath$)
PrintN(path$)
PrintN(file$)
Declare makeplus3(target$,file$,type)

Procedure ReplaceLine(iFileID, sFileName.s, iRepLineNum.i, sReplacement.s, iMode.i)
  ;-------------------------------------------------------------
  iReturnVal = #False
  
  Size = FileSize(sFileName)
  
  If Size > 0
    ; replace text in file
    If ReadFile(iFileID,sFileName)
      *Buffer = AllocateMemory(Size)
      If *Buffer
        
        If ReadData(iFileID, *Buffer, Size) = Size
          CloseFile(iFileID)
          
          CreateFile(iFileID, sFileName)
          
          i = 1 : n = 0
          While i < iRepLineNum
            CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
              If PeekA(*Buffer + n) = $0D : i + 1 : EndIf
            CompilerElse
              If PeekA(*Buffer + n) = $0A : i + 1 : EndIf
            CompilerEndIf
            n + 1
          Wend
          ;Debug PeekS(*Buffer + n, 100)
          
          WriteData(iFileID, *Buffer, n)
          WriteStringN(iFileID, sReplacement, iMode)
          
          i = n
          CompilerIf #PB_Compiler_OS = #PB_OS_MacOS
            While PeekA(*Buffer + i) <> $0D
            CompilerElse
              While PeekA(*Buffer + i) <> $0A
              CompilerEndIf
              i + 1
            Wend
            i + 1
            ;Debug PeekS(*Buffer + i, 100)
            
            WriteData(iFileID, *Buffer + i, Size - i)         
            
            iReturnVal = #True
            
          EndIf
          
          FreeMemory(*Buffer)
          
        EndIf
        CloseFile(iFileID)
      EndIf
    EndIf
    
    ProcedureReturn(iReturnVal)
    
  EndProcedure
  
  
  If ReadFile(0,path$+file$)                            ; open file 
    While Not Eof(0)
      ; FoundLine+1
      line$=LCase(ReadString(0))      ; read line from text file 
      
      If FindString(line$,"'!v")  
          verb=1
      EndIf
      
      
      If FindString(line$,"'!outfile")                         ; did we find this?
        outfile$=Trim(StringField(line$,2," "),#DQUOTE$)
        
        PrintN("Outfile = "+outfile$+" "+Str(FoundLine))     ; Yes, now get outfile  
        PrintN("Copying temp.bin to "+path$+outfile$)
        If CopyFile(path$+"temp.bin",path$+outfile$)
          PrintN("Success")
        Else
          PrintN("Fail")
        EndIf
        
      EndIf
      If FindString(line$,"'!bin")                  ; did we find this?
        target$=Trim(StringField(line$,2," "),#DQUOTE$)
        PrintN("Bin = "+target$+" "+Str(FoundLine)  )   ; Yes, now get outfile   
        
        PrintN("Copying temp.bin to "+target$)
        If CopyFile(path$+"temp.bin",target$)
      ;  If CopyFile(path$+"temp.bin","h:\temp.bin")
          If verb=1
            MessageRequester("Copied",target$)
          EndIf
          
          If FindString(line$,"-a")  
          ;tpath$=Left(GetPathPart(target$),Len(GetPathPart(target$))-3)
          ;tpath$="c:\"+tpath$
          file$=GetFilePart(LCase(target$))
            
          tpath$=GetPathPart(target$)
          
          makeplus3(tpath$,file$,1)
        EndIf 
        
          PrintN("Success")
        Else
          PrintN("Fail")
        EndIf
        
      EndIf  
      
      If FindString(line$,"'!sna")                  ; did we find this?
        target$=Trim(StringField(line$,2," "),#DQUOTE$)
        PrintN("Target = "+target$+" "+Str(FoundLine)  )   ; Yes, now get outfile   
        
        PrintN("Copying compiled.sna to "+target$)
        If CopyFile(path$+"compiled.sna",target$)
          If verb=1
          ;  MessageRequester("Copied",path$+"compiled.sna to "+target$)
          EndIf
          
          If FindString(line$,"-a")  
;           ndrive$=Left(LCase(ProgramParameter(0)),2)
;           npath$=Mid(LCase(ProgramParameter(0)),4)
;           If Right(npath$,1)="\"
;           npath$=Left(npath$,Len(npath$)-1)
;           EndIf   
            file$=GetFilePart(LCase(target$))
            
            tpath$=GetPathPart(target$)

         ; tpath$="c:\"+tpath$
          Debug tpath$
          Debug target$
          makeplus3(tpath$,file$,0)
        EndIf 
        
          PrintN("Success")
        Else
          PrintN("Fail")
        EndIf
        
      EndIf 
      
      If FindString(line$,"'!exec")                  ; did we find this?
        
        exec$=StringField(line$,2,#DQUOTE$)
        PrintN("exec = "+exec$+" "+Str(FoundLine) )    ; Yes, now get outfile 
        target$=Trim(StringField(line$,2," "),#DQUOTE$)
        If verb=1
          MessageRequester("exec =","Running "+exec$)
        EndIf
        If RunProgram("cmd.exe","/c "+exec$,path$)
        Else
          MessageRequester("exec =","failed!!")
        EndIf 
        
      EndIf
      If FindString(line$,"'!noemu")                  ; did we find this?
        noemu=10
        PrintN("noemu = 1 "+Str(FoundLine) )    ; Yes, now get outfile 
                 
      EndIf
      FoundLine+1 
    Wend
    CloseFile(0)
    
    ;     If ReplaceLine(0,path$+conf$,a,"CompilerZXB = "+compiler$, #PB_Ascii)
    ;       Debug "CompilerZXB = Line replaced with "+compiler$+" "+Str(c)
    ;     EndIf 
    ;     If ReplaceLine(0,path$+conf$,b,"LastDir = "+path$+"Sources\", #PB_Ascii)
    ;       Debug "LastDir = Line replaced with "+path$+"Sources\"
    ;     EndIf 
  Else
    PrintN("Could not open "+path$+conf$)
    
  EndIf 
  

  End noemu 
  
  ;   If CreateFile(0,"Scripts\Path.bat",#PB_Ascii)
  ;     If WriteString(0,"echo "+path$)
  ;       Debug "path.bat written"
  ;     EndIf 
  ;     CloseFile(0)
  ;     RunProgram(path$+"\BorIDE\BorIDE_previewR5_0A.exe","",path$+"\BorIDE\")
  ;   Else
  ;     Debug "Could not open scripts\path.bat"
  ;   EndIf 
  ;   
  ;   
  Procedure makeplus3(target$,file$,type)
    
    *memory=AllocateMemory(512)
    stadd=Val(startaddress$) : newaddress$=Str(stadd-1)
    hb=Int(stadd/256)
    lb=stadd-(hb*256)
    If type=1
    PokeS(?Line10+5,newaddress$,-1,#PB_Ascii|#PB_String_NoZero )   ; clear 
    PokeB(?Line10+13,lb)
    PokeB(?Line10+14,hb)
    PokeS(?BinRun+1,startaddress$,5,#PB_Ascii|#PB_String_NoZero ) ; load "" code 
    PokeB(?BinRun+9,lb)
    PokeB(?BinRun+10,hb)
    PokeS(?BinRun+19,startaddress$,5,#PB_Ascii|#PB_String_NoZero )  ; run usr xxxxx
    PokeB(?BinRun+27,lb)
    PokeB(?BinRun+28,hb)
    EndIf
    CopyMemory(?Header,*memory,128)
    CopyMemory(?Line10,*memory+128,?BinRun-?Line10)
    If Len(target$)<4
      PokeB(*memory+128+17,$ef)
      filename$="c:\"+file$
    Else 
      
      ;clear line 
     
      If type=1
        PokeB(*memory+128+17,$a0) ;cd
        filename$="c"+Mid(target$,2)+#DQUOTE$+":"+Chr($ef)+#DQUOTE$+file$
        EndIf
    EndIf   
    
    If type=1    ; bin save -a 
      poke$=filename$+#DQUOTE$
      binlen=?BinRunEnd-?BinRun
      CopyMemory(?BinRun,*memory+128+19+Len(poke$),binlen)
      linelen=Len(poke$)+19+binlen
      linelen2=Len(poke$)+2+26
      PokeS(*memory+128+19,poke$,linelen,#PB_Ascii  |#PB_String_NoZero)     ; 
    Else
      CopyMemory(?SNA,*memory+128,?SNAEND-?SNA)
      poke$="c"+Mid(target$,2)+Chr($22)+Chr($3a)+Chr($a3)+#DQUOTE$+file$+#DQUOTE$+Chr($0d)
      linelen=Len(poke$)+6
      linelen2=Len(poke$)+6
      PokeS(*memory+128+6,poke$,linelen,#PB_Ascii  |#PB_String_NoZero)     ; 
    EndIf 

;     linelen=Len(poke$)+19+binlen
;     linelen2=Len(poke$)+2+26
    
    PokeB(*memory+11,128+linelen)
    PokeB(*memory+16,linelen)
    PokeB(*memory+20,linelen)
    PokeB(*memory+130,linelen2)
    

        
    For x=0 To 126                                ; make flag byte 
      a + Mod (PeekB(*memory+x),256)
    Next 
    Debug Hex(a)
    PokeB(*memory+127,a)
    
    ShowMemoryViewer(*memory,128+linelen)
    
    If OpenFile(1,"autoexec.bas")
      WriteData(1,*memory,128+linelen)
      CloseFile(1)
      CopyFile("autoexec.bas","h:\nextzxos\autoexec.bas")
      If verb=1
        MessageRequester("Autolaunch","h:\nextzxos\autoexec.bas")
      EndIf
      
    EndIf
    FreeMemory(*memory)

    
    DataSection
      Header:
        Data.b	080,076,085,083,051,068,079,083
        Data.b	026,001,000,148,000,000,000,000
        Data.b	020,000,000,000,020,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,000
        Data.b	000,000,000,000,000,000,000,052
        SNA:
        Data.b $00,$0A,$0F,$00,$A0,$22
        SNAEND:
        SNA2:
        Data.b $00,$0A,$0F,$00,$A0,$22
        SNAEND2:
        
      Line10:
    ;  Data.b $00,$0A,$0F,$00,$A3,$22,$63,$3A,$5C,$74,$65,$73,$74,$2E,$73,$6E,$61,$22,$0D
    ;  Data.b $00,$0A,$30,$00,$FD,$32,$34,$35,$37,$35,$0E,$00,$00,$FF,$5F,$00,$3A,$EF,$22
       Data.b $00,$0A,$30,$00,$FD,$32,$34,$35,$37,$35,$0E,$00,$00,$FF,$5F,$00,$3A,$EF,$22
      BinRun:
      Data.b $AF,$32,$34,$35,$37,$36,$0E,$00,$00,$00,$60,$00,$0D,$00,$14,$0E,$00,$F9,$C0,$32,$34,$35,$37,$36,$0E,$00,$00,$00,$60,$00,$0D
      BinRunEnd:
      ; EF= LOAD
      ; A3=SPECTRUM
      ; AF=CODE 
    EndDataSection 
  EndProcedure
; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 167
; FirstLine = 87
; Folding = 5
; Markers = 117,240
; EnableXP
; Executable = postcompile.exe
; CommandLine = C:\NextBuildv5\Sources\spinngtiles\petscii2.bas 32768