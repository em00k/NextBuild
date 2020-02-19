; assume this is the proper dir
;OpenConsole()
NM$=ProgramParameter(1)
LogPath$=ProgramParameter(0)
Dim lines$(256)
;LogPath$="Z:\NextBuild6\Logs\COMPILE.txt"
;LogPath$=fullpath$
If ReadFile(0,LogPath$)
  While Not Eof(0)
    line$=ReadString(0)
    Debug line$
    If FindString(line$,"Syntax Error. Unexpected token")
      out$=line$
     Break 
   EndIf 
    If FindString(line$,"Cannot Convert")
      out$=line$
     Break 
   EndIf 
   
    If FindString(line$,"Type error:")
      out$=line$
     Break 
   EndIf 
   
   
    If FindString(line$,"Unexpected ")
      out$=line$
     Break 
   EndIf 
   
  ;If Len(line$)>0
  ;   out$=line$
  ; EndIf 
  Wend 
  CloseFile(0)
EndIf
;PrintN(out$+#CRLF$)
location=FindString(out$,"temp.bas",1)
newstring$=Mid(out$,location)
If NM$<>"/q"
  MessageRequester("Compile Error",newstring$)
EndIf 
RunProgram("cmd.exe","/c echo:"+#DQUOTE$+newstring$+#DQUOTE$,"")
End 1

; IDE Options = PureBasic 5.70 LTS (Windows - x86)
; ExecutableFormat = Console
; CursorPosition = 5
; EnableXP
; Executable = errorline.exe