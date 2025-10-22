#Requires AutoHotkey v2.0

; --- Function to check if Fusion is active ---
IsFusionActive() {
    title := WinGetTitle("A")
    return InStr(title, "Autodesk Fusion")
}

; --- Ctrl + ` → Hold MMB ---
^`:: {
    if !IsFusionActive()
        return  ; do nothing outside Fusion
    Send("{MButton down}")
    ; Wait for key release
    KeyWait("Ctrl")
    KeyWait("``")
    Send("{MButton up}")
}

; --- Ctrl + Shift + ` → Hold Shift + MMB ---
^+`:: {
    if !IsFusionActive()
        return  ; do nothing outside Fusion
    Send("{Shift down}{MButton down}")
    KeyWait("Ctrl")
    KeyWait("Shift")
    KeyWait("``")
    Send("{MButton up}{Shift up}")
}
