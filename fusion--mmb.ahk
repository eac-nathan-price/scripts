#SingleInstance Force
#UseHook On

; Helper function to check if active window is Autodesk Fusion
IsFusionActive() {
    WinGetTitle, winTitle, A
    return InStr(winTitle, "Autodesk Fusion")
}

; --- Alt + Right Mouse Button (handles Shift inside) ---
~Alt & RButton::
    if (IsFusionActive()) {
        ; Check if Shift is held
        if GetKeyState("Shift", "P") {
            SendInput, {Shift down}{MButton down}   ; Hold Shift + MMB
            KeyWait, RButton
            SendInput, {MButton up}{Shift up}       ; Release both
        } else {
            SendInput, {MButton down}               ; Hold MMB
            KeyWait, RButton
            SendInput, {MButton up}                 ; Release MMB
        }
        return
    } else {
        Click, right                                 ; Normal RMB
    }
return
