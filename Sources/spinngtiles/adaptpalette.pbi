; Library commands:       ImageTo8bit() and Save8bitImage() 
; Author:                 Lloyd Gallant (netmaestro) 
; Date:                   December 12, 2008 
; Target OS:              Microsoft Windows All 
; Target Compiler:        PureBasic 4.3 and later 
; License:                Free, unrestricted, no warranty 
;            
; Usage: ImageTo8bit(hImageIn, palette) 
; 
;        hImageIn: is the 16,24 or 32bit image to reduce to 8bit depth 
;        palette:  is either 0,1 or 2:  0 = grayscale 
;                                       1 = MSX2 Screen8 color palette 
;                                       2 = Adaptive color palette 
; 
; Usage: Save8bitImage(image, filename$ [,memory]) 
; 
;        image:     is an 8bit image to save to disk or memory 
;        filename$: is the name to save it to. 
;        memory:    is a boolean which if true, will cause the procedure to return 
;                   a memory block containing the complete bitmap file. You may 
;                   compress this and send it over a network or catch the image 
;                   from the returned pointer as desired. You must free the pointer 
;                   when you're finished to avoid a memory leak. 
;===================================================================================== 

Procedure GrayscaleTable() 
  
  Global Dim GrayTable.RGBQUAD(256) 
  For i = 0 To 255 
    With GrayTable(i) 
      \rgbBlue  = i 
      \rgbGreen = i 
      \rgbRed   = i 
      \rgbReserved = 255 
    EndWith        
  Next 
  
  *_bpalette = AllocateMemory(256*SizeOf(RGBQUAD)) 
  CopyMemory(@GrayTable(),*_bpalette, MemorySize(*_bpalette)) 
  ReDim GrayTable(0) 
  ProcedureReturn *_bpalette 
  
EndProcedure 

Procedure ColorTable()
   img0 = CatchImage(#PB_Any, ?ColorTable, 954)
   ;img0 = LoadImage(#PB_Any, "Z:\GoogleDrive\speccy\udjeednext\pbpal.bmp")

    DataSection
      ColorTable:
          IncludeBinary ("Z:\GoogleDrive\speccy\udjeednext\newpal.bmp")
       ColorTableend:
     EndDataSection
    
  Global Dim ctable.RGBQUAD(256) 
  
  cc=0 
  StartDrawing(ImageOutput(img0)) 
  For j=0 To 15 
    For i=0 To 15 
      col = Point(i,j) 
      With ctable(cc) 
        \rgbGreen = Green(col) 
        \rgbRed   = Red(col) 
        \rgbBlue  = Blue(col) 
        \rgbReserved = 0 
      EndWith 
      cc+1 
    Next 
  Next 
  StopDrawing() 
  FreeImage(img0) 
  
  *_bpalette = AllocateMemory(256*SizeOf(RGBQUAD)) 
  CopyMemory(@ctable(),*_bpalette, MemorySize(*_bpalette)) 
  ReDim ctable(0) 
  ProcedureReturn *_bpalette 

  
EndProcedure  

ProcedureDLL Save8bitImage(image, filename$, memory=0) 
  
  If GetObject_(image, SizeOf(BITMAP), Bmp.BITMAP) 
    With BmiInfo.BITMAPINFOHEADER 
      \biSize         = SizeOf(BITMAPINFOHEADER) 
      \biWidth        = Bmp\bmWidth 
      \biHeight       = Bmp\bmHeight 
      \biPlanes       = 1 
      \biBitCount     = 8 
    EndWith 
  Else 
    ProcedureReturn 0 
  EndIf 
  
  sz_colorbits = Bmp\bmWidthBytes*Bmp\bmHeight 
  *colortable = AllocateMemory(256*SizeOf(RGBQUAD)) 
  dc = CreateDC_("DISPLAY",0,0,0)
  hdc = CreateCompatibleDC_(dc)
    SelectObject_(hdc, image)
    NumColors = GetDIBColorTable_(hdc, 0, 256, *colortable) 
  DeleteDC_(dc)
  DeleteDC_(hdc)
  sz_image = SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER) + NumColors*SizeOf(RGBQUAD) + sz_colorbits 
  *rawimage = AllocateMemory(sz_image) 
  *fileheader.BITMAPFILEHEADER = *rawimage 
  *header = *rawimage + SizeOf(BITMAPFILEHEADER) 
  With *fileheader 
    \bfType = $4D42 ; "BM" for Bit Map
    \bfSize = sz_image 
    \bfOffBits = SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER) + NumColors*SizeOf(RGBQUAD) 
  EndWith 
  CopyMemory(BmiInfo, *header, SizeOf(BITMAPINFOHEADER)) 
  CopyMemory(*colortable, *rawimage + SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER), NumColors*SizeOf(RGBQUAD)) 
  CopyMemory(Bmp\bmBits, *rawimage + SizeOf(BITMAPFILEHEADER) + SizeOf(BITMAPINFOHEADER) + NumColors*SizeOf(RGBQUAD), sz_colorbits) 
  
  FreeMemory(*colortable) 
  
  If Not memory 
    file = CreateFile(#PB_Any, filename$) 
    If file 
      WriteData(file,*rawimage,MemorySize(*rawimage)) 
      CloseFile(file) 
    EndIf 
    FreeMemory(*rawimage) 
    ProcedureReturn 1 
  Else 
    ProcedureReturn *rawimage 
  EndIf 
  
EndProcedure 

Procedure Get32BitColors(pBitmap) 

  GetObject_(pBitmap, SizeOf(BITMAP), @Bmp.BITMAP) 
  
  With BmiInfo.BITMAPINFOHEADER 
    \biSize         = SizeOf(BITMAPINFOHEADER) 
    \biWidth        = Bmp\bmWidth 
    \biHeight       = -Bmp\bmHeight 
    \biPlanes       = 1 
    \biBitCount     = 32 
    \biCompression  = #BI_RGB  
  EndWith 
  
  *pPixels = AllocateMemory(4*Bmp\bmWidth*Bmp\bmHeight) 
  hDC = GetWindowDC_(#Null) 
  iRes = GetDIBits_(hDC, pBitmap, 0, Bmp\bmHeight , *pPixels, @bmiInfo, #DIB_RGB_COLORS) 
  ReleaseDC_(#Null, hDC) 
  ProcedureReturn *pPixels 
  
EndProcedure 

Procedure AdaptiveColorTable(pBitmap) 

  *pPixels = Get32BitColors(pBitmap) 
  Global Dim ColorBits.l(MemorySize(*pPixels)/4) 
  CopyMemory(*pPixels,ColorBits(),MemorySize(*pPixels)) 
  FreeMemory(*pPixels) 
  SortArray(ColorBits(),#PB_Sort_Ascending) 
  Global Dim Apalette(256) 
  x = ArraySize(colorbits())/256 
  cc=0 
  lastcolor = colorbits(0)-1 
  For i = 0 To 255 
    If colorbits(cc)<>lastcolor 
      Apalette(i) = colorbits(cc) 
      lastcolor = colorbits(cc) 
      cc+x 
    Else 
      While colorbits(cc) = lastcolor And cc < ArraySize(colorbits()) 
        cc+1 
      Wend 
      x = (ArraySize(colorbits())-cc)/(256-i) 
      cc+x-1 
      Apalette(i) = colorbits(cc) 
      lastcolor = colorbits(cc) 
    EndIf 
  Next 
  
  ReDim Colorbits.l(0) 
  
  *_bpalette = AllocateMemory(256*SizeOf(RGBQUAD)) 
  CopyMemory(@Apalette(),*_bpalette, MemorySize(*_bpalette)) 
  ReDim Apalette(0) 
  ProcedureReturn *_bpalette 

EndProcedure 

ProcedureDLL ImageTo8bit(hImageIn, _bpalette) 

  Select _bpalette 
    Case 0 
      *_bpalette = GrayscaleTable() 
    Case 1 
      *_bpalette = ColorTable() 
    Case 2 
      *_bpalette = AdaptiveColorTable(hImageIn) 
    Default 
      *_bpalette = ColorTable() 
  EndSelect 

  GetObject_(hImageIn,SizeOf(BITMAP),bmp.BITMAP) 
  w = bmp\bmWidth 
  h = bmp\bmHeight 
  d = bmp\bmBitsPixel 

  dc = CreateDC_("DISPLAY",0,0,0)
  hdcSrc = CreateCompatibleDC_(dc)

  With bmi.BITMAPINFO 
    \bmiHeader\biSize     = SizeOf(BITMAPINFOHEADER) 
    \bmiHeader\biWidth    = w 
    \bmiHeader\biHeight   = -h 
    \bmiHeader\biPlanes   = 1 
    \bmiHeader\biBitCount = d 
  EndWith  
  
  GetDIBits_(hdcSrc, hImageIn, 0, 0, #Null, @bmi, #DIB_RGB_COLORS) 
    
  *bits = AllocateMemory(bmi\bmiHeader\biSizeImage) 

  GetDIBits_(hdcSrc, hImageIn, 0, h, *bits, @bmi, #DIB_RGB_COLORS) 
  
  With bmi8.BITMAPINFO 
     \bmiHeader\biSize     = SizeOf(BITMAPINFOHEADER) 
     \bmiHeader\biWidth    = w 
     \bmiHeader\biHeight   = h 
     \bmiHeader\biPlanes   = 1 
     \bmiHeader\biBitCount = 8 
  EndWith
  
  hdcDest = CreateCompatibleDC_(dc)

  hImageOut = CreateDIBSection_(hdcDest, @bmi8, #DIB_PAL_COLORS, @ppvbits, 0, 0) 
   
  SelectObject_(hdcDest, hImageOut)  
  SetDIBColorTable_(hdcDest,0,256,*_bpalette) 
  
  GdiFlush_()
  SetDIBits_(hdcSrc, hImageOut, 0, h, *bits, @bmi, #DIB_PAL_COLORS) 
  
  DeleteDC_(dc)
  DeleteDC_(hdcSrc)
  DeleteDC_(hdcDest)
  
  FreeMemory(*bits) 
  FreeMemory(*_bpalette) 
  
  ProcedureReturn hImageOut 

EndProcedure

; UseJPEGImageDecoder() 
; If FileSize("girl.jpg")= -1 
;   InitNetwork() 
;   ReceiveHTTPFile("http://www.lloydsplace.com/girl.jpg", "girl.jpg") 
; EndIf 
; 
; If FileSize("girl.jpg")= -1 
;   Debug "Image not found. Terminating..."
;   End
; EndIf

; hImage = LoadImage(#PB_Any, "Z:\GoogleDrive\speccy\udjeednext\mario2.bmp") 
; 
; i = ImageTo8bit(ImageID(hImage), 1) 
; 
; ; save to a bitmap file 
; Save8bitImage(i, "Z:\GoogleDrive\speccy\udjeednext\mario2-out.bmp") 
; 
; ; save to memory 
; *image = Save8bitImage(i, "", 1) 
; 
; ; test memory image 
; j = CatchImage(#PB_Any, *image) 
; 
; ; Let's take a look at the results...
; 
; OpenWindow(0,0,0,ImageWidth(j),ImageHeight(j),"") 
; ImageGadget(0,0,0,0,0,ImageID(j))
; Repeat
;   ev = WaitWindowEvent()
; 
; Until ev=#PB_Event_CloseWindow
; IDE Options = PureBasic 5.60 (Windows - x86)
; CursorPosition = 60
; FirstLine = 22
; Folding = i-
; EnableXP