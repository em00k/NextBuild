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
  Dim p(x,y)
  ZoomSprite(paper,32,32)
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
    RotateSprite(paper,a,#PB_Absolute)
    a+Int(360/16): If a=360 : a = 0 : EndIf 
  Next x 
EndProcedure

;
; Init phase

SetupSprites()

Repeat
  WindowEvent()
  If trig=0
    ClearScreen(0)
    ;
    ; main loop, try to keep procedural 
    ;
    UpdateScreen()
    FlipBuffers()
    trig=1
  EndIf 
  
  If ElapsedMilliseconds()>timer
    timer=ElapsedMilliseconds()+50
    trig = 0 
  EndIf 
  
  
  ExamineKeyboard()
  ExamineMouse()
Until KeyboardPushed(#PB_Key_Escape)



; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; CursorPosition = 46
; FirstLine = 30
; Folding = -
; EnableXP
; EnableCompileCount = 29
; EnableBuildCount = 0
; EnableUnicode