#SingleInstance Force
#UseHook On

; Check if Autodesk Fusion is active
IsFusionActive() {
    WinGetTitle, winTitle, A
    return InStr(winTitle, "Autodesk Fusion")
}

; --- Ctrl + M ---
^m::
    if (IsFusionActive()) {
        SendInput, {MButton down}       ; Hold middle mouse
        KeyWait, M                      ; Wait until M released
        SendInput, {MButton up}         ; Release MMB
    } else {
        Send, ^m                         ; Pass through normally in other apps
    }
return

; --- Ctrl + Shift + M ---
^+m::
    if (IsFusionActive()) {
        SendInput, {Shift down}{MButton down} ; Hold Shift + MMB
        KeyWait, M
        SendInput, {MButton up}{Shift up}     ; Release both
    } else {
        Send, ^+m                              ; Pass through normally
    }
return
