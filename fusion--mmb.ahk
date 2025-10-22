#SingleInstance Force

; Function to check if active window contains "Autodesk Fusion"
IsFusionActive() {
    WinGetTitle, winTitle, A
    return InStr(winTitle, "Autodesk Fusion")
}

*Alt::
    if (IsFusionActive()) {
        SendInput, {MButton down}   ; Hold middle mouse
        KeyWait, Alt                ; Wait until Alt is released
        SendInput, {MButton up}     ; Release middle mouse
    } else {
        SendInput, {Alt down}       ; Normal Alt behavior
        KeyWait, Alt
        SendInput, {Alt up}
    }
return
