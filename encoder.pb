; ------------------------------------------
; encoder.pb
; Takt / Richtung => Encoder
;
; 2019-12-25    MagdaNC
;
; ------------------------------------------
EnableExplicit

#Inputs  = 3
#Outputs = 3
Global freigabe.d = 0         ; Interne Freigabe
Global takt.d = 0             ; Interner Takt
Global schritt.d = 0          ; Interner Schritt

Structure sDLLParams
  DLLParam.d[100]
EndStructure

; return number of input channels...
ProcedureDLL.b NumInputs()
  ProcedureReturn #Inputs
EndProcedure

; return number of ouput channels...
ProcedureDLL.b NumOutputs()

  ProcedureReturn #Outputs
EndProcedure

; return name for each input...
ProcedureDLL GetInputName(Channel.b, *Name_i)

  Protected GetInputName.s

  If Channel = 0
    GetInputName = "power"
  ElseIf Channel = 1
    GetInputName = "takt"
  ElseIf Channel = 2
    GetInputName = "right"
  Else
    GetInputName = "U"
  EndIf

  PokeS(*Name_i, GetInputName, -1, #PB_Ascii)

EndProcedure

; return name for each output...
ProcedureDLL GetOutputName(Channel.b, *Name_i)

  Protected GetOutputName.s

  If Channel = 0
    GetOutputName = "power"
  ElseIf Channel = 1
    GetOutputName = "A"
  ElseIf Channel = 2
    GetOutputName = "B"
  Else
    GetOutputName = "U"
  EndIf

  PokeS(*Name_i, GetOutputName, -1, #PB_Ascii)

EndProcedure

; check inputs and set outputs while running...
ProcedureDLL CCalculate(*PInput.sDLLParams, *POutput.sDLLParams, *PUser.sDLLParams)

 
    If *PInput\DLLParam[0] > 2.5         ;  ON / OFF
      *POutput\DLLParam[0] = 10          ;  LED = POWER ON
      
        ;interne freigabe
    If  *PInput\DLLParam[1] < 2.5
      freigabe = 10
    EndIf  
    
    If takt < 2.5
      If freigabe > 2.5
        If  *PInput\DLLParam[1] > 2.5
          takt = 10
          freigabe = 0
        EndIf
      EndIf
    EndIf

      ; Zähler vorwärts
      If *PInput\DLLParam[2] < 2.5

        ; Step 1
      If takt > 2.5 
         If schritt = 0
            *POutput\DLLParam[1] = 10
            *POutput\DLLParam[2] = 10
            schritt = 1                     
            takt = 0
         EndIf
      EndIf   
         ; Step 2
      If takt > 2.5 
         If schritt = 1
            *POutput\DLLParam[1] = 0
            *POutput\DLLParam[2] = 10
            schritt = 2                     
            takt = 0
         EndIf
       EndIf
       ; Step 3
      If takt > 2.5 
         If schritt = 2
            *POutput\DLLParam[1] = 0;
            *POutput\DLLParam[2] = 0;
            schritt = 3;                     
            takt = 0;
         EndIf
       EndIf
       ; Step 4
      If takt > 2.5 
         If schritt = 3
            *POutput\DLLParam[1] = 10;
            *POutput\DLLParam[2] = 0;
            schritt = 0;                     
            takt = 0;
         EndIf
       EndIf
     EndIf
     ; Zähler rückwärts
      If *PInput\DLLParam[2] > 2.5

        ; Step 1
      If takt > 2.5 
         If schritt = 2
            *POutput\DLLParam[1] = 10
            *POutput\DLLParam[2] = 10
            schritt = 1                     
            takt = 0
         EndIf
      EndIf   
         ; Step 2
      If takt > 2.5 
         If schritt = 3
            *POutput\DLLParam[1] = 0
            *POutput\DLLParam[2] = 10
            schritt = 2                     
            takt = 0
         EndIf
       EndIf
       ; Step 3
      If takt > 2.5 
         If schritt = 0
            *POutput\DLLParam[1] = 0;
            *POutput\DLLParam[2] = 0;
            schritt = 3;                     
            takt = 0;
         EndIf
       EndIf
       ; Step 4
      If takt > 2.5 
         If schritt = 1
            *POutput\DLLParam[1] = 10;
            *POutput\DLLParam[2] = 0;
            schritt = 0;                     
            takt = 0;
         EndIf
       EndIf
    EndIf
   Else
     *POutput\DLLParam[0] = 0    ;  LED = POWER OFF
   EndIf
EndProcedure

; called when project is started...
ProcedureDLL CSimStart(*PInput.sDLLParams, *POutput.sDLLParams, *PUser.sDLLParams)
  
  *POutput\DLLParam[0] = 0;          // LED POWER
  
  ; state on track
  If *PUser\DLLParam[0] = 1
    *POutput\DLLParam[1] = 10;         // A
  Else
    *POutput\DLLParam[1] = 0;         // A
  EndIf
  If *PUser\DLLParam[1] = 1
    *POutput\DLLParam[2] = 10;          // B
  Else
    *POutput\DLLParam[2] = 0;          // B
  EndIf
  
  ; internal step
  If *PUser\DLLParam[0] = 1 And *PUser\DLLParam[1] = 1
    schritt = 1
  ElseIf *PUser\DLLParam[0] = 0 And *PUser\DLLParam[1] = 1
    schritt = 2    
  ElseIf *PUser\DLLParam[0] = 0 And *PUser\DLLParam[1] = 0
    schritt = 3
  ElseIf *PUser\DLLParam[0] = 1 And *PUser\DLLParam[1] = 0
    schritt = 0
  EndIf
  
EndProcedure

; called when project is stopped...
ProcedureDLL CSimStop(*PInput.sDLLParams, *POutput.sDLLParams, *PUser.sDLLParams)

  ; nothing to do...

EndProcedure

; called when button CONFIGURE is pressed in dialogue...
ProcedureDLL CConfigure(*PUser.sDLLParams)

  ;MessageRequester("Configure", "Nothing to configure")

  Protected Event.i, EventGadget.i, EventType.i, EventWindow.i
  Protected quit.i, outA.d, outB.d

  If OpenWindow(0, 434, 196, 250, 170, "Configure", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_TitleBar)
    
    TextGadget(#PB_Any,40,3,100,20,"Pegel bei DLL-Start")
    CheckBoxGadget(0,40,30,125,30,"Spur A")
    CheckBoxGadget(1, 40, 60, 125, 30, "Spur B")
    ButtonGadget(2, 40, 105, 50, 40, "OK")
    ButtonGadget(3, 120, 105, 50, 40, "close")
   
    outA = *PUser\DLLParam[0]
    outB = *PUser\DLLParam[1]
    
    If outA = 1
      SetGadgetState(0, #PB_Checkbox_Checked)
    Else
      SetGadgetState(0, #PB_Checkbox_Unchecked)
    EndIf
    If outB = 1
      SetGadgetState(1, #PB_Checkbox_Checked)
    Else
      SetGadgetState(1, #PB_Checkbox_Unchecked)
    EndIf
    
   
    Repeat

      Event       = WaitWindowEvent()
      EventGadget = EventGadget()
      EventType   = EventType()
      EventWindow = EventWindow()

      Select Event

        Case #PB_Event_Gadget

          If EventGadget = 0

          ElseIf EventGadget = 1

          ElseIf EventGadget = 2
            
            If GetGadgetState(0) = #PB_Checkbox_Checked  
              *PUser\DLLParam[0] = 1
            Else
              *PUser\DLLParam[0] = 0
            EndIf
            
            If GetGadgetState(1) = #PB_Checkbox_Checked  
              *PUser\DLLParam[1] = 1
            Else
              *PUser\DLLParam[1] = 0
            EndIf
            
            
            quit = 1
          ElseIf EventGadget = 3
            quit = 1
          EndIf

        Case #PB_Event_CloseWindow

          quit = 1

      EndSelect

    Until quit = 1

    CloseWindow(0)

  EndIf

EndProcedure
; IDE Options = PureBasic 5.42 LTS (Windows - x86)
; ExecutableFormat = Shared dll
; CursorPosition = 1
; Folding = --
; Executable = encoder.dll
; DPIAware