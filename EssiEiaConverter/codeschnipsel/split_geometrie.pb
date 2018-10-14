
Global Dim segment.s(0)
Procedure split(in$)
  ; Trennt eine Geometrie in Segmente
  If (Mid(in$,1,1) =  "+" Or  Mid(in$,1,1) =  "-")
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
      ReDim segment(i+1) 
      segment(i+1) = Mid(in$,t1,t2)
    Next
    segment(0) = Str(ListSize(vorzeichen()))
    ProcedureReturn  ListSize(vorzeichen())
  Else
    ; darf nicht mit einer Hilfsfunktion beginnen oder Eingabe ist leer.
    segment(0) = "-1"
    ProcedureReturn  -1
  EndIf
EndProcedure


Procedure show()
  Debug "-------------------"
  temp = Val(segment(0))
  Debug temp
  If temp > 0
    For i=0 To temp-1
      Debug segment(i+1) 
    Next
  ElseIf temp = -1
      Debug "FEHLER"
  EndIf
EndProcedure



split("+")
show()
split("")
show()
split("5+5")
show()
split("+10-102+10-10+4")
show()
split("+-+-+")
show()
split("-+-+-")
show()

; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; CursorPosition = 48
; FirstLine = 1
; Folding = -
; EnableUnicode
; EnableXP