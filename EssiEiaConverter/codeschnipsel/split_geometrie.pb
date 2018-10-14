Procedure split(in$)
  ; Trennt eine Geometrie in Segmente
  ; darf nicht mit einer Hilfsfunktion beginnen.
  NewList vorzeichen()
  laenge = Len(in$)
  For i=0 To laenge-1
    seg$ = Mid(in$,i+1,1)
    If (seg$ = "+" Or seg$ = "-")
      AddElement(vorzeichen())
       vorzeichen() = i
      EndIf
    Next
    
    For i=0 To ListSize(vorzeichen())-1
      SelectElement(vorzeichen(),i)
      start = vorzeichen()+1
      If (i+1 > ListSize(vorzeichen())-1)
        ; kein weiterer Eintrag
        ende = laenge
       Else
         SelectElement(vorzeichen(),i+1)
        ende = vorzeichen()
      EndIf
      t1 = start
      t2 =  ende - (start-1)
      Debug Str(start) + "--" + Str(ende)+ "   --> " + Mid(in$,t1,t2)
      Next
EndProcedure




split("+10-102+10-10+4")
Debug "----"
split("+-+-+")
Debug "----"
split("-+-+-")

; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 36
; Folding = -
; EnableUnicode
; EnableXP