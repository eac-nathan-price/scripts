#Requires AutoHotkey v2.0

; --- Function to check if Fusion is active ---
IsFusionActive() {
    title := WinGetTitle("A")
    return InStr(title, "Autodesk Fusion")
}

; --- Hotkey: Ctrl + ` ---
^`:: {
    if IsFusionActive() {
        ; Hold middle mouse button
        Send("{MButton down}")
        KeyWait("Ctrl")
        KeyWait("``")
        Send("{MButton up}")
    } else {
        ; Pass through normally to other apps without triggering this hotkey again
        SendInput("{Blind}^``")
    }
}

; --- Hotkey: Ctrl + Shift + ` (aka ~) ---
^+`:: {
    if IsFusionActive() {
        ; Hold Shift + MMB
        Send("{Shift down}{MButton down}")
        KeyWait("Ctrl")
        KeyWait("Shift")
        KeyWait("``")
        Send("{MButton up}{Shift up}")
    } else {
        ; Pass through normally
        SendInput("{Blind}^+``")
    }
}
