UsePNGImageDecoder()
UsePNGImageEncoder()

OpenWindow(0,10,10,800,400,"")
CanvasGadget(1,0,10,800,400)
Structure palmap
  r.a
  g.a
  b.a
  i.a
  hb.a
  lb.a
EndStructure
Global infilename$="C:\NextBuildv5\Sources\xmas2019\data\tiles.bmp.bmp"   ; 24 bit!
Global NAME$=GetFilePart(infilename$,#PB_FileSystem_NoExtension)
Procedure ReadPaletteA()
  If ReadFile(1,"C:\NextBuildv5\Sources\xmas2019\data\tiles.pal")
    l=Lof(1)
    Dim ii$(3)
    
    Global NewList palette.palmap() 
    
    Dim rr(256)
    Dim gg(256)
    Dim bb(256)
    While Not Eof(1)
      
      ;line$=ReadString(1)
      
      AddElement(palette()) 
      
      With palette()
        bytein.b=ReadByte(1)  
        \r = bytein
        bytein=ReadByte(1)
        \g = bytein
        bytein=ReadByte(1)
        \b = bytein
        \i = ListIndex(palette())
        res2 = ((\r>>5) << 6) | ((\g >> 5) << 3) | (\b>>5)
        \hb = res2>>1
        \lb = res2 & 1
        ;res2 = ((r>>5) << 6) | ((g >> 5) << 3) | (b>>5)
        ;'res3=res2 >>1 : sb=res2 band 1
        ;Debug res2>>1
        ;Debug res2 & 1
      EndWith
      
      ;colmap(c)=col1
      c=c+1
      ;Debug v 
      i=0
    Wend
    
    CloseFile(1)  
  Else
    MessageRequester("ERROR!","Cannot load r3g3b2.txt palette!")
    End 
  EndIf
  
EndProcedure


Procedure ReadPalette()
  If OpenFile(1,"r3g3b2.txt")
    l=Lof(1)
    Dim ii$(3)
    
    Global NewList palette.palmap() 
    
    Dim rr(256)
    Dim gg(256)
    Dim bb(256)
    While Not Eof(1)
      
      line$=ReadString(1)
      
      
      While i<3
        ii$(i)=StringField(LTrim(line$),i+1," ")
        i+1
      Wend 
      
      AddElement(palette()) 
      
      With palette()
        
        \r = Val(ii$(0))
        \g = Val(ii$(1))
        \b = Val(ii$(2))
        \i = ListIndex(palette())
        
      EndWith
      
      ;colmap(c)=col1
      c=c+1
      ;Debug v 
      i=0
    Wend
    
    CloseFile(1)  
  Else
    MessageRequester("ERROR!","Cannot load r3g3b2.txt palette!")
    End 
  EndIf
  
EndProcedure

Procedure rgb92rgb24(rgb9)
  
  r = PeekA(?LUT3BITTO8BIT+(rgb9 >> 6 & 7))
  g = PeekA(?LUT3BITTO8BIT+(rgb9 >> 3 & 7))
  b = PeekA(?LUT3BITTO8BIT+(rgb9 & 7))
  ;Dim LUT3BITTO8BIT(7) As ubyte => 
  Debug r
  Debug g
  Debug b
  
  
  DataSection: 
    LUT3BITTO8BIT:
    Data.a 0,$24,$49,$6D,$92,$B6,$DB,$FF
  EndDataSection
  
EndProcedure

Procedure rgb24torgb3(r,g,b)
  
  ;b9=peek(@palette+cast(uinteger,c))
  ;g9=peek(@palette+cast(uinteger,c+1))
  ;r9=peek(@palette+cast(uinteger,c+2))
  res2 = ((r>>5) << 6) | ((g >> 5) << 3) | (b>>5)
  ;'res3=res2 >>1 : sb=res2 band 1
  Debug res2>>1
  Debug res2 & 1
  
EndProcedure



ReadPaletteA()
*buf = AllocateMemory(16384)
For loop=3 To 3
  
  source=LoadImage(#PB_Any,infilename$)
  
  output=CreateImage(#PB_Any,8,256*8)
  
  off=0
  
  x = 0 : y = 0 
  
  ; this bit makes a copy of the input image and scales it to ImageID(tmp)
  
  bias = 0 
  
  For c = 0 To 255
    
    
    ; this is where we change the order of reading the tiles. 
    ; so far it does left to right 0 - 255 0 - 192
    ; we would like blocks of 4 ; 1 2
    ;                             3 4 
    ; from                        1 2 3 4 5 6 7 8 9 
    
    For my = 0 To 1
    For mx = 0 To 1 
      StartDrawing(ImageOutput(source))  
      tmp=GrabDrawingImage(#PB_Any,(x)+mx*8,(y)+my*8,8,8)
      
      StopDrawing()
      
      StartDrawing(CanvasOutput(1))
      ;  Box(0,0,50,50,#Black)
      ;DrawImage(ImageID(tmp),0,0)
      ;DrawImage(ImageID(tmp),0,c*8*2,16,16)
      DrawImage(ImageID(tmp),(x*2)+mx*16,(y*2)+my*16,16,16)
  
      StopDrawing()
      ; Draws the image on the image output 
      StartDrawing(ImageOutput(output))
      DrawImage(ImageID(tmp),0,pxc) : pxc=pxc+8
      StopDrawing()
      FreeImage(tmp)
  
      
      
  Next mx 
  
    Next my 
  
         x=x+8
    If x>255                   ; width 
      y = y+16
      x = 0
    EndIf  
    
  Next  
  
  ; this reads the bytes in the image 
  
  StartDrawing(ImageOutput(output))

  For y=0 To 255
    For x=0 To 7
      ;x = 0 : y = 0 
      ;For c = 0 To 255
      ; looks at the pixel at x /y 
      col=Point(x,y)
      r = Red(col)
      g = Green(col)
      b = Blue (col)
      ps=0
      ;Debug Str(r)+" "+Str(g)+" "+Str(b)
      ;FirstElement(palette())
      ForEach palette()
        With palette()
          If r = \r And g = \g And b = \b
            curcol = ListIndex(palette())
            
            ;PokeA(*buffer,curcol)
            ;CharMap(x,y)=curcol
            ;Debug curcol 
            PokeA(*buf+off,curcol)
            
            Break 
          EndIf
        EndWith
      Next
      off+1

      ; Debug val
    Next
  Next 

  StopDrawing()
  
  ; Debug SaveImage(output,"output2.bmp")
  
  ;If OpenFile(5,"4bit.spr")
  ;  WriteData(5,*buf,64*8*8)
  ;  CloseFile(5)
  ;EndIf 
  off=0
  
  For bytepos=0 To 255*8*8          ; converts the byte image to 4 bit nibbles. 
    lbyte=PeekA(*buf+bytepos)<<4   ; gets first nibble shifts left 4 times 
    bytepos+1
    rbyte=PeekA(*buf+bytepos)       ; gets next nibble 
    
    ;old stupid way 
    ;lft$=Right(Hex(lbyte),1) : rght$=Right(Hex(rbyte),1)
    ;in$="$"+lft$+rght$
    ;bit=Val(in$)
    ;  Debug bit
    
    bit = lbyte + rbyte           ; adds the nibbles together
    PokeA(*buf+off,bit)           ; pops it in memory 
    off+1
    
  Next 
  ShowMemoryViewer(*buf,16384)
  If OpenFile(5,"C:\NextBuildv5\Sources\xmas2019\data\"+NAME$+".spr")
    WriteData(5,*buf,255*8*8)
    CloseFile(5)
    DeleteFile("h:\"+NAME$+".spr",#PB_FileSystem_Force)
    CopyFile(NAME$+".spr","h:\"+NAME$+".spr")
  EndIf 
  
  If OpenFile(2,"C:\NextBuildv5\Sources\xmas2019\data\"+NAME$+".pal")
    With palette()
      ForEach palette()
        WriteAsciiCharacter(2,\hb)
        WriteAsciiCharacter(2,\lb)
      Next 
    EndWith
    CloseFile(2)
  ;  DeleteFile("h:\"+NAME$+".pal",#PB_FileSystem_Force)
  ;  CopyFile(NAME$+".pal","h:\"+NAME$+".pal")
  EndIf 
  
  FreeImage(source)
  FreeImage(output)
  
  
  
Next 
FreeMemory(*buf)
Repeat
  x=WaitWindowEvent()
  If x=#PB_Event_CloseWindow
    quit=1
  EndIf
  
Until quit=1

; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 195
; FirstLine = 51
; Folding = w
; EnableXP