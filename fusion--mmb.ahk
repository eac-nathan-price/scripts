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
    ; Wait for release of either Ctrl or `
    KeyWait("Ctrl")
    KeyWait("``") ; escape the backtick key properly
    Send("{MButton up}")
}

; --- Ctrl + Shift + ~ → Hold Shift + MMB ---
^+`:: {
    if !IsFusionActive()
        return
    Send("{Shift down}{MButton down}")
    ; Wait for release of any of the modifier keys
    KeyWait("Ctrl")
    KeyWait("Shift")
    KeyWait("``")
    Send("{MButton up}{Shift up}")
}
