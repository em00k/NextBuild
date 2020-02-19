Enumeration
  #ScrWidth=800
  #ScrHeight=600
EndEnumeration

InitSprite()
InitKeyboard()
InitMouse()
UsePNGImageDecoder()

desktop=ExamineDesktops()

Global window=OpenWindow(#PB_Any,(DesktopWidth(0)/2)-#Scrwidth/2,(DesktopHeight(0)/2)-#ScrHeight/2,#Scrwidth,#ScrHeight,"Test")
OpenWindowedScreen(WindowID(window),0,0,#Scrwidth,#ScrHeight)

;
; Set up some sprites
;

Procedure SetupSprites()
  
  
  ; paper sprite
  Global paper=CreateSprite(#PB_Any,128,150)
  
  Global paper=LoadSprite(#PB_Any,"square.png")
  
  ; draw some test
  ;     StartDrawing(SpriteOutput(paper))
  ;    DrawText(5,5,"#",#White)
  ;    StopDrawing()
  
  ;set up plots
  
  ClipSprite(paper,0,1,15,14)
 ; ZoomSprite(paper,32,32)
  ; ;   
EndProcedure

;
; Update the screen
;
Procedure UpdateScreen()
  Static a 
  Dim images(255)
  ;
  ; draw the paper sprite as a test
  
  For x = 0 To 16 
    ClearScreen(0)
    DisplaySprite(paper,0,0)
    a+Int(360/16): If a=360 : a = 0 : EndIf 
    RotateSprite(paper,a,#PB_Absolute)
    StartDrawing(ScreenOutput())
    images(x)=GrabDrawingImage(#PB_Any,0,0,16,16)
    StopDrawing()
    
  Next x 
  StartDrawing(ScreenOutput())
  For x = 0 To 16 
    DrawImage(ImageID(images(x)),16*x,0)
  Next x
  StopDrawing()
  
EndProcedure

;
; Init phase

SetupSprites()
UpdateScreen()

Repeat
  WindowEvent()
;   If trig=0
;     ClearScreen(0)
;     ;
;     ; main loop, try to keep procedural 
;     ;
;     UpdateScreen()
;     FlipBuffers()
;     trig=1
;   EndIf 
  
  If ElapsedMilliseconds()>timer
    timer=ElapsedMilliseconds()+50
    trig = 0 
  EndIf 
  
  
  ExamineKeyboard()
  ExamineMouse()
  If KeyboardPushed(#PB_Key_S)
    StartDrawing(ScreenOutput())
    outputim=GrabDrawingImage(#PB_Any,0,0,256,192)
    If outputim
      SaveImage(outputim,"export.bmp",#PB_ImagePlugin_BMP)
    EndIf 
    End 
  EndIf 
  
Until KeyboardPushed(#PB_Key_Escape)



; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 95
; FirstLine = 54
; Folding = -
; EnableXP
; EnableCompileCount = 55
; EnableBuildCount = 0
; EnableUnicode