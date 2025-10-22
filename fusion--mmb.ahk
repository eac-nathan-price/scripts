#Requires AutoHotkey v2.0

; --- Helper function to check if Autodesk Fusion is active ---
IsFusionActive() {
    title := WinGetTitle("A")
    return InStr(title, "Autodesk Fusion")
}

; --- Ctrl + ` → Hold MMB ---
^`:: {
    if !IsFusionActive()
        return
    Send("{MButton down}")
    ; Wait for release of either Ctrl or `
    KeyWait("Ctrl")
    KeyWait("``") ; Escaped backtick
    Send("{MButton up}")
}

; --- Ctrl + Shift + ~ → Hold Shift + MMB ---
^+`:: {
    if !IsFusionActive()
        return
    Send("{Shift down}{MButton down}")
    ; Wait for release of modifiers
    KeyWait("Ctrl")
    KeyWait("Shift")
    KeyWait("``")
    Send("{MButton up}{Shift up}")
}
