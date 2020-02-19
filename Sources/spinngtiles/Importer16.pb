UsePNGImageDecoder()
UsePNGImageEncoder()
UseCRC32Fingerprint()
Structure palmap
  r.i
  g.i
  b.i
  i.i
EndStructure
Structure block
  crc.s
  buff.s
EndStructure

XIncludeFile("Importer.pbf")
XIncludeFile("adaptpalette.pbi")

Global file$="roust256.bmp"
Global file$="Z:\GoogleDrive\AGSE\level1\sc1.png"
;Global file$="monty.bmp"
;Global file$="exolon_2014_gameplay__r1585466331.bmp"
Global canvasimage, found, blkoff, blksize=16, bank=0, numtiles=0, bkimage
Global Dim pals(10)
Global NewList blocks.block() 
Global Dim colbyte(maxblock*9)

#WIDTH = 768
#HEIGHT = 576

Global canvasimage=CreateImage(#PB_Any,768,576) 

; ALlocate some memory for the blocks. 
; 16kb should be enough
Global *blocks = AllocateMemory(16384*4)
Global *blocks_bank2 = AllocateMemory(16384*4)
Global *blocks_bank3 = AllocateMemory(16384*4)
Global *scrbuff 

; And some temp memory
Global *temp = AllocateMemory(256)
; map memory 
Global *map = AllocateMemory(32*24*256)  ; 256 screens of 32x24 8x8px blocks

; procs 


Procedure ReadPalette()
  If ReadFile(1,"r3g3b2.txt")
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

Procedure LoadBMP(w.i,h.i)
  
  Global image$=OpenFileRequester("Open bitmap",GetCurrentDirectory()," images |*.bmp;*.png;*.jpg;*.gif",0)
  
  ;result = ReadFile(1,image$, #PB_File_SharedRead )
  
  Debug image$
  
  If image$<>""
    
    ;image = CreateImage(#PB_Any,256*2,192*2)
    
    ;FreeImage(hImage)
    
    hImage = LoadImage(#PB_Any, image$ )
    
    If hImage
      
      i = ImageTo8bit(ImageID(hImage), 1) 
      
      *image = Save8bitImage(i, "", 1) 
      ;Save8bitImage(i, "testme.bmp", 00)
      ;ResizeImage(1,512,64*2,#PB_Image_Raw )
      
      j = CatchImage(#PB_Any, *image) 
      
      ;Save8bitImage(i, "Z:\GoogleDrive\speccy\udjeednext\temp.bmp") 
      
      StartDrawing(CanvasOutput(Canvas_Import))
      
      
      Box(0,0,512,384,RGB(40,40,40))
      DrawImage(ImageID(j),0,0,ImageWidth((j))+w,ImageHeight((j))+h)
      
      StopDrawing()
      
      SetGadgetState (Spin_RX, ImageWidth(j)) : SetGadgetText(Spin_RX, Str(ImageWidth(j)))
      SetGadgetState (Spin_RY, ImageHeight(j)) : SetGadgetText(Spin_RY, Str(ImageHeight(j)))
      
    EndIf 
    
  EndIf
  
EndProcedure

Procedure LoadBKImage()
  
  Global bkimage = LoadImage(#PB_Any, file$ )      ; load image 
  
  Global fname$ = file$
  
  ; make a copy that we can resize and draw 
  
  If bkimage
    
    ;ResizeImage(bkimage,256,192,#PB_Image_Raw)
    i = ImageTo8bit(ImageID(bkimage), 1) 
    *image = Save8bitImage(i, "", 1)  
    bkimage = CatchImage(#PB_Any, *image) 
    CopyImage(bkimage,bigbkimage)
    ResizeImage(bigbkimage,#WIDTH,#HEIGHT,#PB_Image_Raw)
    ; show on canvas 
    
    ;StartDrawing(CanvasOutput(Canvas_Import))
    
    FreeMemory(*image)
    
  EndIf
  
  StartDrawing(ImageOutput(canvasimage))
  DrawImage(ImageID(bigbkimage),0,0,#WIDTH,#HEIGHT)
  StopDrawing()
  
EndProcedure

Procedure ColorLookup(x,y)
  
  retcol = 0 
  ;StartDrawing(ImageOutput(bkimage))
  col = Point (x,y)
  r = Red(col)
  g = Green(col)
  b = Blue (col)
  ForEach palette()
    With palette()
      If r = \r And g = \g And b = \b
        curcol = ListIndex(palette())
        retcol = curcol
        Break 
      EndIf
    EndWith
  Next
  
  ProcedureReturn retcol 
  ;StopDrawing()
  
EndProcedure

Procedure UpdateCanvas()
  
  StartDrawing(CanvasOutput(Canvas_Import))
  DrawImage(ImageID(canvasimage),0,0,#WIDTH,#HEIGHT)
  StopDrawing()
  
EndProcedure

Procedure DrawGrid()
  
  StartDrawing(ImageOutput(canvasimage))
  For y = 0 To 23 Step 2
    For x = 0 To 31 Step 2 
      Line(x*24,0,1,#HEIGHT,#Blue)
      Line(0,y*24,#WIDTH,1,#Blue)
    Next
  Next
  StopDrawing()
  
  
EndProcedure

Procedure CheckBlock(size=64)
  
  
  Static c 
  found = #False
  finger$ = Fingerprint(*temp,size,#PB_Cipher_CRC32)
  
  ;;Debug finger$
  With blocks()
    ForEach blocks()
      ;Debug    blocks()\crc
      
    ;  If CompareMemory(*temp,blocks()\bff
      If finger$ =    blocks()\crc
        ;Debug "Found block already "+finger$
        found = 0
        ProcedureReturn ListIndex(blocks())
        Break 1
      EndIf 
    Next 
  EndWith
  
  ;If found = #False
  AddElement(blocks())
  blocks()\crc=finger$
  Debug "added "+finger$
  c=ListIndex(blocks())
  found = 1 
  Debug c
  numtiles = c - 1 
  ;EndIf 
  ProcedureReturn c
EndProcedure

Procedure SaveData()
  Debug Left(fname$,Len(fname$)-3)+"bin"
  
  If OpenFile(0,Left(fname$,Len(fname$)-3)+"bin")
    WriteData(0,*Map,768)
    CloseFile(0)
  EndIf
  
  If OpenFile(1,Left(fname$,Len(fname$)-3)+"spr")
    WriteData(1,*blocks,16384)
    CloseFile(1)
  Else
    Debug "error saving blocks.spr"
  EndIf
  If bank>0
    If OpenFile(1,Left(fname$,Len(fname$)-4)+"2.spr")
      WriteData(1,*blocks_bank2,16384)
      CloseFile(1)
    EndIf
  EndIf
  
  
EndProcedure

Procedure GetBlocks16()
  
  ; grab block 
  blkoff = 0 
  ; outer loop to move across screen 
  
  gs = GetGadgetState(Checkbox_values)    ; store the state of Show Values
  
  For yy = 0 To 192-8 Step 16 
    For xx = 0 To 256-8 Step 16
      
      found = 0 
      offset = 0 
      ; inner loop to read block ay xx,yy
      StartDrawing(ImageOutput(bkimage))    
      For y = 0 To 15                     ; read 16 pix across and down 
        For x = 0 To 15
          ;val = Point(x+xx,y+yy)
          val2 = ColorLookup(x+xx,y+yy)
          PokeA(*temp+offset,val2)        ; poke value to temp buffer 
          offset = offset + 1             ; increse offset for px
        Next  
      Next 
      StopDrawing()
      
      blk = CheckBlock()                  ; set blk to checkblock result
      
      offset=0
      ; test 
      If found > 0                        ; new block was found not in list 
        StartDrawing(CanvasOutput(Canvas_Import))
        DrawingMode(#PB_2DDrawing_Outlined )
        
        ;{          
        ;}        ;DrawingMode(#PB_2DDrawing_AlphaBlend  )
        
        Box(xx*3,yy*3,48,48,#Red)         ; highlight new block with red 
        DrawingMode(#PB_2DDrawing_Default )
        StopDrawing()
        
        If blk=64 And bank=0             ; have we exceeded the 16kb bank?
          bank+1                         ; yes next bank
          blkoff=0
          
          
        EndIf 
        If bank=0
          CopyMemory(*temp,*blocks+blkoff,256)
        Else 
          CopyMemory(*temp,*blocks_bank2+blkoff,256)
        EndIf 
        
        blkoff+256                        ; increase the blkoff amount by 256
        
      EndIf 
      
      ; stop in the map 
      
      PokeA(*map+((xx/16)+(yy/16)*16),blk)  ; poke the tile number to memory 
      
      ; show tile value
      If blk>0  And gs= 1
        StartDrawing(CanvasOutput(Canvas_Import))
        DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_XOr)
        DrawText(xx*3,yy*3,Str(blk),#White)
        DrawingMode(#PB_2DDrawing_Default )
        StopDrawing()
      EndIf 
    Next 
  Next 
  ;ShowMemoryViewer(*map,768)
  
  
EndProcedure

Procedure GetBlocksSpectrum()
  
  ; grab block 
  
  gs = GetGadgetState(Checkbox_values)    ; store the state of Show Values
  
  ; outer loop to move across screen 
  
  For yy = 0 To 192-8 Step 8 
    For xx = 0 To 256-8 Step 8
      
      found = 0 
      offset = 0 
      ; inner loop to read block ay xx,yy
      StartDrawing(ImageOutput(bkimage))    
      For y = 0 To 7
        For x = 0 To 7
          ; val = Point(x+xx,y+yy)
          val2 = ColorLookup(x+xx,y+yy)
          PokeA(*temp+offset,val2)       ; poke value to temp buffer 
          offset = offset + 1
        Next 
      Next 
      StopDrawing()
      
      blk = CheckBlock(64)
      
      offset=0
      ; test 
      If found > 0
        StartDrawing(CanvasOutput(Canvas_Import))
        DrawingMode(#PB_2DDrawing_Outlined )
        
        ;         For y = 0 To 8
        ;           For x = 0 To 7
        ;             
        ;             val = PeekA(*temp+offset)       ; poke value to temp buffer 
        ;             SelectElement(palette(),val)
        ;             col = RGB(palette()\r,palette()\g,palette()\b)
        ;             ;Plot(x,y,val)
        ;            ; Box(xx*3+x*3,yy*3+y*3,3,3,col)
        ;             
        ;             offset = offset + 1
        ;           Next 
        ;         Next 
        
        ;DrawingMode(#PB_2DDrawing_AlphaBlend  )
        Box(xx*3,yy*3,24,24,#Red)
        DrawingMode(#PB_2DDrawing_Default )
        StopDrawing()
        CopyMemory(*temp,*blocks+blkoff,64)
        blkoff+64
        
      EndIf 
      
      ; stop in the map 
      
      PokeA(*map+((xx/8)+(yy/8)*32),blk)
      If blk>0  And gs= 1
        StartDrawing(CanvasOutput(Canvas_Import))
        DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_XOr)
        DrawText(xx*3,yy*3,Hex(blk),#White)
        DrawingMode(#PB_2DDrawing_Default )
        StopDrawing()
      EndIf
      
    Next 
  Next 
  ShowMemoryViewer(*map,768)
  
  
EndProcedure


Procedure GetBlocks()
  
  ; grab block 
  
  gs = GetGadgetState(Checkbox_values)    ; store the state of Show Values
  
  ; outer loop to move across screen 
  
  For yy = 0 To 192-8 Step 8 
    For xx = 0 To 256-8 Step 8
      
      found = 0 
      offset = 0 
      ; inner loop to read block ay xx,yy
      StartDrawing(ImageOutput(bkimage))    
      For y = 0 To 7
        For x = 0 To 7
          ; val = Point(x+xx,y+yy)
          val2 = ColorLookup(x+xx,y+yy)
          PokeA(*temp+offset,val2)       ; poke value to temp buffer 
          offset = offset + 1
        Next 
      Next 
      StopDrawing()
      
      blk = CheckBlock(64)
      
      offset=0
      ; test 
      If found > 0
        StartDrawing(CanvasOutput(Canvas_Import))
        DrawingMode(#PB_2DDrawing_Outlined )
        
        ;         For y = 0 To 8
        ;           For x = 0 To 7
        ;             
        ;             val = PeekA(*temp+offset)       ; poke value to temp buffer 
        ;             SelectElement(palette(),val)
        ;             col = RGB(palette()\r,palette()\g,palette()\b)
        ;             ;Plot(x,y,val)
        ;            ; Box(xx*3+x*3,yy*3+y*3,3,3,col)
        ;             
        ;             offset = offset + 1
        ;           Next 
        ;         Next 
        
        ;DrawingMode(#PB_2DDrawing_AlphaBlend  )
        Box(xx*3,yy*3,24,24,#Red)
        DrawingMode(#PB_2DDrawing_Default )
        StopDrawing()
        CopyMemory(*temp,*blocks+blkoff,64)
        blkoff+64
        
      EndIf 
      
      ; stop in the map 
      
      PokeA(*map+((xx/8)+(yy/8)*32),blk)
      If blk>0  And gs= 1
        StartDrawing(CanvasOutput(Canvas_Import))
        DrawingMode(#PB_2DDrawing_Transparent|#PB_2DDrawing_XOr)
        DrawText(xx*3,yy*3,Hex(blk),#White)
        DrawingMode(#PB_2DDrawing_Default )
        StopDrawing()
      EndIf
      
    Next 
  Next 
  ShowMemoryViewer(*map,768)
  
  
EndProcedure

Procedure UpdateTiles16()
  
  offset = 0                                      
  StartDrawing(CanvasOutput(Canvas_Blocks))      ; select Canvas_Blocks to draw on
  Box(0,0,380,830,#Black)                        ; Draw a black back ground 
  
  For c = 0 To numtiles                          ; loop for number of tiles in list
    
    For y = 0 To 15                              ; loop acroos and down 
      For x = 0 To 15          
        val = PeekA(*blocks+offset+offadd)       ; get value from *blocks+offset+offadd
        SelectElement(palette(),val)             ; select correct colour 
        col = RGB(palette()\r,palette()\g,palette()\b)
        ;Plot(x,y,val)
        Box(xxbl*32+(x*2),yybl*32+(y*2),2,2,col)     ; draw box to canvas_blocks
        offadd+1                                     ; increase offadd by 1 
      Next 
    Next
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(xxbl*32,yybl*32,Str(c))
    DrawingMode(#PB_2DDrawing_Default)
    xxbl+1                                       ; increase xxbl 
    If xxbl>=8                                   ; if 12 or more reset xxlb and increse
      xxbl=0
      yybl+1                                     ; yybl by 1 
    EndIf
    offset+256 : offadd = 0                      ; next tile to show 
  Next 
  
  For y = 0 To 25 
    For x = 0 To 11 
      Line(x*32,0,1,#HEIGHT,#Blue)
      Line(0,y*32,#WIDTH,1,#Blue)
    Next
  Next
  
  StopDrawing()
  
EndProcedure

Procedure UpdateTiles()
  
  offset = 0                                      
  StartDrawing(CanvasOutput(Canvas_Blocks))      ; select Canvas_Blocks to draw on
  Box(0,0,380,830,#Black)                        ; Draw a black back ground 
  
  For c = 0 To numtiles                          ; loop for number of tiles in list
    
    For y = 0 To 7                              ; loop acroos and down 
      For x = 0 To 7          
        val = PeekA(*blocks+offset+offadd)       ; get value from *blocks+offset+offadd
        SelectElement(palette(),val)             ; select correct colour 
        col = RGB(palette()\r,palette()\g,palette()\b)
        ;Plot(x,y,val)
        Box(xxbl*32+(x*4),yybl*32+(y*4),4,4,col)     ; draw box to canvas_blocks
        offadd+1                                     ; increase offadd by 1 
      Next 
    Next
    DrawingMode(#PB_2DDrawing_Transparent)
    DrawText(xxbl*32,yybl*32,Hex(c))
    DrawingMode(#PB_2DDrawing_Default)
    xxbl+1                                       ; increase xxbl 
    If xxbl>=8                                   ; if 12 or more reset xxlb and increse
      xxbl=0
      yybl+1                                     ; yybl by 1 
    EndIf
    offset +64: offadd = 0                      ; next tile to show 
  Next 
  
  ;StartDrawing(ImageOutput(Canvas_Blocks))
  For y = 0 To 25 
    For x = 0 To 11  
      Line(x*32,0,1,#HEIGHT,#Blue)
      Line(0,y*32,#WIDTH,1,#Blue)
    Next
  Next
  StopDrawing()
  
  StopDrawing()
  
EndProcedure


Procedure DrawBlocks(scalefactor,maxwidth=9)
  ; array of colours
  
  Dim c.i(16)
  
  c(0)=RGB(0,0,0)   ; black
  c(1)=RGB(0,0,202) ; blue
  c(2)=RGB(202,0,0)   ; red
  c(3)=RGB(202,0,202)   ; megenta
  c(4)=RGB(0,202,0); green
  c(5)=RGB(0,202,202)   ; cyan 
  c(6)=RGB(202,202,0)   ; yellow
  c(7)=RGB(202,202,202)   ; white 
  
  ; brights
  
  c(8)=RGB(0,0,0)   ; black
  c(9)=RGB(0,0,255) ; blue
  c(10)=RGB(255,0,0)   ; red
  c(11)=RGB(255,0,255)   ; megenta
  c(12)=RGB(0,255,0); green
  c(13)=RGB(0,255,255)   ; cyan 
  c(14)=RGB(255,255,0)   ; yellow
  c(15)=RGB(255,255,255)   ; white 
  

  StartDrawing(ImageOutput(Canvas_Blocks))
  
  Box(0,0,800,400,#Blue)
  
  scale = scalefactor
  
  Repeat 
    For y = 0 To 7
      For x = 0 To 7
        pixel = PeekA(*scrbuff+(x+y*8)+count)
        
        x1 = (x*scale)+xadd
        y1 = (y*scale)+yadd 
        
        col.c = PeekA(*scrbuff+6143+cc)
;         
;         f.b = Int (col/128)
;         b.b = Int ((col-(f*128))/64)
;         col = Int (col-(64*b)-(128*f))
;         p.b = Int (col/8)
;         i.b = Int (col-(p*8))
;         
        
        ; get paper ink flash and bright from block attribute 
        
        i.b = col.c & %00000111    ; 00000111
        p.b = col.c >> 3 & %0111   ; 00111000
        f.b = col.c & %10000000    ; 10000000
        b.b = col.c >> 6 & %1      ; 01000000

        fg = c(i+8*b)
        bg = c(p+8*b)
        
        ;Debug bg
        
        If pixel = 1
          Box(x1,y1,scale,scale,fg)
        Else
          
          Box(x1,y1,scale,scale,bg) 
        EndIf 
        
       
        
      Next 
       cc+1
    Next 
    
    xadd + 0+ scale * 8 
    count + 1
    
    If x1> maxwidth*8; 64*8-(scale*8)
      yadd+0+scale*8
      xadd = 0 
    EndIf
    ;Debug count / 64
    ;block+1
    
  Until count=40
  
  tiles=GrabDrawingImage(#PB_Any,0,0,80,80)
  
  StopDrawing()

  UpdateCanvas()

  
EndProcedure


Procedure ImLoad()
  file$=OpenFileRequester("","","",0)
  If file$<>""
    blkoff=0 : offset=0 : found=0 : numtiles = 0 
    ClearList(blocks())
    LoadBKImage() : DrawGrid() : UpdateCanvas() : 
    If GetGadgetState(Option_8)=0
      GetBlocks16()
      UpdateTiles16()
    Else
      GetBlocks()
      UpdateTiles()
    EndIf
    
    
  EndIf
EndProcedure     

Procedure ImOnlyLoad()
  file$=OpenFileRequester("","","",0)
  If file$<>""
    ;blkoff=0 : offset=0 : found=0 : numtiles = 0 
    ;ClearList(blocks())
    LoadBKImage() : DrawGrid() : UpdateCanvas() : 
    If GetGadgetState(Option_8)=0
      GetBlocks16()
      UpdateTiles16()
    Else
      GetBlocks()
      UpdateTiles()
    EndIf
    
    
  EndIf
EndProcedure     

Procedure ImSpectrum()
  
  file$=OpenFileRequester("","","",0)
  If file$<>""
    ClearList(blocks())
    ;Global scrnam$ = LoadImage(#PB_Any, file$ )      ; load image 
    
    bkimage = CreateImage(#PB_Any,256,192)
    
    scrin = ReadFile(#PB_Any,file$)
    
    If scrin 
      
      SetWindowTitle(Window_Importer,file$)
      
      Debug "opening "+file$
      
      *scrbuff = AllocateMemory(Lof(scrin))     ; allocate memory for screen 
      
      Dim c.i(16)
      
      c(0)=RGB(0,0,0)   ; black
      c(1)=RGB(0,0,202) ; blue
      c(2)=RGB(202,0,0) ; red
      c(3)=RGB(202,0,202)   ; megenta
      c(4)=RGB(0,202,0)     ; green
      c(5)=RGB(0,202,202)   ; cyan 
      c(6)=RGB(202,202,0)   ; yellow
      c(7)=RGB(202,202,202) ; white 
      
      ; brights
      
      c(8)=RGB(0,0,0)   ; black
      c(9)=RGB(0,0,255) ; blue
      c(10)=RGB(255,0,0); red
      c(11)=RGB(255,0,255)   ; megenta
      c(12)=RGB(0,255,0)     ; green
      c(13)=RGB(0,255,255)   ; cyan 
      c(14)=RGB(255,255,0)   ; yellow
      c(15)=RGB(255,255,255) ; white 
      
      If ReadData(scrin,*scrbuff,6912)
        
        Debug "Read data"
        
        
        
        StartDrawing(ImageOutput(bkimage))
        py=0        
        For outer = 0 To 2                                    ; outer loop which third           
          For off = 0 To 255 Step 32                          ; Next 8*line            
            For sy = 0 To 2047 Step 256                       ; next char                           
              For x = 0 To 31                                 ; left to righ                 
                colb.b = PeekA(*scrbuff+6144+papery+pp)
               i.b = colb & %00000111    ; 00000111
                p.b = colb >> 3 & %0111   ; 00111000
                f.b = colb & %10000000    ; 10000000
                b.b = colb >> 6 & %1      ; 01000000               
                fg = c(i+8*b) : bg = c(p+8*b)                
                sh = 1                                         ; byte to test for                 
                offset = outer*2048                            ; offset third*2048                 
                byte = PeekA(*scrbuff+offset+x+sy+off)         ; get the next linear byte 
                For bb=7 To 0 Step -1                          ; set up shift to read bits 0 - 7                       
                  If byte & sh                                 ; get value and test against sh
                    Plot((x*8)+bb,py,fg)                       ; it was true so pixel 
                  Else 
                    Plot((x*8)+bb,py,gg)                       ; it was a zero                    
                  EndIf                  
                  sh << 1                                     ; shift our test bit left 1                  
                Next    
                sh = 0                                        ; all done reset 
               pp+1   
              Next    
              pp = 0   
              py + 1                                          ; inc leanear plot line           
              If py = 192                                     ; we hit 192 most we can go exit 
                Break 1
              EndIf         
            Next 
            papery+32 :   
            col + 1   
          Next 
        Next   
        StopDrawing()
        CloseFile(scrin)
      Else 
        Debug "Error opening "+fname$
      EndIf
      
    Else
      Debug "Error opening "+fname$
      
      
    EndIf 
    
    new=CopyImage(bkimage,#PB_Any )
    ;'ResizeImage(new,#WIDTH,#HEIGHT,#PB_Image_Raw)
    SaveImage(new,"temp.bmp",#PB_ImagePlugin_BMP)
    file$="temp.bmp"
    LoadBKImage()
    DrawGrid() : UpdateCanvas() : 
    
  ;  
;     StartDrawing(ImageOutput(canvasimage))
;     DrawImage(ImageID(j),0,0,#WIDTH,#HEIGHT)
;     StopDrawing()

   
; 
;     StartDrawing(CanvasOutput(Canvas_Import))
;     DrawImage(ImageID(canvasimage),0,0,#WIDTH,#HEIGHT)
;     StopDrawing()     
   ; DrawBlocks(2,9)
    

  EndIf
  
      GetBlocks()
    UpdateTiles()
EndProcedure


Procedure Window_Importer_Events(event)
  Select event
    Case #PB_Event_CloseWindow
      ProcedureReturn #False
      
    Case #PB_Event_Menu
      Select EventMenu()
      EndSelect
      
    Case #PB_Event_Gadget
      Select EventGadget()
          
        Case Btn_ImLoad
          ; Load in a new image and process blocks 
          ImLoad()
        Case Btn_SaveAll
          ; save all the data, tiles and map
          SaveData()
          
        Case Spin_MWidth
          Width=GetGadgetState(Spin_MWidth)*16*48
          ResizeGadget(Canvas_Import,0, 0, Width, 590)
          SetGadgetAttribute(Scroll_Area_1,#PB_ScrollArea_InnerWidth,Width)
          UpdateCanvas()
          StartDrawing(CanvasOutput(Canvas_Import))
          For y = 0 To 23 Step 2
            For x = 0 To Width*16 Step 2 
              Line(x*24,0,1,#HEIGHT,#Blue)
              Line(0,y*24,Width,1,#Blue)
            Next
          Next
          StopDrawing()
        Case Scroll_Area_1
          Select EventType()
            Case  #PB_EventType_Resize
              SetGadgetAttribute(Scroll_Area_1,#PB_ScrollArea_ScrollStep,32)
              Debug GetGadgetAttribute(Scroll_Area_1,#PB_ScrollArea_ScrollStep)
          EndSelect
        Case Btn_ImOnly
          ImOnlyLoad()
        Case Btn_ImSpectrum
          ImSpectrum()
          
          
      EndSelect
  EndSelect
  ProcedureReturn #True
EndProcedure

Procedure SetUp()
  StartDrawing(CanvasOutput(Canvas_Import))
  Box(0,0,800,600,#Black)
  StopDrawing()
  ReadPalette()
  SetGadgetState(Spin_MWidth,1)
  ;SetGadgetState(#PB_ScrollArea_ScrollStep  ,16)
  
EndProcedure

OpenWindow_Importer()
SetUp() 
LoadBKImage()
DrawGrid()
SetGadgetAttribute(Canvas_Import, #PB_Canvas_Cursor, #PB_Cursor_Cross)
UpdateCanvas()
GetBlocks16()
UpdateTiles16()

Repeat 
  
  event = WaitWindowEvent()
  result=Window_Importer_Events(event)
  
Until result = #False


; IDE Options = PureBasic 5.62 (Windows - x86)
; CursorPosition = 18
; FirstLine = 6
; Folding = EP5+
; EnableXP
; Executable = C:\BorielsZXBasic4Next0.3b\Sources\chicken\importer.exe