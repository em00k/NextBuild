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
  
  Global Dim images(255)
  
  ; paper sprite
  Global paper=CreateSprite(#PB_Any,128,150)
  
  ;Global paper=LoadSprite(#PB_Any,"square.png")
  y = 14 : : height=3 : dir= 0 
  StartDrawing(ScreenOutput())
  For nrsprites=0 To 15 
    
    Box(nrsprites*16,y,16,height,#Red)
    If dir= 0 
      y-2
      If y<=0 : dir=1 : EndIf 
    Else 
      y+2
    EndIf 
  Next 
  StopDrawing()
  
  ; draw some test
  ;     StartDrawing(SpriteOutput(paper))
  ;    DrawText(5,5,"#",#White)
  ;    StopDrawing()
  
  ; ;   
EndProcedure

;
; Update the screen
;
Procedure UpdateScreen()
  Static a 
  ;
  ; draw the paper sprite as a test
  For x = 0 To 16 
    DisplayTransparentSprite(paper,32*x,10,255)
  ;'  RotateSprite(paper,a,#PB_Absolute)
  ;  a+Int(360/16): If a=360 : a = 0 : EndIf 
  Next x 
EndProcedure

;
; Init phase

SetupSprites()

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
      SaveImage(outputim,"growbox.bmp",#PB_ImagePlugin_BMP)
    EndIf 
    End 
  EndIf 
Until KeyboardPushed(#PB_Key_Escape)



; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 27
; FirstLine = 16
; Folding = -
; EnableXP
; EnableCompileCount = 40
; EnableBuildCount = 0
; EnableUnicode