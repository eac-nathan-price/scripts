#Requires AutoHotkey v2.0

; --- Helper function to check if Autodesk Fusion is active ---
IsFusionActive() {
    WinGetTitle(&title, "A")
    return InStr(title, "Autodesk Fusion")
}

; --- Ctrl + ` → Hold MMB ---
^`:: {
    if !IsFusionActive()
        return
    Send("{MButton down}")
    KeyWait("Ctrl") ; Wait until Ctrl is released
    KeyWait("`")
    Send("{MButton up}")
}

; --- Ctrl + Shift + ~ → Hold Shift + MMB ---
^+~:: {
    if !IsFusionActive()
        return
    Send("{Shift down}{MButton down}")
    KeyWait("Ctrl")
    KeyWait("Shift")
    KeyWait("`")  ; ~ is Shift + `
    Send("{MButton up}{Shift up}")
}
