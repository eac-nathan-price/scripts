#Requires AutoHotkey v2.0

; --- Helper function to check if Autodesk Fusion is active ---
IsFusionActive() {
    title := WinGetTitle("A")
    return InStr(title, "Autodesk Fusion")
}

; --- Ctrl + ` → Hold MMB (only in Fusion) ---
^`:: {
    if IsFusionActive() {
        Send("{MButton down}")
        KeyWait("Ctrl")
        KeyWait("``")
        Send("{MButton up}")
    } else {
        ; Pass through original keys to other apps
        Send("^``")
    }
}

; --- Ctrl + Shift + ` (aka ~) → Hold Shift + MMB (only in Fusion) ---
^+`:: {
    if IsFusionActive() {
        Send("{Shift down}{MButton down}")
        KeyWait("Ctrl")
        KeyWait("Shift")
        KeyWait("``")
        Send("{MButton up}{Shift up}")
    } else {
        ; Pass through to other apps
        Send("^+``")
    }
}
