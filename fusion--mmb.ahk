#SingleInstance Force
#UseHook On

*Alt::
    ; Get the active window title
    WinGetTitle, winTitle, A

    ; Check if "Autodesk Fusion" is in the title
    if InStr(winTitle, "Autodesk Fusion") {
        SendInput, {MButton down}   ; Hold middle mouse button
        KeyWait, Alt                ; Wait until Alt is released
        SendInput, {MButton up}     ; Release middle mouse button
        return                      ; Stop here (don't send Alt)
    } else {
        ; If not Fusion, let Alt behave normally
        Send, {Blind}{Alt down}
        KeyWait, Alt
        Send, {Blind}{Alt up}
    }
return
